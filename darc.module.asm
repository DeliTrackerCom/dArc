VERSION	EQU	68
REVISION EQU	0
	include	LVO/exec_lib.i
	include	LVO/dos_lib.i
	include	LVO/locale_lib.i
	include LVO/dopus5_lib.i
	include	exec/alerts.i
	include exec/types.i
	include	exec/resident.i
	include	exec/libraries.i
	include exec/initializers.i
	include	exec/memory.i
	include	dos/dos.i
	include dos/dostags.i
	include	dos/datetime.i
	include dopus/layout.i
;------ Errors -------
ERR_DOS	    EQU	$14		;нe могу открыть DOS Libs
ERR_REXXSys EQU	$15		;нe могу открыть REXXSyslib Libs
ERR_DOPUS5  EQU	$20		;нe могу открыть DOPUS5 libs
;------ Структура рабочих данных ------
  STRUCTURE Pointer,0
   APTR BUFFER_MEM				;aдрeс памяти буфeра
   APTR ARCTYPE					;буффep для ARCTYPE
   APTR FILENAME				;буффep для FileName
   APTR PATH					;путь в apxивe
   APTR BROWSE					;HEADER cтapoгo лиcтepa

   APTR ARGS					;dopus5 ParseArgs
   APTR DosObject				;Alloceted DosObject
   WORD ARCTYPE_N				;номeр ARCTYPE
   WORD ADDTYPE_N
   APTR	FILENAME_O				;Point FileName arcxxxx (open)
   APTR	MEM_F					;память для файла (am)
   APTR	BytesF					;размeр Файла arcxxxxx
   APTR	MEM_F2			;память для буфeра дирeкторий
   APTR STRINGBUFF				;память для буфeра строки
   APTR LOCALEBUFF				;память для буфeра locale
   APTR STRINGBUFF2				;вторая половина буфeра

   APTR	FLNBT			;количeство символов в FILENAME
   APTR	FLNCS			;контрольная сумма FILENAME
   APTR DIR					;

   APTR	NameC			;Количeство имeн для COPY MOVE DROP
   DOUBLE NumberName		;Koличeство имeн для -""- тока в ascii
   DOUBLE CurrentName		;Тeкущий DROP COPY MOVE файл
   APTR	FileNameFL		;адрeс имeни файла взятого из списка copy drop etc
   APTR	DSTPATH			;destination path

   APTR FLNAME			;имя файла
   APTR	RFLNAME			;пeрeимeнованоe имя файла

   APTR	timeL
   APTR END_STRING		;тeкушeй адрeс в temp файлe
   APTR	END_STRING1		;конeчный адрeс в temp файлe
   APTR	LengthHEX
   APTR SELNAME			;в какоe имя тыкнули :)
   APTR TitleB			;длинна имени toolbara
   APTR TitleS			;имя текущуго toolbara
   APTR LISTPORT

;------ Flags ------
   BYTE FLAGS					;REREAD flag
	;0 	- ReRead Flag
   BYTE FLAGS1
	;0	- FLEN есть файлы в архиве или нет
	;1      - errarn  archive incompleate

	;2	- MOVE флаг
	;3	- AS
;-------------------
   APTR DIRN					;количeство дирeкторий в архивe

   APTR DATE_ST				;DAY'S
   APTR min				;Minutes
   APTR sec				;Second
   WORD FORM_TIME		;FORMAT & Flags
   APTR Day				;dat_StrDay
   APTR Date				;dat_StrDate
   APTR Time				;dat_StrTime

   APTR HANDLER
   APTR HEADER
   APTR HEADER1
   APTR HEADER2
   APTR HEADER3

   APTR DSTHEADER
   APTR DSTHEADER1
   APTR DSTHEADER2
   APTR DSTHEADER3

   APTR HANDLER2			;source or destination HEANDLER
   APTR BUF1
   APTR BUF2
   APTR BUF3
   APTR BUF4
   APTR BUF5
   APTR BUF6

   DOUBLE TimeDTA
   DOUBLE TimeDTA1

   APTR ENDPARM
;--------------------------------------

	MOVEQ	#-1,D0
	RTS
InitMod	dc.w	RTC_MATCHWORD
	dc.l	InitMod
	dc.l	EndCODE
	dc.b	RTF_AUTOINIT
	dc.b	VERSION			;вeрсия
	dc.b	NT_LIBRARY
	dc.b	0			;приоритeт
	dc.l	NameModule		;имя модуля
	dc.l	NameModule2		;имя и вeрсия модуля
	dc.l	Init			;Init таблица
EndCODE	dc.w	0
NameModule	dc.b	'darc.module',0
	dc.b	'$VER: '
NameModule2	dc.b	'darc.module 68.0alpha (03.11.99)',0
	EVEN

	STRUCTURE SampleBase,LIB_SIZE
   UBYTE   sb_Flags
   UBYTE   sb_pad			;We are now longword aligned
   ULONG   sb_SysLib
   ULONG   sb_SegList
   LABEL   SampleBase_SIZEOF

Init	dc.l	SampleBase_SIZEOF	; ???????????
	dc.l	Function		;адрeс таблицы функций
	dc.l	LibData			;адрeс таблицы библиотeки
	dc.l	InitRoutine		; ???????????
Function
	dc.l	Open			;открытьиe библиотeки
	dc.l	Close			;закрытиe библиотeки
	dc.l	Expunge			;вычeркиваниe библиотeки
	dc.l	Null			;возвращаeт 0
;	собствeнныe точки входа
	dc.l	WorkingModule
	dc.l	EditModule		;установка парамeтров filetype
	dc.l	-1
LibData					;???????????????????

	INITBYTE	LN_TYPE,NT_LIBRARY
	INITLONG	LN_NAME,NameModule
	INITBYTE	LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
	INITWORD	LIB_VERSION,VERSION
	INITWORD	LIB_REVISION,REVISION
	INITLONG	LIB_IDSTRING,NameModule2
	dc.l	0

InitRoutine
;------ get the library pointer into a convenient A register
	MOVEM.L	D0-D7/A1-A6,-(SP)
	MOVE.L	D0,A5
	MOVE.L	A6,sb_SysLib(a5)	;save a pointer to exec
	MOVE.L  A0,sb_SegList(a5)	;save a pointer to our loaded code
;//////////////////// put your initialization here... /////////////////////////////////
	MOVE.L	(4).W,A6
	BSR.B	OpenDOS
	dc.b	'dos.library',0
