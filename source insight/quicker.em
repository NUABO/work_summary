/******************************************************************************

  �� �� ��   : Quicker.em
  �� �� ��   : 2.0.3
  ��    ��   : lushengwen
  ��������   : 2002��5��16��
  ��������   : ��̸������ߣ��ܴ�����߱��Ч�ʺʹ�������
  �޸���ʷ   :
  1.��    ��   : 2002��5��16��
    ��    ��   : lushengwen
    �޸�����   : �����ļ�

  2.��    ��   : 2002��6��18��
    ��    ��   : lushengwen
    �޸�����   : �����˿鹦�ܵ�

  3.��    ��   : 2002��7��2��
    ��    ��   : lushengwen
    �޸�����   : �����˺���û���������ʱ��ͷ˵����û���������BUG��ͬʱ֧��
                 ��C���Եĳ���ں�����ӡ���ܣ���ǰֻ֧��C++,�޸���C++ע�͸�
                 ΪCע�͵ĺ���

  4.��    ��   : 2002��7��4��
    ��    ��   : lushengwen
    �޸�����   : �޸��˺���ͷ���ļ�ͷ�Ĺ�����������Щsi�汾�в���������ʾ��
                 ����

  5.��    ��   : 2002��7��6��
    ��    ��   : lushengwen
    �޸�����   : �����˶�C���������֧��

  6.��    ��   : 2004��12��27��
    ��    ��   : lushengwen
    �޸�����   : �޸���CPLUSPLUS������÷�ʽ,�����˰�Ȩ˵���д���ط�

  7.��    ��   : 2006��8��5��
    ��    ��   : lushengwen
    �޸�����   : �������Զ�����׮�����Ĺ��ܣ��ܹ�����ͷ�ļ���.c�ļ��Զ�����
			     ��׼��׮�������޸�С�����ո�ʽ���Ϲ淶
			     
  8.��    ��   : 2006��8��7��
    ��    ��   : lushengwen
    �޸�����   : ���Ӻ���������ͳ�ƹ��ܣ������˽�ÿ�������Ĵ��뺯�������ڵ�
                 Ԫ���Բο�

  9.��    ��   : 2006��8��26��
    ��    ��   : lushengwen
    �޸�����   : ���Ӵ����߶�����������

  10.��    ��   : 2010��3��2��
    ��    ��   : lushengwen
    �޸�����   : ͳһ�߶˵�quicker�汾

  11.��    ��   : 2010��3��3��
    ��    ��   : lushengwen
    �޸�����   : ����Comware��̹淶֧�֣��ļ�ͷ�ͺ���ͷ��Comware��̹淶һ��
                 ���Ӻ���������IN��OUT������κͳ��ι��ܣ���������뵱ǰ���ӱ��
                 һ�£�·����Ϊ���·����source insight������Ҫ�����ڴ�����ͼ��
                 λ�ã����罫���̽����ڴ�����ͼ\l00619_V3R3_CodeView\
    
******************************************************************************/


/*****************************************************************************
	Storwareƽ̨ �޶���¼
	
1������storwareƽ̨�淶�޸����ⵥע�͸�ʽ��

2�����ӵ��д����޸�ʱ��ע�͹���
	autoExpand��"ao"/"mo"���
	
3������ѡ�д����ע��/��ע�͹���
	��CommentSelection����Ҫ���������ȼ���

4��������һ��ɾ��һ�������ַ����� ��
   ��Ҫ��SuperBackSpace���󶨵�BackSpace��	

5������Storwareƽ̨��־������淶������־/��������Ϣ����ı�׼����
	autoExpand��"item"���

6������storwareƽ̨UT���Ժ�����׼����ģ��
	autoExpand��"utf"���

7��(2010/10/12 by h05000)����Storware �ⲿ�ӿں���ͷע��
	autoExpand��"ofu"����;

8������"H3C�洢�����̹淶V2.0.doc"���¡�

9�����Storware ST���ͷ�ļ����ӿڡ������ı�׼����

******************************************************************************/



/*****************************************************************************
 �� �� ��  : AutoExpand
 ��������  : ��չ������ں���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸�

*****************************************************************************/
macro AutoExpand()
{
    //������Ϣ
    // get window, sel, and buffer handles
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.lnFirst != sel.lnLast) 
    {
        /*�������*/
        BlockCommandProc()
    }
    if (sel.ichFirst == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    nVer = 0
    nVer = GetVersion()
    /*ȡ���û���*/
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    // get line the selection (insertion point) is on
    szLine = GetBufLine(hbuf, sel.lnFirst);
    // parse word just to the left of the insertion point
    wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
    ln = sel.lnFirst;
    chTab = CharFromAscii(9)
        
    // prepare a new indented blank line to be inserted.
    // keep white space on left and add a tab to indent.
    // this preserves the indentation level.
    chSpace = CharFromAscii(32);
    ich = 0
    while (szLine[ich] == chSpace || szLine[ich] == chTab)
    {
        ich = ich + 1
    }
    szLine1 = strmid(szLine,0,ich)
    szLine = strmid(szLine, 0, ich) # "    "
    
    sel.lnFirst = sel.lnLast
    sel.ichFirst = wordinfo.ich
    sel.ichLim = wordinfo.ich

    /*�Զ���ɼ������ƥ����ʾ*/
    wordinfo.szWord = RestoreCommand(hbuf,wordinfo.szWord)
    sel = GetWndSel(hwnd)
    if (wordinfo.szWord == "pn") /*���ⵥ�ŵĴ���*/
    {
        DelBufLine(hbuf, ln)
        AddPromblemNo()
        AddPNDescription()
        return
    }
    /*��������ִ��*/
    else if (wordinfo.szWord == "config" || wordinfo.szWord == "co")
    {
        DelBufLine(hbuf, ln)
        ConfigureSystem()
        return
    }
    else if (wordinfo.szWord == "review" || wordinfo.szWord == "re")
    {
        DelBufLine(hbuf, ln)
        ConfigureCodeReview()
        return
    }
    /*�޸���ʷ��¼����*/
    else if (wordinfo.szWord == "hi")
    {
        DelBufLine(hbuf, ln)
        InsertHistory(hbuf,ln,language)
        return
    }
    else if (wordinfo.szWord == "abg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseAdd()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "dbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseDel()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "mbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseMod()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }     
    /* add by h05000 for storware log/error item */
    else if (wordinfo.szWord == "item")	
    {
        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine, 0, wordinfo.ich)
    	newln = FuncStorwareItem(hbuf, ln, szLeft) 
    	return
 
    }
    /* add by h05000 for storware UTC */
    else if (wordinfo.szWord == "utc")	
    {
        DelBufLine(hbuf,ln)
        
        szFuncName = Ask("�����뱻�⺯����:")
        UtcFuncHead(hbuf, ln, szFuncName)
        return

	} 
    else if (wordinfo.szWord == "stifi")
    {
        DelBufLine(hbuf, ln)

        /* ����python�ļ���ʽͷ */
        CreatePythonCommonNewFile()
        return
    } 
    else if (wordinfo.szWord == "stcfi")
    {
        DelBufLine(hbuf, ln)

        /* ��������ͷ�ļ� */
        CreateStNewFile()
        return
    } 
    /* py ���ܺ��� */
    else if (wordinfo.szWord == "stfu")
    {
        DelBufLine(hbuf, ln)
        szFuncName = Ask("�����뺯������:")
        CreateStPyFunc (hbuf, ln, szFuncName, szMyName) 
        return
    } 
    /* add by h05000 for storware STC */
    else if (wordinfo.szWord == "stc")
    {
        DelBufLine(hbuf,ln)
                
        szSid = Ask("������ϵͳ������ID,��ʽ��\"st_xxx_001\":")
        StcFuncHead(hbuf, ln, szSid)
        return

	} 
    /* add by h05000 for storware STC */
    else if (wordinfo.szWord == "stdbg")
    {
        DelBufLine(hbuf,ln)
        CreateStPyDebug()
        return
	} 

    
    if(language == 1)
    {
        ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
    else
    {
        ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
}

/*****************************************************************************
 �� �� ��  : ExpandProcEN
 ��������  : Ӣ��˵������չ�����
 �������  : szMyName  �û���
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
  
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    /*Ӣ��ע��*/
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        while(wordinfo.ichLim + kk < lineLen)
        {
            if((szCurLine[wordinfo.ichLim + kk] != " ")||(szCurLine[wordinfo.ichLim + kk] != "\t")
            {
                msg("you must insert /* at the end of a line");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("Please input comment")
        DelBufLine(hbuf, ln)
        szLeft = cat( szLeft, " ")
        /* ��ÿ����ʾ�ַ����ó�80 (by h05000) */
        CommentContent(hbuf,ln,szLeft,szContent,1,80)            
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "while" || szCmd == "wh")
    {
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "else" || szCmd == "el")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfdef()
        return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifndef
    {
        DelBufLine(hbuf, ln)
        InsIfndef()
        return
    }
    else if (szCmd == "#if")
    {
        DelBufLine(hbuf, ln)
        InsertPredefIf()
        return
    }
    else if (szCmd == "cpp")
    {
        DelBufLine(hbuf, ln)
        InsertCPP(hbuf,ln)
        return
    }    
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ()");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
    else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " (; ; )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("Please input loop variable")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " (@szVar@ = ; @szVar@ ; @szVar@++)")
    }
    else if (szCmd == "fo")
    {
        SetBufSelText(hbuf, "r (i = 0; i < ; i++)")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
        if(strlen(symbol) > 0)
        {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = strstr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
             }
             InsBufLine(hbuf, nIdx + 1, "    ULONG i = 0;");        
         }
    }
    else if (szCmd == "switch" )
    {
        nSwitch = ask("Please input the number of case")
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
    else if (szCmd == "do")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ();")
    }
    else if (szCmd == "case" )
    {
        SetBufSelText(hbuf, " :")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine@" # "break;")
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "}")
    }
    else if (szCmd == "stru" )
    {
	    InsertstructelemProc(hbuf,szLine1)
    }
    else if (szCmd == "struct" || szCmd == "st")
    {
        DelBufLine(hbuf, ln)
        szStructName = Ask("Please input struct name")
        InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@_struct");
        szStructName = toupper(szStructName);
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_t")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        szStructName = Ask("Please input enum name")
        InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@_enum");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_e")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "union" || szCmd == "un")
    {
        DelBufLine(hbuf, ln)
        //��ʾ��������������
        szUnionName = Ask("Please input union name")
        InsBufLine(hbuf, ln, "@szLine1@typedef union @szUnionName@_union");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        szUnionName = cat(szUnionName,"_u")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szUnionName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi")
    {
        DelBufLine(hbuf, ln)
        szVersion = getreg(VERSION)
        if(strlen(szVersion) == 0)
        {
    	    szVersion = Ask("Please input project code:")
    	    setreg(VERSION, szVersion)
        }
        InsertFileHeaderEN(hbuf, 0, szMyName, "", 1, szVersion)
        return
    }
    else if (szCmd == "func" || szCmd == "fu")
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("Please input function name")
        FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab")
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
        return
    }
    else if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* Promblem Number: @szQuestion@     Author:@szMyName@,   Date:@sz@-@sz1@-@sz3@ ");
        szContent = Ask("Description")
        szLeft = cat(szLine1,"   Description    : ");
        if(strlen(szLeft) > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1,80)
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        CreateFunctionDef(hbuf,szMyName,1)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)

        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "stub")
    {
        DelBufLine(hbuf, ln)
        /*����C���Ե�ͷ�ļ�*/
        CreateFunctionStub(hbuf,szMyName,0)
        return
    }
    else if (szCmd == "stat")
    {
        DelBufLine(hbuf, ln)
        CreateCodeStatistic()
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Add by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Add by @szMyName@, @sz@-@sz1@-@sz3@ */");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END */");        
        }
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Delete by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Delete by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln + 0)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END */");        
        }
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modify by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modify by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END :@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END ");        
        }
        return
    }
    else if (szCmd == "ao")	/* add by h05000 for storware */
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ich)
        DelBufLine(hbuf, ln)
        
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            szLeft = cat(szLeft, "/* Add by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */")
        }
        else
        {
            szLeft = cat(szLeft, "/* Add by @szMyName@, @sz@-@sz1@-@sz3@ */")
        }

        InsBufLine(hbuf, ln, "@szLeft@");  
		
        return
    }
    else if (szCmd == "mo")		/* add by h05000 for storware */
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ich)
        DelBufLine(hbuf, ln)
        
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            szLeft = cat(szLeft, "/* Modify by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */")
        }
        else
        {
       	    szLeft = cat(szLeft, "/* Modify by @szMyName@, @sz@-@sz1@-@sz3@ */")
        }

        InsBufLine(hbuf, ln, "@szLeft@");  
        return
    }
    else
    {
        SearchForward()
//            ExpandBraceLarge()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}


/*****************************************************************************
 �� �� ��  : ExpandProcCN
 ��������  : ����˵������չ����
 �������  : szMyName  
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)

    //����ע��
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("�ұ߿ռ�̫С,�����µ���")
            stop 
        }        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        /*ע��ֻ������β������ע�͵����ô���*/
        while(wordinfo.ichLim + kk < lineLen)
        {
            if(szCurLine[wordinfo.ichLim + kk] != " ")
            {
                msg("ֻ������β����");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("������ע�͵�����")
        DelBufLine(hbuf, ln)
        szLeft = cat( szLeft, " ")
        CommentContent(hbuf,ln,szLeft,szContent,1,80)            
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    /* ��quicker�Զ����ɵ�ռλ��#���� (by h05000) */
    else if (szCmd == "while" || szCmd == "wh")
    {
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "else" || szCmd == "el")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfdef()
        return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfndef()
        return
    }
    else if (szCmd == "#if")
    {
        DelBufLine(hbuf, ln)
        InsertPredefIf()
        return
    }
    else if (szCmd == "cpp")
    {
        DelBufLine(hbuf, ln)
        InsertCPP(hbuf,ln)
        return
    }    
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ()");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
    else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " (; ; )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("������ѭ������")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " (@szVar@ = ; @szVar@ ; @szVar@++)")
    }
    else if (szCmd == "fo")
    {
        SetBufSelText(hbuf, "r (i = 0; i < ; i++)")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
        if(strlen(symbol) > 0)
        {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = strstr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
            }
            InsBufLine(hbuf, nIdx + 1, "    ULONG i = 0;");        
        }
    }
    else if (szCmd == "switch" || szCmd == "sw")
    {
        nSwitch = ask("������case�ĸ���")
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
    else if (szCmd == "do")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ();")
    }
    else if (szCmd == "case" || szCmd == "ca" )
    {
        SetBufSelText(hbuf, " :")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine@" # "break;")
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "}")
    }
    else if (szCmd == "stru" )
    {
	    InsertstructelemProc(hbuf,szLine1)
    }
    else if (szCmd == "struct" || szCmd == "st" )
    {
        DelBufLine(hbuf, ln)
        szStructName = Ask("������ṹ��:")
        InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@_struct");
        //szStructName = toupper(szStructName);
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@      ");
        szStructName = cat(szStructName,"_t")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        //��ʾ����ö������ת��Ϊ��д
        szStructName = Ask("������ö����:")
        InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@_enum");
        //szStructName = toupper(szStructName);
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        szStructName = cat(szStructName,"_e")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "union" || szCmd == "un")
    {
        DelBufLine(hbuf, ln)
        //��ʾ��������������
        szUnionName = Ask("������������:")
        InsBufLine(hbuf, ln, "@szLine1@typedef union @szUnionName@_union");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        szUnionName = cat(szUnionName,"_u")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szUnionName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi" )
    {
        DelBufLine(hbuf, ln)
        /*�����ļ�ͷ˵��*/
        szVersion = getreg(VERSION)
        if(strlen(szVersion) == 0)
        {
    	    szVersion = Ask("��������Ŀ����:")
    	    setreg(VERSION, szVersion)
        }
        InsertFileHeaderCN(hbuf, 0, szMyName, "", 1, szVersion)
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        /*����C���Ե�ͷ�ļ�*/
        CreateFunctionDef(hbuf,szMyName,0)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)
        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "stub")
    {
        DelBufLine(hbuf, ln)
        /*����C���Ե�ͷ�ļ�*/
        CreateFunctionStub(hbuf,szMyName,0)
        return
    }
    else if (szCmd == "stat")
    {
        DelBufLine(hbuf, ln)
        CreateCodeStatistic()
        return
    }
    else if ((szCmd == "func" || szCmd == "fu")
    		  ||(szCmd == "ifunc" || szCmd == "ifu")  // ����Storwareƽ̨�ⲿ�ӿڵĺ���ͷ
    		)
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            /*����2.1���si����ǷǷ�symbol�ͻ��ж�ִ�У��ʸ�Ϊ�Ժ�һ��
              �Ƿ��С��������ж��Ƿ����º���*/
            if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                /*���Ѿ����ڵĺ���*/
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0, 0)
                    return
                }
            }
        }
        szFuncName = Ask("�����뺯������:")
        /*���º���*/

        if (szCmd == "ifunc" || szCmd == "ifu")
        {
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1, 1)  // ���ɶ���ӿڵĺ���ͷ˵��
		}
        else
        {
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1, 0)
        }
    }
    else if (szCmd == "tab") /*��tab��չΪ�ո�*/
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
    }
    else if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@-@sz1@-@sz3@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        if(strlen(szLeft) > 70)
        {
            Msg("�ұ߿ռ�̫С,�����µ���")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1,80)
        return
    }
    else if (szCmd == "ab" || szCmd == "ab1")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Add by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Add by @szMyName@, @sz@-@sz1@-@sz3@ */");        
        }
        return
    }
    else if (szCmd == "ae" || szCmd == "ae1")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END */");        
        }
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Delete by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Delete by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln + 0)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END */");        
        }
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modify by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modify by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END */");        
        }
        return
    }
    else if (szCmd == "ao")		/* add by h05000 for storware */
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ich)
        DelBufLine(hbuf, ln)
        
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            szLeft = cat(szLeft, "/* Add by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */")
        }
        else
        {
            szLeft = cat(szLeft, "/* Add by @szMyName@, @sz@-@sz1@-@sz3@ */")
        }


        InsBufLine(hbuf, ln, "@szLeft@");   
        return
    }
    else if (szCmd == "mo")		/* add by h05000 for storware */
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ich)
        DelBufLine(hbuf, ln)
        
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            szLeft = cat(szLeft, "/* Modify by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */")
        }
        else
        {
            szLeft = cat(szLeft, "/* Modify by @szMyName@, @sz@-@sz1@-@sz3@ */")
        }
        InsBufLine(hbuf, ln, "@szLeft@");        

    }
    else
    {
        SearchForward()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : BlockCommandProc
 ��������  : ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro BlockCommandProc()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(sel.lnFirst > 0)
    {
        ln = sel.lnFirst - 1
    }
    else
    {
        stop
    }
    szLine = GetBufLine(hbuf,ln)
    szLine = TrimString(szLine)
    if(szLine == "while" || szLine == "wh")
    {
        InsertWhile()   /*����while*/
    }
    else if(szLine == "do")
    {
        InsertDo()   //����do while���
    }
    else if(szLine == "for")
    {
        InsertFor()  //����for���
    }
    else if(szLine == "if")
    {
        InsertIf()   //����if���
    }
    else if(szLine == "el" || szLine == "else")
    {
        InsertElse()  //����else���
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifd") || (szLine == "#ifdef"))
    {
        InsIfdef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifn") || (szLine == "#ifndef"))
    {
        InsIfndef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }    
    else if (szLine == "abg")
    {
        InsertReviseAdd()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "dbg")
    {
        InsertReviseDel()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "mbg")
    {
        InsertReviseMod()
        DelBufLine(hbuf, ln)
        stop
    }
    else if(szLine == "#if")
    {
        InsertPredefIf()
        DelBufLine(hbuf,ln)
        stop
    }
    DelBufLine(hbuf,ln)
    SearchForward()
    stop
}

/*****************************************************************************
 �� �� ��  : RestoreCommand
 ��������  : ��������ָ�����
 �������  : hbuf   
             szCmd  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RestoreCommand(hbuf,szCmd)
{
    if(szCmd == "ca")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "case"
    }
    else if(szCmd == "sw") 
    {
        SetBufSelText(hbuf, "itch")
        szCmd = "switch"
    }
    else if(szCmd == "el")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "else"
    }
    else if(szCmd == "wh")
    {
        SetBufSelText(hbuf, "ile")
        szCmd = "while"
    }
    return szCmd
}

/*****************************************************************************
 �� �� ��  : SearchForward
 ��������  : ��ǰ����#
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchForward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Forward
}

/*****************************************************************************
 �� �� ��  : SearchBackward
 ��������  : �������#
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchBackward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Backward
}

/*****************************************************************************
 �� �� ��  : InsertFuncName
 ��������  : �ڵ�ǰλ�ò��뵫ǰ������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFuncName()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    symbolname = GetCurSymbol()
    SetBufSelText (hbuf, symbolname)
}

/*****************************************************************************
 �� �� ��  : strstr
 ��������  : �ַ���ƥ���ѯ����
 �������  : str1  Դ��
             str2  ��ƥ���Ӵ�
 �������  : ��
 �� �� ֵ  : 0xffffffffΪû���ҵ�ƥ���ַ�����V2.1��֧��-1�ʲ��ø�ֵ
             ����Ϊƥ���ַ�������ʼλ��
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro strstr(str1,str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if((len1 == 0) || (len2 == 0))
    {
        return 0xffffffff
    }
    while( i < len1)
    {
        if(str1[i] == str2[j])
        {
            while(j < len2)
            {
                j = j + 1
                if(str1[i+j] != str2[j]) 
                {
                    break
                }
            }     
            if(j == len2)
            {
                return i
            }
            j = 0
        }
        i = i + 1      
    }  
    return 0xffffffff
}


macro strchr(str1,chr)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    if(len1 == 0)
    {
        return 0xffffffff
    }
    while( i < len1)
    {
        if(str1[i] == chr)
        {
            return i
        }
        i = i + 1      
    }  
    return 0xffffffff
}

/*****************************************************************************
 �� �� ��  : InsertTraceInfo
 ��������  : �ں�������ںͳ��ڲ����ӡ,��֧��һ���ж����������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    symbol = GetSymbolLocationFromLn(hbuf, sel.lnFirst)
    InsertTraceInCurFunction(hbuf,symbol)
}

/*****************************************************************************
 �� �� ��  : InsertTraceInCurFunction
 ��������  : �ں�������ںͳ��ڲ����ӡ,��֧��һ���ж����������
 �������  : hbuf
             symbol
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTraceInCurFunction(hbuf,symbol)
{
    ln = GetBufLnCur (hbuf)
    symbolname = symbol.Symbol
    nLineEnd = symbol.lnLim
    nExitCount = 1;
    InsBufLine(hbuf, ln, "#if (VRP_VERSION_DEBUG == VRP_YES)")
    ln = ln + 1
    InsBufLine(hbuf, ln, "    DRV_DbgToIC(\"\\r\\n |@symbolname@() entry--- \");")
    ln = ln + 1
    InsBufLine(hbuf, ln, "#endif")
    ln = ln + 1
    fIsEnd = 1
    fIsNeedPrt = 1
    fIsSatementEnd = 1
    szLeftOld = ""
    while(ln < nLineEnd)
    {
        szLine = GetBufLine(hbuf, ln)
        iCurLineLen = strlen(szLine)
        
        /*�޳����е�ע�����*/
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //�����Ƿ���return���
/*        ret =strstr(szLine,"return")
        if(ret != 0xffffffff)
        {
            if( (szLine[ret+6] == " " ) || (szLine[ret+6] == "\t" )
                || (szLine[ret+6] == ";" ) || (szLine[ret+6] == "(" ))
            {
                szPre = strmid(szLine,0,ret)
            }
            SetBufIns(hbuf,ln,ret)
            Paren_Right
            sel = GetWndSel(hwnd)
            if( sel.lnLast != ln )
            {
                GetbufLine(hbuf,sel.lnLast)
                RetVal = SkipCommentFromString(szLine,1)
                szLine = RetVal.szContent
                fIsEnd = RetVal.fIsEnd
            }
        }*/
        //�����߿հ״�С
        nLeft = GetLeftBlank(szLine)
        if(nLeft == 0)
        {
            szLeft = "    "
        }
        else
        {
            szLeft = strmid(szLine,0,nLeft)
        }
        szLine = TrimString(szLine)
        iLen = strlen(szLine)
        if(iLen == 0)
        {
            ln = ln + 1
            continue
        }
        szRet = GetFirstWord(szLine)
//        if( (szRet == "if") || (szRet == "else")
        //�����Ƿ���return���
//        ret =strstr(szLine,"return")
        
        if( szRet == "return")
        {
            if( fIsSatementEnd == 0)
            {
                fIsNeedPrt = 1
		InsBufLine(hbuf, ln, "#if (VRP_VERSION_DEBUG == VRP_YES)")
		ln = ln + 1
                InsBufLine(hbuf,ln+1,"@szLeftOld@}")
                szEnd = cat(szLeft,"DRV_DbgToIC(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")
                InsBufLine(hbuf, ln, szEnd )
                InsBufLine(hbuf,ln,"@szLeftOld@{")
		ln = ln + 1
		InsBufLine(hbuf, ln, "#endif")
                nExitCount = nExitCount + 1
                nLineEnd = nLineEnd + 3
                ln = ln + 3
            }
            else
            {
                fIsNeedPrt = 0
		InsBufLine(hbuf, ln, "#if (VRP_VERSION_DEBUG == VRP_YES)")
		ln = ln + 1
                szEnd = cat(szLeft,"DRV_DbgToIC(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")
                InsBufLine(hbuf, ln, szEnd )
                nExitCount = nExitCount + 1
                nLineEnd = nLineEnd + 1
                ln = ln + 1
		InsBufLine(hbuf, ln, "#endif")
		ln = ln + 1
            }
        }
        else
        {
	        ret =strstr(szLine,"}")
	        if( ret != 0xffffffff )
	        {
	            fIsNeedPrt = 1
	        }
        }
        
        szLeftOld = szLeft
        ch = szLine[iLen-1] 
        if( ( ch  == ";" ) || ( ch  == "{" ) 
             || ( ch  == ":" )|| ( ch  == "}" ) || ( szLine[0] == "#" ))
        {
            fIsSatementEnd = 1
        }
        else
        {
            fIsSatementEnd = 0
        }
        ln = ln + 1
    }
    
    //ֻҪǰ���return����һ��}��˵�������Ľ�βû�з��أ���Ҫ�ټ�һ�����ڴ�ӡ
    if(fIsNeedPrt == 1)
    {
	InsBufLine(hbuf, ln, "#if (VRP_VERSION_DEBUG == VRP_YES)")
	ln = ln + 1
        InsBufLine(hbuf, ln,  "    DRV_DbgToIC(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")
	ln = ln + 1
	InsBufLine(hbuf, ln, "#endif")
        InsBufLine(hbuf, ln,  "")
    }
}

