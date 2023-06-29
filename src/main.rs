use std::fs::File;
use std::io::{BufRead, BufReader, Write};
use std::path::{Path, PathBuf};
use std::process::Command;
use colored::Colorize;
use dirs;
use open;

const HELP_URL: &str = "https://github.com/dbusteed/sesh/blob/master/README.md";

#[derive(Debug)]
struct Host {
    host: String,
    hostname: String,
    user: String,
    identity_file: String,
}

impl Host {
    fn connect(&self) {
        let args = if self.identity_file.is_empty() {
            vec![&self.hostname, "-l", &self.user]
        } else {            
            vec![&self.hostname, "-l", &self.user, "-i", &self.identity_file]
        };

        let mut ssh = Command::new("ssh")
            .args(args)
            .spawn()
            .unwrap();

        ssh.wait().unwrap();
    }
}

fn parse_hosts_file(file_path: &PathBuf) -> Vec<Host> {
    let file = File::open(file_path).unwrap();
    let reader = BufReader::new(file);

    let mut hosts: Vec<Host> = vec![];
    let mut current_host = Host {
        host: String::new(),
        hostname: String::new(),
        user: String::new(),
        identity_file: String::from(""),
    };

    for line in reader.lines() {
        let line = line.unwrap();
        let line = line.trim();
        
        if line.is_empty() { continue; }
        if line.starts_with("#") { continue; }

        let tokens: Vec<&str> = line.split_whitespace().collect();
        match tokens[0] {
            "Host" => {
                if !current_host.host.is_empty() {
                    hosts.push(current_host);
                }

                current_host = Host {
                    host: tokens[1].to_owned(),
                    hostname: String::new(),
                    user: String::new(),
                    identity_file: String::from(""),
                };
            }
            "HostName" => {
                current_host.hostname = tokens[1].to_owned();
            }
            "User" => {
                current_host.user = tokens[1].to_owned();
            }
            "IdentityFile" => {
                current_host.identity_file = tokens[1].to_owned();
            }
            _ => {}
        }

    }
    
    if !current_host.host.is_empty() {
        hosts.push(current_host);
    }

    hosts
}

fn main() {

    let hosts: Vec<Host> = if let Some(home) = dirs::home_dir() {
        parse_hosts_file(&Path::new(&home).join(".ssh").join("config"))
    } else {
        println!("{}{}", "ERROR: ".red().bold(), "unable to find home directory");
        std::process::exit(1);
    };

    loop {
        print!("{esc}[2J{esc}[1;1H", esc = 27 as char);

        println!("{}", "┌────────────────────────┐");
        println!("{}{}{}", "│ ", "SSH connection manager".italic(), " │");
        println!("{}", "└────────────────────────┘\n");

        for (i, host) in hosts.iter().enumerate() {
            println!("{} {}", format!("({})", i + 1).cyan().bold(), host.host);
        }
        println!("\n{} {}", "(h)".magenta().bold(), "help");
        println!("{} {}", "(q)".magenta().bold(), "quit");

        print!("\n>>> ");
        let _ = std::io::stdout().flush();
        let mut input = String::new();
        std::io::stdin()
            .read_line(&mut input)
            .expect("Error reading user input!");

        match input.trim().to_lowercase().as_str() {
            "q" => std::process::exit(0),
            "h" => match open::that(HELP_URL) {
                Ok(()) => { /* do nothing, if matched, the command was executed */ },
                Err(_) => println!("See help page @ '{}'", HELP_URL)
            },
            other => {
                match other.parse::<usize>() {
                    Ok(num) => {
                        if num - 1 < hosts.len() {
                            hosts[num - 1].connect();
                            std::process::exit(0);
                        }
                    }
                    Err(_) => continue
                }
            }
        }
    }

}