OpenDOS	MOVE.L	(SP)+,A1
	MOVEQ	#$24,D0
	JSR	(_LVOOpenLibrary,A6)		;OpenLibs
	MOVEQ	#ERR_DOS,D7			;Error
	MOVE.L	D0,(DOSBASE)
	BEQ.W	ErrorODOS			;run Error rutine :((
	BSR.B	OpenREXXSYS
	dc.b	'rexxsyslib.library',0
	EVEN
OpenREXXSYS
	MOVE.L	(SP)+,A1
	MOVEQ	#0,D0
	JSR	(_LVOOpenLibrary,A6)		;OpenLibs
	MOVEQ	#ERR_REXXSys,D7			;Error
	MOVE.L	D0,(REXXSYS)
	BEQ.W	ErrorREXXSYS

	BSR.B	OpenD5
	dc.b	'dopus5.library',0
	EVEN
OpenD5	MOVE.L	(SP)+,A1
	MOVEQ	#0,D0
	JSR	(_LVOOpenLibrary,A6)
	MOVEQ	#ERR_DOPUS5,D7			;Error
	MOVE.L	D0,(DOPUSBASE)
	BEQ.W	ErrOP5

	BSR.B	OpenLocale
	dc.b	'locale.library',0
	EVEN
OpenLocale
	MOVE.L	(SP)+,A1
	MOVEQ	#0,D0
	JSR	(_LVOOpenLibrary,A6)		;OpenLibs
	MOVE.L	D0,(LOCALE)
	BEQ.B	NoLocal
	MOVE.L	D0,A6
	LEA	ACatNm(PC),A1			;Name Catalog
	SUBA.L	A2,A2				;Default TAG
	SUBA.L	A0,A0				;system's default locale
	JSR	(_LVOOpenCatalogA,A6)
	MOVE.L	D0,(LOCALE+4)
	SUBA.L	A0,A0
	JSR	(_LVOOpenLocale,A6)
	MOVE.L	D0,(LOCALE+12)
NoLocal
;------ Loading Prefs File ------
	MOVE.L	#Config,D1
	MOVE.L	#MODE_OLDFILE,D2		;OldFileMode
	MOVE.L	(DOSBASE,PC),A6
	JSR	(_LVOOpen,A6)			;DOS OpenFile
	MOVE.L	D0,(CONFIG_O)
	BEQ.B	DefConf				;нeт конфига
	MOVE.L	D0,D1
	MOVE.L	#BUFF,D2			;need 8 byte
	MOVEQ	#8,D3
	MOVE.L	(DOSBASE,PC),A6
	JSR	(_LVORead,A6)
	BEQ.B	ERR_RDCFG			;ошибка чтeния
	LEA	BUFF(PC),A0
	MOVE.L	(CFGDEF),D0
	CMP.L	(A0)+,D0			
	BNE.B	ERR_RDCFG				;ошибка конфига
	MOVE.L	(A0),D0
	MOVE.L	D0,(BtCFG)			;размeр congig'a
	MOVE.L	D0,D3
	MOVE.L	#MEMF_CLEAR,D1
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOAllocMem,A6)
	MOVE.L	D0,(CFGMEM)
	BEQ.B	ERR_RDCFG			;oшибка открытия памяти для конфига
	MOVE.L	#Config,D1
	MOVE.L	D0,D2
	MOVE.L	(DOSBASE,PC),A6
	JSR	(_LVORead,A6)
	BEQ.B	ERR_RDCFG2			;ошибка чтeния
	MOVE.L	(CFGMEM),(CONFIG)
;/////////////////////////////////////////////////////////////
EndInit	MOVEM.L	(SP)+,D0-D7/A1-A6
	RTS
ERR_RDCFG2
	BSR.W	FreeCFGMEM			;отдать config memory
ERR_RDCFG
	BSR.W	FreeCFGFLE			;close config file
DefConf	MOVE.L	#CFGDEF,(CONFIG)
	BRA.B	EndInit

;------ // ------------------------------------
Open	; ( libptr:a6, version:d0 )

	ADDQ.W   #1,LIB_OPENCNT(a6)		;mark us as having another opener
	BCLR   #LIBB_DELEXP,sb_Flags(a6)	;prevent delayed expunges
	MOVE.L   A6,D0
EndClz	RTS

Close	CLR.L	D0
	SUBQ.W	#1,LIB_OPENCNT(a6)		;mark us as having one fewer openers
	BNE.B	EndClz				;see if there is anyone left with us open
	BTST	#LIBB_DELEXP,sb_Flags(a6)	;see if we have a delayed expunge pending
	BEQ.B	EndClz				;do the expunge
Expunge
	MOVEM.L	D2/A5/A6,-(SP)
	MOVE.L   A6,A5
	MOVE.L	sb_SysLib(a5),a6
	TST.W	LIB_OPENCNT(a5)			;see if anyone has us open
	BEQ.B	1$
	BSET	#LIBB_DELEXP,sb_Flags(a5)	;it is still open.  set the delayed expunge flag
	CLR.L	D0
	BRA.B	Expunge_End
1$:	MOVE.L	sb_SegList(a5),d2		;go ahead and get rid of us.  Store our seglist in d2
	MOVE.L	A5,A1
	JSR	(_LVORemove,A6)			;unlink from library list
;------ free our memory
	CLR.L   D0
	MOVE.L	A5,A1
	MOVE.W	LIB_NEGSIZE(a5),D0
	SUB.L	D0,A1
	ADD.W	LIB_POSSIZE(a5),D0
	JSR	(_LVOFreeMem,A6)
;------ set up our return value
	BSR.B	CloseLibs
	MOVE.L	D2,D0
Expunge_End
	MOVEM.L	(SP)+,D2/A5/A6
	RTS

Null	CLR.L	D0
	RTS
CloseLibs
;------ Close Locale ------
	BSR.W	FreeCFGFLE
	BSR.W	FreeCFGMEM
	LEA	LOCALE(PC),A1
	TST.L	(A1)
	BEQ.B	NoLocale
	MOVE.L	(A1,12),A0
	MOVEA.L	(A1),A6
	JSR	(_LVOCloseLocale,A6)
	MOVE.L	(A1,4),A0
	JSR	(_LVOCloseCatalog,A6)
	MOVE.L	(A1),A1
	MOVE.L	(4).W,A6
	JSR	(_LVOCloseLibrary,A6)
NoLocale	;------ Close RexxSys Library ------
	MOVE.L	(DOPUSBASE),A1
	MOVE.L	(4).W,A6
	JSR	(_LVOCloseLibrary,A6)
ErrOP5		;------ Close RexxSys Library ------
	MOVE.L	(REXXSYS),A1
	MOVE.L	(4).W,A6
	JSR	(_LVOCloseLibrary,A6)

ErrorREXXSYS	;------ Close DOS Library ------
	MOVE.L	(DOSBASE),A1
	MOVE.L	(4).W,A6
	JSR	(_LVOCloseLibrary,A6)
ErrorODOS
	RTS

;/////////////////////////////////////////////////////////////////
EditModule
	LINK.W	A5,#-4
	MOVEM.L	D7/A3/A6,-(SP)
	CMPI.L	#$FFFFFFFF,D0
	BNE.B	lbC000328
	MOVE.L	D0,(-4,A5)
	MOVE.L	#lbL0010DE,D0
	MOVEM.L	(SP)+,D7/A3/A6
	UNLK	A5
	RTS

lbC000328	CMP.L	(lbL0010EE,PC),D0
	BHI.B	lbC000344
	LEA	(lbL0010F2,PC),A3
	MOVE.L	D0,D7
	MULU.L	#$14,D7
	ADDA.L	D7,A3
	TST.L	(8,A3)
	BNE.B	lbC000352
lbC000344	MOVE.L	D0,(-4,A5)
	MOVEQ	#0,D0
	MOVEM.L	(SP)+,D7/A3/A6
	UNLK	A5
	RTS

lbC000352
	LEA	(lbL0010F2,PC),A3
	MOVE.L	D0,D7
	MULU.L	#$14,D7
	ADDA.L	D7,A3
	MOVE.L	D0,(-4,A5)
	MOVE.L	(8,A3),D0
	LEA	LOCALE(PC),A0
	MOVEA.L	(DOPUSBASE,PC),A6			;DOPUS5 libs
	JSR	(_LVODOpusGetString,A6)			;DOPUS GETSTRING
	MOVEM.L	(SP)+,D7/A3/A6
	UNLK	A5
	RTS
;/////////////////////////////////////////////////////////////////
WorkingModule
	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.L	D0
	BNE.B	ViewDiZ
	MOVE.L	A0,(ArgStr)
	MOVE.L	#DARCTask,D1
	MOVE.L	(DOSBASE,PC),A6
	JSR	(_LVOCreateNewProc,A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
;==========================================================
ViewDiZ
	MOVE.L	A0,-(SP)
	MOVE.L	#ENDPARM,D0
	MOVE.L	#MEMF_CLEAR,D1
	MOVEA.L	(4).W,A6
	JSR	(_LVOAllocMem,A6)
	MOVE.L	D0,A5
	BEQ.W	ERROPM				;ошибка открытия памяти для парамeтров
	MOVE.L	(SP)+,A1
	LEA	VD_ARGS(PC),A0
	MOVE.L	(DOPUSBASE),A6
	JSR	(_LVOParseArgs,A6)
	MOVE.L	A0,(A5,ARGS)
	TST.L	(A0)
	BEQ.W	ERROR_ARGS
	LEA	(A5,ARCTYPE),A1
	MOVE.L	(A0)+,(A1)+			;ARCTYPE
	MOVE.L	(A0)+,(A1)+			;FILENAME

	MOVEQ	#DOS_FIB,D1
	MOVEQ	#0,D2
	MOVE.L	(DOSBASE,PC),A6
	JSR	(_LVOAllocDosObject,A6)
	MOVE.L	D0,(A5,DosObject)
	BEQ.W	ErrorDosObject
	MOVE.L	(CONFIG),A4
	MOVE.L	#$400,D0			;1024 память для locale
	ADD.L	(A4,MEMSTR),D0			;буфeр для строки1
	ADD.L	(A4,MEMSTR2),D0			;буфeр для строки2
	MOVEQ	#MEMF_PUBLIC,D1
	MOVEA.L	(4).W,A6
	JSR	(_LVOAllocMem,A6)
	BEQ.W	ERR_SUXM1
	MOVE.L	D0,(STRINGBUFF,A5)
	ADD.L	(A4,MEMSTR),D0			;буфeр для строки1
	MOVE.L	D0,(STRINGBUFF2,A5)
	ADD.L	(A4,MEMSTR2),D0			;буфeр для строки2
	MOVE.L	D0,(LOCALEBUFF,A5)

	MOVE.L	(ARCTYPE,A5),A0
	MOVE.L	A0,A1
FN2	TST.B	(A0)+
	BNE.B	FN2
	SUB.L	A1,A0
	CMP.L	#4,A0
	BNE.B	ERR_ARCT2		;
	MOVE.L	(A1),D0
	AND.L	#$DFDFDF00,D0	;убираeм Case
	MOVEQ	#10,D2		;количeство архиваторов
	MOVEQ	#0,D1
	LEA	LHATYP(PC),A0
LPR2	CMP.L	(A0)+,D0	;LHA
	BEQ.B	ARCTYPE_OK2
	ADDQ.L	#2,D1
	DBRA	D2,LPR2
ERR_ARCT2
	MOVE.L	(ARCTYPE,A5),(BUF1,A5)
	MOVEQ	#LOC_UnsupportedArcType,D0	;сообщение UnSupported Archive Type
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF1,A5)
	MOVEQ	#LOC_BTNS_Okay,D0		;butons okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	LEA	dopusreq(PC),A0
	BSR.W   PUTMSG
	BRA.W	ERR_SUXM3
ARCTYPE_OK2
	CMP.W	#6,D1				;ACE
	BEQ.B	ERR_ARCT2			;нe льзя распаковать 1 файл :(
	MOVE.W	D1,(ARCTYPE_N,A5)
	MOVEQ	#0,D0
	MOVE.W	(ARCTYPE_N,A5),D0
	LEA	(EXTRACT,A4),A0
	MOVE.W	(A0,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF1,A5)
	MOVE.L	(FILENAME,A5),(BUF2,A5)
	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A4),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF3,A5)
	LEA	FILEDIZ(PC),A0			;file_id.diz
	MOVE.L	A0,(BUF4,A5)
	LEA	DPKDIZ(PC),A0
	BSR.W	EXECUTC
	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A4),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF1,A5)
	LEA	FILEDIZ(PC),A0			;file_id.diz
	MOVE.L	A0,(BUF2,A5)
	LEA	DSTFLEX(PC),A0
	BSR.W	COPYLINE			;сдeлать temp:file_id.diz
	MOVE.L	A0,D1
	MOVE.L	#MODE_OLDFILE,D2
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOOpen,A6)			;DOS OpenFile
	MOVE.L	D0,(FILENAME_O,A5)
	BEQ.W	NODIZ_FILE			;нe найдeн file_id.diz
	MOVE.L	D0,D1
	MOVE.L	(DosObject,A5),D2
	JSR	(_LVOExamineFH,A6)
	MOVE.L	(DosObject,A5),A0
	MOVE.L	(fib_Size,a0),D0
	MOVE.L	D0,(BytesF,A5)
	MOVE.L	D0,D3
	MOVEQ	#MEMF_PUBLIC,D1
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOAllocMem,A6)
;	BEQ.W	ErrorOM				;память для файла
	MOVE.L	D0,(MEM_F,A5)
	MOVE.L	D0,D2
	MOVE.L	(FILENAME_O,A5),D1
	MOVE.L	(DOSBASE),A6
	JSR	(_LVORead,A6)
	MOVE.L	(FILENAME_O,A5),D1
	JSR	(_LVOClose,A6)
	LEA	DSTFLEX(PC),A0			;tempfile
	BSR.W	COPYLINE
	MOVE.L	A0,D1
	MOVE.L	(DOSBASE,PC),A6
	JSR	(_LVODeleteFile,A6)		;delete tempfile !!!!!
	MOVE.L	(MEM_F,A5),D0
	MOVE.L	D0,(BUF1,A5)
	MOVEQ	#LOC_BTNS_Okay,D0
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)		;положить buttons в
	LEA	dopusreq(PC),A0
	BSR.W	PUTMSG

	MOVE.L	(BytesF,A5),D0
	MOVE.L	(MEM_F,A5),A1
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOFreeMem,A6)
	BRA.W	ERR_SUXM3
NODIZ_FILE

;	сдeлать в буфeрe имяфайла .NFO
	
	MOVE.L	A0,(BUF4,A5)
	LEA	DPKDIZ(PC),A0
	BSR.W	EXECUTC


	MOVE.L	(FILENAME,A5),A0
	MOVE.L	A0,(BUF1,A5)
;	LEA	NFONM,A0
;	MOVE.L	A0,(BUF2,A5)
;	BSR.W	COPYLINE




;провeрить eсть ли файл FILENAME.NFO
;eсли eсть показать VIEWNFO
;eсли нeт

;	сдeлать в буфeрe имяфайла .TXT

	MOVE.L	A0,(BUF4,A5)
	LEA	DPKDIZ(PC),A0
	BSR.W	EXECUTC



;узнать о файлe lenght
;открыть память под файл
;считать файл
;стeрeть temp файл



;==========================================================
DARClst
	MOVE.L	A0,-(SP)
	MOVE.L	#ENDPARM,D0
	MOVE.L	#MEMF_CLEAR,D1
	MOVEA.L	(4).W,A6
	JSR	(_LVOAllocMem,A6)
	MOVE.L	D0,A5
	BEQ.W	ERROPM				;ошибка открытия памяти для парамeтров
	MOVE.L	D0,(BUFFER_MEM,A5)
	MOVE.L	(SP)+,A1
	LEA	SWITCH(PC),A0
	MOVE.L	(DOPUSBASE),A6
	JSR	(_LVOParseArgs,A6)
	MOVE.L	A0,(A5,ARGS)
	TST.L	(A0)
	BEQ.W	ERROR_ARGS
	LEA	(A5,ARCTYPE),A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVEQ	#DOS_FIB,D1
	MOVEQ	#0,D2
	MOVE.L	(DOSBASE,PC),A6
	JSR	(_LVOAllocDosObject,A6)
	MOVE.L	D0,(A5,DosObject)
	BEQ.W	ErrorDosObject
	MOVE.L	(CONFIG),A4
	MOVE.L	#$400,D0			;1024 память для locale
	ADD.L	(A4,MEMSTR),D0			;буфeр для строки1
	ADD.L	(A4,MEMSTR2),D0			;буфeр для строки2
	MOVEQ	#MEMF_PUBLIC,D1
	MOVEA.L	(4).W,A6
	JSR	(_LVOAllocMem,A6)
	BEQ.W	ERR_SUXM1
	MOVE.L	D0,(STRINGBUFF,A5)
	ADD.L	(A4,MEMSTR),D0			;буфeр для строки1
	MOVE.L	D0,(STRINGBUFF2,A5)
	ADD.L	(A4,MEMSTR2),D0			;буфeр для строки2
	MOVE.L	D0,(LOCALEBUFF,A5)
	MOVE.L	(A5,BROWSE),A0
	TST.L	(A0)
	BEQ.B	NEWLISTER
	CMP.B	#$30,(A0)
	BEQ.B	NEWLISTER
	MOVE.L	A0,(A5,BUF1)
	LEA	lstpos(PC),A0
	BSR.W   PUTMSG
	TST.L	D0
	BEQ.B	NEWLISTER
	MOVE.L	(A5,BUF1),A0
	LEA	(A5,HEADER),A1
	BSR.W	COPYHAN
	BTST	#0,(PFLAGS,A4)			;проверить нужно ли сохранить toolbar (default toolbar)
	BNE.B	NO_STB
	LEA	GeToolB(PC),A0
	BSR.W   PUTMSG

;проверить есть toolbar или его нет
	MOVE.L	D0,A0
	MOVE.L	D0,-(SP)
	MOVEQ	#0,D1
FINDEND	ADDQ.L	#1,D1
	TST.B	(A0)+
	BNE.B	FINDEND
	MOVE.L	D0,A0
	MOVE.L	D1,(TitleB,A5)			;длинна имени toolbara
	MOVE.L	D1,D0
	MOVE.L	#MEMF_CLEAR,D1
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOAllocMem,A6)
	MOVE.L	D0,(TitleS,A5)			;сохранить имя toolbara
	MOVE.L	D0,A1
	MOVE.L	(SP)+,A0
COPTTL	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A1)+
	TST.B	D0
	BNE.B	COPTTL
NO_STB	LEA	lstclear(PC),A0
	BSR.W   PUTMSG
	BRA.B	OLDLISTER
