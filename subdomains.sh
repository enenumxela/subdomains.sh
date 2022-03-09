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

# passive
run_persive=True
passive_sources=(
	amass
	findomain
	subfinder
	sigsubfind3r
)
passive_sources_to_use=False
passive_sources_to_exclude=False
# semi_active
run_semi_active=True
# semi_active: dictionary
run_dictionary=True
# semi_active: permutation
run_permutation=True
# semi_active: reverseDNS
run_reverseDNS=True
# active

_output="./.subdomains.txt"
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
	\rUSAGE:
	\r  ${script_filename} [OPTIONS]

	\rOPTIONS:
	\r  -d,  --domain \t\t\t domain to gather subdomains for
	\r       --use-passive-source\t\t comma(,) separated tools to use
	\r       --exclude-passive-source \t comma(,) separated tools to exclude
	\r       --skip-semi-active \t\t skip semi active techniques
	\r       --skip-dictionary \t\t skip dictionary brute forcing
	\r       --skip-permutation \t\t skip permutations brute forcing
	\r  -o,  --output \t\t\t output text file
	\r       --setup\t\t\t\t setup requirements for this script
	\r  -h,  --help \t\t\t\t display this help message and exit

	\r ${red}${bold}HAPPY HACKING ${yellow}:)${reset}

EOF
}

DOWNLOAD_CMD=

if command -v >&- curl
then
	DOWNLOAD_CMD="curl --silent"
elif command -v >&- wget
then
	DOWNLOAD_CMD="wget --quiet --show-progres --continue --output-document=-"
else
	echo "${blue}[${red}-${blue}]${reset} Could not find wget/cURL" >&2
	exit 1
fi

while [[ "${#}" -gt 0 && ."${1}" == .-* ]]
do
	case ${1} in
		-d | --domain)
			domain=${2}
			shift
		;;
		--use-passive-source)
			passive_sources_to_use=${2}
			passive_sources_to_use_dictionary=${passive_sources_to_use//,/ }

			for i in ${passive_sources_to_use_dictionary}
			do
				if [[ ! " ${passive_sources[@]} " =~ " ${i} " ]]
				then
					echo -e "${blue}[${red}-${blue}]${reset} Unknown Task: ${i}"
					exit 1
				fi
			done

			shift
		;;
		--exclude-passive-source)
			passive_sources_to_exclude=${2}
			passive_sources_to_exclude_dictionary=${passive_sources_to_exclude//,/ }

			for i in ${passive_sources_to_exclude_dictionary}
			do
				if [[ ! " ${passive_sources[@]} " =~ " ${i} " ]]
				then
					echo -e "${blue}[${red}-${blue}]${reset} Unknown Task: ${i}"
					exit 1
				fi
			done

			shift
		;;
		--skip-semi-active)
			run_semi_active=False
		;;
		--skip-dictionary)
			run_dictionary=False
		;;
		--skip-permutation)
			run_permutation=False
		;;
		-o | --output)
			_output="$(dirname ${2})/.${2##*/}"
			output="${2}"
			shift
		;;
		--setup)
			eval ${DOWNLOAD_CMD} https://raw.githubusercontent.com/enenumxela/subdomains.sh/main/install.sh | bash -
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

display_banner

if [ "${SUDO_USER:-$USER}" != "${USER}" ]
then
	echo -e "\n${blue}[${red}-${blue}]${reset} failed!...subdomains.sh called with sudo!\n"
	exit 1
fi

if [[ ${domain} == False ]] || [[ ${domain} == "" ]]
then
	echo -e "\n${blue}[${red}-${blue}]${reset} failed!...Missing -d/--domain argument!\n"
	exit 1
fi

directory="$(dirname ${output})"

if [ ! -d ${directory} ]
then
	mkdir -p ${directory}
fi

# Run passive discovery
_amass() {
	amass enum -passive -d ${domain} | anew ${_output}
}

_subfinder() {
	subfinder -d ${domain} -all -silent | anew ${_output}
}

_findomain() {
	findomain -t ${domain} --quiet | anew ${_output}
}

_sigsubfind3r() {
	sigsubfind3r -d ${domain} --silent | anew ${_output}
}

if [ ${run_persive} == True ]
then
	if [ ${passive_sources_to_use} == False ] && [ ${passive_sources_to_exclude} == False ]
	then
		for source in "${passive_sources[@]}"
		do
			_${source}
		done
	else
		if [ ${passive_sources_to_use} != False ]
		then
			for source in "${passive_sources_to_use_dictionary[@]}"
			do
				_${source}
			done
		fi

		if [ ${passive_sources_to_exclude} != False ]
		then
			for source in ${passive_sources[@]}
			do
				if [[ " ${passive_sources_to_exclude_dictionary[@]} " =~ " ${source} " ]]
				then
					continue
				else
					_${source}
				fi
			done
		fi
	fi
fi

# Run semi active discovery
if [ ${run_semi_active} == True ]
then
	if [ ${run_permutation} == True ]
	then
		cat ${_output} | dnsgen - | dnsx -t 500 -silent | anew ${_output}
	fi

	if [ ${run_reverseDNS} == True ]
	then
		cat ${_output} | uniq | dnsx -a -resp-only -t 500 -silent | hakrevdns --domain --threads=20 | grep -Po "^[^-*\"]*?\K[[:alnum:]-]+\.${domain}" | anew ${_output}
	fi
fi

# Filter out live subdomains from temporary output into output
cat ${_output} | dnsx -t 500 -silent | anew -q ${output}

# Remove temporary output
rm -rf ${_output}

exit 0