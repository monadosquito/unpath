# Description

The `unpath` tool is to expand file paths into their contents.

```sh
unpath
    [-d | --document-format <document_format>]
    [-h | --help]
    <root_directory_path>
    [<document_path>]
```

## Features

- to print a \<document\_path\> file with each file path marker
appended with decorated contents of the file
read from a \<root\_directory\_path\> directory
by a \<file\_path\> path

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

# Convention

This tool follows the [convention](https://github.com/monadosquito/bem#convention)
followed by the [`bem` library](https://github.com/monadosquito/bem).

---

## Table 1

the predefined document formats

|Document format|Inserted file contents prefix                     |Inserted file contents suffix |Path markers                                      |
|---------------|--------------------------------------------------|------------------------------|--------------------------------------------------|
|Markdown       |` ```<<root_directory_path>first_file_extension> `|` ``` `                       |`<!-- "<file_path>" -->`, `<!-- '<file_path>' -->`|

## Table 2

the flag and options descriptions

|Flag or option           |Default value|Description                                    |
|-------------------------|-------------|-----------------------------------------------|
|`-d`, `--document-format`|`Markdown`   |a predefined set of decorations                |
|`-h`, `--help`           |`0`          |whether to print the help message and then exit|
