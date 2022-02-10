#!/usr/bin/env bash

bold="\e[1m"
red="\e[31m"
cyan="\e[36m"
blue="\e[34m"
reset="\e[0m"
green="\e[32m"
yellow="\e[33m"
underline="\e[4m"

echo -e "[+] Running install script for subdomains.sh requirements.\n"

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
    sudo apt -qq -y install ${missing_tools[@]}
fi

# golang

if [ ! -x "$(command -v go)" ]
then
    version=1.17.6

    curl -sL https://golang.org/dl/go${version}.linux-amd64.tar.gz -o /tmp/go${version}.linux-amd64.tar.gz

    sudo tar -xzf /tmp/go${version}.linux-amd64.tar.gz -C /usr/local
fi

(grep -q "export PATH=\$PATH:/usr/local/go/bin" ~/.profile) || {
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
}

(grep -q "export PATH=\$PATH:${HOME}/go/bin" ~/.profile) || {
    echo "export PATH=\$PATH:${HOME}/go/bin" >> ~/.profile
}

source ~/.profile

# amass

go install github.com/OWASP/Amass/v3/...@latest

# subfinder

go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# sigsubfind3r

go install github.com/signedsecurity/sigsubfind3r/cmd/sigsubfind3r@latest

script_directory="${HOME}/.local/bin"

if [ ! -d ${script_directory} ]
then
	mkdir -p ${script_directory}
fi

# findomain

binary_path="${script_directory}/findomain"

if [ -e "${binary_path}" ]
then
    rm ${binary_path}
fi

curl -sL https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -o ${binary_path}
chmod u+x ${binary_path}

# anew

go install github.com/tomnomnom/anew@latest

# dnsx

go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# subdomains.sh

script_path="${script_directory}/subdomains.sh"

if [ -e "${script_path}" ]
then
	rm ${script_path}
fi

curl -sL https://raw.githubusercontent.com/enenumxela/subdomains.sh/main/subdomains.sh -o ${script_path}
chmod u+x ${script_path}