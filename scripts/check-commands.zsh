#!/bin/zsh
# Check that every command this config promises is present in the current
# shell. Source it from an interactive shell that loaded the config:
#
#   zsh -lic 'source scripts/check-commands.zsh'
#
# Expected names come from the installed config itself, so adding a function
# or alias needs no change here:
#   - every file in $ZDOTDIR/functions must resolve as a function and start
#     with "#autoload"
#   - every literal `alias name=...` line in core/, apps.d/ and plugins.d/
#     must have produced that alias
#   - the generated hr-<profile>-<action> aliases must exist for every
#     profile in HEADROOM_PROFILE_ALIASES
# An alias whose name is built from variables anywhere else fails the check,
# because this script can't know its expected name. Teach the script about it
# the way the Headroom aliases are handled below.

() {
  emulate -L zsh
  setopt extended_glob

  local cfg=${ZDOTDIR:?ZDOTDIR is not set}
  local -a missing functions_seen aliases_expected
  local file name line short action

  for file in $cfg/functions/*(N.); do
    name=${file:t}
    functions_seen+=($name)
    [[ $(whence -w -- $name) == "$name: function" ]] || missing+=("function $name (not autoloadable)")
    [[ $(head -n 1 -- $file) == '#autoload' ]] || missing+=("function $name (first line is not #autoload)")
  done

  for file in $cfg/{core,apps.d,plugins.d}/*.zsh(N); do
    for line in ${(f)"$(<$file)"}; do
      if [[ $line =~ '^[[:space:]]*alias[[:space:]]+([[:alnum:]_.:+-]+)=' ]]; then
        aliases_expected+=($match[1])
      elif [[ $line =~ '^[[:space:]]*alias[[:space:]]+["'\'']' && ${file:t} != 20-headroom.zsh ]]; then
        missing+=("alias with a computed name in ${file#$cfg/}: teach scripts/check-commands.zsh about it")
      fi
    done
  done

  for short in ${(k)HEADROOM_PROFILE_ALIASES}; do
    for action in start stop restart status health logs; do
      aliases_expected+=(hr-$short-$action)
    done
  done

  local -aU alias_names=($aliases_expected)
  for name in $alias_names; do
    (( ${+aliases[$name]} )) || missing+=("alias $name")
  done

  print -r -- "functions checked: ${#functions_seen}, aliases checked: ${#alias_names}"

  if (( ${#missing} )); then
    print -u2 -l -- "MISSING:" "  "${^missing}
    return 1
  fi
  print -r -- "all functions and aliases present"
}
