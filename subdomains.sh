#!/usr/bin/env bash

red="\e[31m"
cyan="\e[36m"
blue="\e[34m"
green="\e[32m"
yellow="\e[33m"

bold="\e[1m"
underline="\e[4m"

reset="\e[0m"

domain=False

resolvers=False
dictionary_wordlist=False
permutation_wordlist=False

run_persive=True
passive_sources=(
	amass
	findomain
	subfinder
	sigsubfind3r
)
passive_sources_to_use=False
passive_sources_to_exclude=False

run_semi_active=True
run_dictionary=True
run_permutation=True
run_DNSrecords=True
run_reverseDNS=True

output="./subdomains.txt"
_output=".${output##*/}"

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
	\r  ${0##*/} [OPTIONS]

	\rOPTIONS:
	\r   -d, --domain \t\t\t domain to gather subdomains for ${underline}${cyan}*${reset}
	\r       --use-passive-source\t\t comma(,) separated tools to use
	\r       --exclude-passive-source \t comma(,) separated tools to exclude
	\r       --skip-semi-active \t\t skip semi active techniques
	\r   -r, --resolvers \t\t\t list of DNS resolvers ${underline}${cyan}*${reset}
	\r       --skip-dictionary \t\t skip dictionary brute forcing
	\r  -dW, --dictionary-wordlist \t\t wordlist for dictionary brute forcing
	\r       --skip-permutation \t\t skip permutation brute forcing
	\r  -pW, --permutation-wordlist \t\t wordlist for permutation brute forcing
	\r       --skip-dns-records \t\t skip discovery from DNS records
	\r       --skip-reverse-dns \t\t skip discovery from reverse DNS lookup
	\r   -o, --output \t\t\t output text file
	\r       --setup\t\t\t\t install/update this script & dependencies
	\r   -h, --help \t\t\t\t display this help message and exit

	\rNOTE: options marked with asterik(${underline}${cyan}*${reset}) are required.

	\r${red}${bold}HAPPY HACKING ${yellow}:)${reset}

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
		-r | --resolvers)
			resolvers=${2}
			shift
		;;
		--skip-dictionary)
			run_dictionary=False
		;;
		-dW | --dictionary-wordlist)
			dictionary_wordlist=${2}
			shift
		;;
		--skip-permutation)
			run_permutation=False
		;;
		-pW | --permutation-wordlist)
			permutation_wordlist=${2}
			shift
		;;
		--skip-dns-records)
			run_DNSrecords=False
		;;
		--skip-reverse-dns)
			run_reverseDNS=False
		;;
		-o | --output)
			output="${2}"
			_output="$(dirname ${output})/.${output##*/}"
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

if [[ ${resolvers} == False ]] || [[ ${resolvers} == "" ]]
then
	echo -e "\n${blue}[${red}-${blue}]${reset} failed!...Missing -r/--resolvers argument!\n"
	exit 1
fi

if [ ! -d $(dirname ${output}) ]
then
	mkdir -p $(dirname ${output})
fi

display_banner

# passive discovery
_amass() {
	amass enum -passive -d ${domain} | tee -a ${_output}
}

_subfinder() {
	subfinder -d ${domain} -all -silent | tee -a ${_output}
}

_findomain() {
	findomain -t ${domain} --quiet | tee -a ${_output}
}

_sigsubfind3r() {
	sigsubfind3r -d ${domain} --silent | tee -a ${_output}
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

# semi active discovery: dictionary bruteforcing
if [ ${run_semi_active} == True ] && [ ${run_dictionary} == True ] && [ ${dictionary_wordlist} != False ]
then
	puredns bruteforce ${dictionary_wordlist} ${domain} --resolvers ${resolvers} --quiet | tee -a ${_output}
fi

# semi active discovery: permutations bruteforcing
if [ ${run_semi_active} == True ] && [ ${run_permutation} == True ]
then
	if [ ${permutation_wordlist} != False ]
	then
		cat ${_output} | sort -u | dnsgen -w ${permutation_wordlist} - | puredns resolve --resolvers ${resolvers} --quiet | tee -a ${_output}
	else
		cat ${_output} | sort -u | dnsgen - | puredns resolve --resolvers ${resolvers} --quiet | tee -a ${_output}
	fi
fi

# Filter out live subdomains from temporary output into output
cat ${_output} | puredns resolve --resolvers ${resolvers} --write-massdns /tmp/.massdns --quiet | anew -q ${output}

# semi active discovery: DNS records
if [ ${run_semi_active} == True ] && [ ${run_DNSrecords} == True ] && [ -f /tmp/.massdns ]
then
	cat /tmp/.massdns | grep -Po "^[^-*\"]*?\K[[:alnum:]-]+\.${domain}" | tee -a ${output}
fi

# semi active discovery: reverse DNS lookup
if [ ${run_semi_active} == True ] && [ ${run_reverseDNS} == True ] && [ -f /tmp/.massdns ]
then
	cat /tmp/.massdns | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u | hakrevdns --domain --threads=100 | grep -Po "^[^-*\"]*?\K[[:alnum:]-]+\.${domain}" | tee -a ${output}
fi

# Remove temporary output
rm -rf ${_output} /tmp/.massdns

exit 0