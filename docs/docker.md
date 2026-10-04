# Running with Docker

The repo ships a multi-stage `Dockerfile` (Next.js standalone output,
runs as a non-root user) and a `docker-compose.yml` with the full
integrated stack:
- **`app`**: The Next.js WACRM application (port `3000`)
- **`api-gw`**: Supabase Envoy API gateway (port `54321`, configurable via `SUPABASE_PORT`)
- **`db`**: PostgreSQL with all Supabase extensions (port `5432`)
- **`studio`**: Supabase Studio web dashboard (port `54323`)
- **`auth`**: Supabase GoTrue authentication
- **`rest`**: PostgREST auto-generated REST API
- **`realtime`**: Supabase Realtime engine (WebSockets)
- **`storage`**: Supabase Storage API + Imgproxy
- **`db-migrate`**: Automated migration runner that applies `supabase/migrations/*.sql` on startup

## Quick start

To start the entire stack (CRM + local Supabase):

```bash
docker compose up --build -d
```

- **WACRM Application**: [http://localhost:3000](http://localhost:3000)
- **Supabase Studio Dashboard**: [http://localhost:54323](http://localhost:54323)
- **Supabase API Gateway**: [http://localhost:54321](http://localhost:54321)

All keys and database schemas are preconfigured for local use out of the box with zero external dependencies.

## Using External / Cloud Supabase

If you prefer to connect to hosted Supabase Cloud or an external instance instead of the built-in services, set your keys in `.env.local`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

And start only the `app` container:

```bash
docker compose up app --build -d
```
- Received attachments are copied into the `chat-media` Supabase
  Storage bucket, because Meta deletes media roughly 30 days after it
  arrives and the copy is the only thing that outlives that. It grows
  with inbound volume, so it's worth watching your project's storage
  quota. Turn it off per account under Settings → WhatsApp →
  Attachment Storage; attachments received while it's off become
  unviewable once Meta drops them. Files over 16 MB (the bucket's
  limit) are never copied.
- Nothing inside the container is scheduled. If you use automation
  Wait steps or flows, point an external scheduler at
  `GET /api/automations/cron` and `GET /api/flows/cron` on this
  deployment, sending the shared secret in the `x-cron-secret` header
  (`AUTOMATION_CRON_SECRET`, see `.env.local.example`). Both return
  503 until that variable is set.
