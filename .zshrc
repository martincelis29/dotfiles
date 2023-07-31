export ZSH="$HOME/.oh-my-zsh"

plugins=(sudo git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search you-should-use)

# zsh-history-substring-search Binds
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

source $ZSH/oh-my-zsh.sh

# Set the default editor
export EDITOR=nvim
export VISUAL=nvim
alias vi='nvim'
alias svi='sudo nvim'

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
#export GREP_OPTIONS='--color=auto' #deprecated
alias grep="/usr/bin/grep $GREP_OPTIONS"
unset GREP_OPTIONS

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Edit this .zshrc file
alias ezsh='sudo nvim ~/.zshrc'
alias cls='clear'

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Alias's for multiple directory listing commands
alias ls='lsd -aFh --color=always --group-directories-first' # add colors and file type extensions
alias ll='lsd -Fla --color=always'                           # long listing format
#alias cat='bat'

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search files in the current folder
alias f="find . | grep "

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# Copy file with a progress bar
cpp() {
	set -e
	strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
		awk '{
	count += $NF
	if (count % 10 == 0) {
		percent = count / total_size * 100
		printf "%3d%% [", percent
		for (i=0;i<=percent;i++)
			printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
				printf "]\r"
			}
		}
	END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

# Install Starship - curl -sS https://starship.rs/install.sh | sh

eval "$(starship init zsh)"

alias jellyfin-start='sudo systemctl start jellyfin.service'
alias jellyfin-restart='sudo systemctl restart jellyfin.service'
alias jellyfin-stop='sudo systemctl stop jellyfin.service'
alias jellyfin-status='sudo systemctl status jellyfin.service'

alias dfc='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias xampp='sudo /opt/lampp/lampp'

export PATH=$PATH:/home/martin/.spicetify

declare -A pomo_options
pomo_options["work"]="50"
pomo_options["eat"]="20"
pomo_options["break"]="15"

pomodoro() {
	if [ -n "$1" -a -n "${pomo_options["$1"]}" ]; then
		val=$1
		echo $val
		timer ${pomo_options["$val"]}m
		notify-send -a "Pomodoro" "$val" "session done"
	fi
}

alias wo="pomodoro 'work'"
alias br="pomodoro 'break'"
alias eat="pomodoro 'eat'"
