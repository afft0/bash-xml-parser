#!/bin/bash

# Bash xml reader
# Supported tags only, but attributes are also available
#
# Example of using:
# xmlPath=(recipe composition ingredient);
# ingredients=`parseXmlFile $TMP_DIR/filename "${xmlPath[@]}"`;
#

readXmlDom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
    local ret=$?
    TAG_NAME=${ENTITY%% *}
    ATTRIBUTES=${ENTITY#* }
    return $ret
}

# $1 - path to file, like /path/to/file
# $2 - xml-path array, like (Tag InnerTag InnerInnerTag InnerInnerInnerTag)
# output - string of values separated by commas, like "qwe,asd,zxc"
parseXmlFile() {
    local filePath="${1}"
    shift
    local path=("${@}")

    local lastIndex=0
    local current=0
    local values=''
    let "lastIndex=${#path[*]}-1"
    while readXmlDom; do
        if [[ $TAG_NAME = "${path[current]}" ]]; then
            if [[ $current -eq lastIndex ]]; then
                values=$values"\"$CONTENT\","
            else
                let "current=$current+1"
            fi
        elif [[ $current -eq 0 ]]; then
            continue;
        elif [[ $TAG_NAME = "/"${path[current-1]} ]]; then
            let "current=$current-1"
        fi
    done < $filePath

    echo ${values%?}
}
