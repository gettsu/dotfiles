.PHONY: help setup-keyboard install-deps gen-dirs
DEPS := neovim wezterm tmux i3 picom fcitx5 feh archlinux-wallpaper zsh pyenv
.DEFAULT_GOAL := help

help: ## Show options
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

set-links: ## Set symbolic link
	-@ ln -s ~/dotfiles/init.lua ~/.config/nvim/init.lua
	-@ ln -s ~/dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
	-@ ln -s ~/dotfiles/wezterm.lua ~/.config/wezterm/wezterm.lua
	-@ ln -s ~/dotfiles/cspell.json ~/.config/cspell/cspell.json
	-@ ln -s ~/dotfiles/alacritty.yml ~/.config/alacritty/alacritty.yml
	-@ ln -s ~/dotfiles/custom-words.txt ~/.local/share/cspell/custom-words.txt
	-@ ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
	-@ ln -s ~/dotfiles/i3-config ~/.config/i3/config
	-@ ln -s ~/dotfiles/.fehbg ~/.fehbg
	-@ ln -s ~/dotfiles/.zshrc-basic ~/.zshrc

setup-keyboard: ## Setup keyboard
	sudo cp ~/dotfiles/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf

install-deps: ## Install dependencies
	sudo pacman -S $(DEPS)

gen-dirs: ## Generate directories
	-@ mkdir ~/.config/nvim
	-@ mkdir ~/.config/wezterm
	-@ mkdir ~/.config/alacritty
	-@ mkdir ~/.config/cspell
	-@ mkdir ~/.local/share/cspell
	-@ mkdir ~/.config/i3
