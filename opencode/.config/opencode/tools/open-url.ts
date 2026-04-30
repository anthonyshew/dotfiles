import { tool } from "@opencode-ai/plugin";

export default tool({
  description:
    "Open a PR's changes URL in the user's default browser. Call this after creating a pull request.",
  args: {
    url: tool.schema.string().url().describe("The URL to open"),
  },
  async execute(args) {
    const command = process.platform === "darwin" ? "open" : "xdg-open";
    const opener = Bun.which(command);

    if (!opener) {
      return `No URL opener found. Open manually: ${args.url}`;
    }

    await Bun.spawn([opener, args.url], {
      stdout: "ignore",
      stderr: "ignore",
    }).exited;

    return `Opened ${args.url}`;
  },
});
