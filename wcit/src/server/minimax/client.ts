import type { ChatAssistantResponse } from '#/lib/api'
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
    content?: string
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

function stripCodeFences(raw: string): string {
  const trimmed = raw.trim()
  const fenced = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i)
  return fenced?.[1]?.trim() ?? trimmed
}

function parseAssistantPayload(raw: string): ChatAssistantResponse {
  try {
    const parsed = JSON.parse(stripCodeFences(raw)) as ChatAssistantResponse

    if (
      parsed &&
      typeof parsed === 'object' &&
      'success' in parsed &&
      parsed.success === true &&
      typeof parsed.message === 'string' &&
      parsed.data &&
      typeof parsed.data.message === 'string'
    ) {
      return parsed
    }

    if (
      parsed &&
      typeof parsed === 'object' &&
      'success' in parsed &&
      parsed.success === false &&
      typeof parsed.message === 'string' &&
      Array.isArray(parsed.errors)
    ) {
      return parsed
    }

    return {
      success: true,
      message: 'Assistant reply received',
      data: {
        message: typeof raw === 'string' && raw.trim() ? raw : '_No answer._',
      },
    }
  } catch {
    return {
      success: true,
      message: 'Assistant reply received',
      data: {
        message: raw.trim() || '_No answer._',
      },
    }
  }
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
      role: item.role,
      content: item.content,
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

  const content = payload.choices?.[0]?.message?.content
  if (!content?.trim()) {
    return {
      success: true,
      message: 'No model content returned',
      data: {
        message:
          '_I could not generate an answer yet. Please share the car make, model, year, and your budget so I can help._',
      },
    }
  }

  return parseAssistantPayload(content)
}
