import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders

import qualified Data.Map as M


main = xmonad $ gnomeConfig
    { borderWidth           = 2
    , terminal              = "gnome-terminal"
    , normalBorderColor     = "#3c3b37"
    , focusedBorderColor    = "#632d85"
    , manageHook            = myManageHook <+> manageHook gnomeConfig
    , layoutHook            = smartBorders $ layoutHook gnomeConfig
    , keys                  = myKeys <+> keys gnomeConfig
    }


myKeys (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, xK_p), dmenuRun)
    ]

-- this assumes a properly patched dmenu capable of xft fonts is available
dmenuRun = spawn "dmenu_run -i -b -fn 'Bitstream Vera Sans Mono-9' \
                            \-nb '#1e2426' -nf '#babdb6' \
                            \-sb '#632d85' -sf '#ffffff' \
                            \-p 'run> '"

myManageHook = composeOne [
                    isFullscreen -?> doFullFloat
               ]
