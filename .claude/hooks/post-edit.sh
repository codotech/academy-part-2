#!/usr/bin/env bash
#
# PostToolUse hook  fires after every Edit or Write.
# If a frontend stub was substantially implemented, nudges Claude to offer a checkpoint.
#

INPUT=$(cat)

FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    inp = d.get('tool_input', {})
    path = inp.get('file_path') or inp.get('path') or ''
    print(path)
except:
    print('')
" 2>/dev/null)

declare -a STUBS=(
  "frontend/src/api.ts"
  "frontend/src/state.ts"
  "frontend/src/components/track-card.ts"
  "frontend/src/components/results-grid.ts"
)

for stub in "${STUBS[@]}"; do
  if [[ "$FILE" == *"$stub"* ]]; then
    if [[ -f "$FILE" ]] && grep -q "TODO:" "$FILE" 2>/dev/null; then
      exit 0
    fi
    echo "[AMBIENT] Progress detected on $stub. Mention naturally — not as a directive — that /checkpoint exists when they feel ready: 'Looks like we made real progress on $stub. When you feel like you've got a handle on it, /checkpoint is there if you want to consolidate what you just built.'"
    exit 0
  fi
done

exit 0