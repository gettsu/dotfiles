DEPS := neovim wezterm tmux i3 picom fcitx5 feh archlinux-wallpaper
all:
	- ln -s ~/dotfiles/init.lua ~/.config/nvim/init.lua
	- ln -s ~/dotfiles/wezterm.lua ~/.config/wezterm/wezterm.lua
	- ln -s ~/dotfiles/cspell.json ~/.config/cspell/cspell.json
	- ln -s ~/dotfiles/alacritty.yml ~/.config/alacritty/alacritty.yml
	- ln -s ~/dotfiles/custom-words.txt ~/.local/share/cspell/custom-words.txt
	- ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
	- ln -s ~/dotfiles/i3-config ~/.config/i3/config
	- ln -s ~/dotfiles/.fehbg ~/.fehbg
	- ln -s ~/dotfiles/.zshrc-basic ~/.zshrc

install-dep:
	sudo pacman -S $(DEPS)

gen-dirs:
	- mkdir ~/.config/nvim
	- mkdir ~/.config/wezterm
	- mkdir ~/.config/alacritty
	- mkdir ~/.config/cspell
	- mkdir ~/.local/share/cspell
	- mkdir ~/.config/i3
