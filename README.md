# Terraform Templates for Cisco ASAv/FTDv

This repository contains Terraform templates for deploying Cisco ASAv and FTDv infrastructure in cloud platforms.  *(Currently, AWS - but I'm planning to build Azure templates as well.)*

## Configuration

### Authentication

The main configuration item for these scripts is to simply set up the Authentication for the cloud platforms.

Currently, the scripts assume you're using an AWS credentials file.  The default location is ```$HOME/.aws/credentials``` on Linux and OS X, or ```"%USERPROFILE%\.aws\credentials"``` for Windows users.

Terraform will also check for environment variables, or you can statically define the variables in the script.  More detail on AWS credentials with Terraform can be found [here](https://www.terraform.io/docs/providers/aws/index.html#authentication).

## Contribution

If you'd like to help build out more templates or correct/improve existing ones, please let me know.  I've started to build these ad-hoc as customers asked for them, so any help would be appreciated.