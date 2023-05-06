# Description

The `unpath` tool is to expand file paths into their contents.

```sh
{unpath | unpath {-i | --invert}}
    [--path-prefix <file_path_prefix>]
    [--path-suffix <file_path_suffix>]
    [--prefix <prefix>]
    [--suffix <prefix>]
    [-d | --document-format <document_format>]
    [-h | --help]
    [-s | --save]
    {<root_directory_path> [<document_path>] | [<document_path>]}
```

## Features

- to be an isomorphism\
(`unpath <root_directory_path> <document_path> | unpath --invert` = id\
and `unpath --invert <document_path> | unpath <root_directory_path>` = id)
- to print a \<document\_path\> file
with each \<file\_path\_prefix\>\<local\_file\_path\>\<file\_path\_suffix\> file path marker
prepended
with a \<prefix\> prefix
and appended
with the contents
of the file,
read
from a \<root\_directory\_path\> directory
by a \<local\_file\_path\> path,
and a \<suffix\> suffix

## Installation flow

1. Obtain the derivation. ([?](#obtain))
2. Include it into a dependee. ([?](#include))

## Obtain

Fetch the source code of this tool
at an appropriate commit-ish from a repository.

## Include

1. Import the source code of this tool to get its derivation.
2. Include the derivation
into a `buildInputs` field of a `shell.nix` file of a dependee.

# Usage flow

1. Mark a \<document\_path\> file. ([?](#mark))
2. Expand paths. ([?](#expand))
3. Save output. ([?](#save))

# Mark

Mark the lines needed to be [expanded](#expand)
in a \<document\_path\> file by an appropriate [file path markers](#table-1)
containing a path  of a file
whose contents are to be [expanded](#expand) with.

## Notes

- Paths inside file path markers must be quoted.

# Expand

1. Enter the nix shell running the `nix-shell` command.
2. Run the `unpath <root_directory_path> <document_path>` command.

## Notes

- The `nix-shell` command must be run from a root directory of a dependee
or with a path to the `shell.nix` file as its argument.
- A first [expanding](#expand) can be cancelled
by passing the `--invert` (`-i`) flag.

## Hints

- Some custom prefixes and suffixes can be set directly
to avoid using a predefined set of them.

# Save

If \<document\_path\> file contents
with [expanded](#expand) paths are satisfying,
then run the command
again
but passing the `--save` (`-s`) flag
to save it into a \<document\_path\> file
with new contents.

# Convention

This tool follows the [convention](https://github.com/monadosquito/bem#convention)
followed by the [`bem` library](https://github.com/monadosquito/bem).

---

## Table 1

the predefined document formats

|Document format|Inserted file contents prefix                    |Inserted file contents suffix |Path markers                                                  |
|---------------|-------------------------------------------------|------------------------------|--------------------------------------------------------------|
|Markdown       |` ```<<root_directoy_path>first_file_extension> `|` ``` `                       |`<!-- "<local_file_path>" -->`, `<!-- '<local_file_path>' -->`|

## Table 2

the flag and options descriptions

|Flag or option           |Default value                                      |Description                                                                   |
|-------------------------|---------------------------------------------------|------------------------------------------------------------------------------|
|`--path-prefix`          |`<\!--.*['\"]`                                     |a search pattern before a \<local\_file\_path\> path inside a file path marker|
|`--path-suffix`          |`['\"].*-->`                                       |a search pattern after a \<local\_file\_path\> path inside a file path marker |
|`--prefix`               |` ```<<root_directory_path>_first_file_extension> `|text to prepend to inserted file contents                                     |
|`--suffix`               |` ``` `                                            |text to append to inserted file contents                                      |
|`-d`, `--document-format`|`Markdown`                                         |a predefined set of prefixes and suffixes to use                              |
|`-h`, `--help`           |`0`                                                |whether to print the help message and then exit                               |
|`-i`, `--invert`         |`0`                                                |whether to cancel a previous expanding                                        |
|`-s`, `--save`           |`0`                                                |whether to save output into a \<document\_path\> file instead of printing it  |
