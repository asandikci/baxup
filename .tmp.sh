#!/bin/bash
_old_code() {

  #sleep 1
  echo "Backup script started with user id \"$EUID\""

  #VARIABLES-START----------

  PATH_backup_dir_txt="/home"
  PATH_backup_dir="/home/"
  PATH_backup_cur=""

  VAR_dir_num=0

  DATE_cur=$(date '+%d-%m-%Y_%H-%M')
  #VARIABLES-END------------

  #sleep 3
  echo "There isn't any problem with constant variables"
  #sleep 1
  echo -e "\n"

  if [[ $# == 0 || ! ($1 == "-nc") ]]; then
    if [ $EUID -gt 0 ]; then
      echo -e "Please run as ${COLOR_red}ROOT ${COLOR_nc}!!!"
      sleep 0.1
      echo -e "\n ${COLOR_red}Aborting..."
      sleep 1
      exit
    fi
  else
    echo "no root check"
    sleep 0.1
    echo -e "in progress...\n"
  fi

  echo -e "${COLOR_red}WARNING!!!${COLOR_nc} Your Username must be \"admin\" !!!"
  echo -e "Current Username: ${COLOR_cyan} ${SUDO_USER} ${COLOR_nc}"
  echo -e "Current Executer name: ${COLOR_cyan} ${USER} ${COLOR_nc}"

  [[ -z $SUDO_USER || ${SUDO_USER} == "admin" ]] || {
    echo -e "${COLOR_red}ERROR !!!${COLOR_nc} Requires Manuel DEBUG. id=\"${COLOR_cyan}sudo-user-is-not-user-32764d${COLOR_nc}\""
    exit
  }

  if [[ -z $SUDO_USER ]]; then
    USER_cur=$USER
  else
    USER_cur=$SUDO_USER
  fi

  echo -e "Continuing as ${COLOR_cyan} ${USER_cur} ${COLOR_nc} home user"
  PATH_backup_dir="/home/$USER_cur/backups/"

  echo -e "Backup Target:${COLOR_cyan} $PATH_backup_dir ${COLOR_nc}"
  sleep 3

  [ -f "$PATH_backup_dir_txt" ] ||
    {
      echo -e "${COLOR_red}Error:${COLOR_cyan} ${PATH_backup_dir_txt} ${COLOR_nc} is not exists !!! Check File !!!"
      sleep 0.1
      echo -e "\n ${COLOR_red}Aborting...${COLOR_nc}"
      sleep 1
      exit
    }

  [[ -d $PATH_backup_dir ]] ||
    {
      echo -e "${COLOR_red}Error:${COLOR_cyan} ${PATH_backup_dir} ${COLOR_nc} Folder is not exists !"
      sleep 0.1
      echo -e "\n ${COLOR_red}Creating Folder...${COLOR_nc}"
      sleep 1
      mkdir "$PATH_backup_dir"
      sleep 0.1
      echo -e "Directory Created in ${COLOR_cyan}${PATH_backup_dir}${COLOR_nc}"
      echo -e "Created Automatically because of original backup folder couldn't found !!!\nBackup script original path: /home/admin" >"$PATH_backup_dir/backup-history.txt"
      sleep 1
    }

  [ -f "$PATH_backup_dir/backup-history.txt" ] || {
    echo -e "Created Automatically because of original backup folder couldn't found !!!\nBackup script original path: /home/admin" >"$PATH_backup_dir/backup-history.txt"
    sleep 1
  }

  mkdir "$PATH_backup_dir/$DATE_cur"
  PATH_backup_cur="$PATH_backup_dir$DATE_cur"
  echo -e "created folder ${COLOR_cyan} ${DATE_cur} ${COLOR_nc} in ${COLOR_cyan} $PATH_backup_dir ${COLOR_nc}"
  echo " "

  printf "Started Backup process in ${DATE_cur}\n" >>"$PATH_backup_dir/backup-history.txt"

  printf " - Copied Files:\n" >>"$PATH_backup_dir/backup-history.txt"

  if [[ $# -lt 2 || ! ($2 == "-d") ]]; then
    while read INPUT_num INPUT_path INPUT_type INPUT_extra; do
      if [[ -z $INPUT_num || $INPUT_num == "#" ]]; then
        continue
      fi

      sleep 0.5

      if [ "$INPUT_type" == 0 ]; then ## TODO: merging files if type=1 and Other folder if extra=1 Look backup-dir.txt for more info !!!
        cp -r "$INPUT_path" "$PATH_backup_cur"
        ## TODO: Symbolic links? Hard links?
        echo -e "Copied: ${COLOR_cyan}$INPUT_path${COLOR_nc}"
        printf "  * $INPUT_path\n" >>"$PATH_backup_dir/backup-history.txt"
      fi

      ((VAR_dir_num++))
    done <"$PATH_backup_dir_txt"
  else
    echo -e "$COLOR_cyan SKIPPING $COLOR_nc copy section"
  fi
  echo -e "\nFinished Process: ${COLOR_cyan}Copying ${VAR_dir_num} Target${COLOR_nc}"
  sleep 1
  printf "Archiving and Compressing Backup"
  sleep 0.5
  printf "."
  sleep 0.5
  printf "."
  sleep 0.5
  printf ".\n"
  cd "$PATH_backup_dir" || exit
  tar -czf "$DATE_cur.tar.gz" "$DATE_cur"

  printf " - Archived and Compressed: ${PATH_backup_cur}\n" >>"$PATH_backup_dir/backup-history.txt"

  echo "Removing Unarchived Folder"
  sleep 0.2
  rm -r "$PATH_backup_cur"
  printf " - Removed Unarchived Folder\n" >>"$PATH_backup_dir/backup-history.txt"
  echo "Giving permission to $USER_cur"
  chown "$USER_cur":"$USER_cur" "$PATH_backup_cur.tar.gz"

  printf "Finished Backup Process\n\n\n" >>"$PATH_backup_dir/backup-history.txt"
  sleep 1
  echo -e "\n\nInfo: -script ended ${COLOR_cyan}SUCCESSFULLY${COLOR_nc}-"

}
