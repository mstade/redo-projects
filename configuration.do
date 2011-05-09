exec > $3

cat<<EOF
# Name of the ignore file for your scm
scmignore=".gitignore"

# Name of project config file
project="project.conf"

# Network connection timeout in seconds
timeout=10

# The base url to use for grabbing project scripts
baseurl="https://github.com/mstade/redo-projects/raw/master"


#### Generated functions ###################################

ignore() {
    if [ -e "\$scmignore" ]
    then
        if [ \$(egrep -c "/^\$1$/" "\$scmignore") == 0 ]
        then
            echo "\$1" >> "\$scmignore"
        fi
    fi
}

autoclean() {
    if [ -e clean.do ]
    then
        if [ \$(egrep -c "/redo \$1.clean$/" clean.do) == 0 ]
        then
            echo "\$(echo "[ -e \$1 ] && redo \$1.clean" | cat - clean.do)" > clean.do
            ignore \$1
        fi
    else
        echo "rm -rf *.redo*.tmp" >> clean.do
        echo "rm -rf default.clean.do" >> clean.do
        echo "rm -rf clean.do" >> clean.do
        
        if [ ! -e default.clean.do ]
        then
            echo "rm -rf \\\$1 2> /dev/null" > default.clean.do
        fi

        ignore clean.do
        ignore default.clean.do

        autoclean \$1
    fi
}

info() {
    printf "\e[1;34m# \e[1;30m"
    "\$@"
    printf "\e[m"
}

error() {
    printf "\e[1;31m"
    echo "# \$@"
    printf "\e[m"
    exit 1
}

download() {
    for source in "\$1"
    do
        target="\${2:-\${source##*/}}"

        local="\${source##\$baseurl/}"

        if [ -e "\$local" ]
        then
            ln -s "\$local" "\$target"
        else
            info echo "Download \$source => \$target"
            curl --connect-timeout "\$timeout" --create-dir -#fSLko "\$target" "\$source"
        fi
        
        if [ "$3" != "noclean" ]
        then
            ignore "\$target"
            autoclean "\$target"
        fi
    done
}

parseconf() {
    if [ ! -e yaml2sh ]
    then
        download "https://github.com/mstade/shelp/raw/master/yaml2sh"
        chmod +x yaml2sh
    fi

    if [ -e "\$project" ]
    then
        eval "\$(./yaml2sh \$project)"
    else
        error "Project configuration does not exist"
    fi
}
EOF

source "$3"
autoclean configuration

if [ ! -e project.do ]
then
    echo "$(cat <<EOF
        exec >&2

        if [ ! -e configuration ]
        then
            error "Can't find configuration, please 'redo configuration'"
        fi
        
        source configuration
        [ -e "\$project" ] && parseconf

        while [ -z "\$type" ]
        do
            read -p "# Project template: " type
        done

        download "\$baseurl/\$type/project.do"

        rm setup.do
        redo project
    )" > setup.do

    ignore setup.do
    autoclean setup.do

    info echo "Configuration complete, please 'redo setup'" >&2
fi
