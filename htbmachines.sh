#!/bin/bash

#### colors ####
greenColor="\e[0;32m\033[1m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"
endColor="\033[0m\e[0m"

function ctrl_c(){
	echo -e "\n\n${redColor}[!] Exiting...$endColor"
    tput cnorm
	exit 1
}

#### ctrl+c catcher ####
trap ctrl_c INT

#### help panel ####
function helpPanel(){
  echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Usage:${endColor}"
  echo -e "\n${yellowColor}[+]${endColor} ./htbmachines.sh [arg]\n"
  echo -e "\n${yellowColor}[+]${endColor} ${redColor}-u)${endColor} ${grayColor}Get or update machines data${endColor}"
  echo -e "\n${yellowColor}[+]${endColor} ${redColor}-m)${endColor} ${grayColor}Search machine info${endColor}"
  echo -e "\n${yellowColor}[+]${endColor} ${redColor}-i)${endColor} ${grayColor}Search machine by IP address${endColor}"
  echo -e "\n${yellowColor}[+]${endColor} ${redColor}-y)${endColor} ${grayColor}Search YouTube link from a machine name${endColor}"
  echo -e "\n${yellowColor}[+]${endColor} ${redColor}-d)${endColor} ${grayColor}Search machines by level of difficulty [Fácil, Media, Difícil, Insane]${endColor}"
  echo -e "\n${yellowColor}[+]${endColor} ${redColor}-s)${endColor} ${grayColor}Search machines by skill${endColor}"
  echo -e "\n${yellowColor}[+]${endColor} ${redColor}-h)${endColor} ${grayColor}Show help info${endColor}"
  echo -e "\n"
}

#### get bundle file ####
function getData(){
  tput civis

  if [ ! -f "bundle.js" ];  then
    echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Getting the data"${endColor}
    curl -s https://htbmachines.github.io/bundle.js > bundle.js
    js-beautify bundle.js > bundle2.js
    rm bundle.js
    mv bundle2.js bundle.js
  else
    echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Checking for updates${endColor}"
    curl -s https://htbmachines.github.io/bundle.js > bundle_tmp.js
    js-beautify bundle_tmp.js > tmp.js 
    rm bundle_tmp.js
    md5_tmp_bundle="$(md5sum tmp.js | awk '{print $1}')"
    md5_original_bundle="$(md5sum bundle.js | awk '{print $1}')"

    if [ $md5_tmp_bundle == $md5_original_bundle ]; then
      echo -e "\n${yelloColor}[+]${endColor} ${grayColor} Everything is up to date${endColor}"
      rm tmp.js
    else
      echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Updating the file${endColor}"
      sleep 1
      rm bundle.js
      mv tmp.js bundle.js
      echo -e "\n${yellowColor}[+]${endColor} ${grayColor}File updated${endColor}"
    fi
  fi
  tput cnorm
}

#### search machine by name ####
function searchMachine(){

  machineName="$1"
  machine=$(cat bundle.js | grep "name: \"${machineName}\"" -A 10 | grep -vE "sku|resuelta|id|}|lf" | tr -d '"' | tr -d ',' | sed 's/^ *//')

  if [ "$machine" ]; then
    echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Listing machine properties${endColor}\n"
    echo "${machine}"
    echo -e "\n"
  else
    echo -e "\n${redColor}[!] Machine not found${endColor}\n"
  fi
}

#### serch machine by IP and show the its name
function searchByIP(){
  echo -e "\n"
  ip=$(cat bundle.js | grep "ip: \"${ipAdress}\"" -B 3 | grep -vE "id|sku|ip" | tr -d '"' | tr -d ',' | sed 's/^ *//')

  if [ "$ip" ]; then
    echo -e "\n${ip}\n"
  else
    echo -e "\n${redColor}[!] Machine not found${endColor}\n"
  fi
}

#### search Youtube link from a machine name ####
function searchYoutubeLink(){
  echo -e "\n"
  youtube_link=$(cat bundle.js | grep "name: \"${machineName}\"" -A 10 | grep "youtube:" | tr -d '"' | tr -d ',' | sed 's/^ *//')

  if [ "$youtube_link" ]; then
   echo -e "\n${yellowColor}[+]${endColor}${grayColor} This is the YouTube link for the${endColor} ${blueColor}${machineName}${endColor} ${grayColor}machine:${endColor} ${purpleColor}${youtube_link}${endColor}"
  else
    echo -e "\n${redColor}[!] The machine was not found${endColor}"
  fi
  echo -e "\n"
}

function searchByDifficulty(){
  difficulty_level="$(cat bundle.js | grep "dificultad: \"${difficulty}\"" -B 5 | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep 'name' | awk 'NF{print $NF}')"

  if [ "$difficulty_level" ]; then
    echo "$difficulty_level" | column
  else
    echo -e "\n${redColor}[!] The difficulty level was not found${endColor}\n"
  fi
}

function searchByOS(){
  os="$1"
  echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Searching by OS:${endColor} ${purpleColor}$os${endColor}\n"

  os="$(cat bundle.js | grep "so: \"${os}" -B 5 | tr -d '"' | tr -d ',' | grep "name:" | sed 's/^ *//' | awk 'NF{print $NF}')"

  if [ "$os" ]; then
    echo "${os}" | column
  else
    echo -e "\n${redColor}[!] Wrong OS introduced${endColor}\n"
  fi
}

function searchByDifficultyAndOS() {
  difficulty="$1"
  os="$2"

  echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Searching for machines with difficulty${endColor} ${purpleColor}$difficulty${endColor} ${grayColor}and OS${endColor} ${purpleColor}$os${endColor}\n"

  filter_result="$(cat bundle.js | grep "dificultad: \"${difficulty}" -C 5 | grep "so: \"${os}" -B 4 | grep "name:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk 'NF{print $NF}' | column)"

  if [ "$filter_result" ]; then
    echo "$filter_result" | column
  else
    echo -e "\n${redColor}[!] Data not found${endColor}\n"
  fi
}

function searchBySkill() {
  skill="$1"
  echo $skill

  skill_result="$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk 'NF{print $NF}')"

  if [ "$skill_result" ]; then
    echo "$skill_result" | column
  else
    echo -e "\n${redColor}[!] Machines with this skill not found${endColor}\n"
  fi
}

declare -i parameter_counter=0
declare -i flag_difficulty=0
declare -i flag_os=0

#### menu ####
while getopts "m:i:y:d:o:s:hu" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAdress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; flag_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; flag_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  getData
elif [ $parameter_counter -eq 3 ]; then
  searchByIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
  searchYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchByDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  searchByOS $os
elif [ $flag_os -eq 1 ] && [ $flag_difficulty -eq 1 ]; then
  searchByDifficultyAndOS $difficulty $os
elif [ $parameter_counter -eq 7 ]; then
  searchBySkill "$skill"
else
  helpPanel
fi

