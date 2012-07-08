import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders


main = xmonad $ gnomeConfig
    { borderWidth           = 2
    , terminal              = "gnome-terminal"
    , normalBorderColor     = "#3c3b37"
    , focusedBorderColor    = "#632d85"
    , manageHook            = myManageHook <+> manageHook gnomeConfig
    , layoutHook            = smartBorders $ layoutHook gnomeConfig
    }


myManageHook = composeOne [
                    isFullscreen -?> doFullFloat
               ]
