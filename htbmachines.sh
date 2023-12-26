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
  echo -e "\n\n[+] Usage:"
  echo -e "\n${yellowColor}[+]${endColor} ./htbmachines.sh [arg]\n"
  echo -e "\n${yellowColor}[+]${endColor} -u) Get or update machines data"
  echo -e "\n${yellowColor}[+]${endColor} -m) Search machine info"
  echo -e "\n${yellowColor}[+]${endColor} -i) Search machine by IP address"
  echo -e "\n${yellowColor}[+]${endColor} -h) Show help info"
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

#### search machine ####
function searchMachine(){
  machineName="$1"
  echo -e "\n"
  cat bundle.js | grep "name: \"${machineName}\"" -A 10 | grep -vE "sku|resuelta|id" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  echo -e "\n"
}

#### serch machine by IP and show the its name
function searchByIP(){
  echo -e "\n"
  cat bundle.js | grep "ip: \"${ipAdress}\"" -B 3 | grep -vE "id|sku|ip" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  echo -e "\n"
}

declare -i parameter_counter=0

#### menu ####
while getopts "m:i:hu" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter=2;;
    i) ipAdress=$OPTARG; let parameter_counter=3;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  getData
elif [ $parameter_counter -eq 3 ]; then
  searchByIP $ipAdress
else
  helpPanel
fi

