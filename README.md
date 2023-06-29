# SeSH

Small command line program for managing SSH sessions

<br>

## Installation

Install directly with `cargo`
```bash
$ cargo install --git https://github.com/dbusteed/sesh
```

Or, clone it, build it, and move the binaries to somewhere on your PATH
```bash
$ git clone https://github.com/dbusteed/sesh
$ cd sesh
$ cargo build --release
$ cp ./target/release/sesh /somewhere/bin
```

<br>

## Usage

1. If you don't have one already, create a [SSH config](https://linux.die.net/man/5/ssh_config) file in your home directory. For example:
```bash
# *nix
/home/scoobydoo/.ssh/config

# windows
C:\Users\ScoobyDoo\.ssh\config
```
2. Add the connection details for each location
```ini
# ~/.ssh/config

Host MysteryMachine
    HostName mystery-machine-prod.net
    User scoob
```

<br>

## Supported Keywords

Not all keywords are supported right now, I just focused on getting this to work for my SSH config file which doesn't use too many complex options

Here are the supported keywords:
* `Host`
* `HostName`
* `User`
* `IdentityFile`