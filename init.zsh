# Code from https://gist.github.com/subnut/3af65306fbecd35fe2dda81f59acf2b2

[[ -c /dev/null ]]  ||  return
zmodload zsh/system ||  return

TRANSIENT_PROMPT='> '

function set_prompt {
    PROMPT=$PS1
    RPROMPT=$RPS1
}

zle -N send-break _transient_prompt_widget-send-break
function _transient_prompt_widget-send-break {
    _transient_prompt_widget-zle-line-finish
    zle .send-break
}

zle -N zle-line-finish _transient_prompt_widget-zle-line-finish
function _transient_prompt_widget-zle-line-finish {
    (( ! _transient_prompt_fd )) && {
        sysopen -r -o cloexec -u _transient_prompt_fd /dev/null
        zle -F $_transient_prompt_fd _transient_prompt_restore_prompt
    }
    zle && PROMPT=$TRANSIENT_PROMPT RPROMPT= zle reset-prompt && zle -R
}

function _transient_prompt_restore_prompt {
    exec {1}>&-
    (( ${+1} )) && zle -F $1
    _transient_prompt_fd=0
    set_prompt
    zle reset-prompt
    zle -R
}

(( ${+precmd_functions} )) || typeset -ga precmd_functions
(( ${#precmd_functions} )) || {
    do_nothing() {true}
    precmd_functions=(do_nothing)
}

precmd_functions+=_transient_prompt_precmd
function _transient_prompt_precmd {
    TRAPINT() { zle && _transient_prompt_widget-zle-line-finish; return $(( 128 + $1 )) }
}

# vim: sw=0 ts=4 sts=4 et