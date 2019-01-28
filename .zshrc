export ZSH="/home/boogy/.oh-my-zsh"

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
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

HIST_STAMPS="mm/dd/yyyy"
ZSH_CUSTOM=$HOME/.zsh/

plugins=(
    # custom plugins
    aliases
    archlinux
    directories
    prompt
    expandalias

    # oh-my-zsh plugins
    vi-mode
    virtualenvwrapper
    vagrant
    virtualbox
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
## disable the XON/XOFF tty flow feature [ctrl-S|ctrl-Q]
stty -ixon
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH=${PATH}:${HOME}/bin
export PATH=${PATH}:/home/boogy/.cargo/bin
export PATH=${PATH}:${HOME}/.local/bin

export LANG=en_US.UTF-8
export EDITOR='vim'
export VIEW='vim'
export FZF_CTRL_R_OPTS='--reverse'

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

##
## Load all the goods
##
#
for config_file in $(ls ${HOME}/.bash/*.bash); do
    source_bash ${config_file} &>/dev/null
done
test -f ~/.bash_local \
    && source_bash ${HOME}/.bash_local &>/dev/null

