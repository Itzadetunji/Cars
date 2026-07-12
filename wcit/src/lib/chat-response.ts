import type {
  ChatAssistantResponse,
  ChatAssistantSuccessResponse,
  ErrorResponse,
} from '#/lib/api'

function successReply(
  markdown: string,
  envelopeMessage = 'Assistant reply received',
): ChatAssistantSuccessResponse {
  return {
    success: true,
    message: envelopeMessage,
    data: {
      message: markdown.trim() || '_No answer._',
    },
  }
}

function isErrorResponse(value: unknown): value is ErrorResponse {
  if (!value || typeof value !== 'object') return false
  const candidate = value as Record<string, unknown>
  return (
    candidate.success === false &&
    typeof candidate.message === 'string' &&
    Array.isArray(candidate.errors)
  )
}

function stripCodeFences(raw: string): string {
  const trimmed = raw.trim()
  const fenced = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i)
  return fenced?.[1]?.trim() ?? trimmed
}

function tryParseJson(raw: string): unknown | null {
  const cleaned = stripCodeFences(raw)

  try {
    return JSON.parse(cleaned)
  } catch {
    // continue
  }

  const start = cleaned.indexOf('{')
  const end = cleaned.lastIndexOf('}')
  if (start === -1 || end <= start) return null

  try {
    return JSON.parse(cleaned.slice(start, end + 1))
  } catch {
    return null
  }
}

/**
 * Recover markdown from common malformed model outputs, e.g.
 * data: { "actual markdown...": null } or data: "markdown"
 */
function extractMarkdownFromData(data: unknown): string | null {
  if (typeof data === 'string' && data.trim()) {
    // data.message accidentally contains another full envelope
    const nested = unwrapAssistantMarkdown(data)
    return nested
  }

  if (!data || typeof data !== 'object' || Array.isArray(data)) return null

  const record = data as Record<string, unknown>
  const preferredKeys = ['message', 'content', 'text', 'answer', 'markdown']

  for (const key of preferredKeys) {
    const value = record[key]
    if (typeof value === 'string' && value.trim()) {
      return unwrapAssistantMarkdown(value)
    }
  }

  const stringEntries = Object.entries(record).filter(
    (entry): entry is [string, string] =>
      typeof entry[1] === 'string' && entry[1].trim().length > 0,
  )

  if (stringEntries.length === 1) {
    return unwrapAssistantMarkdown(stringEntries[0][1])
  }

  // Model put the answer as an object KEY instead of data.message
  const longKeys = Object.keys(record)
    .map((key) => key.trim())
    .filter((key) => key.length > 40)

  if (longKeys.length === 1) return longKeys[0]

  if (longKeys.length > 1) {
    return longKeys.sort((a, b) => b.length - a.length)[0]
  }

  return null
}

function parseParsedPayload(parsed: unknown): ChatAssistantResponse {
  if (isErrorResponse(parsed)) return parsed

  if (!parsed || typeof parsed !== 'object') {
    return successReply('_No answer._')
  }

  const record = parsed as Record<string, unknown>
  const envelopeMessage =
    typeof record.message === 'string' && record.message.trim()
      ? record.message
      : 'Assistant reply received'

  if ('data' in record) {
    const markdown = extractMarkdownFromData(record.data)
    if (markdown) return successReply(markdown, envelopeMessage)
  }

  const fallbackMarkdown = extractMarkdownFromData(record)
  if (fallbackMarkdown && fallbackMarkdown !== envelopeMessage) {
    return successReply(fallbackMarkdown, envelopeMessage)
  }

  if (record.success === true) {
    return successReply(
      '_I need a bit more detail to help. What is your budget, and are you buying new or used?_',
      envelopeMessage,
    )
  }

  return successReply('_No answer._', envelopeMessage)
}

/**
 * If the UI/history somehow stored a full API envelope JSON string,
 * peel it down to the user-facing markdown in data.message.
 */
export function unwrapAssistantMarkdown(content: string): string {
  let current = content.trim()

  for (let attempt = 0; attempt < 3; attempt += 1) {
    if (!current.startsWith('{') && !current.startsWith('```')) {
      return current
    }

    const parsed = tryParseJson(current)
    if (!parsed || typeof parsed !== 'object') {
      return current
    }

    const record = parsed as Record<string, unknown>
    if (!('success' in record) && !('data' in record)) {
      return current
    }

    const normalized = parseParsedPayload(parsed)
    if (!normalized.success) {
      return [
        `**${normalized.message}**`,
        '',
        ...normalized.errors.map((error) => `- ${error}`),
      ].join('\n')
    }

    const next = normalized.data.message.trim()
    if (!next || next === current) return next || content
    current = next
  }

  return current
}

/** Normalize MiniMax content (string or already-parsed object) into our API shape. */
export function normalizeAssistantPayload(
  content: unknown,
): ChatAssistantResponse {
  if (content && typeof content === 'object') {
    return parseParsedPayload(content)
  }

  if (typeof content !== 'string' || !content.trim()) {
    return successReply(
      '_I could not generate an answer yet. Please share the car make, model, year, and your budget so I can help._',
      'No model content returned',
    )
  }

  const parsed = tryParseJson(content)
  if (parsed) return parseParsedPayload(parsed)

  // Plain markdown / text fallback
  return successReply(content)
}
