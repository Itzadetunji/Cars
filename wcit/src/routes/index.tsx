import { ClientOnly, createFileRoute } from '@tanstack/react-router'

import { CameraCapture } from '#/components/camera-capture'

export const Route = createFileRoute('/')({ component: Home })

function Home() {
  return (
    <main className="min-h-svh p-6 md:p-10">
      <ClientOnly fallback={<CameraFallback />}>
        <CameraCapture />
      </ClientOnly>
    </main>
  )
}

function CameraFallback() {
  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-2">
      <h1 className="text-3xl font-bold tracking-tight">Camera verify</h1>
      <p className="text-muted-foreground text-sm">Loading camera…</p>
    </div>
  )
}
