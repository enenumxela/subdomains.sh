# subdomains.sh

![Made with Bash](https://img.shields.io/badge/made%20with-Bash-0040ff.svg) ![Maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg) [![open issues](https://img.shields.io/github/issues-raw/enenumxela/subdomains.sh.svg?style=flat&color=0040ff)](https://github.com/enenumxela/subdomains.sh/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/enenumxela/subdomains.sh.svg?style=flat&color=0040ff)](https://github.com/enenumxela/subdomains.sh/issues?q=is:issue+is:closed) [![license](https://img.shields.io/badge/license-MIT-gray.svg?colorB=0040FF)](https://github.com/enenumxela/subdomains.sh/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@enenumxela-0040ff.svg)](https://twitter.com/enenumxela)

A wrapper around tools I use for subdomains gathering - [amass](https://github.com/OWASP/Amass), [subfinder](https://github.com/projectdiscovery/subfinder), [findomain](https://github.com/Edu4rdSHL/findomain) & [sigsubfind3r](http://github.com/signedsecurity/sigsubfind3r) - and filtering out dead records from the gathered list of subdomains - [dnsx](https://github.com/projectdiscovery/dnsx). 

## Installation

Run the installation script:

```bash
curl -s https://raw.githubusercontent.com/enenumxela/subdomains.sh/main/install.sh | bash -
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
  -d,  --domain 			 domain to gather subdomains for
       --use-passive-source		 comma(,) separated tools to use
       --exclude-passive-source 	 comma(,) separated tools to exclude
       --skip-semi-active 		 skip semi active techniques
       --skip-dictionary 		 skip dictionary brute forcing
       --skip-permutation 		 skip permutations brute forcing
  -o,  --output 			 output text file
       --setup				 setup requirements for this script
  -h,  --help 				 display this help message and exit

 HAPPY HACKING :)
```

## Contribution

[Issues](https://github.com/enenumxela/subdomains.sh/issues) and [Pull Requests](https://github.com/enenumxela/subdomains.sh/pulls) are welcome!