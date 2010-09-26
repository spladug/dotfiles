#!/bin/bash

DOTFILEDIR=$(dirname $(readlink -f $0))

# determine if X is installed or not 
# (tells us which vim to use)
# ...there has to be a better way to do this
if [ -f /usr/bin/startx ]; then
    VIMPACKAGE=vim-gnome
else
    VIMPACKAGE=vim-nox
fi

# install the prereqs
sudo aptitude install $VIMPACKAGE ruby-dev rake build-essential

# check out the submodules
git submodule init
git submodule update

# build the command-t c extension
pushd .vim/bundle/command-t
rake make
popd

# make a listing of what there is to link
pushd $DOTFILESDIR
FILES=$(ls -a | grep "^\." | grep -v -e "^..\?$" -e ".git$" -e ".gitmodules$")
popd 

# backup any extant files
BACKUPDIR=~/.dotfiles_backup

for file in $FILES; do
    if [ -e ~/$file ]; then
        echo "backing up $file..."
        mkdir -p $BACKUPDIR
        mv ~/$file $BACKUPDIR/
    fi
done

# put the symlinks in place
for file in $FILES; do
    ln -s ${DOTFILEDIR}/${file} ~/${file}
done
