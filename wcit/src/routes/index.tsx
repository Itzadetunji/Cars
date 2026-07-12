import { createFileRoute } from "@tanstack/react-router";

import { ChatPrompt } from "#/components/chat-prompt";

export const Route = createFileRoute("/")({ component: Home });

function Home() {
	return (
		<main className="min-h-svh p-4 md:p-8 flex flex-col">
			<ChatPrompt />
		</main>
	);
}
