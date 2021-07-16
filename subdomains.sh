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

keep=False
domain=False
resolve=False

sources=(
	amass
	subfinder
	findomain
	sigsubfind3r
)
sources_to_use=False
sources_to_exclude=False

output_directory="."

display_usage() {
	while read -r line
	do
		printf "%b\n" "${line}"
	done <<-EOF
	\r USAGE:
	\r   ${script_filename} [OPTIONS]

	\r OPTIONS:
	\r   -d,  --domain \t\t domain to enumerate subdomains for
	\r   -eS, --exclude-source \t comma(,) separated tools to exclude
	\r   -uS, --use-source\t\t comma(,) separated tools to use
	\r   -r,  --resolve \t\t resolved collected subdomains (massdns)
	\r   -oD, --output-dir \t\t output directory
	\r   -k,  --keep \t\t\t keep each tool's temp results
	\r        --setup\t\t\t setup requirements for this script
	\r   -h,  --help \t\t\t display this help message and exit

	\r ${red}${bold}HAPPY HACKING ${yellow}:)${reset}

EOF
}

_amass() {
	local amass_output="${output_directory}/${domain}-amass-subdomains.txt"

	printf "    [${blue}+${reset}] amass"
	printf "\r"
	${HOME}/go/bin/amass enum -passive -d ${domain} -o ${amass_output} &> /dev/null
	echo -e "    [${green}*${reset}] amass: $(wc -l < ${amass_output})"
}

_subfinder() {
	local subfinder_output="${output_directory}/${domain}-subfinder-subdomains.txt"

	printf "    [${blue}+${reset}] subfinder"
	printf "\r"
	${HOME}/go/bin/subfinder -d ${domain} -silent 1> ${subfinder_output} 2> /dev/null
	echo -e "    [${green}*${reset}] subfinder: $(wc -l < ${subfinder_output})"
}

_findomain() {
	local findomain_output="${output_directory}/${domain}-findomain-subdomains.txt"

	printf "    [${blue}+${reset}] findomain"
	printf "\r"
	${HOME}/.local/bin/findomain -t ${domain} -q 1> ${findomain_output} 2> /dev/null
	echo -e "    [${green}*${reset}] findomain: $(wc -l ${findomain_output} | awk '{print $1}' 2> /dev/null)"
}

_sigsubfind3r() {
	local sigsubfind3r_output="${output_directory}/${domain}-sigsubfind3r-subdomains.txt"

	printf "    [${blue}+${reset}] sigsubfind3r"
	printf "\r"
	${HOME}/go/bin/sigsubfind3r -d ${domain} -silent 1> ${sigsubfind3r_output} 2> /dev/null
	echo -e "    [${green}*${reset}] sigsubfind3r: $(wc -l < ${sigsubfind3r_output})"
}

# display banner
echo -e ${bold}${blue}"
            _         _                       _                 _     
  ___ _   _| |__   __| | ___  _ __ ___   __ _(_)_ __  ___   ___| |__  
 / __| | | | '_ \ / _\` |/ _ \| '_ \` _ \ / _\` | | '_ \/ __| / __| '_ \ 
 \__ \ |_| | |_) | (_| | (_) | | | | | | (_| | | | | \__  ${red}_${blue}\__ \ | | |
 |___/\__,_|_.__/ \__,_|\___/|_| |_| |_|\__,_|_|_| |_|___${red}(_)${blue}___/_| |_| ${yellow}v1.0.0${blue}
"${reset}

# parse options
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
		-r | --resolve)
			resolve=True
		;;
		-oD | --output-dir)
			output_directory="${2}"
			shift
		;;
		-k | --keep)
			keep=True
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

# ensure domain(s) input is provided
if [ ${domain} == False ] && [ ${domains_list} == False ]
then
	echo -e "${blue}[${red}-${blue}]${reset} failed! argument -d/--domain OR -dL/--list is Required!\n"
	exit 1
fi

if [ ! -d ${output_directory} ]
then
	mkdir -p ${output_directory}
fi

# Flow for a single domain
if [ ${domain} != False ]
then
	echo -e "[*] subdomain enumeration on ${domain}"

	subdomains="${output_directory}/${domain}-subdomains.txt"
	dns_records="${output_directory}/${domain}-subdomains-dns-records.txt"

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

	cat ${output_directory}/${domain}-*-subdomains.txt | \
		sed 's#*.# #g' | \
			${HOME}/go/bin/anew -q ${subdomains}

	echo -e "        [>] subdomains: $(wc -l < ${subdomains})"

	if [ ${keep} == False ]
	then
		rm ${output_directory}/${domain}-*-subdomains.txt
	fi

	if [ ${resolve} == True ]
	then
		printf "    [${blue}+${reset}] resolve"
		printf "\r"
		${HOME}/.local/bin/massdns -r ${HOME}/wordlists/resolvers.txt -q -t A -o F -w ${dns_records} ${subdomains}
		echo -e "    [${green}*${reset}] resolved:"
	fi
fi

exit 0