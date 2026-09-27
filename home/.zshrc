# Created by newuser for 5.9.2
export PATH="$HOME/.local/bin:$PATH"

# ---- История ----
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space autocd interactive_comments

# ---- Автодополнение (Tab) ----
fpath=(~/.zsh/zsh-completions/src $fpath)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ---- Привычные клавиши ----
bindkey -e
bindkey '^[[H' beginning-of-line      # Home
bindkey '^[[F' end-of-line            # End
bindkey '^[[3~' delete-char           # Delete
bindkey '^[[1;5D' backward-word       # Ctrl+Left
bindkey '^[[1;5C' forward-word        # Ctrl+Right
bindkey '^H' backward-kill-word       # Ctrl+Backspace
bindkey '^[[3;5~' kill-word           # Ctrl+Delete
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search; zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # Стрелка вверх: поиск по началу команды
bindkey '^[[B' down-line-or-beginning-search

# ---- fzf: Ctrl+R — поиск по истории ----
source <(fzf --zsh)

# ---- Промпт (серый стиль) ----
autoload -Uz vcs_info add-zsh-hook
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '  %b%u%c'
zstyle ':vcs_info:git:*' actionformats '  %b (%a)%u%c'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' ●'
zstyle ':vcs_info:*' stagedstr ' ✚'

_cmd_start() { _t0=$EPOCHREALTIME }
_prompt_pre() {
  local ret=$?
  vcs_info
  local took=''
  if [[ -n $_t0 ]]; then
    local d=$(( EPOCHREALTIME - _t0 )); unset _t0
    (( d >= 2 )) && took=$(printf ' 󱦟 %.1fs' $d)
  fi
  local err=''
  (( ret )) && err="%F{167}✘ $ret%f  "
  local left="%F{240}╭─%f %F{252}%B %n%b%f%F{240}@%m%f  %F{250} %~%f%F{244}${vcs_info_msg_0_//\%/%%}%f%F{242}${took}%f"
  local right="${err}%F{240} %*%f"
  # выравниваем время по правому краю первой строки
  local zero='%([BSUbfksu]|([FK]|){*})'
  local lw=${#${(S%%)left//$~zero/}} rw=${#${(S%%)right//$~zero/}}
  local pad=$(( COLUMNS - lw - rw - 1 ))
  (( pad < 1 )) && pad=1
  PROMPT=$'\n'"${left}${(l:$pad:: :)}${right}"$'\n'"%F{240}╰─%f%(?.%F{255}.%F{167})❯%f "
}
zmodload zsh/datetime
add-zsh-hook preexec _cmd_start
add-zsh-hook precmd _prompt_pre
RPROMPT=''

alias ls='ls --color=auto' ll='ls -lah' grep='grep --color=auto'

# ---- Подсказки из истории (серым, принять — стрелка вправо) ----
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
