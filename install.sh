#!/bin/bash
#
# Copy all the dot files in the user's home directory
# and source them
#

THIS_DIR=$(cd $(dirname "$0"); pwd)
INSTALLDIR=$HOME

MANAGED_FILES=(
    ~/bin
    ~/.zshrc
    ~/.zsh
    ~/.bash
    ~/.bash_aliases
    ~/.vim
    ~/.vimrc
    ~/.tmux.conf
    ~/.pythonrc.py
    ~/.screenrc
    ~/.gdbinit
    ~/.radarerc
    ~/.Xresources
)

## Install necessary packages
test $(command -v curl) || sudo apt install curl
test $(command -v wget) || sudo apt install wget

test -d ${INSTALLDIR} || mkdir -p ${INSTALLDIR}

cd ${INSTALLDIR}
test -d dotfiles || git clone https://github.com/boogy/dotfiles.git && \
cd ${INSTALLDIR}/dotfiles

# if test -z $1; then
#     read -p "Do you want to delete existing files/directorys ? [y/n]: " CLEAN_EXISTING_FILES
# else
#     CLEAN_EXISTING_FILES=$1
# fi
CLEAN_EXISTING_FILES=${1:-yes}

if [[ $CLEAN_EXISTING_FILES =~ [Y|y] ]]; then
    for FILE in ${MANAGED_FILES[@]}; do
        echo "Deleting $FILE" && rm -rf "$FILE"
    done
fi

## copy i3-vm config
# $(which cp) -rf i3 ~/.config/
# rm -rf ~/.config/i3
# ln -sf ${THIS_DIR}/.config/i3 ~/.config/

##
## copy/symlink files to installdir
##
for FILE in ${MANAGED_FILES[@]}; do
    STRIPED_FILE_NAME=${FILE##*/}
    echo "Copying ${THIS_DIR}/${STRIPED_FILE_NAME} to ${INSTALLDIR}"
    ln -sf ${THIS_DIR}/${STRIPED_FILE_NAME} ${INSTALLDIR}
done
## link .config files
for DOT_FILE in $(ls .config/); do
    rm -rf ~/.config/$DOT_FILE
    ln -sf $THIS_DIR/$DOT_FILE ~/.config
done


for DOT_FILE in $(ls .config); do
    if [[ $CLEAN_EXISTING_FILES =~ [Y|y] ]]; then rm -rf $DOT_FILE; fi
    ln -sf $THIS_DIR/.config/$DOT_FILE ~/.config/
done


##
## Install Plug for plugin management
##
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

##
## Install powerline fonts
##
git clone https://github.com/powerline/fonts.git --depth=1 ${INSTALLDIR}/powerline_fonts
cd ${INSTALLDIR}/powerline_fonts
./install.sh
rm -rf ${INSTALLDIR}/powerline_fonts


##
## Load custom snippets for vim-snippets in UltiSnips format
##
ln -sf $HOME/.vim/custom-snippets $HOME/.vim/UltiSnips

## Make sure that .bash_aliases is loaded
[ $(uname) = 'Linux' ] && {
  grep -qEo ".bash_aliases" ~/.bashrc || echo "source ~/.bash_aliases" >> ~/.bashrc
  test -f ~/.bashrc && chmod 0700 $_ && source $_
}

[ $(uname) = 'Darwin' ] && {
  test -f ~/.profile || touch ~/.profile && chmod 0700 $_
  grep -qEo ".bash_aliases" ~/.bashrc || echo "source ~/.bash_aliases" >> ~/.profile
  test -f ~/.profile && chmod 0700 $_ && source $_
}

