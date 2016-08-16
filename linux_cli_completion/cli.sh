#!/usr/bin/env bash

function __cmd_cli() {
        #$COMP_CWORD是系统自动变量，表示当前命令单词索引。 0表示第一个单词，也就是bsu。  
    case $COMP_CWORD in
    0)  #仍在完成根命令，这里不需要处理  
        ;;
    1|*)  #根命令已经完成，这里开始补充一级主命令  
        #${COMP_WORDS[0]}是根命令，在这个例子中就是bsu 
        if [ -z "${COMP_WORDS[COMP_CWORD]}" ]
        then
                COMP_WORDS[$COMP_CWORD]="\*"
        fi
        COMPREPLY=( $(eval /root/cli.py ${COMP_WORDS[*]}))
        ;;
    esac
}

complete -F __cmd_cli cli