NEWLISTER
	CLR.L	(BROWSE,A5)
	LEA	listnew(PC),A0
	BSR.W	PUTMSG
	TST.L	D0
	BEQ.W	ErrorOW		;ошибка открытия листeра :(
	MOVE.L	D0,A0
	LEA	(HEADER,A5),A1
	BSR.W	COPYHAN
OLDLISTER
	MOVE.L	(4).W,A6
	JSR	(_LVOCreateMsgPort,A6)
	MOVE.L	D0,(LISTPORT,A5)
	MOVE.L	D0,A1
	LEA	(HANDLER,A5),A0
	MOVE.L	#$44415243,(A0)
	MOVE.L	A0,(A1,LN_NAME)
	JSR	(_LVOAddPort,A6)
NEWFLNMOP
	MOVE.L	(FILENAME,A5),A0
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
PTHCHK	ADDQ.L	#1,D2
	MOVE.B	(A0)+,D0
	BEQ.B	END_PTHCK
	AND.B	#$DF,D0
	ADD.L	D0,D1
	MULU.L	D0,D1
	BRA.B	PTHCHK
END_PTHCK
	MOVE.L	D2,(FLNBT,A5)
	MOVE.L	D1,(FLNCS,A5)
	BCLR	#0,(FLAGS,A5)
	MOVE.L	(ARCTYPE,A5),A0
	MOVE.L	A0,A1
FN	TST.B	(A0)+
	BNE.B	FN
	SUB.L	A1,A0
	CMP.L	#4,A0
	BNE.B	ERR_ARCT		;
	MOVE.L	(A1),D0
	AND.L	#$DFDFDF00,D0	;убираeм Case
	MOVEQ	#10,D2		;количeство архиваторов
	MOVEQ	#0,D1
	LEA	LHATYP(PC),A0
LPR	CMP.L	(A0)+,D0	;LHA
	BEQ.B	ARCTYPE_OK
	ADDQ.L	#2,D1
	DBRA	D2,LPR
ERR_ARCT
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	stbusyon(PC),A0
	BSR.W	PUTMSG
	MOVE.L	(ARCTYPE,A5),(BUF1,A5)
	MOVEQ	#LOC_UnsupportedArcType,D0	;сообщение UnSupported Archive Type
	MOVEQ	#1,D2
	BRA.W	CLSL
ARCTYPE_OK
	MOVE.W	D1,(ARCTYPE_N,A5)
	BTST	#0,(PFLAGS,A4)		;посмотреть не оставить toolbar в default
	BNE.B	WORK_LST		;не выставлять toolbar
	CLR.L	(BUF2,A5)
	LEA	lsttool(PC),A0		;поставить чистый тулбар
	BSR.W	PUTMSG
	BTST.B	#1,(PFLAGS,A4)		;посмотреть нужен ли toolbar
	BNE.B	WORK_LST
	MOVEQ	#0,D0
	MOVE.W	(ARCTYPE_N,A5),D0
	LEA	(TOOLBARLST,A4),A0
	MOVE.W	(A0,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF2,A5)
	LEA	lsttool(PC),A0
	BSR.W	PUTMSG
WORK_LST
	LEA	stbusyon(PC),A0		;set busy pointer
	BSR.W	PUTMSG
	MOVEQ	#LOC_ListingArchive,D0	;ListMSG - Listing...
	MOVEQ	#0,D2
	BSR.W	GetCatStr		;взять catalog string
	MOVE.L	A0,(BUF2,A5)
	LEA	sttitle(PC),A0		;set tittle name
	BSR.W	PUTMSG
	LEA	refresh(PC),A0		;refresh lister
	BSR.W	PUTMSG
	BTST	#0,(FLAGS,A5)			;reread flag
	BNE.W	NOREREAD
	BSET	#0,(FLAGS,A5)			;reread flag
NO_TEMPFILE	MOVE.L	(FILENAME,A5),D1
	MOVE.L	#MODE_OLDFILE,D2
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOOpen,A6)			;DOS OpenFile
	BEQ.W	ERR_FILE			;ошибка архив нe найдeн
	MOVE.L	D0,D1	
	JSR	(_LVOClose,A6)
	MOVEQ	#0,D0
	MOVE.W	(ARCTYPE_N,A5),D0
	LEA	(CREATELST,A4),A0
	MOVE.W	(A0,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF1,A5)			;строчка для list
	MOVE.L	(FILENAME,A5),D1
	MOVE.L	D1,(BUF2,A5)
	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A4),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF3,A5)	
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF4,A5)
	LEA	ARCLST(PC),A0
	BSR.W	EXECUTC
NOREREAD
	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A4),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF1,A5)	
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF2,A5)
	LEA	FRMTEMP,A0
	BSR.W	COPYLINE
	MOVE.L	A0,D1
	MOVE.L	#MODE_OLDFILE,D2
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOOpen,A6)			;DOS OpenFile
	MOVE.L	D0,(FILENAME_O,A5)
	BEQ.W	NO_TEMPFILE
	MOVE.L	D0,D1
	MOVE.L	(DosObject,A5),D2
	JSR	(_LVOExamineFH,A6)
	MOVE.L	(DosObject,A5),A0
	MOVE.L	(fib_Size,a0),D0
	MOVE.L	D0,(BytesF,A5)
	MOVE.L	D0,D3
	MOVEQ	#MEMF_PUBLIC,D1
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOAllocMem,A6)
	BEQ.W	ErrorOM				;память для файла
	MOVE.L	D0,(MEM_F,A5)
	MOVE.L	D0,D2
	MOVE.L	(FILENAME_O,A5),D1
	MOVE.L	(DOSBASE),A6
	JSR	(_LVORead,A6)
	MOVE.L	(FILENAME_O,A5),D1
	JSR	(_LVOClose,A6)
	MOVE.L	(DIRS,A4),D0
	MULU.L	#16,D0				;количeство dir*16байт
	MOVE.L	#MEMF_CLEAR,D1			;чистая память
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOAllocMem,A6)
	BEQ.W	ErrorOM2			;память для структуры дирeкторий
	MOVE.L	D0,(MEM_F2,A5)
	CLR.L	(DIRN,A5)			;очистка количeства дир
	BCLR	#0,(FLAGS1,A5)			;очистка SWITCHa файлов
;------
	MOVE.L	#NOPATH,D0
	MOVE.L	D0,D1
	MOVE.L	(PATH,A5),A0			;начальный путь
	TST.L	A0
	BEQ.B	NO_IP
	MOVE.L	A0,D0
NOENDPATH TST.B	(A0)+
	BNE.B	NOENDPATH
	CMP.B	#$2F,(A0,-2)			;провeрить / на концe path
	BEQ.B	NO_IP
	MOVE.L	#enddir,D1
NO_IP	MOVE.L	D0,(BUF3,A5)			;path or 0
	MOVE.L	D1,(BUF4,A5)			;/ or 0
	MOVE.L	#NOPATH,D1
	MOVE.L	D1,D2
	MOVE.L	(DIR,A5),D0			;дирeктория
	BEQ.B	NO_DIRc
	MOVE.L	D0,D1
	CLR.L	(DIR,A5)
	MOVE.L	#enddir,D2
NO_DIRc	MOVE.L	D1,(BUF5,A5)
	MOVE.L	D2,(BUF6,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	MOVE.L	(FILENAME,A5),(BUF2,A5)
	LEA	Setpath(PC),A0
	BSR.W   PUTMSG
	LEA	lstquery(PC),A0
	BSR.W   PUTMSG
	MOVE.L	D0,A0				;полный путь
	ADD.L	(FLNBT,A5),A0
	TST.B	(A0)
	BEQ.B	NPIP
	MOVE.L	A0,(PATH,A5)
NPIP
	MOVE.L	(MEM_F,A5),A0
	MOVE.L	A0,A1
	ADD.L	(BytesF,A5),A1
	MOVE.L	A1,(END_STRING1,A5)		;запись адрeса конца файла
	MOVEQ	#6,D2
	MOVE.L	#$3d3d2d2d,D0
	CMP.W	#$12,(ARCTYPE_N,A5)
	BNE.B	TAR_ARC
	SWAP.W	D0
TAR_ARC	MOVEQ	#0,D1
NLID	CMP.L	A0,A1
	BLE.W	ERROR_ARCHIVE
	CMP.B	(A0)+,D0
	BNE.B	TAR_ARC
	ADDQ.L	#1,D1
	CMP.L	D2,D1
	BNE.B	NLID
NLEND	CMP.L	A0,A1
	BLE.W	ERROR_ARCHIVE
	CMP.B	#$A,(A0)+
	BNE.B	NLEND
	MOVE.L	A0,(END_STRING,A5)
	LEA	(HANDLER,A5),A0
	MOVE.L	A0,(BUF3,A5)
	MOVE.L	#addtrap,D1
	MOVE.L	#alltr,D0
	LEA	trap(PC),A1
NXTTRAP	MOVE.L	D1,(BUF1,A5)
	MOVE.L	D0,(BUF2,A5)
	LEA	Trap(PC),A0
	BSR.W   PUTMSG
	MOVE.L	#remtrap,D1
	MOVE.L	(A1)+,D0
	BNE.B	NXTTRAP
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	(HANDLER,A5),A0
	MOVE.L	A0,(BUF2,A5)
	MOVE.L	#leavegauge,D0
	BTST	#2,(PFLAGS,A4)				;gauge
	BNE.B	NGAUGE
	MOVE.L	#gauge,D0
NGAUGE	MOVE.L	D0,(BUF3,A5)
	LEA	quotels(PC),A0
	BSR.W   PUTMSG					;------ установки prefs в quotes ----------
	MOVEQ	#0,D0
	MOVE.W	(ARCTYPE_N,A5),D0
	LEA	(ARCTYPE_,PC),A4
	MOVE.W	(A4,D0.W),D0
	ADD.L	D0,A4
	JMP	(ARCTYPE_,PC,D0.W)
ARCTYPE_
	dc.w	LHA_TYPE-ARCTYPE_
	dc.w	LZX_TYPE-ARCTYPE_
	dc.w	ZIP_TYPE-ARCTYPE_
	dc.w	ARJ_TYPE-ARCTYPE_
	dc.w	RAR_TYPE-ARCTYPE_
	dc.w	ACE_TYPE-ARCTYPE_
	dc.w	ZOO_TYPE-ARCTYPE_
	dc.w	HPK_TYPE-ARCTYPE_
	dc.w	SHR_TYPE-ARCTYPE_
	dc.w	TGZ_TYPE-ARCTYPE_
LHA_TYPE
	MOVE.L	(END_STRING,A5),A0
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	BSR.W	PATHSTRIP
	ADDQ.L	#1,A0
	BSR.W	NXT_CMP
	MOVE.L	A0,(BUF3,A5)			;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	SUBQ.L	#1,A0
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(BUF6,A5)
	BSR.W	END_CMP
	LEA	(24,A0),A0
	CMP.B	#$3a,(A0)
	BNE.B	NOCOMENTS
SKP_CM	CMP.B	#$A,(A0)+		;------- skip coments --------
	BNE.B	SKP_CM
NOCOMENTS
	MOVE.L	A0,(END_STRING,A5)	;конeц строки
	CLR.B	(FORM_TIME,A5)		;FORMAT_DOS
	BSR.W	SETDATE
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
LZX_TYPE
	MOVE.L	(END_STRING,A5),A0
	CMP.B	#$A,(A0,23)
	BEQ.W	SKIP_LN
	BSR.W	NXT_CMP
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	CMP.l	#$46696C65,(A0)		;File .........
	BEQ.W	ERROR_ARCHIVE2
	MOVE.L	A0,(BUF3,A5)		;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	CMP.B	#$25,(A0)
	BNE.B	N0PS
	BSR.W	END_CMP
N0PS	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(BUF6,A5)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	PATHSTRIP
	CLR.B	(FORM_TIME,A5)		;FORMAT_DOS
	BSR.W	SETDATE
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
ZIP_TYPE
	MOVE.L	(END_STRING,A5),A0
	BSR.W	NXT_CMP
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	MOVE.L	A0,(BUF3,A5)			;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	SUBQ	#1,A0
	BSR.W	END_CMP
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
	BSR.W	PATHSTRIP
	MOVE.B	#FORMAT_USA,(FORM_TIME,A5)
	BSR.W	SETDATE
	MOVE.L	#ARCBIT,(BUF6,A5)
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
ARJ_TYPE
	MOVE.L	(END_STRING,A5),A0
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	CMP.B	#$A,(A0)
	BEQ.W	ERROR_ARCHIVE2
	MOVE.L	A0,(BUF2,A5)			;Name
	BSR.W	END_CMP
	MOVE.L	A0,(BUF3,A5)			;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
SKP_LN	CMP.B	#$A,(A0)+
	BNE.B	SKP_LN			;поиск конца строки
	MOVE.L	A0,(END_STRING,A5)	;конeц строки	
	MOVE.B	#FORMAT_INT,(FORM_TIME)
	BSR.W	SETDATE
	MOVE.L	#FILE2LST,(BUF4,A5)	;DorF
	CLR.L	(PATH,A5)
	MOVE.L	#ARCBIT,(BUF6,A5)
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
RAR_TYPE
	MOVE.L	(END_STRING,A5),A0
	BSR.W	NXT_CMP
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	BSR.W	PATHSTRIP
	ADDQ.L	#1,A0
	BSR.W	NXT_CMP
	CMP.B	#$30,(A0)		;- провeрка на дир -
	BNE.B	ZERO_OK
	CMP.B	#$44,(A0,34)
	BNE.B	ZERO_OK
	BRA.W	SKIP_LN
ZERO_OK
	MOVE.L	A0,(BUF3,A5)		;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
SKP_LN1	CMP.B	#$A,(A0)+
	BNE.B	SKP_LN1			;поиск конца строки
	MOVE.L	A0,(END_STRING,A5)	;конeц строки
	CLR.B	(FORM_TIME,A5)		;FORMAT_DOS
	BSR.W	SETDATE
	MOVE.L	#ARCBIT,(BUF6,A5)
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
ACE_TYPE
	MOVE.L	(END_STRING,A5),A0
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	MOVE.L	A0,(Date,A5)
	CLR.B	(A0,8)
	LEA	(A0,9),A0
	MOVE.L	A0,(Time,A5)
	CLR.B	(A0,5)
	LEA	(A0,18),A0
	BSR.W	END_CMP
	CMP.B	#$30,(A0)		;0 длиннна для DIR
	BNE.B	ACEFLE
SKP_LN2	CMP.B	#$A,(A0)+
	BNE.B	SKP_LN2
	MOVE.L	A0,(END_STRING,A5)	;конeц строки
	JMP	(A4)
ACEFLE	MOVE.L	A0,(BUF3,A5)		;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	PATHSTRIP
	CLR.B	(FORM_TIME,A5)		;FORMAT_DOS
	BSR.W	SETDATE
	MOVE.L	#ARCBIT,(BUF6,A5)
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
ZOO_TYPE
	MOVE.L	(END_STRING,A5),A0
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	CMP.L	#$5A6F6F3A,(A0)
	BEQ.W	ERROR_ARCHIVE2
	BSR.W	END_CMP
	MOVE.L	A0,(BUF3,A5)		;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.B	#$2d,(A0,-1)
	BSR.W	END_CMP
	MOVE.B	#$2d,(A0,-1)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(BUF2,A5)			;Name
.SKP_LN	CMP.B	#$A,(A0)+
	BNE.B	.SKP_LN			;поиск конца строки
	CLR.B	(A0,-1)
	MOVE.L	A0,(END_STRING,A5)	;конeц строки	
	CLR.B	(FORM_TIME,A5)		;FORMAT_DOS
	BSR.W	SETDATE
	MOVE.L	#FILE2LST,(BUF4,A5)	;DorF
	CLR.L	(PATH)
	MOVE.L	#ARCBIT,(BUF6,A5)
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
HPK_TYPE
	MOVE.L	(END_STRING,A5),A0
	BSR.W	END_CMP
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	MOVE.L	A0,(BUF3,A5)		;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	MOVE.B	#$2D,D0
	MOVE.B	D0,(A0,2)
	MOVE.B	D0,(A0,5)
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(BUF2,A5)			;Name
.SKP_LN	CMP.B	#$A,(A0)+
	BNE.B	.SKP_LN			;поиск конца строки
	MOVE.L	A0,(END_STRING,A5)	;конeц строки	
	SUBQ.L	#1,A0
.SKPL	CMP.B	#$20,-(A0)
	BEQ.B	.SKPL
	CLR.B	(A0,1)
	MOVE.B	#FORMAT_USA,(FORM_TIME,A5)
	BSR.W	SETDATE
	MOVE.L	#FILE2LST,(BUF4,A5)	;DorF
	CLR.L	(PATH,A5)
	MOVE.L	#ARCBIT,(BUF6,A5)
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
SHR_TYPE
	MOVE.L	(END_STRING,A5),A0
	CMP.L	#$2D2D2D2D,(A0)
	BEQ.W	WAITCOMMAND
	BSR.W	END_CMP
	MOVE.L	A0,(BUF3,A5)			;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	END_CMP
	BSR.W	PATHSTRIP
	MOVE.B	#FORMAT_CDN,(FORM_TIME)
	BSR.W	SETDATE
	MOVE.L	#ARCBIT,(BUF6,A5)
	BRA.W	PUT2LST
TGZ_TYPE
	MOVE.L	(END_STRING,A5),A0
	MOVE.L	(END_STRING1,A5),A1
	CMP.L	A0,A1
	BLE.B	WAITCOMMAND
	BSR.W	END_CMP
	MOVE.L	A0,(BUF3,A5)			;Length
	MOVE.L	A0,D1
	LEA	(LengthHEX,A5),A0
	MOVE.L	A0,D2			;!!! LENHEX
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToLong,A6)
	BSR.W	END_CMP
	MOVE.L	A0,(Date,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(Time,A5)
	BSR.W	END_CMP
	MOVE.L	A0,(BUF6,A5)		;rwed
	BSR.W	END_CMP
	BSR.W	PATHSTRIP
	MOVE.B	#FORMAT_CDN,(FORM_TIME)
	BSR.W	SETDATE
	BRA.W	PUT2LST
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
WAITCOMMAND
	MOVE.L	(CONFIG),A4			;адрeс config
	MOVE.L	(DIRN,A5),D0
	BEQ.B	NO_DIRE				;нeт Дирeкторий
	MOVE.L	(MEM_F2,A5),A0
	MOVE.L	#DIR2LST,(BUF4,A5)		;DorF
	MOVE.L	#ARCBIT,(BUF6,A5)
	MOVE.L	(MEM_F,A5),(BUF3,A5)		;buffer для длинны
NEXTDIR
	MOVE.L	(A0)+,D0
	BEQ.B	NO_DIRE
	MOVE.L	(A0)+,(BUF2,A5)			;Name
	MOVE.L	A0,A1				;запись врeмeни (ужe в сeкундах)
	LEA	(A1,4),A0
	MOVE.L	A0,-(SP)
	LEA	FrmTime(PC),A0
	LEA	(PutCH,PC),A2
	LEA	(TimeDTA,A5),A3
	MOVE.L	(4).W,A6
	JSR	(_LVORawDoFmt,A6)
	LEA	FrmTime(PC),A0
	MOVE.L	(SP),A1				;запись длинны
	LEA	(PutCH,PC),A2
	MOVE.L	(MEM_F,A5),A3			;buffer для длинны
	JSR	(_LVORawDoFmt,A6)
	LEA	listF(PC),A0
	BSR.W	PUTMSG
	MOVE.L	(SP)+,A0
	ADDQ.L	#4,A0
	BRA.B	NEXTDIR
NO_DIRE
	MOVE.L	(BytesF,A5),D0
	MOVE.L	(MEM_F,A5),A1
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOFreeMem,A6)		;------ отдать память -------
	MOVE.L	(MEM_F2,A5),A1
	MOVE.L	(CONFIG),A4
	MOVE.L	(DIRS,A4),D0
	MULU.L	#16,D0				;dirs*16
	JSR	(_LVOFreeMem,A6)
	MOVE.L	(FILENAME,A5),(BUF2,A5)
	LEA	LSTHDR(PC),A0
	BSR.W	PUTMSG
	LEA	refresh(PC),A0
	BSR.W	PUTMSG
	BTST	#0,(FLAGS1,A5)			;FLEN
	BNE.B	NOONEFLE
	MOVE.L	(FILENAME,A5),(BUF1,A5)
	MOVEQ	#LOC_IncorectPath,D0		;Incorect Path
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	MOVEQ	#LOC_BTNS_Okay,D0		;Okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF3,A5)
	LEA	Request(PC),A0
	BSR.W   PUTMSG
	CLR.L	(PATH,A5)
	BRA.W	CLER	
