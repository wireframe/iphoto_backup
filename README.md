[![Build Status](https://travis-ci.org/wireframe/iphoto_backup.png?branch=master)](https://travis-ci.org/wireframe/iphoto_backup)
[![Coverage Status](https://coveralls.io/repos/wireframe/iphoto_backup/badge.png)](https://coveralls.io/r/wireframe/iphoto_backup)
[![Code Climate](https://codeclimate.com/github/wireframe/iphoto_backup/badges/gpa.svg)](https://codeclimate.com/github/wireframe/iphoto_backup)

# iphoto_backup

> Every photo deserves to live in a folder on the filesystem and not
> to be locked up in some cryptic and proprietary iPhoto metadata XML file.

iphoto_backup is a tool that simplifies backups and archiving of your iPhoto images.

## Installation

```bash
$ gem install iphoto_backup
```

## Usage

```bash
$ iphoto_backup

Processing Roll: Wedding Pics...
  copying /iphoto/file.png to /my/custom/backup.png
```

## Options

#### --filter [REGEX]

*aliased to -e*

Restrict exporting to only albums that match the given regular expression.  Albums that do not match the regex will be printed in the log output as well.

example:
```bash
$ iphoto_backup -e Summer


Processing Roll: Summer Pics...
  copying /iphoto/file.png to /my/custom/backup.png

Winter Pics does not match the filter: /Summer/
```

#### --albums

*aliased to -a*

Export iPhoto albums instead of events.

#### --output [/path/to/directory]

*aliased to -o*
*default to ~/Google Drive/Dropbox*

Customize the path for archiving photos.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[Originally implemented as a Python script](https://github.com/wireframe/dotfiles/blob/628b982d9fc4e7b4cc9e6ca806cae81b541f9bbd/home/bin/iphoto_export.py)
