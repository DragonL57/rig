#!/usr/bin/env bash
# Write the eight agent definitions in the layout each harness expects.
# Sourced by install.sh; the kit's own copies under agents/ stay the source
# of truth, these are translations of them.
#
# Verified 2026-08-05:
#   pi           .pi/agents/          frontmatter: description, tools, extensions, thinking, model
#   claude code  .claude/agents/      frontmatter: name, description, tools, model
#   opencode     .opencode/agent/     frontmatter: name, description, mode, tools, model
#   codex        .codex/agents/       TOML: name, description, model, developer_instructions
#
# The body is copied verbatim every time; only its wrapper differs. Each writer
# takes the model and effort this harness resolved for that agent and pins them.
# fallback-runner is unpinned so the orchestrator must select its model at call time.

# Body of a kit agent file: everything after the closing frontmatter fence.
agent_body() {
    awk 'BEGIN { fence = 0 } /^---$/ { fence++; next } fence >= 2' "$1"
}

# Comma-separated tools of a kit agent file, empty when it grants all.
agent_tools() {
    awk -F': *' '/^tools:/ { print $2; exit }' "$1"
}

# Whether a kit agent declares a tool that edits files, from its tools list. An
# empty list or "all" grants every tool, so it can write. Codex and opencode
# express a read-only sandbox, so they key off this. A `read, bash` agent can
# still write through a shell; the list is what the agent was granted, not what
# the shell can reach.
agent_can_write() {
    local tools
    tools="$(agent_tools "$1" | tr -d ' ')"
    case "$tools" in
        ""|all) return 0 ;;
    esac
    case ",$tools," in
        *,write,*|*,replace,*|*,replace_match,*|*,insert,*) return 0 ;;
    esac
    return 1
}

# Canonical effort level, translated to the selected harness's native field.
agent_thinking() {
    awk -F': *' '/^thinking:/ { print $2; exit }' "$1"
}

# One-line description, frontmatter folding removed.
agent_description() {
    awk '
        /^description: *>-?$/ { collecting = 1; next }
        collecting && /^[a-z]+:/ { exit }
        collecting { sub(/^ +/, ""); printf "%s ", $0 }
    ' "$1" | sed -e 's/ *$//'
}

# pi reads the kit's own format, so this only inserts the model pin and
# replaces the thinking level with the assigned effort.
write_pi_agent() {
    local src="$1" dst="$2" model="$3" effort="$4"
    if [ -z "$model" ]; then
        cp "$src" "$dst"
        return
    fi
    # Frontmatter ends at the second fence; the pin goes just above it.
    awk -v model="$model" -v effort="$effort" '
        BEGIN { fence = 0 }
        /^---$/ {
            fence++
            if (fence == 2) print "model: " model
        }
        fence < 2 && /^thinking:/ { print "thinking: " effort; next }
        { print }
    ' "$src" > "$dst"
}

# Claude Code: tools are capitalised names, and "all" is expressed by omission.
# A writing agent needs Edit as well as Write, and pi's editing tools (replace,
# replace_match, insert) have no Claude Code equivalent but Edit. codemode is a pi
# built-in with no Claude Code equivalent, so it contributes no tool.
claude_tools() {
    case "$1" in
        all|"") return ;;
    esac
    # One token at a time, so a name that contains another name cannot be
    # rewritten by accident. An unknown name passes through unchanged.
    printf '%s\n' "$1" | tr ',' '\n' | while read -r tool; do
        case "$(printf '%s' "$tool" | tr -d ' ')" in
            ""|codemode) ;;
            read) printf 'Read\n' ;;
            bash) printf 'Bash\n' ;;
            write) printf 'Write\nEdit\n' ;;
            replace|replace_match|insert) printf 'Edit\n' ;;
            grep) printf 'Grep\n' ;;
            find|ls) printf 'Glob\n' ;;
            *) printf '%s\n' "$tool" ;;
        esac
    done | sort -u | paste -sd, -
}

