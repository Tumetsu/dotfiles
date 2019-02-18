export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

HIST_STAMPS="mm/dd/yyyy"
# ZSH_CUSTOM=$HOME/.zsh/

plugins=(
    vi-mode
    virtualenvwrapper
    vagrant
    systemd
    sudo
    tmux
    cargo
    encode64
    command-not-found
    ssh-agent
    autojump
    fzf
)
source $ZSH/oh-my-zsh.sh

##
## User config
##
fpath=($HOME/.zsh/completions $fpath)
# enable autocomplete function
autoload -U compinit && compinit

## disable the XON/XOFF tty flow feature [ctrl-S|ctrl-Q]
stty -ixon
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH=${PATH}:${HOME}/bin
export PATH=${PATH}:/home/boogy/.cargo/bin
export PATH=${PATH}:${HOME}/.local/bin
export PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"

export LANG=en_US.UTF-8
export EDITOR='vim'
export VIEW='vim'
export FZF_CTRL_R_OPTS='--reverse'
export TERM=xterm-256color

zsh_custom_files=(
    aliases
    directories
    prompt
    expandalias
    python
    virtualbox
    docker
    ssh
)
for zsh_config_file in $zsh_custom_files; do
    ZSH_FULL_FILE_PATH="${HOME}/.zsh/${zsh_config_file}.zsh"
    [ -f $FULL_FILE_PATH ] && source "${ZSH_FULL_FILE_PATH}" &>/dev/null
done

test -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    && source $_
test -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    && source $_

## bash files
##
function source_bash {
    emulate -L bash
    builtin source "$@"
}

bash_config_files=(
    functions
    aliases
    ctf
    git
)
for config_file in $bash_config_files; do
    FULL_FILE_PATH="${HOME}/.bash/${config_file}.bash"
    [ -f $FULL_FILE_PATH ] && source_bash "${FULL_FILE_PATH}" &>/dev/null
done

test -f ~/.bash_local \
    && source_bash ${HOME}/.bash_local &>/dev/null

