# ArgFuscator-docker
**This is a fork of the original ArgFuscator.  It allows Argfuscator to be deployed in a docker container.

ArgFuscator is an open-source, stand-alone web application that helps generate obfuscated command lines for common system-native executables.

👉 **Use the interactive version of ArgFuscator on [ArgFuscator.net](https://argfuscator.net/)** 🚀

👾 _Find the cross-platform PowerShell version on [wietze/Invoke-Argfuscator](https://www.github.com/wietze/Invoke-Argfuscator)._

## One-sentence pitch

Paste a valid command in [ArgFuscator](https://argfuscator.net/) and get a working, obfuscated command-line equivalent in return.

## Summary

Command-Line obfuscation ([T1027.010](https://attack.mitre.org/techniques/T1027/010/)) is the masquerading of a command's true intention through the manipulation of a process' command line. Across [Windows](https://www.wietzebeukema.nl/blog/windows-command-line-obfuscation), Linux and MacOS, many applications parse passed command-line arguments in unexpected ways, leading to situations in which insertion, deletion and/or subsitution of certain characters does not change the program's execution flow. Successful command-line obfuscation is likely to frustrate defensive measures such as AV and EDR software, in some cases completely bypassing detection altogether.

Although previous research has highlighted the risks of command-line obfuscation, mostly with anecdotal examples of vulnerable (system-native) applications, there is an knowledge vacuum surrounding this technique. This project aims to overcome this by providing a centralised resource that documents and demonstrates various command-line obfuscation techniques, and records the subsceptability of popular applications for each.

## Install
1. Clone this repository.
2. Allow setup.sh to be executed. ```sudo chmod +x setup.sh```
3. Run ```./setup.sh```.
4. Choose Development server for a quick server that can be closed with Ctrl+C.
5. Choose Production for a detached server that runs in the background.
6. Access server at IP:4000 for both containers.
