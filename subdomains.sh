#!/usr/bin/env bash

# Formatting
blue="\e[34m"
bold="\e[1m"
cyan="\e[36m"
green="\e[32m"
red="\e[31m"
reset="\e[0m"
yellow="\e[33m"
underline="\e[4m"

# Tareget root domain
domain=False

# Wordlists: resolvers, DNS dictionary & permutations
resolvers=False
dictionary_wordlist=False
permutation_wordlist=False

# Methodology
## Passive Discovery
run_passive_discovery=True

passive_tools=(
	amass
	crobat
	findomain
	subfinder
	sigsubfind3r
)
passive_tools_to_use=False
passive_tools_to_exclude=False

## Active Discovery
run_active_discovery=True
run_dictionary_bruteforce=True
run_permutation_bruteforce=True
run_DNSrecords=True
run_reverseDNS=True

# Output (Subddomains)
output=False
_output=

# Download command (curl or wget)
DOWNLOAD_CMD=

if command -v >&- curl
then
	DOWNLOAD_CMD="curl --silent"
elif command -v >&- wget
then
	DOWNLOAD_CMD="wget --quiet --show-progres --continue --output-document=-"
else
	echo "${bold}${blue}[${red}-${blue}]${reset} Could not find wget/cURL" >&2
	exit 1
fi

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
	\r   -d, --domain \t\t\t domain to discover subdomains for ${underline}${red}*${reset}
	\r   -r, --resolvers \t\t\t list of DNS resolvers containing file ${underline}${red}*${reset}
	\r       --skip-passive \t\t\t skip passive discovery discovery
	\r       --use-passive-tools \t\t comma(,) separated passive tools to use
	\r       --exclude-passive-tools \t\t comma(,) separated passive tools to exclude
	\r       --skip-active \t\t\t skip active discovery discovery
	\r       --skip-dictionary \t\t skip discovery from dictionary DNS brute forcing
	\r  -dW, --dictionary-wordlist \t\t wordlist for dictionary DNS  brute forcing
	\r       --skip-permutation \t\t skip discovery from permutation DNS brute forcing
	\r  -pW, --permutation-wordlist \t\t wordlist for permutation DNS brute forcing
	\r       --skip-dns-records \t\t skip discovery from DNS records
	\r       --skip-reverse-dns \t\t skip discovery from reverse DNS lookup
	\r   -o, --output \t\t\t output text file
	\r       --setup\t\t\t\t install/update this script & dependencies
	\r   -h, --help \t\t\t\t display this help message and exit

	\rNOTE: options marked with asterik(${underline}${red}*${reset}) are required.

	\r${red}${bold}HAPPY HACKING ${yellow}:)${reset}

EOF
}

# Process command line arguments
while [[ "${#}" -gt 0 && ."${1}" == .-* ]]
do
	case ${1} in
		-d | --domain)
			domain=${2}
			shift
		;;
		-r | --resolvers)
			resolvers=${2}
			shift
		;;
		--skip-passive)
			run_passive_discovery=False
		;;
		--use-passive-tools)
			passive_tools_to_use=${2}
			passive_tools_to_use_dictionary=${passive_tools_to_use//,/ }

			for i in ${passive_tools_to_use_dictionary}
			do
				if [[ ! " ${passive_tools[@]} " =~ " ${i} " ]]
				then
					echo -e "${bold}${blue}[${red}-${blue}]${reset} Unknown Task: ${i}"
					exit 1
				fi
			done

			shift
		;;
		--exclude-passive-tools)
			passive_tools_to_exclude=${2}
			passive_tools_to_exclude_dictionary=${passive_tools_to_exclude//,/ }

			for i in ${passive_tools_to_exclude_dictionary}
			do
				if [[ ! " ${passive_tools[@]} " =~ " ${i} " ]]
				then
					echo -e "${bold}${blue}[${red}-${blue}]${reset} Unknown Task: ${i}"
					exit 1
				fi
			done

			shift
		;;
		--skip-active)
			run_active_discovery=False
		;;
		--skip-dictionary)
			run_dictionary_bruteforce=False
		;;
		-dW | --dictionary-wordlist)
			dictionary_wordlist=${2}
			shift
		;;
		--skip-permutation)
			run_permutation_bruteforce=False
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
			shift
		;;
		--setup)
			eval ${DOWNLOAD_CMD} https://raw.githubusercontent.com/hueristiq/subdomains.sh/main/install.sh | bash -
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

# Ensure the script is not called with sudo
if [ "${SUDO_USER:-$USER}" != "${USER}" ]
then
	echo -e "\n${bold}${blue}[${red}-${blue}]${reset} failed!...subdomains.sh called with sudo!\n"
	exit 1
fi

# Ensure target root domain
if [[ ${domain} == False ]] || [[ ${domain} == "" ]]
then
	echo -e "\n${bold}${blue}[${red}-${blue}]${reset} failed!...Missing -d/--domain argument!\n"
	exit 1
fi

