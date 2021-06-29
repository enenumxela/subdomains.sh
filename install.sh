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

echo -e "\n[+] Running install script for subdomains.sh & its requirements.\n"

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
    sudo apt -qq -y install ${missing_tools[@]}
fi

# golang

if [ ! -x "$(command -v go)" ]
then
    version=1.15.7

    wget https://golang.org/dl/go${version}.linux-amd64.tar.gz -O /tmp/go${version}.linux-amd64.tar.gz

    sudo tar -xzf /tmp/go${version}.linux-amd64.tar.gz -C /usr/local

    (grep -q "export PATH=\$PATH:/usr/local/go/bin" ~/.profile) || {
        export PATH=$PATH:/usr/local/go/bin
        echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
        source ~/.profile
    }
fi

# amass

GO111MODULE=on go get github.com/OWASP/Amass/v3/...

# subfinder

GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder

# sigsubfind3r

GO111MODULE=on go get -v github.com/signedsecurity/sigsubfind3r/cmd/sigsubfind3r

# findomain

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

# subdomains.sh

curl -sL https://raw.githubusercontent.com/enenumxela/subdomains.sh/main/subdomains.sh -o ${script_path}
chmod u+x ${script_path}