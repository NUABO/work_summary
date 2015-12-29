/******************************************************************************

  文 件 名   : Quicker.em
  版 本 号   : 2.0.3
  作    者   : lushengwen
  生成日期   : 2002年5月16日
  功能描述   : 编程辅助工具，能大大地提高编程效率和代码质量
  修改历史   :
  1.日    期   : 2002年5月16日
    作    者   : lushengwen
    修改内容   : 创建文件

  2.日    期   : 2002年6月18日
    作    者   : lushengwen
    修改内容   : 扩充了块功能等

  3.日    期   : 2002年7月2日
    作    者   : lushengwen
    修改内容   : 更正了函数没有输入参数时，头说明就没有输入参数BUG，同时支持
                 了C语言的出入口函数打印功能，以前只支持C++,修改了C++注释改
                 为C注释的函数

  4.日    期   : 2002年7月4日
    作    者   : lushengwen
    修改内容   : 修改了函数头和文件头的功能描述在有些si版本中不能正常显示的
                 问题

  5.日    期   : 2002年7月6日
    作    者   : lushengwen
    修改内容   : 增加了对C＋＋代码的支持

  6.日    期   : 2004年12月27日
    作    者   : lushengwen
    修改内容   : 修改了CPLUSPLUS宏的引用方式,更新了版权说明中错误地方

  7.日    期   : 2006年8月5日
    作    者   : lushengwen
    修改内容   : 增加了自动生成桩函数的功能，能够根据头文件和.c文件自动生成
			     标准的桩函数，修改小括弧空格方式符合规范
			     
  8.日    期   : 2006年8月7日
    作    者   : lushengwen
    修改内容   : 增加函数代码行统计功能，方便了解每个函数的代码函数，用于单
                 元测试参考

  9.日    期   : 2006年8月26日
    作    者   : lushengwen
    修改内容   : 增加代码走读的人名输入

  10.日    期   : 2010年3月2日
    作    者   : lushengwen
    修改内容   : 统一高端的quicker版本

  11.日    期   : 2010年3月3日
    作    者   : lushengwen
    修改内容   : 增加Comware编程规范支持，文件头和函数头与Comware编程规范一致
                 增加函数参数按IN和OUT区分入参和出参功能，代码检视与当前检视表格
                 一致，路径改为相对路径，source insight工程需要建立在代码视图的
                 位置，例如将工程建立在代码视图\l00619_V3R3_CodeView\
    
******************************************************************************/


/*****************************************************************************
	Storware平台 修订记录
	
1、按照storware平台规范修改问题单注释格式；

2、增加单行代码修改时的注释功能
	autoExpand的"ao"/"mo"命令；
	
3、增加选中代码的注释/反注释功能
	宏CommentSelection，需要自行设置热键；

4、撤销键一次删除一个中文字符功能 ；
   需要把SuperBackSpace键绑定到BackSpace键	

5、按照Storware平台日志错误码规范增加日志/错误码信息定义的标准生成
	autoExpand的"item"命令；

6、增加storware平台UT测试函数标准生成模板
	autoExpand的"utf"命令；

7、(2010/10/12 by h05000)增加Storware 外部接口函数头注释
	autoExpand的"ofu"命令;

8、根据"H3C存储软件编程规范V2.0.doc"更新。

9、添加Storware ST相关头文件、接口、用例的标准生成

******************************************************************************/



