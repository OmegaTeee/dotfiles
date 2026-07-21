#!/bin/zsh
# ~/.zshrc
# Small entry point. Everything else lives under ~/.config/zsh.

zmodload zsh/datetime 2>/dev/null
typeset -gF ZSH_START_TIME="${EPOCHREALTIME:-0}"
typeset -ga ZSH_PATH_BEFORE=("${path[@]}")

# Powerlevel10k instant prompt must remain near the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -g ZSH_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
source "${ZSH_CONFIG_HOME}/init.zsh"

typeset -gF ZSH_STARTUP_MS=0
if (( ZSH_START_TIME > 0 )) && [[ -n ${EPOCHREALTIME:-} ]]; then
  ZSH_STARTUP_MS=$(( (EPOCHREALTIME - ZSH_START_TIME) * 1000 ))
fi
