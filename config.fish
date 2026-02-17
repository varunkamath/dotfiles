if status is-interactive
    # Commands to run in interactive sessions can go here
end

export NODE_OPTIONS="--use-system-ca"
export UV_HTTP_TIMEOUT=300

function starship_transient_rprompt_func
  starship module battery
  starship module time
end
function starship_transient_prompt_func
  starship module character
end
starship init fish | source
enable_transience

zoxide init fish | source

set DISABLE_UNTRACKED_FILES_DIRTY "true"
set -x CLAUDE_CODE_SUBAGENT_MODEL claude-opus-4-6
set -x CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS 1

export PATH="/opt/homebrew/Cellar/tcl-tk/bin:$PATH"

if test -f "$HOME/.cargo/env"
    fish_add_path "$HOME/.cargo/bin"
end

if test -f "$HOME/.local/bin/env"
    fish_add_path "$HOME/.local/bin"
end

alias ls "lsd"

function jjship
    set branch (jj log -r '@-' --no-graph -T 'bookmarks')
    if test -z "$branch"
        echo "No bookmark on parent commit"
        return 1
    end
    jj ship && jj git push --bookmark "$branch" && git stash -q && git switch "$branch" && git stash pop -q
end

export UV_NATIVE_TLS=true

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# pnpm
set -gx PNPM_HOME "/Users/e439996/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

fish_add_path $HOME/.local/bin
