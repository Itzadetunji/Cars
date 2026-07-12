import { useEffect, useRef, useState } from 'react'
import { useForm } from '@tanstack/react-form'
import { useMutation } from '@tanstack/react-query'
import { Camera, CameraOff, CheckCircle2, Loader2, Send } from 'lucide-react'

import { Button } from '#/components/ui/button'
import { verifyPhoto } from '#/server/verify-photo'

export function CameraCapture() {
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const streamRef = useRef<MediaStream | null>(null)

  const [previewUrl, setPreviewUrl] = useState<string | null>(null)
  const [cameraError, setCameraError] = useState<string | null>(null)
  const [cameraReady, setCameraReady] = useState(false)

  const mutation = useMutation({
    mutationFn: async (image: File) => {
      const formData = new FormData()
      formData.append('image', image)
      return verifyPhoto({ data: formData })
    },
  })

  const form = useForm({
    defaultValues: {
      image: null as File | null,
    },
    onSubmit: async ({ value }) => {
      if (!value.image) return
      await mutation.mutateAsync(value.image)
    },
  })

  useEffect(() => {
    let cancelled = false

    async function startCamera() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: { ideal: 'environment' } },
          audio: false,
        })

        if (cancelled) {
          for (const track of stream.getTracks()) track.stop()
          return
        }

        streamRef.current = stream
        if (videoRef.current) {
          videoRef.current.srcObject = stream
          await videoRef.current.play()
        }
        setCameraReady(true)
        setCameraError(null)
      } catch {
        setCameraError(
          'Camera access was denied or is unavailable in this browser.',
        )
        setCameraReady(false)
      }
    }

    void startCamera()

    return () => {
      cancelled = true
      for (const track of streamRef.current?.getTracks() ?? []) track.stop()
      streamRef.current = null
    }
  }, [])

  useEffect(() => {
    return () => {
      if (previewUrl) URL.revokeObjectURL(previewUrl)
    }
  }, [previewUrl])

  function capturePhoto() {
    const video = videoRef.current
    const canvas = canvasRef.current
    if (!video || !canvas || !cameraReady) return

    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    const context = canvas.getContext('2d')
    if (!context) return

    context.drawImage(video, 0, 0, canvas.width, canvas.height)
    canvas.toBlob(
      (blob) => {
        if (!blob) return
        const file = new File([blob], `capture-${Date.now()}.jpg`, {
          type: 'image/jpeg',
        })
        form.setFieldValue('image', file)
        setPreviewUrl((prev) => {
          if (prev) URL.revokeObjectURL(prev)
          return URL.createObjectURL(file)
        })
        mutation.reset()
      },
      'image/jpeg',
      0.92,
    )
  }

  function clearCapture() {
    form.setFieldValue('image', null)
    setPreviewUrl((prev) => {
      if (prev) URL.revokeObjectURL(prev)
      return null
    })
    mutation.reset()
  }

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-6">
      <div className="space-y-2">
        <h1 className="text-3xl font-bold tracking-tight">Camera verify</h1>
        <p className="text-muted-foreground text-sm">
          Capture a photo, send it to the backend, and get <code>true</code>{' '}
          back.
        </p>
      </div>

      <div className="bg-muted relative overflow-hidden rounded-xl border aspect-[4/3]">
        {previewUrl ? (
          <img
            src={previewUrl}
            alt="Captured preview"
            className="size-full object-cover"
          />
        ) : (
          <video
            ref={videoRef}
            playsInline
            muted
            className="size-full object-cover"
          />
        )}

        {!cameraReady && !previewUrl && (
          <div className="bg-background/80 absolute inset-0 flex flex-col items-center justify-center gap-2 p-6 text-center">
            <CameraOff className="text-muted-foreground size-8" />
            <p className="text-muted-foreground text-sm">
              {cameraError ?? 'Starting camera…'}
            </p>
          </div>
        )}
      </div>

      <canvas ref={canvasRef} className="hidden" />

      <form
        className="flex flex-col gap-3"
        onSubmit={(event) => {
          event.preventDefault()
          event.stopPropagation()
          void form.handleSubmit()
        }}
      >
        <form.Field name="image">
          {(field) => (
            <div className="flex flex-wrap gap-2">
              {!previewUrl ? (
                <Button
                  type="button"
                  onClick={capturePhoto}
                  disabled={!cameraReady}
                >
                  <Camera />
                  Take photo
                </Button>
              ) : (
                <>
                  <Button type="button" variant="outline" onClick={clearCapture}>
                    Retake
                  </Button>
                  <Button
                    type="submit"
                    disabled={!field.state.value || mutation.isPending}
                  >
                    {mutation.isPending ? (
                      <Loader2 className="animate-spin" />
                    ) : (
                      <Send />
                    )}
                    Send to backend
                  </Button>
                </>
              )}
            </div>
          )}
        </form.Field>
      </form>

      {mutation.isSuccess && mutation.data === true && (
        <div className="bg-primary/5 text-foreground flex items-center gap-2 rounded-lg border px-4 py-3 text-sm">
          <CheckCircle2 className="text-primary size-4 shrink-0" />
          Backend returned <code className="font-semibold">true</code>
        </div>
      )}

      {mutation.isError && (
        <div className="border-destructive/30 bg-destructive/5 text-destructive rounded-lg border px-4 py-3 text-sm">
          {mutation.error instanceof Error
            ? mutation.error.message
            : 'Upload failed'}
        </div>
      )}
    </div>
  )
}
