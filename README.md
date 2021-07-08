# Puppetfile Version Checker

Check your Puppetfile for outdated or deprecated Puppet Forge modules.

## Usage

The puppet-version-checker was tested with Ruby 2.7.0.

### Requirements

* gem 'httparty'
* gem 'optparse'
* gem 'ostruct'

### Options

* `-p | --puppetfile` Full path to Puppetfile
* `-r | --report` Full path to report file. If no file is given, output is written to STDOUT
* `-u | --update` Update Puppetfile with new versions and comment deprecated modules. This option requires -o as the updated content will be written to a new file
* `-o | --output` Full path to the new Puppetfile

### Example

```bash
./puppetfile-version-checker -p /var/tmp/Puppetfile -r /var/tmp/report.txt 
```