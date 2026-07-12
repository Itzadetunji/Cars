import type { ChatAssistantResponse } from '#/lib/api'
import { normalizeAssistantPayload } from '#/lib/chat-response'
import { CAR_BUYER_SYSTEM_PROMPT } from './system-prompt'

const MINIMAX_API_URL = 'https://api.minimax.io/v1/text/chatcompletion_v2'
const MINIMAX_MODEL = process.env.MINIMAX_MODEL ?? 'MiniMax-M2.5'

type ChatRole = 'user' | 'assistant' | 'system'

export type MiniMaxChatMessage = {
  role: ChatRole
  content: string
}

type MiniMaxChoice = {
  message?: {
    content?: string | Record<string, unknown>
    reasoning_content?: string
  }
  finish_reason?: string
}

type MiniMaxApiResponse = {
  choices?: MiniMaxChoice[]
  base_resp?: {
    status_code?: number
    status_msg?: string
  }
  error?: {
    message?: string
  }
}

const responseJsonSchema = {
  type: 'json_schema' as const,
  json_schema: {
    name: 'chat_assistant_response',
    description:
      'Structured API envelope. data.message must contain markdown for the user.',
    schema: {
      type: 'object',
      additionalProperties: false,
      required: ['success', 'message', 'data'],
      properties: {
        success: {
          type: 'boolean',
          description: 'Always true for model replies',
        },
        message: {
          type: 'string',
          description: 'Short plain-text API status message',
        },
        data: {
          type: 'object',
          additionalProperties: false,
          required: ['message'],
          properties: {
            message: {
              type: 'string',
              description: 'Markdown content shown to the user',
            },
          },
        },
      },
    },
  },
}

function toModelHistoryContent(
  role: 'user' | 'assistant',
  content: string,
): string {
  if (role === 'user') return content

  // Prior assistant turns stay in the required JSON shape so format does not drift.
  // content here should already be markdown (UI unwraps envelopes before storing).
  return JSON.stringify({
    success: true,
    message: 'Prior assistant reply',
    data: { message: content },
  })
}

export async function askCarAdvisor(input: {
  message: string
  history?: Array<{ role: 'user' | 'assistant'; content: string }>
}): Promise<ChatAssistantResponse> {
  const apiKey = process.env.MINIMAX_API_KEY

  if (!apiKey) {
    return {
      success: false,
      message: 'MiniMax is not configured',
      errors: ['Set MINIMAX_API_KEY in your environment'],
    }
  }

  const messages: MiniMaxChatMessage[] = [
    { role: 'system', content: CAR_BUYER_SYSTEM_PROMPT },
    ...(input.history ?? []).map((item) => ({
      role: item.role as ChatRole,
      content: toModelHistoryContent(item.role, item.content),
    })),
    { role: 'user', content: input.message },
  ]

  const response = await fetch(MINIMAX_API_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: MINIMAX_MODEL,
      messages,
      temperature: 0.3,
      max_completion_tokens: 4096,
      response_format: responseJsonSchema,
    }),
  })

  const payload = (await response.json()) as MiniMaxApiResponse

  if (!response.ok) {
    return {
      success: false,
      message: 'MiniMax request failed',
      errors: [
        payload.error?.message ??
          payload.base_resp?.status_msg ??
          `HTTP ${response.status}`,
      ],
    }
  }

  if (payload.base_resp?.status_code && payload.base_resp.status_code !== 0) {
    return {
      success: false,
      message: 'MiniMax request failed',
      errors: [payload.base_resp.status_msg ?? 'Unknown MiniMax error'],
    }
  }

  return normalizeAssistantPayload(payload.choices?.[0]?.message?.content)
}