write_claude_agent() {
    local src="$1" dst="$2" model="$3" effort="$4" name tools
    name="$(basename "$src" .md)"
    tools="$(claude_tools "$(agent_tools "$src")")"
    {
        echo "---"
        echo "name: $name"
        echo "description: $(agent_description "$src")"
        [ -n "$tools" ] && echo "tools: $tools"
        [ -n "$model" ] && echo "model: $model"
        [ -n "$model" ] && echo "effort: $effort"
        echo "---"
        agent_body "$src"
    } > "$dst"
}

write_opencode_agent() {
    local src="$1" dst="$2" model="$3" effort="$4" name
    name="$(basename "$src" .md)"
    {
        echo "---"
        echo "name: $name"
        echo "description: $(agent_description "$src")"
        echo "mode: subagent"
        [ -n "$model" ] && echo "model: $model"
        case "${model##*/}" in
            gpt-6-*|gpt-6.*)
                echo "reasoningEffort: $effort"
                echo "forceReasoning: true"
                ;;
            gpt-*|deepseek-*) [ -n "$model" ] && echo "reasoningEffort: $effort" ;;
            claude-*-5-5) echo "effort: $effort" ;;
        esac
        if ! agent_can_write "$src"; then
            echo "tools:"
            echo "  write: false"
            echo "  edit: false"
        fi
        echo "---"
        agent_body "$src"
    } > "$dst"
}

# Codex takes TOML, with the prompt in a multi-line string. Inspection-only
# agents get sandbox_mode = "read-only", matching the boundary in their prompts.
write_codex_agent() {
    local src="$1" dst="$2" model="$3" effort="$4" name
    name="$(basename "$src" .md)"
    {
        printf 'name = "%s"\n' "$name"
        printf 'description = "%s"\n' "$(agent_description "$src" | sed 's/"/\\"/g')"
        [ -n "$model" ] && printf 'model = "%s"\n' "$model"
        [ -n "$model" ] && printf 'model_reasoning_effort = "%s"\n' "$effort"
        if ! agent_can_write "$src"; then
            printf 'sandbox_mode = "read-only"\n'
        fi
        printf 'developer_instructions = """\n'
        # A closing triple quote inside the body would end the string early.
        agent_body "$src" | sed 's/"""/\x27\x27\x27/g'
        printf '"""\n'
    } > "$dst"
}

# Where each harness keeps its project-scoped agents.
harness_dir() {
    case "$2" in
        pi)       echo "$1/.pi/agents" ;;
        claude)   echo "$1/.claude/agents" ;;
        opencode) echo "$1/.opencode/agent" ;;
        codex)    echo "$1/.codex/agents" ;;
    esac
}

# Translate one kit agent into the layout a harness expects, pinning the model
# and effort that harness resolved for it. Callers set model_<harness>_<agent>
# and effort_<harness>_<agent>; fallback-runner deliberately has neither.
write_harness_agent() {
    local src="$1" harness="$2" dst="$3" agent model_var effort_var model effort
    agent="$(basename "$src" .md)"
    model_var="$(assignment_var model "$harness" "$agent")"
    effort_var="$(assignment_var effort "$harness" "$agent")"
    model="${!model_var-}"
    effort="${!effort_var:-$(agent_thinking "$src")}"
    case "$harness" in
        pi)       write_pi_agent "$src" "$dst" "$model" "$effort" ;;
        claude)   write_claude_agent "$src" "$dst" "$model" "$effort" ;;
        opencode) write_opencode_agent "$src" "$dst" "$model" "$effort" ;;
        codex)    write_codex_agent "$src" "$dst" "$model" "$effort" ;;
    esac
}

# The file name one harness gives a kit agent.
harness_agent_file() {
    local name="$(basename "$1" .md)"
    case "$2" in
        codex) echo "$name.toml" ;;
        *)     echo "$name.md" ;;
    esac
}

# Write every agent in the layout one harness expects.
write_harness_agents() {
    local kit="$1" target="$2" harness="$3" dir
    dir="$(harness_dir "$target" "$harness")"
    mkdir -p "$dir"
    for agent in "$kit"/agents/*.md; do
        write_harness_agent "$agent" "$harness" "$dir/$(harness_agent_file "$agent" "$harness")"
    done
}
