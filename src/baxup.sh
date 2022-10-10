#!/bin/bash

# SECTION VARIABLES
# More about cli coloring: LINK https://stackoverflow.com/a/28938235
colorRed='\033[1;91m'
colorYellow='\033[1;93m'
colorGreen='\033[1;92m'
colorCyan='\033[1;96m'
# colorWhite='\033[1;97m\033[40m' # with dark background
colorReset='\033[0m'

msgHelp="Usage: baxup [OPTIONS]
Backups files specified in backup-dir.txt
  [NI] => Not Implemented
  [NI] -d, --debug                do not copy files, work with empty folder
  -r, --root                      ignore the required sudo permisson ${colorRed}-Dangerous-${colorReset}
  -k, --keep                      keep unarchived folder
  -c, --create                    create a new compressed backup archive
  [NI] -s, --setup=PATH           extract target archive and move to root for merge
  [NI] --lock                     lock current state of Home directory
  [NI] --restore                  restore previous state of Home directory
  -v, --verbose                   verbosely list files processed and logs
  [NI] -l, --log                  output logs   
  -h, --help                      display this help message

  [NI] --show                     shows current configurations
  [NI] --startup=USERNAME         special commands for startup
                                  (checks frequenciese and automatically creates backup)
  [NI] --set-path=PATH            set path for baxups
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
boolLock=0
boolRestore=0

varFrequency=0
varUser=$([ -n "$SUDO_USER" ] && echo "$SUDO_USER" || echo "$USER")

pathBaxups="/home/${varUser}/baxups/"
pathHistory="/home/${varUser}/baxups/history.log"
pathTargets="/home/${varUser}/baxups/targets.txt"
pathSetup=""

dateCur=$(date '+%Y-%m-%d_%H-%M')

#-!SECTION VARIABLES

# SECTION FUNCTIONS

