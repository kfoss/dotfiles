
### LAST_UPDATED_AT '2021-03-15'
### BEGIN_ADD_BASHRC


# Environment variables.
export VISUAL='vim'
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# Terminal prompt formatting.
# If this is an xterm set the title to user@host:dir
PS1='${debian_chroot:+($debian_chroot)}\[\033[36m\]\u@\h\[\033[00m\]:\[\033[31m\]\W>\[\033[00m\]'
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Create new tmux session.
#  Usage: tmux_create_session <repo_name> </path/to/repo>
function tmux_create_session() {
  local REPO_NAME="${1}"
  local PATH_NAME="${2}"

  # Create a new  tmux session.
  tmux new-session -d -s "${REPO_NAME}"
  tmux attach -t "${REPOT_NAME}" \; \
                 set-option set-titles on \; \
                 set-option set-titles-string "${REPO_NAME}" \; \
                 split-window -h \; \
                 select-pane -t 0 \; \
                 detach
  tmux send-keys -t "${REPO_NAME}" "cd ${PATH_NAME}" Enter
  tmux attach -t "${REPO_NAME}"
}

# Override tmux to include helper commands.
function tmux() {
  local _CMD="${1}"
  if [[ "${_CMD}" == "ls" ]]; then
    /usr/bin/tmux list-sessions
  elif [[ "${_CMD}" == "at" ]]; then
    shift
    /usr/bin/tmux attach-session -t "${@}"
  else
    /usr/bin/tmux "${@}"
  fi
}

# Print list of processes using swap space.
function swap_usage() {
  echo -n "Getting swap usage..."
  THRESHOLD=1024

  # Save map of { size: "command1, command2, ..." }
  declare -a PROCESSES
  for PROCESS in /proc/*/status ; do
    SWAP=$(awk '/^Pid|VmSwap|Name/{printf $2 " " $3}END { print ""}' "${PROCESS}")

    # Get teh size in MB. Only track use of a meaningful amount of swap space.
    SIZE=$(echo "${SWAP}" | cut -d' ' -f 3)
    if [[ "${SIZE}" < "${THRESHOLD}" ]]; then continue; fi
    MEGABYTES=$((SIZE/1024))

    # Store a mapping of size=>name1,name2,...
    NAME=$(echo "${SWAP}" | cut -d' ' -f 1)
    PROCESSES[$MEGABYTES]="${PROCESSES[${MEGABYTES}]}, ${NAME}"
  done
  echo "Done!"

  # Print the results in descending order on size.
  YELLOW=$(tput setaf 190)
  NORMAL=$(tput sgr0)
  SORTED=$(for s in ${!PROCESSES[@]}; do echo "${s}"; done | sort -rn)
  for SIZE in ${SORTED[@]}; do
    printf "%s%+5s%sMB: %s\n" \
      "${YELLOW}" \
      "${SIZE}" \
      "${NORMAL}" \
      "${PROCESSES["${SIZE}"]:2}"
  done
}

function path_root() {
  local CURRENT="${1}"
  if [[ "${CURRENT}" == "" ]]; then
    CURRENT=$(pwd)
  fi
  echo "${CURRENT}" | sed -e  "s|dev.*||"
}

# Enable fzf.
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_COMMAND="ag --nocolor '$(path_root)' -g ''"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
--reverse --inline-info
'

# Utilities.
alias gss="git status -s"
alias gcom="git commit -am \"Commit: $(date "+%Y-%m-%d %H:%S")\""

# enable bash completion
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# overrule git SSL noisy failures
export GIT_SSL_NO_VERIFY=1

# aliases
# Quick launch tmux.
alias tmx='tmux new -s'
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# ls shorthands
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# enable sqlite3 to use command history
alias sqlite3="rlwrap sqlite3"
# remove orphaned files ending in ~
alias clean_cwd='find . -iname "*~" | while read f; do rm "$f"; echo "removed $f"; done'
# stop hadoop
alias hadoop_stop="for service in /etc/init.d/hadoop*; do sudo \$service stop; done"
# alert long running commands.  Use: "sleep 10; alert"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# check if system installed a given package
function is_installed(){
  local __package="$1"
  for __package; do
      dpkg -s "$__package" >/dev/null 2>&1 && {
          return 0
      } || {
          return
      }
  done
}

# notify the user
function notify_user(){
  local __msg=$1

  if is_installed zenity; then
    zenity --info --text "$__msg" &
  else
    echo -e "\n$__msg\n\n"
  fi
}

# ask the user a question
function ask_user(){
  local __msg=$1
    if is_installed zenity; then
    zenity --question --text "$__msg"
  else
    echo "$__msg [Yn]"
    read __confirm
    if [ "$__confirm" != "n" ]; then
      return 0
    else
      return
    fi
  fi
}

# notify and wait for user confirmation before continuing
function notify_and_wait(){
  local __msg=$1

  ask_user "$__msg \n\n\nReady to continue?"
  if [ "0" -ne "$?" ]; then
    notify_and_wait "$__msg"
  fi
}

# notify and wait for user confirmation before continuing
function ask_to_proceed(){
  local __msg=$1
  ask_user $__msg

  if [ "0" -eq "$?" ]; then
    return 0
  else
    return
  fi
}

# notify and continue without waiting for user confirmation
function notify_without_waiting(){
  local __msg=$1
  notify_user "$__msg"
}

# escape command-line quotes
function shell_quote() {
  # run in a subshell to protect the caller's environment
  (
    sep=''
    for arg in "$@"; do
      sqesc=$(printf '%s\n' "${arg}" | sed -e "s/'/'\\\\''/g")
      sep=' '
    done
  )
}

# setup local marks to easily jump to frequent directories
export MARKPATH=$HOME/.marks
function jump {
    cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
}
function mark {
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark {
    rm -i $MARKPATH/$1
}
function marks {
    ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}

# grep for a specific pid
function grep_pid() {
  __input=$1
  ps aux | grep $__input | grep -v grep | sed -e 's/\s\+/ /g' | cut -d' ' -f 2
}

# grep for a specific pmap
function grep_pmap() {
  __input=$1
  pmap $(ps aux | grep $__input | grep -v grep | sed -e 's/\s\+/ /g' | cut -d' ' -f 2)
}

function remove_old_kernels() {
  sudo dpkg --list 'linux-image*'| awk '{ if ($1=="ii") print $2}'| grep -v `uname -r`
  echo "sudo apt-get purge ..."
  echo "sudo apt-get autoremove --assume-yes"
  echo "sudo update-grub"
}

export JAVA_HOME="/usr/lib/jvm/java-8-oracle"

###END_ADD_BASHRC