/*****************************************************************************
 �� �� ��  : GetFirstWord
 ��������  : ȡ���ַ����ĵ�һ������
 �������  : szLine
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFirstWord(szLine)
{
    szLine = TrimLeft(szLine)
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ") || (szLine[nIdx] == "\t") 
          || (szLine[nIdx] == ";") || (szLine[nIdx] == "(")
          || (szLine[nIdx] == ".") || (szLine[nIdx] == "{")
          || (szLine[nIdx] == ",") || (szLine[nIdx] == ":") )
        {
            return strmid(szLine,0,nIdx)
        }
        nIdx = nIdx + 1
    }
    return szLine
    
}

macro GetFirstKeyWord(szLine)
{
    
    szLine = TrimLeft(szLine)
    szline = cat(szline," ")
    iFlag = 0
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ") || (szLine[nIdx] == "\t") 
          || (szLine[nIdx] == ";") || (szLine[nIdx] == "(")
          || (szLine[nIdx] == ".") || (szLine[nIdx] == "{")
          || (szLine[nIdx] == ",") || (szLine[nIdx] == ":")
          || (AsciiFromChar (szLine[nIdx]) > 128 ))
        {
            szKey =  strmid(szLine,0,nIdx)
            if (szKey == "else" || iFlag == 1 )
            {
                 if (iFlag == 0)
                 {
                     szOldKey = szKey
                     iFlag = 1
                 }
                 nIdx = nIdx + 1
                 continue
            }
            else
            {            
                if (szOldKey == "else")
                {
                    if ( (szLine[nIdx-1] != "f") || (szLine[nIdx-1] != "i") )
                    {
                        return "else"
                    }
                    else
                    {
                        return "else if"
                    }
                }
                
                return szKey
            }
        }
        else 
        {
            if (iFlag == 1)
            {
                iFlag = 0
            }
        }
        nIdx = nIdx + 1
    }
    if (szOldKey == "else")
    {
        return "else"
    }
    return ""
    
}

/*****************************************************************************
 �� �� ��  : AutoInsertTraceInfoInBuf
 ��������  : �Զ���ǰ�ļ���ȫ����������ڼ����ӡ��ֻ��֧��C++
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AutoInsertTraceInfoInBuf()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)

    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        isCodeBegin = 0
        fIsEnd = 1
        isBlandLine = 0
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
		    	while (ichild < cchild)
				{
                    symbol = GetBufSymLocation(hbuf, isym)
    		        hsyml = SymbolChildren(symbol)
					childsym = SymListItem(hsyml, ichild)
                    ln = childsym.lnName 
                    isCodeBegin = 0
                    fIsEnd = 1
                    isBlandLine = 0
                    while( ln < childsym.lnLim )
                    {   
                        szLine = GetBufLine (hbuf, ln)
                        
                        //ȥ��ע�͵ĸ���
                        RetVal = SkipCommentFromString(szLine,fIsEnd)
        		        szNew = RetVal.szContent
        		        fIsEnd = RetVal.fIsEnd
                        if(isCodeBegin == 1)
                        {
                            szNew = TrimLeft(szNew)
                            //����Ƿ��ǿ�ִ�д��뿪ʼ
                            iRet = CheckIsCodeBegin(szNew)
                            if(iRet == 1)
                            {
                                if( isBlandLine != 0 )
                                {
                                    ln = isBlandLine
                                }
                                InsBufLine(hbuf,ln,"")
                                childsym.lnLim = childsym.lnLim + 1
                                SetBufIns(hbuf, ln+1 , 0)
                                InsertTraceInCurFunction(hbuf,childsym)
                                break
                            }
                            if(strlen(szNew) == 0) 
                            {
                                if( isBlandLine == 0 ) 
                                {
                                    isBlandLine = ln;
                                }
                            }
                            else
                            {
                                isBlandLine = 0
                            }
                        }
        		        //���ҵ������Ŀ�ʼ
        		        if(isCodeBegin == 0)
        		        {
            		        iRet = strstr(szNew,"{")
                            if(iRet != 0xffffffff)
                            {
                                isCodeBegin = 1
                            }
                        }
                        ln = ln + 1
                    }
                    ichild = ichild + 1
				}
		        SymListFree(hsyml)
	        }
            else if( ( symbol.Type == "Function") ||  (symbol.Type == "Method") )
            {
                ln = symbol.lnName     
                while( ln < symbol.lnLim )
                {   
                    szLine = GetBufLine (hbuf, ln)
                    
                    //ȥ��ע�͵ĸ���
                    RetVal = SkipCommentFromString(szLine,fIsEnd)
    		        szNew = RetVal.szContent
    		        fIsEnd = RetVal.fIsEnd
                    if(isCodeBegin == 1)
                    {
                        szNew = TrimLeft(szNew)
                        //����Ƿ��ǿ�ִ�д��뿪ʼ
                        iRet = CheckIsCodeBegin(szNew)
                        if(iRet == 1)
                        {
                            if( isBlandLine != 0 )
                            {
                                ln = isBlandLine
                            }
                            SetBufIns(hbuf, ln , 0)
                            InsertTraceInCurFunction(hbuf,symbol)
                            InsBufLine(hbuf,ln,"")
                            break
                        }
                        if(strlen(szNew) == 0) 
                        {
                            if( isBlandLine == 0 ) 
                            {
                                isBlandLine = ln;
                            }
                        }
                        else
                        {
                            isBlandLine = 0
                        }
                    }
    		        //���ҵ������Ŀ�ʼ
    		        if(isCodeBegin == 0)
    		        {
        		        iRet = strstr(szNew,"{")
                        if(iRet != 0xffffffff)
                        {
                            isCodeBegin = 1
                        }
                    }
                    ln = ln + 1
                }
            }
        }
        isym = isym + 1
    }
    
}

/*****************************************************************************
 �� �� ��  : CheckIsCodeBegin
 ��������  : �Ƿ�Ϊ�����ĵ�һ����ִ�д���
 �������  : szLine ���û�пո��ע�͵��ַ���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckIsCodeBegin(szLine)
{
    iLen = strlen(szLine)
    if(iLen == 0)
    {
        return 0
    }
    nIdx = 0
    nWord = 0
    if( (szLine[nIdx] == "(") || (szLine[nIdx] == "-") 
           || (szLine[nIdx] == "*") || (szLine[nIdx] == "+"))
    {
        return 1
    }
    if( szLine[nIdx] == "#" )
    {
        return 0
    }
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ")||(szLine[nIdx] == "\t") 
             || (szLine[nIdx] == "(")||(szLine[nIdx] == "{")
             || (szLine[nIdx] == ";") )
        {
            if(nWord == 0)
            {
                if( (szLine[nIdx] == "(")||(szLine[nIdx] == "{")
                         || (szLine[nIdx] == ";")  )
                {
                    return 1
                }
                szFirstWord = StrMid(szLine,0,nIdx)
                if(szFirstWord == "return")
                {
                    return 1
                }
            }
            while(nIdx < iLen)
            {
                if( (szLine[nIdx] == " ")||(szLine[nIdx] == "\t") )
                {
                    nIdx = nIdx + 1
                }
                else
                {
                    break
                }
            }
            nWord = nWord + 1
            if(nIdx == iLen)
            {
                return 1
            }
        }
        if(nWord == 1)
        {
            asciiA = AsciiFromChar("A")
            asciiZ = AsciiFromChar("Z")
            ch = toupper(szLine[nIdx])
            asciiCh = AsciiFromChar(ch)
            if( ( szLine[nIdx] == "_" ) || ( szLine[nIdx] == "*" )
                 || ( ( asciiCh >= asciiA ) && ( asciiCh <= asciiZ ) ) )
            {
                return 0
            }
            else
            {
                return 1
            }
        }
        nIdx = nIdx + 1
    }
    return 1
}

/*****************************************************************************
 �� �� ��  : AutoInsertTraceInfoInPrj
 ��������  : �Զ���ǰ����ȫ���ļ���ȫ����������ڼ����ӡ��ֻ��֧��C++
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AutoInsertTraceInfoInPrj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        szExt = toupper(GetFileNameExt(filename))
        if( (szExt == "C") || (szExt == "CPP") )
        {
            hbuf = OpenBuf (filename)
            if(hbuf != 0)
            {
                SetCurrentBuf(hbuf)
                AutoInsertTraceInfoInBuf()
            }
        }
        //�Զ�������ļ����ɸ�����Ҫ��
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemoveTraceInfo
 ��������  : ɾ���ú����ĳ���ڴ�ӡ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemoveTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(hbuf == hNil)
       stop
    symbolname = GetCurSymbol()
    symbol = GetSymbolLocationFromLn(hbuf, sel.lnFirst)
//    symbol = GetSymbolLocation (symbolname)
    nLineEnd = symbol.lnLim
    szEntry = "DRV_DbgToIC(\"\\r\\n |@symbolname@() entry--- \");"
    szExit = "DRV_DbgToIC(\"\\r\\n |@symbolname@() exit---:"
    ln = symbol.lnName
    fIsEntry = 0
    while(ln < nLineEnd)
    {
        szLine = GetBufLine(hbuf, ln)
        
        /*�޳����е�ע�����*/
        RetVal = TrimString(szLine)
        if(fIsEntry == 0)
        {
            ret = strstr(szLine,szEntry)
            if(ret != 0xffffffff)
            {
                DelBufLine(hbuf,ln)
                nLineEnd = nLineEnd - 1
                fIsEntry = 1
                ln = ln + 1
                continue
            }
        }
        ret = strstr(szLine,szExit)
        if(ret != 0xffffffff)
        {
            DelBufLine(hbuf,ln)
            nLineEnd = nLineEnd - 1
        }
        ln = ln + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemoveCurBufTraceInfo
 ��������  : �ӵ�ǰ��buf��ɾ����ӵĳ���ڴ�ӡ��Ϣ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemoveCurBufTraceInfo()
{
    hbuf = GetCurrentBuf()
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
		    	while (ichild < cchild)
				{
    		        hsyml = SymbolChildren(symbol)
					childsym = SymListItem(hsyml, ichild)
                    SetBufIns(hbuf,childsym.lnName,0)
                    RemoveTraceInfo()
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
	        }
            else if( ( symbol.Type == "Function") ||  (symbol.Type == "Method") )
            {
                SetBufIns(hbuf,symbol.lnName,0)
                RemoveTraceInfo()
            }
        }
        isym = isym + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemovePrjTraceInfo
 ��������  : ɾ�������е�ȫ������ĺ����ĳ���ڴ�ӡ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemovePrjTraceInfo()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            SetCurrentBuf(hbuf)
            RemoveCurBufTraceInfo()
        }
        //�Զ�������ļ����ɸ�����Ҫ��
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : InsertFileHeaderEN
 ��������  : ����Ӣ���ļ�ͷ����
 �������  : hbuf       
             ln         �к�
             szName     ������
             szContent  ������������
             cpp        �Ƿ����CPP���ݺ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileHeaderEN(hbuf, ln,szName,szContent,cpp,szVersion)
{
    
/*    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    GetFunctionList(hbuf,hnewbuf)*/
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    szFile = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 0,  "/*******************************************************************************")
    InsBufLine(hbuf, ln + 1,  " Copyright (c) 2007-@sz@, Hangzhou H3C Technologies Co., Ltd. All rights reserved.")
    InsBufLine(hbuf, ln + 2,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 3,  "                            @szFile@")
    InsBufLine(hbuf, ln + 4,  "   Project Code: @szVersion@")
    InsBufLine(hbuf, ln + 5,  "   Module Name :")
    InsBufLine(hbuf, ln + 6,  "   Date Created: @sz@-@sz1@-@sz3@ ")
    InsBufLine(hbuf, ln + 7,  "   Author      : @szName@")
    nlnDesc = ln
    iLen = strlen (szContent)
    InsBufLine(hbuf, ln + 8,  "   Description : @szContent@ ")
    InsBufLine(hbuf, ln + 9,  "")
    InsBufLine(hbuf, ln + 10,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 11,  "  Modification History")
    InsBufLine(hbuf, ln + 12,  "  DATE        NAME             DESCRIPTION")
    InsBufLine(hbuf, ln + 13,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 14,  "                                                                             ")
    InsBufLine(hbuf, ln + 15,  "*******************************************************************************/")
    InsBufLine(hbuf, ln + 16, "")
    if(cpp == 1)
    {
        InsertCPP(hbuf,ln + 17)
    }
  //InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 20, " * external variables                           *")
  //InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 22, "")
  //InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 24, " * external routine prototypes                  *")
  //InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 26, "")
  //InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 28, " * internal routine prototypes                  *")
  //InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 30, "")
  //InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 32, " * project-wide global variables                *")
  //InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 34, "")
  //InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 36, " * module-wide global variables                 *")
  //InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 38, "")
  //InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 40, " * constants                                    *")
  //InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 42, "")
  //InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 44, " * macros                                       *")
  //InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 46, "")
  //InsBufLine(hbuf, ln + 47, "/*----------------------------------------------*")
  //InsBufLine(hbuf, ln + 48, " * routines' implementations                    *")
  //InsBufLine(hbuf, ln + 49, " *----------------------------------------------*/")
  //InsBufLine(hbuf, ln + 50, "")
    if(iLen != 0)
    {
        return
    }
    
    //���û�й���������������ʾ����
    szContent = Ask("Description")
    SetBufIns(hbuf,nlnDesc + 22,0)
    DelBufLine(hbuf,nlnDesc +8)
    
    //ע���������,�Զ�����
    CommentContent(hbuf,nlnDesc + 8,"   Description: ",szContent,0,75)
}


/*****************************************************************************
 �� �� ��  : InsertFileHeaderCN
 ��������  : �������������ļ�ͷ˵��
 �������  : hbuf       
             ln         
             szName     
             szContent  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2010��3��4��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸��˲��ܼ���CPP�͹��λ�ò��Ե�����

*****************************************************************************/
macro InsertFileHeaderCN(hbuf, ln,szName,szContent, cpp, szVersion)
{
/*    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }*/
    //GetFunctionList(hbuf,hnewbuf)
    szFile = GetFileName(GetBufName (hbuf))
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    InsBufLine(hbuf, ln + 0,  "/*******************************************************************************")
    InsBufLine(hbuf, ln + 1,  "                ��Ȩ����(C)��2007-@sz@�����ݻ���ͨ�ż������޹�˾")
    InsBufLine(hbuf, ln + 2,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 3,  "                            @szFile@")
    InsBufLine(hbuf, ln + 4,  "  �� Ʒ ��: @szVersion@")
    InsBufLine(hbuf, ln + 5,  "  ģ �� ��:")
    InsBufLine(hbuf, ln + 6,  "  ��������: @sz@��@sz1@��@sz3@��")
    InsBufLine(hbuf, ln + 7,  "  ��    ��: @szName@")
    nlnDesc = ln
    iLen = strlen (szContent)
    InsBufLine(hbuf, ln + 8,  "  �ļ�����: @szContent@ ")
    InsBufLine(hbuf, ln + 9,  "")
    InsBufLine(hbuf, ln + 10,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 11,  "   �޸���ʷ")
    InsBufLine(hbuf, ln + 12,  "   ����        ����             ����")
    InsBufLine(hbuf, ln + 13,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 14,  "")
    InsBufLine(hbuf, ln + 15,  "*******************************************************************************/")
    if(cpp == 1)
    {
        InsertCPP(hbuf,ln + 16)
    }
  // InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 20, " * �ⲿ����˵��                                 *")
  // InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 22, "")
  //  InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 24, " * �ⲿ����ԭ��˵��                             *")
  //  InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 26, "")
  //  InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 28, " * �ڲ�����ԭ��˵��                             *")
  //  InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 30, "")
  //  InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 32, " * ȫ�ֱ���                                     *")
  //  InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 34, "")
  //  InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 36, " * ģ�鼶����                                   *")
  //  InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 38, "")
  //  InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 40, " * ��������                                     *")
  //  InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 42, "")
  //  InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 44, " * �궨��                                       *")
  //  InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 46, "")
    if(strlen(szContent) != 0)
    {
        return
    }
    
    //���û�й���������������ʾ����
    szContent = Ask("����")
    SetBufIns(hbuf,nlnDesc + 21,0)
    DelBufLine(hbuf,nlnDesc + 8)
    
    //ע���������,�Զ�����
    CommentContent(hbuf,nlnDesc + 8,"  �ļ�����: ",szContent,0,75)
}

/*****************************************************************************
 �� �� ��  : GetFunctionList
 ��������  : ��ú����б�
 �������  : hbuf  
             hnewbuf    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFunctionList(hbuf,hnewbuf)
{
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    //����ȡ��ȫ���ĵ�ǰbuf���ű��е�ȫ������
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        if(symbol.Type == "Class Placeholder")
        {
	        hsyml = SymbolChildren(symbol)
			cchild = SymListCount(hsyml)
			ichild = 0
	    	while (ichild < cchild)
			{
				childsym = SymListItem(hsyml, ichild)
                AppendBufLine(hnewbuf,childsym.symbol)
				ichild = ichild + 1
			}
	        SymListFree(hsyml)
        }
        if(strlen(symbol) > 0)
        {
            if( (symbol.Type == "Method") || 
                (symbol.Type == "Function") || ("Editor Macro" == symbol.Type) )
            {
                //ȡ�������Ǻ����ͺ�ķ���
                symname = symbol.Symbol
                //�����Ų��뵽��buf����������Ϊ�˼���V2.1
                AppendBufLine(hnewbuf,symname)
               }
           }
        isym = isym + 1
    }
}

macro GetFunctionList1(hbuf,hnewbuf)
{
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    //����ȡ��ȫ���ĵ�ǰbuf���ű��е�ȫ������
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        if(symbol.Type == "Class Placeholder")
        {
	        hsyml = SymbolChildren(symbol)
			cchild = SymListCount(hsyml)
			ichild = 0
	    	while (ichild < cchild)
			{
				childsym = SymListItem(hsyml, ichild)
                AppendBufLine(hnewbuf,childsym.symbol)
				ichild = ichild + 1
			}
	        SymListFree(hsyml)
        }
        if(strlen(symbol) > 0)
        {
            if( (symbol.Type == "Method") || 
                (symbol.Type == "Function") || ("Editor Macro" == symbol.Type) )
            {
                //ȡ�������Ǻ����ͺ�ķ���
                symname = symbol.Symbol

                FuncCodeStatistic(hbuf,hnewbuf,symbol)
               }
           }
        isym = isym + 1
    }
}

/*****************************************************************************
 �� �� ��  : InsertFileList
 ��������  : �����б����
 �������  : hbuf  
             ln    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileList(hbuf,hnewbuf,ln)
{
    if(hnewbuf == hNil)
    {
        return ln
    }
    isymMax = GetBufLineCount (hnewbuf)
    isym = 0
    while (isym < isymMax) 
    {
        szLine = GetBufLine(hnewbuf, isym)
        InsBufLine(hbuf,ln,"              @szLine@")
        ln = ln + 1
        isym = isym + 1
    }
    return ln 
}


/*****************************************************************************
 �� �� ��  : CommentContent1
 ��������  : �Զ�������ʾ�ı�,��Ϊmsg�Ի����ܴ�����е���������Ҳ��ܳ���255
             ���ַ�����Ϊ���У������˴Ӽ�����ȡ���ݵİ취���������������Ǽ�
             ���������ݵ�ǰ���ֵĻ�����Ϊ�û��ǿ��������ݣ���������Ȼ�п�����
             �󣬵����ָ��ʷǳ��͡���CommentContent��ͬ���������������е�����
             �ϲ���һ�����������Ը�����Ҫѡ�������ַ�ʽ
 �������  : hbuf       
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����'*'��'/'
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentContent1 (hbuf,ln,szPreStr,szContent,isEnd)
{
    //���������еĶ���ı��ϲ�
    szClip = MergeString()
    //ȥ������Ŀո�
    szTmp = TrimString(szContent)
    //������봰���е������Ǽ������е�����˵���Ǽ���������
    ret = strstr(szClip,szTmp)
    if(ret == 0)
    {
        szContent = szClip
    }
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }
    iLen = strlen (szContent)
    szTmp = cat(szPreStr,"#");
    if( iLen == 0)
    {
        InsBufLine(hbuf, ln, "@szTmp@")
    }
    else
    {
        i = 0
        while  (iLen - i > 75 - k )
        {
            j = 0
            while(j < 75 - k)
            {
                iNum = szContent[i + j]
                //��������ı���ɶԴ���
                if( AsciiFromChar (iNum)  > 160 )
                {
                   j = j + 2
                }
                else
                {
                   j = j + 1
                }
                if( (j > 70 - k) && (szContent[i + j] == " ") )
                {
                    break
                }
            }
            if( (szContent[i + j] != " " ) )
            {
                n = 0;
                iNum = szContent[i + j + n]
                while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                {
                    n = n + 1
                    if((n >= 3) ||(i + j + n >= iLen))
                         break;
                    iNum = szContent[i + j + n]
                   }
                if(n < 3)
                {
                    j = j + n 
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)                
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                    if(sz1[strlen(sz1)-1] != "-")
                    {
                        sz1 = cat(sz1,"-")                
                    }
                }
            }
            else
            {
                sz1 = strmid(szContent,i,i+j)
                sz1 = cat(szPreStr,sz1)
            }
            InsBufLine(hbuf, ln, "@sz1@")
            ln = ln + 1
            szPreStr = szLeftBlank
            i = i + j
            while(szContent[i] == " ")
            {
                i = i + 1
            }
        }
        sz1 = strmid(szContent,i,iLen)
        sz1 = cat(szPreStr,sz1)
        if(isEnd)
        {
            sz1 = cat(sz1,"*/")
        }
        InsBufLine(hbuf, ln, "@sz1@")
    }
    return ln
}



/*****************************************************************************
 �� �� ��  : CommentContent
 ��������  : �Զ�������ʾ�ı�,��Ϊmsg�Ի����ܴ�����е���������Ҳ��ܳ���255
             ���ַ�����Ϊ���У������˴Ӽ�����ȡ���ݵİ취���������������Ǽ�
             ���������ݵ�ǰ���ֵĻ�����Ϊ�û��ǿ��������ݣ���������Ȼ�п�����
             �󣬵����ָ��ʷǳ���
 �������  : hbuf       
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����'*'��'/'
             iMax       ÿ����󳤶�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2010��3��3��
    ��    ��   : ¬ʤ��
    �޸�����   : �����˳��Ȳ���

*****************************************************************************/
macro CommentContent (hbuf,ln,szPreStr,szContent,isEnd, iMax)
{
    if(iMax < 70)
    {
        iMax = 70
    }
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }

    hNewBuf = newbuf("clip")
    if(hNewBuf == hNil)
        return       
    SetCurrentBuf(hNewBuf)
    PasteBufLine (hNewBuf, 0)
    lnMax = GetBufLineCount( hNewBuf )
    szTmp = TrimString(szContent)

    //�ж������������0��ʱ������Щ�汾�������⣬Ҫ�ų���
    if(lnMax != 0)
    {
        szLine = GetBufLine(hNewBuf , 0)
	    ret = strstr(szLine,szTmp)
	    if(ret == 0)
	    {
	        /*������봰����������Ǽ������һ����˵���Ǽ���������ȡ�������е���
	          ��*/
	        szContent = TrimString(szLine)
	    }
	    else
	    {
	        lnMax = 1
	    }	    
    }
    else
    {
        lnMax = 1
    }    
    szRet = ""
    nIdx = 0
    while ( nIdx < lnMax) 
    {
        if(nIdx != 0)
        {
            szLine = GetBufLine(hNewBuf , nIdx)
            szContent = TrimLeft(szLine)
               szPreStr = szLeftBlank
        }
        iLen = strlen (szContent)
        szTmp = cat(szPreStr,"#");
        if( (iLen == 0) && (nIdx == (lnMax - 1))
        {
            InsBufLine(hbuf, ln, "@szTmp@")
        }
        else
        {
            i = 0
            //��ÿ�д����ַ�����
            while  (iLen - i > iMax - k )
            {
                j = 0
                while(j < iMax - k)
                {
                    iNum = szContent[i + j]
                    if( AsciiFromChar (iNum)  > 160 )
                    {
                       j = j + 2
                    }
                    else
                    {
                       j = j + 1
                    }
                    if(i + j >= iLen)
                    {
                        break;
                    }
                    if( (j > iMax - k) && (szContent[i + j] == " ") )
                    {
                        break
                    }
                }
                if(i + j >= iLen)
                {
                    break;
                }
                if( (szContent[i + j] != " " ) )
                {
                    n = 0;
                    iNum = szContent[i + j + n]
                    //����������ַ�ֻ�ܳɶԴ���
                    while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                    {
                        n = n + 1
                        if((n >= 3) ||(i + j + n >= iLen))
                        {
                             break;
                        }
                        iNum = szContent[i + j + n]
                    }
                    if(n < 3)
                    {
                        //�ֶκ�ֻ��С��3�����ַ������¶���������ȥ
                        j = j + n 
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)                
                    }
                    else
                    {
                        //����3���ַ��ļ����ַ��ֶ�
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)
                        if(sz1[strlen(sz1)-1] != "-")
                        {
                            sz1 = cat(sz1,"-")                
                        }
                    }
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                }
                InsBufLine(hbuf, ln, "@sz1@")
                ln = ln + 1
                szPreStr = szLeftBlank
                i = i + j
                while(szContent[i] == " ")
                {
                    i = i + 1
                }
            }
            sz1 = strmid(szContent,i,iLen)
            sz1 = cat(szPreStr,sz1)
            if((isEnd == 1) && (nIdx == (lnMax - 1))
            {
                sz1 = cat(sz1," */")
            }
            InsBufLine(hbuf, ln, "@sz1@")
        }
        ln = ln + 1
        nIdx = nIdx + 1
    }
    closebuf(hNewBuf)
    return ln - 1
}

