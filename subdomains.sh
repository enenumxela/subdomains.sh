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
domains_list=False

sources=(
	amass
	subfinder
	findomain
	sigsubfind3r
)
sources_to_use=False
sources_to_exclude=False

output_directory="$(pwd)/subdomain-enumeration"

display_usage() {
	while read -r line
	do
		printf "%b\n" "${line}"
	done <<-EOF
	\r USAGE:
	\r   ${script_filename} [OPTIONS]

	\r OPTIONS:
	\r    -d, --domain \t\t domain to enumerate subdomains for
	\r   -dL, --domain-list \t\t domain to enumerate subdomains for
    \r   -eS, --exclude-source \t comma(,) separated tools to exclude
	\r   -uS, --use-source\t\t comma(,) separated tools to use
	\r    -r, --resolve \t\t resolved collected subdomains
    \r    -o, --output-dir \t\t output directory
	\r    -k, --keep \t\t\t keep each tool's temp results
	\r        --setup\t\t\t setup requirements for this script
	\r    -h, --help \t\t\t display this help message and exit
    
    \r ${red}${bold}HAPPY HACKING ${yellow}:)${reset}

EOF
}

_amass() {
	local amass_output="${output_directory}/${domain}-temp-amass-subdomains.txt"

	printf "    [${blue}+${reset}] amass"
	printf "\r"
	${HOME}/go/bin/amass enum -passive -d ${domain} -o ${amass_output} &> /dev/null
	echo -e "    [${green}*${reset}] amass: $(wc -l < ${amass_output})"
}

_subfinder() {
	local subfinder_output="${output_directory}/${domain}-temp-subfinder-subdomains.txt"

	printf "    [${blue}+${reset}] subfinder"
	printf "\r"
	${HOME}/go/bin/subfinder -d ${domain} -silent 1> ${subfinder_output} 2> /dev/null
	echo -e "    [${green}*${reset}] subfinder: $(wc -l < ${subfinder_output})"
}

_findomain() {
	local findomain_output="${output_directory}/${domain}-temp-findomain-subdomains.txt"

	printf "    [${blue}+${reset}] findomain"
	printf "\r"
	${HOME}/.local/bin/findomain -t ${domain} -q 1> ${findomain_output} 2> /dev/null
	echo -e "    [${green}*${reset}] findomain: $(wc -l ${findomain_output} | awk '{print $1}' 2> /dev/null)"
}

_sigsubfind3r() {
	local sigsubfind3r_output="${output_directory}/${domain}-temp-sigsubfind3r-subdomains.txt"

	printf "    [${blue}+${reset}] sigsubfind3r"
	printf "\r"
	${HOME}/go/bin/sigsubfind3r -d ${domain} -silent 1> ${sigsubfind3r_output} 2> /dev/null
	echo -e "    [${green}*${reset}] sigsubfind3r: $(wc -l < ${sigsubfind3r_output})"
}

handle_domain() {
	local subdomains_txt=${output_directory}/${domain}-subdomains.txt
	local resolved_txt=${output_directory}/${domain}-resolved.txt

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

    cat ${output_directory}/${domain}-temp-*-subdomains.txt | \
		sed 's#*.# #g' | \
			${HOME}/go/bin/anew -q ${subdomains_txt}

	echo -e "        [>] subdomains: $(wc -l < ${subdomains_txt})"

	if [ ${resolve} == True ]
	then
		${HOME}/.local/bin/massdns -r ${HOME}/wordlists/resolvers.txt -q -t A -o S -w ${output_directory}/${domain}-temp-massdns-subdomains.txt ${output_directory}/${domain}-subdomains.txt

		cat ${output_directory}/${domain}-temp-massdns-subdomains.txt | \
			grep -Po "^[^-*\"]*?\K[[:alnum:]-]+\.${domain}" | \
				${HOME}/go/bin/anew -q ${resolved_txt}

		echo -e "        [>] resolved  : $(wc -l < ${resolved_txt})"
	fi

	[ ${keep} == False ] && rm ${output_directory}/${domain}-temp-*-subdomains.txt
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
		-dL | --domain-list)
			domains_list=${2}
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
		-o | --output-dir)
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
	echo -e "\n[*] subdomain enumeration on ${domain}"
	handle_domain
fi

# Flow for a domain list
if [ ${domains_list} != False ]
then
	total=$(wc -l < ${domains_list})
	count=1
	while read domain
	do
		if [[ ${domain} == "" ]]
		then
			echo -e "\n[*] (${count}/${total}) empty! skipping..."
		else
			echo -e "\n[*] (${count}/${total}) subdomain enumeration on ${domain}"
			handle_domain
		fi
		let count+=1
	done < ${domains_list}
fi

exit 0