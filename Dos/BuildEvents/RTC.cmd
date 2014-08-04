@echo off

call SCMCredentials.cmd

set SCM_URI=https://jtsrv.uk.hibm.hsbc:9093/jazz
set SCM_NICKNAME=jazzhost
set DEV_TAG=Dev

echo Login...
scm login -r %SCM_URI% -u %SCM_USER% -P %SCM_PASS% -n %SCM_NICKNAME%
echo ('rout' to logout)

rem RTC log out
doskey rout=scm logout -r %SCM_NICKNAME%
