#!/bin/bash
#
#
FILE_DIR=/home/zhong/cloud_cov

SCRIPTFILE="$(basename "$0")"
usage()
{
    echo "Usage: $SCRIPTFILE [-d install_dir] [-h help]"
    echo "    -d  specify install directory. If skipped, default directory is \"/home/cloud\""
    echo "    -h  for help"
    exit 0
}

while getopts d:h OPTION
do
    case "$OPTION" in
        d) FILE_DIR="$OPTARG"
        ;;
        h) usage
        ;;
        \?) usage
        ;;
    esac
done

for i in `find $FILE_DIR  -name "*.py" `
do      
	echo $i
	iconv -f UTF-8 -t GBK $i -o /tmp/flag.py
	if [ $? -ne 0 ]; then
		rm -rf /tmp/flag.py
	else
		mv  /tmp/flag.py $i >/dev/null 2>&1
	fi
done
