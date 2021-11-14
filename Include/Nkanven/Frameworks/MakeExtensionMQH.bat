@echo off

:
:	Get the current date and time in a format to show in the files
:
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,2%

:
:	Make sure there is an Extensions folder here
:
if not exist Extensions\ goto :quit

:
:	Move into the extensions folder to start
:
cd Extensions

:
:	Remove any existing mqh files
:
del *.mqh

:
:	Step through the directories here and build up mqh files for each
:
for /D %%f in (*) do (
	call :makemqh %%f
)

:
: Build the AllExtensions file
:
call :makemqh .

:
: Move back up to the frameworks folder
:
cd ..

:
: Step through the framework files and build up the new framework.mqh
:
set framework_version=
for /f "tokens=*" %%f in ('dir /b /a:d /o:n "Framework_*"') do (
	set framework_version=%%f
)
call :makeframework1 %framework_version%


goto :quit

:makeframework1

set file=Framework.mqh

echo /* > %file%
echo  	Framework.mqh >> %file%
echo. 	 >> %file%
echo    Copyright 2013-2020, Orchard Forex >> %file%
echo    https://www.orchardforex.com >> %file%
echo. >> %file%
echo. >> %file%
echo */ >> %file%
echo. >> %file%
echo // >> %file%
echo //	The only purpose of this mqh file is to provide a single >> %file%
echo //		point to change the current framework version >> %file%
echo // >> %file%
echo //	If you place an include to this file in your code you >> %file%
echo //		will get the version framework defined in this file >> %file%
echo //		unless your code has already included another >> %file%
echo //		framework file >> %file%
echo. >> %file%
echo #ifndef	_FRAMEWORK_VERSION_ >> %file%
echo     #include "%1/Framework.mqh" >> %file%
echo #endif >> %file%

goto :eof

:makemqh

set mcurrent=%cd%
set mpath1=%~f1
for %%f in ("%mpath1%") do set mpath=%%~nxf
set msub=%mpath%/
if "%mcurrent%"=="%mpath1%" set msub=
set mfile=All%mpath%.mqh

echo /* > %mfile%
echo  	All%mn2%.mqh >> %mfile%
echo.  >> %mfile%
echo 	Copyright 2013-2020, Orchard Forex >> %mfile%
echo 	https://www.orchardforex.com >> %mfile%
echo.  >> %mfile%
echo 	Auto Generated at %ldt% >> %mfile%
echo.  >> %mfile%
echo */ >> %mfile%
echo.  >> %mfile%
echo // >> %mfile%
echo //	Extension %mn2% go here >> %mfile%
echo // >> %mfile%

for %%f in (%1\*.mqh) do (
	if not "%%~nxf"=="%mfile%" echo #include "%msub%%%~nxf" >> %mfile%
)
echo Built include file %mfile%

goto :eof

:quit
echo Finished
pause
goto :eof