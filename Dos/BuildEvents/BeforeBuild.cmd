@echo off

rem Description
rem -----------
rem Use Version.cmd to generate version.h if not exists
rem If it is the case the release will automatically tag as private
rem


echo.
echo %~n0 Step...
echo.

if "%~1"=="" goto MISS_PARAM
if "%~2"=="" goto MISS_PARAM

set ProjectDir=%~1
set ConfigurationName=%~2

if not exist "%ProjectDir%version.h" call :TAG_VERSION
type %ProjectDir%VERSION
echo.

echo Build VERSIONINFO.rc (%ConfigurationName%)
if "%ConfigurationName%" == "Debug" (
	rc /d DEBUG VERSIONINFO.rc
) else (
	rc VERSIONINFO.rc
)
echo.

echo %~n0 Done.
echo.
goto :eof

:TAG_VERSION
echo Generate version.h

if "%ConfigurationName%" == "SCMRelease" (
	call %ProjectDir%SCMVersion.cmd
) else (
	call %ProjectDir%Version.cmd
)

set VERSION=%MAJOR_VER%.%MINOR_VER%.%BUILD_VER%.%PRIVA_VER%
echo %VERSION%>%ProjectDir%VERSION

echo // Generated file>>"%ProjectDir%version.h"
echo #define MAJOR_VER ^%MAJOR_VER%>>"%ProjectDir%version.h"
echo #define MINOR_VER ^%MINOR_VER%>>"%ProjectDir%version.h"
echo #define BUILD_VER ^%BUILD_VER%>>"%ProjectDir%version.h"
echo #define PRIVA_VER ^%PRIVA_VER%>>"%ProjectDir%version.h"
if "%PRIVATEBUILD%"=="1" (
	echo #define PRIVATEBUILD ^%PRIVATEBUILD%>>"%ProjectDir%version.h"
)
echo #define VER_PRIVATEBUILD_STR %VER_PRIVATEBUILD_STR%>>"%ProjectDir%version.h"
echo.
goto :eof

:MISS_PARAM
echo Miss parameter: %~n0 !!!
echo.
exit 1