/*****************************************************************************
 函 数 名  : AutoExpand
 功能描述  : 扩展命令入口函数
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 修改

*****************************************************************************/
macro AutoExpand()
{
    //配置信息
    // get window, sel, and buffer handles
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.lnFirst != sel.lnLast) 
    {
        /*块命令处理*/
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
    /*取得用户名*/
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

    /*自动完成简化命令的匹配显示*/
    wordinfo.szWord = RestoreCommand(hbuf,wordinfo.szWord)
    sel = GetWndSel(hwnd)
    if (wordinfo.szWord == "pn") /*问题单号的处理*/
    {
        DelBufLine(hbuf, ln)
        AddPromblemNo()
        AddPNDescription()
        return
    }
    /*配置命令执行*/
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
    /*修改历史记录更新*/
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
        
        szFuncName = Ask("请输入被测函数名:")
        UtcFuncHead(hbuf, ln, szFuncName)
        return

	} 
    else if (wordinfo.szWord == "stifi")
    {
        DelBufLine(hbuf, ln)

        /* 生成python文件格式头 */
        CreatePythonCommonNewFile()
        return
    } 
    else if (wordinfo.szWord == "stcfi")
    {
        DelBufLine(hbuf, ln)

        /* 生成用例头文件 */
        CreateStNewFile()
        return
    } 
    /* py 功能函数 */
    else if (wordinfo.szWord == "stfu")
    {
        DelBufLine(hbuf, ln)
        szFuncName = Ask("请输入函数名称:")
        CreateStPyFunc (hbuf, ln, szFuncName, szMyName) 
        return
    } 
    /* add by h05000 for storware STC */
    else if (wordinfo.szWord == "stc")
    {
        DelBufLine(hbuf,ln)
                
        szSid = Ask("请输入系统测试例ID,格式如\"st_xxx_001\":")
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
 函 数 名  : ExpandProcEN
 功能描述  : 英文说明的扩展命令处理
 输入参数  : szMyName  用户名
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
  
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    /*英文注释*/
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
        /* 将每行显示字符设置成80 (by h05000) */
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
        //提示输入联合体名称
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

        /*生成不要文件名的新头文件*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "stub")
    {
        DelBufLine(hbuf, ln)
        /*生成C语言的头文件*/
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
 函 数 名  : ExpandProcCN
 功能描述  : 中文说明的扩展命令
 输入参数  : szMyName  
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)

    //中文注释
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("右边空间太小,请用新的行")
            stop 
        }        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        /*注释只能在行尾，避免注释掉有用代码*/
        while(wordinfo.ichLim + kk < lineLen)
        {
            if(szCurLine[wordinfo.ichLim + kk] != " ")
            {
                msg("只能在行尾插入");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("请输入注释的内容")
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
    /* 将quicker自动生成的占位符#消除 (by h05000) */
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
        szVar = ask("请输入循环变量")
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
        nSwitch = ask("请输入case的个数")
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
        szStructName = Ask("请输入结构名:")
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
        //提示输入枚举名并转换为大写
        szStructName = Ask("请输入枚举名:")
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
        //提示输入联合体名称
        szUnionName = Ask("请输入联合名:")
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
        /*生成文件头说明*/
        szVersion = getreg(VERSION)
        if(strlen(szVersion) == 0)
        {
    	    szVersion = Ask("请输入项目编码:")
    	    setreg(VERSION, szVersion)
        }
        InsertFileHeaderCN(hbuf, 0, szMyName, "", 1, szVersion)
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        /*生成C语言的头文件*/
        CreateFunctionDef(hbuf,szMyName,0)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)
        /*生成不要文件名的新头文件*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "stub")
    {
        DelBufLine(hbuf, ln)
        /*生成C语言的头文件*/
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
    		  ||(szCmd == "ifunc" || szCmd == "ifu")  // 增加Storware平台外部接口的函数头
    		)
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            /*对于2.1版的si如果是非法symbol就会中断执行，故该为以后一行
              是否有‘（’来判断是否是新函数*/
            if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                /*是已经存在的函数*/
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0, 0)
                    return
                }
            }
        }
        szFuncName = Ask("请输入函数名称:")
        /*是新函数*/

        if (szCmd == "ifunc" || szCmd == "ifu")
        {
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1, 1)  // 生成对外接口的函数头说明
		}
        else
        {
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1, 0)
        }
    }
    else if (szCmd == "tab") /*将tab扩展为空格*/
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
        InsBufLine(hbuf, ln, "@szLine1@/* 问 题 单: @szQuestion@     修改人:@szMyName@,   时间:@sz@-@sz1@-@sz3@ ");
        szContent = Ask("修改原因")
        szLeft = cat(szLine1,"   修改原因: ");
        if(strlen(szLeft) > 70)
        {
            Msg("右边空间太小,请用新的行")
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
 函 数 名  : BlockCommandProc
 功能描述  : 块命令处理函数
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        InsertWhile()   /*插入while*/
    }
    else if(szLine == "do")
    {
        InsertDo()   //插入do while语句
    }
    else if(szLine == "for")
    {
        InsertFor()  //插入for语句
    }
    else if(szLine == "if")
    {
        InsertIf()   //插入if语句
    }
    else if(szLine == "el" || szLine == "else")
    {
        InsertElse()  //插入else语句
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifd") || (szLine == "#ifdef"))
    {
        InsIfdef()        //插入#ifdef
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifn") || (szLine == "#ifndef"))
    {
        InsIfndef()        //插入#ifdef
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
 函 数 名  : RestoreCommand
 功能描述  : 缩略命令恢复函数
 输入参数  : hbuf   
             szCmd  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : SearchForward
 功能描述  : 向前搜索#
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro SearchForward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Forward
}

/*****************************************************************************
 函 数 名  : SearchBackward
 功能描述  : 向后搜索#
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro SearchBackward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Backward
}

/*****************************************************************************
 函 数 名  : InsertFuncName
 功能描述  : 在当前位置插入但前函数名
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : strstr
 功能描述  : 字符串匹配查询函数
 输入参数  : str1  源串
             str2  待匹配子串
 输出参数  : 无
 返 回 值  : 0xffffffff为没有找到匹配字符串，V2.1不支持-1故采用该值
             其它为匹配字符串的起始位置
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertTraceInfo
 功能描述  : 在函数的入口和出口插入打印,不支持一行有多条语句的情况
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertTraceInCurFunction
 功能描述  : 在函数的入口和出口插入打印,不支持一行有多条语句的情况
 输入参数  : hbuf
             symbol
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        /*剔除其中的注释语句*/
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //查找是否有return语句
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
        //获得左边空白大小
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
        //查找是否有return语句
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
    
    //只要前面的return后有一个}了说明函数的结尾没有返回，需要再加一个出口打印
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
 函 数 名  : GetFirstWord
 功能描述  : 取得字符串的第一个单词
 输入参数  : szLine
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : AutoInsertTraceInfoInBuf
 功能描述  : 自动当前文件的全部函数出入口加入打印，只能支持C++
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
                        
                        //去掉注释的干扰
                        RetVal = SkipCommentFromString(szLine,fIsEnd)
        		        szNew = RetVal.szContent
        		        fIsEnd = RetVal.fIsEnd
                        if(isCodeBegin == 1)
                        {
                            szNew = TrimLeft(szNew)
                            //检测是否是可执行代码开始
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
        		        //查找到函数的开始
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
                    
                    //去掉注释的干扰
                    RetVal = SkipCommentFromString(szLine,fIsEnd)
    		        szNew = RetVal.szContent
    		        fIsEnd = RetVal.fIsEnd
                    if(isCodeBegin == 1)
                    {
                        szNew = TrimLeft(szNew)
                        //检测是否是可执行代码开始
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
    		        //查找到函数的开始
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
 函 数 名  : CheckIsCodeBegin
 功能描述  : 是否为函数的第一条可执行代码
 输入参数  : szLine 左边没有空格和注释的字符串
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : AutoInsertTraceInfoInPrj
 功能描述  : 自动当前工程全部文件的全部函数出入口加入打印，只能支持C++
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //自动保存打开文件，可根据需要打开
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 函 数 名  : RemoveTraceInfo
 功能描述  : 删除该函数的出入口打印
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        /*剔除其中的注释语句*/
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
 函 数 名  : RemoveCurBufTraceInfo
 功能描述  : 从当前的buf中删除添加的出入口打印信息
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : RemovePrjTraceInfo
 功能描述  : 删除工程中的全部加入的函数的出入口打印
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //自动保存打开文件，可根据需要打开
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 函 数 名  : InsertFileHeaderEN
 功能描述  : 插入英文文件头描述
 输入参数  : hbuf       
             ln         行号
             szName     作者名
             szContent  功能描述内容
             cpp        是否添加CPP兼容宏
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    
    //如果没有功能描述内容则提示输入
    szContent = Ask("Description")
    SetBufIns(hbuf,nlnDesc + 22,0)
    DelBufLine(hbuf,nlnDesc +8)
    
    //注释输出处理,自动换行
    CommentContent(hbuf,nlnDesc + 8,"   Description: ",szContent,0,75)
}


/*****************************************************************************
 函 数 名  : InsertFileHeaderCN
 功能描述  : 插入中文描述文件头说明
 输入参数  : hbuf       
             ln         
             szName     
             szContent  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2010年3月4日
    作    者   : 卢胜文
    修改内容   : 修改了不能加入CPP和光标位置不对的问题

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
    InsBufLine(hbuf, ln + 1,  "                版权所有(C)，2007-@sz@，杭州华三通信技术有限公司")
    InsBufLine(hbuf, ln + 2,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 3,  "                            @szFile@")
    InsBufLine(hbuf, ln + 4,  "  产 品 名: @szVersion@")
    InsBufLine(hbuf, ln + 5,  "  模 块 名:")
    InsBufLine(hbuf, ln + 6,  "  生成日期: @sz@年@sz1@月@sz3@日")
    InsBufLine(hbuf, ln + 7,  "  作    者: @szName@")
    nlnDesc = ln
    iLen = strlen (szContent)
    InsBufLine(hbuf, ln + 8,  "  文件描述: @szContent@ ")
    InsBufLine(hbuf, ln + 9,  "")
    InsBufLine(hbuf, ln + 10,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 11,  "   修改历史")
    InsBufLine(hbuf, ln + 12,  "   日期        姓名             描述")
    InsBufLine(hbuf, ln + 13,  "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 14,  "")
    InsBufLine(hbuf, ln + 15,  "*******************************************************************************/")
    if(cpp == 1)
    {
        InsertCPP(hbuf,ln + 16)
    }
  // InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 20, " * 外部变量说明                                 *")
  // InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 22, "")
  //  InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 24, " * 外部函数原型说明                             *")
  //  InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 26, "")
  //  InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 28, " * 内部函数原型说明                             *")
  //  InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 30, "")
  //  InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 32, " * 全局变量                                     *")
  //  InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 34, "")
  //  InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 36, " * 模块级变量                                   *")
  //  InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 38, "")
  //  InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 40, " * 常量定义                                     *")
  //  InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 42, "")
  //  InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
  //  InsBufLine(hbuf, ln + 44, " * 宏定义                                       *")
  //  InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
  //  InsBufLine(hbuf, ln + 46, "")
    if(strlen(szContent) != 0)
    {
        return
    }
    
    //如果没有功能描述内容则提示输入
    szContent = Ask("描述")
    SetBufIns(hbuf,nlnDesc + 21,0)
    DelBufLine(hbuf,nlnDesc + 8)
    
    //注释输出处理,自动换行
    CommentContent(hbuf,nlnDesc + 8,"  文件描述: ",szContent,0,75)
}

/*****************************************************************************
 函 数 名  : GetFunctionList
 功能描述  : 获得函数列表
 输入参数  : hbuf  
             hnewbuf    
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetFunctionList(hbuf,hnewbuf)
{
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    //依次取出全部的但前buf符号表中的全部符号
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
                //取出类型是函数和宏的符号
                symname = symbol.Symbol
                //将符号插入到新buf中这样做是为了兼容V2.1
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
    //依次取出全部的但前buf符号表中的全部符号
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
                //取出类型是函数和宏的符号
                symname = symbol.Symbol

                FuncCodeStatistic(hbuf,hnewbuf,symbol)
               }
           }
        isym = isym + 1
    }
}

/*****************************************************************************
 函 数 名  : InsertFileList
 功能描述  : 函数列表插入
 输入参数  : hbuf  
             ln    
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : CommentContent1
 功能描述  : 自动排列显示文本,因为msg对话框不能处理多行的情况，而且不能超过255
             个字符，作为折中，采用了从简帖板取数据的办法，如果如果的数据是剪
             贴板中内容的前部分的话就认为用户是拷贝的内容，这样做虽然有可能有
             误，但这种概率非常低。与CommentContent不同的是它将剪贴板中的内容
             合并成一段来处理，可以根据需要选择这两种方式
 输入参数  : hbuf       
             ln         行号
             szPreStr   首行需要加入的字符串
             szContent  需要输入的字符串内容
             isEnd      是否需要在末尾加入'*'和'/'
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CommentContent1 (hbuf,ln,szPreStr,szContent,isEnd)
{
    //将剪贴板中的多段文本合并
    szClip = MergeString()
    //去掉多余的空格
    szTmp = TrimString(szContent)
    //如果输入窗口中的内容是剪贴板中的内容说明是剪贴过来的
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
                //如果是中文必须成对处理
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
 函 数 名  : CommentContent
 功能描述  : 自动排列显示文本,因为msg对话框不能处理多行的情况，而且不能超过255
             个字符，作为折中，采用了从简帖板取数据的办法，如果如果的数据是剪
             贴板中内容的前部分的话就认为用户是拷贝的内容，这样做虽然有可能有
             误，但这种概率非常低
 输入参数  : hbuf       
             ln         行号
             szPreStr   首行需要加入的字符串
             szContent  需要输入的字符串内容
             isEnd      是否需要在末尾加入'*'和'/'
             iMax       每行最大长度
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2010年3月3日
    作    者   : 卢胜文
    修改内容   : 增加了长度参数

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

    //判断如果剪贴板是0行时对于有些版本会有问题，要排除掉
    if(lnMax != 0)
    {
        szLine = GetBufLine(hNewBuf , 0)
	    ret = strstr(szLine,szTmp)
	    if(ret == 0)
	    {
	        /*如果输入窗输入的内容是剪贴板的一部分说明是剪贴过来的取剪贴板中的内
	          容*/
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
            //以每行处理字符个数
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
                    //如果是中文字符只能成对处理
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
                        //分段后只有小于3个的字符留在下段则将其以上去
                        j = j + n 
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)                
                    }
                    else
                    {
                        //大于3个字符的加连字符分段
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
 函 数 名  : FormatLine
 功能描述  : 将一行长文本进行自动分行
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro FormatLine()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.ichFirst > 70)
    {
        Msg("选择太靠右了")
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
 函 数 名  : CreateBlankString
 功能描述  : 产生几个空格的字符串
 输入参数  : nBlankCount  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : TrimLeft
 功能描述  : 去掉字符串左边的空格
 输入参数  : szLine  
 输出参数  : 去掉左空格后的字符串
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : TrimRight
 功能描述  : 去掉字符串右边的空格
 输入参数  : szLine  
 输出参数  : 去掉右空格后的字符串
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : TrimString
 功能描述  : 去掉字符串左右空格
 输入参数  : szLine  
 输出参数  : 去掉左右空格后的字符串
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}


