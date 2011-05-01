#!/bin/bash

set -e

# platform-specific stuff 
case $OSTYPE in
    linux-gnu*)
        READLINK=readlink
        # determine if X is installed or not 
        # (tells us which vim to use)
        # ...there has to be a better way to do this
        if [ -f /usr/bin/startx ]; then
            VIMPACKAGE="vim-gnome ttf-bitstream-vera"
        else
            VIMPACKAGE=vim-nox
        fi

        # install the prereqs
        sudo aptitude install $VIMPACKAGE ruby-dev rake 
        ;;
    darwin*)
        READLINK=greadlink
        ;;
    *)
        echo "Unknown platform"
        exit 1
        ;;
esac

# figure out where we are
WORKINGDIR=$(pwd)
DOTFILEDIR=$(dirname $($READLINK -f $0))

# make a listing of what there is to link
cd $DOTFILEDIR
FILES=$(ls -a | grep "^\." | grep -v -e "^..\?$" -e ".git")

# check out the submodules
git submodule init
git submodule update

# build the command-t c extension
cd .vim/bundle/command-t
rake make

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

# all done, go back to where we started
cd $WORKINGDIR
