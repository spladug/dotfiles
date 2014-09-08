#!/bin/bash

DOTFILE_ROOT=$(dirname $(readlink -f $0))


function _back_up {
    local FILE=$1

    if [ -e $FILE -o -L $FILE ]; then
        mkdir -p ~/dotfile-backup
        mv $FILE ~/dotfile-backup/
    fi
}

function install_dotfile {
    local FILE=$1
    local TARGET=${2:-$HOME/.$FILE}

    _back_up $TARGET
    ln -s $DOTFILE_ROOT/$FILE $TARGET
}

function install_xdg_config {
    local FILE=$1
    local CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
    local TARGET=$CONFIG_DIR/$FILE/config

    _back_up $TARGET
    mkdir -p ${CONFIG_DIR}/$FILE
    ln -s $DOTFILE_ROOT/$FILE $TARGET
}