# Ensure resolvers
if [[ ${resolvers} == False ]] || [[ ${resolvers} == "" ]]
then
	# resolvers list file not provided
	echo -e "\n${bold}${blue}[${red}-${blue}]${reset} failed!...Missing -r/--resolvers argument!\n"
	exit 1
elif [ ! -f ${resolvers} ]
then
	# resolvers list file provided not found
	echo -e "\n${bold}${blue}[${red}-${blue}]${reset} failed!...Resolvers list file, \`${resolvers}\`, not found!\n"
	exit 1
elif [ ! -s ${resolvers} ]
then
	# resolvers list file provide found but empty
	echo -e "\n${bold}${blue}[${red}-${blue}]${reset} failed!...Resolvers list file, \`${resolvers}\`, is empty!\n"
	exit 1
fi

# Prepare output
if [ ${output} == False ]
then
	output="./subdomains.txt"
fi

_output="$(dirname ${output})/.${output##*/}"

if [ ! -d $(dirname ${output}) ]
then
	mkdir -p $(dirname ${output})
fi

# Diplay the banner
display_banner

# passive discovery
if [ ${run_passive_discovery} == True ]
then
	# passive discovery commands
	declare -A PDCs=(
		["amass"]="amass enum -passive -d ${domain} | anew ${_output}"
		["crobat"]="crobat -s ${domain} | anew ${_output}"
		["subfinder"]="subfinder -d ${domain} -all -silent | anew ${_output}"
		["findomain"]="findomain -t ${domain} --quiet | anew ${_output}"
		["sigsubfind3r"]="sigsubfind3r -d ${domain} --silent | anew ${_output}"
	)

	# determine passive commands to run
	PDCs_to_use=""

	if [ ${passive_tools_to_use} == False ] && [ ${passive_tools_to_exclude} == False ]
	then
		for tool in "${passive_tools[@]}"
		do
			PDC_to_use="${PDC_to_use}\n${PDCs[${tool}]}"
		done
	else
		if [ ${passive_tools_to_use} != False ]
		then
			for tool in "${passive_tools_to_use_dictionary[@]}"
			do
				PDC_to_use="${PDC_to_use}\n${PDCs[${tool}]}"
			done
		fi

		if [ ${passive_tools_to_exclude} != False ]
		then
			for tool in ${passive_tools[@]}
			do
				if [[ " ${passive_tools_to_exclude_dictionary[@]} " =~ " ${tool} " ]]
				then
					continue
				else
					PDC_to_use="${PDC_to_use}\n${PDCs[${tool}]}"
				fi
			done
		fi
	fi

	# run passive commands to use (in parallel)
	echo -e ${PDC_to_use} | rush '{}'
fi

# active discovery
if [ ${run_active_discovery} == True ]
then
	# DNS dictionary bruteforce
	if [ ${run_dictionary_bruteforce} == True ] && [ ${dictionary_wordlist} != False ]
	then
		puredns bruteforce ${dictionary_wordlist} ${domain} --resolvers ${resolvers} --quiet | anew ${_output}
	fi

	# permutations bruteforce
	if [ ${run_permutation_bruteforce} == True ]
	then
		if [ ${permutation_wordlist} != False ]
		then
			gotator -sub ${_output} -perm ${permutation_wordlist} -prefixes -depth 3 -numbers 10 -mindup -adv -silent | puredns resolve --resolvers ${resolvers} --quiet | anew ${_output}
		else
			gotator -sub ${_output} -prefixes -depth 3 -numbers 10 -mindup -adv -silent | puredns resolve --resolvers ${resolvers} --quiet | anew ${_output}
		fi
	fi
fi

# Filter out live subdomains from temporary output into output
if [ -f ${_output} ] && [ -s ${_output} ]
then
	cat ${_output} | puredns resolve --resolvers ${resolvers} --write-massdns /tmp/.massdns --quiet | anew -q ${output}

	if [ ${run_active_discovery} == True ]
	then
		ADCs_to_use=""

		declare -A ADCs=(
			["tls_probe"]="cat ${output} | cero -d | grep -Po \"^[^-*\\\"]*?\K[[:alnum:]-]+\.${domain}\" | anew ${output}"
			["csp_probe"]="cat ${output} | httpx -csp-probe -silent | grep -Po \"^[^-*\\\"]*?\K[[:alnum:]-]+\.${domain}\" | anew ${output}"
			["DNS_records"]="cat /tmp/.massdns | grep -Po \"^[^-*\\\"]*?\K[[:alnum:]-]+\.${domain}\" | anew ${output}"
			["reverse_DNS_lookup"]="cat /tmp/.massdns | grep -E -o \"([0-9]{1,3}[\.]){3}[0-9]{1,3}\" | sort -u | hakrevdns --domain --threads=100 | grep -Po \"^[^-*\\\"]*?\K[[:alnum:]-]+\.${domain}\" | anew ${output}"
		)

		for ADC in "${!ADCs[@]}"
		do
			ADCs_to_use="${ADCs_to_use}\n${ADCs[${ADC}]}"
		done

		echo -e ${ADCs_to_use} | rush '{}'
	fi
fi

# Remove temporary output
rm -rf ${_output} /tmp/.massdns

exit 0