/*****************************************************************************
 函 数 名  : GetFunctionDef
 功能描述  : 将分成多行的函数参数头合并成一行
 输入参数  : hbuf    
             symbol  函数符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //去掉被注释掉的内容
        RetVal = SkipCommentFromString(szLine,fIsEnd)
		szLine = RetVal.szContent
		szLine = TrimString(szLine)
		fIsEnd = RetVal.fIsEnd
        //如果是{表示函数参数头结束了
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
 函 数 名  : GetWordFromString
 功能描述  : 从字符串中取得以某种方式分割的字符串组
 输入参数  : hbuf         生成分割后字符串的buf
             szLine       字符串
             nBeg         开始检索位置
             nEnd         结束检索位置
             chBeg        开始的字符标志
             chSeparator  分割字符
             chEnd        结束字符标志
 输出参数  : 最大字符长度
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetWordFromString(hbuf,szLine,nBeg,nEnd,chBeg,chSeparator,chEnd)
{
    if((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }
    nMaxLen = 0
    nIdx = nBeg
    //先定位到开始字符标记处
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chBeg)
        {
            break
        }
        nIdx = nIdx + 1
    }
    nBegWord = nIdx + 1
    
    //用于检测chBeg和chEnd的配对情况
    iCount = 0
    
    nEndWord = 0
    //以分隔符为标记进行搜索
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
 函 数 名  : FuncHeadCommentCN
 功能描述  : 生成中文的函数头注释
 输入参数  : hbuf      
             ln        行号
             szFunc    函数名
             szMyName  作者名
             newFunc   是否新函数
             flag      是否为添加注意事项模板。0-不;1-添加。Storware平台外部接口需要添加 
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2010年03月3日
    作    者   : 卢胜文
    修改内容   : 增加函数参数IN和OUT识别，格式改为Comware规范定义的格式

  3.日    期   : 2010年10月13日
    作    者   : h05000
    修改内容   : 增加外部函数注意事项模板。调整了下参数列表和    

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
            //将文件参数头整理成一行并去掉了注释
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName 
            //取出返回值定义
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
                //对于宏返回值特殊处理
                szRet = ""
            }
            //从函数头分离出函数参数
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
        InsBufLine(hbuf, ln+1, " 函 数 名  : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln+1, " 函 数 名  : ")
    }
    SysTime = GetSysTime(1);
    szTime = SysTime.Date

    InsBufLine(hbuf, ln+2,     " 创建日期  : @szTime@ ")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln+3,  " 作    者  : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln+3,  " 作    者  : ")
    }
    oldln = ln
    
    InsBufLine(hbuf, ln+4,     " 函数描述  :")
    lnIn = ln + 5
    lnOut = ln + 5
    bExistIn = 0;
    bExistOut = 0;
    szIns =                    " 输入参数  : "
    szOuts =                   " 输出参数  : "
    if(newFunc != 1)
    {
        //对于已经存在的函数插入函数参数
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
        InsBufLine(hbuf, ln+4,   " 输入参数  : 无")
    }
    if(bExistOut == 0)
    {       
        ln = ln + 1
        InsBufLine(hbuf, ln+4,   " 输出参数  : 无")
    }
    InsBufLine(hbuf, ln+5,       " 返 回 值  : @szRet@")
    InsBufLine(hbuf, ln+6,       " 注意事项  : ")
    
    caution_list = 0
    if (1 == flag)
    {    
        t_ln = ln+6
    	/* 插入Storware平台外部接口注意事项说明列表.  added by h05000 */
    	InsBufLine(hbuf, t_ln+1, "  1.是处于管理通道还是数据通道，是什么流程: ")
    	InsBufLine(hbuf, t_ln+2, "  2.调用前是否需要申请内存: ")
    	InsBufLine(hbuf, t_ln+3, "  3.是否允许在中断中调用: ")
    	InsBufLine(hbuf, t_ln+4, "  4.接口中是否释放了其他地方申请的内存: ")
    	InsBufLine(hbuf, t_ln+5, "  5.接口中是否有down信号量操作: ")
    	InsBufLine(hbuf, t_ln+6, "  6.是否有禁止中断的操作: ")
    	InsBufLine(hbuf, t_ln+7, "  7.接口的阻塞类型: ")
    	InsBufLine(hbuf, t_ln+8, "  8.是否可重入: ")

        ln = ln + 8
        caution_list = 8
    }
  
    InsbufLIne(hbuf, ln+7, " ");
    InsBufLine(hbuf, ln + 8,   "-------------------------------------------------------------------------------")
    InsBufLine(hbuf, ln + 9,   "    修改历史                                                                  ")
    InsBufLine(hbuf, ln + 10,  "    日期        姓名             描述                                         ")
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
    szContent = Ask("请输入函数功能描述的内容")
    setWndSel(hwnd,sel)
    DelBufLine(hbuf,oldln + 4)

    //显示输入的功能描述内容
    newln = CommentContent(hbuf,oldln+4," 函数描述  : ",szContent,0,75) - 2
    ln = ln + newln - oldln

	// 增加了注意事项列表后基准变化，以"ln+6"为界注意处理可能增加的列表行数

    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
            
        //提示输入新函数的返回值
        szRet = Ask("请输入返回值类型")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+3 - caution_list, " 返 回 值  : @szRet@")            
            PutBufLine(hbuf, ln+12, "@szRet@ @szFunc@( )")
            SetbufIns(hbuf,ln+12,strlen(szRet)+strlen(szFunc) + 2
        }
        szFuncDef = ""
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 2
        sel.ichLim = sel.ichFirst + 1	

        //循环输入参数
        while (1)
        {
            szParam = ask("请输入函数参数名")           
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
    return ln + 17	/* 函数名位置 */ 
}

