#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH="$HOME/.local/bin:$PATH"



# eDEX-UI: Fastfetch только в первом терминале MAIN
if [[ $- == *i* ]] && command -v fastfetch >/dev/null 2>&1; then
    edex_tree="$(
        ps -o comm= -p $$,$PPID 2>/dev/null
        pstree -s $$ 2>/dev/null
    )"

    if grep -Eqi 'edex-ui|edex_ui|electron' <<< "$edex_tree"; then
        edex_pid="$(
            pgrep -n -f 'edex-ui|edex_ui' 2>/dev/null \
                || printf '%s' "$PPID"
        )"

        marker="/tmp/edex-main-fastfetch-${UID}-${edex_pid}"

        # Первый Bash в текущем запуске eDEX-UI считаем MAIN.
        if (
            set -o noclobber
            printf '%s\n' "$$" > "$marker"
        ) 2>/dev/null; then
            (
                sleep 2
                printf '\033[2J\033[H'
                fastfetch
                printf '\n'
            ) >/dev/tty 2>/dev/null &
        fi
    fi
fi
