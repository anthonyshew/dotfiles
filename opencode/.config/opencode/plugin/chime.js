export const ChimePlugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  return {
    event: async ({ event }) => {
      // Skip chime for subagents (sessions with a parentID)
      if (event.type === "session.idle") {
        const session = await client.session.get({
          path: { id: event.properties.sessionID },
          query: { directory },
        });
        if (session.data?.parentID) {
          return;
        }
        await $`afplay /System/Library/Sounds/Pop.aiff`;
      }
    },
  };
};