/*****************************************************************************
 函 数 名  : FuncHeadCommentEN
 功能描述  : 函数头英文说明
 输入参数  : hbuf      
             ln        
             szFunc    
             szMyName  
             newFunc   
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2010年03月3日
    作    者   : 卢胜文
    修改内容   : 增加函数参数IN和OUT识别，格式改为Comware规范定义的格式

  3.日    期   : 2010年03月15日
    作    者   : 卢胜文
    修改内容   : 修改了函数参数位置不对的BUG

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
            //将文件参数头整理成一行并去掉了注释
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName
            
            //取出返回值定义
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
                //对于宏返回值特殊处理
                szRet = ""
            }
            
            //从函数头分离出函数参数
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
        //对于已经存在的函数插入函数参数
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

    //显示输入的功能描述内容
    newln = CommentContent(hbuf,oldln+4," Description  : ",szContent,0,75) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
            
        //提示输入新函数的返回值
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
        //循环输入参数
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
 函 数 名  : InsertHistory
 功能描述  : 插入修改历史记录
 输入参数  : hbuf      
             ln        行号
             language  语种
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertHistory(hbuf,ln,language)
{
   /* iHistoryCount = 1
    isLastLine = ln
    i = 0
    while(ln-i>0)
    {
        szCurLine = GetBufLine(hbuf, ln-i);
        iBeg1 = strstr(szCurLine,"日    期  ")
        iBeg2 = strstr(szCurLine,"Date      ")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            iHistoryCount = iHistoryCount + 1
            i = i + 1
            continue
        }
        iBeg1 = strstr(szCurLine,"修改历史")
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
 函 数 名  : UpdateFunctionList
 功能描述  : 更新函数列表
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        //以文件头说明中前有大于10个空格的为函数列表记录
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

    //插入函数列表
    InsertFileList( hbuf,hnewbuf,ln )
    closebuf(hnewbuf)
 }

/*****************************************************************************
 函 数 名  : InsertHistoryContentCN
 功能描述  : 插入历史修改记录中文说明
 输入参数  : hbuf           
             ln             
             iHostoryCount  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数
  2.日    期   : 2005年11月16日
    作    者   : 于晖
    修改内容   : 按COMWARE开发规范修改。
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
    szContent = Ask("请输入修改的内容")
    CommentContent(hbuf, ln ,"  @szTime@  @szMyName@     ",szContent,0,75)
}


/*****************************************************************************
 函 数 名  : InsertHistoryContentEN
 功能描述  : 插入历史修改记录英文说明
 输入参数  : hbuf           当前buf
             ln             当前行号
             iHostoryCount  修改记录的编号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数
  2.日    期   : 2005年11月16日
    作    者   : 于晖
    修改内容   : 按COMWARE开发规范修改。
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
 函 数 名  : CreateFunctionDef
 功能描述  : 生成C语言头文件
 输入参数  : hbuf      
             szName    
             language  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateFunctionDef(hbuf, szName, language)
{
    ln = 0

    //获得当前没有后缀的文件名
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("请输入头文件名")
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
    //搜索符号表取得函数名
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
        szContent = cat(szContent," 的头文件")
        //插入文件头说明
        InsertFileHeaderCN(hOutbuf, 0, szName, szContent, 0, szVersion)
    }
    else
    {
        szContent = cat(szContent," header file")
        //插入文件头说明
        InsertFileHeaderEN(hOutbuf, 0, szName, szContent, 0, szVersion)        
    }
}

/*****************************************************************************
 函 数 名  : CreateFunctionStub
 功能描述  : 生成C语桩文件
 输入参数  : hbuf      
             szName    
             language  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateFunctionStub(hbuf, szName, language)
{
    ln = 0

    //获得当前没有后缀的文件名
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("请输入头文件名")
        szFileName = GetFileNameNoExt(sz)
    }
    sz = cat(szFileName,"_stub.c")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //搜索符号表取得函数名
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
        szContent = cat(szContent," 的桩文件")
        //插入文件头说明
        InsertFileHeaderCN(hOutbuf,0,szName,szContent, 1)
    }
    else
    {
        szContent = cat(szContent," stub file")
        //插入文件头说明
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
 函 数 名  : GetLeftWord
 功能描述  : 取得左边的单词
 输入参数  : szLine    
             ichRight 开始取词位置
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : CreateClassPrototype
 功能描述  : 生成Class的定义
 输入参数  : hbuf      当前文件
             hOutbuf   输出文件
             ln        输出行号
             symbol    符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    //去掉注释的干扰
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
                    //函数参数头结束
                    isLastLine = 1  
                    //去掉最后多余的字符
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
            //函数参数头还没有结束再取一行
            szLine = GetBufLine (hbuf, sline)
            //去掉注释的干扰
            RetVal = SkipCommentFromString(szLine,fIsEnd)
	        szNew = RetVal.szContent
	        fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}

/*****************************************************************************
 函 数 名  : CreateFuncStub
 功能描述  : 生成C函数的桩函数
 输入参数  : hbuf      当前文件
             hOutbuf   输出文件
             ln        输出行号
             szType    原型类型
             symbol    符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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

    //去掉注释的干扰
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
                    //函数参数头结束
                    isLastLine = 1  
                    //去掉最后多余的字符
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
            //函数参数头还没有结束再取一行
            szLine = GetBufLine (hbuf, sline)
            szLine = cat("         ",szLine)
            //去掉注释的干扰
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
 函 数 名  : CreateFuncPrototype
 功能描述  : 生成C函数原型定义
 输入参数  : hbuf      当前文件
             hOutbuf   输出文件
             ln        输出行号
             szType    原型类型
             symbol    符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateFuncPrototype(hbuf,ln,szType,symbol)
{
    isLastLine = 0
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf,symbol.lnName)
    //去掉注释的干扰
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
                    //函数参数头结束
                    isLastLine = 1  
                    //去掉最后多余的字符
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
            //函数参数头还没有结束再取一行
            szLine = GetBufLine (hbuf, sline)
            szLine = cat("         ",szLine)
            //去掉注释的干扰
            RetVal = SkipCommentFromString(szLine,fIsEnd)
	        szNew = RetVal.szContent
	        fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}

/*****************************************************************************
 函 数 名  : FuncCodeStatistic
 功能描述  : 生成C函数的桩函数
 输入参数  : hbuf      当前文件
             hOutbuf   输出文件
             ln        输出行号
             szType    原型类型
             symbol    符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2007年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //函数还没有结束再取一行
        szLine = GetBufLine (hbuf, sline)

        //去掉注释的干扰
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
 函 数 名  : CreateCodeStatistic
 功能描述  : 生成基于函数的代码统计文件
 输入参数  : hbuf      
             szName    
             language  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2007年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateCodeStatistic( )
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    ln = 0

    //获得当前没有后缀的文件名
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("请输入文件名")
        szFileName = GetFileNameNoExt(sz)
    }
    sz = cat(szFileName,".sta")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //搜索符号表取得函数名
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
 函 数 名  : CreateNewHeaderFile
 功能描述  : 生成一个新的头文件，文件名可输入
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    //获得当前没有后缀的文件名
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
        szContent = cat(szContent," 的头文件")

        //插入文件头说明
        InsertFileHeaderCN(hOutbuf,0,szName,szContent, 0, szVersion)
    }
    else
    {
        szContent = cat(szContent," header file")

        //插入文件头说明
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
    //搜索符号表取得函数名
    //z06321修改下一行
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
        //只提取字符和# { / *作为命令
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
 函 数 名  : ReplaceBufTab
 功能描述  : 替换tab为空格
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ReplaceBufTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    nBlank = Ask("一个Tab替换几个空格")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)
    ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
}

/*****************************************************************************
 函 数 名  : ReplaceTabInProj
 功能描述  : 在整个工程内替换tab为空格
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    nBlank = Ask("一个Tab替换几个空格")
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
 函 数 名  : ReplaceInBuf
 功能描述  : 替换tab为空格,只在2.1中有效
 输入参数  : hbuf             
             chOld            
             chNew            
             nBeg             
             nEnd             
             fMatchCase       
             fRegExp          
             fWholeWordsOnly  
             fConfirm         
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ConfigureSystem
 功能描述  : 配置系统
 输入参数  : 无
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数
  2.日    期   : 2005年11月16日
    作    者   : 于晖
    修改内容   : 按COMWARE开发规范修改。
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
 函 数 名  : GetLeftBlank
 功能描述  : 得到字符串左边的空格字符数
 输入参数  : szLine  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ExpandBraceLittle
 功能描述  : 小括号扩展
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ExpandBraceMid
 功能描述  : 中括号扩展
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ExpandBraceLarge
 功能描述  : 大括号扩展
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //对于没有块选择的情况，直接插入{}即可
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
        //对于有块选择的情况还得考虑将块选择区分开了
        
        //检查选择区内是否大括号配对，如果嫌太慢则注释掉下面的判断
        RetVal= CheckBlockBrace(hbuf)
        if(RetVal.iCount != 0)
        {
            msg("Invalidated brace number")
            stop
        }
        
        //取出选中区前的内容
        szOld = strmid(szLine,0,sel.ichFirst)
        if(sel.lnFirst != sel.lnLast)
        {
            //对于多行的情况
            
            //第一行的选中部分
            szMid = strmid(szLine,sel.ichFirst,strlen(szLine))
            szMid = TrimString(szMid)
            szLast = GetBufLine(hbuf,sel.lnLast)
            if( sel.ichLim > strlen(szLast) )
            {
                //如果选择区长度大于改行的长度，最大取该行的长度
                szLineselichLim = strlen(szLast)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            
            //得到最后一行选择区为的字符
            szRight = strmid(szLast,szLineselichLim,strlen(szLast))
            szRight = TrimString(szRight)
        }
        else
        {
            //对于选择只有一行的情况
             if(sel.ichLim >= strlen(szLine))
             {
                 sel.ichLim = strlen(szLine)
             }
             
             //获得选中区的内容
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
             
             //同样得到选中区后的内容
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
                //对于最后一行应该是选中区内的内容后移四位
                szCurLine = strmid(szCurLine,0,szLineselichLim + 4)
                PutBufLine(hbuf,nIdx+1,szCurLine)                    
            }
            else
            {
                //其它情况是整行的内容后移四位
                PutBufLine(hbuf,nIdx+1,szCurLine)
            }
            nIdx = nIdx + 1
        }
        if(strlen(szRight) != 0)
        {
            //最后插入最后一行没有被选择的内容
            InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@@szRight@")        
        }
        InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@}")        
        nlineCount = nlineCount + 1
        if(nLeft < sel.ichFirst)
        {
            //如果选中区前的内容不是空格，则要保留该部分内容
            PutBufLine(hbuf,ln,szOld)
            InsBufLine(hbuf, ln+1, "@szLeft@{")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }
        else
        {
            //如果选中区前没有内容直接删除该行
            DelBufLine(hbuf,ln)
            InsBufLine(hbuf, ln, "@szLeft@{")
        }
        if(strlen(szMid) > 0)
        {
            //插入第一行选择区的内容
            InsBufLine(hbuf, ln+1, "@szLeft@    @szMid@")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }        
    }
    retVal.szLeft = szLeft
    retVal.nLineCount = nlineCount
    //返回行数和左边的空白
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
 函 数 名  : DelCompoundStatement
 功能描述  : 删除一个复合语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //查找复合语句的开始
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
            //查找对应的大括号
            
            //使用自己编写的代码速度太慢
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
            
            //使用Si的大括号配对方法，但V2.1时在注释嵌套时可能有误
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
 函 数 名  : CheckBlockBrace
 功能描述  : 检测定义块中的大括号配对情况
 输入参数  : hbuf  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : SearchCompoundEnd
 功能描述  : 查找一个复合语句的结束点
 输入参数  : hbuf    
             ln      查询起始行
             ichBeg  查询起始点
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        //如果nCount=0则说明{}是配对的
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
 函 数 名  : CheckBrace
 功能描述  : 检测括号的配对情况
 输入参数  : szLine       输入字符串
             ichBeg       检测起始
             ichEnd       检测结束
             chBeg        开始字符(左括号)
             chEnd        结束字符(右括号)
             nCheckCount  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //如果是/*注释区，跳过该段
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
        //如果是//注释则停止查找
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
 函 数 名  : CheckBrace
 功能描述  : 检测括号的配对情况
 输入参数  : szLine       输入字符串
             ichBeg       检测起始
             ichEnd       检测结束
             chBeg        开始字符(左括号)
             chEnd        结束字符(右括号)
             nCheckCount  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //如果是/*注释区，跳过该段
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

        //如果是"字符区，跳过该段
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

        //如果是"字符区，跳过该段
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
        //如果是//注释则停止查找
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
 函 数 名  : InsertElse
 功能描述  : 插入else语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertCase
 功能描述  : 插入case语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertSwitch
 功能描述  : 插入swich语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    nSwitch = ask("请输入case的个数")
    InsertMultiCaseProc(hbuf,szLeft,nSwitch)
    SearchForward()    
}

/*****************************************************************************
 函 数 名  : InsertMultiCaseProc
 功能描述  : 插入多个case
 输入参数  : hbuf     
             szLeft   
             nSwitch  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
            //先去掉代码中注释的内容
            RetVal = SkipCommentFromString(szLine,fIsEnd)
            szLine = RetVal.szContent
            fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
            //从剪贴板中取得case值
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
        //先去掉代码中注释的内容
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
        //从剪贴板中取得case值
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
 函 数 名  : GetSwitchVar
 功能描述  : 从枚举、宏定义取得case值
 输入参数  : szLine  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : SkipCommentFromString
 功能描述  : 去掉注释的内容，将注释内容清为空格
 输入参数  : szLine        输入行的内容
             isCommentEnd  是否但前行的开始已经是注释结束了
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen )
    {
        //如果当前行开始还是被注释，或遇到了注释开始的变标记，注释内容改为空格?
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
                
                //如果是倒数第二个则最后一个也肯定是在注释内
//                if(nIdx == nLen -2 )
//                {
//                    szLine[nIdx + 1] = " "
//                }
                nIdx = nIdx + 1 
            }    
            
            //如果已经到了行尾终止搜索
            if(nIdx == nLen)
            {
                break
            }
        }
        
        //如果遇到的是//来注释的说明后面都为注释
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
 函 数 名  : InsertDo
 功能描述  : 插入Do语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertWhile
 功能描述  : 插入While语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertFor
 功能描述  : 插入for语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    szVar = ask("请输入循环变量")
    PutBufLine(hbuf,ln, "@szLeft@for (@szVar@ = #; @szVar@#; @szVar@++)")
    SearchForward()
}

/*****************************************************************************
 函 数 名  : InsertIf
 功能描述  : 插入If语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : MergeString
 功能描述  : 将剪贴板中的语句合并成一行
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro MergeString()
{
    hbuf = newbuf("clip")
    if(hbuf == hNil)
        return       
    SetCurrentBuf(hbuf)
    PasteBufLine (hbuf, 0)
    
    //如果剪贴板中没有内容，则返回
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
 函 数 名  : ClearPrombleNo
 功能描述  : 清除问题单号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ClearPrombleNo()
{
   SetReg ("PNO", "")
}

/*****************************************************************************
 函 数 名  : AddPromblemNo
 功能描述  : 添加问题单号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2002年12月26日
    作    者   : 吕磊
    修改内容   : 增加问题单描述

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
 函 数 名  : AddPNDescription
 功能描述  : 添加问题单描述
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 吕磊
    修改内容   : 新生成函数

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
 函 数 名  : ComentCPPtoC
 功能描述  : 转换C++注释为C注释
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月02日
    作    者   : 卢胜文
    修改内容   : 新生成函数,支持块注释

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
        /*如果是空行，跳过该行*/
        if(ich == ilen)
        {         
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }
        
        /*如果该行只有一个字符*/
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
            /*如果不是在注释区内*/
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                
                /* 去掉中间嵌套的注释 */
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
                    /* 如果是连续的注释*/
                    szLine[ich] = " "
                    szLine[ich+1] = " "
                }
                else
                {
                    /*如果不是连续的注释则是新注释的开始*/
                    szLine[ich] = "/"
                    szLine[ich+1] = "*"
                }
                if ( lnCurrent == lnLast )
                {
                    /*如果是最后一行则在行尾添加结束注释符*/
                    szLine = cat(szLine,"  */")
                    isCommentContinue = 0
                }
                /*更新该行*/
                PutBufLine(hbuf,lnCurrent,szLine)
                isCommentContinue = 1
                szOldLine = szLine
                lnCurrent = lnCurrent + 1
                continue 
            }
            else
            {   
                /*如果该行的起始不是//注释*/
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
            //如果是/*注释区，跳过该段
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
                /* 如果是//注释*/
                isCommentContinue = 1
                nIdx = ich
                //去掉期间的/* 和 */注释符以免出现注释嵌套错误
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
 函 数 名  : CommentLine
 功能描述  : 将选中区进行但行注释可用于LLD转CODE
 输入参数  : 无 
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年8月10日
    作    者   : 卢胜文
    修改内容   : 新生成

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
        
        //去掉期间的/* 和 */注释符以免出现注释嵌套错误
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
        //去掉期间的/* 和 */注释符以免出现注释嵌套错误
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
 函 数 名  : LLDToCode
 功能描述  : 用于消息设计转换为代码，要求详细设计缩进以用tab键或4个空格
 输入参数  : 无 
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年8月10日
    作    者   : 卢胜文
    修改内容   : 新生成

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
            
            //去掉期间的/* 和 */注释符以免出现注释嵌套错误
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
 函 数 名  : CodeReview
 功能描述  : 代码检视用采用上研123模板
 输入参数  : 无 
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年8月10日
    作    者   : 卢胜文
    修改内容   : 新生成

  2.日    期   : 2010年3月3日
    作    者   : 卢胜文
    修改内容   : 修改符合最新的检视表单格式，采用相对路径定位文件

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
                        if ( szLevel == "Suggest提示" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "General一般" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major严重" )
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
            if(szLine == "总计")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
/*        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"总计")
        AppendBufLine(hbuf,"严重	一般	提示	总计")
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
    level = ask("1:提示问题 2:一般问题 3:严重问题")
    if(level == 1)
    {
        szLevel = "Suggest提示"
    }
    else if(level == 2)
    {
        szLevel = "General一般"
    }
    else if(level == 3)
    {
        szLevel = "Major严重"
    }
    else
    {
        stop
    }
    szErr = ask("问题描述")
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
    //AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	Code软件编码")    
    AppendBufLine(hNewBuf,"@szMyName@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	编码")    
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
                        if ( szLevel == "提示" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "一般" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "严重" )
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
            if(szLine == "总计")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"总计")
        AppendBufLine(hbuf,"严重	一般	提示	总计")
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
    level = ask("1:提示问题 2:一般问题 3:严重问题")
    if(level == 1)
    {
        szLevel = "提示"
    }
    else if(level == 2)
    {
        szLevel = "一般"
    }
    else if(level == 3)
    {
        szLevel = "严重"
    }
    else
    {
        stop
    }
    szErr = ask("问题描述")
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
    AppendBufLine(hNewBuf,"@szFileName@/@lnTmp@	@szErr@	编码			@szLevel@")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
}

/*****************************************************************************
 函 数 名  : CodeReview
 功能描述  : 代码检视用采用wordpro模板
 输入参数  : 无 
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年8月10日
    作    者   : 卢胜文
    修改内容   : 新生成

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
                        if ( szLevel == "□提示" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "□一般" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "□严重" )
                        {
                            iLevel3 = iLevel3 + 1
                        }
                        else if ( szLevel == "□致命" )
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
            if(szLine == "总计")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 + iLevel4              
                PutBufLIne(hbuf,ln+2,"@iLevel4@	@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3 + iLevel4
        AppendBufLine(hbuf,"总计")
        AppendBufLine(hbuf,"致命	严重	一般	提示	总计")
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
    level = ask("1:提示问题 2:一般问题 3:严重问题 4:致命问题")
    if(level == 1)
    {
        szLevel = "提示"
    }
    else if(level == 2)
    {
        szLevel = "一般"
    }
    else if(level == 3)
    {
        szLevel = "严重"
    }
    else if(level == 4)
    {
        szLevel = "致命"
    }
    else
    {
        stop
    }
    szErr = ask("问题描述")
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
    AppendBufLine(hNewBuf,"@nTotal@	@szFileName@/@lnTmp@	@szErr@	□@szLevel@	编码	@szMyName@")    
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
                        if ( szLevel == "Suggest提示" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "General一般" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major严重" )
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
            if(szLine == "总计")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"总计")
        AppendBufLine(hbuf,"严重	一般	提示	总计")
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
    level = ask("1:提示问题 2:一般问题 3:严重问题")
    if(level == 1)
    {
        szLevel = "Suggest提示"
    }
    else if(level == 2)
    {
        szLevel = "General一般"
    }
    else if(level == 3)
    {
        szLevel = "Major严重"
    }
    else
    {
        stop
    }
    szErr = ask("问题描述")
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
    AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	Code代码")    
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
                        if ( szLevel == "Suggest提示" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "General一般" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major严重" )
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
            if(szLine == "总计")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
/*        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"总计")
        AppendBufLine(hbuf,"严重	一般	提示	总计")
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
    level = ask("1:提示问题 2:一般问题 3:严重问题")
    if(level == 1)
    {
        szLevel = "Suggest提示"
    }
    else if(level == 2)
    {
        szLevel = "General一般"
    }
    else if(level == 3)
    {
        szLevel = "Major严重"
    }
    else
    {
        stop
    }
    szErr = ask("问题描述")
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
    //AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	Code软件编码")    
    AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	Code软件编码")    
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
    szReviewer = ASK("请输入检视者1名字, 输入字符'#'表示删除");
    if(szLanguage == "#")
    {
       SetReg ("REVIEWER1", "")
    }
    else
    {
       SetReg ("REVIEWER1", szReviewer)
    }
    
    szReviewer = ASK("请输入检视者2名字, 输入字符'#'表示删除");
    if(szLanguage == "#")
    {
       SetReg ("REVIEWER2", "")
    }
    else
    {
       SetReg ("REVIEWER2", szReviewer)
    }

    szReviewer = ASK("请输入检视者3名字, 输入字符'#'表示删除");
    if(szLanguage == "#")
    {
       SetReg ("REVIEWER3", "")
    }
    else
    {
       SetReg ("REVIEWER3", szReviewer)
    }

    szReviewer = ASK("请输入检视者4名字, 输入字符'#'表示删除");
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
 函 数 名  : CodeReviewWithName
 功能描述  : 多人检视功能
 输入参数  : 无 
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2008年8月10日
    作    者   : 卢胜文
    修改内容   : 新生成

  2.日    期   : 2010年3月3日
    作    者   : 卢胜文
    修改内容   : 修改为相对路径方式

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
                        if ( szLevel == "Suggest提示" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "General一般" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major严重" )
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
            if(szLine == "总计")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
/*        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"总计")
        AppendBufLine(hbuf,"严重	一般	提示	总计")
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
    level = ask("1:提示问题 2:一般问题 3:严重问题")
    if(level == 1)
    {
        szLevel = "Suggest提示"
    }
    else if(level == 2)
    {
        szLevel = "General一般"
    }
    else if(level == 3)
    {
        szLevel = "Major严重"
    }
    else
    {
        stop
    }
    szErr = ask("问题描述")
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
    str = "问题发现人:"
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
    //AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	Code软件编码")    
    if(flag == 1)
    {
        if (nRevier == 1)
        {
	        AppendBufLine(hNewBuf,"@szReviewer0@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	编码")    
        }
        else if (nRevier == 2)
        {
	        AppendBufLine(hNewBuf,"@szReviewer1@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	编码")    
        }
        else if (nRevier == 3)
        {
	        AppendBufLine(hNewBuf,"@szReviewer2@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	编码")    
        }
        else if (nRevier == 4)
        {
	        AppendBufLine(hNewBuf,"@szReviewer3@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	编码")    
        }
        else
        {
            stop
        }
    }
    else
    {
        AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	编码")        
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
                        if ( szLevel == "Suggest提示" )
                        {
                            iLevel1 = iLevel1 + 1
                        }
                        else if ( szLevel == "General一般" )
                        {
                            iLevel2 = iLevel2 + 1
                        }
                        else if ( szLevel == "Major严重" )
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
            if(szLine == "总计")
            {
                iTotal = iLevel1 + iLevel2 + iLevel3 
                PutBufLIne(hbuf,ln+2,"@iLevel3@	@iLevel2@	@iLevel1@	@iTotal@")
                return
            }
            ln = ln + 1
            iLineCount = iLineCount + 1
        }        
        iTotal = iLevel1 + iLevel2 + iLevel3
        AppendBufLine(hbuf,"总计")
        AppendBufLine(hbuf,"严重	一般	提示	总计")
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
    level = ask("1:提示问题 2:一般问题 3:严重问题")
    if(level == 1)
    {
        szLevel = "Suggest提示"
    }
    else if(level == 2)
    {
        szLevel = "General一般"
    }
    else if(level == 3)
    {
        szLevel = "Major严重"
    }
    else
    {
        stop
    }
    szErr = ask("问题描述")
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
    AppendBufLine(hNewBuf,"@nTotal@	@szErr@	@szFileName@/@lnTmp@	Defect缺陷	@szLevel@	Code代码")    
    SetSourceLink(hNewBuf,nTotal-1,GetBufName (hbuf),lnCurrent)
    SaveBuf(hNewBuf)
}


/*****************************************************************************
 函 数 名  : CmtCvtLine
 功能描述  : 将//转换成/*注释
 输入参数  : lnCurrent  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 
    作    者   : 
    修改内容   : 

  2.日    期   : 2002年7月02日
    作    者   : 卢胜文
    修改内容   : 修改了注释嵌套所产生的问题?

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
        //如果是/*注释区，跳过该段
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
 函 数 名  : GetFileNameExt
 功能描述  : 得到文件扩展名
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetFileNameNoExt
 功能描述  : 得到函数名没有扩展名
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetRelFileName
 功能描述  : 得到相对路径的文件名
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetFileName
 功能描述  : 得到文件名
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsIfdef
 功能描述  : 插入#ifdef语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsIfdef()
{
    sz = Ask("Enter #ifdef condition:")
    if (sz != "")
        IfdefStr(sz);
}

/*****************************************************************************
 函 数 名  : InsIfndef
 功能描述  : ＃ifndef语句对插入的入口调用宏
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsIfndef()
{
    sz = Ask("Enter #ifndef condition:")
    if (sz != "")
        IfndefStr(sz);
}

/*****************************************************************************
 函 数 名  : InsertCPP
 功能描述  : 在buf中插入C类型定义
 输入参数  : hbuf  
             ln    
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ReviseCommentProc
 功能描述  : 问题单修改命令处理
 输入参数  : hbuf      
             ln        
             szCmd     
             szMyName  
             szLine1   
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        InsBufLine(hbuf, ln, "@szLine1@/* 问 题 单: @szQuestion@     修改人:@szMyName@,   时间:@sz@-@sz1@-@sz3@ ");
        szContent = Ask("修改原因")
        szLeft = cat(szLine1,"   修改原因: ");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@-@sz1@-@sz3@   问题单号:@szQuestion@*/");
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
            InsBufLine(hbuf, ln, "@szLine1@/* END: Added by @szMyName@, @sz@-@sz1@-@sz3@   问题单号:@szQuestion@ */");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@-@sz1@-@sz3@   问题单号:@szQuestion@*/");
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
            InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@-@sz1@-@sz3@   问题单号:@szQuestion@ */");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@-@sz1@-@sz3@   问题单号:@szQuestion@*/");
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
            InsBufLine(hbuf, ln, "@szLine1@/* END: Modified by @szMyName@, @sz@-@sz1@-@sz3@   问题单号:@szQuestion@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END: Modified by @szMyName@, @sz@-@sz1@-@sz3@ */");
        }
        return
    }
}

