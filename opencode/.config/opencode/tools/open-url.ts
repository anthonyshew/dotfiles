import { tool } from "@opencode-ai/plugin";

export default tool({
  description:
    "Open a PR's changes URL in the user's default browser. Call this after creating a pull request.",
  args: {
    url: tool.schema.string().url().describe("The URL to open"),
  },
  async execute(args) {
    await Bun.$`open ${args.url}`.quiet();
    return `Opened ${args.url}`;
  },
});
