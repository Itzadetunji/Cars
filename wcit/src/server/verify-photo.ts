import { createServerFn } from '@tanstack/react-start'

export const verifyPhoto = createServerFn({ method: 'POST' })
  .validator((data: FormData) => {
    const image = data.get('image')

    if (!(image instanceof File) || image.size === 0) {
      throw new Error('A camera image is required')
    }

    return { image }
  })
  .handler(async ({ data }) => {
    // Image received on the server — extend with real verification later.
    void data.image.name
    void data.image.size
    void data.image.type

    return true as const
  })
