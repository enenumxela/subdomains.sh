#!/usr/bin/env bash

bold="\e[1m"
red="\e[31m"
cyan="\e[36m"
blue="\e[34m"
reset="\e[0m"
green="\e[32m"
yellow="\e[33m"
underline="\e[4m"

echo -e " [+] Running install script for subdomains.sh requirements.\n"

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
    version=1.15.7

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

GO111MODULE=on go get github.com/OWASP/Amass/v3/...

# subfinder

GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder

# sigsubfind3r

GO111MODULE=on go get -v github.com/signedsecurity/sigsubfind3r/cmd/sigsubfind3r

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

go get -u github.com/tomnomnom/anew

# dnsx

go get -v github.com/projectdiscovery/dnsx/cmd/dnsx