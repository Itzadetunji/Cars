export interface ErrorResponse {
  success: false
  message: string
  errors: string[]
}

export interface SuccessResponse<TData, TMeta = undefined> {
  success: true
  message: string
  data: TData
  meta?: TMeta
}

export interface Pagination {
  current_page: number
  total_pages: number
  total: number
  per_page: number
  from?: number
  to?: number
}

export interface PaginationMeta {
  pagination: Pagination
}

export type PaginatedSuccessResponse<TItem> = SuccessResponse<
  TItem[],
  PaginationMeta
>

export type MessageSuccessResponse = SuccessResponse<Record<string, never>>

/** Assistant payload: markdown lives in `data.message`. */
export type ChatAssistantData = {
  message: string
}

export type ChatAssistantSuccessResponse = SuccessResponse<ChatAssistantData>

export type ChatAssistantResponse =
  | ChatAssistantSuccessResponse
  | ErrorResponse
