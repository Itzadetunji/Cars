import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

const messageSchema = z.object({
  message: z.string().trim().min(1, 'Message is required'),
})

export const submitMessage = createServerFn({ method: 'POST' })
  .validator(messageSchema)
  .handler(async ({ data }) => {
    void data.message
    return true as const
  })
