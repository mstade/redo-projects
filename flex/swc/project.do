redo-always
redo-ifchange configuration
source configuration

if [ -e project ]
then
    parseconf
else
    echo "## Project information"
    echo "type: flex/swc"
        
    input "Name" name "${PWD##*/}"
    echo "name: $name"
        
    input "Locale" locale "${LANG%%.*}"
    echo "locale: $locale"
        
    input "Player version: " version "10.1.1"
    echo "player: $version"
    
    echo

    echo "## Compiler directives"
    echo "compiler: compc"
    echo "srcdir: src"
    echo "target: target"
fi


#for dep in .actionScriptProperties.do .flexLibProperties.do .project.do
#do
#    [ ! -e "$dep" ] && download "$projects/flex/swc/$dep"
#    redo-ifchange "$dep"
#done
#
#for dir in "${target:=target}" "${srcdir:=src}" "$srcdir/main" "$srcdir/test" "$libdir"
#do
#    if [ ! -z "$dir" ]
#    then
#        mkdir -p "$dir"
#    fi
#done
