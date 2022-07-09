# subdomains.sh

![Made with Bash](https://img.shields.io/badge/made%20with-Bash-0040ff.svg) ![Maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg) [![open issues](https://img.shields.io/github/issues-raw/hueristiq/subdomains.sh.svg?style=flat&color=0040ff)](https://github.com/hueristiq/subdomains.sh/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/hueristiq/subdomains.sh.svg?style=flat&color=0040ff)](https://github.com/hueristiq/subdomains.sh/issues?q=is:issue+is:closed) [![license](https://img.shields.io/badge/license-MIT-gray.svg?colorB=0040FF)](https://github.com/hueristiq/subdomains.sh/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@itshueristiq-0040ff.svg)](https://twitter.com/itshueristiq)

A wrapper around tools used for subdomain enumeration, to automate the workflow, on a given domain, written in bash.

## Resources

* [The Workflow](#the-workflow)
* [Installation](#installation)
* [Usage](#usage)
* [Credits](#credits)
* [Contribution](#contribution)

## The Workflow

<div align="center">

![Flow Chart](https://github.com/hueristiq/subdomains.sh/blob/main/static/flowchart.png)

</div>

## Installation

Run the installation script:

```bash
curl -s https://raw.githubusercontent.com/hueristiq/subdomains.sh/main/install.sh | bash -
```
Or run in an ephemeral Docker container:

Clone the repository and run

```bash
cd subdomains.sh
# Build the container image
./docker-subdomains.sh build

# After build, you can run the script with the same options listed above.
# Each run will run in a new container, and the container is destroyed after run
./docker-sudomains.sh -d example.com -r 1.1.1.1

# To destroy the container image if desired
./docker-subdomains.sh destroy

```

## Usage

To display this script's help message, use the `-h` flag:

```bash
subdomains.sh -h
```

```text
           _         _                       _                 _     
 ___ _   _| |__   __| | ___  _ __ ___   __ _(_)_ __  ___   ___| |__  
/ __| | | | '_ \ / _` |/ _ \| '_ ` _ \ / _` | | '_ \/ __| / __| '_ \ 
\__ \ |_| | |_) | (_| | (_) | | | | | | (_| | | | | \__  _\__ \ | | |
|___/\__,_|_.__/ \__,_|\___/|_| |_| |_|\__,_|_|_| |_|___(_)___/_| |_| v1.0.0

USAGE:
  subdomains.sh [OPTIONS]

OPTIONS:
   -d, --domain 			 domain to discover subdomains for *
   -r, --resolvers 			 list of DNS resolvers containing file *
       --use-passive-source		 comma(,) separated passive tools to use
       --exclude-passive-source 	 comma(,) separated passive tools to exclude
       --skip-semi-active 		 skip discovery from semi active techniques
       --skip-dictionary 		 skip discovery from dictionary DNS brute forcing
  -dW, --dictionary-wordlist 		 wordlist for dictionary DNS  brute forcing
       --skip-permutation 		 skip discovery from permutation DNS brute forcing
  -pW, --permutation-wordlist 		 wordlist for permutation DNS brute forcing
       --skip-dns-records 		 skip discovery from DNS records
       --skip-reverse-dns 		 skip discovery from reverse DNS lookup
       --skip-active 			 skip discovery from active techniques
   -o, --output 			 output text file
       --setup				 install/update this script & dependencies
   -h, --help 				 display this help message and exit

NOTE: options marked with asterik(*) are required.

HAPPY HACKING :)
```

## Credits

Credit goes to the authors of the various tools I used in this script:

* [@OWASP](https://github.com/OWASP) for [amass](https://github.com/OWASP/Amass)
* [@hakluke](https://github.com/hakluke) for [hakrevdns](https://github.com/hakluke/hakrevdns)
* [@d3mondev](https://github.com/d3mondev) for [puredns](https://github.com/d3mondev/puredns)
* [@tomnonom](https://github.com/tomnomnom) for [anew](https://github.com/tomnomnom/anew)
* [@Edu4rdSHL](https://github.com/Edu4rdSHL) for [findomain](https://github.com/Edu4rdSHL/findomain)
* [@signedsecurity](http://github.com/signedsecurity) for [sigsubfind3r](http://github.com/signedsecurity/sigsubfind3r)
* [@projectdiscovery](https://github.com/projectdiscovery) for [subfinder](https://github.com/projectdiscovery/subfinder) and [httpx](https://github.com/projectdiscovery/subfinder)

## Contribution

[Issues](https://github.com/hueristiq/subdomains.sh/issues) and [Pull Requests](https://github.com/hueristiq/subdomains.sh/pulls) are welcome!
