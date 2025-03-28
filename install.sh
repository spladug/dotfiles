#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
    echo "Please run this installer as yourself, not root."
    exit 1
fi

readonly progname=$(basename "$0")
readonly root=$(dirname "$(readlink -f "$0")")

readonly backup_dir=$(mktemp -d "$HOME/dotfile-backup.XXXXXX")
function _remove_empty_backups {
    rmdir --ignore-fail-on-non-empty "$backup_dir"
}
trap _remove_empty_backups EXIT

function install_packages {
    local package_needs_installation=no
    for package in "$@"; do
        if ! pacman -Qi "${package}" &>/dev/null; then
            package_needs_installation=yes
            break
        fi
    done

    if [[ "$package_needs_installation" = "yes" ]]; then
        sudo pacman --sync --noconfirm --needed "$@"
    fi
}

function install_file {
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
        install_file "etc/$path" ".${path}"
    done
}

function install_xdg_config {
    for path in "$@"; do
        install_file "etc/$path" ".config/$path"
    done
}

function install_xdg_data {
    for path in "$@"; do
        install_file "share/$path" ".local/share/$path"
    done
}

function ensure_xdg_data_dir {
    for path in "$@"; do
        mkdir -vp "${HOME}/.local/share/${path}"
    done
}

function ensure_xdg_state_dir {
    for path in "$@"; do
        mkdir -vp "${HOME}/.local/state/${path}"
    done
}

function ensure_xdg_cache_dir {
    for path in "$@"; do
        mkdir -vp "${HOME}/.cache/${path}"
    done
}

function build_docker_image {
    podman build -t "${1}" -f "dockerfiles/Dockerfile.${1}" dockerfiles/
}

function install_makepkg {
    # argument 1 should be the directory of the PKGBUILD
    # any subsequent arguments form an allowlist of which packages to install
    # if the PKGBUILD contains split packages
    pushd "$1"
    shift

    local packages_to_build
    local package_needs_building=no

    packages_to_build=$(makepkg --packagelist)
    for package in $packages_to_build; do
        if [[ ! -f $package ]]; then
            package_needs_building=yes
            break
        fi
    done

    if [[ "$package_needs_building" = "yes" ]]; then
        makepkg --syncdeps --noconfirm
    fi

    for package_path in $packages_to_build; do
        # apply allowlist if present
        if [[ "$#" -ne 0 ]]; then
            local filename
            local allowed=no

            filename=$(basename "$package_path")
            for allowed in "$@"; do
                if [[ "$filename" =~ ^${allowed}- ]]; then
                    allowed=yes
                    break
                fi
            done

            if [[ "$allowed" != yes ]]; then
                continue
            fi
        fi

        sudo pacman --upgrade --needed --noconfirm "$package_path"
    done

    popd
}

function enable_gnome_extension {
    local extension_uuid="$1"

    if ! gnome-extensions list | grep -q "$extension_uuid"; then
        echo "Extension '$extension_uuid' not found. Try restarting gnome shell before continuing."
        exit 1
    fi

    gnome-extensions enable "$extension_uuid"
}

function configure_gnome {
    dconf write /org/gnome/mutter/overlay-key '""'
    dconf write /org/gnome/desktop/interface/enable-hot-corners false

    dconf write /org/gnome/desktop/interface/enable-animations false

    dconf write /org/gnome/desktop/interface/clock-show-weekday true
    dconf write /org/gnome/desktop/interface/clock-show-seconds true

    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    dconf write /org/gnome/settings-daemon/plugins/color/night-light-enabled true

    dconf write /org/gnome/mutter/attach-modal-dialogs false

    dconf write /org/gnome/shell/keybindings/toggle-quick-settings "['<Shift><Super>s']"

    dconf write '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name' "'Launch Terminal'"
    dconf write '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command' "'/usr/bin/alacritty'"
    dconf write '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding' "'<Super>t'"
    dconf write '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings' "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

    dconf write '/org/gnome/shell/keybindings/toggle-application-view' "['<Super>slash']"
}

function configure_pop_shell {
    enable_gnome_extension pop-shell@system76.com

    /usr/share/gnome-shell/extensions/pop-shell@system76.com/scripts/configure.sh
    dconf write /org/gnome/shell/extensions/pop-shell/hint-color-rgba "'rgb(128, 0, 255)'"
    dconf write /org/gnome/shell/extensions/pop-shell/active-hint true
    dconf write /org/gnome/shell/extensions/pop-shell/tile-by-default true
    dconf write /org/gnome/shell/extensions/pop-shell/toggle-tiling "@as []"
}

