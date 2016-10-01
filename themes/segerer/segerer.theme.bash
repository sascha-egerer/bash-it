# segerer bash-it theme
# @author Sascha Egerer <sascha.egerer@gmail.com>
#
# Theme inspired by:
# * ZSH agnoster theme: https://gist.github.com/agnoster/3712874
#
# Use the solarized color scheme:
#	https://github.com/altercation/solarized
#
# IMPORTANT: In all likelihood, you will need to install 
#	 a Powerline-patched font for this theme to render 
#	 correctly. https://gist.github.com/qrush/1595572


CURRENT_BG='NONE'
SEGMENT_SEPARATOR='⮀'
SCM_THEME_PROMPT_DIRTY=''
SCM_THEME_PROMPT_CLEAN=''
SCM_GIT_CHAR="±"
SCM_SVN_CHAR="⑆"
SCM_HG_CHAR="☿"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""
 
# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
	local bg fg
	[[ -n $1 ]] && bg="$1" || bg='black'
	[[ -n $2 ]] && fg="$2" || fg='white'

	if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
		echo -e -n " \[$(echo_color $CURRENT_BG fg)\]\[$(echo_color $bg bg)\]$SEGMENT_SEPARATOR \[$(echo_color $fg fg)\]"
	else
		echo -e -n "\[$(echo_color $bg bg)\] \[$(echo_color $fg fg)\]"
	fi

	CURRENT_BG=$bg

	[[ -n $3 ]] && echo -n $3
}
 
# End the prompt, closing any open segments
prompt_end() {
	if [[ $CURRENT_BG != 'NONE' && -n $CURRENT_BG ]]; then
		echo -e -n " \[$(echo_color reset)\]\[$(echo_color $CURRENT_BG fg)\]$SEGMENT_SEPARATOR"
	fi
	echo -e -n "\[$(echo_color reset)\] "
	CURRENT_BG=''
}
 
doubletime_scm_prompt() {
	CHAR=$(scm_char)
	if [ $CHAR = $SCM_NONE_CHAR ]; then
		return
	elif [ $CHAR = $SCM_GIT_CHAR ]; then
		git_prompt_status
	else
		prompt_segment 'green' 'white' "$(scm_prompt_info)"
	fi
}
git_prompt_status() {
	local git_status_output ref fg bg icon
	if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
		git_status_output=$(git status 2> /dev/null )
			ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"

		if [ -n "$(echo $git_status_output | grep 'Changes not staged')" ]; then
		fg='cyan'
		bg='black'
		icon='✗'
		elif [ -n "$(echo $git_status_output | grep 'Changes to be committed')" ]; then
		fg='yellow'
		bg='black'
		icon='^'
		elif [ -n "$(echo $git_status_output | grep 'Untracked files')" ]; then
		fg='red'
		bg='black'
		icon='+'
		elif [ -n "$(echo $git_status_output | grep 'nothing to commit')" ]; then
		fg='green'
		bg='white'
		icon='✓'
		else	
		fg='green'
		bg='white'
		icon='✓'
		fi

	prompt_segment $fg $bg "${ref/refs\/heads\//⭠ } $icon"
	fi
}

prompt_docker_host() {
	if [[ -n "$DOCKER_HOST" ]]; then
		prompt_segment 'blue' 'white' '🐋	 $DOCKER_HOST'
	fi
}

# Dir: current working directory
prompt_dir() {
	prompt_segment 'white' 'black' '\w'
}
 
# Status:
# - was there an error
# - am I root
prompt_status() {
	local symbols
	symbols=()
	[[ $RETVAL -ne 0 ]] && symbols+='✘'
	[[ $UID -eq 0 ]] && symbols+='⚡'

	[[ -n "$symbols" ]] && prompt_segment 'red' 'white' "$symbols"
}

prompt_user() {
	prompt_segment 'white' 'black' "$USER@$HOSTNAME"
}

build_prompt() {
	prompt_user
	prompt_dir
	doubletime_scm_prompt
	prompt_docker_host
	prompt_status
	prompt_end
}

## Main prompt
build_command() {
	RETVAL=$?
	PS1="$(build_prompt)"
}
 
PROMPT_COMMAND=build_command
