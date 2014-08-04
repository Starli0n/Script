@echo off

rem Description
rem -----------
rem Delete version.h
rem Delete VERSION
rem


echo.
echo %~n0 Step...
echo.

if "%~1"=="" goto MISS_PARAM

set ProjectDir=%~1

if exist %ProjectDir%version.h (
	echo Delete .\version.h
	del /f %ProjectDir%version.h
)

if exist %ProjectDir%VERSION (
	echo Delete .\VERSION
	del /f %ProjectDir%VERSION
)

echo.
echo %~n0 Done.
echo.
goto :eof

:MISS_PARAM
echo Miss parameter: %~n0 !!!
echo.
exit 1
goto :eof