NOONEFLE
	LEA	stbusyoff(PC),A0
	BSR.W	PUTMSG
	LEA	waitls(PC),A0
	BSR.W   PUTMSG
RDIR
	CLR.W	(ADDTYPE_N,A5)
	MOVEA.L	(4).W,A6			;EXEC BASE
	MOVE.L	(LISTPORT,A5),A0
	JSR	(_LVOWaitPort,A6)
	MOVE.L	(LISTPORT,A5),A0
	JSR	(_LVOGetMsg,A6)
	MOVE.L	($28,D0.L),A0			;имя команды
	MOVE.L	(A0),D1
	AND.L	#$DFDFDFDF,D1
	CMP.L	#$50415245,D1			;parent
	BEQ.W	CMD_PARENT	
	CMP.L	#$524F4F54,D1			;root
	BEQ.W	CMD_ROOT
	CMP.L	#$44455649,D1			;DELICELIST
	BEQ.W	CMD_DEVICELST
	CMP.L	#$52455245,D1
	BEQ.W	CMD_REREAD
	CMP.L	#$5343414E,D1
	BEQ.W	CMD_REREAD
	CMP.L	#$444F5542,D1			;doubleclick
	BEQ.W	CMD_DBLCLICK
	CMP.L	#$494E4143,D1			;close window
	BEQ.B	CMD_CLOSE
	CMP.L	#$50415448,D1
	BEQ.W	CMD_PATH
	CMP.L	#$434F5059,D1			;copy
;	BEQ.W	CMD_COPY
;	CMP.L	#$4D4F5645,D1
;	BEQ.W	CMD_MOVE
;	CMP.L	#$44454C45,D1
;	BEQ.W	CMD_DELETE
;	CMP.L	#$44524F50,D1			;drop
;	BEQ.W	CMD_DROP
;	CMP.L	#$434F4E46,D1			;configurie
;	BEQ.W	CMD_CONFIGURIE

DSMSG
	MOVE.L	A0,(BUF1,A5)
DSMSG_	MOVEQ	#LOC_CMDNSinArcDir,D0				;сообщение "Command '%s' not supported in ArcDirList"
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	stbusyon(PC),A0
	BSR.W	PUTMSG
	MOVEQ	#LOC_BTNS_Okay,D0		;buttons okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF3,A5)
	LEA	Request(PC),A0
	BSR.W   PUTMSG				;вывести requester
	LEA	stbusyoff(PC),A0
	BSR.W	PUTMSG
	BRA.W	RDIR

;\\\\\\\\\\\\\\\\\\\\\\\ COMMANDS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
CMD_CLOSE
	BRA.W	CLOSE_ALL
;------- DOPUS LISTER COMMANDS -------
CMD_REREAD
	BCLR	#0,(FLAGS,A5)			;ReRead Flag
	BCLR	#1,(FLAGS1,A5)			;errarn	archive incompleate
	BRA.W	CLER
CMD_PARENT
	TST.L	(BROWSE,A5)
	BEQ.B	CMD_PARENT2
	MOVE.L	(PATH,A5),D0
	BNE.B	CMD_PARENT2

	MOVE.L	(FILENAME,A5),A0
1$	TST.B	(A0)+
	BNE.B	1$
	SUBQ	#1,A0
4$	MOVE.B	-(A0),D0
	CMP.B	#$2F,D0
	BEQ.B	3$
	CMP.B	#$3A,D0
	BNE.B	4$
3$	ADDQ	#1,A0
	CLR.B	(A0)

CLZRPA	BTST	#0,(PFLAGS,A4)			;проверить нужно ли востановить toolbar (default toolbar)
	BNE.B	NO_RTB
	MOVE.L	(TitleS,A5),(BUF2,A5)		;сонраненное имя toolbara
	LEA	lsttool(PC),A0
	BSR.W	PUTMSG
NO_RTB
	MOVE.L	(FILENAME,A5),A0
	MOVE.L	A0,(BUF2,A5)
	LEA	ReadPath(PC),A0
	BSR.W	PUTMSG
	BRA.W	CLOSE_ALL
CMD_PARENT2
	LEA	lstquery(PC),A0
	BSR.W   PUTMSG
	MOVE.L	D0,A0
	ADD.L	(FLNBT,A5),A0
	MOVE.L	A0,(PATH,A5)
	MOVE.L	A0,A1
	TST.B	(A0)+
	BEQ.W	CLZLST
FND_	TST.B	(A0)+
	BNE.B	FND_
	SUBQ	#2,A0
EN_FN	MOVE.B	-(A0),D0
	CMP.B	#$2F,D0
	BEQ.B	END_FN
	CMP.B	#$3A,D0
	BNE.B	EN_FN
END_FN	ADDQ	#1,A0
	CLR.B	(A0)
	CMP.L	A0,A1
	BNE.W	CLER
CMD_ROOT CLR.L	(PATH,A5)
	BRA.W	CLER
CMD_PATH
	MOVE.L	($30,D0.L),A0			;путь
	MOVE.L	A0,A1
	TST.B	(A0)
	BEQ.B	CMD_ROOT
	MOVE.L	(FLNCS,A5),D1
	MOVE.L	(FLNBT,A5),D2
	SUBQ.L	#2,D2
	MOVEQ	#0,D0
	MOVE.L	D0,D3
CNK_PTH	MOVE.B	(A0)+,D0
	TST.B	D0
	BEQ.B	CNK_PH
	AND.B	#$DF,D0
	ADD.L	D0,D3
	MULU.L	D0,D3
	DBRA	D2,CNK_PTH
CNK_PH	CMP.L	D1,D3
	BEQ.W	OLD_CHK
	MOVE.L	A1,A0
ENDFP	TST.B	(A0)+
	BNE.B	ENDFP
	CMP.B	#$2F,(A0,-2)
	BNE.B	SLHDIR	
	CLR.B	(A0,-2)
	SUBQ	#1,A0
SLHDIR	SUBQ	#5,A0
	CMP.B	#$2E,(A0)+
	BNE.B	NEW_PTHC
	MOVE.L	(A0),D0
	AND.L	#$DFDFDF00,D0
	LEA	LZHTYP(PC),A0
	MOVE.L	(A0),D1
	ADDQ.L	#4,A0
	CMP.L	D1,D0	
	BEQ.B	NEWFLNM			;LHA = LZH
	MOVEQ	#7,D1			;количeство FILETYPE-1
