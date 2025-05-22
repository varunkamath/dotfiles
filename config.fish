if status is-interactive
    # Commands to run in interactive sessions can go here
end

function starship_transient_rprompt_func
  starship module time
end
function starship_transient_prompt_func
  starship module character
end
starship init fish | source
enable_transience

zoxide init fish | source

set DISABLE_UNTRACKED_FILES_DIRTY "true"

export PATH="/opt/homebrew/Cellar/tcl-tk/bin:$PATH"

if test -f "$HOME/.cargo/env"
    fish_add_path "$HOME/.cargo/bin"
end

if test -f "$HOME/.local/bin/env"
    fish_add_path "$HOME/.local/bin"
end

alias ls "lsd"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
