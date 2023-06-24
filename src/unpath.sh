helpMsg="\
The unpath tool is to expand file paths into their contents.

{unpath | unpath {-i | --invert}}
    [--path-prefix <path_prefix>]
    [--path-suffix <path_suffix>]
    [--prefix <prefix>]
    [--suffix <prefix>]
    [-d | --document-format <document_format>]
    [-h | --help]
    [-s | --save]
    {<root_directory_path> [<document_path>] | [<document_path>]}

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

-i, --invert (0)
    whether to cancel a previous expanding

-s, --save (0)
    whether to save output into a <document_path> file instead of printing it\
"
noFlagOrOptErr () {
    echo "error: $1 flag or option undefined"
}
noFmtErr () {
    echo "error: $1 document format undefined"
}
noRootPathErr='<root_directory_path> argument not passed'
stdinDocMsg='document read from stdin...'
noDocPathErr='<document_path> argument not passed'

path () {
    pathPrefix=$1
    pathSuffix=$2
    suffix=$3
    doc=$4

    anyPathMrkPtrn="$pathPrefix.*$pathSuffix"
    echo "$doc" \
        | sed \
              --regexp-extended \
              --expression="\|$anyPathMrkPtrn|N" \
              --expression="s|($anyPathMrkPtrn)\n^\s*$|\1\n$suffix\n|" \
        | sed "\|$anyPathMrkPtrn|,\|^$suffix$|{\|$anyPathMrkPtrn|!d}"
}

args=()
documentFormat=Markdown
help=0
pathPrefix=''
pathSuffix=''
prefix=''
suffix=''
save=0
savePath=/dev/stdout
invert=0
docPathArgPos=2

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
            ;;
        -s | --save)
            save=1
            shift
            ;;
        -i | --invert)
            invert=1
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

documentFormat=${documentFormat,,}
if (( $invert == 1 ))
then
    docPathArgPos=1
else
    rootPath="${1:?$noRootPathErr}"
fi
if (( $save == 1 ))
then
    if (( $# == 1 && $invert == 0 ))
    then
        echo "$noDocPathErr"
        exit 1
    fi
    doc=$(cat "${!docPathArgPos}")
    savePath=${!docPathArgPos}
else
    rqdArgsNum=$(($docPathArgPos - 1))
    if [[ $# == ${!rqdArgsNum} ]]
    then
        echo "$stdinDocMsg"
        doc=$(tee)
    else
        doc=$(cat "${!docPathArgPos}")
    fi
fi

paths=($(find $rootPath -type f))
case $documentFormat in
    markdown | md)
        pathPfx="<\!-- *['\"]"
        pathSfx="['\"] *-->"
        sfx='```'
        pfx () {
            ext=$1

            echo "$sfx$ext"
        }
        ;;
    *)
        echo "$(noFmtErr "$documentFormat")"
        exit 1
        ;;
esac
: ${pathPrefix:="$pathPfx"}
: ${pathSuffix:="$pathSfx"}
if [[ -n $prefix ]]
then
    prefix () {
        echo "$prefix"
    }
else
    prefix () {
        ext=$1

        echo "$(pfx "$ext")"
    }
fi
: ${suffix:="$sfx"}

output=$(path "$pathPrefix" "$pathSuffix" "$suffix" "$doc")
if (( $invert == 0 ))
then
    mrkLclRoots=($(echo "$doc" \
                  | sed --quiet --regexp-extended \
                       "s|$pathPrefix(.*)$pathSuffix|\1|p"
                  )
                )
    mrkLclRoots=($(for mrkLclRootIx in "${!mrkLclRoots[@]}"
                   do
                       mrkLclRoot=${mrkLclRoots[$mrkLclRootIx]%%/*}
                       if [[ $mrkLclRoot == '*.*' ]]
                       then
                           echo noLclRoot
                       else
                           echo "$mrkLclRoot"
                       fi
                   done \
                  | sort --unique
                  )
                )
    for mrkLclRoot in "${mrkLclRoots[@]}"
    do
        for path in "${paths[@]}"
        do
            pathMrk=$pathPfx$path$pathSfx
            output=$(echo "$output" \
                    | sed "\|$pathMrk|a $prefix\n$suffix" \
                    | sed "\|$pathMrk|N; \|\n|r $path"
                    )
            if [[ $mrkLclRoot == noLclRoot ]]
            then
                lclPath=${path#*/}
                lclPath=${lclPath#*/}
            else
                lclPath=$mrkLclRoot${path##*/$mrkLclRoot}
            fi
            lclPathMrk=$pathPrefix$lclPath$pathSuffix
            pathExt=${path##*.}
            output=$(echo "$output" \
                    | sed "\|$lclPathMrk|a $(prefix "$pathExt")\n$suffix" \
                    | sed "\|$lclPathMrk|N; \|\n|r $path"
                    )
        done
    done
fi
echo "$output" > "$savePath"