/*****************************************************************************
 �� �� ��  : FormatLine
 ��������  : ��һ�г��ı������Զ�����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FormatLine()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.ichFirst > 70)
    {
        Msg("ѡ��̫������")
        stop 
    }
    hbuf = GetWndBuf(hwnd)
    // get line the selection (insertion point) is on
    szCurLine = GetBufLine(hbuf, sel.lnFirst);
    lineLen = strlen(szCurLine)
    szLeft = strmid(szCurLine,0,sel.ichFirst)
    szContent = strmid(szCurLine,sel.ichFirst,lineLen)
    DelBufLine(hbuf, sel.lnFirst)
    CommentContent(hbuf,sel.lnFirst,szLeft,szContent,0,80)            

}

/*****************************************************************************
 �� �� ��  : CreateBlankString
 ��������  : ���������ո���ַ���
 �������  : nBlankCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateBlankString(nBlankCount)
{
    szBlank=""
    nIdx = 0
    while(nIdx < nBlankCount)
    {
        szBlank = cat(szBlank," ")
        nIdx = nIdx + 1
    }
    return szBlank
}

/*****************************************************************************
 �� �� ��  : TrimLeft
 ��������  : ȥ���ַ�����ߵĿո�
 �������  : szLine  
 �������  : ȥ����ո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimLeft(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = 0
    while( nIdx < nLen )
    {
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
        nIdx = nIdx + 1
    }
    return strmid(szLine,nIdx,nLen)
}

/*****************************************************************************
 �� �� ��  : TrimRight
 ��������  : ȥ���ַ����ұߵĿո�
 �������  : szLine  
 �������  : ȥ���ҿո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimRight(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = nLen
    while( nIdx > 0 )
    {
        nIdx = nIdx - 1
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
    }
    return strmid(szLine,0,nIdx+1)
}

/*****************************************************************************
 �� �� ��  : TrimString
 ��������  : ȥ���ַ������ҿո�
 �������  : szLine  
 �������  : ȥ�����ҿո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}


/*****************************************************************************
 �� �� ��  : GetFunctionDef
 ��������  : ���ֳɶ��еĺ�������ͷ�ϲ���һ��
 �������  : hbuf    
             symbol  ��������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFunctionDef(hbuf,symbol)
{
    ln = symbol.lnName
    szFunc = ""
    if(strlen(symbol) == 0)
    {
       return szFunc
    }
    fIsEnd = 1
//    msg(symbol)
    while(ln < symbol.lnLim)
    {
        szLine = GetBufLine (hbuf, ln)
        //ȥ����ע�͵�������
        RetVal = SkipCommentFromString(szLine,fIsEnd)
		szLine = RetVal.szContent
		szLine = TrimString(szLine)
		fIsEnd = RetVal.fIsEnd
        //�����{��ʾ��������ͷ������
        ret = strstr(szLine,"{")        
        if(ret != 0xffffffff)
        {
            szLine = strmid(szLine,0,ret)
            szFunc = cat(szFunc,szLine)
            break
        }
        szFunc = cat(szFunc,szLine)        
        ln = ln + 1
    }
    return szFunc
}

/*****************************************************************************
 �� �� ��  : GetWordFromString
 ��������  : ���ַ�����ȡ����ĳ�ַ�ʽ�ָ���ַ�����
 �������  : hbuf         ���ɷָ���ַ�����buf
             szLine       �ַ���
             nBeg         ��ʼ����λ��
             nEnd         ��������λ��
             chBeg        ��ʼ���ַ���־
             chSeparator  �ָ��ַ�
             chEnd        �����ַ���־
 �������  : ����ַ�����
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetWordFromString(hbuf,szLine,nBeg,nEnd,chBeg,chSeparator,chEnd)
{
    if((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }
    nMaxLen = 0
    nIdx = nBeg
    //�ȶ�λ����ʼ�ַ���Ǵ�
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chBeg)
        {
            break
        }
        nIdx = nIdx + 1
    }
    nBegWord = nIdx + 1
    
    //���ڼ��chBeg��chEnd��������
    iCount = 0
    
    nEndWord = 0
    //�Էָ���Ϊ��ǽ�������
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chSeparator)
        {
           szWord = strmid(szLine,nBegWord,nIdx)
           szWord = TrimString(szWord)
           nLen = strlen(szWord)
           if(nMaxLen < nLen)
           {
               nMaxLen = nLen
           }
           AppendBufLine(hbuf,szWord)
           nBegWord = nIdx + 1
        }
        if(szLine[nIdx] == chBeg)
        {
            iCount = iCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            iCount = iCount - 1
            nEndWord = nIdx
            if( iCount == 0 )
            {
                break
            }
        }
        nIdx = nIdx + 1
    }
    if(nEndWord > nBegWord)
    {
        szWord = strmid(szLine,nBegWord,nEndWord)
        szWord = TrimString(szWord)
        nLen = strlen(szWord)
        if(nMaxLen < nLen)
        {
            nMaxLen = nLen
        }
        AppendBufLine(hbuf,szWord)
    }
    return nMaxLen
}


/*****************************************************************************
 �� �� ��  : FuncHeadCommentCN
 ��������  : �������ĵĺ���ͷע��
 �������  : hbuf      
             ln        �к�
             szFunc    ������
             szMyName  ������
             newFunc   �Ƿ��º���
             flag      �Ƿ�Ϊ���ע������ģ�塣0-��;1-��ӡ�Storwareƽ̨�ⲿ�ӿ���Ҫ��� 
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2010��03��3��
    ��    ��   : ¬ʤ��
    �޸�����   : ���Ӻ�������IN��OUTʶ�𣬸�ʽ��ΪComware�淶����ĸ�ʽ

  3.��    ��   : 2010��10��13��
    ��    ��   : h05000
    �޸�����   : �����ⲿ����ע������ģ�塣�������²����б��    

*****************************************************************************/
macro FuncHeadCommentCN(hbuf, ln, szFunc, szMyName, newFunc, flag)
{
    iIns = 0
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
            if(hTmpBuf == hNil)
            {
                stop
            }
            //���ļ�����ͷ�����һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName 
            //ȡ������ֵ����
            szTemp = strmid(szLine,0,iBegin)
            szTemp = TrimString(szTemp)
            szRet =  GetFirstWord(szTemp)
            if(symbol.Type == "Method")
            {
                szTemp = strmid(szTemp,strlen(szRet),strlen(szTemp))
                szTemp = TrimString(szTemp)
                if(szTemp == "::")
                {
                    szRet = ""
                }
            }
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }
            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szLine = ""
        szRet = ""
    }
    InsBufLine(hbuf, ln, "/*******************************************************************************")
    if( strlen(szFunc)>0 )
    {
        InsBufLine(hbuf, ln+1, " �� �� ��  : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln+1, " �� �� ��  : ")
    }
    SysTime = GetSysTime(1);
    szTime = SysTime.Date

    InsBufLine(hbuf, ln+2,     " ��������  : @szTime@ ")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln+3,  " ��    ��  : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln+3,  " ��    ��  : ")
    }
    oldln = ln
    
    InsBufLine(hbuf, ln+4,     " ��������  :")
    lnIn = ln + 5
    lnOut = ln + 5
    bExistIn = 0;
    bExistOut = 0;
    szIns =                    " �������  : "
    szOuts =                   " �������  : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ������뺯������
        i = 0
        bIsParamType = 0;
        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            if(szTmp == "VOID")
            {
                szTmp = "None"
            }
            else
            {
                iBeg1 = strstr(szTmp,"OUT ")
                if(iBeg1 == 0)
                {
                    bIsParamType = 1
                }
                iBeg1 = strstr(szTmp,"INOUT ")
                if(iBeg1 == 0)
                {
                    bIsParamType = 2
                }
            }
            nLen = strlen(szTmp)
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)
            if((0 == bIsParamType)||(2 == bIsParamType))
            {
                szInParam = cat(szIns,szTmp)
                ln = ln + 1
                InsBufLine(hbuf, lnIn, "@szInParam@")
                lnIn = lnIn + 1
                lnOut = lnOut + 1
                szIns = "             "
                bExistIn = 1
            }
            if((1 == bIsParamType)||(2 == bIsParamType))
            {
                szOutParam = cat(szOuts,szTmp)
                ln = ln + 1
                InsBufLine(hbuf, lnOut, "@szOutParam@")
                lnOut = lnOut + 1
                szOuts = "             "
                bExistOut = 1
            }
            bIsParamType = 0
            i = i + 1
        }    
        closebuf(hTmpBuf)
    }
    if(bExistIn == 0)
    {       
        ln = ln + 1
        InsBufLine(hbuf, ln+4,   " �������  : ��")
    }
    if(bExistOut == 0)
    {       
        ln = ln + 1
        InsBufLine(hbuf, ln+4,   " �������  : ��")
    }
    InsBufLine(hbuf, ln+5,       " �� �� ֵ  : @szRet@")
    InsBufLine(hbuf, ln+6,       " ע������  : ")
    
    caution_list = 0
    if (1 == flag)
    {    
        t_ln = ln+6
    	/* ����Storwareƽ̨�ⲿ�ӿ�ע������˵���б�.  added by h05000 */
    	InsBufLine(hbuf, t_ln+1, "  1.�Ǵ��ڹ���ͨ����������ͨ������ʲô����: ")
    	InsBufLine(hbuf, t_ln+2, "  2.����ǰ�Ƿ���Ҫ�����ڴ�: ")
    	InsBufLine(hbuf, t_ln+3, "  3.�Ƿ��������ж��е���: ")
    	InsBufLine(hbuf, t_ln+4, "  4.�ӿ����Ƿ��ͷ��������ط�������ڴ�: ")
    	InsBufLine(hbuf, t_ln+5, "  5.�ӿ����Ƿ���down�ź�������: ")
    	InsBufLine(hbuf, t_ln+6, "  6.�Ƿ��н�ֹ�жϵĲ���: ")
    	InsBufLine(hbuf, t_ln+7, "  7.�ӿڵ���������: ")
    	InsBufLine(hbuf, t_ln+8, "  8.�Ƿ������: ")

        ln = ln + 8
        caution_list = 8
    }
  
    InsbufLIne(hbuf, ln+7, " ");
    InsBufLine(hbuf, ln + 8,   "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 9,   "    �޸���ʷ                                                                  ")
    InsBufLine(hbuf, ln + 10,  "    ����        ����             ����                                         ")
    InsBufLine(hbuf, ln + 11,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 12,  "                                                                              ")
    InsBufLine(hbuf, ln + 13,  "*******************************************************************************/")

    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+14, "ULONG @szFunc@()")
        InsBufLine(hbuf, ln+15, "{");
        InsBufLine(hbuf, ln+16, "    ");
        InsBufLine(hbuf, ln+17, "}");
        SearchForward()
    }     
    
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 14
    sel.lnLast = ln + 14        
    szContent = Ask("�����뺯����������������")
    setWndSel(hwnd,sel)
    DelBufLine(hbuf,oldln + 4)

    //��ʾ����Ĺ�����������
    newln = CommentContent(hbuf,oldln+4," ��������  : ",szContent,0,75) - 2
    ln = ln + newln - oldln

	// ������ע�������б���׼�仯����"ln+6"Ϊ��ע�⴦��������ӵ��б�����

    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
            
        //��ʾ�����º����ķ���ֵ
        szRet = Ask("�����뷵��ֵ����")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+3 - caution_list, " �� �� ֵ  : @szRet@")            
            PutBufLine(hbuf, ln+12, "@szRet@ @szFunc@( )")
            SetbufIns(hbuf,ln+12,strlen(szRet)+strlen(szFunc) + 2
        }
        szFuncDef = ""
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 2
        sel.ichLim = sel.ichFirst + 1	

        //ѭ���������
        while (1)
        {
            szParam = ask("�����뺯��������")           
            szParam = TrimString(szParam)
            //szParam = cat("IN ",szParam)
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
   
            sel.lnFirst = ln + 12
            sel.lnLast = ln + 12
            setWndSel(hwnd,sel)
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+1 -caution_list, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+1 - caution_list, "@szTmp@")
                oldsel.lnFirst = ln + 12
                oldsel.lnLast = ln + 12        
            }
            SetBufSelText(hbuf,szParam)
            szIns = "             "
            szFuncDef = ", "
            oldsel.lnFirst = ln + 14
            oldsel.lnLast = ln + 14
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 17	/* ������λ�� */ 
}

/*****************************************************************************
 �� �� ��  : FuncHeadCommentEN
 ��������  : ����ͷӢ��˵��
 �������  : hbuf      
             ln        
             szFunc    
             szMyName  
             newFunc   
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2010��03��3��
    ��    ��   : ¬ʤ��
    �޸�����   : ���Ӻ�������IN��OUTʶ�𣬸�ʽ��ΪComware�淶����ĸ�ʽ

  3.��    ��   : 2010��03��15��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸��˺�������λ�ò��Ե�BUG

*****************************************************************************/
macro FuncHeadCommentEN(hbuf, ln, szFunc, szMyName,newFunc)
{
    iIns = 0
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
            if(hTmpBuf == hNil)
            {
                stop
            }
            //���ļ�����ͷ�����һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName
            
            //ȡ������ֵ����
            szTemp = strmid(szLine,0,iBegin)
            szTemp = TrimString(szTemp)
            szRet =  GetFirstWord(szTemp)
            if(symbol.Type == "Method")
            {
                szTemp = strmid(szTemp,strlen(szRet),strlen(szTemp))
                szTemp = TrimString(szTemp)
                if(szTemp == "::")
                {
                    szRet = ""
                }
            }
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }
            
            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szRet = ""
        szLine = ""
    }
    InsBufLine(hbuf, ln, "/*******************************************************************************")
    if( strlen(szFunc)>0 )
    {
        InsBufLine(hbuf, ln+1, " Func Name    : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln+1, " Func Name    : ")
    }

    
    SysTime = GetSysTime(1);
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day

    InsBufLine(hbuf, ln+2, " Date Created : @sz1@/@sz2@/@sz3@ ")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln+3, " Author       : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln+3, " Author       : ")
    }

    oldln = ln
    InsBufLine(hbuf, ln+4, " Description  :")
    lnIn = ln + 5
    lnOut = ln + 5
    szIns = " Input        : "
    bExistIn = 0;
    bExistOut = 0;
    szOuts = " Output       : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ������뺯������
        i = 0
        bIsParamType = 0;
        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            if(szTmp == "VOID")
            {
                szTmp = "None"
            }
            else
            {
                iBeg1 = strstr(szTmp,"OUT ")
                if(iBeg1 == 0)
                {
                    bIsParamType = 1
                }
                iBeg1 = strstr(szTmp,"INOUT ")
                if(iBeg1 == 0)
                {
                    bIsParamType = 2
                }
            }
            nLen = strlen(szTmp)
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)
            if((0 == bIsParamType)||(2 == bIsParamType))
            {
                szInParam = cat(szIns,szTmp)
                ln = ln + 1
                InsBufLine(hbuf, lnIn, "@szInParam@")
                lnIn = lnIn + 1
                lnOut = lnOut + 1
                szIns = "                "
                bExistIn = 1
            }
            if((1 == bIsParamType)||(2 == bIsParamType))
            {
                szOutParam = cat(szOuts,szTmp)
                ln = ln + 1
                InsBufLine(hbuf, lnOut, "@szOutParam@")
                lnOut = lnOut + 1
                szOuts = "                "
                bExistOut = 1
            }
            i = i + 1
            bIsParamType = 0

        }    
        closebuf(hTmpBuf)
    }
    if(bExistIn == 0)
    {       
            ln = ln + 1
            InsBufLine(hbuf, ln+4, " Input        : None")
    }
    if(bExistOut == 0)
    {       
            ln = ln + 1
            InsBufLine(hbuf, ln+4, " Output       : None")
    }
//    InsBufLine(hbuf, ln+5, " Calls        : ")
//    InsBufLine(hbuf, ln+6, " Called By    : ")
    InsBufLine(hbuf, ln+5, " Return       : @szRet@")
    InsbufLIne(hbuf, ln+6, " Caution      : ");
    InsbufLIne(hbuf, ln+7  " ");


    InsBufLine(hbuf, ln + 8,   "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 9,   "  Modification History                                                      ")
    InsBufLine(hbuf, ln + 10,  "  DATE        NAME             DESCRIPTION                                  ")
    InsBufLine(hbuf, ln + 11,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 12,  "                                                                            ")
    InsBufLine(hbuf, ln + 13,  "*******************************************************************************/")

    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+14, "ULONG @szFunc@()")
        InsBufLine(hbuf, ln+15, "{");
        InsBufLine(hbuf, ln+16, "    ");
        InsBufLine(hbuf, ln+17, "}");
        SearchForward()
    }        
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 14
    sel.lnLast = ln + 14        
    szContent = Ask("Description")
    setWndSel(hwnd,sel)
    DelBufLine(hbuf,oldln + 4)

    //��ʾ����Ĺ�����������
    newln = CommentContent(hbuf,oldln+4," Description  : ",szContent,0,75) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
            
        //��ʾ�����º����ķ���ֵ
        szRet = Ask("Please input return value type")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+3, " Return Value : @szRet@")            
            PutBufLine(hbuf, ln+12, "@szRet@ @szFunc@( )")
            SetbufIns(hbuf,ln+12,strlen(szRet)+strlen(szFunc) + 2
        }
        szFuncDef = ""
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 2
        sel.ichLim = sel.ichFirst + 1
        //ѭ���������
        while (1)
        {
            szParam = ask("Please input parameter")           
            szParam = TrimString(szParam)
            //szParam = cat("IN ",szParam)
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
            sel.lnFirst = ln + 12
            sel.lnLast = ln + 12
            setWndSel(hwnd,sel)
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+1, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+1, "@szTmp@")
                oldsel.lnFirst = ln + 12
                oldsel.lnLast = ln + 12        
            }
            SetBufSelText(hbuf,szParam)
            szIns = "                "
            szFuncDef = ", "
            oldsel.lnFirst = ln + 14
            oldsel.lnLast = ln + 14
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 17
}



/*****************************************************************************
 �� �� ��  : InsertHistory
 ��������  : �����޸���ʷ��¼
 �������  : hbuf      
             ln        �к�
             language  ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertHistory(hbuf,ln,language)
{
   /* iHistoryCount = 1
    isLastLine = ln
    i = 0
    while(ln-i>0)
    {
        szCurLine = GetBufLine(hbuf, ln-i);
        iBeg1 = strstr(szCurLine,"��    ��  ")
        iBeg2 = strstr(szCurLine,"Date      ")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            iHistoryCount = iHistoryCount + 1
            i = i + 1
            continue
        }
        iBeg1 = strstr(szCurLine,"�޸���ʷ")
        iBeg2 = strstr(szCurLine,"History      ")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            break
        }
        iBeg = strstr(szCurLine,"/**********************")
        if( iBeg != 0xffffffff )
        {
            break
        }
        i = i + 1
    }*/
    if(language == 0)
    {
        InsertHistoryContentCN(hbuf,ln,iHistoryCount)
    }
    else
    {
        InsertHistoryContentEN(hbuf,ln,iHistoryCount)
    }
}

/*****************************************************************************
 �� �� ��  : UpdateFunctionList
 ��������  : ���º����б�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro UpdateFunctionList()
{
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    GetFunctionList1(hbuf,hnewbuf)
    ln = sel.lnFirst
    iHistoryCount = 1
    isLastLine = ln
    iTotalLn = GetBufLineCount (hbuf) 
    while(ln < iTotalLn)
    {
        szCurLine = GetBufLine(hbuf, ln);
        iLen = strlen(szCurLine)
        j = 0;
        while(j < iLen)
        {
            if(szCurLine[j] != " ")
                break
            j = j + 1
        }
        
        //���ļ�ͷ˵����ǰ�д���10���ո��Ϊ�����б��¼
        if(j > 10)
        {
            DelBufLine(hbuf, ln)   
        }
        else
        {
            break
        }
        iTotalLn = GetBufLineCount (hbuf) 
    }

    //���뺯���б�
    InsertFileList( hbuf,hnewbuf,ln )
    closebuf(hnewbuf)
 }

/*****************************************************************************
 �� �� ��  : InsertHistoryContentCN
 ��������  : ������ʷ�޸ļ�¼����˵��
 �������  : hbuf           
             ln             
             iHostoryCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���
  2.��    ��   : 2005��11��16��
    ��    ��   : ����
    �޸�����   : ��COMWARE�����淶�޸ġ�
*****************************************************************************/
macro  InsertHistoryContentCN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    szMyName = getreg(MYNAME)

    if( strlen(szMyName) < 0 )
    {
       szMyName = "#"
    }
    szContent = Ask("�������޸ĵ�����")
    CommentContent(hbuf, ln ,"  @szTime@  @szMyName@     ",szContent,0,75)
}


/*****************************************************************************
 �� �� ��  : InsertHistoryContentEN
 ��������  : ������ʷ�޸ļ�¼Ӣ��˵��
 �������  : hbuf           ��ǰbuf
             ln             ��ǰ�к�
             iHostoryCount  �޸ļ�¼�ı��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���
  2.��    ��   : 2005��11��16��
    ��    ��   : ����
    �޸�����   : ��COMWARE�����淶�޸ġ�
*****************************************************************************/
macro  InsertHistoryContentEN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day
    szMyName = getreg(MYNAME)
    InsBufLine(hbuf, ln, "")
    if( strlen(szMyName) < 0 )
    {
       szMyName = "#"
    }
    szContent = Ask("Please input modification")
    CommentContent(hbuf,ln + 1,"   @sz1@/@sz2@/@sz3@   @szMyName@     ",szContent,0,75)
}

/*****************************************************************************
 �� �� ��  : CreateFunctionDef
 ��������  : ����C����ͷ�ļ�
 �������  : hbuf      
             szName    
             language  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFunctionDef(hbuf, szName, language)
{
    ln = 0

    //��õ�ǰû�к�׺���ļ���
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("������ͷ�ļ���")
        szFileName = GetFileNameNoExt(sz)
        szExt = GetFileNameExt(szFileName)        
        szPreH = toupper (szFileName)
        szPreH = cat("_",szPreH)
        szExt = toupper(szExt)
        szPreH = cat(szPreH,"_@szExt@_")
    }
    szPreH = toupper (szFileName)
    sz = cat(szFileName,".h")
    szPreH = cat("__",szPreH)
    szPreH = cat(szPreH,"_H__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //�������ű�ȡ�ú�����
    SetCurrentBuf(hOutbuf)
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
				szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
			    InsBufLine(hOutbuf, ln, "{")
			    InsBufLine(hOutbuf, ln, "class @szClassName@")
			    ln = ln + 2
		    	while (ichild < cchild)
				{
					childsym = SymListItem(hsyml, ichild)
					childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
		        ln = ln + 2
	        }
            else if( symbol.Type == "Function" )
            {
                ln = CreateFuncPrototype(hbuf,ln,"extern",symbol)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName.word
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
            
        }
        isym = isym + 1
    }
    InsertCPP(hOutbuf,0)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    szVersion = getreg(VERSION)
    if(strlen(szVersion) == 0)
    {
    	szVersion = Ask("Please input project code(such as Comware):")
    	setreg(VERSION,szVersion)
    }
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")
        //�����ļ�ͷ˵��
        InsertFileHeaderCN(hOutbuf, 0, szName, szContent, 0, szVersion)
    }
    else
    {
        szContent = cat(szContent," header file")
        //�����ļ�ͷ˵��
        InsertFileHeaderEN(hOutbuf, 0, szName, szContent, 0, szVersion)        
    }
}

/*****************************************************************************
 �� �� ��  : CreateFunctionStub
 ��������  : ����C��׮�ļ�
 �������  : hbuf      
             szName    
             language  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFunctionStub(hbuf, szName, language)
{
    ln = 0

    //��õ�ǰû�к�׺���ļ���
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("������ͷ�ļ���")
        szFileName = GetFileNameNoExt(sz)
    }
    sz = cat(szFileName,"_stub.c")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //�������ű�ȡ�ú�����
    SetCurrentBuf(hOutbuf)
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
				szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
			    InsBufLine(hOutbuf, ln, "{")
			    InsBufLine(hOutbuf, ln, "class @szClassName@")
			    ln = ln + 2
		    	while (ichild < cchild)
				{
					childsym = SymListItem(hsyml, ichild)
					childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
		        ln = ln + 2
	        }
            else if( symbol.Type == "Function" )
            {
                ln = CreateFuncStub(hbuf,ln,symbol,1)
            }
            else if( symbol.Type == "Function Prototype" )
            {
                ln = CreateFuncStub(hbuf,ln,symbol,0)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName.word
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
            
        }
        isym = isym + 1
    }
    sz = cat(szFileName,".h")
//    InsertCPP(hOutbuf,0)
    InsBufLine(hOutbuf, 0, "")
    InsBufLine(hOutbuf, 0, "#include \"@sz@\"")
    InsBufLine(hOutbuf, 0, "")
    
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��׮�ļ�")
        //�����ļ�ͷ˵��
        InsertFileHeaderCN(hOutbuf,0,szName,szContent, 1)
    }
    else
    {
        szContent = cat(szContent," stub file")
        //�����ļ�ͷ˵��
        InsertFileHeaderEN(hOutbuf,0,szName,szContent, 1)        
    }
}

macro CopyCurFileName()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    szName = GetBufName (hbuf)
    symbolname = GetCurSymbol()
    newHbuf = newbuf("clip")
    if(newHbuf == hNil)
        return       
    SetCurrentBuf(newHbuf)
    /*szName = cat(szName,"   ")
    szName = cat(szName,symbolname)    
    szName = cat(szName,"( )")*/
    AppendBufLine(newHbuf,szName)
    CopyBufLine (newHbuf, 0)
    CloseBuf(newHbuf)
}
/*****************************************************************************
 �� �� ��  : GetLeftWord
 ��������  : ȡ����ߵĵ���
 �������  : szLine    
             ichRight ��ʼȡ��λ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetLeftWord(szLine,ichRight)
{
    retval = ""
    ich = strlen(szLine)
    if(ich == 0)
    {
        return ""
    }
    ich = ichRight-1
    while(ich > 0)
    {
        if( (szLine[ich] == " ") || (szLine[ich] == "\t")
            || ( szLine[ich] == ":") || (szLine[ich] == "."))

        {
            ich = ich - 1
            ichRight = ich
        }
        else
        {
            break
        }
    }    
    while(ich > 0)
    {
        if( (szLine[ich] == " ") || (szLine[ich] == "\t")
            || ( szLine[ich] == ":") || (szLine[ich] == "."))
        {
            break
        }
        ich = ich - 1
    }
    retval.word = strmid(szLine,ich,ichRight+1)
    retval.iWord = ich;
    return retval
}
/*****************************************************************************
 �� �� ��  : CreateClassPrototype
 ��������  : ����Class�Ķ���
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateClassPrototype(hbuf,ln,symbol)
{
    isLastLine = 0
    fIsEnd = 1
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf, symbol.lnName)
    sline = symbol.lnFirst     
    szClassName = symbol.Symbol
    ret = strstr(szLine,szClassName)
    if(ret == 0xffffffff)
    {
        return ln
    }
    szPre = strmid(szLine,0,ret)
    szLine = strmid(szLine,symbol.ichName,strlen(szLine))
    szLine = cat(szPre,szLine)
    //ȥ��ע�͵ĸ���
    RetVal = SkipCommentFromString(szLine,fIsEnd)
    fIsEnd = RetVal.fIsEnd
    szNew = RetVal.szContent
    szLine = cat("    ",szLine)
    szNew = cat("    ",szNew)
    while((isLastLine == 0) && (sline < symbol.lnLim))
    {   
        i = 0
        j = 0
        iLen = strlen(szNew)
        while(i < iLen)
        {
            if(szNew[i]=="(")
            {
               j = j + 1;
            }
            else if(szNew[i]==")")
            {
                j = j - 1;
                if(j <= 0)
                {
                    //��������ͷ����
                    isLastLine = 1  
                    //ȥ����������ַ�
        	        szLine = strmid(szLine,0,i+1);
                    szLine = cat(szLine,";")
                    break
                }
            }
            i = i + 1
        }
        InsBufLine(hOutbuf, ln, "@szLine@")
        ln = ln + 1
        sline = sline + 1
        if(isLastLine != 1)
        {              
            //��������ͷ��û�н�����ȡһ��
            szLine = GetBufLine (hbuf, sline)
            //ȥ��ע�͵ĸ���
            RetVal = SkipCommentFromString(szLine,fIsEnd)
	        szNew = RetVal.szContent
	        fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}

/*****************************************************************************
 �� �� ��  : CreateFuncStub
 ��������  : ����C������׮����
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             szType    ԭ������
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFuncStub(hbuf,ln,symbol,fun)
{
    isLastLine = 0
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf,symbol.lnName)
    
    Retval = GetLeftWord(szLine,symbol.ichName)
    szRetval = TrimString(toupper(Retval.word))
    if (fun == 0)
    {
	    iBegin = Retval.iWord;
	       
	    szLine = strmid(szLine,iBegin,strlen(szLine))
    }

    //ȥ��ע�͵ĸ���
    RetVal = SkipCommentFromString(szLine,fIsEnd)
    szNew = RetVal.szContent
    fIsEnd = RetVal.fIsEnd
    sline = symbol.lnFirst     
    while((isLastLine == 0) && (sline < symbol.lnLim))
    {   
        i = 0
        j = 0
        iLen = strlen(szNew)
        while(i < iLen)
        {
            if(szNew[i]=="(")
            {
               j = j + 1;
            }
            else if(szNew[i]==")")
            {
                j = j - 1;
                if(j <= 0)
                {
                    //��������ͷ����
                    isLastLine = 1  
                    //ȥ����������ַ�
        	        szLine = strmid(szLine,0,i+1);
                    break
                }
            }
            i = i + 1
        }
        InsBufLine(hOutbuf, ln, "@szLine@")
        ln = ln + 1
        sline = sline + 1
        if(isLastLine != 1)
        {              
            //��������ͷ��û�н�����ȡһ��
            szLine = GetBufLine (hbuf, sline)
            szLine = cat("         ",szLine)
            //ȥ��ע�͵ĸ���
            RetVal = SkipCommentFromString(szLine,fIsEnd)
	        szNew = RetVal.szContent
	        fIsEnd = RetVal.fIsEnd
        }                    
    }
    InsBufLine(hOutbuf, ln, "{")    
    ln = ln + 1
    if(szRetval == "VOID")
    {	    
	    InsBufLine(hOutbuf, ln, "    return ;")    
        ln = ln + 1
    }
    else if(szRetval == "ULONG")
    {	    
	    InsBufLine(hOutbuf, ln, "    return ERROR_OK;")    
        ln = ln + 1
    }
    else if(szRetval == "BOOL")
    {	    
	    InsBufLine(hOutbuf, ln, "    return TRUE;")    
        ln = ln + 1
    }
    else if(szRetval == "BOOL_T")
    {	    
	    InsBufLine(hOutbuf, ln, "    return BOOL_TRUE;")    
        ln = ln + 1
    }
    else
    {	    
	    InsBufLine(hOutbuf, ln, "    return ERROR_OK;")    
        ln = ln + 1
    }
    InsBufLine(hOutbuf, ln, "}")    
    ln = ln + 1
    
    return ln
}


/*****************************************************************************
 �� �� ��  : CreateFuncPrototype
 ��������  : ����C����ԭ�Ͷ���
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             szType    ԭ������
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFuncPrototype(hbuf,ln,szType,symbol)
{
    isLastLine = 0
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf,symbol.lnName)
    //ȥ��ע�͵ĸ���
    RetVal = SkipCommentFromString(szLine,fIsEnd)
    szNew = RetVal.szContent
    fIsEnd = RetVal.fIsEnd
    szLine = cat("@szType@ ",szLine)
    szNew = cat("@szType@ ",szNew)
    sline = symbol.lnFirst     
    while((isLastLine == 0) && (sline < symbol.lnLim))
    {   
        i = 0
        j = 0
        iLen = strlen(szNew)
        while(i < iLen)
        {
            if(szNew[i]=="(")
            {
               j = j + 1;
            }
            else if(szNew[i]==")")
            {
                j = j - 1;
                if(j <= 0)
                {
                    //��������ͷ����
                    isLastLine = 1  
                    //ȥ����������ַ�
        	        szLine = strmid(szLine,0,i+1);
                    szLine = cat(szLine,";")
                    break
                }
            }
            i = i + 1
        }
        InsBufLine(hOutbuf, ln, "@szLine@")
        ln = ln + 1
        sline = sline + 1
        if(isLastLine != 1)
        {              
            //��������ͷ��û�н�����ȡһ��
            szLine = GetBufLine (hbuf, sline)
            szLine = cat("         ",szLine)
            //ȥ��ע�͵ĸ���
            RetVal = SkipCommentFromString(szLine,fIsEnd)
	        szNew = RetVal.szContent
	        fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}

/*****************************************************************************
 �� �� ��  : FuncCodeStatistic
 ��������  : ����C������׮����
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             szType    ԭ������
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2007��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FuncCodeStatistic(hbuf,hOutbuf,symbol)
{
    isLastLine = 0
//    hOutbuf = GetCurrentBuf()
    iCodeline = 0;
    bNeedStat = 1;
    sline = symbol.lnFirst
    while(sline < symbol.lnLim)
    {   
        //������û�н�����ȡһ��
        szLine = GetBufLine (hbuf, sline)

        //ȥ��ע�͵ĸ���
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szNew = RetVal.szContent
        szNew = TrimString(szNew)
        if ( strlen(szNew) == 0 )
        {
	        fIsEnd = RetVal.fIsEnd
	        sline = sline + 1
	        continue
        }
        if (bNeedStat == 1)
        {
	        if (GetFirstWord(szNew)== "#if")
	        {
	            szNew[0] = " "
	            szNew[1] = " "
	            szNew[2] = " "
		        if (GetFirstWord(szNew)== "0")
		        {
		        
		            bNeedStat = 0
		        }
	        
	        }
        }
        else 
        {

	        if (GetFirstWord(szNew)== "#endif")
	        {
	            bNeedStat = 1
		        fIsEnd = RetVal.fIsEnd
		        sline = sline + 1
	            continue
	        }
        }
        
        if(bNeedStat == 1)
        {
            iCodeline = iCodeline + 1
        }

        fIsEnd = RetVal.fIsEnd
        sline = sline + 1
    }
    sline = symbol.lnFirst
    symname = symbol.Symbol
    iLen = strlen(symname);
    if(iLen > 40)
    {
	    AppendBufLine(hOutbuf,"@symname@\t@iCodeline@\t\t@sline@")    
    }
    else
    {
	    symname = cat(symname,"                                      ")
	    symname = strtrunc(symname, 40);
    }
    AppendBufLine(hOutbuf,"@symname@\t@iCodeline@\t\t@sline@")
    return
}


/*****************************************************************************
 �� �� ��  : CreateCodeStatistic
 ��������  : ���ɻ��ں����Ĵ���ͳ���ļ�
 �������  : hbuf      
             szName    
             language  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2007��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateCodeStatistic( )
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    ln = 0

    //��õ�ǰû�к�׺���ļ���
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("�������ļ���")
        szFileName = GetFileNameNoExt(sz)
    }
    sz = cat(szFileName,".sta")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //�������ű�ȡ�ú�����
    SetCurrentBuf(hOutbuf)
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
				szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
			    InsBufLine(hOutbuf, ln, "{")
			    InsBufLine(hOutbuf, ln, "class @szClassName@")
			    ln = ln + 2
		    	while (ichild < cchild)
				{
					childsym = SymListItem(hsyml, ichild)
					childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
		        ln = ln + 2
	        }
            else if( symbol.Type == "Function" )
            {
                FuncCodeStatistic(hbuf,hOutbuf,symbol)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName.word
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
            
        }
        isym = isym + 1
    }
}

/*****************************************************************************
 �� �� ��  : CreateNewHeaderFile
 ��������  : ����һ���µ�ͷ�ļ����ļ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateNewHeaderFile()
{
    hbuf = GetCurrentBuf()
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szName = getreg(MYNAME)
    if(strlen( szName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    ln = 0
    //��õ�ǰû�к�׺���ļ���
    sz = ask("Please input header file name")
    szFileName = GetFileNameNoExt(sz)
    szExt = GetFileNameExt(sz)        
    szPreH = toupper (szFileName)
    szPreH = cat("__",szPreH)
    szExt = toupper(szExt)
    szPreH = cat(szPreH,"_@szExt@__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop

    SetCurrentBuf(hOutbuf)
    InsertCPP(hOutbuf,0)
    HeadIfdefStr(szPreH)


    szVersion = getreg(VERSION)
    if(strlen(szVersion) == 0)
    {
    	szVersion = Ask("Please input project code(such as Comware):")
    	setreg(VERSION,szVersion)
    }
    
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")

        //�����ļ�ͷ˵��
        InsertFileHeaderCN(hOutbuf,0,szName,szContent, 0, szVersion)
    }
    else
    {
        szContent = cat(szContent," header file")

        //�����ļ�ͷ˵��
        InsertFileHeaderEN(hOutbuf,0,szName,szContent, 0, szVersion)        
    }

    lnMax = GetBufLineCount(hOutbuf)
    if(lnMax > 9)
    {
        ln = lnMax - 9
    }
    else
    {
        return
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.lnFirst = ln
    sel.ichFirst = 0
    sel.ichLim = 0
    SetBufIns(hOutbuf,ln,0)
    szType = Ask ("Please prototype type : extern or static")
    //�������ű�ȡ�ú�����
    //z06321�޸���һ��
    ln = ln + 2
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
	        {
		        hsyml = SymbolChildren(symbol)
				cchild = SymListCount(hsyml)
				ichild = 0
				szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
			    InsBufLine(hOutbuf, ln, "{")
			    InsBufLine(hOutbuf, ln, "class @szClassName@")
			    ln = ln + 2
		    	while (ichild < cchild)
				{
					childsym = SymListItem(hsyml, ichild)
					childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
					ichild = ichild + 1
				}
		        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
		        ln = ln + 2
	        }
            else if( symbol.Type == "Function" )
            {
                ln = CreateFuncPrototype(hbuf,ln,szType,symbol)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName.word
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
        }
        isym = isym + 1
    }
    sel.lnLast = ln 
    SetWndSel(hwnd,sel)
}


/*   G E T   W O R D   L E F T   O F   I C H   */
/*-------------------------------------------------------------------------
    Given an index to a character (ich) and a string (sz),
    return a "wordinfo" record variable that describes the 
    text word just to the left of the ich.

    Output:
        wordinfo.szWord = the word string
        wordinfo.ich = the first ich of the word
        wordinfo.ichLim = the limit ich of the word
-------------------------------------------------------------------------*/
macro GetWordLeftOfIch(ich, sz)
{
    wordinfo = "" // create a "wordinfo" structure
    
    chTab = CharFromAscii(9)
    
    // scan backwords over white space, if any
    ich = ich - 1;
    if (ich >= 0)
        while (sz[ich] == " " || sz[ich] == chTab)
        {
            ich = ich - 1;
            if (ich < 0)
                break;
        }
    
    // scan backwords to start of word    
    ichLim = ich + 1;
    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    while (ich >= 0)
    {
        ch = toupper(sz[ich])
        asciiCh = AsciiFromChar(ch)
        
/*        if ((asciiCh < asciiA || asciiCh > asciiZ)
             && !IsNumber(ch)
             &&  (ch != "#") )
            break // stop at first non-identifier character
*/
        //ֻ��ȡ�ַ���# { / *��Ϊ����
        if ((asciiCh < asciiA || asciiCh > asciiZ) 
           && !IsNumber(ch)
           && ( ch != "#" && ch != "{" && ch != "/" && ch != "*"))
            break;

        ich = ich - 1;
    }
    
    ich = ich + 1
    wordinfo.szWord = strmid(sz, ich, ichLim)
    wordinfo.ich = ich
    wordinfo.ichLim = ichLim;
    
    return wordinfo
}


