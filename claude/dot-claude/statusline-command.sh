#!/usr/bin/env bash
#
# Claude Code Status Line — Catppuccin Latte/Mocha + Powerline
#
# A Powerline-style status line for Claude Code using the Catppuccin palette.
# Displays: user@host, directory, git branch, model, and context remaining %.
#
# Requirements:
#   - A Nerd Font (any variant) for Powerline glyphs and icons
#   - jq for JSON parsing
#   - A terminal with true-colour (24-bit) support
#
# Compatibility:
#   - bash 3.2+ (macOS default) and bash 5.x (Ubuntu 24.04 LTS)
#   - Nerd Font glyphs are encoded as raw hex bytes ($'\xHH') rather than
#     $'\uXXXX' Unicode escapes, because bash < 4.4 does not support \u.
#     The hex sequences are the UTF-8 encoding of each codepoint:
#       U+E0B0 (Powerline right arrow) → \xEE\x82\xB0
#       U+F07C (folder open icon)      → \xEF\x81\xBC
#       U+E725 (git branch icon)       → \xEE\x9C\xA5
#
# Usage:
#   Set in ~/.claude/settings.json:
#     "statusLine": {
#       "type": "command",
#       "command": "bash ~/.claude/statusline-command.sh"
#     }
#
#   Claude Code pipes a JSON object to stdin with these fields:
#     .workspace.current_dir             — current working directory
#     .model.display_name                — active model name
#     .context_window.remaining_percentage — context window remaining (0-100)
#
# Segments (left to right):
#   1. user@host         — Surface0 bg, Text fg
#   2. directory         — Mauve bg, Crust fg, folder icon
#   3. git branch        — Green bg, Crust fg, branch icon (only in git repos)
#   4. AWS profile       — Peach bg, Crust fg (only if AWS_PROFILE is set)
#   5. model             — Blue bg, Crust fg
#   6. context remaining — Peach bg, Crust fg
#
# Colour reference: https://catppuccin.com/palette
# ---------------------------------------------------------------------------

# ── Theme ──────────────────────────────────────────────────────────────────
# Set to "latte" for light theme, "mocha" for dark theme.
# Override at runtime via: CLAUDE_STATUSLINE_THEME=mocha bash statusline-command.sh
THEME="${CLAUDE_STATUSLINE_THEME:-latte}"

# ── Input ──────────────────────────────────────────────────────────────────
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# ── Glyphs (hex-encoded UTF-8 for bash 3.2 compatibility) ─────────────────
sep=$'\xEE\x82\xB0'         # U+E0B0 Powerline right arrow
icon_folder=$'\xEF\x81\xBC' # U+F07C nf-fa-folder_open
icon_git=$'\xEE\x9C\xA5'    # U+E725 nf-dev-git_branch

reset=$'\e[0m'

# ── Palette ────────────────────────────────────────────────────────────────
if [ "$THEME" = "latte" ]; then
  # Catppuccin Latte (light)
  #   Crust:    #dce0e8  Text:     #4c4f69
  #   Surface0: #ccd0da  Green:    #40a02b
  #   Mauve:    #8839ef  Blue:     #1e66f5
  #   Peach:    #fe640b
  crust_fg=$'\e[38;2;220;224;232m'
  text_fg=$'\e[38;2;76;79;105m'
  surface0_bg=$'\e[48;2;204;208;218m'
  green_bg=$'\e[48;2;64;160;43m'
  peach_bg=$'\e[48;2;254;100;11m'
  blue_bg=$'\e[48;2;30;102;245m'
  mauve_bg=$'\e[48;2;136;57;239m'
  surface0_fg=$'\e[38;2;204;208;218m'
  green_fg=$'\e[38;2;64;160;43m'
  peach_fg=$'\e[38;2;254;100;11m'
  blue_fg=$'\e[38;2;30;102;245m'
  mauve_fg=$'\e[38;2;136;57;239m'
