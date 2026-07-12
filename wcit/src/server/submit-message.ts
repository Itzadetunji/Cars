import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

import { askCarAdvisor } from '#/server/minimax/client'

const historyItemSchema = z.object({
  role: z.enum(['user', 'assistant']),
  content: z.string().trim().min(1),
})

const messageSchema = z.object({
  message: z.string().trim().min(1, 'Message is required'),
  history: z.array(historyItemSchema).max(40).optional(),
})

export const submitMessage = createServerFn({ method: 'POST' })
  .validator(messageSchema)
  .handler(async ({ data }) => {
    return askCarAdvisor({
      message: data.message,
      history: data.history,
    })
  })
