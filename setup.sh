#!/usr/bin/bash 

# dotfiles path
DOTFILES=$(\
    builtin cd "$(\
    dirname "$(readlink -f "${BASH_SOURCE[0]}")")"\
    > /dev/null && pwd)
MACOS_DOTFILES=~/.macos-dotfiles

# prepare folders
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/spell
mkdir -vp ~/.config/autostart

# make soft symlinks
echo "- Symlinking dotfiles (${DOTFILES})"
"${MACOS_DOTFILES}"/bin/ln_dotfiles          ${DOTFILES}
ln -sfv "${MACOS_DOTFILES}"/inputrc          ~/.inputrc
ln -sfv "${MACOS_DOTFILES}"/bash_aliases     ~/.bash_aliases
ln -sfv "${MACOS_DOTFILES}"/bash_prompt      ~/.bash_prompt
ln -sfv "${MACOS_DOTFILES}"/vimrc            ~/.vimrc
ln -sfv "${MACOS_DOTFILES}"/vim/*            ~/.vim
ln -sfv "${DOTFILES}"/config/gtk-3.0/gtk.css ~/.config/gtk-3.0/gtk.css
ln -sfv "${DOTFILES}"/config/autostart/*     ~/.config/autostart
ln -sfv "${DOTFILES}"/fonts/*/*.otb          ~/.local/share/fonts

echo "- Enable bitmap fonts & reconfigure fontconfig"
sudo rm /etc/fonts/conf.d/70-no-bitmaps.conf
sudo ln -sfv /etc/fonts/conf.avail/70-yes-bitmaps.conf /etc/fonts/conf.d
sudo dpkg-reconfigure fontconfig
