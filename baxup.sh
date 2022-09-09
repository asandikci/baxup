#!/bin/bash

# SECTION VARIABLES
# More about cli coloring: LINK https://stackoverflow.com/a/28938235
colorRed='\033[1;91m'
# colorYellow='\033[1;93m'
# colorGreen='\033[1;92m'
colorCyan='\033[1;96m'
# colorWhite='\033[1;97m\033[40m' # with dark background
colorReset='\033[0m'

msgHelp="Usage: baxup [OPTIONS]
Backups files specified in backup-dir.txt
  [NI] => Not Implemented
  -d, --debug                do not copy files, work with empty folder
  [NI] -r, --root                 ignore the required sudo permisson ${colorRed}-Dangerous-${colorReset}
  [NI] -k, --keep                 keep unarchived folder
  [NI] -c, --create               create a new compressed backup archive
  [NI] -s, --setup=PATH           extract target archive and move to root for merge
  -v, --verbose                   verbosely list files processed and logs
  [NI] -l, --log                  output logs
  [NI] -f, --frequency=NUMBER     set a frequency for baxup (1 time each NUMBER day)             
  -h, --help                      display this help message

  [NI] --startup                  special commands for startup
                                  (checks frequency and automatically creates backup)
  [NI] --dir-path=PATH            specify a path for backup-dir.txt
  [NI] --target-path=PATH         specify a path where backups will be stored
${colorCyan}Copyright 2022 © Aliberk Sandıkçı${colorReset}\n"
# msgExample='msg'

boolDebug=0
# boolRoot=0
# boolKeep=0
# boolCreate=0
boolVerbose=0
# boolLog=0
boolHelp=0
# boolStartup=0

# varFrequency=0
varUser=$([ -n "$SUDO_USER" ] && echo "$SUDO_USER" || echo "$USER")
pathDir="/home/${varUser}/backups/backup-dir.txt"
pathHistory="/home/${varUser}/backups/backup-history"
pathTarget="/home/${varUser}/backups/"
#-!SECTION VARIABLES

_help() {
  printf '%b' "${msgHelp}"
}

_check_args() {
  if [ $# == 0 ]; then
    boolHelp=1
  else
    for ((i = 1; i <= $#; i++)); do
      # look for more info: LINK https://unix.stackexchange.com/a/631737
      case "${!i}" in
      "--help" | "-h")
        boolHelp=1
        ;;
      "--verbose" | "-v")
        boolVerbose=1
        ;;
      "--debug" | "-d")
        boolDebug=1
        ;;
      esac
    done
  fi

}

_check_args "$@"

if [ $boolHelp == 1 ]; then
  _help
  exit
elif [ $boolDebug == 1 ]; then
  echo "$varUser"

fi