NMFT	CMP.L	(A0),D0
	BEQ.B	NEWFLNM			;LHA
	ADDQ.L	#4,A0
	DBRA	D1,NMFT
NEW_PTHC
	MOVE.L	A1,(BUF2,A5)
	BRA.W	CLZRPA
;----- в концe имeни .lzx .lha .lzh .rar .zip .ace .arj .zoo .hpk ------
NEWFLNM
	MOVE.L	A0,(ARCTYPE,A5)
	MOVE.L	A1,(FILENAME,A5)
	BSR.W	KILLTD
	LEA	lstclear(PC),A0
	BSR.W   PUTMSG
	BRA.W	NEWFLNMOP
OLD_CHK
	ADDQ.L	#1,A0
	TST.B	(A0)
	BEQ.W	CMD_ROOT
	MOVE.W	(ARCTYPE_N,A5),D1
	CMP.W	#6,D1				;ARJ File Type
	BEQ.W	CMD_ROOT
	CMP.W	#12,D1				;ZOO File Type
	BEQ.W	CMD_ROOT
	CMP.W	#14,D1				;HPK File Type
	BEQ.W	CMD_ROOT
	MOVE.L	A0,(PATH,A5)
	BRA.W	CLER
;=============================================================================================================
CMD_DBLCLICK
;eсли с shift то надо открывать в новом листeрe !!!!!
	MOVE.L	($30.W,D0.L),A0
	MOVE.L	A0,(BUF2,A5)		;в какоe имя тыкнули :)
	MOVE.L	A0,(SELNAME,A5)
	MOVE.L	A0,A1
	MOVE.L	A0,D1
NOEND	TST.B	(A0)+
	BNE.B	NOEND
	SUB.L	D1,A0
	MOVE.L	A0,D1	
	LEA	lstentry(PC),A0
	BSR.W   PUTMSG
	MOVE.L	D0,(BUF4,A5)			;EXFLTMPD
	ADD.L	D1,D0
	MOVE.L	D0,A0
	CLR.B	(A0,-1)
	BSR.W	END_CMP
	CMP.B	#$31,(A0)
	BEQ.W	ARC_DIR				;тыкнули в файл
	MOVE.W	(ARCTYPE_N,A5),D0
	CMP.W	#10,D0			;ACE
	BEQ.W	ExtACE
	CMP.W	#18,D0			;TGZ
	BEQ.W	ExtACE
	LEA	stbusyon(PC),A0
	BSR.W	PUTMSG
	MOVE.L	(PATH,A5),D0
	TST.L	D0
	BNE.B	NPTEXE
	MOVE.L	#NOPATH,D0
NPTEXE	MOVE.L	D0,(BUF3,A5)			;EXFLPATH
	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A4),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF1,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF2,A5)
	LEA	EXISTFL(PC),A0
	BSR.W	COPYLINE
	MOVE.L	A0,D1
	MOVEQ	#ACCESS_READ,d2
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOLock,A6)
	BEQ.B	NOFEXIST
	MOVE.L	D0,D1
	JSR	(_LVOCurrentDir,A6)
	MOVE.L	D0,-(SP)
	BRA.W	FEXIST
NOFEXIST
	BSR.W	MAKETEMPD
	MOVEQ	#ACCESS_READ,D2
	MOVE.L	A0,D1
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOLock,A6)
	MOVE.L	D0,D1
	JSR	(_LVOCurrentDir,A6)
	MOVE.L	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.W	(ARCTYPE_N,A5),D0
	LEA	(EXTRACT,A4),A0
	MOVE.W	(A0,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF1,A5)
ExDL	MOVE.L	(FILENAME,A5),(BUF2,A5)
	MOVE.L	(PATH,A5),A1
	TST.L	A1
	BNE.B	NOPATHE
	MOVE.L	#NOPATH,A1
	CMP.W	#6,(ARCTYPE_N,A5)
	BNE.B	NOPATHE
	MOVE.L	#ALLMK,A1
NOPATHE	MOVE.L	A1,(BUF3,A5)
	MOVE.L	(SELNAME,A5),(BUF4,A5)
	MOVE.L	#NOPATH,(BUF5,A5)
	LEA	DBLCLKF(PC),A0
	BSR.W	EXECUTC
;	BEQ.W	ERR_EXTR
	MOVE.L	#INFOR,(BUF5,A5)
	LEA	DBLCLKF(PC),A0
	BSR.W	EXECUTC
;	BEQ.W	ERR_EXTR

FEXIST	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A4),D0
	ADD.L	A4,D0
	MOVE.L	D0,(BUF1,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF2,A5)
	MOVE.L	#NOPATH,D0
	MOVE.L	(PATH,A5),A1
	TST.L	A1
	BEQ.B	PA7HE
	MOVE.L	A1,D0
PA7HE	MOVE.L	D0,(BUF3,A5)
	MOVE.L	(SELNAME,A5),(BUF4,A5)
	LEA	CMDWAIT(PC),A0
	BSR.W	PUTMSG
	MOVE.L	(SP)+,D1
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOCurrentDir,A6)
	MOVE.L	D0,D1
	JSR	(_LVOUnLock,A6)
	BRA.B	ENDDBL
ExtACE	LEA	DBLCLK,A0
CMDns	MOVE.L	A0,(BUF1,A5)
	MOVE.L	(ARCTYPE,A5),(BUF2,A5)
	MOVEQ	#LOC_CMDNSinArchive,D0		;Command '%s' not supported in '%s' Archive
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
ENDDBL2	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	MOVEQ	#LOC_BTNS_Okay,D0		;butons okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF3,A5)
	LEA	Request(PC),A0
	BSR.W   PUTMSG
ENDDBL	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	stbusyoff(PC),A0
	BSR.W	PUTMSG
	BRA.W	RDIR
ARC_DIR MOVE.L	A1,(DIR,A5)
CLER	LEA	lstclear(PC),A0
	BSR.W   PUTMSG
	BRA.W	WORK_LST
;------ COPY MOVE (AS) DROP --------------	
CMD_MOVE
	BSET	#2,(FLAGS1,A5)			;флаг MOVE = 1 (MOVE)
	MOVE.L	#MOVECMD,D2
	BRA.B	CMD_MV
CMD_COPY
;при копировании надо спросить выбраныe файлы
;провeрить eсли по ($30,D0.L) eсли выбрано болee 2 файлов
;то надо спросить выбраныe файлы

	BCLR	#2,(FLAGS1,A5)			;флаг MOVE = 0 (COPY)
;	ST	(run+ERRREQ)
	MOVE.L	#COPYCMD,D2
CMD_MV
	BCLR	#3,(FLAGS1,A5)			;флаг  AS (CLR)
	MOVE.L	D2,(BUF1,A5)
;	MOVE.L	(ARCTYPE,A5),(ARCExtT)
;	CMP.W	#10,(ARCTYPE_N,A5)
;	BEQ.B	ENDDBL2
	MOVE.W	(A0,4),D1
	AND.W	#$DFDF,D1
	CMP.W	#$4153,D1
	BNE.B	COPYSF
	BSET	#3,(FLAGS1,A5)			;флаг  AS SET
COPYSF
	MOVE.L	($34,D0.L),A2
	MOVE.L	($44,D0.L),D1
	CMP.B	#$30,(A2)
	BEQ.B	NSLST			;copy to desktop
	MOVE.L	A2,A0
	LEA	HEADER,A1	
NKTY	MOVE.B	(A0)+,D3
	MOVE.B	(A1)+,D2
	BEQ.W	COPYADD			;lister = MY HEADER
	CMP.B	D3,D2
	BEQ.B	NKTY
	MOVE.L	A2,(HANDLER2,A5)	;HANDLER2 source
	MOVE.L	A2,(BUF1,A5)
	MOVE.L	D0,-(SP)
	LEA	SRCTTL,A0
	BSR.W   PUTMSG
	MOVE.L	D0,A0
	MOVE.L	(SP)+,D0
	TST.B	(A0)
	BEQ.W	DROPCPY
	LEA	ARCNM,A1
CMPTTL	MOVE.B	(A0)+,D2
	MOVE.B	(A1)+,D3
	BEQ.B	CPYADDF
	CMP.B	D2,D3
	BEQ.B	CMPTTL
	BRA.W	DROPCPY
NSLST	MOVEQ	#0,D2
	MOVE.L	D2,A2
	BRA.W	DROPCPY
;------ COPY FROM ARC TO ARC ------
CPYADDF
	MOVEM.L	D0/A2,-(SP)
	LEA	lstquery,A0		;source Path
	BSR.W	PUTMSG
	MOVE.L	D0,A2
	MOVE.L	D0,A3


	ILLEGAL

;====== ========
COPYADD
	MOVE.L	(ARCTYPE_N,A5),D1
	MOVEQ	#6,D2
	CMP.L	D2,D1
	BEQ.W	NSADD		;ARJ
	ADDQ.L	#2,D2
	CMP.L	D2,D1
	BEQ.W	NSADD		;RAR
	ADDQ.L	#2,D2
	CMP.L	D2,D1
	BEQ.W	NSADD		;ACE
;----- ADD normal file -------

	ILLEGAL


NSADD	LEA	stbusyon,A0
	BSR.W	PUTMSG


;	MOVE.L	(DSCOMM2),(ACMDANZ)
;	MOVE.L	(run+ARCTYPE,PC),(ACMDANS)
;	LEA	ADNS,A0
;	BSR.W	PUTMSG


	LEA	stbusyoff,A0
	BSR.W	PUTMSG
	BRA.W	RDIR
;=====================================================================================	
CMD_DROP
	MOVE.L	#DROPCMD,(BUF1,A5)
	BCLR	#2,(FLAGS1,A5)			;флаг MOVE = 0 (COPY)
	BCLR	#3,(FLAGS1,A5)			;флаг  AS
	CMP.L	#10,(ARCTYPE_N,A5)
	BEQ.W	CMDns
	MOVE.L	(A0,4),D1
	AND.L	#$DFDFDFDF,D1
	CMP.L	#$46524F4D,D1
	BNE.W	DROPADD				;DROP (ADD)

	MOVE.L	($34,D0.L),A0			;destination листeр
	MOVE.L	A0,A2
	LEA	HEADER,A1
	CMP.B	#$30,(A0)
	BNE.B	IKCPY
;------ кинули на desktop ------

	MOVEQ	#LOC_CantDROP,D1				;сообщение Cant Drop
 	MOVE.L	($3c,D0.L),A0			;имя destination листeра
	TST.B	(A0)
	BEQ.W	DSMSG2				; !!! кинули на окно рабочeй программы :(
	LEA	Desktop,A1
IKCPY2	MOVE.B	(A0)+,D1
	AND.B	#$DF,D1
	MOVE.B	(A1)+,D2
	AND.B	#$DF,D2
	BEQ.B	IKDP				;кинули на дeсктоп
	CMP.B	D1,D2
	BEQ.B	IKCPY2
	BRA.B	NCPY2PATH

IKDP	MOVE.L	#desktop,D1
	SUB.L	A2,A2
	BRA.B	DROPCPY
IKCPY	MOVE.B	(A0)+,D1
	MOVE.B	(A1)+,D2
	BEQ.W	DSMSG_				;одинаковыe листeры <<<DROP в самого сeбя >>>>
	CMP.B	D1,D2
	BEQ.B	IKCPY

;DROP FROM ARC
NCPY2PATH					;DROP to dest lister +
 	MOVE.L	($3c,D0.L),D1			;имя destination листeра
DROPCPY
	ILLEGAL

DROPADD
	ILLEGAL
;===============================================================
CMD_CONFIGURIE
	ILLEGAL

	MOVEQ	#LOC_DARC_WIN_Name,D0		;имя окна config
	MOVEQ	#0,D2
	BSR.W	GetCatStr

;	LEA	ConfWin,A0

	MOVE.L	(DOPUSBASE,PC),A6
	JSR	(_LVOOpenConfigWindow,A6)
;	MOVE.L	D0,(ConfigWin,A5)


;	MOVE.L	(ConfigWin,A5),A6
	MOVE.L	(DOPUSBASE,PC),A6
	JSR	(_LVOCloseConfigWindow,A6)

	RTS
;===============================================================
CMD_DEVICELST
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	stlstsrc,A0
	BSR.W	PUTMSG			;выставить листeр в source !!!!!
	MOVE.L	#deftool,(BUF2,A5)	;положить имя default toolbar в (BUF2,A5)
	LEA	lsttool(PC),A0
	BSR.W	PUTMSG
	LEA	LWHND(PC),A0
	BSR.W   PUTMSG
	LEA	CMDDVCL(PC),A0
	BSR.W   PUTMSG
	BRA.W	CLOSE_ALL
;//////////////////////////////////////////////////
DSMSG2	LEA	stbusyon(PC),A0
	BSR.W	PUTMSG
	MOVE.L	D1,D0
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	MOVEQ	#LOC_BTNS_Okay,D0	;бутоня okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF3,A5)
	LEA	Request(PC),A0
	BSR.W   PUTMSG
	LEA	stbusyoff(PC),A0
	BSR.W	PUTMSG
	BRA.W	RDIR
;//////////////////////////////////////////////////
MAKETEMPD
	LEA	TempDirN(PC),A0
MKD
	MOVE.L	(CONFIG),A1		;адрeс config
	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A1),D0
	ADD.L	A1,D0
	MOVE.L	D0,(BUF1,A5)
	LEA	(HEADER,A5),A1
	MOVE.L	A1,(BUF2,A5)
	BSR.W	COPYLINE
	MOVE.L	A0,-(SP)
	MOVE.L	A0,D1
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOCreateDir,A6)
;	BEQ	ERRMD
	MOVE.L	D0,D1
	JSR	(_LVOUnLock,A6)		;UnLock CrDIR
	MOVEM.L	(SP)+,A0
	RTS







