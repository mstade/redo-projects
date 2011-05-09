./configure.sh

eval "$(./yaml2sh project.conf)"

if [ ! -z "$locale" ]
then
    locale="-locale=$locale"
fi 

if [ ! -z "$metadata" ]
then
    metadata="-keep-as3-metadata+=$(echo "$metadata" | tr '\n' ',' | sed 's/,$//')"
fi

cat <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<actionScriptProperties analytics="false" mainApplicationPath="$NAME.as" projectUUID="$UUID" version="6">
    <compiler
        additionalCompilerArguments="$locale $METADATA"
        autoRSLOrdering="true"
        copyDependentFiles="false"
        fteInMXComponents="false"
        generateAccessible="false"
        htmlExpressInstall="true"
        htmlGenerate="false"
        htmlHistoryManagement="false"
        htmlPlayerVersionCheck="true"
        includeNetmonSwc="false"
        outputFolderPath="$bindir"
        sourceFolderPath="$srcdir"
        strict="true"
        targetPlayerVersion="$player"
        useApolloConfig="false"
        useDebugRSLSwfs="true"
        verifyDigests="true"
        warn="true">
        
        <compilerSourcePath/>
        
        <libraryPath defaultLinkType="0">
            <libraryPathEntry kind="4" path=""/>
EOF

for swc in $dependencies
do
    echo "       <!-- libraryPathEntry kind=\"3\" linkType=\"1\" path=\"$0\" useDefaultLinkType=\"false\"/ -->"
done

[ -d "$libdir" ] echo "<libraryPathEntry kind=\"1\" path=\"$libdir\"/>"

cat <<EOF
        </libraryPath>
        
        <sourceAttachmentPath/>
    </compiler>
   
    <applications>
        <application path="$name.as"/>
    </applications>
   
    <modules/>
   
    <buildCSSFiles/>

</actionScriptProperties>
EOF
