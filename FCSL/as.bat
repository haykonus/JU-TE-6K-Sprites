@echo off

set file=%1
set option=
set binfile=

if "%1"=="" goto end	
if "%2"=="" goto end

if "%2"=="ROM" (
	set binfile="%file%_3000H.bin"
	set option="-D SP_VERSION=0"
	goto run
)
if "%2"=="RAM" (
	set binfile="%file%_8300H.bin"
	set option="-D SP_VERSION=1"
	goto run
)

:end
echo "use: as <file> <ROM|RAM>
exit /B

:run
echo -------- %file% -----------

set bin=..\..\..\..\..\as\bin
%bin%\asw.exe -L %file%.asm -a "%option%"
%bin%\p2bin.exe -r $-$ "%file%.p" "%binfile%"
%bin%\plist.exe "%file%.p" 
del %file%.inc
del %file%.p
del %file%.lst