/*****************************************************************************
 �� �� ��  : ReplaceBufTab
 ��������  : �滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceBufTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    nBlank = Ask("һ��Tab�滻�����ո�")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)
    ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
}

/*****************************************************************************
 �� �� ��  : ReplaceTabInProj
 ��������  : �������������滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    nBlank = Ask("һ��Tab�滻�����ո�")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)

    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            iTotalLn = GetBufLineCount (hbuf)
            ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
        }
        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : ReplaceInBuf
 ��������  : �滻tabΪ�ո�,ֻ��2.1����Ч
 �������  : hbuf             
             chOld            
             chNew            
             nBeg             
             nEnd             
             fMatchCase       
             fRegExp          
             fWholeWordsOnly  
             fConfirm         
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceInBuf(hbuf,chOld,chNew,nBeg,nEnd,fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    sel.ichLim = 0
    sel.lnLast = 0
    sel.ichFirst = sel.ichLim
    sel.lnFirst = sel.lnLast
    SetWndSel(hwnd, sel)
    LoadSearchPattern(chOld, 0, 0, 0);
    while(1)
    {
        Search_Forward
        selNew = GetWndSel(hwnd)
        if(sel == selNew)
        {
            break
        }
        SetBufSelText(hbuf, chNew)
           selNew.ichLim = selNew.ichFirst 
        SetWndSel(hwnd, selNew)
        sel = selNew
    }
}


macro ReplaceTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    ln = 0;
    lnLast = sel.lnLast
    while(sel.lnFirst <= lnLast)
    {
        szLine = GetBufLine(hbuf,sel.lnFirst)
        sel.ichFirst = 0
        sel.lnLast = sel.lnFirst
        ich = 0
        iLen = strlen (szLine)
        while (ich < iLen )
        {
            if (szLine [ ich ] == "\t")
            {
                sel.ichLim = sel.ichFirst + 1
                SetWndSel(hwnd,sel)
                SetBufSelText(hbuf,"    ")
                sel.ichFirst = sel.ichFirst + 3
            }
            ich = ich + 1
            sel.ichFirst = sel.ichFirst + 1
        }        
        sel.lnFirst = sel.lnFirst + 1
    }
}

/*****************************************************************************
 �� �� ��  : ConfigureSystem
 ��������  : ����ϵͳ
 �������  : ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���
  2.��    ��   : 2005��11��16��
    ��    ��   : ����
    �޸�����   : ��COMWARE�����淶�޸ġ�
*****************************************************************************/
macro ConfigureSystem()
{
    szLanguage = ASK("Please select language: 0 Chinese ,1 English");
    if(szLanguage == "#")
    {
       SetReg ("LANGUAGE", "0")
    }
    else
    {
       SetReg ("LANGUAGE", szLanguage)
    }
    
    szName = ASK("Please input your name");
    if(szName == "#")
    {
       SetReg ("MYNAME", "")
    }
    else
    {
       SetReg ("MYNAME", szName)
    }

    szVersion = ASK("Please input project code(such as Comware):");
    if(szVersion == "#")
    {
       SetReg ("VERSION", "")
    }
    else
    {
       SetReg ("VERSION", szVersion)
    }

}

/*****************************************************************************
 �� �� ��  : GetLeftBlank
 ��������  : �õ��ַ�����ߵĿո��ַ���
 �������  : szLine  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetLeftBlank(szLine)
{
    nIdx = 0
    nEndIdx = strlen(szLine)
    while( nIdx < nEndIdx )
    {
        if( (szLine[nIdx] !=" ") && (szLine[nIdx] !="\t") )
        {
            break;
        }
        nIdx = nIdx + 1
    }
    return nIdx
}

/*****************************************************************************
 �� �� ��  : ExpandBraceLittle
 ��������  : С������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLittle()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast) 
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "()")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 1)    
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)    
        SetBufSelText (hbuf, "(")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 1)    
        SetBufSelText (hbuf, ")")
    }
    
}

/*****************************************************************************
 �� �� ��  : ExpandBraceMid
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceMid()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast) 
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "[]")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 1)    
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)    
        SetBufSelText (hbuf, "[")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 1)    
        SetBufSelText (hbuf, "]")
    }
    
}

/*****************************************************************************
 �� �� ��  : ExpandBraceLarge
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLarge()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    nlineCount = 0
    retVal = ""
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    szRight = ""
    szMid = ""
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        //����û�п�ѡ��������ֱ�Ӳ���{}����
        if( nLeft == strlen(szLine) )
        {
            SetBufSelText (hbuf, "{")
        }
        else
        {    
            ln = ln + 1        
            InsBufLine(hbuf, ln, "@szLeft@{")     
            nlineCount = nlineCount + 1

        }
        InsBufLine(hbuf, ln + 1, "@szLeft@    ")
        InsBufLine(hbuf, ln + 2, "@szLeft@}")
        nlineCount = nlineCount + 2
        SetBufIns (hbuf, ln + 1, strlen(szLeft)+4)
    }
    else
    {
        //�����п�ѡ���������ÿ��ǽ���ѡ�����ֿ���
        
        //���ѡ�������Ƿ��������ԣ������̫����ע�͵�������ж�
        RetVal= CheckBlockBrace(hbuf)
        if(RetVal.iCount != 0)
        {
            msg("Invalidated brace number")
            stop
        }
        
        //ȡ��ѡ����ǰ������
        szOld = strmid(szLine,0,sel.ichFirst)
        if(sel.lnFirst != sel.lnLast)
        {
            //���ڶ��е����
            
            //��һ�е�ѡ�в���
            szMid = strmid(szLine,sel.ichFirst,strlen(szLine))
            szMid = TrimString(szMid)
            szLast = GetBufLine(hbuf,sel.lnLast)
            if( sel.ichLim > strlen(szLast) )
            {
                //���ѡ�������ȴ��ڸ��еĳ��ȣ����ȡ���еĳ���
                szLineselichLim = strlen(szLast)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            
            //�õ����һ��ѡ����Ϊ���ַ�
            szRight = strmid(szLast,szLineselichLim,strlen(szLast))
            szRight = TrimString(szRight)
        }
        else
        {
            //����ѡ��ֻ��һ�е����
             if(sel.ichLim >= strlen(szLine))
             {
                 sel.ichLim = strlen(szLine)
             }
             
             //���ѡ����������
             szMid = strmid(szLine,sel.ichFirst,sel.ichLim)
             szMid = TrimString(szMid)            
             if( sel.ichLim > strlen(szLine) )
             {
                 szLineselichLim = strlen(szLine)
             }
             else
             {
                 szLineselichLim = sel.ichLim
             }
             
             //ͬ���õ�ѡ�����������
             szRight = strmid(szLine,szLineselichLim,strlen(szLine))
             szRight = TrimString(szRight)
        }
        nIdx = sel.lnFirst
        while( nIdx < sel.lnLast)
        {
            szCurLine = GetBufLine(hbuf,nIdx+1)
            if( sel.ichLim > strlen(szCurLine) )
            {
                szLineselichLim = strlen(szCurLine)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            szCurLine = cat("    ",szCurLine)
            if(nIdx == sel.lnLast - 1)
            {
                //�������һ��Ӧ����ѡ�����ڵ����ݺ�����λ
                szCurLine = strmid(szCurLine,0,szLineselichLim + 4)
                PutBufLine(hbuf,nIdx+1,szCurLine)                    
            }
            else
            {
                //������������е����ݺ�����λ
                PutBufLine(hbuf,nIdx+1,szCurLine)
            }
            nIdx = nIdx + 1
        }
        if(strlen(szRight) != 0)
        {
            //���������һ��û�б�ѡ�������
            InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@@szRight@")        
        }
        InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@}")        
        nlineCount = nlineCount + 1
        if(nLeft < sel.ichFirst)
        {
            //���ѡ����ǰ�����ݲ��ǿո���Ҫ�����ò�������
            PutBufLine(hbuf,ln,szOld)
            InsBufLine(hbuf, ln+1, "@szLeft@{")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }
        else
        {
            //���ѡ����ǰû������ֱ��ɾ������
            DelBufLine(hbuf,ln)
            InsBufLine(hbuf, ln, "@szLeft@{")
        }
        if(strlen(szMid) > 0)
        {
            //�����һ��ѡ����������
            InsBufLine(hbuf, ln+1, "@szLeft@    @szMid@")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }        
    }
    retVal.szLeft = szLeft
    retVal.nLineCount = nlineCount
    //������������ߵĿհ�
    return retVal
}

/*
macro ScanStatement(szLine,iBeg)
{
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen -1)
    {
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "/")
        {
            return 0xffffffff
        }
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "*")
        {
           while(nIdx < iLen)
           {
               if(szLine[nIdx] == "*" && szLine[nIdx + 1] == "/")
               {
                   break
               }
               nIdx = nIdx + 1
               
           }
        }
        if( (szLine[nIdx] != " ") && (szLine[nIdx] != "\t" ))
        {
            return nIdx
        }
        nIdx = nIdx + 1
    }
    if( (szLine[iLen -1] == " ") || (szLine[iLen -1] == "\t" ))
    {
        return 0xffffffff
    }
    return nIdx
}
*/
/*
macro MoveCommentLeftBlank(szLine)
{
    nIdx  = 0
    iLen = strlen(szLine)
    while(nIdx < iLen - 1)
    { 
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "*")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "*"
                    return szLine
                }
                nIdx = nIdx + 1
            }
        
        }
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "/"
                    return szLine
                }
                nIdx = nIdx + 1
            }
        
        }
        nIdx = nIdx + 1
    }
    return szLine
}*/

/*****************************************************************************
 �� �� ��  : DelCompoundStatement
 ��������  : ɾ��һ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro DelCompoundStatement()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine(hbuf,ln )
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    Msg("@szLine@  will be deleted !")
    fIsEnd = 1
    while(1)
    {
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //���Ҹ������Ŀ�ʼ
        ret = strstr(szTmp,"{")
        if(ret != 0xffffffff)
        {
            szNewLine = strmid(szLine,ret+1,strlen(szLine))
            szNew = strmid(szTmp,ret+1,strlen(szTmp))
            szNew = TrimString(szNew)
            if(szNew != "")
            {
                InsBufLine(hbuf,ln + 1,"@szLeft@    @szNewLine@");
            }
            sel.lnFirst = ln
            sel.lnLast = ln
            sel.ichFirst = ret
            sel.ichLim = ret
            //���Ҷ�Ӧ�Ĵ�����
            
            //ʹ���Լ���д�Ĵ����ٶ�̫��
/*            retTmp = SearchCompoundEnd(hbuf,ln,ret)
            if(retTmp.iCount == 0)
            {
                
                DelBufLine(hbuf,retTmp.ln)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = retTmp.ln - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }*/
            
            //ʹ��Si�Ĵ�������Է�������V2.1ʱ��ע��Ƕ��ʱ��������
            SetWndSel(hwnd,sel)
            Block_Down
            selNew = GetWndSel(hwnd)
            if(selNew != sel)
            {
                
                DelBufLine(hbuf,selNew.lnFirst)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = selNew.lnFirst - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }
            break
        }
        szTmp = TrimString(szTmp)
        iLen = strlen(szTmp)
        if(iLen != 0)
        {
            if(szTmp[iLen-1] == ";")
            {
                break
            }
        }
        DelBufLine(hbuf,ln)   
        if( ln == GetBufLineCount(hbuf ))
        {
             break
        }
        szLine = GetBufLine(hbuf,ln)
    }
}

/*****************************************************************************
 �� �� ��  : CheckBlockBrace
 ��������  : ��ⶨ����еĴ�����������
 �������  : hbuf  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBlockBrace(hbuf)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    RetVal = ""
    szLine = GetBufLine( hbuf, ln )    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        RetVal.iCount = 0
        RetVal.ich = sel.ichFirst
        return RetVal
    }
    if(sel.lnFirst == sel.lnLast && sel.ichFirst != sel.ichLim)
    {
        RetTmp = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetTmp.szContent
        RetVal = CheckBrace(szTmp,sel.ichFirst,sel.ichLim,"{","}",0,1)
        return RetVal
    }
    if(sel.lnFirst != sel.lnLast)
    {
	    fIsEnd = 1
	    while(ln <= sel.lnLast)
	    {
	        if(ln == sel.lnFirst)
	        {
	            RetVal = CheckBrace(szLine,sel.ichFirst,strlen(szLine)-1,"{","}",nCount,fIsEnd)
	        }
	        else if(ln == sel.lnLast)
	        {
	            RetVal = CheckBrace(szLine,0,sel.ichLim,"{","}",nCount,fIsEnd)
	        }
	        else
	        {
	            RetVal = CheckBrace(szLine,0,strlen(szLine)-1,"{","}",nCount,fIsEnd)
	        }
	        fIsEnd = RetVal.fIsEnd
	        ln = ln + 1
	        nCount = RetVal.iCount
	        szLine = GetBufLine( hbuf, ln )    
	    }
    }
    return RetVal
}

/*****************************************************************************
 �� �� ��  : SearchCompoundEnd
 ��������  : ����һ���������Ľ�����
 �������  : hbuf    
             ln      ��ѯ��ʼ��
             ichBeg  ��ѯ��ʼ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchCompoundEnd(hbuf,ln,ichBeg)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    SearchVal = ""
//    szLine = GetBufLine( hbuf, ln )
    lnMax = GetBufLineCount(hbuf)
    fIsEnd = 1
    while(ln < lnMax)
    {
        szLine = GetBufLine( hbuf, ln )
        RetVal = CheckBrace(szLine,ichBeg,strlen(szLine)-1,"{","}",nCount,fIsEnd)
        fIsEnd = RetVal.fIsEnd
        ichBeg = 0
        nCount = RetVal.iCount
        
        //���nCount=0��˵��{}����Ե�
        if(nCount == 0)
        {
            break
        }
        ln = ln + 1
//        szLine = GetBufLine( hbuf, ln )    
    }
    SearchVal.iCount = RetVal.iCount
    SearchVal.ich = RetVal.ich
    SearchVal.ln = ln
    return SearchVal
}

/*****************************************************************************
 �� �� ��  : CheckBrace
 ��������  : ������ŵ�������
 �������  : szLine       �����ַ���
             ichBeg       �����ʼ
             ichEnd       ������
             chBeg        ��ʼ�ַ�(������)
             chEnd        �����ַ�(������)
             nCheckCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/

macro CheckBraceOld(szLine,ichBeg,ichEnd,chBeg,chEnd,nCheckCount,isCommentEnd)
{
    retVal = ""
    retVal.ich = 0
    nIdx = ichBeg
    nLen = strlen(szLine)
    if(ichEnd >= nLen)
    {
        ichEnd = nLen - 1
    }
    fIsEnd = 1
    while(nIdx <= ichEnd)
    {
        //�����/*ע�����������ö�
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx <= ichEnd )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                nIdx = nIdx + 1 
            }
            if(nIdx > ichEnd)
            {
                break
            }
        }
        //�����//ע����ֹͣ����
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            break
        }
        if(szLine[nIdx] == chBeg)
        {
            nCheckCount = nCheckCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            nCheckCount = nCheckCount - 1
            if(nCheckCount == 0)
            {
                retVal.ich = nIdx
            }
        }
        nIdx = nIdx + 1
    }
    retVal.iCount = nCheckCount
    retVal.fIsEnd = fIsEnd
    return retVal
}


/*****************************************************************************
 �� �� ��  : CheckBrace
 ��������  : ������ŵ�������
 �������  : szLine       �����ַ���
             ichBeg       �����ʼ
             ichEnd       ������
             chBeg        ��ʼ�ַ�(������)
             chEnd        �����ַ�(������)
             nCheckCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBrace(szLine,ichBeg,ichEnd,chBeg,chEnd,nCheckCount,isCommentEnd)
{
    retVal = ""
    retVal.ich = 0
    nIdx = ichBeg
    nLen = strlen(szLine)
    if(ichEnd >= nLen)
    {
        ichEnd = nLen - 1
    }
    fIsEnd = 1
    while(nIdx <= ichEnd)
    {
        //�����/*ע�����������ö�
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx <= ichEnd )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                nIdx = nIdx + 1 
            }
            if(nIdx > ichEnd)
            {
                break
            }
        }

        //�����"�ַ����������ö�
        else if( (szLine[nIdx] != "\\") && (szLine[nIdx+1] == "'"))
        {
            while(nIdx <= ichEnd )
            {
                if((szLine[nIdx] != "\\") && szLine[nIdx+1] == "'")
                {
                    nIdx = nIdx + 1 
                    break
                }
                nIdx = nIdx + 1 
            }
            if(nIdx > ichEnd)
            {
                break
            }
        }

        //�����"�ַ����������ö�
        else if( (szLine[nIdx] != "\\") && (szLine[nIdx+1] == '"'))
        {
            while(nIdx <= ichEnd )
            {
                if((szLine[nIdx] != "\\") && szLine[nIdx+1] == '"')
                {
                    nIdx = nIdx + 1 
                    break
                }
                nIdx = nIdx + 1 
            }
            if(nIdx > ichEnd)
            {
                break
            }
        }
        //�����//ע����ֹͣ����
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            break
        }
        if(szLine[nIdx] == chBeg)
        {
            nCheckCount = nCheckCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            nCheckCount = nCheckCount - 1
            if(nCheckCount == 0)
            {
                retVal.ich = nIdx
            }
        }
        nIdx = nIdx + 1
    }
    retVal.iCount = nCheckCount
    retVal.fIsEnd = fIsEnd
    return retVal
}

/*****************************************************************************
 �� �� ��  : InsertElse
 ��������  : ����else���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertElse()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@else")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    ")
        SetBufIns (hbuf, ln+2, strlen(szLeft)+4)
        return
    }
    SetBufIns (hbuf, ln, strlen(szLeft)+7)
}

/*****************************************************************************
 �� �� ��  : InsertCase
 ��������  : ����case���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCase()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@" # "case # :")
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "    " # "#")
    InsBufLine(hbuf, ln + 2, "@szLeft@" # "    " # "break;")
    SearchForward()    
}

/*****************************************************************************
 �� �� ��  : InsertSwitch
 ��������  : ����swich���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertSwitch()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@switch (#)")    
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "{")
    nSwitch = ask("������case�ĸ���")
    InsertMultiCaseProc(hbuf,szLeft,nSwitch)
    SearchForward()    
}

/*****************************************************************************
 �� �� ��  : InsertMultiCaseProc
 ��������  : ������case
 �������  : hbuf     
             szLeft   
             nSwitch  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertMultiCaseProc(hbuf,szLeft,nSwitch)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst

    nIdx = 0
    if(nSwitch == 0)
    {
        hNewBuf = newbuf("clip")
        if(hNewBuf == hNil)
            return       
        SetCurrentBuf(hNewBuf)
        PasteBufLine (hNewBuf, 0)
        nLeftMax = 0
        lnMax = GetBufLineCount(hNewBuf )
        i = 0
        fIsEnd = 1
        while ( i < lnMax) 
        {
            szLine = GetBufLine(hNewBuf , i)
            //��ȥ��������ע�͵�����
            RetVal = SkipCommentFromString(szLine,fIsEnd)
            szLine = RetVal.szContent
            fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
            //�Ӽ�������ȡ��caseֵ
            szLine = GetSwitchVar(szLine)
            if(strlen(szLine) != 0 )
            {
                ln = ln + 5
                InsBufLine(hbuf, ln - 3, "@szLeft@    " # "case @szLine@:")
                InsBufLine(hbuf, ln - 2, "@szLeft@    " # "{")
                InsBufLine(hbuf, ln - 1, "@szLeft@    " # "    ")
                InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # "break;")
                InsBufLine(hbuf, ln + 1, "@szLeft@    " # "}")
              }
              i = i + 1
        }
        closebuf(hNewBuf)
       }
       else
       {
        while(nIdx < nSwitch)
        {
            ln = ln + 5
            InsBufLine(hbuf, ln - 3, "@szLeft@    " # "case :")
            InsBufLine(hbuf, ln - 2, "@szLeft@    " # "{")
            InsBufLine(hbuf, ln - 1, "@szLeft@    " # "    ")
            InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # "break;")
            InsBufLine(hbuf, ln + 1, "@szLeft@    " # "}")
            nIdx = nIdx + 1
        }
      }
    InsBufLine(hbuf, ln + 2, "@szLeft@    " # "default:")
    InsBufLine(hbuf, ln + 3, "@szLeft@    " # "{")
    InsBufLine(hbuf, ln + 4, "@szLeft@    " # "    ")
    InsBufLine(hbuf, ln + 5, "@szLeft@    " # "    " # "break;")
    InsBufLine(hbuf, ln + 6, "@szLeft@    " # "}")
    InsBufLine(hbuf, ln + 7, "@szLeft@" # "}")

    SetWndSel(hwnd, sel)
    SearchForward()
}


macro InsertstructelemProc(hbuf,szLeft)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nIdx = 0
    hNewBuf = newbuf("clip")
    if(hNewBuf == hNil)
        return       
    SetCurrentBuf(hNewBuf)
    PasteBufLine (hNewBuf, 0)
    nLeftMax = 0
    lnMax = GetBufLineCount(hNewBuf )
    i = 0
    fIsEnd = 1
    str = Ask("Please input struct prefix")
    while ( i < lnMax) 
    {
        szLine = GetBufLine(hNewBuf , i)
        //��ȥ��������ע�͵�����
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
        //�Ӽ�������ȡ��caseֵ
        szLine = GetSwitchVar(szLine)
        if(strlen(szLine) != 0 )
        {
            InsBufLine(hbuf, ln, "@szLeft@" # "@str@" # "@szLine@")
        }
        i = i + 1
    }
    closebuf(hNewBuf)
}

/*****************************************************************************
 �� �� ��  : GetSwitchVar
 ��������  : ��ö�١��궨��ȡ��caseֵ
 �������  : szLine  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetSwitchVar(szLine)
{
    if( (szLine == "{") || (szLine == "}") )
    {
        return ""
    }
    ret = strstr(szLine,"#define" )
    if(ret != 0xffffffff)
    {
        szLine = strmid(szLine,ret + 8,strlen(szLine))
    }
    szLine = TrimLeft(szLine)
    nIdx = 0
    nLen = strlen(szLine)
    while( nIdx < nLen)
    {
        if((szLine[nIdx] == " ") || (szLine[nIdx] == ",") || (szLine[nIdx] == "="))
        {
            szLine = strmid(szLine,0,nIdx)
            return szLine
        }
        nIdx = nIdx + 1
    }
    return szLine
}

/*
macro SkipControlCharFromString(szLine)
{
   nLen = strlen(szLine)
   nIdx = 0
   newStr = ""
   while(nIdx < nLen - 1)
   {
       if(szLine[nIdx] == "\t")
       {
           newStr = cat(newStr,"    ")
       }
       else if(szLine[nIdx] < " ")
       {
           newStr = cat(newStr," ")           
       }
       else
       {
           newStr = cat(newStr," ")                      
       }
   }
}
*/
/*****************************************************************************
 �� �� ��  : SkipCommentFromString
 ��������  : ȥ��ע�͵����ݣ���ע��������Ϊ�ո�
 �������  : szLine        �����е�����
             isCommentEnd  �Ƿ�ǰ�еĿ�ʼ�Ѿ���ע�ͽ�����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen )
    {
        //�����ǰ�п�ʼ���Ǳ�ע�ͣ���������ע�Ϳ�ʼ�ı��ǣ�ע�����ݸ�Ϊ�ո�?
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx < nLen )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    szLine[nIdx+1] = " "
                    szLine[nIdx] = " " 
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                szLine[nIdx] = " "
                
                //����ǵ����ڶ��������һ��Ҳ�϶�����ע����
//                if(nIdx == nLen -2 )
//                {
//                    szLine[nIdx + 1] = " "
//                }
                nIdx = nIdx + 1 
            }    
            
            //����Ѿ�������β��ֹ����
            if(nIdx == nLen)
            {
                break
            }
        }
        
        //�����������//��ע�͵�˵�����涼Ϊע��
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine = strmid(szLine,0,nIdx)
            break
        }
        nIdx = nIdx + 1                
    }
    RetVal.szContent = szLine;
    RetVal.fIsEnd = fIsEnd
    return RetVal
}

/*****************************************************************************
 �� �� ��  : InsertDo
 ��������  : ����Do���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertDo()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+1, "@szLeft@    #")
    }
    PutBufLine(hbuf, sel.lnLast + val.nLineCount, "@szLeft@}while (#);")    
//       SetBufIns (hbuf, sel.lnLast + val.nLineCount, strlen(szLeft)+8)
    InsBufLine(hbuf, ln, "@szLeft@do")    
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertWhile
 ��������  : ����While���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertWhile()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@while (#)")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
    SetBufIns (hbuf, ln, strlen(szLeft)+7)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertFor
 ��������  : ����for���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFor()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln,"@szLeft@for (#; #; #)")
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
    sel.lnFirst = ln
    sel.lnLast = ln 
    sel.ichFirst = 0
    sel.ichLim = 0
    SetWndSel(hwnd, sel)
    SearchForward()
    szVar = ask("������ѭ������")
    PutBufLine(hbuf,ln, "@szLeft@for (@szVar@ = #; @szVar@#; @szVar@++)")
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertIf
 ��������  : ����If���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertIf()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@if (#)")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
//       SetBufIns (hbuf, ln, strlen(szLeft)+4)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : MergeString
 ��������  : ���������е����ϲ���һ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro MergeString()
{
    hbuf = newbuf("clip")
    if(hbuf == hNil)
        return       
    SetCurrentBuf(hbuf)
    PasteBufLine (hbuf, 0)
    
    //�����������û�����ݣ��򷵻�
    lnMax = GetBufLineCount(hbuf )
    if( lnMax == 0 )
    {
        closebuf(hbuf)
        return ""
    }
    lnLast =  0
    if(lnMax > 1)
    {
        lnLast = lnMax - 1
         i = lnMax - 1
    }
    while ( i > 0) 
    {
        szLine = GetBufLine(hbuf , i-1)
        szLine = TrimLeft(szLine)
        nLen = strlen(szLine)
        if(szLine[nLen - 1] == "-")
        {
              szLine = strmid(szLine,0,nLen - 1)
        }
        nLen = strlen(szLine)
        if( (szLine[nLen - 1] != " ") && (AsciiFromChar (szLine[nLen - 1])  <= 160))
        {
              szLine = cat(szLine," ") 
        }
        SetBufIns (hbuf, lnLast, 0)
        SetBufSelText(hbuf,szLine)
        i = i - 1
    }
    szLine = GetBufLine(hbuf,lnLast)
    closebuf(hbuf)
    return szLine
}

/*****************************************************************************
 �� �� ��  : ClearPrombleNo
 ��������  : ������ⵥ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ClearPrombleNo()
{
   SetReg ("PNO", "")
}

/*****************************************************************************
 �� �� ��  : AddPromblemNo
 ��������  : ������ⵥ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2002��12��26��
    ��    ��   : ����
    �޸�����   : �������ⵥ����

*****************************************************************************/
macro AddPromblemNo()
{
    szQuestion = ASK("Please Input problem number ");
    if(szQuestion == "#")
    {
       szQuestion = ""
       SetReg ("PNO", "")
    }
    else
    {
       SetReg ("PNO", szQuestion)
    }
    return szQuestion
}

