import { useEffect, useRef, useState } from 'react'
import { useForm } from '@tanstack/react-form'
import { useMutation } from '@tanstack/react-query'
import { ArrowUp, Loader2 } from 'lucide-react'
import Markdown from 'react-markdown'

import { Button } from '#/components/ui/button'
import { submitMessage } from '#/server/submit-message'
import { cn } from '#/lib/utils'
import type { ChatAssistantResponse } from '#/lib/api'

type ChatMessage = {
  id: string
  role: 'user' | 'assistant'
  content: string
}

export function ChatPrompt() {
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const listRef = useRef<HTMLDivElement>(null)
  const [messages, setMessages] = useState<ChatMessage[]>([])

  const mutation = useMutation({
    mutationFn: async (input: {
      message: string
      history: Array<{ role: 'user' | 'assistant'; content: string }>
    }) => {
      return submitMessage({ data: input })
    },
  })

  const form = useForm({
    defaultValues: {
      message: '',
    },
    onSubmit: async ({ value, formApi }) => {
      const message = value.message.trim()
      if (!message || mutation.isPending) return

      const history = messages.map(({ role, content }) => ({ role, content }))

      setMessages((prev) => [
        ...prev,
        {
          id: crypto.randomUUID(),
          role: 'user',
          content: message,
        },
      ])
      formApi.reset()
      resizeTextarea()

      try {
        const response = (await mutation.mutateAsync({
          message,
          history,
        })) as ChatAssistantResponse

        if (response.success) {
          setMessages((prev) => [
            ...prev,
            {
              id: crypto.randomUUID(),
              role: 'assistant',
              content: response.data.message,
            },
          ])
          return
        }

        setMessages((prev) => [
          ...prev,
          {
            id: crypto.randomUUID(),
            role: 'assistant',
            content: [
              `**${response.message}**`,
              '',
              ...response.errors.map((error) => `- ${error}`),
            ].join('\n'),
          },
        ])
      } catch {
        // Error UI handled via mutation state
      }
    },
  })

  const hasMessages = messages.length > 0

  useEffect(() => {
    const node = listRef.current
    if (!node) return
    node.scrollTop = node.scrollHeight
  }, [messages.length, mutation.isPending, mutation.isError])

  function resizeTextarea() {
    const el = textareaRef.current
    if (!el) return
    el.style.height = '0px'
    el.style.height = `${Math.min(el.scrollHeight, 200)}px`
  }

  return (
    <div className="mx-auto flex h-[min(100svh-3rem,52rem)] w-full max-w-2xl flex-col">
      <div
        ref={listRef}
        className="flex min-h-0 flex-1 flex-col gap-6 overflow-y-auto px-1 pb-6"
      >
        {!hasMessages ? (
          <div className="flex flex-1 flex-col items-center justify-center gap-3 px-4 text-center">
            <h1 className="text-balance text-3xl font-bold tracking-tight md:text-4xl">
              I want to get a car
            </h1>
            <p className="text-muted-foreground max-w-md text-pretty text-sm md:text-base">
              Tell me the car you’re considering — I’ll help with price,
              reliability, safety, ownership costs, and how it compares.
            </p>
          </div>
        ) : (
          messages.map((message) => (
            <div
              key={message.id}
              className={cn(
                'flex w-full',
                message.role === 'user' ? 'justify-end' : 'justify-start',
              )}
            >
              <div
                className={cn(
                  'max-w-[85%] rounded-3xl px-4 py-3 text-sm leading-relaxed',
                  message.role === 'user'
                    ? 'bg-primary text-primary-foreground rounded-br-lg text-pretty'
                    : 'bg-muted text-foreground rounded-bl-lg',
                )}
              >
                {message.role === 'user' ? (
                  message.content
                ) : (
                  <div className="prose prose-sm dark:prose-invert max-w-none prose-p:my-2 prose-headings:mb-2 prose-headings:mt-3 prose-ul:my-2 prose-li:my-0.5">
                    <Markdown>{message.content}</Markdown>
                  </div>
                )}
              </div>
            </div>
          ))
        )}

        {mutation.isPending && (
          <div className="flex justify-start">
            <div className="bg-muted text-muted-foreground flex items-center gap-2 rounded-3xl rounded-bl-lg px-4 py-3 text-sm">
              <Loader2 className="size-4 animate-spin" />
              Thinking…
            </div>
          </div>
        )}

        {mutation.isError && (
          <div className="border-destructive/30 bg-destructive/5 text-destructive rounded-2xl border px-4 py-3 text-sm">
            {mutation.error instanceof Error
              ? mutation.error.message
              : 'Something went wrong'}
          </div>
        )}
      </div>

      <form
        className="sticky bottom-0 pt-2"
        onSubmit={(event) => {
          event.preventDefault()
          event.stopPropagation()
          void form.handleSubmit()
        }}
      >
        <form.Field name="message">
          {(field) => {
            const canSend =
              field.state.value.trim().length > 0 && !mutation.isPending

            return (
              <div className="bg-background/90 rounded-[1.75rem] border p-2 shadow-[0_1px_2px_rgba(0,0,0,0.04),0_8px_24px_rgba(0,0,0,0.06)] backdrop-blur-sm">
                <div className="flex items-end gap-2">
                  <textarea
                    ref={textareaRef}
                    name={field.name}
                    value={field.state.value}
                    rows={1}
                    placeholder="e.g. Toyota Camry 2022 — is it worth buying?"
                    aria-label="Message"
                    className="placeholder:text-muted-foreground max-h-[200px] min-h-12 w-full resize-none bg-transparent px-3 py-3 text-base leading-6 outline-none md:text-sm"
                    onBlur={field.handleBlur}
                    onChange={(event) => {
                      field.handleChange(event.target.value)
                      resizeTextarea()
                    }}
                    onKeyDown={(event) => {
                      if (event.key === 'Enter' && !event.shiftKey) {
                        event.preventDefault()
                        if (canSend) void form.handleSubmit()
                      }
                    }}
                  />
                  <Button
                    type="submit"
                    size="icon"
                    disabled={!canSend}
                    className="mb-1 size-9 shrink-0 rounded-full active:scale-[0.96]"
                    aria-label="Send message"
                  >
                    {mutation.isPending ? (
                      <Loader2 className="animate-spin" />
                    ) : (
                      <ArrowUp />
                    )}
                  </Button>
                </div>
              </div>
            )
          }}
        </form.Field>
        <p className="text-muted-foreground mt-2 text-center text-xs">
          Enter to send · Shift + Enter for a new line
        </p>
      </form>
    </div>
  )
}
