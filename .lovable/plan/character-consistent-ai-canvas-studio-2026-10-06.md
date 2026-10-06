# Character-consistent AI canvas studio

## Goal
Evolve the existing visual canvas into a character-first creation studio, while keeping provider/model choices limited to integrations verified in the live workspace catalog. Add a canvas command bar and a terminal CLI, with an orchestrated workflow for image/video creation and editing.

## Scope
- Make characters persistent canvas entities: reference image(s), name/description, visual traits, and reusable consistency notes that are automatically updated from user-approved generation outcomes.
- Add an in-canvas command bar supporting image generation, video generation, reference-guided edits, prompt optimization, style transfer, and supported image enhancement/removal/VFX actions. Results become canvas items and retain links to source/reference character context.
- Add generation orchestration with explicit steps/statuses, inputs, selected supported model, cancellation/error reporting, and history on the canvas.
- Add an agent/context layer that can summarize a board and propose updates to its living character/style context; changes remain reviewable and user-approved rather than silently rewriting identity.
- Provide a separate terminal CLI that targets the same supported command workflow, with documented install/configuration and commands for generation and board context operations.
- Use verified gateway integrations: `openai/gpt-6-astra`, `openai/gpt-image-2.5-sunburst`, `anthropic/claude-fable-5-1`, supported Gemini image models, and `google/veo-3.1` variants. Check each model's endpoint requirements before implementation.
- Do not list unsupported provider requests as usable models: Seedream 5.0, Seedance 2.5, Wan 3, Flux, LTX, and GPT-2. External providers may be added later only after an available connector or credentials exist.

## Implementation approach
- Preserve the existing TanStack Start app and Konva canvas; add the studio controls as focused canvas UI.
- Keep gateway calls and orchestration server-side, stream requests, and use the existing Lovable Cloud auth/storage patterns. Do not use Supabase Edge Functions for new internal server logic.
- Build the CLI as a small, separately invokable package/script that calls an authenticated app API; never put gateway secrets in browser or CLI source.
- Confirm which enhancement operations have a verified provider endpoint; present unsupported operations as unavailable rather than simulating their completion.

## Acceptance checks
- Existing canvas editing, upload, and board flow remain intact.
- A character can be defined and reused as context for multiple generations; its context can be reviewed and updated.
- Users can initiate image/video work through the canvas command bar and the terminal CLI.
- Only verified model identifiers are selectable, and unsupported providers are clearly absent/unavailable.
- Generation failures, permissions, progress, and cancellation are visible and do not lose partial results.

## Technical details
- Current gateway support confirmed: GPT-6 Astra, GPT Image 2.5 Sunburst, Claude Fable 5.1, Gemini image models including Gemini 3 Pro Image, and Veo 3.1 variants.
- Video generation uses the gateway video job interface, not chat/image endpoints. OpenAI Responses calls must follow the project gateway contract; Claude uses native Messages. Image and video outputs need verified storage/asset persistence paths.
- Upscaling, background removal, and generalized VFX are not established as available operations from the current model catalog; implementation must verify available endpoints before exposing them as functional actions.