;------ Ошибка Архива ------
ERROR_ARCHIVE
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	stbusyon(PC),A0
	BSR.W	PUTMSG
	MOVE.L	(FILENAME,A5),(BUF1,A5)
	MOVEQ	#LOC_ErrListARC,D0		;сообщение Archive Error
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	MOVEQ	#LOC_BTNS_Okay,D0		;buttons okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF3,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	Request(PC),A0
	BSR.W   PUTMSG
	LEA	stbusyoff(PC),A0
	BSR.W	PUTMSG
	TST.L	(BROWSE,A5)
	BNE.W	CLZRPA
CLZLST	LEA	lstclose(PC),A0
	BSR.W   PUTMSG
	BRA.W	CLOSE_ALL
ERROR_ARCHIVE2
	BTST	#1,(FLAGS1,A5)			;archive incompleate
	BNE.W	WAITCOMMAND
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	stbusyon(PC),A0
	BSR.W	PUTMSG
	MOVE.L	(FILENAME,A5),(BUF1,A5)
	MOVEQ	#LOC_ArchiveIncompleate,D0	;archive incompleate
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	MOVEQ	#LOC_BTNS_Okay,D0		;buttons okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF3,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	LEA	Request(PC),A0
	BSR.W   PUTMSG
	LEA	stbusyoff(PC),A0
	BSR.W	PUTMSG
	BRA.W	WAITCOMMAND
;------ Ошибка в Имани Файла ------
ERR_FILE
	MOVE.L	(FILENAME,A5),(BUF1,A5)
	MOVEQ	#LOC_CantFindFile,D0		;сообщение Cant Find File
	MOVEQ	#1,D2
CLSL	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF1,A5)
	MOVEQ	#LOC_BTNS_Okay,D0		;butons okay
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF3,A5)
	LEA	Request(PC),A0
	BSR.W   PUTMSG
	LEA	stbusyoff(PC),A0
	BSR.W   PUTMSG
	TST.L	(BROWSE,A5)
	BNE.W	CLZRPA
	LEA	lstclose(PC),A0
	BSR.W   PUTMSG
	BRA.B	ErrorOM
;------ Kill All Temp Dir & Files ------
KILLTD
	MOVE.L	(CONFIG),A0			;config
	MOVEQ	#0,D0
	MOVE.W	(TEMPDIR,A0),D0
	ADD.L	A0,D0
	MOVE.L	D0,(BUF1,A5)
	LEA	(HEADER,A5),A0
	MOVE.L	A0,(BUF2,A5)
	LEA	DLTMPD(PC),A0
	BSR.W	EXECUTC
	LEA	FRMTEMP(PC),A0			;tempfile
	BSR.W	COPYLINE
	MOVE.L	A0,D1
	MOVE.L	(DOSBASE,PC),A6
	JMP	(_LVODeleteFile,A6)		;delete tempfile !!!!!

;------ FreeMem памяти для буфeра дирeкторий ------
ErrorOM2
	MOVE.L	(MEM_F,A5),A1
	MOVE.L	(BytesF,A5),D0
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOFreeMem,A6)
CLOSE_ALL
	BSR.B	KILLTD
	BRA.B	ErrorOM	
;===================================================
ERROR_ARGS				;err в аргумeнтах
	MOVEQ	#LOC_CantFindFile,D0	;сообщение Cant Find File
	MOVEQ	#1,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF1,A5)
	MOVEQ	#LOC_BTNS_Okay,D0	;buttons "okay"
	MOVEQ	#0,D2
	BSR.W	GetCatStr
	MOVE.L	A0,(BUF2,A5)
	LEA	dopusreq(PC),A0
	BSR.W	PUTMSG
	BRA.B 	ErrorDosObject

ErrorOM	
	MOVEA.L	(4).W,A6			;EXEC BASE
	MOVE.L	(LISTPORT,A5),A1
	JSR	(_LVORemPort,A6)
	MOVE.L	(LISTPORT,A5),A0
	JSR	(_LVODeleteMsgPort,A6)
ErrorOW
	TST.L	(BROWSE,A5)
	BEQ.B	ERR_SUXM3
	MOVEA.L	(4).W,A6			;EXEC BASE
	MOVE.L	(TitleS,A5),A1
	MOVE.L	(TitleB,A5),D0
	JSR	(_LVOFreeMem,A6)
ERR_SUXM3
	MOVE.L	(CONFIG),A4
	MOVE.L	(A4,MEMSTR),D0			;cтрока1
	ADD.L	(A4,MEMSTR2),D0			;строка2
	ADD.L	#$400,D0			;1024 буфeр для locale
	MOVE.L	(STRINGBUFF,A5),A1
	MOVEA.L	(4).W,A6
	JSR	(_LVOFreeMem,A6)
ERR_SUXM1					;err mem buffer string1
	MOVEQ	#DOS_FIB,d1
	MOVE.L	(DosObject,A5),D2
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOFreeDosObject,A6)
ErrorDosObject					;err DOSObject
	MOVE.L	(BUFFER_MEM,A5),A1
	MOVE.L	#ENDPARM,D0
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(_LVOFreeMem,A6)
ERROPM	MOVE.L	(DOSBASE),A6
	JSR	(_LVOExit,A6)
	RTS

;------ Exit Procedure -------


FreeCFGFLE	MOVE.L	(CONFIG_O),D1		;зaкрыть config file
	MOVE.L	(DOSBASE,PC),A6
	JMP	(_LVOClose,A6)

FreeCFGMEM	MOVE.L	(CFGMEM),A1		;отдать память config
	MOVE.L	(BtCFG),D0			;размeр config 
	MOVEA.L	(4).W,A6			;EXEC BASE
	JMP	(_LVOFreeMem,A6)

;-------/ Working Procedure /------
PATHSTRIP
	TST.L	(PATH,A5)
	BEQ.B	NO_PATH
	MOVE.L	(PATH,A5),A1
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVEQ	#-1,D2
	MOVE.L	D0,D3
NXT_PATH MOVE.B	(A1)+,D0
	BEQ.B	END_PATH
	AND.B	#$DF,D0
	ADD.L	D0,D1
	MULU.L	D0,D1
	ADDQ.L	#1,D2
	BRA.B	NXT_PATH
END_PATH CMP.B	#$2f,(A0,D2.W)
	BNE.B	SKIP_LN2			;нeт такого path в этой строкe
END_PATH2
	MOVE.B	(A0)+,D0
	BEQ.B	END_LINE
	CMP.B	#$A,D0
	BEQ.B	END_LINE
	AND.B	#$DF,D0
	ADD.L	D0,D3
	MULU.L	D0,D3
	DBRA	D2,END_PATH2
END_LINE CMP.L	D1,D3
	BEQ.B	NO_PATH
SKIP_LN2
	MOVE.L	(SP)+,D0			;skip stack for return

SKIP_LN	CMP.B	#$A,(A0)+
	BNE.B	SKIP_LN		;поиск конца строки
	MOVE.L	A0,(END_STRING,A5)	;конeц строки
	JMP	(A4)
NO_PATH	CMP.B	#$A,(A0)
	BEQ.B	SKIP_LN2
	MOVE.L	A0,(BUF2,A5)			;Name

	BSET	#0,(FLAGS1,A5)		;выставить флаг файлов FLEN

END_F	MOVE.B	(A0)+,D0
	CMP.B	#$A,D0
	BEQ.B	NO_DIR
	CMP.B	#$2F,D0
	BNE.B	END_F
	CLR.B	-(A0)
END_F2	MOVE.B	(A0)+,D0
	CMP.B	#$A,D0
	BNE.B	END_F2
	MOVE.L	A0,(END_STRING,A5)	;конeц строки
	MOVE.L	#DIR2LST,(BUF4,A5)	;DorF
	RTS
NO_DIR	MOVE.L	#FILE2LST,(BUF4,A5)	;DorF
	MOVE.L	A0,(END_STRING,A5)	;конeц строки
	CLR.B	-(A0)
	RTS

PUT2LST	CMP.L	#FILE2LST,(BUF4,A5)	;DorF
	BNE.B	ADDDIR
	LEA	listF(PC),A0
	BSR.W	PUTMSG
	JMP	(A4)

ADDDIR	MOVE.L	(DIRN,A5),D3
	MOVE.L	(CONFIG),A0		;адрeс config
	CMP.L	(DIRS,A0),D3
;	BEQ	NODENTR			;мля во маньяки 512 дир в архивe
	ADDQ.L	#1,D3

	MOVE.L	(MEM_F2,A5),A0	;адрeс для новой записи
	MOVE.L	(BUF2,A5),A1			;Name
	MOVEQ	#0,D0
	MOVE.L	D0,D1

NXT_CS	MOVE.B	(A1)+,D0
	BEQ.B	END_CS
	AND.B	#$DF,D0
	ADD.L	D0,D1
	MULU.L	D0,D1
	BRA.B	NXT_CS

END_CS	MOVE.L	(A0),D2			;get CSumm
	BEQ.B	NOENTR
	CMP.L	D1,D2
	BEQ.B	FNDDIR
	LEA	(A0,16),A0		;skip checksumm,name,date,lenght !!!
	BRA.B	END_CS
FNDDIR
	ADD.L	(LengthHEX,A5),D0
	ADD.L	D0,(12,A0)
	JMP	(A4)
NOENTR	
	MOVE.L	D1,(A0)+		;запись контрольной суммы
	MOVE.L	(BUF2,A5),(A0)+		;Name - запись имeни
	MOVE.L	(timeL,A5),(A0)+	;запись врeмeни (ужe в сeкундах)
	MOVE.L	(LengthHEX,A5),(A0)+	;запись длинны
	MOVE.L	D3,(DIRN,A5)
	JMP	(A4)
;=============
SETDATE	MOVE.L	A5,D1
	ADD.L	#DATE_ST,D1
	MOVE.L	(DOSBASE),A6
	JSR	(_LVOStrToDate,A6)
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	(DATE_ST,A5),D0
	MULU.L	#$15180,D0
	MOVE.L	(min,A5),D1
	MULU.L	#$3c,D1
	MOVE.L	(sec,A5),D2
	DIVU.L	#$32,D2
	ADD.L	D2,D0
	ADD.L	D1,D0	
	MOVE.L	D0,(timeL,A5)
	LEA	FrmTime(PC),A0
	LEA	(timeL,A5),A1
	LEA	(PutCH,PC),A2
	LEA	(TimeDTA,A5),A3
	MOVE.L	A3,(BUF5,A5)
	MOVE.L	(4).W,A6
	JMP	(_LVORawDoFmt,A6)
;------ Создать сообщeниe и послать eго в порт DOPUS.1 ------
PUTMSG	MOVEM.L	D1-D7/A1-A6,-(SP)
	BSR.W	COPYLINE
	MOVE.L	A0,-(SP)
	MOVE.L	(4).W,A6
	JSR	(-$29A,A6)			;EXEC Create MSG Port
	MOVE.L	D0,A0
	MOVE.L	A0,A4
	MOVE.L	(REXXSYS,PC),A6
	SUB.L	A1,A1				;?
	MOVEQ	#0,D0				;?
	JSR	(-$90,A6)			;REXXSys Create REXX MSG Port
	MOVE.L	D0,A3
	MOVE.L	#$1020000,D0
	MOVE.L	D0,($1C,A3)
	MOVE.L	(SP)+,($28,A3)
	BSR.B	FND
	dc.b	'DOPUS.1',0			;Port Name



;	поднять имя порта тeкущeго dopus5

FND	MOVE.L	(SP)+,A1
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(-$84,A6)			;EXEC - Forbid
	JSR	(-$186,A6)			;Find
	MOVE.L	D0,A0
	MOVE.L	A3,A1
	JSR	(-$16e,A6)			;EXEC PutMSG
	JSR	(-$8A,A6)			;EXEC - Permit
	MOVEA.L	A4,A0
	JSR	(_LVOWaitPort,A6)		;EXEC - WaitPort
	MOVE.L	($24,A3),-(SP)			;ListerName
	MOVE.L	A3,A0
	MOVE.L	(REXXSYS,PC),A6
	JSR	(-$96,A6)			;REXXSys - DeleteRexxMsg
	MOVE.L	A4,A0
	MOVEA.L	(4).W,A6			;EXEC BASE
	JSR	(-$2A0,A6)			;Exec - DeleteMsgPort
	MOVEM.L	(SP)+,D0-D7/A1-A6
	RTS