function configure_workspaces {
    dconf write /org/gnome/mutter/dynamic-workspaces false
    dconf write /org/gnome/desktop/wm/preferences/num-workspaces 10

    for i in {1..10}
    do
       dconf write "/org/gnome/shell/keybindings/switch-to-application-$i" "@as []"
       dconf write "/org/gnome/desktop/wm/keybindings/switch-to-workspace-$i" "['<Super>$i']"
       dconf write "/org/gnome/desktop/wm/keybindings/move-to-workspace-$i" "['<Super><Shift>$i']"
    done
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-10 "['<Super>0']"
    dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-10 "['<Super><Shift>0']"

    # this must come after turning off dynamic workspaces
    enable_gnome_extension simply.workspaces@andyrichardson.dev
}

function configure_just_perfection {
    enable_gnome_extension just-perfection-desktop@just-perfection

    dconf write /org/gnome/shell/extensions/just-perfection/activities-button false
    dconf write /org/gnome/shell/extensions/just-perfection/workspace-popup false
    dconf write /org/gnome/shell/extensions/just-perfection/quick-settings-night-light false
    dconf write /org/gnome/shell/extensions/just-perfection/startup-status 0
    dconf write /org/gnome/shell/extensions/just-perfection/notification-banner-position 2
}

function do_install {
    git submodule update --init

    install_xdg_config environment.d
    systemctl --user daemon-reload
    # probably need to log out and in here

    install_packages \
        aws-vault \
        base-devel \
        bat \
        bat-extras \
        catatonit \
        eza \
        fzf \
        git \
        git-delta \
        gnome-shell-extension-appindicator \
        pass \
        pgcli \
        pyright \
        ripgrep \
        ruff \
        starship \
        ttf-sourcecodepro-nerd \
        vim \
        vim-airline \
        wmctrl \
        yamllint \
        zoxide \
        zsh \
        zsh-autosuggestions \
        zsh-history-substring-search \
        zsh-syntax-highlighting

    sudo mkdir -p /usr/local/share/zsh/site-functions
    sudo ln -sf /usr/share/zsh/site-functions/_eza /usr/local/share/zsh/site-functions/_eza

    build_docker_image psql
    build_docker_image heroku-cli
    build_docker_image diceware
    install_file bin .local/bin

    install_xdg_config zsh
    ensure_xdg_state_dir zsh
    ensure_xdg_cache_dir zsh

    install_xdg_config starship.toml

    install_xdg_config alacritty
    install_xdg_config git
    install_xdg_config yamllint
    install_file lib/python .local/lib/python

    install_xdg_config environment.d
    systemctl --user daemon-reload

    install_xdg_config vim
    ensure_xdg_data_dir vim/{undo,swap,backup}
    install_makepkg src/vi-vim-symlink

    install_xdg_config containers
    install_xdg_config gtk-3.0

    install_xdg_config systemd
    systemctl --user enable alacritty-theme-switcher.service
    systemctl --user start alacritty-theme-switcher.service
    systemctl --user enable alacritty-theme-switcher-restart.path
    systemctl --user start alacritty-theme-switcher-restart.path
    systemctl --user enable wallpaper.timer
    systemctl --user start wallpaper.timer

    # do all the makepkg work up front so we only have to restart the shell once
    install_makepkg src/pop-shell-shortcuts-git
    install_makepkg src/gnome-shell-extension-pop-shell-git
    install_makepkg src/gnome-shell-extension-simply-workspaces-git
    install_makepkg src/gnome-shell-extension-just-perfection-desktop
    configure_gnome
    configure_pop_shell
    configure_workspaces
    configure_just_perfection

    if [ ! -d "$GNUPGHOME" ]; then
        mkdir "$GNUPGHOME"
        chmod 0700 "$GNUPGHOME"
        echo 'pinentry-program /usr/bin/pinentry-gnome3' > "${GNUPGHOME}/gpg-agent.conf"
    fi

    gpg --import gpg/1password.asc
    install_makepkg src/1password

    gpg --import gpg/mullvad.asc
    install_makepkg src/mullvad-vpn-bin

    gpg --import gpg/slack.asc
    install_makepkg src/slack

    gpg --import gpg/hashicorp.asc
    install_makepkg src/tfenv
    sudo touch /opt/tfenv/use-gnupg
}

# only run the active bits of code if we're not being sourced for someone else
# to use our functions
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    do_install
fi