/*****************************************************************************
 函 数 名  : InsertReviseAdd
 功能描述  : 插入添加修改注释对
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2002年12月26日
    作    者   : 吕磊
    修改内容   : 增加问题单描述

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
 函 数 名  : InsertReviseDel
 功能描述  : 插入删除修改注释对
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2002年12月26日
    作    者   : 吕磊
    修改内容   : 增加问题单描述

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
 函 数 名  : InsertReviseMod
 功能描述  : 插入修改注释对
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

  2.日    期   : 2002年12月26日
    作    者   : 吕磊
    修改内容   : 增加问题单描述

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
 函 数 名  : IfndefStr
 功能描述  : 插入＃ifndef语句对
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertPredefIf
 功能描述  : 插入＃if语句对的入口调用宏
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertPredefIf()
{
    sz = Ask("Enter #if condition:")
    PredefIfStr(sz)
}

/*****************************************************************************
 函 数 名  : PredefIfStr
 功能描述  : 在选择行前后插入＃if语句对
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : HeadIfdefStr
 功能描述  : 在选择行前后插入#ifdef语句对
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetSysTime
 功能描述  : 取得系统时间，只在V2.1时有用
 输入参数  : a  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetSysTime(a)
{
    //从sidate取得时间
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
        SysTime.Date="2002年05月20日"
    }
    else
    {
        SysTime.Month=getreg(Month)
        SysTime.Day=getreg(Day)
        SysTime.Date=getreg(Date)
   /*         SysTime.Date=cat(SysTime.Year,"年")
        SysTime.Date=cat(SysTime.Date,SysTime.Month)
        SysTime.Date=cat(SysTime.Date,"月")
        SysTime.Date=cat(SysTime.Date,SysTime.Day)
        SysTime.Date=cat(SysTime.Date,"日")*/
    }
    return SysTime
}

