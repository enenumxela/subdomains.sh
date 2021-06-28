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
domains_list=False
sources=(
	amass
    subfinder
    findomain
	sigsubfind3r
)
sources_to_use=False
sources_to_exclude=False
output_directory="$(pwd)/subdomains.sh-output"

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
    \r   -eS, --exclude-source \t comma(,) separated passive tools to exclude
	\r   -uS, --use-source\t\t comma(,) separated passive tools to use
    \r    -o, --output-dir \t\t output directory
	\r    -k, --keep \t\t\t keep each tool's temp results
	\r        --setup\t\t\t setup requirements for this script
	\r    -h, --help \t\t\t display this help message and exit
    
    \r ${red}${bold}HAPPY HACKING ${yellow}:)${reset}

EOF
}

# Function to install and setup required tools
setup_requirements() {
	tools=(
		tee
		wget
	)
	missing_tools=()

	for tool in "${tools[@]}"
	do
		if [ ! -x "$(command -v ${tool})" ]
		then 
			missing_tools+=(${tool})
		fi
	done

	if [ ${#missing_tools[@]} -gt 0 ]
	then
		if [ "${UID}" -gt 0 ]
		then
			echo ${password} | sudo -S apt -qq -y install ${missing_tools[@]}
		else
			apt -qq -y install ${missing_tools[@]}
		fi
	fi

	if [ ! -x "$(command -v go)" ]
	then
		version=1.15.7

		wget https://golang.org/dl/go${version}.linux-amd64.tar.gz -O /tmp/go${version}.linux-amd64.tar.gz

		if [ "${UID}" -gt 0 ]
		then
			echo ${password} | sudo -S tar -xzf /tmp/go${version}.linux-amd64.tar.gz -C /usr/local
		else
			tar -xzf /tmp/go${version}.linux-amd64.tar.gz -C /usr/local
		fi

		(grep -q "export PATH=\$PATH:/usr/local/go/bin" ~/.profile) || {
			export PATH=$PATH:/usr/local/go/bin
			echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
			source ~/.profile
		}
	fi

	GO111MODULE=on go get github.com/OWASP/Amass/v3/...
	GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
	GO111MODULE=on go get -v github.com/signedsecurity/sigsubfind3r/cmd/sigsubfind3r

	if [ ! -f ${HOME}/.local/bin/findomain ]
	then
		curl -sL https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -o ${HOME}/.local/bin/findomain
		chmod u+x ${HOME}/.local/bin/findomain
	fi

	script_directory="${HOME}/.local/bin"

	if [ ! -d ${script_directory} ]
	then
		mkdir -p ${script_directory}
	fi

	script_path="${script_directory}/${script_filename}"

	if [ -e "${script_path}" ]
	then
		rm ${script_path}
	fi

	curl -sL https://github.com/enenumxela/subdomains.sh/raw/main/subdomains.sh -o ${script_path}
	chmod u+x ${script_path}
}

_amass() {
	local amass_output="${output_directory}/${domain}-temp-amass-subdomains.txt"

	printf "    [${blue}+${reset}] amass"
	printf "\r"
	${HOME}/go/bin/amass enum -passive -d ${domain} -o ${amass_output} &> /dev/null
	echo -e "    [${green}*${reset}] amass: $(wc -l < ${amass_output})"
}

_sigsubfind3r() {
	local sigsubfind3r_output="${output_directory}/${domain}-temp-sigsubfind3r-subdomains.txt"

	printf "    [${blue}+${reset}] sigsubfind3r"
	printf "\r"
	${HOME}/go/bin/sigsubfind3r -d ${domain} -silent 1> ${sigsubfind3r_output} 2> /dev/null
	echo -e "    [${green}*${reset}] sigsubfind3r: $(wc -l < ${sigsubfind3r_output})"
}

_findomain() {
	local findomain_output="${output_directory}/${domain}-temp-findomain-subdomains.txt"

	printf "    [${blue}+${reset}] findomain"
	printf "\r"
	${HOME}/.local/bin/findomain -t ${domain} -q 1> ${findomain_output} 2> /dev/null
	echo -e "    [${green}*${reset}] findomain: $(wc -l ${findomain_output} | awk '{print $1}' 2> /dev/null)"
}

_subfinder() {
	local subfinder_output="${output_directory}/${domain}-temp-subfinder-subdomains.txt"

	printf "    [${blue}+${reset}] subfinder"
	printf "\r"
	${HOME}/go/bin/subfinder -d ${domain} -silent 1> ${subfinder_output} 2> /dev/null
	echo -e "    [${green}*${reset}] subfinder: $(wc -l < ${subfinder_output})"
}

handle_domain() {
    if [ ! -d ${output_directory} ]
    then
        mkdir -p ${output_directory}
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

    cat ${output_directory}/${domain}-temp-*-subdomains.txt | sed 's#*.# #g' | anew -q ${output_directory}/${domain}-subdomains.txt
	echo -e "    [=] unique subdomains: $(wc -l < ${output_directory}/${domain}-subdomains.txt)"

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
		-o | --output-dir)
			output_directory="${2}"
			shift
		;;
		-k | --keep)
			keep=True
		;;
		--setup)
			setup_requirements
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

# ensure required tools are installed
tools=(
	amass
	subfinder
	findomain
	sigsubfind3r
)
missing_tools=()

for tool in "${tools[@]}"
do
	if [ ! -x "$(command -v ${tool})" ]
	then 
		missing_tools+=(${tool})
	fi
done

[ ${#missing_tools[@]} -gt 0 ] && {
	missing_tools_str="${missing_tools[@]}"
	echo -e "\n${blue}[${red}-${blue}]${reset} failed! missing tool(s) : " ${missing_tools_str// /,}"\n"
	exit 1
}

# ensure domain(s) is/are provided
if [ ${domain} == False ] && [ ${domains_list} == False ]
then
	echo -e "${blue}[${red}-${blue}]${reset} failed! argument -d/--domain OR -l/--list is Required!\n"
	exit 1
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
		echo -e "\n[*] (${count}/${total}) subdomain enumeration on ${domain}"
		handle_domain
		let count+=1
	done < ${domains_list}
fi

exit 0