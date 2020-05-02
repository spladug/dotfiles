#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
    echo "Please run this installer as yourself, not root."
    exit 1
fi

readonly progname=$(basename "$0")
readonly root=$(dirname "$(readlink -f "$0")")
readonly required_packages=(
    awscli
    fonts-firacode
    fzf
    pcscd
    ripgrep
    scdaemon
    vim-nox
)

readonly backup_dir=$(mktemp -d "$HOME/dotfile-backup.XXXXXX")
function _remove_empty_backups {
    rmdir --ignore-fail-on-non-empty "$backup_dir"
}
trap _remove_empty_backups EXIT

function install {
    local source="${root}/${1}"
    local dest="${HOME}/${2}"

    if [[ "$dest" -ef "$source" ]]; then
        echo "${progname}: nothing to do for '${dest}'"
        return
    fi

    if [[ -e "$dest" ]]; then
        mkdir -p "${backup_dir}/$(dirname "$2")"
        mv "$dest" "${backup_dir}/${2}"
        echo "${progname}: backed up '${dest}' to '${backup_dir}'"
    fi

    mkdir -v -p "$(dirname "$dest")"
    ln -s "$source" "$dest"
    echo "${progname}: installed '${dest}'"
}

function install_dotfile {
    for path in "$@"; do
        install "etc/$path" ".${path}"
    done
}

function install_xdg_config {
    for path in "$@"; do
        install "etc/$path" ".config/$path"
    done
}

function install_xdg_data {
    for path in "$@"; do
        install "share/$path" ".local/share/$path"
    done
}

function ensure_xdg_data_dir {
    for path in "$@"; do
        mkdir -vp "${HOME}/.local/share/${path}"
    done
}

function do_install {
    # pull in the vim modules etc.
    git submodule update --init

    sudo apt-get update
    sudo apt-get install -y "${required_packages[@]}"

    install bin .local/bin
    install lib/passmenu .local/lib/passmenu

    install_dotfile bashrc
    ensure_xdg_data_dir bash

    install_xdg_config git

    install_xdg_config regolith

    install_xdg_config environment.d
    systemctl --user daemon-reload

    install_xdg_config vim
    ensure_xdg_data_dir vim/{undo,swap,backup}
    sudo update-alternatives --set editor /usr/bin/vim.nox

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "passmenu"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "${HOME}/.local/lib/passmenu/passmenu"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>p"
}

# only run the active bits of code if we're not being sourced for someone else
# to use our functions
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    do_install
fi
