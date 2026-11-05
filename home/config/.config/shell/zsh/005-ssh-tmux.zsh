# Auto-attach tmux for interactive SSH logins.
#
# Behaviour:
#   * Only interactive SSH shells are wrapped; local terminals, `ssh host
#     command`, scp/sftp and shells already inside tmux are left alone.
#   * The session name comes from the login directory (same default as `t`),
#     so a dropped connection reattaches to the same session.
#   * SSH_AUTH_SOCK is redirected through ~/.ssh/ssh_auth_sock before tmux
#     starts, so panes that outlive a connection still have a valid agent
#     socket after reconnecting.
#
# Opt out with NYX_NO_TMUX=1. Override the name with NYX_TMUX_SESSION=<name>.

function _nyx_ssh_tmux() {
  [[ -o interactive ]] || return 0
  [[ -t 0 && -t 1 ]] || return 0
  [[ -n ${SSH_TTY:-} || -n ${SSH_CONNECTION:-} ]] || return 0
  [[ -z ${TMUX:-} ]] || return 0
  [[ ${NYX_NO_TMUX:-0} != 1 ]] || return 0
  [[ ${TERM:-dumb} != dumb ]] || return 0
  (( $+commands[tmux] )) || return 0

  local session="${NYX_TMUX_SESSION:-${PWD:t}}"
  session="${session//[.:]/_}"

  local sock=""
  if [[ -n ${SSH_AUTH_SOCK:-} && -S ${SSH_AUTH_SOCK} && -d $HOME/.ssh ]]; then
    sock="$HOME/.ssh/ssh_auth_sock"
    ln -sfn "$SSH_AUTH_SOCK" "$sock" 2>/dev/null && export SSH_AUTH_SOCK="$sock"
  fi

  if [[ -n $sock ]]; then
    exec env SSH_AUTH_SOCK="$sock" tmux new-session -A -s "$session" -c "$PWD"
  else
    exec tmux new-session -A -s "$session" -c "$PWD"
  fi
}

_nyx_ssh_tmux
unfunction _nyx_ssh_tmux 2>/dev/null
