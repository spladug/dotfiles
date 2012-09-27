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
        # sudo apt-get install $VIMPACKAGE make ruby-dev rake 
        ;;
    darwin*)
        READLINK=greadlink
        ;;
    *)
        echo "Unknown platform. Dealing without apt."
        READLINK=readlink
        ;;
esac

# figure out where we are
WORKINGDIR=$(pwd)
DOTFILEDIR=$(dirname $($READLINK -f $0))

# make a listing of what there is to link
cd $DOTFILEDIR
FILES=$(ls -a | grep "^\." | grep -v -e "^..\?$" -e ".git")

if which git >> /dev/null
then
    # check out the submodules
    git submodule init
    git submodule update

    # pyflakes has its own submodule
    (
    cd .vim/bundle/pyflakes-vim
    git submodule init
    git submodule update
    )
else
    echo "Git not found. Doing my best without."
fi

# backup any extant files
BACKUPDIR=~/.dotfiles_backup

for file in $FILES bin; do
    if [ -e ~/$file ]; then
        echo "backing up $file..."
        mkdir -p $BACKUPDIR
        mv --backup=numbered ~/$file $BACKUPDIR/
    fi
done

# put the symlinks in place
for file in $FILES; do
    ln -s ${DOTFILEDIR}/${file} ~/${file}
done

# also do the bin
ln -s ${DOTFILEDIR}/bin ~/bin

# all done, go back to where we started
cd $WORKINGDIR