/*****************************************************************************
 函 数 名  : HeaderFileCreate
 功能描述  : 生成头文件
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : FunctionHeaderCreate
 功能描述  : 生成函数头
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        szFuncName = Ask("请输入函数名称:")
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1, 0)
    }
    else
    {
        szFuncName = Ask("Please input function name")
           FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    
    }
}

/*****************************************************************************
 函 数 名  : GetVersion
 功能描述  : 得到Si的版本号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetVersion()
{
   Record = GetProgramInfo ()
   return Record.versionMajor
}

/*****************************************************************************
 函 数 名  : GetProgramInfo
 功能描述  : 获得程序信息，V2.1才用
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetProgramInfo ()
{   
    Record = ""
    Record.versionMajor     = 2
    Record.versionMinor    = 1
    return Record
}

/*****************************************************************************
 函 数 名  : FileHeaderCreate
 功能描述  : 生成文件头
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    iTotalParams = ask("请输入所需的参数个数")
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
 函 数 名  : InsertulRet
 功能描述  : 插入ulRet
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTestStart
 功能描述  : 插入TestStart
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月21日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTestEnd
 功能描述  : 插入TestEnd
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月21日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTestStartAndEnd
 功能描述  : 插入TestStartAndEnd
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月21日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertulFabricHead
 功能描述  : 插入FabricHead
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月20日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTest0
 功能描述  : 插入ulRet
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTest1
 功能描述  : 插入ulRet
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTest2
 功能描述  : 插入ulRet
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTest3
 功能描述  : 插入ulRet
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTest4
 功能描述  : 插入ulRet
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertTest5
 功能描述  : 插入ulRet
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdDisplay
 功能描述  : 插入Display命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdSet
 功能描述  : 插入Set命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdDriver
 功能描述  : 插入Driver命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdFabric
 功能描述  : 插入Fabric命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdFe
 功能描述  : 插入Fe命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdFap
 功能描述  : 插入Fap命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdSerDesParam
 功能描述  : 插入SerDesParam命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdSlot
 功能描述  : 插入slot命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdSlotId
 功能描述  : 插入SlotId命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdChip
 功能描述  : 插入chip命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdChipNum
 功能描述  : 插入chipnum命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdLink
 功能描述  : 插入link命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdLinkNum
 功能描述  : 插入linknum命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCmdInteger
 功能描述  : 插入Integer命令
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年3月15日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertCheckSfcDevNumInt
 功能描述  : 插入内部函数，网板全局设备号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcDevNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，网板全局设备号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_DEVNUM_INT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckSfcSlotIdInt
 功能描述  : 插入内部函数，网板槽位号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcSlotIdInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，网板槽位号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_SLOTID_INT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckSfcChipNumInt
 功能描述  : 插入内部函数，网板芯片号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcChipNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，网板芯片号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_CHIPNUM_INT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckSfcLinkNumInt
 功能描述  : 插入内部函数，网板链路号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcLinkNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，网板链路号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_LINKNUM_INT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcDevNumInt
 功能描述  : 插入内部函数，线卡板全局设备号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcDevNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，线卡板全局设备号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_DEVNUM_INT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcSlotIdInt
 功能描述  : 插入内部函数，线卡板槽位号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcSlotIdInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，线卡板槽位号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_SLOTID_INT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcChipNumInt
 功能描述  : 插入内部函数，线卡板芯片号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcChipNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，线卡板芯片号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_CHIPNUM_INT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcLinkNumInt
 功能描述  : 插入内部函数，线卡板链路号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcLinkNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，线卡板链路号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_LINKNUM_INT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcPortNumInt
 功能描述  : 插入内部函数，线卡板端口号合法性断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月19日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcPortNumInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，线卡板端口号合法性断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_PORTNUM_INT(ucPortNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckSfcDevNumExt
 功能描述  : 插入外部函数，检查网板全局设备号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcDevNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查网板全局设备号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_DEVNUM_EXT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckSfcSlotIdExt
 功能描述  : 插入外部函数，检查网板槽位号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcSlotIdExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查网板槽位号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_SLOTID_EXT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckSfcChipNumExt
 功能描述  : 插入外部函数，检查网板芯片号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcChipNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查网板芯片号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_CHIPNUM_EXT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckSfcLinkNumExt
 功能描述  : 插入外部函数，检查网板链路号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckSfcLinkNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查网板链路号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_SFC_LINKNUM_EXT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcDevNumExt
 功能描述  : 插入外部函数，检查网板全局设备号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcDevNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查线卡板全局设备号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_DEVNUM_EXT(ucDevNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcSlotIdExt
 功能描述  : 插入外部函数，检查线卡板槽位号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcSlotIdExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查线卡板槽位号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_SLOTID_EXT(usSlotId);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcChipNumExt
 功能描述  : 插入外部函数，检查线卡板芯片号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcChipNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查线卡板芯片号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_CHIPNUM_EXT(ucChipNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcLinkNumExt
 功能描述  : 插入外部函数，检查线卡板链路号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcLinkNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查线卡板链路号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_LINKNUM_EXT(ucLinkNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckLcPortNumExt
 功能描述  : 插入外部函数，检查线卡端口路号是否合法
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckLcPortNumExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查线卡板端口号是否合法 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_LC_PORTNUM_EXT(ucPortNum);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheckPointerInt
 功能描述  : 插入内部函数，入参指针非空断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckPointerInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，入参指针非空断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_POINTER_INT(pPointer);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheck2PointerInt
 功能描述  : 插入内部函数，两个入参指针非空断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月14日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheck2PointerInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，两个入参指针非空断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_TWO_POINTER_INT(pPointer1, pPointer2);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheck3PointerInt
 功能描述  : 插入内部函数，入参指针非空断言
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月14日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheck3PointerInt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 内部函数，三个入参指针非空断言 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_THREE_POINTER_INT(pPointer1, pPointer2, pPointer3);")
    InsBufLine(hbuf, ln+3, " ")
}


/*****************************************************************************
 函 数 名  : InsertCheckPointerExt
 功能描述  : 插入外部函数，检查入参指针是否为空
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月12日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheckPointerExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查入参指针是否为空 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_POINTER_EXT(pPointer);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheck2PointerExt
 功能描述  : 插入外部函数，检查两个入参指针是否为空
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月14日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheck2PointerExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查两个入参指针是否为空 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_TWO_POINTER_EXT(pPointer1, pPointer2);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertCheck3PointerExt
 功能描述  : 插入外部函数，检查三个入参指针是否为空
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年4月14日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertCheck3PointerExt()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 外部函数，检查三个入参指针是否为空 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_CHECK_THREE_POINTER_EXT(pPointer1, pPointer2, pPointer3);")
    InsBufLine(hbuf, ln+3, " ")
}

/*****************************************************************************
 函 数 名  : InsertDbgLog
 功能描述  : 插入调试日志
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年7月25日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertDbgLog()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   " ")
    InsBufLine(hbuf, ln+1, "    /* 调试日志 */")
    InsBufLine(hbuf, ln+2, "    DRV_FABRIC_DebugDiagLog(DRV_FABRIC_FILE_ID, __LINE__,")
    InsBufLine(hbuf, ln+3, "                            DRV_FABRIC_DIAGLOG_INFO_ID(IC_LEVEL_ERR),")
    InsBufLine(hbuf, ln+4, "                            \"\\r\\nDevNum=%u, AddrNum1=%X, AddrNum2=%x, enSrcType=%u, ulEndOffset = 0x%x\",")
    InsBufLine(hbuf, ln+5, "                            ucDevNum, ulAddrNum, ulAddrNum2, enSrcType, ulEndOffset);")
    InsBufLine(hbuf, ln+6, " ")
}

