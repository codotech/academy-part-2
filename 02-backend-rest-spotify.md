# Homework #2: Backend, REST & Spotify

## What You'll Do

This week you're going to build a real backend that searches Spotify, then wire it to a **new frontend starter** we provide for you. Think of it as joining a real engineering team: the platform team has already shipped the frontend foundation; your job is to build the backend it expects and connect the two.

By the end of this homework:

- You'll have a local Node + Express backend running at `localhost:3000`
- A modern Vite + TypeScript frontend running at `localhost:5173`, wired to your backend, searching real Spotify tracks
- You'll understand what a backend actually is, how HTTP works, and how to reason about system latency
- You'll have written your first real API integration (Spotify OAuth + search)
- You'll have implemented runtime contracts (Zod) as a guardrail between two services you own

> **Heads up:** Next week's class is a pivot. We're redesigning how this whole course works. But the concepts and muscle you build this week: backend fundamentals, REST APIs, external integrations. You'll need either way. Nothing in this homework is throw-away.

---

## Our Approach Still: AI-Native

You already know the drill from Homework #1. Stay inside Claude Code. Don't bounce between Claude and a separate terminal. Let it install packages, run commands, debug, and explain. Your job is to **think, decide, and prove it works**, not to type boilerplate.

**What you WON'T touch this week:** the Claude SDK (LLM integration). That's coming later. This week is pure backend, REST, and Spotify.

---

## Before You Start: Know Your Track

Answer these three questions honestly. No grades — this just tells you where to start.

**1. Have you built a Node.js + Express server before, even a toy one?**
**2. Do you understand async/await and Promises in JavaScript without looking it up?**
**3. Have you used TypeScript in strict mode on a real project?**

---

| Your answers | Your track |
|---|---|
| Mostly No | **Full track** — start from Part 1 |
| Mixed (know some JS, not Node/TS) | **Express track** — do Part 1 selectively, see markers below |
| Mostly Yes | **Fast track** — skip to Part 3, do Part 1 concept check only |

**Everyone — regardless of track — does Parts 3, 4, and 5 in full.** That's where the actual course learning is.

---

> **One concept that matters before anything else — even if you're on the fast track:**
>
> **TypeScript types are erased at runtime.**
>
> If you're coming from C# or Java, this is the most important thing to internalize. In C#, `response is SearchResponse` works at runtime. In TypeScript, it doesn't — the type `SearchResponse` is gone the moment the compiler runs. At runtime, you receive a raw `unknown` blob from the network. Zod validates it. TypeScript types describe it. They are not the same thing.
>
> This is why `contracts.ts` exists. This is why `SearchResponseSchema.safeParse()` is not optional. If you understand this one thing, everything else in this homework clicks.

---

## Part 0: Prerequisites

### You need

- Node.js v20+ (check with `node --version`)
- Claude Code installed and working
- A Spotify Developer account (free)

### Clone the starter repo

```bash
git clone <URL provided in class> music-finder
cd music-finder
```

Inside you'll find two folders: `frontend/` and `backend/`. **Read the root `README.md` first** — it explains both starters and how Claude Code works in this homework.

```bash
# Frontend
cd frontend && npm install && npm run dev
# → http://localhost:5173 — searches fail (expected, API client is a stub)

# Backend (new terminal)
cd ../backend
cp .env.example .env   # paste your Spotify credentials
npm install && npm run dev
# → http://localhost:3000/health returns { "status": "ok" }
```

Read the `README.md` in each folder. The backend README has the only hard requirement: what `GET /api/search` must return. How you get there is up to you.

> Your Homework #1 frontend stays as a reference. You won't modify it this week.

### Get Spotify API credentials

1. Go to [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard) and log in with any Spotify account
2. Click **Create App**
3. Fill in:
   - **App name:** "Music Finder - Your Name"
   - **App description:** "Codo Academy homework"
   - **Redirect URI:** `http://localhost:3000/callback` (we won't use it, but it's required)
   - **Which API/SDKs are you planning to use?** Select "Web API"
4. After creation, click **Settings** and copy your **Client ID** and **Client Secret**

Keep these somewhere safe; you'll put them in a `.env` file in Part 3.

