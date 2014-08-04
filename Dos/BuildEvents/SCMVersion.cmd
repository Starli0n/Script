@echo off

rem Description
rem -----------
rem Set some environment variables
rem
rem %STREAM%: Stream name used by the workspace
rem %WORKSPACE%: Workspace name
rem %UUID%: Get last changeset UUID
rem %VERSION%: %MAJOR_VER%.%MINOR_VER%.%BUILD_VER%.%PRIVA_VER%
rem %MAJOR_VER%: Defined outside
rem %MINOR_VER%: Defined outside
rem %BUILD_VER%: Based on the number of commit inside the Component (starting at 0)
rem %PRIVA_VER%: 0 for a clean release or %USERNAME% for a private version
rem %PRIVATEBUILD%: 0 for a clean workspace or 1 for a workspace including some change
rem

rem Requirement
rem -----------
rem %SCM_URI%: Path to scm repository uri
rem %COMPONENT%: Name of the actual component
rem SCMCredentials.cmd: Defines user and password for scm connection (see below)

rem SCMCredentials.cmd
rem ------------------
rem @echo off
rem set SCM_USER=%USERNAME%
rem set SCM_PASS=xxxxxxxxxx


goto MAIN

:PARAM
call Version.cmd
if ERRORLEVEL 1 goto VERSION_MAJ_FAILED
call "SCMCredentials.cmd"
if ERRORLEVEL 1 goto CREDENTIALS_FAILED
set SCM_URI=%SCM_URI%
set SCM_NICKNAME=jazzhost
goto :eof

:LOGIN
echo LOGIN
if "%SCM_USER%"=="" (
	scm login -r %SCM_URI% -n %SCM_NICKNAME%
) ELSE (
	scm login -r %SCM_URI% -u %SCM_USER% -P %SCM_PASS% -n %SCM_NICKNAME%
)
echo.
goto :eof

:STATUS
echo STATUS
set TMP_STATUS=%TEMP%\%COMPONENT%Status
scm status>%TMP_STATUS%
if ERRORLEVEL 1 goto VERSION_FAILED
rem Get "Workspace:" line from scm status
for /F "tokens=*" %%a in ('type "%TMP_STATUS%" ^| find "Workspace:"') do set LINE=%%a
rem Get WORKSPACE and STREAM from "Workspace:" line (uses " as delims)
for /F tokens^=2^,4^ delims^=^" %%a in ('echo "%LINE%"') do (
	rem "
	set WORKSPACE=%%a
	set STREAM=%%b
)
rem Set PRIVATEBUILD=1 if there are some change in the workspace (ie: Unresolved files)
rem Count number of line of the command (3 first lines: Workspace, Component, Baseline)
for /F "tokens=*" %%a in ('type %TMP_STATUS% ^| find /v /c ""') do set COUNT=%%a
if "%COUNT%"=="3" (
	rem Workspace is clean
	set PRIVATEBUILD=0
) else (
	rem Workspace has some change
	set PRIVATEBUILD=1
)
rem Delete temporary file
erase /F /Q %TMP_STATUS%
echo .done
echo.
goto :eof

:HISTORY
echo HISTORY
rem Get UUID of last changeset
for /F "tokens=*" %%a in ('scm --show-uuid y history -m 1 ^| find "("') do set LAST_COMMIT=%%a
set UUID=%LAST_COMMIT:~6,23%
rem Get last commit ID (starting at 0)
for /F "tokens=*" %%a in ('scm history -m 1000000 ^| find /v /c ""') do set BUILD_VER=%%a
rem Remove header and starting at 0
set /A BUILD_VER=%BUILD_VER% - 2
echo .done
echo.
goto :eof

:SHOW_VERSION
echo SHOW_VERSION
if "%PRIVATEBUILD%"=="0" set PRIVA_VER=0
set VERSION=%MAJOR_VER%.%MINOR_VER%.%BUILD_VER%.%PRIVA_VER%
echo STREAM=%STREAM%
echo WORKSPACE=%WORKSPACE%
echo UUID=%UUID%
echo VERSION=%VERSION%
echo MAJOR_VER=%MAJOR_VER%
echo MINOR_VER=%MINOR_VER%
echo BUILD_VER=%BUILD_VER%
echo PRIVA_VER=%PRIVA_VER%
echo PRIVATEBUILD=%PRIVATEBUILD%
echo.
goto :eof

:LOGOUT
echo LOGOUT
scm logout -r %SCM_NICKNAME%
echo.
goto :eof

:TEST_VERSION
echo TEST_VERSION
for /F "tokens=*" %%a in ('echo %VERSION% ^| find /c "~"') do set VERSION_KO=%%a
if "%VERSION_KO%"=="1" goto VERSION_FAILED
echo .done
echo.
goto :eof

:MAIN
call :PARAM
call :LOGIN
call :STATUS
call :HISTORY
call :SHOW_VERSION
call :LOGOUT
call :TEST_VERSION
goto :eof

:VERSION_MAJ_FAILED
echo Failed to open Version.cmd
echo.
pause
exit 1

:CREDENTIALS_FAILED
echo Please create 'SCMCredentials.cmd' with your credentials
echo.
echo set SCM_USER=%USERNAME%
echo set SCM_PASS=xxxxxxxx
echo.
pause
exit 2

:VERSION_FAILED
echo Failed to retrieve version from RTC !!!
echo (Please close RTC first)
echo.
pause
exit 3