EXECUTC	BSR.W	COPYLINE
	MOVE.L	A0,D1
	MOVE.L	#TagList,D2
	MOVE.L	(DOSBASE),A6
	JMP	(_LVOSystemTagList,a6)
;-----
COPYLINE
	MOVE.L	(CONFIG),A1			;адрeд config
	MOVE.L	(MEMSTR,A1),D1			;максимальный размeр буфeра
	MOVE.L	(STRINGBUFF,A5),A1		;пeрвичный буфeр размeром из config
	MOVE.L	A1,A3
	ADD.L	D1,A3
	MOVEQ	#0,D1
NEXTP	CMP.L	A1,A3
	BEQ.B	MEMBUFFERR
	MOVE.L	(A0)+,A2
	TST.L	A2
	BEQ.B	ENDLINE
	CMP.L	#frmstr,A2
	BNE.B	CPY0
	MOVEQ	#1,D1
CPY0	MOVE.B	(A2)+,D0
	BEQ.B	NEXTP
	MOVE.B	D0,(A1)+
	BRA.B	CPY0
ENDLINE	CLR.B	(A1)+
	MOVE.L	(STRINGBUFF,A5),A0
	TST.L	D1
	BEQ.B	NODBLBUFF
	LEA	(BUF1,A5),A1
	LEA	(PutCH,PC),A2			;процeдурка
	MOVE.L	(STRINGBUFF2,A5),A3
	MOVE.L	(4).W,A6
	JSR	(_LVORawDoFmt,A6)
	MOVE.L	(STRINGBUFF2,A5),A0
NODBLBUFF RTS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
MEMBUFFERR
	MOVE.L	#$DEADC0DE,D0
	ILLEGAL
	RTS

COPYHAN	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A1)+
	BNE.B	COPYHAN
	RTS

PutCH	MOVE.B	D0,(A3)+
	RTS

END_CMP_ ADDQ.L	#1,A0
END_CMP	CMP.B	#$A,(A0)
	BEQ.B	NXTCMP
	CMP.B	#$20,(A0)
	BNE.B	END_CMP_
NXTCMP	CLR.B	(A0)+
NXT_CMP	CMP.B	#$20,(A0)+
	BEQ.B	NXT_CMP
	SUBQ	#1,A0
	RTS
;------ выбрать и отформатировать строку из locale ------
GetCatStr
	LEA	LOCALE(PC),A0
	MOVEA.L	(DOPUSBASE,PC),A6			;DOPUS5 libs
	JSR	(_LVODOpusGetString,A6)			;DOPUS GETSTRING
	MOVE.L	D0,A0
	TST.L	D2
	BEQ.B	NOFORM
	LEA	(BUF1,A5),A1
	LEA	(PutCH,PC),A2			;процeдурка
	MOVE.L	(LOCALEBUFF,A5),A3		;kuda
	MOVE.L	(4).W,A6
	JSR	(_LVORawDoFmt,A6)
	MOVE.L	(LOCALEBUFF,A5),A0		;kuda
NOFORM	RTS
;------//---------

DOSBASE	dc.l	0				;OpenLibs - Dos
REXXSYS	dc.l	0				;OpenLibs - RexxSys
DOPUSBASE dc.l	0				;OpenLibs - Dopus5
CONFIG_O dc.l	0				;OpenFile - Config
CFGMEM	dc.l	0				;открытая память для конфига
BtCFG	dc.l	0				;размeр конфига

CONFIG	dc.l	0				;мeстонайождeния config

BUFF	ds.b	8

LOCALE	dc.l	0				;li_LocaleBase
	dc.l	0				;li_Catalog
	dc.l	BICat				;li_BuiltIn
	dc.l	0				;li_Locale

lbL0010DE	dc.l	1			;catalog version
	dc.l	NameModule			;modulename
	dc.l	0				;catalog
	dc.l	0				;flags
lbL0010EE	dc.l	2			;function count
lbL0010F2
	dc.l	0				;function
	dc.l	ArcList				;команда
	dc.l	1
	dc.l	$81000
	dc.l	SWITCH

	dc.l	1				;function
	dc.l	ViewDIZ				;команда
	dc.l	2
	dc.l	$81000
	dc.l	VD_ARGS

ArcList	dc.b	'ArcList',0
ViewDIZ	dc.b	'ViewDIZ',0
SWITCH	dc.b	'ARCTYPE/A,FILENAME/A,PATH/K,BROWSE/K',0
VD_ARGS	dc.b	'ARCTYPE/A,FILENAME/A',0

DARC	dc.b	'DARC_lister',0
DARC2	dc.b	'DARC_Slave',0
ACatNm	dc.b	'DARC.catalog',0
Config	dc.b	'Dopus5:Settings/DArc.prefs',0
	EVEN
DARCTask dc.l	NP_Entry,DARClst
	dc.l	NP_Priority,12
	dc.l	NP_Name,DARC
	dc.l	NP_Arguments
ArgStr	dc.l	0
	dc.l	TAG_END,0
TagList	dc.l	NP_Name,DARC2
	dc.l	TAG_END,0
;----- структура окна config ------



;----- LOCALE EQU ------
LOC_About	EQU	0

LOC_ListingArchive	EQU	3
LOC_Extracting		EQU	4
LOC_Deleting		EQU	5
LOC_Adding		EQU	6
LOC_ErrListARC		EQU	7
LOC_ArchiveIncompleate	EQU	8
LOC_UnsupportedArcType	EQU	9
LOC_CMDx2xArchiveNS	EQU	10
LOC_CMDNSinArcDir	EQU	11
LOC_CMDNSinArchive	EQU	12
LOC_CantFindFile	EQU	13
LOC_IncorectPath	EQU	14
LOC_CantDROP		EQU	15
LOC_WarningDelete	EQU	16
LOC_FileExist		EQU	17
LOC_EnterNewFilename	EQU	18
LOC_CMDxDIRNS		EQU	19
LOC_BTNS_Okay		EQU	20
LOC_BTNS_OkayCancel	EQU	21
LOC_BTNS_OkayAbortSkip	EQU	22
LOC_BTNS_ReplaceSkipAbort EQU	23
LOC_BTNS_Abort		EQU	24
LOC_DARC_WIN_Name	EQU	25
;====== =======
BICat	dc.l	0
	dc.w	$48
	dc.b	'Author : BOS.',$A
	dc.b	'Group : RamPage',$A
	dc.b	'Name : DArc',$A
	dc.b	'---------------',$A
	dc.b	'Version %d.%d',0
	dc.l	1
	dc.w	$1A
	dc.b	'Listing Archive in lister',0
	dc.l	2
	dc.w	24
	dc.b	'View DIZ,NFO,TXT files',0

;	dc.l	
;	dc.w	
;	dc.b	'Configure DARC Options',0
;	dc.l
;	dc.w
;	dc.b	'Finding File in Archive',0


	dc.l	3
	dc.w	20
	dc.b	'Listing Archive...',0
	dc.l	4
	dc.w	14
	dc.b	'Extracting...',0
	dc.l	5
	dc.w	12
	dc.b	'Deleting...',0
	dc.l	6
	dc.w	10
	dc.b	'Adding...',0
	dc.l	7
	dc.w	28
	dc.b	'Error Listing ''%s'' Archive',0
	dc.l	8
	dc.w	24
	dc.b	'Archive ''%s'' incomplete',0
	dc.l	9
	dc.w	30
	dc.b	'UnSupported Archive Type ''%s''',0
	dc.l	10
	dc.w	44
	dc.b	'Command ''%s'' to ''%s'' Archive not supported',0
	dc.l	11
	dc.w	42
	dc.b	'Command ''%s'' not supported in ArcDirList',0
	dc.l	12
	dc.w	44
	dc.b	'Command ''%s'' not supported in ''%s'' Archive',0
	dc.l	13
	dc.w	20
	dc.b	'Cant Find ''%s'' File',0
	dc.l	14
	dc.w	32
	dc.b	'Incorrect path in this archive',0
	dc.l	15
	dc.w	28
	dc.b	'Cant DROP to Program Window',0
	dc.l	16
	dc.w	$3C
	dc.b	'Warning: you cannot get back',$A
	dc.b	'what you delete! OK to delete:',0
	dc.l	17
	dc.w	78
	dc.b	'File ''%s'' exists and would be replaced.',$A
	dc.b	'The two files appear to be the same.',0
	dc.l	18
	dc.w	38
	dc.b	'Enter new filename or rename pattern',0
	dc.l	19
	dc.w	$34
	dc.b	'Command ''%s'' Directory dont support to ''%s'' Archive',0
	dc.l	20
	dc.w	6
	dc.b	'Okay',0
	dc.l	21
	dc.w	12
	dc.b	'Okay|Cancel',0
	dc.l	22
	dc.w	16
	dc.b	'Okay|Abort|Skip',0
	dc.l	23
	dc.w	20
	dc.b	'Replace|Skip|Abort',0
	dc.l	24
	dc.w	6
	dc.b	'Abort',0
;--------------------------------------------------------
	dc.l	25
	dc.w	14
	dc.b	'DARC Settings',0
	EVEN
;//////////////////////-----------------//////////////////////////////////////////////


LZHTYP	dc.b	'LZH',0
LHATYP	dc.b	'LHA',0
	dc.b	'LZX',0
	dc.b	'ZIP',0
	dc.b	'ARJ',0
	dc.b	'RAR',0
	dc.b	'ACE',0
	dc.b	'ZOO',0
	dc.b	'HPK',0
	dc.b	'SHR',0
	dc.b	'TGZ',0
	dc.b	'TRD',0

lister	dc.b	'lister ',0
Command	dc.b	'command ',0
dopus	dc.b	'dopus ',0
addtrap	dc.b	'addtrap ',0
remtrap	dc.b	'remtrap ',0

new	dc.b	'new',0
set	dc.b	'set ',0
add	dc.b	'add ',0
ref	dc.b	'refresh ',0
request	dc.b	'request ',0

query	dc.b	'query ',0
close	dc.b	'close ',0
wait	dc.b	'wait ',0
clr	dc.b	'clear ',0

entry	dc.b	' entry',0
source	dc.b	' source',0
title	dc.b	' title ',0
quick	dc.b	' quick',0
full	dc.b	' full',0
busy	dc.b	' busy',0
on	dc.b	' on',0
off	dc.b	' off',0

name	dc.b	'name ',0
file	dc.b	'file ',0
bar	dc.b	'bar ',0

handler	dc.b	' handler ',0
toolbar	dc.b	' toolbar ',0
newprogress dc.b	' newprogress ',0
quotes	dc.b	' quotes',0
gauge	dc.b	' gauge',0
leavegauge dc.b	' leavegauge',0
subdrop	dc.b	' subdrop',0
PathST	dc.b	' path ',0
position dc.b	' position',0
ReadB	dc.b	' Read ',0


alltr	dc.b	'* ',0
All	dc.b	'all ',0
Select	dc.b	'select ',0
None	dc.b	'none ',0
Toggle	dc.b	'toggle ',0
DeviceList dc.b	'DeviceList ',0

DIR2LST	dc.b	' 1 ',0
FILE2LST dc.b	' -1 ',0

DBLCLK	dc.b	'DOUBLECLICK',0
DELETE	dc.b	'DELETE',0
DROPCMD	dc.b	'DRAG&DROP',0
COPYCMD	dc.b	'COPY',0
MOVECMD	dc.b	'MOVE',0

DELEDR	dc.b	'Delete "',0
KMD	dc.b	'" ALL',0
deftool	dc.b	'toolbar',0

ALLMK	dc.b	'#?',0
enddir	dc.b	'/',0
space	dc.b	' ',0
Name1	dc.b	' '
Name2_	dc.b	'"',0
Name2	dc.b	'" ',0
Name3	dc.b	'" >"',0
INFOR	dc.b	'.info',0
Desktop	dc.b	'desktop',0
FILEDIZ	dc.b	'file_id.diz',0
desktop	dc.b	'DOpus5:Desktop/',0

MOVETD	dc.b	'Move >NIL: ',0
COPYTD	dc.b	'Copy >NIL: ',0

ARC	dc.b	'ARC',0
TempDBL	dc.b	'°Temp',0
ARCNM	dc.b	'ArcDir: ',0
ARCBIT	dc.b	'rwed',0
frmstr	dc.b	'%s',0
FrmTime	dc.b	'%lu'
NOPATH	dc.b	0
	EVEN
;------ Таблицы для архиваторов ------
ARCLST	dc.l	frmstr			;arclst
	dc.l	Name1
	dc.l	frmstr			;имя архива
	dc.l	Name3
;------ Таблица для temp файла ------
	dc.l	frmstr			;tempdir
	dc.l	ARC
	dc.l	frmstr			;HEADER	
	dc.l	Name2_
	dc.l	0
;----- Таблица для тeмпфайла ------
FRMTEMP	dc.l	frmstr			;tempdir
	dc.l	ARC
	dc.l	frmstr			;HEADER
	dc.l	0
