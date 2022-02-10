#!/usr/bin/env bash

bold="\e[1m"
red="\e[31m"
cyan="\e[36m"
blue="\e[34m"
reset="\e[0m"
green="\e[32m"
yellow="\e[33m"
underline="\e[4m"
script_filename=${0##*/}

domain=False
live=False

sources=(
	amass
	findomain
	subfinder
	sigsubfind3r
)
sources_to_use=False
sources_to_exclude=False

output="./subdomains.txt"

display_banner() {
echo -e ${bold}${blue}"
            _         _                       _                 _     
  ___ _   _| |__   __| | ___  _ __ ___   __ _(_)_ __  ___   ___| |__  
 / __| | | | '_ \ / _\` |/ _ \| '_ \` _ \ / _\` | | '_ \/ __| / __| '_ \ 
 \__ \ |_| | |_) | (_| | (_) | | | | | | (_| | | | | \__  ${red}_${blue}\__ \ | | |
 |___/\__,_|_.__/ \__,_|\___/|_| |_| |_|\__,_|_|_| |_|___${red}(_)${blue}___/_| |_| ${yellow}v1.0.0${blue}
"${reset}
}

display_usage() {
	display_banner

	while read -r line
	do
		printf "%b\n" "${line}"
	done <<-EOF
	\r USAGE:
	\r   ${script_filename} [OPTIONS]

	\r OPTIONS:
	\r   -d,  --domain \t\t domain to gather subdomains for
	\r   -uS, --use-source\t\t comma(,) separated tools to use
	\r   -eS, --exclude-source \t comma(,) separated tools to exclude
	\r        --live \t\t\t output live subdomains only
	\r   -o,  --output \t\t output text file
	\r        --setup\t\t\t setup requirements for this script
	\r   -h,  --help \t\t\t display this help message and exit

	\r ${red}${bold}HAPPY HACKING ${yellow}:)${reset}

EOF
}

_amass() {
	if [ ${live} == True ]
	then
		amass enum -passive -d ${domain} | dnsx -silent | anew ${output}
	else
		amass enum -passive -d ${domain} | anew ${output}
	fi
}

_subfinder() {
	if [ ${live} == True ]
	then
		subfinder -d ${domain} -all -silent | dnsx -silent | anew ${output}
	else
		subfinder -d ${domain} -all -silent | anew ${output}
	fi
}

_findomain() {
	if [ ${live} == True ]
	then
		findomain -t ${domain} -q | dnsx -silent | anew ${output}
	else
		findomain -t ${domain} -q | anew ${output}
	fi
}

_sigsubfind3r() {
	if [ ${live} == True ]
	then
		sigsubfind3r -d ${domain} --silent | dnsx -silent | anew ${output}
	else
		sigsubfind3r -d ${domain} --silent | anew ${output}
	fi
}

while [[ "${#}" -gt 0 && ."${1}" == .-* ]]
do
	case ${1} in
		-d | --domain)
			domain=${2}
			shift
		;;
		-eS | --exclude-source)
			sources_to_exclude=${2}
			sources_to_exclude_dictionary=${sources_to_exclude//,/ }

			for i in ${sources_to_exclude_dictionary}
			do
				if [[ ! " ${sources[@]} " =~ " ${i} " ]]
				then
					echo -e "[-] Unknown Task: ${i}"
					exit 1
				fi
			done
			shift
		;;
		-uS | --use-source)
			sources_to_use=${2}
			sources_to_use_dictionary=${sources_to_use//,/ }

			for i in ${sources_to_use_dictionary}
			do
				if [[ ! " ${sources[@]} " =~ " ${i} " ]]
				then
					echo -e "[-] Unknown Task: ${i}"
					exit 1
				fi
			done
			shift
		;;
		--live)
			live=True
			shift
		;;
		-o | --output)
			output="${2}"
			shift
		;;
		--setup)
			curl -sL https://raw.githubusercontent.com/enenumxela/subdomains.sh/main/install.sh | bash -
			exit 0
		;;
		-h | --help)
			display_usage
			exit 0
		;;
		*)
			display_usage
			exit 1
		;;
	esac
	shift
done

[[ ${domain} != False ]] && [[ ${domain} != "" ]] && {
	directory="$(dirname ${output})"

	if [ ! -d ${directory} ]
	then
		mkdir -p ${directory}
	fi
	
	[ ${sources_to_use} == False ] && [ ${sources_to_exclude} == False ] && {
		for source in "${sources[@]}"
		do
			_${source}
		done
	} || {
		[ ${sources_to_use} != False ] && {
			for source in "${sources_to_use_dictionary[@]}"
			do
				_${source}
			done
		}
		[ ${sources_to_exclude} != False ] && {
			for source in ${sources[@]}
			do
				if [[ " ${sources_to_exclude_dictionary[@]} " =~ " ${source} " ]]
				then
					continue
				else
					_${source}
				fi
			done
		}
	}
}

exit 0