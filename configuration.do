exec > "$3"

cat<<'EOF'
# Name of the ignore file for your scm
ignorefile=".gitignore"

# Name of project config file
project="project.conf"

# Network connection timeout in seconds
timeout=10

# The base url to use for grabbing project scripts
projects="https://github.com/mstade/redo-projects/raw/master"

# Url to yaml2sh
yaml2sh="https://github.com/mstade/shelp/raw/master/yaml2sh"


############################################################

ignore() {
    if [ -e "$ignorefile" ]
    then
        while read line
        do
            [ "$line" == "$@" ] && return
        done < "$ignorefile"

        echo "$@" >> "$ignorefile"
    fi
}

autoclean() {

    if [ ! -e clean.do ]
    then
        echo "exec 2> /dev/null" > clean.do
        echo "rm -rf *.tmp" >> clean.do
        echo "rm -rf clean.do" >> clean.do
    fi
    
    target="rm -rf $@"

    while read line
    do
        [ "$line" == "$target" ] && return
    done < clean.do

    echo $target >> clean.do
    ignore "$@"
}

info() {
    eval "$@" | while read line
    do
        printf "\e[1;36m#\e[1;30m %s" "$line"
        echo
    done

    printf "\e[m"
}

input() {
    if [ -z "$2" ]
    then
        error "Input variable must be specified as second argument"
    fi

    if [ ! -z "$3" ]
    then
        default=" [$3]"
    fi

    printf "\e[1;35m#\e[1;30m $1$default: \e[m" >&2
    read "$2" >&2

    if [ -z "$2" ]
    then
        "$2"="$default"
    fi
}

error() {
    printf "\e[1;31m# " >&2
    echo "$@" >&2
    printf "\e[m" >&2
    exit 1
}

download() {
    for source in "$1"
    do
        target="${2:-${source##*/}}"

        local="${source##$projects/}"

        if [ -e "$local" ]
        then
            ln -s "$local" "$target"
        else
            info echo "Download $source => $target" >&2
            curl --connect-timeout "$timeout" --create-dir -#fSLko "$target" "$source" >&2
        fi
    done
}

parseconf() {
    if [ ! -e yaml2sh ]
    then
        download "$yaml2sh" && autoclean yaml2sh
        chmod +x yaml2sh
    fi

    if [ -e "$project" ]
    then
        eval "$(./yaml2sh $project)"
    else
        if [ -e "project.do" ]
        then
            error "No project configuration, please \'redo project\'"
        else
            error "No project specified, please \'redo configuration\'"
        fi
    fi
}
EOF

. "$3"
autoclean "$1$2" 

if [ ! -e project.do ]
then
    while [ -z "$type" ]
    do
        input "Project template" type
    done

    download "$projects/$type/project.do"
    info echo "Ready to \'redo project\'" >&2
fi
