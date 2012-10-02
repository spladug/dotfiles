#!/bin/bash

set -e

# where is the GNU readlink?
if which greadlink > /dev/null; then
    READLINK=greadlink
else
    READLINK=readlink
fi

# install extra packages if on debian/ubuntu and desired
if which whiptail > /dev/null; then
    if whiptail --yesno "install additional packages for vim?" 10 60 \
                --yes-button "install" \
                --no-button "skip"; then
        if dpkg -l xorg > /dev/null; then
            VIM="vim-gnome ttf-bitstream-vera"
        else
            VIM="vim-nox"
        fi

        sudo apt-get install $VIM pyflakes
    fi
fi

# figure out where we are
WORKINGDIR=$(pwd)
DOTFILEDIR=$(dirname $($READLINK -f $0))

# make a listing of what there is to link
cd $DOTFILEDIR
FILES=$(ls -a | grep "^\." | grep -v -e "^..\?$" -e ".git")

# check out the submodules
git submodule init
git submodule update

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

# also do the bin
ln -s ${DOTFILEDIR}/bin ~/bin
