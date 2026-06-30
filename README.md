# cap-web-coolify-image

Custom Coolify build wrapper for `ghcr.io/capsoftware/cap-web:latest`.

It patches Cap's compiled self-host proxy allowlist so Workflow DevKit control-plane requests are not redirected to `/login`:

```ts
path.startsWith("/.well-known/workflow")
```

This fixes self-host uploads getting stuck at `Muxing segments into MP4...` when `POST /.well-known/workflow/v1/{flow,step}` returns login HTML instead of the workflow route handler.

The Docker build intentionally fails if the compiled proxy marker cannot be found, so upstream image changes do not silently deploy without the patch.
