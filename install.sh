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
    podman
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

function install_shell {
    podman run --rm -v ${root}/src:/src -w /src ubuntu:20.04 ./build-shell.sh
    make -C src/shell install configure enable
}

function configure_workspaces {
    dconf write /org/gnome/shell/overrides/dynamic-workspaces false
    dconf write /org/gnome/desktop/wm/preferences/num-workspaces 10

    for i in {1..10}
    do
       dconf write /org/gnome/shell/keybindings/switch-to-application-$i "@as []"
       dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-$i "['<Super>$i']"
       dconf write /org/gnome/desktop/wm/keybindings/move-window-to-workspace-$i "['<Super><Shift>$i']"
    done
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-10 "['<Super>0']"
    dconf write /org/gnome/desktop/wm/keybindings/move-window-to-workspace-10 "['<Super><Shift>10']"

    gsettings set org.gnome.desktop.interface enable-animations false
}

function do_install {
    # pull in the vim modules etc.
    git submodule update --init

    local package_needs_installation=no
    for package in "${required_packages[@]}"; do
        if ! dpkg -s "${package}" 2>/dev/null | grep -q 'install ok installed'; then
            package_needs_installation=yes
            break
        fi
    done

    if [[ "$package_needs_installation" = "yes" ]]; then
        sudo apt-get update
        sudo apt-get install -y "${required_packages[@]}"
    fi

    install bin .local/bin
    install lib/python .local/lib/python

    install_dotfile profile
    install_dotfile bashrc
    ensure_xdg_data_dir bash

    install_xdg_config git

    install_xdg_config environment.d
    systemctl --user daemon-reload

    install_xdg_config vim
    ensure_xdg_data_dir vim/{undo,swap,backup}
    if [[ ! /etc/alternatives/editor -ef /usr/bin/vim.nox ]]; then
        sudo update-alternatives --set editor /usr/bin/vim.nox
    fi

    install share/gnome-shell/extensions .local/share/gnome-shell/extensions
    gnome-extensions enable "simply.workspaces@andyrichardson.dev"

    install_shell
    configure_workspaces
}

# only run the active bits of code if we're not being sourced for someone else
# to use our functions
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    do_install
fi
