# subdomains.sh

![Made with Bash](https://img.shields.io/badge/made%20with-Bash-0040ff.svg) ![Maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg) [![open issues](https://img.shields.io/github/issues-raw/enenumxela/subdomains.sh.svg?style=flat&color=0040ff)](https://github.com/enenumxela/subdomains.sh/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/enenumxela/subdomains.sh.svg?style=flat&color=0040ff)](https://github.com/enenumxela/subdomains.sh/issues?q=is:issue+is:closed) [![license](https://img.shields.io/badge/license-MIT-gray.svg?colorB=0040FF)](https://github.com/enenumxela/subdomains.sh/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@enenumxela-0040ff.svg)](https://twitter.com/enenumxela)

`subdomains.sh` wrapper around tools I use for subdomain enumeration on a given domain. This script is written with the aim to automate the workflow.

## Resources

* [Usage](#usage)
* [Installation](#installation)
* [Credits](#credits)
* [Contribution](#contribution)

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
  -d,  --domain 			 domain to gather subdomains for
  -dW,  --dictionary-wordlist 		 wordlist for dictionary brute forcing
  -pW,  --permutation-wordlist 		 wordlist for permutation brute forcing
       --use-passive-source		 comma(,) separated tools to use
       --exclude-passive-source 	 comma(,) separated tools to exclude
       --skip-semi-active 		 skip semi active techniques
       --skip-dictionary 		 skip dictionary brute forcing
       --skip-permutation 		 skip permutation brute forcing
  -o,  --output 			 output text file
       --setup				 install/update this script & dependencies
  -h,  --help 				 display this help message and exit

 HAPPY HACKING :)

```

## Installation

Run the installation script:

```bash
curl -s https://raw.githubusercontent.com/enenumxela/subdomains.sh/main/install.sh | bash -
```

## Credits

Credit goes to the authors of the various tools used in this script:

* [@OWASP](https://github.com/OWASP) for [amass](https://github.com/OWASP/Amass)
* [@hakluke](https://github.com/hakluke) for [hakrevdns](https://github.com/hakluke/hakrevdns)
* [@tomnonom](https://github.com/tomnomnom) for [anew](https://github.com/tomnomnom/anew)
* [@Edu4rdSHL](https://github.com/Edu4rdSHL) for [findomain](https://github.com/Edu4rdSHL/findomain)
* [@signedsecurity](http://github.com/signedsecurity) for [sigsubfind3r](http://github.com/signedsecurity/sigsubfind3r)
* [@projectdiscovery](https://github.com/projectdiscovery) for [subfinder](https://github.com/projectdiscovery/subfinder) & [dnsx](https://github.com/projectdiscovery/dnsx)

## Contribution

[Issues](https://github.com/enenumxela/subdomains.sh/issues) and [Pull Requests](https://github.com/enenumxela/subdomains.sh/pulls) are welcome!