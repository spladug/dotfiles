#!/bin/sh

readonly ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
readonly ALACRITTY_THEME_DIR="${ALACRITTY_CONFIG_DIR}/themes/themes"

readonly LIGHT_THEME="night_owlish_light"
readonly DARK_THEME="wombat"

update_alacritty_color_scheme() {
    case "$1" in
        *prefer-dark*)
            theme=$DARK_THEME
            ;;
        *default*)
            theme=$LIGHT_THEME
            ;;
    esac

    ln -sf "${ALACRITTY_THEME_DIR}/${theme}.toml" "${ALACRITTY_CONFIG_DIR}/active-theme.toml"
    touch "${ALACRITTY_CONFIG_DIR}/alacritty.toml"  # trigger reload of config since symlinks aren't tracked
}

update_alacritty_color_scheme "$(dconf read /org/gnome/desktop/interface/color-scheme)"
dconf watch /org/gnome/desktop/interface/color-scheme | while read -r change; do
    update_alacritty_color_scheme "$change"
done
