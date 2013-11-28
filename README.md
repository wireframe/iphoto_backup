# iphoto_backup

> Every photo deserves to live in a folder on the filesystem and not 
> to be locked up in some cryptic and proprietary iPhoto metadata XML file.

iphoto_backup is a tool to simplify backups and archiving of your iPhoto images.

[Originally implemented as a Python script](https://github.com/wireframe/dotfiles/blob/628b982d9fc4e7b4cc9e6ca806cae81b541f9bbd/home/bin/iphoto_export.py)

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
