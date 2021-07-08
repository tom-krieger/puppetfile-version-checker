# Puppetfile Version Checker

Check your Puppetfile for outdated or deprecated Puppet Forge modules.

## Usage

The puppet-version-checker was tested with Ruby 2.7.0. 
Parsing of Puppetfiles might need some updates.

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

### Return code

`0` Everything ok
`1` wrong parmeters or help called
`3` deprecated modules found
`4` modules with newer versions found
`5` deprecated and newer versions found