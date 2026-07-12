import { useEffect, useRef, useState, type ChangeEvent } from "react";
import { useForm } from "@tanstack/react-form";
import { useMutation } from "@tanstack/react-query";
import {
	Camera,
	CameraOff,
	CheckCircle2,
	Loader2,
	Send,
	ShieldAlert,
} from "lucide-react";

import { Button } from "#/components/ui/button";
import { verifyPhoto } from "#/server/verify-photo";

type CameraStatus = "idle" | "requesting" | "ready" | "denied" | "unsupported";

function getCameraSupportError(): string | null {
	if (typeof window === "undefined") return null;

	if (!window.isSecureContext) {
		return "Camera needs HTTPS (or localhost). Restart the dev server and open the https:// URL.";
	}

	if (!navigator.mediaDevices?.getUserMedia) {
		return "Live camera is unavailable here. Use “Open camera app” below instead.";
	}

	return null;
}

export function CameraCapture() {
	const videoRef = useRef<HTMLVideoElement>(null);
	const canvasRef = useRef<HTMLCanvasElement>(null);
	const fileInputRef = useRef<HTMLInputElement>(null);
	const streamRef = useRef<MediaStream | null>(null);

	const [previewUrl, setPreviewUrl] = useState<string | null>(null);
	const [cameraError, setCameraError] = useState<string | null>(null);
	const [cameraStatus, setCameraStatus] = useState<CameraStatus>("idle");

	const cameraReady = cameraStatus === "ready";
	const liveCameraAvailable =
		typeof window !== "undefined" &&
		window.isSecureContext &&
		Boolean(navigator.mediaDevices?.getUserMedia);

	const mutation = useMutation({
		mutationFn: async (image: File) => {
			const formData = new FormData();
			formData.append("image", image);
			return verifyPhoto({ data: formData });
		},
	});

	const form = useForm({
		defaultValues: {
			image: null as File | null,
		},
		onSubmit: async ({ value }) => {
			if (!value.image) return;
			await mutation.mutateAsync(value.image);
		},
	});

	useEffect(() => {
		const supportError = getCameraSupportError();
		if (supportError) {
			setCameraStatus("unsupported");
			setCameraError(supportError);
		}

		return () => {
			for (const track of streamRef.current?.getTracks() ?? []) track.stop();
			streamRef.current = null;
		};
	}, []);

	useEffect(() => {
		return () => {
			if (previewUrl) URL.revokeObjectURL(previewUrl);
		};
	}, [previewUrl]);

	function applyCapturedFile(file: File) {
		form.setFieldValue("image", file);
		setPreviewUrl((prev) => {
			if (prev) URL.revokeObjectURL(prev);
			return URL.createObjectURL(file);
		});
		mutation.reset();
	}

	async function requestCameraAccess() {
		const supportError = getCameraSupportError();
		if (supportError) {
			setCameraStatus("unsupported");
			setCameraError(supportError);
			return;
		}

		setCameraStatus("requesting");
		setCameraError(null);

		try {
			for (const track of streamRef.current?.getTracks() ?? []) track.stop();

			const stream = await navigator.mediaDevices.getUserMedia({
				video: { facingMode: { ideal: "environment" } },
				audio: false,
			});

			streamRef.current = stream;
			if (videoRef.current) {
				videoRef.current.srcObject = stream;
				await videoRef.current.play();
			}

			setCameraStatus("ready");
			setCameraError(null);
		} catch (error) {
			setCameraStatus("denied");
			setCameraError(
				error instanceof DOMException && error.name === "NotAllowedError"
					? "Camera permission was denied. Allow access in your browser settings, then try again."
					: "Camera access was denied or is unavailable.",
			);
		}
	}

	function capturePhoto() {
		const video = videoRef.current;
		const canvas = canvasRef.current;
		if (!video || !canvas || !cameraReady) return;

		canvas.width = video.videoWidth;
		canvas.height = video.videoHeight;
		const context = canvas.getContext("2d");
		if (!context) return;

		context.drawImage(video, 0, 0, canvas.width, canvas.height);
		canvas.toBlob(
			(blob) => {
				if (!blob) return;
				applyCapturedFile(
					new File([blob], `capture-${Date.now()}.jpg`, {
						type: "image/jpeg",
					}),
				);
			},
			"image/jpeg",
			0.92,
		);
	}

	function onNativeCameraChange(event: ChangeEvent<HTMLInputElement>) {
		const file = event.target.files?.[0];
		if (!file) return;
		applyCapturedFile(file);
		event.target.value = "";
	}

	function clearCapture() {
		form.setFieldValue("image", null);
		setPreviewUrl((prev) => {
			if (prev) URL.revokeObjectURL(prev);
			return null;
		});
		mutation.reset();
	}

	return (
		<div className="mx-auto flex w-full max-w-lg flex-col gap-6">
			<div className="space-y-2">
				<h1 className="text-3xl font-bold tracking-tight">Camera verify</h1>
				<p className="text-muted-foreground text-sm">
					Capture a photo, send it to the backend, and get <code>true</code>{" "}
					back.
				</p>
			</div>

			<div className="bg-muted relative aspect-[4/3] overflow-hidden rounded-xl border">
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
					<div className="bg-background/85 absolute inset-0 flex flex-col items-center justify-center gap-4 p-6 text-center">
						{cameraStatus === "denied" || cameraStatus === "unsupported" ? (
							<ShieldAlert className="text-destructive size-8" />
						) : (
							<CameraOff className="text-muted-foreground size-8" />
						)}

						<div className="space-y-1">
							<p className="text-sm font-medium">
								{cameraStatus === "requesting"
									? "Waiting for permission…"
									: cameraStatus === "unsupported"
										? "Live camera unavailable"
										: cameraStatus === "denied"
											? "Camera permission needed"
											: "Camera access required"}
							</p>
							<p className="text-muted-foreground text-sm text-pretty">
								{cameraError ??
									"Allow camera access for a live preview, or open the device camera app."}
							</p>
						</div>

						<div className="flex flex-wrap items-center justify-center gap-2">
							{liveCameraAvailable && (
								<Button
									type="button"
									onClick={() => void requestCameraAccess()}
									disabled={cameraStatus === "requesting"}
								>
									{cameraStatus === "requesting" ? (
										<Loader2 className="animate-spin" />
									) : (
										<Camera />
									)}
									{cameraStatus === "denied"
										? "Try again"
										: cameraStatus === "requesting"
											? "Requesting…"
											: "Allow camera access"}
								</Button>
							)}

							<Button
								type="button"
								variant={liveCameraAvailable ? "outline" : "default"}
								onClick={() => fileInputRef.current?.click()}
							>
								<Camera />
								Open camera app
							</Button>
						</div>
					</div>
				)}
			</div>

			<canvas
				ref={canvasRef}
				className="hidden"
			/>
			<input
				ref={fileInputRef}
				type="file"
				accept="image/*"
				capture="environment"
				className="hidden"
				onChange={onNativeCameraChange}
			/>

			<form
				className="flex flex-col gap-3"
				onSubmit={(event) => {
					event.preventDefault();
					event.stopPropagation();
					void form.handleSubmit();
				}}
			>
				<form.Field name="image">
					{(field) => (
						<div className="flex flex-wrap gap-2">
							{!previewUrl ? (
								<>
									<Button
										type="button"
										onClick={capturePhoto}
										disabled={!cameraReady}
									>
										<Camera />
										Take photo
									</Button>
									<Button
										type="button"
										variant="outline"
										onClick={() => fileInputRef.current?.click()}
									>
										Open camera app
									</Button>
								</>
							) : (
								<>
									<Button
										type="button"
										variant="outline"
										onClick={clearCapture}
									>
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
						: "Upload failed"}
				</div>
			)}
		</div>
	);
}
