#!/usr/bin/env bash

function __cmd_cli() {
        #$COMP_CWORD��ϵͳ�Զ���������ʾ��ǰ����������� 0��ʾ��һ�����ʣ�Ҳ����bsu��  
    case $COMP_CWORD in
    0)  #������ɸ�������ﲻ��Ҫ����  
        ;;
    1|*)  #�������Ѿ���ɣ����￪ʼ����һ��������  
        #${COMP_WORDS[0]}�Ǹ��������������о���bsu 
        if [ -z "${COMP_WORDS[COMP_CWORD]}" ]
        then
                COMP_WORDS[$COMP_CWORD]="\*"
        fi
        COMPREPLY=( $(eval /root/cli.py ${COMP_WORDS[*]}))
        ;;
    esac
}

complete -F __cmd_cli cli
