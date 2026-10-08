# pkgbuilds

A [paru PKGBUILD repository](https://github.com/Morganamilo/paru#pkgbuild-repositories),
wired up by `Path=` in `~/.config/paru/paru.conf`. Packages here take priority
over the AUR, so a directory with the same `pkgname` as an AUR package masks
it. heptane doesn't need to know: it just asks paru for the name.

This dir sits outside `home/` on purpose so chezmoi never copies it anywhere.

Each GNOME release, bump the shell extensions here. The AUR packages tend to
lag by weeks and simply-workspaces is only maintained in my fork.