/*****************************************************************************
 �� �� ��  : AddPNDescription
 ��������  : ������ⵥ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ����
    �޸�����   : �����ɺ���

*****************************************************************************/

macro AddPNDescription()
{
    szQuestion = ASK("Please Input problem Description ");
    if(szQuestion == "#")
    {
       szQuestion = ""
       SetReg ("PNDes", "")
    }
    else
    {
       SetReg ("PNDes", szQuestion)
    }
    return szQuestion
}


/*
this macro convet selected  C++ coment block to C comment block 
for example:
  line "  // aaaaa "
  convert to  /* aaaaa */
*/
/*macro ComentCPPtoC()
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnLast = GetWndSelLnLast( hwnd )

    lnCurrent = lnFirst
    fIsEnd = 1
    while ( lnCurrent <= lnLast )
    {
        fIsEnd = CmtCvtLine( lnCurrent,fIsEnd )
        lnCurrent = lnCurrent + 1;
    }
}*/

/*****************************************************************************
 �� �� ��  : ComentCPPtoC
 ��������  : ת��C++ע��ΪCע��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��02��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���,֧�ֿ�ע��

*****************************************************************************/
macro ComentCPPtoC()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
    ch_comment = CharFromAscii(47)   
    isCommentEnd = 1
    isCommentContinue = 0
    while ( lnCurrent <= lnLast )
    {

        ich = 0
        szLine = GetBufLine(hbuf,lnCurrent)
        ilen = strlen(szLine)
        while ( ich < ilen )
        {
            if( (szLine[ich] != " ") && (szLine[ich] != "\t") )
            {
                break
            }
            ich = ich + 1
        }
        /*����ǿ��У���������*/
        if(ich == ilen)
        {         
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }
        
        /*�������ֻ��һ���ַ�*/
        if(ich > ilen - 2)
        {
            if( isCommentContinue == 1 )
            {
                szOldLine = cat(szOldLine,"  */")
                PutBufLine(hbuf,lnCurrent-1,szOldLine)
                isCommentContinue = 0
            }
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }       
        if( isCommentEnd == 1 )
        {
            /*���������ע������*/
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                
                /* ȥ���м�Ƕ�׵�ע�� */
                nIdx = ich + 2
                while ( nIdx < ilen -1 )
                {
                    if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                         ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                    {
                        szLine[nIdx] = " "
                        szLine[nIdx+1] = " "
                    }
                    nIdx = nIdx + 1
                }
                
                if( isCommentContinue == 1 )
                {
                    /* �����������ע��*/
                    szLine[ich] = " "
                    szLine[ich+1] = " "
                }
                else
                {
                    /*�������������ע��������ע�͵Ŀ�ʼ*/
                    szLine[ich] = "/"
                    szLine[ich+1] = "*"
                }
                if ( lnCurrent == lnLast )
                {
                    /*��������һ��������β��ӽ���ע�ͷ�*/
                    szLine = cat(szLine,"  */")
                    isCommentContinue = 0
                }
                /*���¸���*/
                PutBufLine(hbuf,lnCurrent,szLine)
                isCommentContinue = 1
                szOldLine = szLine
                lnCurrent = lnCurrent + 1
                continue 
            }
            else
            {   
                /*������е���ʼ����//ע��*/
                if( isCommentContinue == 1 )
                {
                    szOldLine = cat(szOldLine,"  */")
                    PutBufLine(hbuf,lnCurrent-1,szOldLine)
                    isCommentContinue = 0
                }
            }        
        }
        while ( ich < ilen - 1 )
        {
            //�����/*ע�����������ö�
            if( (isCommentEnd == 0) || (szLine[ich] == "/" && szLine[ich+1] == "*"))
            {
                isCommentEnd = 0
                while(ich < ilen - 1 )
                {
                    if(szLine[ich] == "*" && szLine[ich+1] == "/")
                    {
                        ich = ich + 1 
                        isCommentEnd = 1
                        break
                    }
                    ich = ich + 1 
                }
                if(ich >= ilen - 1)
                {
                    break
                }
            }
            
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                /* �����//ע��*/
                isCommentContinue = 1
                nIdx = ich
                //ȥ���ڼ��/* �� */ע�ͷ��������ע��Ƕ�״���
                while ( nIdx < ilen -1 )
                {
                    if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                         ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                    {
                        szLine[nIdx] = " "
                        szLine[nIdx+1] = " "
                    }
                    nIdx = nIdx + 1
                }
                szLine[ich+1] = "*"
                if( lnCurrent == lnLast )
                {
                    szLine = cat(szLine,"  */")
                }
                PutBufLine(hbuf,lnCurrent,szLine)
                break
            }
            ich = ich + 1
        }
        szOldLine = szLine
        lnCurrent = lnCurrent + 1
    }
}


/*****************************************************************************
 �� �� ��  : CommentLine
 ��������  : ��ѡ�������е���ע�Ϳ�����LLDתCODE
 �������  : �� 
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��8��10��
    ��    ��   : ¬ʤ��
    �޸�����   : ������

*****************************************************************************/
macro CommentLine()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
    
    ReplaceInBuf(hbuf,"\t","    ",0, lnLast, 1, 0, 0, 1)
    lnOld = 0
    while ( lnCurrent <= lnLast )
    {
        szLine = GetBufLine(hbuf,lnCurrent)
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            lnCurrent = lnCurrent + 1
            continue
        }
        else
        {
            InsBufLine(hbuf,lnCurrent,"")
            lnCurrent = lnCurrent + 1
            lnLast = lnLast + 1
        }
        DelBufLine(hbuf,lnCurrent)
        
        nIdx = 0
        
        //ȥ���ڼ��/* �� */ע�ͷ��������ע��Ƕ�״���
        while ( nIdx < ilen -1 )
        {
            if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                 ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
            {
                szLine[nIdx] = " "
                szLine[nIdx+1] = " "
            }
            nIdx = nIdx + 1
        }
        szLine = cat("/* ",szLine)
        lnOld = lnCurrent
        lnCurrent = CommentContent(hbuf,lnCurrent,szLeft,szLine,1,117)
        lnLast = lnCurrent - lnOld + lnLast
        lnCurrent = lnCurrent + 1
    }
}

macro CommentBlock()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
    while ( lnCurrent <= lnLast )
    {
        szLine = GetBufLine(hbuf,lnCurrent)
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft)
        nIdx = 0
        bNeedPut = 0
        ilen = strlen(szLine)
        //ȥ���ڼ��/* �� */ע�ͷ��������ע��Ƕ�״���
        while ( nIdx < ilen -1 )
        {
            if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                 ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
            {
                szLine[nIdx] = " "
                szLine[nIdx+1] = " "
                bNeedPut = 1
            }
            nIdx = nIdx + 1
        }
        if( lnCurrent == lnFirst )
        {
            SetBufIns(hbuf,lnCurrent,nLeft)
            SetBufSelText(hbuf, "/* ")
        }
        if ( lnCurrent == lnLast )
        {
            szLine = GetBufLine(hbuf,lnCurrent)
            szLine = TrimRight(szLine)
            iLen = strlen(szLine)
            szLine = cat(szLine," */")
            bNeedPut = 1
        }
        if (bNeedPut == 1)
        {
            PutBufLine(hbuf,lnCurrent,szLine)
        }
        bNeedPut = 0
        lnCurrent = lnCurrent + 1
    }
}

macro UncommentBlock()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    nTotal = GetBufLine( hbuf )
    lnCurrent = sel.lnFirst
    szLine = GetBufLine(hbuf,lnCurrent)
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft)
    szLine = TrimLeft(szLine)
    if( (szLine[0] == "/") && (szLine[1] == "*") )
    {
        sel.ichFirst = nLeft
        sel.ichLim = nLeft + 2
        SetWndSel(hwnd,sel)
        SetBufSelText(hbuf, "")
    }
    else
    {
        return
    }
    lnLast = GetWndSelLnLast( hwnd )
    while ( lnCurrent <= nTotal )
    {
        szLine = GetBufLine(hbuf,lnCurrent)
        nIdx = 0
        ilen = strlen(szLine)
        while ( nIdx < ilen -1 )
        {
            if( ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
            {
                szLine[nIdx] = " "
                szLine[nIdx+1] = " "
                return
            }
            nIdx = nIdx + 1
        }
     }
}

macro GetDirection()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    lnCurrent = 0
    iTotalLn = GetBufLineCount (hbuf)
    while ( lnCurrent < iTotalLn )
    {
        szLine = GetBufLine(hbuf,lnCurrent)
        ilen = strlen(szLine)
        lnFirst = strstr(szLine,"Directory of ")
        if(lnFirst != 0)
        {
            DelBufLine(hbuf,lnCurrent)
            iTotalLn = iTotalLn - 1
            continue
        }
        szLine = strmid(szline,13,iLen)
        PutBufLIne(hbuf,lnCurrent,"-i\"@szline@\"")
        lnCurrent = lnCurrent + 1
    }
}

/*****************************************************************************
 �� �� ��  : LLDToCode
 ��������  : ������Ϣ���ת��Ϊ���룬Ҫ����ϸ�����������tab����4���ո�
 �������  : �� 
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��8��10��
    ��    ��   : ¬ʤ��
    �޸�����   : ������

*****************************************************************************/
macro LLDToCode()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
//    lnTotal = GetBufLineCount(hbuf)
    ReplaceTab()
    //ReplaceInBuf(hbuf,"\t","    ",0, lnTotal, 1, 0, 0, 1)
    lnOld = 0
    szFirst = ""
    szLeftOld = ""
    nLeftOld = 0xffffffff
    nBegLeft = 100000
    while ( lnCurrent <= lnLast )
    {
        szLine = GetBufLine(hbuf,lnCurrent)
        nLeft = GetLeftBlank(szLine)
        if(nBegLeft > nLeft)
        {
            nBegLeft = nLeft
        }
        szLeft = strmid(szLine,0,nLeft);
        szLine = TrimString(szLine)
        szFirst = GetFirstKeyWord(szLine)
        szFirst = tolower( szFirst )
        ilen = strlen(szLine)
        iFirst = strlen(szFirst)
        szTemp = strmid(szLine,iFirst,ilen)
        szTemp = TrimLeft(szTemp)
        szSecond = GetFirstKeyWord(szTemp)
        szSecond = tolower(szSecond)
        if( iLen == 0 )
        {
            lnCurrent = lnCurrent + 1
            continue
        }
        else if(  szLine == "{" )
        {
            nLeftOld = 0xffffffff;
            lnCurrent = lnCurrent + 1
            continue;
        }
        else if(  szLine == "}"  )
        {
	        if( nLeftOld != 0xffffffff ) 
	        {
	            if( nLeftOld >= nLeft + 4 )
	            {
	                DelBufLine(hbuf,lnCurrent)        
                    lnLast = lnLast - 1
	                lnCurrent = lnCurrent - 1
	                while( nLeftOld >= nLeft + 4 )
	                {
	                    lnLast = lnLast + 1
	                    szLeftOld = strtrunc(szLeftOld,strlen(szLeftOld)-4)
	                    InsBufLine(hbuf,lnOld+1,"@szLeftOld@}")        
	                    lnOld = lnOld + 1
	                    nLeftOld = nLeftOld - 4
	                    lnCurrent = lnCurrent + 1
	                }
	            }
	            else
	            {
		            nLeftOld = 0xffffffff;
	            }
            }
            lnCurrent = lnCurrent + 1
            continue;
        }
        else if ( (ilen <= 9) && ( ( szFirst == "break" ) 
                  || ( szFirst == "do" ) || ( szFirst == "case" )
                  || ( szFirst == "continue" ) ) )
        {
	    }
        else if ( szFirst == "return" ) 
        {
        }
        else if ( (ilen == 4) && (  szFirst == "else" ) )
        {
        }
        else
        {
            if( lnCurrent < lnLast &&  nLeftOld != 0xffffffff)
            {
                lnLast = lnLast + 1
                InsBufLine( hbuf,lnCurrent, "");
                lnCurrent = lnCurrent + 1            
            }
            DelBufLine(hbuf,lnCurrent)                
            nIdx = 0
            
            //ȥ���ڼ��/* �� */ע�ͷ��������ע��Ƕ�״���
            while ( nIdx < ilen -1 )
            {
                if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                     ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                {
                    szLine[nIdx] = " "
                    szLine[nIdx+1] = " "
                }
                nIdx = nIdx + 1
            }
            szLine = cat("/* ",szLine)
            lnOld1 = lnCurrent
            lnCurrent = CommentContent(hbuf,lnCurrent,szLeft,szLine,1,117)
            lnLast = lnCurrent - lnOld1 + lnLast
        }
        if ( szFirst == "if" )
        {
            lnLast = lnLast + 1
            InsBufLine(hbuf,lnCurrent+1,"@szLeft@if (#)")
            lnCurrent = lnCurrent + 1
        }        
        else if ( szFirst == "else" )
        {
	        if ( szSecond == "if" )
	        {
	            lnLast = lnLast + 1
	            InsBufLine(hbuf,lnCurrent + 1,"@szLeft@else if (#)")
	            lnCurrent = lnCurrent + 1
	        }   
	        else if(ilen != 4)
	        {
	            lnLast = lnLast + 1
	            InsBufLine(hbuf,lnCurrent + 1,"@szLeft@else")
	            lnCurrent = lnCurrent + 1
	        }
	        else
	        {
	            //lnLast = lnLast -1
	            //DelBufLine(hbuf,lnCurrent-1)
	            //lnCurrent = lnCurrent - 1
	        }
        }
        else if ( szFirst == "do" && ilen != 2)
        {
            lnLast = lnLast + 1
            InsBufLine(hbuf,lnCurrent + 1,"@szLeft@do")
            lnCurrent = lnCurrent + 1
        }   
        else if ( szFirst == "switch" && ilen != 6)
        {
            lnLast = lnLast + 1
            InsBufLine(hbuf,lnCurrent + 1,"@szLeft@switch (#)")
            lnCurrent = lnCurrent + 1
        }   
        else if ( szFirst == "while" && ilen != 5)
        {
            lnLast = lnLast + 1
            InsBufLine(hbuf,lnCurrent + 1,"@szLeft@while (#)")
            lnCurrent = lnCurrent + 1
        }   
        else if ( szFirst == "for" && ilen != 3)
        {
            lnLast = lnLast + 1
            InsBufLine(hbuf,lnCurrent + 1,"@szLeft@for (# ; #; #)")
            lnCurrent = lnCurrent + 1
        }   

        if( nLeftOld != 0xffffffff ) 
        {
            if(  nLeft >= nLeftOld + 4  )
            {
                PutBufLine( hbuf, lnOld+1, "@szLeftOld@{" )
                //lnCurrent = lnCurrent + 1
                //lnLast = lnLast + 1
            }

            if( nLeftOld >= nLeft + 4 )
            {
                while( nLeftOld >= nLeft + 4 )
                {
                    lnLast = lnLast + 1
                    szLeftOld = strtrunc(szLeftOld,strlen(szLeftOld)-4)
                    InsBufLine(hbuf,lnOld + 1,"@szLeftOld@}")        
                    lnOld = lnOld + 1
                    nLeftOld = nLeftOld - 4
                    lnCurrent = lnCurrent + 1
                }
//                InsBufLine(hbuf,lnOld,"")        
//                lnCurrent = lnCurrent + 1
//                lnLast = lnLast + 1
            }
        }
        
        szLeftOld = szLeft
        nLeftOld = nLeft
        lnOld = lnCurrent
        lnCurrent = lnCurrent + 1
    }
    if( nLeftOld >= nBegLeft + 4 )
    {
        while( nLeftOld >= nBegLeft + 4 )
        {
            lnLast = lnLast + 1
            szLeftOld = strtrunc(szLeftOld,strlen(szLeftOld)-4)
            InsBufLine(hbuf,lnOld+1,"@szLeftOld@}")        
            lnOld = lnOld + 1
            nLeftOld = nLeftOld - 4
            lnCurrent = lnCurrent + 1
        }
    }
    SetBufIns(hbuf, lnFirst, 0)
    LoadSearchPattern("#", 1, 0, 1);
}