/*****************************************************************************
 函 数 名  : InsertErrLog
 功能描述  : 插入错误日志
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年7月25日
    作    者   : 赵明飞
    修改内容   : 新生成函数

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
 函 数 名  : InsertFapInitErrLog
 功能描述  : 插入FAP初始化处理日志
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2009年1月19日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertFapInitErrLog()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   "    /* 交换网模块FAP初始化部分错误返回处理 */")
    InsBufLine(hbuf, ln+1, "    DRV_FAP_INIT_RET_PROC(ulRet, ulSandRet, ucChipNum);")
    InsBufLine(hbuf, ln+2, " ")
}

/*****************************************************************************
 函 数 名  : InsertTestLog
 功能描述  : 插入错误日志
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2008年11月21日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertTestLog()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    InsBufLine(hbuf, ln,   "    /* 测试代码  HSDTESTCODE */")
    InsBufLine(hbuf, ln+1, "    if (DRV_SYSM_OPEN_DEBUG == g_ulDrvFabricTestPrintFlg)")
    InsBufLine(hbuf, ln+2, "    {")
    InsBufLine(hbuf, ln+3, "    }")
    InsBufLine(hbuf, ln+4, "")
}

/*****************************************************************************
 函 数 名  : InsertRpc
 功能描述  : 插入错误日志
 输出参数  : 无
 返 回 值  :
 调用函数  :
 被调函数  :

 修改历史      :
  1.日    期   : 2009年2月25日
    作    者   : 赵明飞
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertRpc()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst

    InsBufLine(hbuf, ln,   "    /* BEGIN: Modified by z06321, 2009/2/25   PN:HSDGETNODEID */")
    InsBufLine(hbuf, ln+1, "    /* 交换网模块RPC调用处理 */")
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
 函 数 名  : unCommentStr
 功能描述  : 转换C++注释为C注释
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2008年5月15日
    作    者   : l04615
    修改内容   : 新生成函数,去掉字符串中的注释字符

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
 函 数 名  : CommentSelection
 功能描述  : 将选中的行块注释或反注释
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2008年5月15日
    作    者   : l04615
    修改内容   : 新生成函数

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
 * 代替SourceInsight原有的Backspace功能（希望如此）
 * 增加了对双字节汉字的支持，在删除汉字的时候也能同时删除汉字的高字节而缓解半个汉字问题
 * 能够对光标在汉字中间的情况进行自动修正
 *
 * 安装：
 * ① 复制入SourceInsight安装目录；
 * ② Project→Open Project，打开Base项目；
 * ③ 将复制过去的SuperBackspace.em添加入Base项目；
 * ④ 重启SourceInsight；
 * ⑤ Options→Key Assignments，将Marco: SuperBackspace绑定到BackSpace键；
 * ⑥ Enjoy！！
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
 函 数 名  : FuncStorwareItem
 功能描述  : 生成Storware日志/错误码id描述信息
 输入参数  : hbuf      
             ln        	行号
             left
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 修改历史      :
  1.日    期   : 2010年9月20日
    作    者   : h05000
    修改内容   : 新生成函数
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
    *  对话框循序: id宏定义、英文描述、中文描述、
                   id实际值、触发描述、参考操作
    */


    /* 记录从宏定义开始增加的行数 */	
    add_count_1 = 0	
    
    tmp_ln = ln_def + add_count_1
    /* 添加日志/错误码宏定义 */
    szRet = Ask("日志/错误码宏定义:")
    seRet = trimleft(seRet)
    if(strlen(szRet) > 0)
    {	    	    	
        DelBufLine(hbuf, tmp_ln)	
        InsBufLine(hbuf, tmp_ln, "@szLeft@ITEM_INFO(@szRet@,")
    }
    
    /* 添加英文描述信息 */
    tmp_ln = ln_en + add_count_1
    szContent = Ask("英文描述信息:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    szContent = cat(szContent, "\",")
    newln = CommentContent(hbuf, tmp_ln, "@szLeft2@\"", szContent, 0, 80)   
    add_count_1 = add_count_1 + newln - tmp_ln   

    /* 添加中文描述信息 */
    tmp_ln = ln_cn + add_count_1
    szContent = Ask("中文描述信息:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    szContent = cat(szContent, "\"),")
    newln = CommentContent(hbuf, tmp_ln, "@szLeft2@\"", szContent, 0, 80)   
    add_count_1 = add_count_1 + newln - tmp_ln  


    /* 记录从实际值开始增加的行数 */
    add_count_2 = 0

    /* 添加id */
    tmp_ln = ln_id + add_count_2
    szRet = Ask("日志ID或错误码的实际值:")
    seRet = TrimLeft(seRet)
    if(strlen(szRet) > 0)
    {	
        DelBufLine(hbuf, tmp_ln)	
        InsBufLine(hbuf, tmp_ln, "@szLeft@*ID:@szRet@")
    }
    
    /* 添加触发描述 */
    tmp_ln = ln_trigger + add_count_2
    szContent = Ask("对出现该错误或打印该日志时所进行的操作及相关条件进行说明:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    newln = CommentContent(hbuf, tmp_ln, "@szLeft@*Trigger Action:", szContent, 0, 80)   
    add_count_2 = add_count_2 + newln - tmp_ln    

    /* 添加参考操作 */
    tmp_ln = ln_Recommend + add_count_2
    szContent = Ask("出现该情况后，推荐的处理方法:")
    seContent = trimleft(seContent)
    DelBufLine(hbuf, tmp_ln)
    newln = CommentContent(hbuf, tmp_ln, "@szLeft@*Recommended Action:", szContent, 0, 80)   
    add_count_2 = add_count_2 + newln - tmp_ln   


    return tln + add_count_1 + add_count_2
	
}

/* Storware UTC 测试用例ID中编号字段位置
 * 测试用例ID格式为: UT_被测函数名_001	
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
 函 数 名  : UtcFuncHead
 功能描述  : UtcFuncHead函数生成
 输入参数  : hbuf      
             ln        	行号
             szUid     	被测函数
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 修改历史      :
  1.日    期   : 2010年9月20日
    作    者   : h05000
    修改内容   : 新生成函数
*****************************************************************************/
macro UtcFuncHead(hbuf, ln, szFuncName)
{
    tln = ln
    szDefId = "001"
	
    InsBufLine(hbuf, tln, "/******************************************************************************")
    tln = tln + 1
    ln_id = tln
    InsBufLine(hbuf, tln, " 用 例 ID  ：UT_@szFuncName@_@szDefId@")
    tln = tln + 1 
    ln_item = tln
    InsBufLine(hbuf, tln, " 测 试 项  ：")  
    tln = tln + 1 
    ln_title = tln
    InsBufLine(hbuf, tln, " 用例标题  ：")	
    tln = tln + 1 
    ln_level = tln
    InsBufLine(hbuf, tln, " 重要级别  ：")
    tln = tln + 1 
    ln_cond = tln
    InsBufLine(hbuf, tln, " 预置条件  ：")  
    tln = tln + 1 
    ln_input = tln
    InsBufLine(hbuf, tln, " 输    入  ：")	
    tln = tln + 1 
    ln_result = tln
    InsBufLine(hbuf, tln, " 预期结果  ：")
    tln = tln + 1 
    InsBufLine(hbuf, tln, "******************************************************************************/")
    tln = tln + 1 
    ln_func = tln
    InsBufLine(hbuf,tln,  "TEST(UT_@szFuncName@, @szDefId@)")
	
    /* 将测试用例格式定成"UT_被测函数名_001" 时的处理
    // 根据测试用例拆分编号
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
    InsBufLine(hbuf,tln, "    /* 定义函数调用参数 */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* 定义被测函数返回值 */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* 预置条件 */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /*");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "     * 构造被测函数入参、出参");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "     */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* 对被测函数打桩 */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* 调用被测函数 */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* 预期结果 */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");        
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    /* 清除测试环境 */");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "");        
    tln = tln + 1 
    InsBufLine(hbuf,tln, "    UT_END;");
    tln = tln + 1 
    InsBufLine(hbuf,tln, "}");

    /* 添加id */
    szRet = Ask("被测函数的用例编号,如\"001\":")
    seRet = TrimLeft(seRet)
    if(strlen(szRet) > 0)
    {	
        DelBufLine(hbuf, ln_id)	
        InsBufLine(hbuf, ln_id, " 用 例 ID  ：UT_@szFuncName@_@szRet@")
    }
    DelBufLine(hbuf, ln_func)	
    InsBufLine(hbuf, ln_func,  "TEST(UT_@szFuncName@, @szRet@)")
  
    /* 对话框插入后增加的行数 */  
    addlncount = 0

    /* 测试项描述 */
    ttln = ln_item + addlncount
    szContent = Ask("测试项描述:")
    DelBufLine(hbuf, ttln)
    newln = CommentContent(hbuf, ttln, " 测 试 项  ：", szContent, 0, 80)   
    addlncount = addlncount + newln - ttln  

    /* 测试用例标题 */
    ttln = ln_title + addlncount
    szContent = Ask("用例标题:")
    DelBufLine(hbuf, ttln)
    newln = CommentContent(hbuf, ttln, " 用例标题  ：", szContent, 0, 80)   
    addlncount = addlncount + newln - ttln  
	
    /* 测试例重要级别 */
    ttln = ln_level + addlncount
    szContent = Ask("重要级别:")
    DelBufLine(hbuf, ttln)
    newln = CommentContent(hbuf, ttln, " 重要级别  ：", szContent, 0, 80)   
    addlncount = addlncount + newln - ttln  

    staff = "            "	// 插入行对齐字符
    /* 设置预置条件 */
    count = 0 				// 预置条件个数
    t_add = 0				// 插入行数
    ttln = ln_cond + addlncount		// "预置条件"字符串位置
    tmp_ln = ttln
    while (1)	// 循环设置预置条件
    {
        szParam = ask("设置预置条件,以空格结束")
        szParam = TrimLeft(szParam)
        if (szParam == "")
        {
            break;
        }
        count = count + 1
        szTmp = cat(staff, count) 
        szTmp = cat(szTmp, ". ") 
        tmp_ln = ttln + t_add + 1 			// 在下一行插入
        newln = CommentContent(hbuf, tmp_ln, szTmp, szParam, 0, 80)       	
        t_add = t_add + (newln - tmp_ln) + 1	// 循环中增加的行数
	
    }
    addlncount = addlncount + t_add

    /* 设置输入 */
    ttln = ln_input + addlncount
    count = 0 
    t_add = 0				// 插入行数
    tmp_ln = ttln
    while (1)	// 循环设置输入
    {
        szParam = ask("设置输入,以空格结束")
        szParam = TrimLeft(szParam)
        if (szParam == "")
        {
            break;
        }
        count = count + 1	
        szTmp = cat(staff, count) 
        szTmp = cat(szTmp, ". ") 
        tmp_ln = ttln + t_add + 1 // 在下一行插入 	
        newln = CommentContent(hbuf, tmp_ln, szTmp, szParam, 0, 80)       	
        t_add = t_add + (newln - tmp_ln) + 1	// 循环中总增加的行数	
    }	
    addlncount = addlncount + t_add

    /* 设置预期结果 */
    ttln = ln_result + addlncount    	
    count = 0
    t_add = 0				// 插入行数
    tmp_ln = ttln
    while (1)	// 循环设置输入
    {
        szParam = ask("设置预期结果,以空格结束")
        szParam = TrimLeft(szParam)
        if (szParam == "")
        {
            break;
        }
        count = count + 1
        szTmp = cat(staff, count) 
        szTmp = cat(szTmp, ". ") 
        tmp_ln = ttln + t_add + 1 	// 插入新行位置
        newln = CommentContent(hbuf, tmp_ln, szTmp, szParam, 0, 80)       	
        t_add = t_add + (newln - tmp_ln) + 1	// 循环中总增加的行数
	
    }
    addlncount = addlncount + t_add

    /* 最后的行号 */
    return tln + addlncount
}