# 0(only verbose)-1 | 0-1(Info)-2(Warning)-3(Error) | text
_log() {
  if [[ $boolVerbose == 1 || $1 == 1 ]]; then
    if [[ $# -gt 3 && $3 == "_date_" ]]; then
      printf "%s" "$(date '+%Y-%m-%d %H:%M | ')"
      set -- "$1" "$2" "$4"
    fi

    if [[ $2 == 0 ]]; then
      printf '%b' "$colorReset"
      for ((i = 3; i <= "$#"; i++)); do
        printf '%b' "${!i}"
        sleep 0.1
      done
      printf '%b' "$colorReset\n"
    elif [[ $2 == 1 ]]; then
      printf '%b%s%b' "$colorCyan" "Info:" "$colorReset $3 $colorReset\n"
    elif [[ $2 == 2 ]]; then
      printf '%b%s%b' "$colorYellow" "Warning:" "$colorReset $3 $colorReset\n"
    elif [[ $2 == 3 ]]; then
      printf '%b%s%b' "$colorRed" "Error:" "$colorReset $3 $colorReset\n"
    fi
  fi
}

# log to history.log
_log_history() {
  printf '%b' "$(date '+%Y-%m-%d %H:%M:%S') | $1\n" >>"$pathHistory"
}

# abort from script
_abort() {
  sleep 0.5
  _log 1 0 "${colorRed}Aborting" "." "." "."
  sleep 0.5
  exit
}

# show help message
_help() {
  _log 1 0 "${msgHelp}"
}

# check arguments
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
      elif [[ $tmpVar == "--help" || $tmpVar == "-h" ]]; then
        boolHelp=1
      elif [[ $tmpVar == "--startup="* ]]; then
        boolStartup=1
        varUser=${tmpVar#*=}
      elif [[ $tmpVar == "--lock" ]]; then
        boolLock=1
      elif [[ $tmpVar == "--restore" ]]; then
        boolRestore=1
      else
        _log 1 2 "There is no command named $tmpVar or $tmpVar do not have enough argument"
        _abort
      fi
    done
  fi
}

# check user home folder
_check_user() {
  _log "1" "0" "Is your 'home folder' name ${colorCyan}${varUser}${colorReset} ?"
  read -rp "(Y/N) " input
  if [[ $input == [yY] ]]; then
    _log "0" "1" "Proceeding with default home folder name: ${colorCyan}${varUser}"
  else
    _log "0" "2" "Home folder name is different (reported by user)"
    read -rp "Enter your home folder name (case sensitive): " input
    varUser=$input
    _log "1" "1" "Proceeding with user which entered manually: ${colorCyan}$varUser"
    pathBaxups="/home/${varUser}/baxups/"
    pathHistory="/home/${varUser}/baxups/history.log"
    pathTargets="/home/${varUser}/baxups/targets.txt"
  fi
}

# check "baxups" folder if exist, if not create folder and related files
_check_folder() {
  [[ -d $pathBaxups ]] || {
    _log 0 2 "There is no $pathBaxups folder"
    _log 0 1 "Creating $pathBaxups folder"
    mkdir "$pathBaxups"
    _log_history "Created Automatically because of originial baxup folder couldn't found\n"
    printf '%b' "# Write your targets below to backup\n#         Path                                                           Type                    Frequency\n# 1      /example-path/                                                   0                         1" >"$pathTargets"
    sleep 1
  }

  [[ -f $pathHistory ]] || {
    _log_history "Created Automatically because of originial baxup folder couldn't found\n\n\n"
  }

  [[ -f $pathTargets ]] || {
    printf '%b' "# Write your targets below to backup\n#         Path                                                           Type                    Frequency\n# 1      /example-path/                                                   0                         1" >"$pathTargets"
  }

  chown -R "$varUser":"$varUser" "$pathBaxups"
  chown "$varUser":"$varUser" "$pathHistory"
  chown "$varUser":"$varUser" "$pathTargets"
}

_create() {
  pathCur="$pathBaxups$dateCur"
  processNum=0

  mkdir "$pathCur"
  _log_history "Creation Process Started"
  _log_history "Created Folder $dateCur"
  _log 0 1 "Created Folder $dateCur"
  printf '%b'"Backup Created at $dateCur\nSee log for more info: $pathHistory\n" >"$pathBaxups/$dateCur/info.txt"
  _log 0 1 "Created File info.txt in backup $dateCur"
  _log_history "Created File info.txt in backup $dateCur"

  _log 1 0 "Starting Process:" " ${colorCyan}Copying Files"
  _log_history "Copied Files:"

  while read -r inputNum inputPath inputType inputFrequency; do
    if [[ -z $inputNum || $inputNum == "#" ]]; then
      continue
    fi
    sleep 0.2
    if [[ $inputType == "0" ]]; then
      cp -r "$inputPath" "$pathCur"
      _log 1 1 "Copied $inputPath"
      _log_history " - $inputPath (Frequency: $inputFrequency)"
    else
      _log_history "Skipped: $inputPath (will be merged)"
    fi

    ((processNum++))
  done <"$pathTargets"

  _log 1 0 "\nFinished Process: ${colorCyan}Copying ${processNum} Target(s)"
  sleep 1
  _log 1 1 "Archiving and Compressing Backup"

  cd "$pathBaxups" || { _abort; }
  if [[ $boolVerbose == 1 ]]; then tar -cvzf "${dateCur}.tar.gz" "$dateCur"; else tar -czf "${dateCur}.tar.gz" "$dateCur"; fi

  _log_history "Archived and Compressed: $pathCur"

  if [[ $boolKeep == 0 ]]; then
    _log 1 1 "Removing Unarchived Folder"
    sleep 1
    rm -r "$pathCur"
  else
    _log 0 1 "Keeping Unarchived Folder"
    chown -R "$varUser":"$varUser" "$pathCur"
  fi

  chown "$varUser":"$varUser" "${pathCur}.tar.gz"

  _log 1 1 "Finished backup process"
  _log_history "Finished Backup Process\n\n"
}

#-!SECTION FUNCTIONS

# SECTION MAIN
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
  echo "$pathBaxups"
  echo "$boolLock"
  echo "$boolRestore"
elif [[ $boolCreate == 1 && $boolSetup == 1 ]]; then
  _log 1 2 "Do not use both create and setup commands"
  _abort
elif [[ $boolRoot == 0 && $EUID -gt 0 ]]; then
  _log 1 3 "Please run as Root(sudo)"
  _abort
elif [[ ($boolCreate == 1 || $boolSetup == 1) && $boolStartup == 0 ]]; then
  _check_user
  _check_folder
  if [[ $boolCreate == 1 ]]; then
    _create
    sleep 1
    _log 1 0 "Script Ended ${colorGreen}Successfully"
    sleep 1
    exit
  elif [[ $boolSetup == 1 ]]; then
    _log 1 2 "Setup Command Not Implemented Yet"
    _abort
  fi

fi

#-!SECTION MAIN
