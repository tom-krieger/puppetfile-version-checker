# Puppetfile Version Checker

Check your Puppetfile for outdated or deprecated Puppet Forge modules.

The Puppetfile version checker can create an updated Puppetfile with updated versions and commented deprecated modules. 
Or it creates just a report with deprecated modules and modules having newer versions available.
If there are modules in the Puppetfile which should not be removed in case of deprecation or get updated versions, 
these modules can be put in an exclude list.

The puppet-version-checker was tested with Ruby 2.7.0.
Parsing of Puppetfiles might need some updates.

## Requirements

* Ruby 2.7.0 (it's tested with Ruby 2.7.0)
* gem 'httparty'
* gem 'optparse'
* gem 'ostruct'

## Configuration file

```yaml
---
forge:
  url: https://forgeapi.puppet.com
  #proxy_url: x.x.x.x
  #proxy_port: 3128
  #proxy_user: a_user
  #proxy_pass: a_password
```

The `config.yaml` file has to be located in the same place as the Ruby script.
Currently the configuration file contains settings for the Forge API and for a proxy. 
The proxy needs at least the url and the port.

If there is no config.yaml found, the default values are used. This is using the well 
known Forge API URL and no proxy settings.

## Usage

```bash
./puppetfile-version-checker -p PuppeTfile
                   [-r report file] [-u]
                   [-o output updated Puppetfile (required with -u)]
                   [-e module-slug -e module-slug ...]
```

### Options

* `-p | --puppetfile` Full path to Puppetfile
* `-r | --report` Full path to report file. If no file is given, output is written to STDOUT
* `-u | --update` Update Puppetfile with new versions and comment deprecated modules. This option requires -o as the updated content will be written to a new file
* `-o | --output` Full path to the new Puppetfile
* `-e | --exclude` Module slugs not to update or comment on deprecation. The modules will be listed in the report with deprecation warning or new version.
* `-h | --help` You know ;)

### Examples

Create a new Puppetfile together with a report and exclude some mudules.
```bash
./puppetfile-version-checker -p Puppetfile -u
                             -o /var/tmp/Puppetfile.updated 
                             -r /var/tmp/report.txt
                             -e WhatsARanjit-node_manager
                             -e herculesteam-augeasproviders 
```

Just create a report on STDOUT.
```bash
./puppetfile-version-checker -p Puppetfile
```

### Return code

`0` Everything ok

`1` wrong options or help called

`3` deprecated modules found

`4` modules with newer versions found

`5` deprecated and newer versions found

## Limitations

Currently the checker works only with Puppet Forge and can not deal with private Puppet Module repositories.