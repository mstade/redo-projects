exec >&2

if [ ! -e project.conf ]
then
    echo "## Project information" > project.conf
    echo "type: flex/swc" >> project.conf
        
    read -p "Name? [${PWD##*/}]: " name
    echo "name: ${name:-${PWD##*/}}" >> project.conf
        
    read -p "Locale? [${LANG%%.*}]: " locale
    echo "locale: ${locale:-${LANG%%.*}}" >> project.conf
        
    read -p "Player version? [10.1.0]: " version
    echo "player: ${version:-10.1.0}" >> project.conf
    
    echo "" >> project.conf

    echo "## Compiler directives" >> project.conf
    echo "compiler: compc" >> project.conf
    echo "srcdir: src" >> project.conf
    echo "bindir: bin" >> project.conf
fi

redo-ifchange configuration
source configuration

parseconf

for dep in .actionScriptProperties.do .flexLibProperties.do .project.do
do
    [ ! -e "$dep" ] && download "$baseurl/flex/swc/$dep"
    redo-ifchange "$dep"
done

for dir in "${bindir:=bin}" "${srcdir:=src}" "$libdir" 
do
    if [ ! -z "$dir" ]
    then
        [ ! -d "$dir" ] && mkdir "$dir"
    fi
done