/*****************************************************************************
 �� �� ��  : CodeReview
 ��������  : ��������ò�������123ģ��
 �������  : �� 
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��8��10��
    ��    ��   : ¬ʤ��
    �޸�����   : ������

  2.��    ��   : 2010��3��3��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸ķ������µļ��ӱ���ʽ���������·����λ�ļ�

*****************************************************************************/
macro CodeReview()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()    
    szExt = GetFileNameExt(GetBufName(hbuf))
    if( tolower(szExt) == "rev")
    {
        nTotal = GetBufLineCount(hbuf)
        ln  = 0
        iLevel1 = 0
        iLevel2 = 0
        iLevel3 = 0
        iLineCount = 1
        iCount = 1
        while ( ln < nTotal )
        {
            szLine = GetBufLine(hbuf,ln)
            szLine = TrimString(szLine)
            iLen = strlen(szLine)
            i = 0
            iLineNum = 0
            iLineNumBeg = 0
            linkRec = GetSourceLink (hbuf, ln)
            iItem = 0
            if(iLen == 0)
            {
                ln = ln + 1
                continue
            }
            while(i < iLen)
            {
                if( (szLine[i]=="/") && (iItem == 2 )
                {
                    szName = strmid(szLine,iLineNumBeg,i)
                    iLineNumBeg = i + 1
                    PutBufLIne(hbuf,ln,"@szRight@")    
                    //PutBufLIne(hbuf,ln,"@iCount@@szRight@")    
                    szLine = GetBufLine(hbuf,ln)
	            iLen = strlen(szLine)
                    iCount = iCount + 1
                }
                else if( szLine[i] == "	" )
                {
                    if ( iItem == 0 )
                    {
                        //szRight = strmid(szLine, i, iLen)
                        szRight = szLine
                    }
                    else if( iItem == 1 )
                    {
                        iLineNumBeg = i + 1
                    }
                    else if( iItem == 2 )
                    {
                        iLineNum = strmid(szLine, iLineNumBeg, i)
                        if( linkRec != "" )
                        {
                            szLeft = strmid(szLine, 0, iLineNumBeg)
                            szRight = strmid(szLine, i, iLen)
                            linkln = linkRec.ln + 1
                            PutBufLIne(hbuf,ln,"@szLeft@@linkln@@szRight@")
                        }
                    }
                    else if ( iItem == 4 )
                    {
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        if ( szLevel == "Suggest��ʾ" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "Generalһ��" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major����" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        break
                    }
                    iItem = iItem + 1
                    iLineNumBeg = i + 1
                }
                i = i + 1
            }
            if( i < iLen )
            {
                SetSourceLink(hbuf,ln,szName,iLineNum-1)                    
            }
            if(szLine == "�ܼ�")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
/*        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"�ܼ�")
        AppendBufLine(hbuf,"����	һ��	��ʾ	�ܼ�")
        AppendBufLine(hbuf,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")        */
        return
    }
    
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
//    szLine = GetBufLine(hbuf,lnCurrent)
//    szLine = TrimString(szLine)
//    szFileName = GetRelFileName(GetBufName (hbuf))
//    szNewFileName = cat(szFileName,".rev")
    hNewBuf = openbuf("CodeReview.rev")
    if(hNewBuf == 0)
    {
        hNewBuf = NewBuf("CodeReview.rev")    
    }
    szFileName = GetRelFileName(GetBufName(hbuf))   
//    szFileName = GetBufName(hbuf)
    level = ask("1:��ʾ���� 2:һ������ 3:��������")
    if(level == 1)
    {
        szLevel = "Suggest��ʾ"
    }
    else if(level == 2)
    {
        szLevel = "Generalһ��"
    }
    else if(level == 3)
    {
        szLevel = "Major����"
    }
    else
    {
        stop
    }
    szErr = ask("��������")
    lnTmp = lnCurrent + 1
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nIdx = 0
    nTotal = GetBufLineCount(hNewBuf)
    while( nIdx < nTotal)
    {
        szLine = GetBufLine(hNewBuf,nIdx)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            DelBufLine(hNewBuf,nIdx)
            nTotal = nTotal - 1
        }
        else
        {
            nIdx = nIdx + 1
        }
    }
    nTotal = nTotal + 1
    //AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	Code�������")    
    AppendBufLine(hNewBuf,"@szMyName@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	����")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
    nTotal = GetBufLineCount(hNewBuf)
    ln  = 0
    iLineCount = 1
    iCount = 1
    while ( ln < nTotal )
    {
        szLine = GetBufLine(hNewBuf,ln)
        szLine = TrimString(szLine)
        iLen = strlen(szLine)
        i = 0
        iLineNum = 0
        iLineNumBeg = 0
        linkRec = GetSourceLink (hNewBuf, ln)
        iItem = 0
        if(iLen == 0)
        {
            ln = ln + 1
            continue
        }
        while(i < iLen)
        {
            if( (szLine[i]=="/") && (iItem == 2 )
            {
                szName = strmid(szLine,iLineNumBeg,i)
                iCount = iCount + 1
                iLineNumBeg = i + 1
            }
            else if( szLine[i] == "	" )
            {
                if ( iItem == 0 )
                {
                    szRight = strmid(szLine, i, iLen)
                    PutBufLIne(hNewBuf,ln,"@iCount@@szRight@")
                }
                else if( iItem == 1 )
                {
                    iLineNumBeg = i + 1
                }
                else if( iItem == 2 )
                {
                    iLineNum = strmid(szLine, iLineNumBeg, i)
                    if( linkRec != "" )
                    {
                        szLeft = strmid(szLine, 0, iLineNumBeg)
                        szRight = strmid(szLine, i, iLen)
                        linkln = linkRec.ln + 1
                        PutBufLIne(hNewBuf,ln,"@szLeft@@linkln@@szRight@")
                    }
                }
                iItem = iItem + 1
                iLineNumBeg = i + 1
            }
            i = i + 1
        }
        if( i < iLen )
        {
            SetSourceLink(hNewBuf,ln,szName,iLineNum-1)                    
        }
        ln = ln + 1
        iLineCount = iLineCount + 1
    }        
}

macro CodeReview1()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()    
    szExt = GetFileNameExt(GetBufName (hbuf))
    if( tolower(szExt) == "rev")
    {
        nTotal = GetBufLineCount(hbuf)
        ln  = 0
        iLevel1 = 0
        iLevel2 = 0
        iLevel3 = 0
        iLineCount = 1
        while ( ln < nTotal )
        {
            szLine = GetBufLine(hbuf,ln)
            szLine = TrimString(szLine)
            iLen = strlen(szLine)
            i = 0
            iLineNum = 0
            iLineNumBeg = 0
            iItem = 0
            if(iLen == 0)
            {
                ln = ln + 1
                continue
            }
            while(i < iLen)
            {
                if( (szLine[i]=="/") && (iItem == 0) )
                {
                    szName = strmid(szLine,iLineNumBeg,i)
                    iLineNumBeg = i + 1
                }
                else if( szLine[i] == "	" )
                {
                    if( iItem == 0 )
                    {
                        iLineNum = strmid(szLine, iLineNumBeg, i)
                    }
                    else if ( iItem == 5 )
                    {
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        if ( szLevel == "��ʾ" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "һ��" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "����" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        break
                    }
                    iItem = iItem + 1
                    iLineNumBeg = i + 1
                }
                i = i + 1
            }
            if( i < iLen )
            {
                SetSourceLink(hbuf,ln,szName,iLineNum-1)                    
            }
            if(szLine == "�ܼ�")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"�ܼ�")
        AppendBufLine(hbuf,"����	һ��	��ʾ	�ܼ�")
        AppendBufLine(hbuf,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")        
        return
    }
    
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
//    szLine = GetBufLine(hbuf,lnCurrent)
//    szLine = TrimString(szLine)
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
//    szNewFileName = cat(szFileName,".rev")
    hNewBuf = openbuf("CodeReview.rev")
    if(hNewBuf == 0)
    {
        hNewBuf = NewBuf("CodeReview.rev")    
    }
    szFileName = GetRelFileName(GetBufName(hbuf))
    level = ask("1:��ʾ���� 2:һ������ 3:��������")
    if(level == 1)
    {
        szLevel = "��ʾ"
    }
    else if(level == 2)
    {
        szLevel = "һ��"
    }
    else if(level == 3)
    {
        szLevel = "����"
    }
    else
    {
        stop
    }
    szErr = ask("��������")
    lnTmp = lnCurrent + 1
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nIdx = 0
    nTotal = GetBufLineCount(hNewBuf)
    while( nIdx < nTotal)
    {
        szLine = GetBufLine(hNewBuf,nIdx)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            DelBufLine(hNewBuf,nIdx)
            nTotal = nTotal - 1
        }
        else
        {
            nIdx = nIdx + 1
        }
    }
    nTotal = nTotal + 1
    AppendBufLine(hNewBuf,"@szFileName@/@lnTmp@	@szErr@	����			@szLevel@")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
}

/*****************************************************************************
 �� �� ��  : CodeReview
 ��������  : ��������ò���wordproģ��
 �������  : �� 
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��8��10��
    ��    ��   : ¬ʤ��
    �޸�����   : ������

*****************************************************************************/
macro UMSCCodeReview()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()    
    szExt = GetFileNameExt(GetBufName (hbuf))
    if( tolower(szExt) == "rev")
    {
        nTotal = GetBufLineCount(hbuf)
        ln  = 0
        iLevel1 = 0
        iLevel2 = 0
        iLevel3 = 0
        iLevel4 = 0
        iLineCount = 1
        while ( ln < nTotal )
        {
            szLine = GetBufLine(hbuf,ln)
            szLine = TrimString(szLine)
            iLen = strlen(szLine)
            i = 0
            iLineNum = 0
            iLineNumBeg = 0
            iItem = 0
            if(iLen == 0)
            {
                ln = ln + 1
                continue
            }
            while(i < iLen)
            {
                if( (szLine[i]=="/") && (iItem == 1) )
                {
                    szName = strmid(szLine,iLineNumBeg,i)
                    iLineNumBeg = i + 1
                }
                else if( szLine[i] == "	" )
                {
                    if( iItem == 0 )
                    {
                        iLineNumBeg = i + 1
                        szNewLine = strmid(szLine, iLineNumBeg, iLen)
                        PutBufLine(hbuf,ln,"@iLineCount@	@szNewLine@")
                    }
                    else if( iItem == 1 )
                    {
                        iLineNum = strmid(szLine, iLineNumBeg, i)
                    }
                    else if ( iItem == 3 )
                    {
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        if ( szLevel == "����ʾ" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "��һ��" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "������" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        else if ( szLevel == "������" )
                        {
                            iLevel4 = iLevel4 + 1
                        }
                        break
                    }
                    iItem = iItem + 1
                    iLineNumBeg = i + 1
                }
                i = i + 1
            }
            if( i < iLen )
            {
                SetSourceLink(hbuf,ln,szName,iLineNum-1)                    
            }
            if(szLine == "�ܼ�")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 + iLevel4              
                PutBufLIne(hbuf,ln+2,"@iLevel4@	@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3 + iLevel4
        AppendBufLine(hbuf,"�ܼ�")
        AppendBufLine(hbuf,"����	����	һ��	��ʾ	�ܼ�")
        AppendBufLine(hbuf,"@iLevel4@	@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")        
        return
    }
    
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
//    szLine = GetBufLine(hbuf,lnCurrent)
//    szLine = TrimString(szLine)
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
//    szNewFileName = cat(szFileName,".rev")
    hNewBuf = openbuf("CodeReview.rev")
    if(hNewBuf == 0)
    {
        hNewBuf = NewBuf("CodeReview.rev")    
    }
    szFileName = GetRelFileName(GetBufName (hbuf))
    level = ask("1:��ʾ���� 2:һ������ 3:�������� 4:��������")
    if(level == 1)
    {
        szLevel = "��ʾ"
    }
    else if(level == 2)
    {
        szLevel = "һ��"
    }
    else if(level == 3)
    {
        szLevel = "����"
    }
    else if(level == 4)
    {
        szLevel = "����"
    }
    else
    {
        stop
    }
    szErr = ask("��������")
    lnTmp = lnCurrent + 1
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nIdx = 0
    nTotal = GetBufLineCount(hNewBuf)
    while( nIdx < nTotal)
    {
        szLine = GetBufLine(hNewBuf,nIdx)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            DelBufLine(hNewBuf,nIdx)
            nTotal = nTotal - 1
        }
        else
        {
            nIdx = nIdx + 1
        }
    }
    nTotal = nTotal + 1
    AppendBufLine(hNewBuf,"@nTotal@	@szFileName@/@lnTmp@	@szErr@	��@szLevel@	����	@szMyName@")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
}


macro CodeReviewOld()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()    
    szExt = GetFileNameExt(GetBufName (hbuf))
    if( tolower(szExt) == "rev")
    {
        nTotal = GetBufLineCount(hbuf)
        ln  = 0
        iLevel1 = 0
        iLevel2 = 0
        iLevel3 = 0
        iLineCount = 1
        while ( ln < nTotal )
        {
            szLine = GetBufLine(hbuf,ln)
            szLine = TrimString(szLine)
            iLen = strlen(szLine)
            i = 0
            iCount = 0
            iLineNum = 0
            iLineNumBeg = 0
            linkRec = GetSourceLink (hbuf, ln)
            iItem = 0
            if(iLen == 0)
            {
                ln = ln + 1
                continue
            }
            while(i < iLen)
            {
                if( (szLine[i]=="/") && (iItem == 2 )
                {
                    szName = strmid(szLine,iLineNumBeg,i)
                    iCount = iCount + 1
                    iLineNumBeg = i + 1
                }
                else if( szLine[i] == "	" )
                {
                    if ( iItem == 1 )
                    {
                        szRight = strmid(szLine, i, iLen)
                        PutBufLIne(hbuf,ln,"@iCount@@szRight@")                    
                    }
                    else if( iItem == 2 )
                    {
                        iLineNum = strmid(szLine, iLineNumBeg, i)
                        if( linkRec != "" )
                        {
                            szLeft = strmid(szLine, 0, iLineNumBeg)
                            szRight = strmid(szLine, i, iLen)
                            linkln = linkRec.ln + 1
                            PutBufLIne(hbuf,ln,"@szLeft@@linkln@@szRight@")
                        }
                    }
                    else if ( iItem == 4 )
                    {
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        if ( szLevel == "Suggest��ʾ" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "Generalһ��" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major����" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        break
                    }
                    iItem = iItem + 1
                    iLineNumBeg = i + 1
                }
                i = i + 1
            }
            if( i < iLen )
            {
                SetSourceLink(hbuf,ln,szName,iLineNum-1)                    
            }
            if(szLine == "�ܼ�")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"�ܼ�")
        AppendBufLine(hbuf,"����	һ��	��ʾ	�ܼ�")
        AppendBufLine(hbuf,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")        
        return
    }
    
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
//    szLine = GetBufLine(hbuf,lnCurrent)
//    szLine = TrimString(szLine)
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
//    szNewFileName = cat(szFileName,".rev")
    hNewBuf = openbuf("CodeReview.rev")
    if(hNewBuf == 0)
    {
        hNewBuf = NewBuf("CodeReview.rev")    
    }
    szFileName = GetRelFileName(GetBufName (hbuf))
    level = ask("1:��ʾ���� 2:һ������ 3:��������")
    if(level == 1)
    {
        szLevel = "Suggest��ʾ"
    }
    else if(level == 2)
    {
        szLevel = "Generalһ��"
    }
    else if(level == 3)
    {
        szLevel = "Major����"
    }
    else
    {
        stop
    }
    szErr = ask("��������")
    lnTmp = lnCurrent + 1
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nIdx = 0
    nTotal = GetBufLineCount(hNewBuf)
    while( nIdx < nTotal)
    {
        szLine = GetBufLine(hNewBuf,nIdx)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            DelBufLine(hNewBuf,nIdx)
            nTotal = nTotal - 1
        }
        else
        {
            nIdx = nIdx + 1
        }
    }
    nTotal = nTotal + 1
    AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	Code����")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
}


macro CodeReview2()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()    
    szExt = GetFileNameExt(GetBufName(hbuf))
    if( tolower(szExt) == "rev")
    {
        nTotal = GetBufLineCount(hbuf)
        ln  = 0
        iLevel1 = 0
        iLevel2 = 0
        iLevel3 = 0
        iLineCount = 1
        iCount = 1
        while ( ln < nTotal )
        {
            szLine = GetBufLine(hbuf,ln)
            szLine = TrimString(szLine)
            iLen = strlen(szLine)
            i = 0
            iLineNum = 0
            iLineNumBeg = 0
            linkRec = GetSourceLink (hbuf, ln)
            iItem = 0
            if(iLen == 0)
            {
                ln = ln + 1
                continue
            }
            while(i < iLen)
            {
                if( (szLine[i]=="/") && (iItem == 2 )
                {
                    szName = strmid(szLine,iLineNumBeg,i)
                    iLineNumBeg = i + 1
                    PutBufLIne(hbuf,ln,"@iCount@@szRight@")    
		            szLine = GetBufLine(hbuf,ln)
		            iLen = strlen(szLine)
                    iCount = iCount + 1
                }
                else if( szLine[i] == "	" )
                {
                    if ( iItem == 0 )
                    {
                        szRight = strmid(szLine, i, iLen)
                    }
                    else if( iItem == 1 )
                    {
                        iLineNumBeg = i + 1
                    }
                    else if( iItem == 2 )
                    {
                        iLineNum = strmid(szLine, iLineNumBeg, i)
                        if( linkRec != "" )
                        {
                            szLeft = strmid(szLine, 0, iLineNumBeg)
                            szRight = strmid(szLine, i, iLen)
                            linkln = linkRec.ln + 1
                            PutBufLIne(hbuf,ln,"@szLeft@@linkln@@szRight@")
                        }
                    }
                    else if ( iItem == 4 )
                    {
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        if ( szLevel == "Suggest��ʾ" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "Generalһ��" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major����" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        break
                    }
                    iItem = iItem + 1
                    iLineNumBeg = i + 1
                }
                i = i + 1
            }
            if( i < iLen )
            {
                SetSourceLink(hbuf,ln,szName,iLineNum-1)                    
            }
            if(szLine == "�ܼ�")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
/*        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"�ܼ�")
        AppendBufLine(hbuf,"����	һ��	��ʾ	�ܼ�")
        AppendBufLine(hbuf,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")        */
        return
    }
    
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
//    szLine = GetBufLine(hbuf,lnCurrent)
//    szLine = TrimString(szLine)
//    szFileName = GetRelFileName(GetBufName (hbuf))
//    szNewFileName = cat(szFileName,".rev")
    hNewBuf = openbuf("CodeReview.rev")
    if(hNewBuf == 0)
    {
        hNewBuf = NewBuf("CodeReview.rev")    
    }
    szFileName = GetFileName(GetBufName (hbuf))
//    szFileName = GetBufName(hbuf)
    level = ask("1:��ʾ���� 2:һ������ 3:��������")
    if(level == 1)
    {
        szLevel = "Suggest��ʾ"
    }
    else if(level == 2)
    {
        szLevel = "Generalһ��"
    }
    else if(level == 3)
    {
        szLevel = "Major����"
    }
    else
    {
        stop
    }
    szErr = ask("��������")
    lnTmp = lnCurrent + 1
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nIdx = 0
    nTotal = GetBufLineCount(hNewBuf)
    while( nIdx < nTotal)
    {
        szLine = GetBufLine(hNewBuf,nIdx)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            DelBufLine(hNewBuf,nIdx)
            nTotal = nTotal - 1
        }
        else
        {
            nIdx = nIdx + 1
        }
    }
    nTotal = nTotal + 1
    //AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	Code�������")    
    AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	Code�������")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
    nTotal = GetBufLineCount(hNewBuf)
    ln  = 0
    iLineCount = 1
    iCount = 1
    while ( ln < nTotal )
    {
        szLine = GetBufLine(hNewBuf,ln)
        szLine = TrimString(szLine)
        iLen = strlen(szLine)
        i = 0
        iLineNum = 0
        iLineNumBeg = 0
        linkRec = GetSourceLink (hNewBuf, ln)
        iItem = 0
        if(iLen == 0)
        {
            ln = ln + 1
            continue
        }
        while(i < iLen)
        {
            if( (szLine[i]=="/") && (iItem == 2 )
            {
                szName = strmid(szLine,iLineNumBeg,i)
                iCount = iCount + 1
                iLineNumBeg = i + 1
            }
            else if( szLine[i] == "	" )
            {
                if ( iItem == 0 )
                {
                    szRight = strmid(szLine, i, iLen)
                    PutBufLIne(hNewBuf,ln,"@iCount@@szRight@")    
                }
                else if( iItem == 1 )
                {
                    iLineNumBeg = i + 1
                }
                else if( iItem == 2 )
                {
                    iLineNum = strmid(szLine, iLineNumBeg, i)
                    if( linkRec != "" )
                    {
                        szLeft = strmid(szLine, 0, iLineNumBeg)
                        szRight = strmid(szLine, i, iLen)
                        linkln = linkRec.ln + 1
                        PutBufLIne(hNewBuf,ln,"@szLeft@@linkln@@szRight@")
                    }
                }
                iItem = iItem + 1
                iLineNumBeg = i + 1
            }
            i = i + 1
        }
        if( i < iLen )
        {
            SetSourceLink(hNewBuf,ln,szName,iLineNum-1)                    
        }
        ln = ln + 1
        iLineCount = iLineCount + 1
    }        
}



macro GetReviewName()
{
    szTmp0 = getreg(REVIEWER1)
    szTmp1 = getreg(REVIEWER2)
    szTmp2 = getreg(REVIEWER3)
    szTmp3 = getreg(REVIEWER4)
    str = ""
    if (strlen(szTmp0) != 0)
    {
        str = cat(str," 1.@szTmp0@ ")
    }
    if (strlen(szTmp1) != 0)
    {
        str = cat(str," 2.@szTmp1@ ")
    }
    if (strlen(szTmp2) != 0)
    {
        str = cat(str," 3.@szTmp2@ ")
    }
    if (strlen(szTmp3) != 0)
    {
        str = cat(str," 4.@szTmp3@ ")
    }
    return str
}

macro ConfigureCodeReview()
{
    str = GetReviewName()
    if (strlen(str) != 0)
    {
        msg(str)
    }
    szReviewer = ASK("�����������1����, �����ַ�'#'��ʾɾ��");
    if(szLanguage == "#")
    {
       SetReg ("REVIEWER1", "")
    }
    else
    {
       SetReg ("REVIEWER1", szReviewer)
    }
    
    szReviewer = ASK("�����������2����, �����ַ�'#'��ʾɾ��");
    if(szLanguage == "#")
    {
       SetReg ("REVIEWER2", "")
    }
    else
    {
       SetReg ("REVIEWER2", szReviewer)
    }

    szReviewer = ASK("�����������3����, �����ַ�'#'��ʾɾ��");
    if(szLanguage == "#")
    {
       SetReg ("REVIEWER3", "")
    }
    else
    {
       SetReg ("REVIEWER3", szReviewer)
    }

    szReviewer = ASK("�����������4����, �����ַ�'#'��ʾɾ��");
    if(szLanguage == "#")
    {
       SetReg ("REVIEWER4", "")
    }
    else
    {
       SetReg ("REVIEWER4", szReviewer)
    }
    str = GetReviewName()
    if (strlen(str) != 0)
    {
        msg(str)
    }
}


/*****************************************************************************
 �� �� ��  : CodeReviewWithName
 ��������  : ���˼��ӹ���
 �������  : �� 
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��8��10��
    ��    ��   : ¬ʤ��
    �޸�����   : ������

  2.��    ��   : 2010��3��3��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸�Ϊ���·����ʽ

*****************************************************************************/
macro CodeReviewWithName()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()    
    szExt = GetFileNameExt(GetBufName (hbuf))
    if( tolower(szExt) == "rev")
    {
        nTotal = GetBufLineCount(hbuf)
        ln  = 0
        iLevel1 = 0
        iLevel2 = 0
        iLevel3 = 0
        iLineCount = 1
        iCount = 1
        while ( ln < nTotal )
        {
            szLine = GetBufLine(hbuf,ln)
            szLine = TrimString(szLine)
            iLen = strlen(szLine)
            i = 0
            iLineNum = 0
            iLineNumBeg = 0
            linkRec = GetSourceLink (hbuf, ln)
            iItem = 0
            if(iLen == 0)
            {
                ln = ln + 1
                continue
            }
            while(i < iLen)
            {
                if( (szLine[i]=="/") && (iItem == 2 )
                {
                    szName = strmid(szLine,iLineNumBeg,i)
                    iLineNumBeg = i + 1
                    PutBufLIne(hbuf,ln,"@iCount@@szRight@")    
		            szLine = GetBufLine(hbuf,ln)
		            iLen = strlen(szLine)
                    iCount = iCount + 1
                }
                else if( szLine[i] == "	" )
                {
                    if ( iItem == 0 )
                    {
                        szRight = strmid(szLine, i, iLen)
                    }
                    else if( iItem == 1 )
                    {
                        iLineNumBeg = i + 1
                    }
                    else if( iItem == 2 )
                    {
                        iLineNum = strmid(szLine, iLineNumBeg, i)
                        if( linkRec != "" )
                        {
                            szLeft = strmid(szLine, 0, iLineNumBeg)
                            szRight = strmid(szLine, i, iLen)
                            linkln = linkRec.ln + 1
                            PutBufLIne(hbuf,ln,"@szLeft@@linkln@@szRight@")
                        }
                    }
                    else if ( iItem == 4 )
                    {
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        if ( szLevel == "Suggest��ʾ" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "Generalһ��" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major����" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        break
                    }
                    iItem = iItem + 1
                    iLineNumBeg = i + 1
                }
                i = i + 1
            }
            if( i < iLen )
            {
                SetSourceLink(hbuf,ln,szName,iLineNum-1)                    
            }
            if(szLine == "�ܼ�")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
/*        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"�ܼ�")
        AppendBufLine(hbuf,"����	һ��	��ʾ	�ܼ�")
        AppendBufLine(hbuf,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")        */
        return
    }
    
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
//    szLine = GetBufLine(hbuf,lnCurrent)
//    szLine = TrimString(szLine)
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
//    szNewFileName = cat(szFileName,".rev")
    hNewBuf = openbuf("CodeReview.rev")
    if(hNewBuf == 0)
    {
        hNewBuf = NewBuf("CodeReview.rev")    
    }
    szFileName = GetRelFileName(GetBufName (hbuf))
//    szFileName = GetBufName (hbuf)
    level = ask("1:��ʾ���� 2:һ������ 3:��������")
    if(level == 1)
    {
        szLevel = "Suggest��ʾ"
    }
    else if(level == 2)
    {
        szLevel = "Generalһ��"
    }
    else if(level == 3)
    {
        szLevel = "Major����"
    }
    else
    {
        stop
    }
    szErr = ask("��������")
    lnTmp = lnCurrent + 1
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }

    szTmp0 = getreg(REVIEWER1)
    szTmp1 = getreg(REVIEWER2)
    szTmp2 = getreg(REVIEWER3)
    szTmp3 = getreg(REVIEWER4)
    nCount = 1
    str = "���ⷢ����:"
    if (strlen(szTmp0) != 0)
    {
        str = cat(str," @nCount@.@szTmp0@ ")
        szReviewer0 = szTmp0;
        nCount = nCount + 1
    }
    if (strlen(szTmp1) != 0)
    {
        str = cat(str," @nCount@.@szTmp1@ ")
        szReviewer1 = szTmp1;
        nCount = nCount + 1
    }
    if (strlen(szTmp2) != 0)
    {
        str = cat(str," @nCount@.@szTmp2@ ")
        szReviewer2 = szTmp2;
        nCount = nCount + 1
    }
    if (strlen(szTmp3) != 0)
    {
        str = cat(str," @nCount@.@szTmp3@")
        szReviewer3 = szTmp3;
        nCount = nCount + 1
    }
    if(nCount != 1)
    {
        nRevier = 0
        nRevier = ask(str)
        flag = 1;
    }
    else
    {
        flag = 0;
    }

    nIdx = 0
    nTotal = GetBufLineCount(hNewBuf)
    while( nIdx < nTotal)
    {
        szLine = GetBufLine(hNewBuf,nIdx)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            DelBufLine(hNewBuf,nIdx)
            nTotal = nTotal - 1
        }
        else
        {
            nIdx = nIdx + 1
        }
    }
    nTotal = nTotal + 1
    //AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	Code�������")    
    if(flag == 1)
    {
        if (nRevier == 1)
        {
	        AppendBufLine(hNewBuf,"@szReviewer0@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	����")    
        }
        else if (nRevier == 2)
        {
	        AppendBufLine(hNewBuf,"@szReviewer1@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	����")    
        }
        else if (nRevier == 3)
        {
	        AppendBufLine(hNewBuf,"@szReviewer2@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	����")    
        }
        else if (nRevier == 4)
        {
	        AppendBufLine(hNewBuf,"@szReviewer3@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	����")    
        }
        else
        {
            stop
        }
    }
    else
    {
        AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	����")        
    }
    SetSourceLink(hNewBuf,nTotal-1,GetBufName(hbuf),lnCurrent)
    SaveBuf(hNewBuf)
    nTotal = GetBufLineCount(hNewBuf)
    ln  = 0
    iLineCount = 1
    iCount = 1
    while ( ln < nTotal )
    {
        szLine = GetBufLine(hNewBuf,ln)
        szLine = TrimString(szLine)
        iLen = strlen(szLine)
        i = 0
        iLineNum = 0
        iLineNumBeg = 0
        linkRec = GetSourceLink (hNewBuf, ln)
        iItem = 0
        if(iLen == 0)
        {
            ln = ln + 1
            continue
        }
        while(i < iLen)
        {
            if( (szLine[i]=="/") && (iItem == 2 )
            {
                szName = strmid(szLine,iLineNumBeg,i)
                iCount = iCount + 1
                iLineNumBeg = i + 1
            }
            else if( szLine[i] == "	" )
            {
                if ( iItem == 0 )
                {
                    szRight = strmid(szLine, i, iLen)
                    PutBufLIne(hNewBuf,ln,"@iCount@@szRight@")    
                }
                else if( iItem == 1 )
                {
                    iLineNumBeg = i + 1
                }
                else if( iItem == 2 )
                {
                    iLineNum = strmid(szLine, iLineNumBeg, i)
                    if( linkRec != "" )
                    {
                        szLeft = strmid(szLine, 0, iLineNumBeg)
                        szRight = strmid(szLine, i, iLen)
                        linkln = linkRec.ln + 1
                        PutBufLIne(hNewBuf,ln,"@szLeft@@linkln@@szRight@")
                    }
                }
                iItem = iItem + 1
                iLineNumBeg = i + 1
            }
            i = i + 1
        }
        if( i < iLen )
        {
            SetSourceLink(hNewBuf,ln,szName,iLineNum-1)                    
        }
        ln = ln + 1
        iLineCount = iLineCount + 1
    }        
}

macro CodeReview_bak04()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()    
    szExt = GetFileNameExt(GetBufName (hbuf))
    if( tolower(szExt) == "rev")
    {
        nTotal = GetBufLineCount(hbuf)
        ln  = 0
        iLevel1 = 0
        iLevel2 = 0
        iLevel3 = 0
        iLineCount = 1
        iCount = 1
        while ( ln < nTotal )
        {
            szLine = GetBufLine(hbuf,ln)
            szLine = TrimString(szLine)
            iLen = strlen(szLine)
            i = 0
            iLineNum = 0
            iLineNumBeg = 0
            linkRec = GetSourceLink (hbuf, ln)
            iItem = 0
            if(iLen == 0)
            {
                ln = ln + 1
                continue
            }
            while(i < iLen)
            {
                if( (szLine[i]=="/") && (iItem == 2 )
                {
                    szName = strmid(szLine,iLineNumBeg,i)
                    iCount = iCount + 1
                    iLineNumBeg = i + 1
                }
                else if( szLine[i] == "	" )
                {
                    if ( iItem == 0 )
                    {
                        szRight = strmid(szLine, i, iLen)
                        PutBufLIne(hbuf,ln,"@iCount@@szRight@")    
                    }
                    else if( iItem == 1 )
                    {
                        iLineNumBeg = i + 1
                    }
                    else if( iItem == 2 )
                    {
                        iLineNum = strmid(szLine, iLineNumBeg, i)
                        if( linkRec != "" )
                        {
                            szLeft = strmid(szLine, 0, iLineNumBeg)
                            szRight = strmid(szLine, i, iLen)
                            linkln = linkRec.ln + 1
                            PutBufLIne(hbuf,ln,"@szLeft@@linkln@@szRight@")
                        }
                    }
                    else if ( iItem == 4 )
                    {
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        szLevel = strmid(szLine, iLineNumBeg, i)
                        if ( szLevel == "Suggest��ʾ" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "Generalһ��" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major����" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        break
                    }
                    iItem = iItem + 1
                    iLineNumBeg = i + 1
                }
                i = i + 1
            }
            if( i < iLen )
            {
                SetSourceLink(hbuf,ln,szName,iLineNum-1)                    
            }
            if(szLine == "�ܼ�")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"�ܼ�")
        AppendBufLine(hbuf,"����	һ��	��ʾ	�ܼ�")
        AppendBufLine(hbuf,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")        
        return
    }
    
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
//    szLine = GetBufLine(hbuf,lnCurrent)
//    szLine = TrimString(szLine)
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
//    szNewFileName = cat(szFileName,".rev")
    hNewBuf = openbuf("CodeReview.rev")
    if(hNewBuf == 0)
    {
        hNewBuf = NewBuf("CodeReview.rev")    
    }
    szFileName = GetRelFileName(GetBufName (hbuf))
    level = ask("1:��ʾ���� 2:һ������ 3:��������")
    if(level == 1)
    {
        szLevel = "Suggest��ʾ"
    }
    else if(level == 2)
    {
        szLevel = "Generalһ��"
    }
    else if(level == 3)
    {
        szLevel = "Major����"
    }
    else
    {
        stop
    }
    szErr = ask("��������")
    lnTmp = lnCurrent + 1
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nIdx = 0
    nTotal = GetBufLineCount(hNewBuf)
    while( nIdx < nTotal)
    {
        szLine = GetBufLine(hNewBuf,nIdx)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if( iLen == 0 )
        {
            DelBufLine(hNewBuf,nIdx)
            nTotal = nTotal - 1
        }
        else
        {
            nIdx = nIdx + 1
        }
    }
    nTotal = nTotal + 1
    AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defectȱ��	@szLevel@	Code����")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
}


/*****************************************************************************
 �� �� ��  : CmtCvtLine
 ��������  : ��//ת����/*ע��
 �������  : lnCurrent  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 
    ��    ��   : 
    �޸�����   : 

  2.��    ��   : 2002��7��02��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸���ע��Ƕ��������������?

*****************************************************************************/
macro CmtCvtLine(lnCurrent, isCommentEnd)
{
    hbuf = GetCurrentBuf()
    szLine = GetBufLine(hbuf,lnCurrent)
    ch_comment = CharFromAscii(47)   
    ich = 0
    ilen = strlen(szLine)
    
    fIsEnd = 1
    iIsComment = 0;
    
    while ( ich < ilen - 1 )
    {
        //�����/*ע�����������ö�
        if( (isCommentEnd == 0) || (szLine[ich] == "/" && szLine[ich+1] == "*"))
        {
            fIsEnd = 0
            while(ich < ilen - 1 )
            {
                if(szLine[ich] == "*" && szLine[ich+1] == "/")
                {
                    ich = ich + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                ich = ich + 1 
            }
            if(ich >= ilen - 1)
            {
                break
            }
        }
        if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
        {
            nIdx = ich
            while ( nIdx < ilen -1 )
            {
                if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                     ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                {
                    szLine[nIdx] = " "
                    szLine[nIdx+1] = " "
                }
                nIdx = nIdx + 1
            }
            szLine[ich+1] = "*"
            szLine = cat(szLine,"  */")
            DelBufLine(hbuf,lnCurrent)
            InsBufLine(hbuf,lnCurrent,szLine)
            return fIsEnd
        }
        ich = ich + 1
    }
    return fIsEnd
}

/*****************************************************************************
 �� �� ��  : GetFileNameExt
 ��������  : �õ��ļ���չ��
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameExt(sz)
{
    i = 1
    j = 0
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
         szExt = strmid(sz,j + 1,iLen)
         return szExt
      }
      i = i + 1
    }
    return ""
}

/*****************************************************************************
 �� �� ��  : GetFileNameNoExt
 ��������  : �õ�������û����չ��
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameNoExt(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    j = iLen 
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
      }
      if( sz[iLen-i] == "\\" )
      {
         szName = strmid(sz,iLen-i+1,j)
         return szName
      }
      i = i + 1
    }
    szName = strmid(sz,0,j)
    return szName
}


/*****************************************************************************
 �� �� ��  : GetRelFileName
 ��������  : �õ����·�����ļ���
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetRelFileName(sz)
{

    hprj = GetCurrentProj ()
    path = GetProjDir (hprj)
    iPathLen = strlen(path)
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    if(iLen <= iPathLen)
    return sz
    szName = strmid(sz,iPathLen+1,iLen)
    return szName
}

/*****************************************************************************
 �� �� ��  : GetFileName
 ��������  : �õ��ļ���
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    j = iLen 
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
      }
      if( sz[iLen-i] == "\\" )
      {
         szName = strmid(sz,iLen-i+1,iLen)
         return szName
      }
      i = i + 1
    }
    return sz
}

/*****************************************************************************
 �� �� ��  : InsIfdef
 ��������  : ����#ifdef���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsIfdef()
{
    sz = Ask("Enter #ifdef condition:")
    if (sz != "")
        IfdefStr(sz);
}

/*****************************************************************************
 �� �� ��  : InsIfndef
 ��������  : ��ifndef���Բ������ڵ��ú�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsIfndef()
{
    sz = Ask("Enter #ifndef condition:")
    if (sz != "")
        IfndefStr(sz);
}

/*****************************************************************************
 �� �� ��  : InsertCPP
 ��������  : ��buf�в���C���Ͷ���
 �������  : hbuf  
             ln    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCPP(hbuf,ln)
{
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "#endif")
    //InsBufLine(hbuf, ln, "#endif")
    InsBufLine(hbuf, ln, "extern \"C\"{")
    //InsBufLine(hbuf, ln, "#if __cplusplus")
    InsBufLine(hbuf, ln, "#ifdef __cplusplus")
    InsBufLine(hbuf, ln, "")
    
    iTotalLn = GetBufLineCount (hbuf)            
    InsBufLine(hbuf, iTotalLn, "")
    InsBufLine(hbuf, iTotalLn, "#endif")
    //InsBufLine(hbuf, iTotalLn, "#endif")
    InsBufLine(hbuf, iTotalLn, "}")
    //InsBufLine(hbuf, iTotalLn, "#if __cplusplus")
    InsBufLine(hbuf, iTotalLn, "#ifdef __cplusplus")
    InsBufLine(hbuf, iTotalLn, "")
}

/*****************************************************************************
 �� �� ��  : ReviseCommentProc
 ��������  : ���ⵥ�޸������
 �������  : hbuf      
             ln        
             szCmd     
             szMyName  
             szLine1   
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReviseCommentProc(hbuf,ln,szCmd,szMyName,szLine1)
{
    if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@-@sz1@-@sz3@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        if(strlen(szLeft) > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1,117)
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@-@sz1@-@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@-@sz1@-@sz3@ */");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: Added by @szMyName@, @sz@-@sz1@-@sz3@   ���ⵥ��:@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: Added by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@-@sz1@-@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln + 0)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@-@sz1@-@sz3@   ���ⵥ��:@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@-@sz1@-@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: Modified by @szMyName@, @sz@-@sz1@-@sz3@   ���ⵥ��:@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: Modified by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        return
    }
}

/*****************************************************************************
 �� �� ��  : InsertReviseAdd
 ��������  : ��������޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2002��12��26��
    ��    ��   : ����
    �޸�����   : �������ⵥ����

*****************************************************************************/
macro InsertReviseAdd()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    //szDescription = GetReg ("PNDes") 
    if (strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Add by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Add by @szMyName@, @sz@-@sz1@-@sz3@ */");        
    }

    if(sel.lnLast < lnMax - 1)
    {
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END: */");
        }
    }
    else
    {
        if(strlen(szQuestion)>0)
        {
            AppendBufLine(hbuf, "@szLeft@/* END: @szQuestion@ */");
        }
        else
        {
            AppendBufLine(hbuf, "@szLeft@/* END: */");
        }
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseDel
 ��������  : ����ɾ���޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2002��12��26��
    ��    ��   : ����
    �޸�����   : �������ⵥ����

*****************************************************************************/
macro InsertReviseDel()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ReviseDel()
    sel.lnFirst = sel.lnFirst + 1
    sel.lnLast = sel.lnLast + 1
    SetWndSel(hwnd,sel)
    iAsk = ask("1: /* */  2: #if 0")
    if(iAsk == 1)
    {
        CommentBlock()
    }
    else
    {
        PredefIfStr(0)
    }
}

macro ReviseDel()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    //szDescription = GetReg ("PNDes") 
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Delete by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Delete by @szMyName@, @sz@-@sz1@-@sz3@ */");        
    }

    if(sel.lnLast < lnMax - 1)
    {
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END  */");
        }
    }
    else
    {
        if(strlen(szQuestion)>0)
        {
            AppendBufLine(hbuf, "@szLeft@/* END: @szQuestion@ */");
        }
        else
        {
            AppendBufLine(hbuf, "@szLeft@/* END */");
        }
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseMod
 ��������  : �����޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

  2.��    ��   : 2002��12��26��
    ��    ��   : ����
    �޸�����   : �������ⵥ����

*****************************************************************************/
macro InsertReviseMod()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    //szDescription = GetReg ("PNDes") 
    if(strlen(szQuestion)>0)
    {
    	InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Modify by @szMyName@, @sz@-@sz1@-@sz3@, @szQuestion@ */");   
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Modify by @szMyName@, @sz@-@sz1@-@sz3@ */");        
    }

    if(sel.lnLast < lnMax - 1)
    {
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END: @szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END */");
        }
    }
    else
    {
        if(strlen(szQuestion)>0)
        {
            AppendBufLine(hbuf, "@szLeft@/* END: @szQuestion@ */");
        }
        else
        {
            AppendBufLine(hbuf, "@szLeft@/* END */");
        }
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

// Wrap ifdef <sz> .. endif around the current selection
macro IfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifdef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : IfndefStr
 ��������  : ���룣ifndef����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro IfndefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifndef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


/*****************************************************************************
 �� �� ��  : InsertPredefIf
 ��������  : ���룣if���Ե���ڵ��ú�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertPredefIf()
{
    sz = Ask("Enter #if condition:")
    PredefIfStr(sz)
}

/*****************************************************************************
 �� �� ��  : PredefIfStr
 ��������  : ��ѡ����ǰ����룣if����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro PredefIfStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* #if @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#if  @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


/*****************************************************************************
 �� �� ��  : HeadIfdefStr
 ��������  : ��ѡ����ǰ�����#ifdef����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro HeadIfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    hbuf = GetCurrentBuf()
    InsBufLine(hbuf, lnFirst, "")
    InsBufLine(hbuf, lnFirst, "#define @sz@")
    InsBufLine(hbuf, lnFirst, "#ifndef @sz@")
    iTotalLn = GetBufLineCount (hbuf)                
    InsBufLine(hbuf, iTotalLn, "#endif /* @sz@ */")
    InsBufLine(hbuf, iTotalLn, "")
}

/*****************************************************************************
 �� �� ��  : GetSysTime
 ��������  : ȡ��ϵͳʱ�䣬ֻ��V2.1ʱ����
 �������  : a  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetSysTime(a)
{
    //��sidateȡ��ʱ��
    RunCmd ("sidate")
    SysTime=""
    SysTime.Year=getreg(Year)
    if(strlen(SysTime.Year)==0)
    {
        setreg(Year,"2002")
        setreg(Month,"05")
        setreg(Day,"02")
        SysTime.Year="2002"
        SysTime.month="05"
        SysTime.day="20"
        SysTime.Date="2002��05��20��"
    }
    else
    {
        SysTime.Month=getreg(Month)
        SysTime.Day=getreg(Day)
        SysTime.Date=getreg(Date)
   /*         SysTime.Date=cat(SysTime.Year,"��")
        SysTime.Date=cat(SysTime.Date,SysTime.Month)
        SysTime.Date=cat(SysTime.Date,"��")
        SysTime.Date=cat(SysTime.Date,SysTime.Day)
        SysTime.Date=cat(SysTime.Date,"��")*/
    }
    return SysTime
}

/*****************************************************************************
 �� �� ��  : HeaderFileCreate
 ��������  : ����ͷ�ļ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro HeaderFileCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }

   CreateFunctionDef(hbuf,szMyName,language)
}

/*****************************************************************************
 �� �� ��  : FunctionHeaderCreate
 ��������  : ���ɺ���ͷ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FunctionHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nVer = GetVersion()
    lnMax = GetBufLineCount(hbuf)
    if(ln != lnMax)
    {
        szNextLine = GetBufLine(hbuf,ln)
        if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2 ))
        {
            symbol = GetCurSymbol()
            if(strlen(symbol) != 0)
            {  
                if(language == 0)
                {
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0, 0)
                }
                else
                {                
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                }
                return
            }
        }
    }
    if(language == 0 )
    {
        szFuncName = Ask("�����뺯������:")
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1, 0)
    }
    else
    {
        szFuncName = Ask("Please input function name")
           FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    
    }
}

/*****************************************************************************
 �� �� ��  : GetVersion
 ��������  : �õ�Si�İ汾��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetVersion()
{
   Record = GetProgramInfo ()
   return Record.versionMajor
}

/*****************************************************************************
 �� �� ��  : GetProgramInfo
 ��������  : ��ó�����Ϣ��V2.1����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetProgramInfo ()
{   
    Record = ""
    Record.versionMajor     = 2
    Record.versionMinor    = 1
    return Record
}

/*****************************************************************************
 �� �� ��  : FileHeaderCreate
 ��������  : �����ļ�ͷ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FileHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    ln = 0
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SetBufIns (hbuf, 0, 0)

    szVersion = getreg(VERSION)
    if(strlen(szVersion) == 0)
    {
    	szVersion = Ask("Please input project code:")
    	setreg(VERSION, szVersion)
    }
    
    if(language == 0)
    {
        InsertFileHeaderCN( hbuf,ln, szMyName,"", 1, VERSION)
    }
    else
    {
        InsertFileHeaderEN( hbuf,ln, szMyName,"", 1, VERSION)
    }
}

macro CreateTestCase()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = 0
    lnBegin = 0
    lnCurrent = lnFirst
    lnLast = GetBufLineCount( hbuf )
    szNewLine = ""
    while ( lnCurrent < lnLast )
    {
        szLine = GetBufLine(hbuf,lnCurrent)
        szLine = TrimString(szLine)
        ilen = strlen(szLine)
        if(ilen == 0)
        {
	        DelBufLine(hbuf,lnCurrent);
	        lnLast = lnLast - 1
            continue;
        }
        nLeft = strchr(szLine,"|")
        if(0xffffffff == nLeft)
        {
            szNewLine = cat(szNewLine,"\\n");
            szNewLine = cat(szNewLine,szLine);
	        DelBufLine(hbuf,lnCurrent);
	        lnLast = lnLast - 1
        }
        else
        {
            if(strlen(szNewLine)!= 0)
            {               
		        PutBufLine(hbuf,lnBegin,szNewLine)
            }
	        lnBegin = lnCurrent
            szNewLine = szLine            
            lnCurrent = lnCurrent + 1
        }
    }
    PutBufLine(hbuf,lnBegin,szNewLine)

//    hbuf = newBuf("")
/*    SetCurrentBuf(hbuf)
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalParams = ask("����������Ĳ�������")
    cir = 8192
    cbs = 0
    ebs = 0
    pir = cir + 2
    i = 0
    while(i < iTotalParams)
    {
	    AppendBufLine(hbuf, "traffic-params @i@ cir @cir@ cbs @cbs@ ebs @ebs@ pir @pir@")
	    i = i + 1
	    cir = cir + i*i + i*23 + i
	    cbs = cbs + i*i + i*203 + i
	    ebs = ebs + i*i + i*251 + i
	    pir = cir + i*i + i*331 + i
    }
    sel = GetWndSel(hwnd)
    sel.lnFirst = 0
    sel.ichFirst = 0
    sel.lnLast = GetBufLineCount(hbuf)
    SetWndSel(hWnd,sel)
    Copy
    CloseBuf(hbuf)*/
}
/*****************************************************************************
 �� �� ��  : InsertulRet
 ��������  : ����ulRet
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertulRet()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "    ULONG ulRet = VOS_OK;")
}

/*****************************************************************************
 �� �� ��  : InsertTestStart
 ��������  : ����TestStart
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��21��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTestStart()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "/* test start */")
}

/*****************************************************************************
 �� �� ��  : InsertTestEnd
 ��������  : ����TestEnd
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��21��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTestEnd()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "/* test end */")
}
/*****************************************************************************
 �� �� ��  : InsertTestStartAndEnd
 ��������  : ����TestStartAndEnd
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��21��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTestStartAndEnd()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,     "/* test start */")
    InsBufLine(hbuf, ln + 2, "/* test end */")
}