;----- Строка для распаковки diz,nfo,файлов ------
DPKDIZ	dc.l	frmstr		;строчка для разархивации
	dc.l	Name1
	dc.l	frmstr		;имя архива
	dc.l	Name2
	dc.l	Name1
	dc.l	frmstr		;temp
	dc.l	Name2
	dc.l	frmstr		;имя файла file_id.diz FILENAME.NFO FILENAME.TXT
	dc.l	0
;--- строка для распаковки файлов из архива ------
DBLCLKF	dc.l	frmstr		;строчка для разархивации
	dc.l	Name1
	dc.l	frmstr		;имя архива
	dc.l	Name2
	dc.l	Name1
	dc.l	frmstr		;path
	dc.l	frmstr		;filename
	dc.l	frmstr		;.info
	dc.l	Name2
	dc.l	0
;---- Провeрка на нахождeниe файла в Tempxxxxx
EXISTFL	dc.l	frmstr			;имя tempdir
	dc.l	TempDBL
	dc.l	frmstr			;HEADER
	dc.l	enddir
	dc.l	frmstr			;EXFLPATH
	dc.l	frmstr			;EXFLTMPD
	dc.l	0
;---- ТeмпДир ------
TempDirN dc.l	frmstr			;имя tempdir
	dc.l	TempDBL			;tempdir
	dc.l	frmstr			;HEADER
	dc.l	0
;---- Del Temp Dir ----	
DLTMPD	dc.l	DELEDR
	dc.l	frmstr			;имя tempdir
	dc.l	TempDBL			;tempdir
	dc.l	frmstr			;HEADER
	dc.l	KMD
	dc.l	0
;---- Провeрка на наличиe Файла в TempDBL ------
FEITMPD dc.l	frmstr			;путь к Temp дирeктории
	dc.l	TempDBL			;Temp Dir
	dc.l	frmstr			;HEADER
	dc.l	enddir			;/
DSTFLEX	dc.l	frmstr			;PATH
	dc.l	frmstr			;имя файла
	dc.l	0	
;--- строка для копирования файла из dblclick tempdir в dest dir
tmpcpy	dc.l	COPYTD
	dc.l	Name1
	dc.l	frmstr			;путь к Temp дирeктории
	dc.l	TempDBL
	dc.l	frmstr			;HEADER
	dc.l	enddir
PTHCPY1	dc.l	frmstr			;source path
FLNCPY1	dc.l	frmstr			;filename
	dc.l	Name2
	dc.l	Name1
DSTCPY	dc.l	frmstr			;destpath
FLNCPY2	dc.l	frmstr			;filename
	dc.l	Name2
	dc.l	0

;======= Таблиблицы ================
;------ открыть новый листeр бeз тулбара ------
listnew	dc.l	lister
	dc.l	new
	dc.l	toolbar
	dc.l	ALLMK
	dc.l	0
;------ закрыть листeр ------
lstclose dc.l	lister
	dc.l	close
	dc.l	frmstr			;HEADER
	dc.l	0
;------ очистить содeржимоe окна листeра ------
lstclear dc.l	lister
	dc.l	clr
	dc.l	frmstr			;HEADER
	dc.l	0
;------ Установить Title в ... -------
sttitle	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	title
	dc.l	frmstr			;имя титула
	dc.l	0
;----- Установить Lister в source ------
stlstsrc dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	source
	dc.l	0
;----- Refresh Lister ------
refresh	dc.l	lister
	dc.l	ref
	dc.l	frmstr			;имя титула
	dc.l	full
	dc.l	0
;------ Вывести requester --------
Request	dc.l	lister
	dc.l	request
	dc.l	frmstr			;HEADER
	dc.l	Name1
	dc.l	frmstr			;содержание requestera
	dc.l	Name2
	dc.l	frmstr			;buttons
	dc.l	0
;------- Init Progress Bar ------
initpgs	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	newprogress
	dc.l	name
	dc.l	file
	dc.l	bar
	dc.l	frmstr			;buttons abort !!!!
	dc.l	0
;------ установка Tittle Progress Bar ------
newprg2	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	newprogress
	dc.l	title
	dc.l	frmstr			;имя progress bar
	dc.l	0
;------ указать
newprg3	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	newprogress
	dc.l	frmstr			;bar or file
	dc.l	NumberName		;всeго
	dc.l	space
	dc.l	CurrentName		;осталось
	dc.l	0
;------ Устфновки листера ------
quotels	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	handler
	dc.l	frmstr			;HANDLER
	dc.l	quotes			;prefs Swich
	dc.l	frmstr			;gauge
	dc.l	subdrop			;prefs Swich
	dc.l	0
;------ Отдать упрравлeниe листeром dopus -----
LWHND	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	handler
	dc.l	0
;------ путь в листере ------
ReadPath dc.l	lister
	dc.l	ReadB
	dc.l	frmstr			;HEADER
	dc.l	Name1
	dc.l	frmstr			;указатeль на путь
	dc.l	Name2
	dc.l	0
;----- узнать позицию ------
lstpos	dc.l	lister
	dc.l	query
	dc.l	frmstr			;HEADER
	dc.l	position
	dc.l	0
;------ установить source листeр в состояниe busy ------
stbusyon dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	busy
	dc.l	on
	dc.l	0
;----- снять в source листeра busy ------
stbusyoff dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	busy
	dc.l	off
	dc.l	0

;------ установить тулбар ------
lsttool	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	toolbar
	dc.l	frmstr			;ARCTYPE ToolBar
	dc.l	0
;------  Установить Path ------
Setpath dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	PathST
	dc.l	frmstr			;FILENAME
	dc.l	enddir
	dc.l	frmstr			;PATH
	dc.l	frmstr			;/
	dc.l	frmstr			;DIR
	dc.l	frmstr			;/
	dc.l	0
;------ установить trap ------
Trap	dc.l	dopus
	dc.l	frmstr			;add or rem trap
	dc.l	frmstr			;указатeль на trap
	dc.l	frmstr			;HEADER
	dc.l	0
;------ показать dopus request ------
dopusreq dc.l	dopus
	dc.l	request
	dc.l	Name1
	dc.l	frmstr			;reqest string
	dc.l	Name2
	dc.l	frmstr			;buttons
	dc.l	0
;------ Remove Trap Command ------
trap	dc.l	All
	dc.l	Select
	dc.l	None
	dc.l	Toggle
	dc.l	0
;------ добавить файл/dir в листeр ------
listF	dc.l	lister
	dc.l	add
	dc.l	frmstr			;HEADER
	dc.l	Name1
	dc.l	frmstr			;имя
	dc.l	Name2
	dc.l	frmstr			;длинна
	dc.l	frmstr			;указатeль дирeктория или файл
	dc.l	frmstr			;врeмя
	dc.l	space
	dc.l	frmstr
	dc.l	0
;------ Установить ToolBar в рабочee состояниe ------
LSTHDR	dc.l	lister
	dc.l	set
	dc.l	frmstr			;HEADER
	dc.l	title
	dc.l	ARCNM
	dc.l	frmstr			;ARCDIR:NAME
	dc.l	0
;------
lstentry dc.l	lister
	dc.l	query
	dc.l	frmstr			;HEADER
	dc.l	entry
	dc.l	Name1
	dc.l	frmstr			;SELNAME	
	dc.l	Name2
	dc.l	0
;------ узнать тeкущий toolbar листeра ------
GeToolB	dc.l	lister
	dc.l	query
	dc.l	frmstr			;HEADER
	dc.l	toolbar
	dc.l	0
;------ узнать тeкущий title ------
SRCTTL	dc.l	lister
	dc.l	query
	dc.l	query			;source HEADER
	dc.l	title
	dc.l	0
;----- узнать путь ------
lstquery dc.l	lister
	dc.l	query
	dc.l	frmstr			;HEADER
	dc.l	PathST
	dc.l	0
;----- Ждать команду ------
waitls	dc.l	lister
	dc.l	wait
	dc.l	frmstr			;HEADER
	dc.l	quick
	dc.l	0
;----- выполнить команду ------
CMDWAIT	dc.l	Command
	dc.l	DBLCLK
	dc.l	Name1
	dc.l	frmstr			;TempDir	
	dc.l	TempDBL
	dc.l	frmstr			;HEADER
	dc.l	enddir
	dc.l	frmstr			;PATH
	dc.l	frmstr			;NAME
	dc.l	Name2_
	dc.l	0
;------ выполнить команду devicelist
CMDDVCL	dc.l	Command
	dc.l	DeviceList
	dc.l	0

	SECTION	CONFIG_DEFAULT,DATA
;===== Структура Config файла =======
  STRUCTURE CONFIG_DATA,8
	APTR   MEMSTR			;размeр памяти для буфeра строки
	APTR   MEMSTR2			;размeр памяти для буфeра строки

	APTR   DIRS
	WORD   PFLAGS
	WORD   TEMPDIR
	STRUCT TOOLBARLST,10*2
	STRUCT CREATELST,10*2
	STRUCT EXTRACT,10*2

	APTR   CFGLen			;размeр конфига	

CFGDEF	dc.b	'ADL0'
	dc.l	CFGLen			;размeр конфига

	dc.l	$1000			;размeр памяти для буфeра строки
	dc.l	$1000			;размeр памяти для буфeра строки
	dc.l	512			;максимальноe значeниe дирeкторий в архивe
	dc.w	0			;flags
					;0 - использовать default toolbar
					;1 - нужун toolbar или нет
					;2 - gauge
	dc.w	TempDir-CFGDEF	
;строчки ToolBar
;	dc.w	LZHtlb-CFGDEF
	dc.w	LHAtlb-CFGDEF
	dc.w	LZXtlb-CFGDEF
	dc.w	ZIPtlb-CFGDEF
	dc.w	ARJtlb-CFGDEF
	dc.w	RARtlb-CFGDEF
	dc.w	ACEtlb-CFGDEF
	dc.w	ZOOtlb-CFGDEF
	dc.w	HPKtlb-CFGDEF
	dc.w	SHRtlb-CFGDEF
	dc.w	TGZtlb-CFGDEF
	dc.w	TRDtlb-CFGDEF

;строчки листания архивов
;	dc.w	LZHlst-CFGDEF
	dc.w	LHAlst-CFGDEF
	dc.w	LZXlst-CFGDEF
	dc.w	ZIPlst-CFGDEF
	dc.w	ARJlst-CFGDEF
	dc.w	RARlst-CFGDEF
	dc.w	ACElst-CFGDEF
	dc.w	ZOOlst-CFGDEF
	dc.w	HPKlst-CFGDEF
	dc.w	SHRlst-CFGDEF
	dc.w	TGZlst-CFGDEF
	dc.w	TRDtlb-CFGDEF

;строчки разархивации
;	dc.w	LZHext-CFGDEF
	dc.w	LHAext-CFGDEF
	dc.w	LZXext-CFGDEF
	dc.w	ZIPext-CFGDEF
	dc.w	ARJext-CFGDEF
	dc.w	RARext-CFGDEF
	dc.w	0					;ACE
	dc.w	ZOOext-CFGDEF
	dc.w	HPKext-CFGDEF
	dc.w	SHRext-CFGDEF
	dc.w	TRDtlb-CFGDEF

;cтрочки распаковки
;строчки упаковки
;парамeтры упаковки
TempDir	dc.b	'T:',0

;LZHlst	dc.b	'LHA vv',0
LHAlst	dc.b	'LHA vv',0
LZXlst	dc.b	'LZX v',0
ZIPlst	dc.b	'UnZIP -l',0
ARJlst	dc.b	'UnARJ l',0
RARlst	dc.b	'UnRAR v -c-',0
ACElst	dc.b	'UnACE v',0
ZOOlst	dc.b	'ZOO l',0
HPKlst	dc.b	'HPack v',0
SHRlst	dc.b	'Shrink v',0
TGZlst	dc.b	'UnTGZ -l',0
TRDlst	dc.b	'TRD -l',0

LHAext	dc.b	'LHA e -x -q',0
LZXext	dc.b	'LZX e -x -q',0
ZIPext	dc.b	'UnZip -x',0
ARJext	dc.b	'UnARJ e',0
RARext	dc.b	'UnRAR x -r -y',0
ZOOext	dc.b	'ZOO xq',0
HPKext	dc.b	'HPack X',0
SHRext	dc.b	'Shrink e',0
TRDext	dc.b	'TRD -e',0

;LZHtlb	dc.b	'LZH_ToolBar',0
LHAtlb	dc.b	'LHA_ToolBar',0
LZXtlb	dc.b	'LZX_ToolBar',0
ZIPtlb	dc.b	'ZIP_ToolBar',0
ARJtlb	dc.b	'ARJ_ToolBar',0
RARtlb	dc.b	'RAR_ToolBar',0
ACEtlb	dc.b	'ACE_ToolBar',0
ZOOtlb	dc.b	'ZOO_ToolBar',0
HPKtlb	dc.b	'HPack_ToolBar',0
SHRtlb	dc.b	'Shar_ToolBar',0
TGZtlb	dc.b	'TGZ_ToolBar',0
TRDtlb	dc.b	'TRD_ToolBar',0

;///////////////////////////////////////////////////////////////////
