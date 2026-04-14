# Music Finder  Homework #2

This repo has two starters. You build on top of both.

```
demo/
├── frontend/   ← design system + SPA shell given. You wire the data layer.
└── backend/    ← Express scaffold given. You build the Spotify integration.
```

## Quick Start

```bash
# Frontend
cd frontend && npm install && npm run dev
# → http://localhost:5173  page renders, searches fail (expected)

# Backend (new terminal)
cd backend
cp .env.example .env   # paste your Spotify credentials
npm install && npm run dev
# → http://localhost:3000/health returns { "status": "ok" }
```

Read the README in each folder before touching any code.

---

## How Claude Works in This Homework

Claude Code is your primary tool  not just for writing code, but for understanding what you build. Here's how it works differently in this homework:

**Claude is Socratic.** When you ask "how do I implement X", Claude won't always just implement it. It may ask what you think should happen first. That's intentional. The goal is understanding, not code generation.

**Claude knows the repo.** This repo has a root `.claude/CLAUDE.md` that gives Claude context  what the stubs are, what concepts matter, what you should understand by the end. Claude uses this to guide, not just to answer.

**`/checkpoint` is yours.** At any point, type `/checkpoint` and Claude switches into learning mode. It asks 3 questions about what was just built  one at a time, conversationally. Not a quiz. A check that what landed in your head matches what went into the repo.

**When to use `/checkpoint`:**
- After implementing `src/api.ts` in the frontend
- After implementing `src/state.ts`
- After the Spotify OAuth flow works in the backend
- After the full system runs end-to-end

**The workflow:**
```
1. Read the stub / README
2. Tell Claude what you want to build (describe the outcome, not the steps)
3. Claude implements. You read and understand.
4. Run /checkpoint when something clicks.
5. Move to the next thing.
```

You're not here to type code. You're here to understand what the code does and why it's structured that way.