/*****************************************************************************
 �� �� ��  : InsertulFabricHead
 ��������  : ����FabricHead
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��20��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertulFabricHead()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "#include \"drv_fabric_pub.h\"")
}

/*****************************************************************************
 �� �� ��  : InsertTest0
 ��������  : ����ulRet
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTest0()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "    printf(\"test0\\r\\n\");")
}

/*****************************************************************************
 �� �� ��  : InsertTest1
 ��������  : ����ulRet
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTest1()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "    printf(\"test1\\r\\n\");")
}

/*****************************************************************************
 �� �� ��  : InsertTest2
 ��������  : ����ulRet
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTest2()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "    printf(\"test2\\r\\n\");")
}

/*****************************************************************************
 �� �� ��  : InsertTest3
 ��������  : ����ulRet
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTest3()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "    printf(\"test3\\r\\n\");")
}

/*****************************************************************************
 �� �� ��  : InsertTest4
 ��������  : ����ulRet
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTest4()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "    printf(\"test4\\r\\n\");")
}

/*****************************************************************************
 �� �� ��  : InsertTest5
 ��������  : ����ulRet
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTest5()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "    printf(\"test5\\r\\n\");")
}

/*****************************************************************************
 �� �� ��  : InsertCmdDisplay
 ��������  : ����Display����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdDisplay()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_ELEM_DISPLAY,")
    InsBufLine(hbuf, ln, "                                     DRV_GetGeneralHelpInfo(),")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(DRV_GetGeneralCmdWord(DRV_ELEM_DISPLAY),")
    InsBufLine(hbuf, ln, "    /* $1 _display */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdSet
 ��������  : ����Set����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdSet()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_ELEM_SET,")
    InsBufLine(hbuf, ln, "                                     DRV_GetGeneralHelpInfo(),")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(DRV_GetGeneralCmdWord(DRV_ELEM_SET),")
    InsBufLine(hbuf, ln, "    /* $1 _set */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdDriver
 ��������  : ����Driver����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdDriver()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_ELEM_DRIVER,")
    InsBufLine(hbuf, ln, "                                     DRV_GetGeneralHelpInfo(),")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(DRV_GetGeneralCmdWord(DRV_ELEM_DRIVER),")
    InsBufLine(hbuf, ln, "    /* $2 driver */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdFabric
 ��������  : ����Fabric����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdFabric()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_FABRIC,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(g_aszDrvFabricCmdWord[DRV_FABRIC_CMD_WORD_FABRIC],")
    InsBufLine(hbuf, ln, "    /* $3 fabric */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdFe
 ��������  : ����Fe����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdFe()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_FE,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(g_aszDrvFabricCmdWord[DRV_FABRIC_CMD_WORD_FE],")
    InsBufLine(hbuf, ln, "    /* $4 fe */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdFap
 ��������  : ����Fap����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdFap()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_FAP,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(g_aszDrvFabricCmdWord[DRV_FABRIC_CMD_WORD_FAP],")
    InsBufLine(hbuf, ln, "    /* $4 fap */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdSerDesParam
 ��������  : ����SerDesParam����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdSerDesParam()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_SERDES_PARAM,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(g_aszDrvFabricCmdWord[DRV_FABRIC_CMD_WORD_SERDES_PARAM],")
    InsBufLine(hbuf, ln, "    /* $5 serdes-parameter */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdSlot
 ��������  : ����slot����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdSlot()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_ELEM_SLOT,")
    InsBufLine(hbuf, ln, "                                     DRV_GetGeneralHelpInfo(),")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(DRV_GetGeneralCmdWord(DRV_ELEM_SLOT),")
    InsBufLine(hbuf, ln, "    /* $N slot */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdSlotId
 ��������  : ����SlotId����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdSlotId()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_SLOTID,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CMO_DRV_FABRIC_XXX_SLOTID,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(\"INTEGER\",")
    InsBufLine(hbuf, ln, "    /* $N slotid */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdChip
 ��������  : ����chip����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdChip()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_ELEM_CHIP,")
    InsBufLine(hbuf, ln, "                                     DRV_GetGeneralHelpInfo(),")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(DRV_GetGeneralCmdWord(DRV_ELEM_CHIP),")
    InsBufLine(hbuf, ln, "    /* $N chip */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdChipNum
 ��������  : ����chipnum����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdChipNum()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_CHIPNUM,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CMO_DRV_FABRIC_XXX_CHIPNUM,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(\"INTEGER\",")
    InsBufLine(hbuf, ln, "    /* $N chipnum */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdLink
 ��������  : ����link����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdLink()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_LINK,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(g_aszDrvFabricCmdWord[DRV_FABRIC_CMD_WORD_LINK],")
    InsBufLine(hbuf, ln, "    /* $N link */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdLinkNum
 ��������  : ����linknum����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdLinkNum()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_LINKNUM,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CMO_DRV_FABRIC_XXX_LINKNUM,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(\"INTEGER\",")
    InsBufLine(hbuf, ln, "    /* $N linknum */")
}

/*****************************************************************************
 �� �� ��  : InsertCmdInteger
 ��������  : ����Integer����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��3��15��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCmdInteger()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "                                     &NewCmdVec);")
    InsBufLine(hbuf, ln, "                                     DRV_FABRIC_INFO_YYY,")
    InsBufLine(hbuf, ln, "                                     g_astDrvFabricHelpInfo,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     NULL,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CLI_USELESS_PARA,")
    InsBufLine(hbuf, ln, "                                     CMO_DRV_FABRIC_XXX,")
    InsBufLine(hbuf, ln, "    ulRet += CLI_NewDefineCmdElement(\"INTEGER\",")
    InsBufLine(hbuf, ln, "    /* $N XXX */")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcDevNumInt
 ��������  : �����ڲ�����������ȫ���豸�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcDevNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ�����������ȫ���豸�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_DEVNUM_INT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcSlotIdInt
 ��������  : �����ڲ������������λ�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcSlotIdInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ������������λ�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_SLOTID_INT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcChipNumInt
 ��������  : �����ڲ�����������оƬ�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcChipNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ�����������оƬ�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_CHIPNUM_INT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcLinkNumInt
 ��������  : �����ڲ�������������·�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcLinkNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ�������������·�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_LINKNUM_INT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcDevNumInt
 ��������  : �����ڲ��������߿���ȫ���豸�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcDevNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ��������߿���ȫ���豸�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_DEVNUM_INT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcSlotIdInt
 ��������  : �����ڲ��������߿����λ�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcSlotIdInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ��������߿����λ�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_SLOTID_INT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcChipNumInt
 ��������  : �����ڲ��������߿���оƬ�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcChipNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ��������߿���оƬ�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_CHIPNUM_INT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcLinkNumInt
 ��������  : �����ڲ��������߿�����·�źϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcLinkNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ��������߿�����·�źϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_LINKNUM_INT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcPortNumInt
 ��������  : �����ڲ��������߿���˿ںźϷ��Զ���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��19��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcPortNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ��������߿���˿ںźϷ��Զ��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_PORTNUM_INT(ucPortNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcDevNumExt
 ��������  : �����ⲿ�������������ȫ���豸���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcDevNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ�������������ȫ���豸���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_DEVNUM_EXT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcSlotIdExt
 ��������  : �����ⲿ��������������λ���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcSlotIdExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ��������������λ���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_SLOTID_EXT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcChipNumExt
 ��������  : �����ⲿ�������������оƬ���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcChipNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ�������������оƬ���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_CHIPNUM_EXT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckSfcLinkNumExt
 ��������  : �����ⲿ���������������·���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckSfcLinkNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ���������������·���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_LINKNUM_EXT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcDevNumExt
 ��������  : �����ⲿ�������������ȫ���豸���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcDevNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ����������߿���ȫ���豸���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_DEVNUM_EXT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcSlotIdExt
 ��������  : �����ⲿ����������߿����λ���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcSlotIdExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ����������߿����λ���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_SLOTID_EXT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcChipNumExt
 ��������  : �����ⲿ����������߿���оƬ���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcChipNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ����������߿���оƬ���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_CHIPNUM_EXT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcLinkNumExt
 ��������  : �����ⲿ����������߿�����·���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcLinkNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ����������߿�����·���Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_LINKNUM_EXT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckLcPortNumExt
 ��������  : �����ⲿ����������߿��˿�·���Ƿ�Ϸ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckLcPortNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ����������߿���˿ں��Ƿ�Ϸ� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_PORTNUM_EXT(ucPortNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheckPointerInt
 ��������  : �����ڲ����������ָ��ǿն���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckPointerInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ����������ָ��ǿն��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_POINTER_INT(pPointer);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheck2PointerInt
 ��������  : �����ڲ��������������ָ��ǿն���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��14��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheck2PointerInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ��������������ָ��ǿն��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_TWO_POINTER_INT(pPointer1, pPointer2);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheck3PointerInt
 ��������  : �����ڲ����������ָ��ǿն���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��14��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheck3PointerInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ڲ��������������ָ��ǿն��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_THREE_POINTER_INT(pPointer1, pPointer2, pPointer3);")
    InsBufLine(hbuf, ln+3, " ")
}


/*****************************************************************************
 �� �� ��  : InsertCheckPointerExt
 ��������  : �����ⲿ������������ָ���Ƿ�Ϊ��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��12��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheckPointerExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ������������ָ���Ƿ�Ϊ�� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_POINTER_EXT(pPointer);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheck2PointerExt
 ��������  : �����ⲿ����������������ָ���Ƿ�Ϊ��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��14��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheck2PointerExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ����������������ָ���Ƿ�Ϊ�� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_TWO_POINTER_EXT(pPointer1, pPointer2);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertCheck3PointerExt
 ��������  : �����ⲿ����������������ָ���Ƿ�Ϊ��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��4��14��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCheck3PointerExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* �ⲿ����������������ָ���Ƿ�Ϊ�� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_THREE_POINTER_EXT(pPointer1, pPointer2, pPointer3);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 �� �� ��  : InsertDbgLog
 ��������  : ���������־
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��7��25��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertDbgLog()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* ������־ */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_DebugDiagLog(DRV_FABRIC_FILE_ID, __LINE__,")
    InsBufLine(hbuf, ln+3, "                            DRV_FABRIC_DIAGLOG_INFO_ID(IC_LEVEL_ERR),")
    InsBufLine(hbuf, ln+4, "                            \"\\r\\nDevNum=%u, AddrNum1=%X, AddrNum2=%x, enSrcType=%u, ulEndOffset = 0x%x\",")
    InsBufLine(hbuf, ln+5, "                            ucDevNum, ulAddrNum, ulAddrNum2, enSrcType, ulEndOffset);")
    InsBufLine(hbuf, ln+6, " ")
}

/*****************************************************************************
 �� �� ��  : InsertErrLog
 ��������  : ���������־
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��7��25��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertErrLog()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   "        DRV_FABRIC_ErrorDiagLog(DRV_FABRIC_FILE_ID, __LINE__,")
    InsBufLine(hbuf, ln+1, "                                DRV_FABRIC_DIAGLOG_INFO_ID(IC_LEVEL_ERR),")
    InsBufLine(hbuf, ln+2, "                                \"\\r\\n%s p1=0x%x, p2=%u, p3=0x%x, p4=0x%x\",")
    InsBufLine(hbuf, ln+3, "                                DRV_FABRIC_GetDebugInfo(DRV_FABRIC_DBG_GET_PCA9555_FAIL),")
    InsBufLine(hbuf, ln+4, "                                ucDevAddr, ucReg, (ULONG)pulSendDataLen, (ULONG)ppSendData);")
    InsBufLine(hbuf, ln+5, "        return VOS_ERR;")
    InsBufLine(hbuf, ln+6, " ")
}

/*****************************************************************************
 �� �� ��  : InsertFapInitErrLog
 ��������  : ����FAP��ʼ��������־
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2009��1��19��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFapInitErrLog()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   "    /* ������ģ��FAP��ʼ�����ִ��󷵻ش��� */")
    InsBufLine(hbuf, ln+1, "    DRV_FAP_INIT_RET_PROC(ulRet, ulSandRet, ucChipNum);")
    InsBufLine(hbuf, ln+2, " ")
}

/*****************************************************************************
 �� �� ��  : InsertTestLog
 ��������  : ���������־
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2008��11��21��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTestLog()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   "    /* ���Դ���  HSDTESTCODE */")
    InsBufLine(hbuf, ln+1, "    if (DRV_SYSM_OPEN_DEBUG == g_ulDrvFabricTestPrintFlg)")
    InsBufLine(hbuf, ln+2, "    {")
    InsBufLine(hbuf, ln+3, "    }")
    InsBufLine(hbuf, ln+4, "")
}

/*****************************************************************************
 �� �� ��  : InsertRpc
 ��������  : ���������־
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2009��2��25��
    ��    ��   : ������
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertRpc()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst

    InsBufLine(hbuf, ln,   "    /* BEGIN: Modified by z06321, 2009/2/25   PN:HSDGETNODEID */")
    InsBufLine(hbuf, ln+1, "    /* ������ģ��RPC���ô��� */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_RPC_PROC(usSlotId, ulNodeId, ulRet, pstSendData, ulSendLen, pstRecvData, ulReceiveLen);")
    InsBufLine(hbuf, ln+3, "    /*   END: Modified by z06321, 2009/2/25   PN:HSDGETNODEID */")
}

macro LookupRefs()
{
    hbuf = NewBuf("Results") // create output buffer
    if (hbuf == 0)
        stop
    SearchForRefs(hbuf, "HSD40996", 0)
    SetCurrentBuf(hbuf) // put buffer in a window
}


/*****************************************************************************
 �� �� ��  : unCommentStr
 ��������  : ת��C++ע��ΪCע��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��5��15��
    ��    ��   : l04615
    �޸�����   : �����ɺ���,ȥ���ַ����е�ע���ַ�

*****************************************************************************/
macro unCommentStr(str)
{
	istrlen = strlen(str)
	nIdx = 0

	if (istrlen < 2)
		return str
    
    while (nIdx<istrlen-1)
    {
        if( (( str[nIdx] == "/" ) && (str[nIdx+1] == "*"))||
             (( str[nIdx] == "*" ) && (str[nIdx+1] == "/")) )
        {
            str[nIdx] = " "
            str[nIdx+1] = " "
        }
        nIdx = nIdx + 1
    }
	return str
}

macro siMin(x, y)
{
	if (x < y)
	{
		return x
	}else
		return y
}

macro siMax(x, y)
{
	if (x>y)
	{
		return x
	}else
		return y
}

macro beginWithComment(Line)
{
	fLine = TrimLeft(Line)
	len = strlen(fLine)
	if (len<2)
		return 0
	return ((fLine[0]=="/") &&(fLine[1]=="*"))
}

macro endWithComment(Line)
{
	lLine = TrimRight(Line)
	len = strlen(lLine)
	if (len<2)
		return 0
	return ((lLine[len-1]=="/")&&(lLine[len-2]=="*"))

}
macro getRightBlank(line)
{
	len = strlen(line)
	while (len)
	{
		if ((line[len-1]!=" ")||(line[len-1]!="\t"))
			break;

		len = len - 1
	}

	return len;
	
}
/*****************************************************************************
 �� �� ��  : CommentSelection
 ��������  : ��ѡ�е��п�ע�ͻ�ע��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2008��5��15��
    ��    ��   : l04615
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentSelection()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    icharFirst = GetWndSelIchFirst ( hwnd)
    icharLim = GetWndSelIchLim (hwnd)
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
    lnOld = 0

    if (lnFirst==lnLast) /* just select one line */
    {
    	if (icharFirst!=icharLim) /*  has selected some thing */
    	{
			szLine = GetBufLine(hbuf,lnCurrent)    
			ilen = strlen(szLine)
			nLeft = GetLeftBlank(szLine);
			nRight = getRightBlank(szLine);

			if (nLeft < icharLim)
			{
				icharFirst = siMax(icharFirst, nLeft)
			}
			icharLim = siMin(icharLim, nRight)
			
			szLeft = strmid(szLine, 0, icharFirst)
			szSel = strmid (szLine, icharFirst, icharLim)
			szRight = strmid(szLine, icharLim, ilen)

			iSelen = strlen(szSel)
			if (iSelen >0 )
			{
				if ((beginWithComment(szSel))&&(endWithComment(szSel)))
				{
					unCmtSel = strmid(szSel, 2, iSelen -2)
					unCmtSel = TrimString(unCmtSel)
					szLine = cat(szLeft, unCmtSel)
					szLine = cat(szLine, szRight)
				}
				else
				{

					szSel = unCommentStr(szSel)

					szLine = cat(szLeft, "/* ")
					szLine = cat(szLine, szSel)
					szLine = cat(szLine,  " */")
					szLine = cat(szLine, szRight)

				}
				PutBufLine(hbuf, lnCurrent, szLine)
			}
		}
    }
    else /* more than one line has been selected */
    {
	    while ( lnCurrent <= lnLast )
	    {
	        szLine = GetBufLine(hbuf,lnCurrent)
	        nLeft = GetLeftBlank(szLine)
	        nRight = getRightBlank(szLine)
	        iLineLen = strlen(szLine)

	        if (lnCurrent == lnFirst) /* the first line */
	        {
	        	icharFirst = siMax(nLeft, icharFirst)
	        	szLeft = strmid(szLine,0,icharFirst)
	        	szRight = strmid(szLine,icharFirst,iLineLen)
	        	szRight = TrimLeft(szRight)

	        	if (beginWithComment(szRight))
	        	{
	        		szRight = unCommentStr(szRight)	 
	        		szRight = TrimLeft(szRight)
	        		szLine = szLeft
	        	}
	        	else
	        	{
		        	szRight = unCommentStr(szRight)
		        	szLine = cat(szLeft, "/* ")
	        	}
	       	}
	       	else
	       	if (lnCurrent == lnLast ) /* the last line */
	       	{
	       		icharLim = siMin(nRight, icharLim)
				szLeft = strmid(szLine,0,icharLim)
				szRight = strmid(szLine, icharLim, iLineLen)
				szLeft = TrimRight(szLeft)
	       		if (endWithComment(szLeft))
	       		{	
	       			szLine = unCommentStr(szLeft)
	       		}
	       		else
	       		{
					szLeft = unCommentStr(szLeft)
					szLine = cat(szLeft, " */")
				}
	       	}
	       	else  /* other lines */
	       	{
				szLeft = strmid(szLine, 0, nLeft)
				if (nLeft > iLineLen)
					nLeft = iLineLen
				szRight = strmid(szLine, nLeft, iLineLen)
				ilen = strlen(szRight)
				if (ilen >0)
				{
					szRight = unCommentStr(szRight)
				}
				szLine = szLeft
	       	}

			szLine = cat(szLine, szRight)
			
			PutBufLine(hbuf, lnCurrent, szLine)
	        
	       	lnCurrent = lnCurrent + 1
	    }
	}


}


/**
 *
 * ����SourceInsightԭ�е�Backspace���ܣ�ϣ����ˣ�
 * �����˶�˫�ֽں��ֵ�֧�֣���ɾ�����ֵ�ʱ��Ҳ��ͬʱɾ�����ֵĸ��ֽڶ���������������
 * �ܹ��Թ���ں����м����������Զ�����
 *
 * ��װ��
 * �� ������SourceInsight��װĿ¼��
 * �� Project��Open Project����Base��Ŀ��
 * �� �����ƹ�ȥ��SuperBackspace.em�����Base��Ŀ��
 * �� ����SourceInsight��
 * �� Options��Key Assignments����Marco: SuperBackspace�󶨵�BackSpace����
 * �� Enjoy����
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
macro SuperBackspace()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();

    if (hbuf == 0)
        stop;   // empty buffer

    // get current cursor postion
    ipos = GetWndSelIchFirst(hwnd);

    // get current line number
    ln = GetBufLnCur(hbuf);

    if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) {
        // sth. was selected, del selection
        SetBufSelText(hbuf, " ");  // stupid & buggy sourceinsight :(
        // del the " "
        SuperBackspace(1);
        stop;
    }

    // copy current line
    text = GetBufLine(hbuf, ln);

    // get string length
    len = strlen(text);

    // if the cursor is at the start of line, combine with prev line
    if (ipos == 0 || len == 0) {
        if (ln <= 0)
            stop;   // top of file
        ln = ln - 1;    // do not use "ln--" for compatibility with older versions
        prevline = GetBufLine(hbuf, ln);
        prevlen = strlen(prevline);
        // combine two lines
        text = cat(prevline, text);
        // del two lines
        DelBufLine(hbuf, ln);
        DelBufLine(hbuf, ln);
        // insert the combined one
        InsBufLine(hbuf, ln, text);
        // set the cursor position
        SetBufIns(hbuf, ln, prevlen);
        stop;
    }

    num = 1; // del one char
    if (ipos >= 1) {
        // process Chinese character
        i = ipos;
        count = 0;
        while (AsciiFromChar(text[i - 1]) >= 160) {
            i = i - 1;
            count = count + 1;
            if (i == 0)
                break;
        }
        if (count > 0) {
            // I think it might be a two-byte character
            num = 2;
            // This idiot does not support mod and bitwise operators
            if ((count / 2 * 2 != count) && (ipos < len))
                ipos = ipos + 1;    // adjust cursor position
        }
    }

    // keeping safe
    if (ipos - num < 0)
        num = ipos;

    // del char(s)
    text = cat(strmid(text, 0, ipos - num), strmid(text, ipos, len));
    DelBufLine(hbuf, ln);
    InsBufLine(hbuf, ln, text);
    SetBufIns(hbuf, ln, ipos - num);
    stop;
}


/*****************************************************************************
 �� �� ��  : FuncStorwareItem
 ��������  : ����Storware��־/������id������Ϣ
 �������  : hbuf      
             ln        	�к�
             left
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 �޸���ʷ      :
  1.��    ��   : 2010��9��20��
    ��    ��   : h05000
    �޸�����   : �����ɺ���
*****************************************************************************/
macro FuncStorwareItem(hbuf, ln, left)
{
    tln = ln
    len = strlen(left)
    szLeft = CreateBlankString(len)
    szBlank = CreateBlankString(strlen("ITEM_INFO("))
    szLeft2 = cat(szLeft,szBlank)
	
    DelBufLine(hbuf, tln)
    
    InsBufLine(hbuf, tln, "@szLeft@/*************************************************************************")
    tln = tln + 1
    ln_id = tln
    InsBufLine(hbuf, tln, "@szLeft@*ID:")
    tln = tln + 1
    ln_trigger = tln
    InsBufLine(hbuf, tln, "@szLeft@*Trigger Action:")  
    tln = tln + 1
    ln_Recommend = tln
    InsBufLine(hbuf, tln, "@szLeft@*Recommended Action:")
    tln = tln + 1
    InsBufLine(hbuf, tln, "@szLeft@*************************************************************************/")
    tln = tln + 1
    ln_def = tln
    InsBufLine(hbuf, tln, "@szLeft@ITEM_INFO(,")
    tln = tln + 1
    ln_en = tln
    InsBufLine(hbuf, tln, "@szLeft2@\"\",")
    tln = tln + 1
    ln_cn = tln
    InsBufLine(hbuf, tln, "@szLeft2@\"\"),")

    /*
    *  �Ի���ѭ��: id�궨�塢Ӣ������������������
                   idʵ��ֵ�������������ο�����
    */


    /* ��¼�Ӻ궨�忪ʼ���ӵ����� */	
    add_count_1 = 0	
    
    tmp_ln = ln_def + add_count_1
    /* �����־/������궨�� */
    szRet = Ask("��־/������궨��:")
    seRet = trimleft(seRet)
    if(strlen(szRet) > 0)
    {	    	    	
        DelBufLine(hbuf, tmp_ln)	
        InsBufLine(hbuf, tmp_ln, "@szLeft@ITEM_INFO(@szRet@,")
    }
    
    /* ���Ӣ��������Ϣ */
    tmp_ln = ln_en + add_count_1
    szContent = Ask("Ӣ��������Ϣ:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    szContent = cat(szContent, "\",")
    newln = CommentContent(hbuf, tmp_ln, "@szLeft2@\"", szContent, 0, 80)   
    add_count_1 = add_count_1 + newln - tmp_ln   

    /* �������������Ϣ */
    tmp_ln = ln_cn + add_count_1
    szContent = Ask("����������Ϣ:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    szContent = cat(szContent, "\"),")
    newln = CommentContent(hbuf, tmp_ln, "@szLeft2@\"", szContent, 0, 80)   
    add_count_1 = add_count_1 + newln - tmp_ln  


    /* ��¼��ʵ��ֵ��ʼ���ӵ����� */
    add_count_2 = 0

    /* ���id */
    tmp_ln = ln_id + add_count_2
    szRet = Ask("��־ID��������ʵ��ֵ:")
    seRet = TrimLeft(seRet)
    if(strlen(szRet) > 0)
    {	
        DelBufLine(hbuf, tmp_ln)	
        InsBufLine(hbuf, tmp_ln, "@szLeft@*ID:@szRet@")
    }
    
    /* ��Ӵ������� */
    tmp_ln = ln_trigger + add_count_2
    szContent = Ask("�Գ��ָô�����ӡ����־ʱ�����еĲ����������������˵��:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    newln = CommentContent(hbuf, tmp_ln, "@szLeft@*Trigger Action:", szContent, 0, 80)   
    add_count_2 = add_count_2 + newln - tmp_ln    

    /* ��Ӳο����� */
    tmp_ln = ln_Recommend + add_count_2
    szContent = Ask("���ָ�������Ƽ��Ĵ�����:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    newln = CommentContent(hbuf, tmp_ln, "@szLeft@*Recommended Action:", szContent, 0, 80)   
    add_count_2 = add_count_2 + newln - tmp_ln   


    return tln + add_count_1 + add_count_2
	
}

/* Storware UTC ��������ID�б���ֶ�λ��
 * ��������ID��ʽΪ: UT_���⺯����_001	
*/
macro lookupUtcId(str)
{
	len = strlen(str)
 
    i = len-1
    while( i > 0)
    {
        if((str[i]=="0")||(str[i]=="1")||(str[i]=="2")||(str[i]=="3")||(str[i]=="4")
        	||(str[i]=="5")||(str[i]=="6")||(str[i]=="7")||(str[i]=="8")
        	||(str[i]=="9"))
        {
        	i=i-1        	
        	continue
		}
		else if (str[i]=="_" || str[i] == ".")
		{		
			return i;
		}
		else
		{
			return len
		}   
    }  
    return len
}



/*****************************************************************************
 �� �� ��  : UtcFuncHead
 ��������  : UtcFuncHead��������
 �������  : hbuf      
             ln        	�к�
             szUid     	���⺯��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 �޸���ʷ      :
  1.��    ��   : 2010��9��20��
    ��    ��   : h05000
    �޸�����   : �����ɺ���
*****************************************************************************/
macro UtcFuncHead(hbuf, ln, szFuncName)
{
    tln = ln
    szDefId = "001"
	
    InsBufLine(hbuf, tln, "/******************************************************************************")
    tln = tln + 1
    ln_id = tln
    InsBufLine(hbuf, tln, " �� �� ID  ��UT_@szFuncName@_@szDefId@")
    tln = tln + 1 
    ln_item = tln
    InsBufLine(hbuf, tln, " �� �� ��  ��")  
    tln = tln + 1 
    ln_title = tln
    InsBufLine(hbuf, tln, " ��������  ��")	
    tln = tln + 1 
    ln_level = tln
    InsBufLine(hbuf, tln, " ��Ҫ����  ��")
    tln = tln + 1 
    ln_cond = tln
    InsBufLine(hbuf, tln, " Ԥ������  ��")  
    tln = tln + 1 
    ln_input = tln
    InsBufLine(hbuf, tln, " ��    ��  ��")	
    tln = tln + 1 
    ln_result = tln
    InsBufLine(hbuf, tln, " Ԥ�ڽ��  ��")
    tln = tln + 1 
    InsBufLine(hbuf, tln, "******************************************************************************/")
    tln = tln + 1 
    ln_func = tln
    InsBufLine(hbuf,tln,  "TEST(UT_@szFuncName@, @szDefId@)")
	
    /* ������������ʽ����"UT_���⺯����_001" ʱ�Ĵ���
    // ���ݲ���������ֱ��
    if (strlen(szUid) > 0)
    {
	    len = strlen(szUid)
        ret = lookupUtcId(szUid)
	    if (ret != len)
	    {
            left = strmid(szUid,0,ret)
            right = strmid(szUid, ret+1, len)
            InsBufLine(hbuf,tln, "TEST(@left@, @right@)")    
        }
        else
        {
            InsBufLine(hbuf,tln, "TEST(@szUid@, )")
        }
	}
	*/
	
    tln = tln + 1 
    InsBufLine(hbuf,tln, "{");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    UT_BEGIN;");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* ���庯�����ò��� */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* ���屻�⺯������ֵ */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* Ԥ������ */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /*");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "     * ���챻�⺯����Ρ�����");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "     */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* �Ա��⺯����׮ */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* ���ñ��⺯�� */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* Ԥ�ڽ�� */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");        
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* ������Ի��� */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");        
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    UT_END;");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "}");

    /* ���id */
    szRet = Ask("���⺯�����������,��\"001\":")
    seRet = TrimLeft(seRet)
    if(strlen(szRet) > 0)
    {	
        DelBufLine(hbuf, ln_id)	
        InsBufLine(hbuf, ln_id, " �� �� ID  ��UT_@szFuncName@_@szRet@")
    }
    DelBufLine(hbuf, ln_func)	
    InsBufLine(hbuf, ln_func,  "TEST(UT_@szFuncName@, @szRet@)")
  
    /* �Ի����������ӵ����� */  
    addlncount = 0

    /* ���������� */
    ttln = ln_item + addlncount
    szContent = Ask("����������:")
    DelBufLine(hbuf, ttln)
    newln = CommentContent(hbuf, ttln, " �� �� ��  ��", szContent, 0, 80)   
    addlncount = addlncount + newln - ttln  

    /* ������������ */
    ttln = ln_title + addlncount
    szContent = Ask("��������:")
    DelBufLine(hbuf, ttln)
    newln = CommentContent(hbuf, ttln, " ��������  ��", szContent, 0, 80)   
    addlncount = addlncount + newln - ttln  
	
    /* ��������Ҫ���� */
    ttln = ln_level + addlncount
    szContent = Ask("��Ҫ����:")
    DelBufLine(hbuf, ttln)
    newln = CommentContent(hbuf, ttln, " ��Ҫ����  ��", szContent, 0, 80)   
    addlncount = addlncount + newln - ttln  

    staff = "            "	// �����ж����ַ�
    /* ����Ԥ������ */
    count = 0 				// Ԥ����������
    t_add = 0				// ��������
    ttln = ln_cond + addlncount		// "Ԥ������"�ַ���λ��
    tmp_ln = ttln
    while (1)	// ѭ������Ԥ������
    {
        szParam = ask("����Ԥ������,�Կո����")
        szParam = TrimLeft(szParam)
        if (szParam == "")
        {
            break;
        }
        count = count + 1
        szTmp = cat(staff, count) 
        szTmp = cat(szTmp, ". ") 
        tmp_ln = ttln + t_add + 1 			// ����һ�в���
        newln = CommentContent(hbuf, tmp_ln, szTmp, szParam, 0, 80)       	
        t_add = t_add + (newln - tmp_ln) + 1	// ѭ�������ӵ�����
	
    }
    addlncount = addlncount + t_add

    /* �������� */
    ttln = ln_input + addlncount
    count = 0 
    t_add = 0				// ��������
    tmp_ln = ttln
    while (1)	// ѭ����������
    {
        szParam = ask("��������,�Կո����")
        szParam = TrimLeft(szParam)
        if (szParam == "")
        {
            break;
        }
        count = count + 1	
        szTmp = cat(staff, count) 
        szTmp = cat(szTmp, ". ") 
        tmp_ln = ttln + t_add + 1 // ����һ�в��� 	
        newln = CommentContent(hbuf, tmp_ln, szTmp, szParam, 0, 80)       	
        t_add = t_add + (newln - tmp_ln) + 1	// ѭ���������ӵ�����	
    }	
    addlncount = addlncount + t_add

    /* ����Ԥ�ڽ�� */
    ttln = ln_result + addlncount    	
    count = 0
    t_add = 0				// ��������
    tmp_ln = ttln
    while (1)	// ѭ����������
    {
        szParam = ask("����Ԥ�ڽ��,�Կո����")
        szParam = TrimLeft(szParam)
        if (szParam == "")
        {
            break;
        }
        count = count + 1
        szTmp = cat(staff, count) 
        szTmp = cat(szTmp, ". ") 
        tmp_ln = ttln + t_add + 1 	// ��������λ��
        newln = CommentContent(hbuf, tmp_ln, szTmp, szParam, 0, 80)       	
        t_add = t_add + (newln - tmp_ln) + 1	// ѭ���������ӵ�����
	
    }
    addlncount = addlncount + t_add

    /* �����к� */
    return tln + addlncount
}



/*****************************************************************************
 �� �� ��  : CreatePythonCommonNewFile
 ��������  : ����һ���µ�python�ļ����ļ��������롣
 �������  : ��
 �������  : ��
 �� �� ֵ  : szFileName ���ɵ��ļ���
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2010��10��19��
    ��    ��   : h05000
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreatePythonCommonNewFile()
{
    hbuf = GetCurrentBuf()

    szFileName = ask("�������ļ���:")

    hOutbuf = NewBuf(szFileName) // create output buffer
    if (hOutbuf == 0)
        stop

    SetCurrentBuf(hOutbuf)

    /* �����ļ��ĵ�һ�п�ʼд */ 
    ln = 0	

    InsBufLine(hOutbuf, ln,     "#!/usr/bin/python")
    InsBufLine(hOutbuf, ln + 1, "# -*- coding: cp936 -*-")
    InsBufLine(hOutbuf, ln + 2, "'''Filename: @szFileName@'''")  
    InsBufLine(hOutbuf, ln + 3, " ")  


    /* ���ļ�β����ӽ������� */    
    iTotalLn = GetBufLineCount (hOutbuf)            
    InsBufLine(hOutbuf, iTotalLn, "")
    InsBufLine(hOutbuf, iTotalLn, "# End of @szFileName@")            
    InsBufLine(hOutbuf, iTotalLn, "")            
    InsBufLine(hOutbuf, iTotalLn, "")            
    InsBufLine(hOutbuf, iTotalLn, "")            
    InsBufLine(hOutbuf, iTotalLn, "")


    /* ��궨λ */
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = 0
    
    sel.lnFirst = ln+4
    sel.lnLast = ln+4 
    SetWndSel(hwnd,sel)

    return szFileName
}


/*****************************************************************************
 �� �� ��  : CreateStNewFile
 ��������  : ����һ���µĲ������ļ����ļ��������롣
 �������  : hbuf      
             ln        	�к�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2010��10��19��
    ��    ��   : h05000
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertStcInitRecord(hbuf, ln, szFileName)
{
    tln = ln
    InsBufLine(hbuf, tln, "")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import os")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import sys")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import re")
    tln = tln + 1
    InsBufLine(hbuf, tln, "")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import st_ssh")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import st_log")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import st_stat")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import st_common")
    tln = tln + 1
    InsBufLine(hbuf, tln, "import st_conf")
    tln = tln + 1
    InsBufLine(hbuf, tln, "")
    tln = tln + 1
    InsBufLine(hbuf, tln, "#==========================================================================")
    tln = tln + 1
    InsBufLine(hbuf, tln, "# Initializing Log and Report.")
    tln = tln + 1
    InsBufLine(hbuf, tln, "# initlog(level, name, path):")
    tln = tln + 1
    InsBufLine(hbuf, tln, "# level: \"base\", \"extended\", \"advanced\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "# name : log_name must be log_Filename, report_name can be report_Filename.")    
    tln = tln + 1
    InsBufLine(hbuf, tln, "# path : \"st_conf.HOME_PATH/storware_st/log/st_log_\",  \"st_conf.HOME_PATH/storware_st/log/st_report_\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "#==========================================================================")
    tln = tln + 1
    InsBufLine(hbuf, tln, "")
    tln = tln + 1
    InsBufLine(hbuf, tln, "# Initializing log, log_name must be \"log_ + Filename\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "LOG_LEVEL = \"base\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "LOG_NAME = \"log_@szFileName@\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "LOG_PATH = st_conf.HOME_PATH+\"storware_st/log/st_log_\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "LOG, LOGFILE = st_log.init_log(LOG_LEVEL, LOG_NAME, LOG_PATH)")
    tln = tln + 1
    InsBufLine(hbuf, tln, "")
    tln = tln + 1
    InsBufLine(hbuf, tln, "# Initializing report, report_name must be \"report_ + Filename\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "REPORT_LEVEL = \"base\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "REPORT_NAME = \"report_@szFileName@\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "REPORT_PATH = st_conf.HOME_PATH+\"storware_st/log/st_report_\"")
    tln = tln + 1
    InsBufLine(hbuf, tln, "REPORT, REPORTFILE = st_log.init_log(REPORT_LEVEL, REPORT_NAME, REPORT_PATH)")
    tln = tln + 1
    InsBufLine(hbuf, tln, "")


    /* ��궨λ�� ����֮�� */
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = 0
    
    sel.lnFirst = tln + 2
    sel.lnLast = tln + 2 

    SetWndSel(hwnd,sel)

}



/*****************************************************************************
 �� �� ��  : CreateStNewFile
 ��������  : ����һ���µĲ��������ļ����ļ��������롣
 �������  : ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2010��10��20��
    ��    ��   : h05000
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateStNewFile()
{
    /* ����pythonͷ */
    szFileName = CreatePythonCommonNewFile()

    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst;
        
    hbuf = GetWndBuf(hwnd)
	/* ���������ļ���׼�ļ�ͷ */
    InsertStcInitRecord(hbuf, ln, szFileName)

}


/*****************************************************************************
 �� �� ��  : CreateStPyFunc
 ��������  : ����ST��ص�python���ܺ���
 �������  : hbuf      
             ln        	�к�
             szFunc		��������
             szMyName 	�û��� 			 
 �������  : ��
 �� �� ֵ  : 
 
 �޸���ʷ      :
  1.��    ��   : 2010��10��20��
    ��    ��   : h05000
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateStPyFunc(hbuf, ln, szFunc, szMyName)
{
    tln = ln
    SysTime = GetSysTime(1);
    szTime = SysTime.Date

    InsBufLine(hbuf, tln,   "def @szFunc@():")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    ��������       ��@szFunc@")
    tln = tln + 1
    ln_func = tln /* ��¼λ�� */
    InsBufLine(hbuf, tln,   "    ��������       ��")  
    tln = tln + 1
    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, tln,"    ��    ��       ��@szMyName@")
    }
    else
    {
       InsBufLine(hbuf, tln,"    ��    ��       :")
    }	
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    ��������       ��@szTime@")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    ���ʵ�ȫ�ֱ��� ��")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    �޸ĵ�ȫ�ֱ��� ��")  
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    ��    ��       ��")	  
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    ��    ��       ��")	
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    �� �� ֵ       ��")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    ��    ��       ��")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''")


    add_count = 0 	// ���ӵ�����
	
    /* �������� */
    szContent = Ask("�����뺯����������")
    DelBufLine(hbuf, ln_func)
    newln = CommentContent(hbuf, ln_func, "    ��������       ��", szContent, 0, 80)   
    add_count = newln - ln_func  

    /* ���һ���к� */
    return tln + add_count	
}

/*****************************************************************************
 �� �� ��  : StFuncHead
 ��������  : Storware STC��������
 �������  : hbuf      
             ln        	�к�
             szUid     	��������id����ʽΪ:st_���⺯����_001
 �������  : ��
 �� �� ֵ  : �������һ�е�λ��
 ���ú���  : 
 ��������  : 
 �޸���ʷ      :
  1.��    ��   : 2010��9��20��
    ��    ��   : h05000
    �޸�����   : �����ɺ���
*****************************************************************************/
macro StcFuncHead(hbuf, ln, szSid)
{
    tln = ln
    
    /* ��д��ʽ������ */
    szName = toupper(szSid)

    InsBufLine(hbuf, tln, "# ST_TEST_CASE_BEGIN @szName@")
    tln = tln + 1
    InsBufLine(hbuf, tln, "")
    tln = tln + 1
    InsBufLine(hbuf, tln, "def @szName@():")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    �� �� ID  ��@szName@")
    tln = tln + 1
    ln_item = tln
    InsBufLine(hbuf, tln, "    �� �� ��  ��")  
    tln = tln + 1
    ln_title = tln
    InsBufLine(hbuf, tln, "    ��������  ��")	
    tln = tln + 1
    ln_level = tln
    InsBufLine(hbuf, tln, "    ��Ҫ����  ��")
    tln = tln + 1
    ln_state = tln
    InsBufLine(hbuf, tln, "    ����״̬  ��")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    Ԥ������  ��")  
    tln = tln + 1
    InsBufLine(hbuf, tln, "    ��    ��  ��")	
    tln = tln + 1
    InsBufLine(hbuf, tln, "    ��������  ��")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    Ԥ�ڽ��  ��")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    try:")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        # Define test case's name")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        test_case = r'@szName@'")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        # Begin log, don't modify")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        st_log.st_begin(test_case, LOG)")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        # [step 1] Pre-condition initialization")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        LOG.info ('[step 1] Pre-condition initialization')")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        result = 'ok'")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        client = st_ssh.ssh_connect()")    
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        # [step 2] Tested command call")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        LOG.info ('[step 2] Tested command call')")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        # [step 3] Check result")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        LOG.info ('[step 3] Check result')")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        # [step 4] Clear environment")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        LOG.info ('[step 4] Clear environment')")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    except Exception, allerr_msg:")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        LOG.info (r\"Exception:\" + allerr_msg)")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        LOG.info ('Clear environment')")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        result = 'err'")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    finally:")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        # [step 5] Print report")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        LOG.info ('[step 5] Print report')")
    tln = tln + 1
    InsBufLine(hbuf, tln, "        st_common.testcase_end(result, client, REPORT, LOG, test_case)")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    return test_case, result")    
    tln = tln + 1
    InsBufLine(hbuf, tln, "        ")
    tln = tln + 1
    InsBufLine(hbuf, tln, "# End of Testcase_@szName@")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    ")    

	
    lstln = tln
    t_add_count = 0 	// �Ի������ӵ�����

    /* ���������� */
    tln = ln_item
    szContent = Ask("����������:")
    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    �� �� ��  ��", szContent, 0, 80)   
    t_add_count = newln - tln  

    /* ������������ */
    tln = ln_title + t_add_count
    szContent = Ask("��������:")
    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    ��������  ��", szContent, 0, 80)   
    t_add_count = t_add_count + newln - tln  
	
    /* ��������Ҫ���� */
    tln = ln_level + t_add_count
    szContent = Ask("��Ҫ����:")
    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    ��Ҫ����  ��", szContent, 0, 80)   
    t_add_count = t_add_count + newln - tln  

    /* ����������״̬ */
    tln = ln_state + t_add_count
    szContent = Ask("����״̬: A(AUTO) or M(MANUAL) or B(BLOCK)")
	szContent = toupper(szContent)

	if ((szContent == "A")||(szContent == "AUTO")
    {  
        szContent = "AUTO";
    }
	else if ((szContent == "M")||(szContent == "MANUAL"))
    {
        szContent = "MANUAL";
    }
	else if ((szContent == "B")||(szContent == "BLOCK"))
    {
        szContent = "BLOCK";
    }
    else
    {
        /* ���벻������Ϊ�� */
    	szContent = " "
    }

    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    ����״̬  ��", szContent, 0, 80)   
    t_add_count = t_add_count + newln - tln  

    /* �������һ��λ�� */
    return lstln + t_add_count

}



/*****************************************************************************
 �� �� ��  : CreateStPyFunc
 ��������  : ����ST��ص�python���Թ��ܴ���
 �������  : ��		 
 �������  : 
 �� �� ֵ  : ���һ��
 
 �޸���ʷ      :
  1.��    ��   : 2010��10��19��
    ��    ��   : h05000
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateStPyDebug()
{

    hbuf = GetCurrentBuf()
    hwnd = GetCurrentWnd()
    ln = GetWndSelLnFirst(hwnd)

    /* ��ȡû����չ���ĵ�ǰ�ļ����� */
    fileName = GetFileNameNoExt(GetBufName (hbuf))
	
    InsBufLine(hbuf, ln, "# Below is used to debug")    
    ln = ln + 1
    InsBufLine(hbuf, ln, "DEBUG = 0")
    ln = ln + 1
    InsBufLine(hbuf, ln, "")
    ln = ln + 1
    InsBufLine(hbuf, ln, "")
    ln = ln + 1
    InsBufLine(hbuf, ln, "def test():")  
    ln = ln + 1
    InsBufLine(hbuf, ln, "    '''this funtion is used for debugging'''")	
    ln = ln + 1
    InsBufLine(hbuf, ln, "    #st_raid_raid_array_create_001()")
    ln = ln + 1
    InsBufLine(hbuf, ln, "    st_stat.result_parse(REPORTFILE)")
    ln = ln + 1
    InsBufLine(hbuf, ln, "    st_common.st_message('@fileName@')  # this parameter should be Filename")
    ln = ln + 1
    InsBufLine(hbuf, ln, "    ")  
    ln = ln + 1
    InsBufLine(hbuf, ln, "    # copy report for CI")	
    ln = ln + 1
    InsBufLine(hbuf, ln, "    os.popen('cp ' + REPORTFILE + ' ' + st_conf.CC_ST_Log_Path + 'report.txt')")
    ln = ln + 1
    InsBufLine(hbuf, ln, "    os.popen('cp ' + st_conf.CONF_PATH + 'user_st ' + st_conf.CC_ST_File_Path) ")
    ln = ln + 1
    InsBufLine(hbuf, ln, "    ")  
    ln = ln + 1
    InsBufLine(hbuf, ln, "if 1 == DEBUG:")	  
    ln = ln + 1
    InsBufLine(hbuf, ln, "    test()")	
    ln = ln + 1
    InsBufLine(hbuf, ln, "")

    return ln
}




