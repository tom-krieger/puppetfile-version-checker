# Puppetfile Version Checker

Check your Puppetfile for outdated or deprecated Puppet Forge modules.

The Puppetfile version checker can create an updated Puppetfile with updated versions and commented deprecated modules. 
Or it creates just a report with deprecated modules and modules having newer versions available.
If there are modules in the Puppetfile which should not be removed in case of deprecation or get updated versions, 
these modules can be put in an exclude list.

The puppet-version-checker was tested with Ruby 2.7.0.
Parsing of Puppetfiles might need some updates.

### Requirements

* RUBY 2.7.0 (it's tested with Ruby 2.7.0)
* gem 'httparty'
* gem 'optparse'
* gem 'ostruct'

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

### Example

```bash
./puppetfile-version-checker -p Puppetfile -u
                             -o Puppetfile.updated 
                             -r report.txt
                             -e WhatsARanjit-node_manager
                             -e herculesteam-augeasproviders 
```

### Return code

`0` Everything ok

`1` wrong parmeters or help called

`3` deprecated modules found

`4` modules with newer versions found

`5` deprecated and newer versions found
