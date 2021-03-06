# Mass mailing tool (mmt)

## What is it?
`mmt` is a simple utility that allows the automated sending of emails using a configuration file and a template for the email body.
It was written in [Elixir](http://elixir-lang.org/) and used mainly on linux systems like [Arch Linux](https://www.archlinux.org/), [Fedora](https://getfedora.org/) and [Ubuntu](http://www.ubuntu.com/).

## Prerequisites
Running `mmt` requires a running mail transfer agent (MTA) e.g. [postfix](http://www.postfix.org/) and the [GNU mailutils](https://www.gnu.org/software/mailutils/mailutils.html) software (Arch Linux: [`pacman -S mailutils`](https://www.archlinux.org/packages/?sort=&q=mailutils&maintainer=&flagged=), Ubuntu: [`apt-get install mailutils`](http://packages.ubuntu.com/search?keywords=mailutils)). For Fedora etc. you are all set since `mailx` is installed by default.

## Using `mmt`
The easiest way to use the tool is to generate a sample configuration (`--sample-config`) and a template file (`--sample-template`) and take it from there.

    $ ./mmt --help

    Send emails in bulk based on a template and a config file containing
    the email body and recipient names/addresses respectively.

      --help            print this help
      --config-path     path to the config file
      --dry-run         print commands that would be executed, but do not
                        execute them
      --subject         email subject
      --template-path   path to the template file
      --sample-config   prints a sample config file to stdout
      --sample-template prints a sample template file to stdout
