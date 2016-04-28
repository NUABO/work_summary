#!/bin/bash
#
#例如 sh  cov_code.sh -d /home/zhong/cloud_cov
#把文件从utf-8转为GBK,解决source insight中文乱码问题

FILE_DIR=/home/cloud

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
	iconv -f UTF-8 -t GBK $i -o $i
	#if [ $? -ne 0 ]; then
	#	echo "Fail to iconv -f UTF-8 -t GBK $i -o $i"
	#fi
done
