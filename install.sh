#!/usr/bin/env bash

# Formating
blue="\e[34m"
bold="\e[1m"
cyan="\e[36m"
green="\e[32m"
red="\e[31m"
yellow="\e[33m"
reset="\e[0m"
underline="\e[4m"

echo -e ${bold}${blue}"
           _         _                       _                 _     
 ___ _   _| |__   __| | ___  _ __ ___   __ _(_)_ __  ___   ___| |__  
/ __| | | | '_ \ / _\` |/ _ \| '_ \` _ \ / _\` | | '_ \/ __| / __| '_ \ 
\__ \ |_| | |_) | (_| | (_) | | | | | | (_| | | | | \__  ${red}_${blue}\__ \ | | |
|___/\__,_|_.__/ \__,_|\___/|_| |_| |_|\__,_|_|_| |_|___${red}(_)${blue}___/_| |_| ${yellow}v1.0.0${blue}

Installation script..."${reset}

if [ "${SUDO_USER:-$USER}" != "${USER}" ]
then
	echo -e "\n${blue}[${red}-${blue}]${reset} failed!...ps.sh called with sudo!\n"
	exit 1
fi

CMD_PREFIX=

if [ ${UID} -gt 0 ] && [ -x "$(command -v sudo)" ]
then
	CMD_PREFIX="sudo"
elif [ ${UID} -gt 0 ] && [ ! -x "$(command -v sudo)" ]
then
	echo -e "\n${blue}[${red}-${blue}]${reset} failed!...\`sudo\` command not found!\n"
	exit 1
fi

DOWNLOAD_CMD=

if command -v >&- curl
then
	DOWNLOAD_CMD="curl -sL"
elif command -v >&- wget
then
	DOWNLOAD_CMD="wget --quiet --show-progres --continue --output-document=-"
else
	echo "\n${blue}[${red}-${blue}]${reset} Could not find wget/cURL\n" >&2
	exit 1
fi

script_directory="${HOME}/.local/bin"

if [ ! -d ${script_directory} ]
then
	mkdir -p ${script_directory}
fi

tools=(
	curl
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
	echo -e "[+] ${missing_tools[@]}\n"

	eval ${CMD_PREFIX} apt-get -qq -y install ${missing_tools[@]}
fi

if [ ! -x "$(command -v go)" ] && [ ! -x "$(command -v /usr/local/go/bin/go)" ]
then
	version=1.17.6

	echo -e "\n[+] go${version}\n"

	eval ${DOWNLOAD_CMD} https://golang.org/dl/go${version}.linux-amd64.tar.gz -o /tmp/go${version}.linux-amd64.tar.gz

	eval ${CMD_PREFIX} tar -xzf /tmp/go${version}.linux-amd64.tar.gz -C /usr/local
fi

(grep -q "export PATH=\$PATH:/usr/local/go/bin" ~/.profile) || {
	echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
}
(grep -q "export PATH=\$PATH:${HOME}/go/bin" ~/.profile) || {
	echo "export PATH=\$PATH:${HOME}/go/bin" >> ~/.profile
}

source ~/.profile

echo -e "\n[+] amass\n"

go install github.com/OWASP/Amass/v3/...@latest

echo -e "\n[+] anew\n"

go install github.com/tomnomnom/anew@latest

echo -e "\n[+] cero\n"

go install github.com/glebarez/cero@latest

echo -e "\n[+] crobat\n"

go install github.com/cgboal/sonarsearch/cmd/crobat@latest

echo -e "\n[+] findomain\n"

binary_path="/usr/local/bin/findomain"

eval ${CMD_PREFIX} bash <<EOF
eval ${DOWNLOAD_CMD} https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux > ${binary_path}
chmod a+x ${binary_path}
EOF

echo -e "\n[+] gotator\n"

go install github.com/Josue87/gotator@latest

echo -e "\n[+] hakrevdns\n"

go install github.com/hakluke/hakrevdns@latest

echo -e "\n[+] httpx\n"

go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

echo -e "\n[+] massdns\n"

if [ ! -x "$(command -v massdns)" ]
then
	git clone https://github.com/blechschmidt/massdns.git /tmp/massdns
	cd /tmp/massdns
	make
	eval ${CMD_PREFIX} mv bin/massdns /usr/bin/
	cd -
	rm -rf /tmp/massdns
fi

echo -e "\n[+] puredns\n"

go install github.com/d3mondev/puredns/v2@latest

echo -e "\n[+] rush\n"

go install github.com/shenwei356/rush@latest

echo -e "\n[+] subfind3r\n"

go install github.com/hueristiq/subfind3r/cmd/subfind3r@latest

echo -e "\n[+] subfinder\n"

go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo -e "\n[+] subdomains.sh\n"

script_path="${script_directory}/subdomains.sh"

if [ -e "${script_path}" ]
then
	rm ${script_path}
fi

eval ${DOWNLOAD_CMD} https://raw.githubusercontent.com/hueristiq/subdomains.sh/main/subdomains.sh > ${script_path}
chmod u+x ${script_path}
