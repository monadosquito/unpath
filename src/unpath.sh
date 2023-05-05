helpMsg="\
The unpath tool is to expand file paths into their contents.

unpath
    [-d | --document-format <document_format>]
    [-h | --help]
    <root_directory_path>
    [<document_path>]

Print a <document_path> file with each file path marker \
appended with decorated contents of the file \
read from a <root_directory_path> directory \
by a <file_path> path.

PREDEFINED DOCUMENT FORMATS

Markdown
    inserted file contents prefix -- "'```<<root_directory_path>first_file_extension>'"
    inserted file contents suffix -- "'```'"
    file path markers                  -- <!-- \"<file_path>\" -->, \
<!-- '<file_path>' -->

-d, --document-format (Markdown)
    a predefined set of decorations to use

-h, --help (0)
    whether to print the help message and then exit\
"
noFlagOrOptErr () {
    echo "error: $1 flag or option undefined"
}
noFmtErr () {
    echo "error: $1 document format undefined"
}
noRootPathErr='<root_directory_path> argument not passed'
stdinDocMsg='document read from stdin...'

args=()
documentFormat=Markdown
help=0

while (( $# > 0 ))
do
    case $1 in
        -d | --document-format)
            documentFormat=$2
            shift
            shift
            ;;
        -h | --help)
            help=1
            echo "$helpMsg"
            exit 0
            ;;
        -* | --*)
            echo "$(noFlagOrOptErr "$1")"
            exit 1
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done
set -- "${args[@]}"

rootPath="${1:?$noRootPathErr}"
documentFormat=${documentFormat,,}
if (( $# == 1 ))
then
    echo "$stdinDocMsg"
    doc=$(tee)
else
    doc=$(cat "$2")
    docPath=$2
fi

paths=($(find $rootPath -type f))
fstPath=${paths[0]}
ext=${fstPath##*.}
case $documentFormat in
    markdown | md)
        pathPfx="<\!-- *['\"]"
        pathSfx="['\"] *-->"
        sfx='```'
        pfx="$sfx$ext"
        ;;
    *)
        echo "$(noFmtErr "$documentFormat")"
        exit 1
        ;;
esac
pathExpanded=$doc
for path in "${paths[@]}"
do
    pathMrk=$pathPfx$path$pathSfx
    pathExpanded=$(echo "$pathExpanded" \
                  | sed "\|$pathMrk|a $pfx\n$sfx" \
                  | sed "\|$pathMrk|N; \|\n|r $path"
                  )
done
echo "$pathExpanded"
