# [Unreleased]

## Added

- Hidden files under a \<root\_directory\_path\> directory are ignored.
- Each \<local\_file\_path\> expansion \<prefix\> includes its \<local\_file\_path\> extension
when the predefined set of Markdown prefixes and suffixes is used.
- The path marker first directory names
differring from each other
are supported.
- The idempotent property is maintained.
- A previous [expanding](https://github.com/monadosquito/unpath#expand) can be cancelled
by passing the `--invert` (`-i`) flag.
- A document
with [expanded](https://github.com/monadosquito/unpath#expand) file paths can be [saved](https://github.com/monadosquito/unpath#save)
into a \<document\_path\> file by passing the `--save` (`-s`) flag.
- Some custom prefixes and suffixes can be set
by passing them as values of corresponding \<prefix\> or \<suffix\> options.
- A \<root\_directory\_path\> directory can be omitted from markers file paths.
- A \<document\_path\> file can be printed with each file path marker
appended with decorated contents of the file
read from a \<root\_directory\_path\> directory
by a \<local\_file\_path\> path.
