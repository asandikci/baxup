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
  -r, --root                      ignore the required sudo permisson ${colorRed}-Dangerous-${colorReset}
  -k, --keep                      keep unarchived folder
  -c, --create                    create a new compressed backup archive
  -s, --setup=PATH                extract target archive and move to root for merge
  -v, --verbose                   verbosely list files processed and logs
  -l, --log                       output logs
  -f, --frequency=NUMBER          set a frequency for baxup (1 time each NUMBER day)             
  -h, --help                      display this help message

  --startup                       special commands for startup
                                  (checks frequency and automatically creates backup)
  [NI] --dir-path=PATH            specify a path for backup-dir.txt
  [NI] --target-path=PATH         specify a path where backups will be stored
${colorCyan}Copyright 2022 © Aliberk Sandıkçı${colorReset}\n"
# msgExample='msg'

boolDebug=0
boolRoot=0
boolKeep=0
boolCreate=0
boolSetup=0
boolVerbose=0
boolLog=0
boolFrequency=0
boolHelp=0
boolStartup=0

varFrequency=0
varUser=$([ -n "$SUDO_USER" ] && echo "$SUDO_USER" || echo "$USER")

pathDir="/home/${varUser}/backups/backup-dir.txt"
pathHistory="/home/${varUser}/backups/backup-history"
pathTarget="/home/${varUser}/backups/"
pathSetup=""
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
      tmpVar="${!i}"

      if [[ $tmpVar == "--debug" || $tmpVar == "-d" ]]; then
        boolDebug=1
      elif [[ $tmpVar == "--root" || $tmpVar == "-r" ]]; then
        boolRoot=1
      elif [[ $tmpVar == "--keep" || $tmpVar == "-k" ]]; then
        boolKeep=1
      elif [[ $tmpVar == "--create" || $tmpVar == "-c" ]]; then
        boolCreate=1
      elif [[ $tmpVar == "--setup="* || $tmpVar == "-s="* ]]; then
        boolSetup=1
        pathSetup=${tmpVar#*=}
      elif [[ $tmpVar == "--verbose" || $tmpVar == "-v" ]]; then
        boolVerbose=1
      elif [[ $tmpVar == "--log" || $tmpVar == "-l" ]]; then
        boolLog=1
      elif [[ $tmpVar == "--frequency="* || $tmpVar == "-f="* ]]; then
        boolFrequency=1
        varFrequency=${tmpVar#*=}
      elif [[ $tmpVar == "--help" || $tmpVar == "-h" ]]; then
        boolHelp=1
      elif [[ $tmpVar == "--startup" ]]; then
        boolStartup=1
      else
        printf '%b%s%b%s%b' "$colorRed" "Error: " "$colorReset" "There is no command named $tmpVar or $tmpVar do not have enough argument" "\n"
        sleep 0.1
        printf '%b%s%b' "$colorRed" "Aborting..." "$colorReset\n"
        exit
      fi

    done

  fi

}

_check_args "$@"

if [[ $boolHelp == 1 ]]; then
  _help
  exit
elif [[ $boolDebug == 1 ]]; then
  echo "-Temporary Debug Scripts-"
  echo -e "Variables Currently not in usage:\n"
  echo "$boolRoot"
  echo "$boolKeep"
  echo "$pathSetup"
  echo "$boolVerbose"
  echo "$boolLog"
  echo "$boolFrequency"
  echo "$varFrequency"
  echo "$boolStartup"
  echo "$pathDir"
  echo "$pathHistory"
  echo "$pathTarget"
elif [[ $boolCreate == 1 && $boolSetup == 1 ]]; then
  printf '%b%s%b%s%b' "$colorRed" "Warning: " "$colorReset" "Do not use both create and setup commands" "\n"
fi
