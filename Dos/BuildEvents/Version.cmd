@echo off

rem This file is used by Visual Studio to improve build time performance by preventing from using the slow RTC command line tool
rem Use 'Deploy.cmd' to make a clean release to deliver in production environment

set MAJOR_VER=1
set MINOR_VER=1
set BUILD_VER=0
set PRIVA_VER=%USERNAME%
set PRIVATEBUILD=1
set VER_PRIVATEBUILD_STR="Build by %USERNAME%"
