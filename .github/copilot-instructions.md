## Quick context for AI coding agents

This repository is a full-stack TypeScript app (React + Vite frontend, Express backend) using PostgreSQL with Drizzle ORM.

- Frontend: `client/` — React + TypeScript, Vite as bundler (`vite.config.ts`). UI uses Tailwind + Radix primitives and small component library under `client/src/components` (see `ui/` for design system components).
- Backend: `server/` — Express app in TypeScript. Entry: `server/index.ts`. Routes registered via `server/routes.ts` (scan this file for API surface).
- Database: PostgreSQL, accessed with `pg` + `drizzle-orm`. Schema lives in `shared/schema.ts` and migrations in `migrations/`. Drizzle config: `drizzle.config.ts`.

Important files to reference when making changes:

- `package.json` — scripts: `dev` runs `tsx server/index.ts` (dev server), `build` bundles client and server (Vite + esbuild), `start` runs built server.
- `server/index.ts` — bootstraps Express, mounts `/uploads` static route, sets up request logging, error handler, and conditionally initializes Vite in development.
- `server/db.ts` — exports `db` (Drizzle) configured from `process.env.DATABASE_URL`. Ensure `DATABASE_URL` is present for local testing.
- `shared/schema.ts` — canonical DB schema and Zod/Drizzle types used across server and migrations.
- `drizzle.config.ts` — drizzle-kit config; use `npm run db:push` to push schema changes.

Patterns and conventions (do not invent these; follow them):

- Single-port deployment: server serves both API and SPA. Do not add a separate client server unless you update `server/index.ts` routing. The app relies on the server's `PORT` env var.
- Environment variables: loaded via `dotenv` in `server/index.ts` and `server/db.ts`. Use `.env` for local development; do not hardcode secrets.
- DB migrations: modify `shared/schema.ts` (Drizzle tables) and run `npm run db:push` to generate/migrate. `migrations/` is the source of truth.
- API logging: `server/index.ts` captures JSON responses for `/api` routes and truncates lines >80 chars. Keep response shapes compact when possible for readable logs.
- File uploads: static uploads are served from `public/uploads`; server expects uploaded files there.

Frontend specifics:

- Routing: client uses `wouter` (lightweight router). Look in `client/src/main.tsx` and `client/src/App.tsx` for route setup.
- Components: curated under `client/src/components` with `ui/` primitives (Radix wrappers) and concrete components (e.g., `ListingCard.tsx`, `SearchBar.tsx`). Follow existing props and className patterns.
- Styling: Tailwind + `tailwind.config.ts`. Use utility classes and `class-variance-authority` where patterns exist (see `components/ui/button.tsx` for example).
- Data fetching: `@tanstack/react-query` is used — mutate/query keys are defined near the components that use them. Reuse `client/src/lib/queryClient.ts` and follow existing query cache patterns.

Backend specifics:

- Authentication: `passport` + `passport-local` with `express-session` present in dependencies; check `server/routes.ts` and auth context in `client/src/contexts/AuthContext.tsx` for flow.
- Sessions: Postgres-backed session stores are used (`connect-pg-simple` or `memorystore` present). If changing session behavior, update both server and client session-consumption points.
- Error handling: routes should throw errors with `status`/`statusCode` fields if non-200. The global error handler in `server/index.ts` converts these to JSON `{ message }`.

Developer workflows and commands:

- Start dev (server + Vite middleware):

```bash
npm run dev
```

- Build production assets and server bundle:

```bash
npm run build
```

- Run migrations (drizzle-kit):

```bash
npm run db:push
```

- Typecheck only:

```bash
npm run check
```

Notes and gotchas:

- `DATABASE_URL` is mandatory. Many commands and the app will throw if it's missing. For local dev use a Postgres container or a local DB and export `DATABASE_URL`.
- The server uses ESM and `tsx` in dev. When editing server code, restart `npm run dev` if you see strange stale behavior.
- Keep shared types in `shared/schema.ts` to avoid duplication — both server and migrations import from it (`@shared/schema` alias is used).
- Avoid adding client-only dependencies to top-level server imports that run in Node without bundling — they may break `esbuild` bundle unless marked external.

Examples to copy from the codebase:

- Add a new table: update `shared/schema.ts` (follow `pgTable(...)` pattern), create Drizzle insert schemas using `createInsertSchema`, then run `npm run db:push`.
- Add an API route: update `server/routes.ts` to register a new route, throw errors with `err.status`, and add client-side fetch using React Query with the path `/api/your-route`.

If anything is unclear or you want the instructions translated to Persian, tell me which sections to expand or translate and I'll update the file.
