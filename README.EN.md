# Cloudflare DNS SSL Automation Script

Here's a Bash script that automates the process of getting an SSL certificate from Let's Encrypt using Certbot and Cloudflare DNS validation.

Simplify SSL certificate setup for domains managed by Cloudflare.

## Table of contents

- [Overview](#Overview)
- [Requirements](#Requirements)
- [How to use](#How-to-use)
- [Install](#Install)
- [Setting](#Setting)
- [License](#License)

## Overview

This script automates the following main tasks:

- Install required packages: Install packages such as dialog, certbot, python3-certbot-dns-cloudflare.
- Enter Cloudflare Credentials: Asks for the Cloudflare API key and email address, and specifies the domain name and certificate storage directory.
- Shell script generation: Generates a shell script named ssl.sh based on the entered information.
- Obtain SSL Certificate: Run the generated ssl.sh script to obtain an SSL certificate from Let's Encrypt using Cloudflare DNS Validation.

By using this script, you can reduce manual configuration work and efficiently set up SSL certificates. It also generates a shell script, so it can be reused later.

**NOTE:** Before running this script, make sure you have a Cloudflare API key and email address and that the domain in question is managed by Cloudflare. Also, the server you run the script on must have superuser privileges (root).

## Requirements

- Linux based system (tested on Ubuntu)
- Bash shell
- Cloudflare API key and email address
- Domains managed by Cloudflare

## How to use

1. Clone this repository to your local machine: `git clone https://github.com/winning-JP/cloudflare-dns-certbot.git`

2. Go to your project directory: `cd cloudflare-dns-certbot`

3. Change the settings to run the main script as superuser (root): `chmod +x setup.sh`

4. Run the main script as superuser (root): `sudo ./setup.sh`

5. Enter the user's Cloudflare credentials, domain name, and certificate storage directory.

6. Check your settings and run the generated `ssl.sh` script.

## Install

Before running the script, make sure you have the required packages installed:

`sudo apt-get update`

`sudo apt-get install -y dialog certbot python3-certbot-dns-cloudflare`

## Setting

The script prompts the user for the following information:

- Cloudflare API Key: Obtained from your Cloudflare account.
- Cloudflare Email Address: Use the email address associated with your Cloudflare account.
- Domain Name: Enter the domain name for which you want to obtain an SSL certificate.
- Destination Directory: Specify the full path of the directory to save the certificate. If left blank, it will be saved where the shell is running.

## License

This project is provided under the MIT license
- See the [LICENSE](LICENSE) file for details.