else
  # Catppuccin Mocha (dark)
  #   Crust:    #11111b  Text:     #cdd6f4
  #   Surface0: #313244  Green:    #a6e3a1
  #   Mauve:    #cba6f7  Blue:     #89b4fa
  #   Peach:    #fab387
  crust_fg=$'\e[38;2;17;17;27m'
  text_fg=$'\e[38;2;205;214;244m'
  surface0_bg=$'\e[48;2;49;50;68m'
  green_bg=$'\e[48;2;166;227;161m'
  peach_bg=$'\e[48;2;250;179;135m'
  blue_bg=$'\e[48;2;137;180;250m'
  mauve_bg=$'\e[48;2;203;166;247m'
  surface0_fg=$'\e[38;2;49;50;68m'
  green_fg=$'\e[38;2;166;227;161m'
  peach_fg=$'\e[38;2;250;179;135m'
  blue_fg=$'\e[38;2;137;180;250m'
  mauve_fg=$'\e[38;2;203;166;247m'
fi

# ── Segment data ───────────────────────────────────────────────────────────
# Each segment is a pipe-delimited string: "name|content|arrow_fg"
#   name     — used to look up the background colour for the next arrow
#   content  — ANSI-formatted text to display
#   arrow_fg — foreground colour of the trailing Powerline arrow
segments=()

# Segment 1: user@host
segments+=("surface0|${surface0_bg}${text_fg} $(whoami)@$(hostname -s) |${surface0_fg}")

# Segment 2: directory (truncated to last 3 path components, ~ for $HOME)
short_dir="$cwd"
home_dir="$HOME"
short_dir="${short_dir/#$home_dir/~}"
IFS='/' read -ra parts <<< "$short_dir"
if [ "${#parts[@]}" -gt 3 ]; then
  short_dir="${parts[${#parts[@]}-3]}/${parts[${#parts[@]}-2]}/${parts[${#parts[@]}-1]}"
fi
segments+=("mauve|${mauve_bg}${crust_fg} ${icon_folder} ${short_dir} |${mauve_fg}")

# Segment 3: git branch + dirty indicator (only inside a git repo)
if cd "$cwd" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_content=" ${icon_git} ${branch} "
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
      git_content+="* "
    fi
    segments+=("green|${green_bg}${crust_fg}${git_content}|${green_fg}")
  fi
fi

# Segment 4: AWS profile (only if AWS_PROFILE is set)
if [ -n "$AWS_PROFILE" ]; then
  segments+=("peach|${peach_bg}${crust_fg}  ${AWS_PROFILE} |${peach_fg}")
fi

# Segment 5: model name
segments+=("blue|${blue_bg}${crust_fg} ${model} |${blue_fg}")

# Segment 6: context window remaining
if [ -n "$remaining" ]; then
  remaining_int=${remaining%.*}
  segments+=("peach|${peach_bg}${crust_fg} Context Remaining: ${remaining_int}% |${peach_fg}")
fi

# ── Render ─────────────────────────────────────────────────────────────────
# Walk the segment array, printing each segment's content followed by a
# Powerline arrow whose foreground matches the current segment's bg and
# whose background matches the next segment's bg (or transparent if last).
output=""
total=${#segments[@]}
for (( i = 0; i < total; i++ )); do
  IFS='|' read -r _name content arrow_fg <<< "${segments[$i]}"
  output+="$content"

  if (( i + 1 < total )); then
    IFS='|' read -r next_name _next_content _next_arrow <<< "${segments[$((i + 1))]}"
    case "$next_name" in
      surface0) next_bg="$surface0_bg" ;;
      green)    next_bg="$green_bg" ;;
      peach)    next_bg="$peach_bg" ;;
      blue)     next_bg="$blue_bg" ;;
      mauve)    next_bg="$mauve_bg" ;;
    esac
    output+="${next_bg}${arrow_fg}${sep}${reset}"
  else
    output+="${reset}${arrow_fg}${sep}${reset}"
  fi
done

printf '%s\n' "$output"
