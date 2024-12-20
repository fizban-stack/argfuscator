# ArgFuscator

ArgFuscator is an open-source, stand-alone web application that helps generate obfuscated command lines for common system-native executables.

👉 **Use the interactive version of ArgFuscator on [ArgFuscator.net](https://argfuscator.net/)** 🚀

👾 _Find the cross-platform PowerShell version on [wietze/Invoke-Argfuscator](https://www.github.com/wietze/Invoke-Argfuscator)._

## One-sentence pitch

Paste a valid command in [ArgFuscator](https://argfuscator.net/) and get a working, obfuscated command-line equivalent in return.

## Summary

Command-Line obfuscation ([T1027.010](https://attack.mitre.org/techniques/T1027/010/)) is the masquerading of a command's true intention through the manipulation of a process' command line. Across [Windows](https://www.wietzebeukema.nl/blog/windows-command-line-obfuscation), Linux and MacOS, many applications parse passed command-line arguments in unexpected ways, leading to situations in which insertion, deletion and/or subsitution of certain characters does not change the program's execution flow. Successful command-line obfuscation is likely to frustrate defensive measures such as AV and EDR software, in some cases completely bypassing detection altogether.

Although previous research has highlighted the risks of command-line obfuscation, mostly with anecdotal examples of vulnerable (system-native) applications, there is an knowledge vacuum surrounding this technique. This project aims to overcome this by providing a centralised resource that documents and demonstrates various command-line obfuscation techniques, and records the subsceptability of popular applications for each.

## Goal

The primary goal of this project is to document known command-line obfuscation techniques against applications commonly used in cyber attacks, and using this knowledge to allow users to generate obfuscated command lines. For cyber security defenders, this provides a powerful tool to test one's own defence systems. Since detecting or otherwise accommodating for command-line obfuscation does not have to be difficult, having access to a this resource allows for effective, real-world validation of defense mechanisms in one's environment.

## Coming about

First, through literature review and our own research, command-line obfuscation techniques were gathered, analysed and classified. The identified techniques form the basis for the subsequent analysis.

Secondly, by assessing a wide variety of popular applications, both in [automated fashion](https://github.com/wietze/windows-command-line-obfuscation) and through manual inspection, a mapping between the defined techinques and vulnerable applications was created. The results are captured in a machine-readable format (see [`./models`](/models/)).

Thirdly, a system was created that allows for the transformation of an arbitrary command line using a sequence of defined obfuscation technique in a provided configuration. To ensure ease of use, a TypeScript implementation was created (see [`./src`](/src/)) that is supported by a user-friendly web interface (see [`./gui`](/gui/)), which can interpret the aforementioned model files.

Finally, the models were tested against the created implementation in order to validate their correctness, which allows for the further tuning of the findings. The result is this project, encompassing the results of all stages.

## Local development

To run ArgFuscator yourself, follow the following steps:

0. Prerequirements:
    1. Clone this repository;
    2. Install TypeScript (e.g. `apt install tsc`); and,
    3. Install [Jekyll](https://jekyllrb.com/docs/installation/).

1. From the main folder of this repostitory, run the following command:

   ```bash
   tsc -w --project src/ --outfile gui/assets/js/main.js
   ```

2. From the `gui/` folder, run:

   ```bash
   jekyll serve
   ```