---

## Part 1: Study the Foundations

> **Full track:** Do this whole section (~90 min).
> **Express track:** Do the required items marked ★. Skip the rest.
> **Fast track:** Read the concept check at the bottom. Skip the videos and reading.

### Watch

| Topic | Search for | Channel | Track |
|-------|-----------|---------|-------|
| What is Node.js? | "What the heck is Node.js" | Fireship | ★ Required |
| Node event loop | "Node.js event loop explained" | Fireship, ByteByteGo | ★ Required |
| What happens when you type a URL | "What happens when you type google.com" | ByteByteGo | ★ Required |
| HTTP crash course | "HTTP explained" or "HTTP crash course" | Fireship | ★ Required |
| REST API | "REST API explained" or "REST API best practices" | ByteByteGo | Full track |
| Backend engineering | "Backend engineering fundamentals" | Hussein Nasser | Full track |
| System latency | "Latency vs throughput" or "Latency percentiles p99" | ByteByteGo | Full track |

### Read

| Resource | Track |
|----------|-------|
| [MDN: HTTP Overview](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Overview) | ★ Required |
| [Node.js docs: Anatomy of an HTTP Transaction](https://nodejs.org/en/learn/modules/anatomy-of-an-http-transaction) | ★ Required |
| [Vinay Sahni: Best Practices for a Pragmatic RESTful API](https://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api) | Full track |
| [roadmap.sh: Backend](https://roadmap.sh/backend) — skim top tier, click into anything unfamiliar | Full track |

### Concept check — everyone answers these before class

You don't need to write anything down. But in the next session, you'll be asked:

1. Why is Node.js single-threaded? What does "non-blocking I/O" mean?
2. What's the difference between `GET /songs`, `POST /songs`, `PUT /songs/123`, and `DELETE /songs/123`?
3. What does a **401** mean vs **403** vs **404** vs **500**?
4. Walk through what happens when your browser hits `https://spotify.com`: DNS → TCP → HTTPS → HTTP request → server response → browser render.
5. What is a **protocol**? How does HTTP sit on top of TCP?
6. What does "**latency p99 = 500ms**" mean? How is it different from average latency?
7. Why do we need **Spotify's OAuth** and why can't the frontend just call `api.spotify.com/v1/search` directly?

### Tip

If any concept doesn't click from videos or reading, paste it into Claude Code:

```
Explain what "non-blocking I/O" means in Node.js. Use a concrete example
of a slow database query vs a fast in-memory lookup.
```

Claude is a tutor. Use it.

---

## Part 2: Build a Node + Express Backend

> **Full track:** Do this whole section (~90 min).
> **Express track:** Do this section fast (~30 min) — you know this, just get the scaffolding done.
> **Fast track:** Skip. Start from your existing Node/Express setup, or scaffold it in 5 min with the prompt in the cheat sheet at the bottom.

You're going to build a tiny backend from scratch using Claude Code. This becomes the foundation for the Spotify integration in Part 3.

### Step 1: Create your backend project

In your terminal (NOT inside the Homework #1 frontend folder):

```bash
mkdir music-finder-backend
cd music-finder-backend
claude
```

> **Coming from Java or C#?** `package.json` is your project manifest — the equivalent of `pom.xml` or `.csproj`. It lists your dependencies (`express`, `typescript`, etc.) and the scripts you can run (`npm run dev`, `npm run build`). `npm install` downloads everything in `dependencies` and `devDependencies` into `node_modules/`. That folder is never committed to git (it's in `.gitignore`) — just like you don't commit your Maven local repository. `devDependencies` are tools that only run on your machine (TypeScript compiler, nodemon). `dependencies` are what ships to production.

### Step 2: Understand what you have

```bash
curl localhost:3000/health
```

Then ask Claude:

```
Walk me through what happens when I curl GET http://localhost:3000/health.
Explain it at three levels:
1. Node.js — event loop, what the request handler does
2. HTTP — headers, status codes, response body
3. TCP/IP — what's actually happening underneath
```

Read it. Ask follow-up questions. This is the foundation for everything else.

### Checkpoint

- [ ] `curl localhost:3000/health` returns `{ "status": "ok" }`
- [ ] You can explain the request flow at all three levels

---

> **All tracks rejoin here. Parts 3, 4, and 5 are mandatory for everyone.**

---

## Part 3: Connect to Spotify (~60 min)

### What is Client Credentials?

Spotify's **Client Credentials** flow is the simplest OAuth pattern: you trade your Client ID + Secret for an access token. The token expires after an hour. No user login needed. You can search tracks, artists, albums — but can't touch personal Spotify data.

This is also why the frontend can't call Spotify directly: the Client Secret would be exposed in browser JavaScript. The backend holds the secret, gets the token, makes the call.

### Your task

Open your backend in Claude Code and paste your Spotify credentials into `.env`. Then:

```
I need to add a GET /api/search?q=<query> endpoint to this Express server.
It should call Spotify's search API using Client Credentials OAuth and return
results in exactly this shape:

{
  "results": [
    {
      "id": "string",
      "name": "string",
      "artist": "string",
      "album": "string",
      "preview_url": "string or null",
      "external_url": "string",
      "cover_url": "string or null"
    }
  ]
}

Requirements:
- GET /api/search with missing or empty q → 400 { "error": "..." }
- Spotify auth token should be cached in memory (don't re-fetch on every request)
- If Spotify returns an error → 502 { "error": "..." }
- Use fetch (built into Node 20+), no external HTTP library needed
- Explain the Client Credentials OAuth flow as you implement it

How you structure it is up to you.
```

That's it. One prompt. Claude decides the structure. Your job is to understand what it built and verify the outcome.

### Verify it

```bash
curl "http://localhost:3000/api/search?q=daft+punk" | jq '.results[0]'
# → a track object with all required fields

curl "http://localhost:3000/api/search?q="
# → 400 { "error": "..." }

curl "http://localhost:3000/api/search?q=daft+punk"
curl "http://localhost:3000/api/search?q=daft+punk"
# → second call should be faster (token cached)
```

Then ask Claude to explain what it built — the auth flow, the token caching, the error handling. Make sure you understand it before moving on.
```

Confirm:
- Real queries return real Spotify tracks
- Empty or missing query returns 400
### Checkpoint

- [ ] `GET /api/search?q=<anything>` returns real Spotify results in the contracted shape
- [ ] Missing/empty query returns 400
- [ ] Token is cached (second call is faster than first)
- [ ] `.env` is in `.gitignore` — your secret is not in git
- [ ] You can explain to Claude what the Client Credentials flow is doing

---

## Part 4: Wire Up the Frontend Starter (~75 min)

Time for the magic moment. Your backend is ready. The frontend starter is ready. You just need to wire them.

The starter is **opinionated**. It already has the design system, the SPA shell, the search prompt, the loading/error states, and a Vite dev server. You will fill in **four small pieces** that connect everything: an API client, a localStorage history, a track card, and the results-grid state machine.

### Why does this architecture exist?

Before you touch any code, understand the shape of what you're building and why it's two servers, not one.

**CORS — the rule that forces this design.**

Browsers enforce a security rule called the **Same-Origin Policy**: JavaScript on `http://localhost:5173` (your frontend) is not allowed to make requests to `https://api.spotify.com` (a different origin). The browser blocks it. This is not a bug — it prevents malicious pages from making requests on behalf of a logged-in user.

CORS (Cross-Origin Resource Sharing) is the mechanism that lets servers selectively relax this rule by sending headers like `Access-Control-Allow-Origin`. Spotify's API does NOT relax it for browser requests — it only accepts server-to-server calls.

This is why the architecture looks like this:

```
Browser (5173) → Your backend (3000) → Spotify API
```

The browser IS allowed to talk to your backend (same machine, you control the CORS headers). Your backend IS allowed to talk to Spotify (server-to-server, no browser CORS enforcement). So your backend is a proxy — it exists because CORS forces it.

**Why does the Vite dev server proxy `/api` to `localhost:3000`?**

Even your backend is on a different port (`3000`) than the frontend (`5173`). Technically that's a different origin, so the browser would block that too — unless your backend sends CORS headers. In dev, Vite sidesteps this by proxying: when the frontend fetches `/api/search`, Vite intercepts it server-side and forwards it to `localhost:3000` before the browser ever sees the response. No CORS headers needed in dev because there's never a cross-origin request — Vite makes the call, not the browser.

In production you'd configure proper CORS headers on the backend. For now, Vite handles it.

---

### Step 0: Read what's there

Inside `music-finder-frontend/`:

```bash
cat README.md
ls src/
```

Identify:
- **GIVEN** files (header, search-prompt, empty-state, loading-state, error-state, toast, all CSS, the home view, contracts.ts) — don't touch these
- **STUB** files (api.ts, state.ts, components/track-card.ts, components/results-grid.ts) — these are yours

Open `src/contracts.ts` and read it carefully.

> **What is a contract?**
>
> A contract is an agreement between two systems about the shape of data they exchange. In this homework, the frontend and backend are two separate systems — they can't share TypeScript types at runtime. The only thing that connects them is the *shape of the HTTP response*.
>
> `contracts.ts` makes that agreement machine-readable. It says: "anyone calling `GET /api/search` will receive exactly this JSON shape — these fields, these types, these nullability rules." The frontend uses this file to validate every response at runtime. If the backend sends back the wrong shape — a missing field, a renamed key, a string where `null` was expected — Zod catches it immediately and surfaces a `ContractError` before it becomes a broken UI.
>
> This is how Stripe manages their API. When they release a new version, they version the contract. Apps depending on v1 keep working. The contract is what lets two independent systems evolve without breaking each other.
>
> In a larger codebase, contracts are often shared packages — the backend generates them, the frontend imports them. Here, we've put it in the frontend for simplicity. But the principle is the same: **the contract is the source of truth. Both sides honor it.**

**Your backend MUST return responses that match `SearchResponseSchema`.** If it doesn't, the frontend will surface a `ContractError` — not broken UI, not a confusing crash. A clear, explicit violation.

### Step 1: Verify the contract is honored

Your backend should already return the right shape from Part 3. Double-check:

```bash
curl "http://localhost:3000/api/search?q=daft+punk" | jq '.results[0]'
```

Every field must match exactly — `id`, `name`, `artist`, `album`, `preview_url`, `external_url`, `cover_url`. If any key is wrong or missing, the frontend Zod parser will surface a `ContractError`.

### Step 2: Implement `src/api.ts` ← most important stub

> This is the one that matters most. Take your time here. Everything else follows from understanding this.

Open the frontend in Claude Code:

```bash
cd music-finder-frontend
claude
```

Read the file first — it has a detailed comment block. Then:

```
Implement searchTracks in src/api.ts following the comment block at the top
of the file. Use fetch('/api/search?q=' + encodeURIComponent(query))
(Vite proxies /api to localhost:3000, so no full URL needed). Validate the
response with SearchResponseSchema.safeParse. Throw NetworkError,
BackendError, or ContractError for the three failure modes the comment
describes.
```

### Step 3: Implement `src/state.ts` ← second most important

```
Implement state.ts following the comment block. Use localStorage key 'mf:v1'.
Cap recent queries at 10 (de-dupe by string, newest first). Cap saved tracks
at 30 (de-dupe by id, newest first). When reading from localStorage, validate
the shape with z.array(z.string()) and z.array(TrackSchema). On any parse
failure, return an empty history rather than throwing.
```

### Step 4: Implement `src/components/track-card.ts`
> Claude implements this. Read what it wrote and understand the CustomEvent pattern. Don't spend more than 20 minutes here.

```
Implement createTrackCard following the comment block. Render a div.track-card
with .track-art (use props.track.cover_url image with alt="" if present, else
a ♪ glyph), .track-info (.track-title and .track-meta showing "artist · album"),
and .track-actions with one .btn-icon button. The button shows ♥ when saved
and adds 'is-saved' class on the root. Clicking dispatches a CustomEvent
('save' with detail { track } when not saved, 'unsave' with detail { id }
when saved). Both events bubble.
```

### Step 5: Implement `src/components/results-grid.ts`
> Claude implements this too. Focus on understanding the state machine concept — what states exist, what transitions are valid. Don't get lost in the DOM details.

```
Implement createResultsGrid following the comment block. The element wraps
a section divider (h2.section-divider) and a results container (div.results-grid).
Build setLoading, setError, showResults, showSuggested, showEmpty methods
that swap the contents. Use createTrackCard for each track and call
isTrackSaved from state.ts to set the saved flag. Use createEmptyState,
createLoadingState, createErrorState from components/. setError takes an
onRetry callback and wires it to the retry event from createErrorState.
```

### Step 6: Run the full system

Open two terminals:

```bash
# Terminal 1: backend
cd music-finder-backend
npm run dev

# Terminal 2: frontend
cd music-finder-frontend
npm run dev
```

Open [http://localhost:5173](http://localhost:5173). Type a search prompt. You should see:

1. The skeleton loading state for ~200-500ms
2. Real Spotify tracks rendered as cards
3. Click ♥ on a track → "Saved to your history" toast appears
4. Reload the page → that track is now in "Suggested from your history"
5. Stop the backend → search again → error state with a Try Again button

### Step 7: Prove the contract guardrail works

Temporarily break the backend response (e.g., rename `name` to `title` in the response object). Search again. The UI should show a `ContractError` with a clear message — **not** a broken card. That's the guardrail catching the violation before it reaches the user.

Restore the backend.

### Checkpoint

- [ ] Frontend shows real Spotify tracks when you search
- [ ] Loading skeleton appears while waiting
- [ ] Error state appears if you stop the backend
- [ ] Saved tracks survive a page reload
- [ ] Breaking the backend contract surfaces a ContractError, not a broken UI
- [ ] `npm run typecheck && npm run lint` pass cleanly

---

## Part 5: Measure Latency (~20 min)

You've built a system. Now prove how fast (or slow) it is.

### Step 1: Add request timing

In Claude Code (backend):

```
Add a simple Express middleware that logs every request with:
- HTTP method
- URL path
- Status code
- Duration in milliseconds (use Date.now() at start and end)
Format: [2026-04-13T10:30:00Z] GET /api/search?q=daft+punk 200 342ms
```

### Step 2: Run searches and observe

Run 10-15 searches through your frontend. Look at the backend logs. You'll see durations like:

```
GET /api/search?q=daft+punk 200 412ms
GET /api/search?q=daft+punk 200 189ms
GET /api/search?q=chill 200 234ms
GET /api/search?q= 400 2ms
```

### Step 3: Reason about the numbers

Answer these for yourself:

1. **Why is the first search after server start slower than subsequent ones?** (Hint: token fetch)
2. **Why is the same query second time usually faster?** (Spoiler: it shouldn't be by much right now. We're not caching the results, only the token. This matters for a later lesson.)
3. **Why is `400` (empty query) so fast?** (No external call.)
4. **If p99 is 800ms and p50 is 200ms, what does that tell you?**

### Step 4: Write down your observations

Just in a text file or note. Not required to submit. For discussion in class.

Example:
```
Ran 10 searches. Latency:
- min: 180ms
- median (p50): 240ms
- max (p99): 620ms
- First search (cold token): 412ms
- Empty query (400): 2ms
```

---

## Deliverables

| # | Deliverable | Required |
|---|-------------|----------|
| 1 | Local backend at `localhost:3000` with `/health` and `/api/search` | Yes |
| 2 | Backend connects to Spotify and returns the contracted JSON shape | Yes |
| 3 | Frontend starter at `localhost:5173` displays real Spotify results from your backend | Yes |
| 4 | Saved tracks survive a page reload (localStorage + Zod-validated read) | Yes |
| 5 | Breaking the backend contract surfaces a `ContractError` in the UI, not broken cards | Yes |
| 6 | `.env` excluded from git (your Spotify secret is not leaked) | Yes |
| 7 | Latency observations logged (at least 10 searches) | Yes |
| 8 | Push the backend repo to GitHub (use `gh` CLI via Claude Code) | Yes |
| 9 | `npm run typecheck && npm run lint` pass cleanly in the frontend | Yes |
| 10 | Be ready to answer the concept questions from Part 1 in next class | Yes |

---

## Claude Code Prompts Cheat Sheet

### Backend setup

```
Initialize a new Node.js + TypeScript + Express project with:
- Strict mode TypeScript
- Express on port 3000
- GET /health returning { status: "ok" }
- nodemon for dev mode
- Run it with `npm run dev`
```

### Environment variables

```
Set up dotenv for env variables. Add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET
to .env. Validate both exist on startup, fail clearly if not.
Add .env to .gitignore.
```

### Spotify integration

```
Build a SpotifyClient module that:
- Gets a token via Client Credentials OAuth (POST to accounts.spotify.com/api/token)
- Caches the token in memory until expiry
- Has searchTracks(query) that calls api.spotify.com/v1/search with type=track
- Returns simplified tracks: { id, name, artist, album, preview_url, external_url }
Use fetch (built-in in Node 20+). No axios, no node-fetch.
```

### Search endpoint

```
Add GET /api/search?q=<query> that:
- Returns 400 if q is missing/empty
- Calls spotifyClient.searchTracks
- Returns { results: [...] }
- Returns 502 on Spotify errors
```

### CORS

```
Add CORS support using the cors package. Allow all origins for dev.
Explain what CORS is, why browsers block cross-origin requests by default,
and what the headers actually do.
```

### Request logging

```
Add an Express middleware that logs each request with method, path,
status code, and duration in ms.
```

### Frontend integration

```
Find the mock song data in this frontend. Replace it with a real fetch
to http://localhost:3000/api/search?q=<query>. Add loading and error states.
Keep the existing card UI; just change the data source.
```

### Learning prompts

```
Explain the Client Credentials OAuth flow step by step, using my SpotifyClient
as the concrete example.
```

```
What is CORS? Why does my browser block fetches to a different origin?
Walk me through the preflight request.
```

```
Given these request durations [list them], calculate p50, p95, p99.
Explain why p99 matters more than average latency for users.
```

---

## Tips

**Stay in Claude Code.** Don't copy-paste commands from Stack Overflow. Ask Claude Code to install things, run commands, and debug errors. That's the muscle.

**Read what Claude generates.** Don't just run it. Ask "explain this line" whenever something is new. You're learning, not just shipping.

**Test as you go.** Every time Claude makes a change, test it. `curl`, open the browser, check the logs. Don't let broken code accumulate.

**When stuck, describe the symptom.** "I'm getting a 401 from Spotify when I call searchTracks." Claude reads your code and finds it. Don't dig alone.

---

## Resources

### Node.js & Backend

- [Fireship: What is Node.js?](https://www.youtube.com/c/Fireship) (search the channel)
- [Hussein Nasser: Backend Engineering](https://www.youtube.com/@hnasr)
- [ByteByteGo](https://www.youtube.com/@ByteByteGo): system design and networking
- [Node.js docs: Anatomy of an HTTP Transaction](https://nodejs.org/en/learn/modules/anatomy-of-an-http-transaction)

### HTTP & REST

- [MDN: HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP)
- [MDN: HTTP Response Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status)
- [Vinay Sahni: Pragmatic RESTful API](https://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api)
- [Stack Overflow: REST API design best practices](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)

### Spotify API

- [Spotify Web API docs](https://developer.spotify.com/documentation/web-api)
- [Client Credentials flow](https://developer.spotify.com/documentation/web-api/tutorials/client-credentials-flow)
- [Search endpoint reference](https://developer.spotify.com/documentation/web-api/reference/search)

### Express & TypeScript

- [Express.js docs](https://expressjs.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)

### CORS

- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)

### Latency & Metrics

- [Google SRE: Monitoring distributed systems (Ch. 6)](https://sre.google/sre-book/monitoring-distributed-systems/): section on the Four Golden Signals
- [ByteByteGo: Latency vs Throughput](https://www.youtube.com/@ByteByteGo) (search the channel)

---

## What's Next

Next class, we're taking a sharp turn. The course is being redesigned: new structure, new philosophy, new ways to think about what engineering even IS in the AI era. This homework gives you muscle you'll need either way: a Node + Express backend, a real external API integration, and the beginnings of system thinking.

Show up next class with:
- Your backend running, showing real Spotify data in your frontend
- Answers to the concept questions (verbally, not written)
- Any observations or questions from the study portion

See you there.
