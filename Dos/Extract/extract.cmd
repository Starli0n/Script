@echo off

if "%~1"=="" goto usage
if "%~2"=="" goto usage
if "%~3"=="" goto usage
if "%~4"=="" goto usage
set src=%~1
set dst=%~2
set list_file=%~3
set log_file=%~4


if not exist "%src%" (
	echo Not Exist - source: %src%
	goto :eof
)
if not exist "%list_file%" (
	echo Not Exist - list_file: %list_file%
	goto :eof
)

goto main


:usage
echo +--------------+
echo ^|              ^|
echo ^|   Extract    ^|
echo ^|              ^|
echo +--------------+
echo.
echo Parameters:
echo.
echo   1- src       : %~1
echo   2- dst       : %~2
echo   3- list_file : %~3
echo   4- log_file  : %~4
echo.
echo Usage:
echo.
echo   Extract a list of files (%%3) from a source directory (%%1) to a destination directory (%%2).
echo   The list of files (%%3) is relative to the source directory (%%1) which defined the root path of the files.
echo   The tool extracts the arborescence of the list of files (%%3) to the destination directory (%%2).
echo   A log file (%%4) lists files that are listed into the list of files (%%3) but not found in the source directory (%%1).
echo   The destination directory (%%2) is not necessarily empty but the tool will erase existing files.
goto :eof


:main

if not exist "%dst%" mkdir "%dst%"
if exist "%log_file%" del -f "%log_file%"

for /f "tokens=*" %%i in ('type "%list_file%"') do (
	if exist "%src%\%%i" (
		rem Force destination as a file not a directory
		echo f | xcopy /Y "%src%\%%i" "%dst%\%%i">nul
	) else (
        echo         Not Exist: %src%\%%i
		echo Not Exist: %src%\%%i>> "%log_file%"
	)
)
