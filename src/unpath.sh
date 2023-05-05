helpMsg="\
The unpath tool is to expand file paths into their contents.

unpath
    [--path-prefix <path_prefix>]
    [--path-suffix <path_suffix>]
    [--prefix <prefix>]
    [--suffix <prefix>]
    [-d | --document-format <document_format>]
    [-h | --help]
    <root_directory_path>
    [<document_path>]

Print a <document_path> file
with each <file_path_prefix><local_file_path><file_path_suffix> file path marker \
prepended \
with a <prefix> prefix\
and appended \
with contents \
of the file, \
read \
from a <root_directory_path> directory \
by a <local_file_path> path, \
and a <suffix> suffix.

PREDEFINED DOCUMENT FORMATS

Markdown
    inserted file contents prefix -- "'```<<root_directory_path>first_file_extension>'"
    inserted file contents suffix -- "'```'"
    file path markers                  -- <!-- \"<local_file_path>\" -->, \
<!-- '<local_file_path>' -->

--path-prefix (<\!--.*['\"])
    a search pattern before a <local_file_path> path inside a file path marker

--path-suffix (['\"].*-->)
    a search pattern after a <local_file_path> path inside a file path marker

--prefix ("'```'"<<root_directory_path>first_file_extension>)
    text to prepend to inserted file contents

--suffix ("'```'")
    text to append to inserted file contents

-d, --document-format (Markdown)
    a predefined set of prefixes and suffixes to use

-h, --help (0)
    whether to print the help message and then exit
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
pathPrefix=''
pathSuffix=''
prefix=''
suffix=''

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
        --path-prefix)
            pathPrefix=$2
            shift
            shift
            ;;
        --path-suffix)
            pathSuffix=$2
            shift
            shift
            ;;
        --prefix)
            prefix=$2
            shift
            shift
            ;;
        --suffix)
            suffix=$2
            shift
            shift
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
: ${pathPrefix:="$pathPfx"}
: ${pathSuffix:="$pathSfx"}
: ${prefix:="$pfx"}
: ${suffix:="$sfx"}

fstMrkPath=$(echo "$doc" \
            | sed --quiet --regexp-extended \
                  "s|$pathPrefix(.*)$pathSuffix|\1|p" \
            | head -1
            )
fstLclRoot=${fstMrkPath%%/*}
pathExpanded=$doc
for path in "${paths[@]}"
do
    pathMrk=$pathPfx$path$pathSfx
    pathExpanded=$(echo "$pathExpanded" \
                  | sed "\|$pathMrk|a $prefix\n$suffix" \
                  | sed "\|$pathMrk|N; \|\n|r $path"
                  )
    lclPath=$fstLclRoot${path##*/$fstLclRoot}
    lclPathMrk=$pathPfx$lclPath$pathSfx
    pathExpanded=$(echo "$pathExpanded" \
                  | sed "\|$lclPathMrk|a $prefix\n$suffix" \
                  | sed "\|$lclPathMrk|N; \|\n|r $path"
                  )
done
echo "$pathExpanded"