/*****************************************************************************
 函 数 名  : CreatePythonCommonNewFile
 功能描述  : 生成一个新的python文件，文件名可输入。
 输入参数  : 无
 输出参数  : 无
 返 回 值  : szFileName 生成的文件名
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2010年10月19日
    作    者   : h05000
    修改内容   : 新生成函数

*****************************************************************************/
macro CreatePythonCommonNewFile()
{
    hbuf = GetCurrentBuf()

    szFileName = ask("请输入文件名:")

    hOutbuf = NewBuf(szFileName) // create output buffer
    if (hOutbuf == 0)
        stop

    SetCurrentBuf(hOutbuf)

    /* 从新文件的第一行开始写 */ 
    ln = 0	

    InsBufLine(hOutbuf, ln,     "#!/usr/bin/python")
    InsBufLine(hOutbuf, ln + 1, "# -*- coding: cp936 -*-")
    InsBufLine(hOutbuf, ln + 2, "'''Filename: @szFileName@'''")  
    InsBufLine(hOutbuf, ln + 3, " ")  


    /* 在文件尾部添加结束描述 */    
    iTotalLn = GetBufLineCount (hOutbuf)            
    InsBufLine(hOutbuf, iTotalLn, "")
    InsBufLine(hOutbuf, iTotalLn, "# End of @szFileName@")            
    InsBufLine(hOutbuf, iTotalLn, "")            
    InsBufLine(hOutbuf, iTotalLn, "")            
    InsBufLine(hOutbuf, iTotalLn, "")            
    InsBufLine(hOutbuf, iTotalLn, "")


    /* 光标定位 */
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
 函 数 名  : CreateStNewFile
 功能描述  : 生成一个新的测试例文件，文件名可输入。
 输入参数  : hbuf      
             ln        	行号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2010年10月19日
    作    者   : h05000
    修改内容   : 新生成函数

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


    /* 光标定位到 两行之后 */
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
 函 数 名  : CreateStNewFile
 功能描述  : 生成一个新的测试用例文件，文件名可输入。
 输入参数  : 无
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2010年10月20日
    作    者   : h05000
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateStNewFile()
{
    /* 生成python头 */
    szFileName = CreatePythonCommonNewFile()

    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst;
        
    hbuf = GetWndBuf(hwnd)
	/* 插入用例文件标准文件头 */
    InsertStcInitRecord(hbuf, ln, szFileName)

}


/*****************************************************************************
 函 数 名  : CreateStPyFunc
 功能描述  : 生成ST相关的python功能函数
 输入参数  : hbuf      
             ln        	行号
             szFunc		函数名称
             szMyName 	用户名 			 
 输出参数  : 无
 返 回 值  : 
 
 修改历史      :
  1.日    期   : 2010年10月20日
    作    者   : h05000
    修改内容   : 新生成函数

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
    InsBufLine(hbuf, tln,   "    函数名称       ：@szFunc@")
    tln = tln + 1
    ln_func = tln /* 记录位置 */
    InsBufLine(hbuf, tln,   "    功能描述       ：")  
    tln = tln + 1
    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, tln,"    作    者       ：@szMyName@")
    }
    else
    {
       InsBufLine(hbuf, tln,"    作    者       :")
    }	
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    创建日期       ：@szTime@")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    访问的全局变量 ：")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    修改的全局变量 ：")  
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    输    入       ：")	  
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    输    出       ：")	
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    返 回 值       ：")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    其    它       ：")
    tln = tln + 1
    InsBufLine(hbuf, tln,   "    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''")


    add_count = 0 	// 增加的行数
	
    /* 功能描述 */
    szContent = Ask("请输入函数功能描述")
    DelBufLine(hbuf, ln_func)
    newln = CommentContent(hbuf, ln_func, "    功能描述       ：", szContent, 0, 80)   
    add_count = newln - ln_func  

    /* 最后一行行号 */
    return tln + add_count	
}

/*****************************************************************************
 函 数 名  : StFuncHead
 功能描述  : Storware STC函数生成
 输入参数  : hbuf      
             ln        	行号
             szUid     	测试用例id。格式为:st_被测函数名_001
 输出参数  : 无
 返 回 值  : 插入最后一行的位置
 调用函数  : 
 被调函数  : 
 修改历史      :
  1.日    期   : 2010年9月20日
    作    者   : h05000
    修改内容   : 新生成函数
*****************************************************************************/
macro StcFuncHead(hbuf, ln, szSid)
{
    tln = ln
    
    /* 大写格式的用例 */
    szName = toupper(szSid)

    InsBufLine(hbuf, tln, "# ST_TEST_CASE_BEGIN @szName@")
    tln = tln + 1
    InsBufLine(hbuf, tln, "")
    tln = tln + 1
    InsBufLine(hbuf, tln, "def @szName@():")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    用 例 ID  ：@szName@")
    tln = tln + 1
    ln_item = tln
    InsBufLine(hbuf, tln, "    测 试 项  ：")  
    tln = tln + 1
    ln_title = tln
    InsBufLine(hbuf, tln, "    用例标题  ：")	
    tln = tln + 1
    ln_level = tln
    InsBufLine(hbuf, tln, "    重要级别  ：")
    tln = tln + 1
    ln_state = tln
    InsBufLine(hbuf, tln, "    用例状态  ：")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    预置条件  ：")  
    tln = tln + 1
    InsBufLine(hbuf, tln, "    输    入  ：")	
    tln = tln + 1
    InsBufLine(hbuf, tln, "    操作步骤  ：")
    tln = tln + 1
    InsBufLine(hbuf, tln, "    预期结果  ：")
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
    t_add_count = 0 	// 对话框增加的行数

    /* 测试项描述 */
    tln = ln_item
    szContent = Ask("测试项描述:")
    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    测 试 项  ：", szContent, 0, 80)   
    t_add_count = newln - tln  

    /* 测试用例标题 */
    tln = ln_title + t_add_count
    szContent = Ask("用例标题:")
    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    用例标题  ：", szContent, 0, 80)   
    t_add_count = t_add_count + newln - tln  
	
    /* 测试例重要级别 */
    tln = ln_level + t_add_count
    szContent = Ask("重要级别:")
    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    重要级别  ：", szContent, 0, 80)   
    t_add_count = t_add_count + newln - tln  

    /* 测试例用例状态 */
    tln = ln_state + t_add_count
    szContent = Ask("用例状态: A(AUTO) or M(MANUAL) or B(BLOCK)")
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
        /* 输入不对设置为空 */
    	szContent = " "
    }

    DelBufLine(hbuf, tln)
    newln = CommentContent(hbuf, tln, "    用例状态  ：", szContent, 0, 80)   
    t_add_count = t_add_count + newln - tln  

    /* 返回最后一行位置 */
    return lstln + t_add_count

}



/*****************************************************************************
 函 数 名  : CreateStPyFunc
 功能描述  : 生成ST相关的python调试功能代码
 输入参数  : 无		 
 输出参数  : 
 返 回 值  : 最后一行
 
 修改历史      :
  1.日    期   : 2010年10月19日
    作    者   : h05000
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateStPyDebug()
{

    hbuf = GetCurrentBuf()
    hwnd = GetCurrentWnd()
    ln = GetWndSelLnFirst(hwnd)

    /* 获取没有扩展名的当前文件名称 */
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




