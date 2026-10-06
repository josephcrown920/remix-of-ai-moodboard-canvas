# Project architecture rules

- Put app-internal server logic in client-safe `*.functions.ts` modules and raw HTTP handlers in TanStack routes; this keeps RPC calls typed and streaming endpoints explicit.
- Persist board-scoped studio data with owner-checked Row Level Security and explicit Data API grants; this keeps character context and generation history isolated to the board owner.
- Treat AI actions as explicit, cancellable user-triggered runs and require approval before changing canonical character context; this prevents silent identity drift and duplicate work.
