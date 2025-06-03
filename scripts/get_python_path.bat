@echo off
REM
REM Copyright (c) 2025 Dylan(JunKi) Hong
REM
REM SPDX-License-Identifier: Apache-2.0
REM
setlocal EnableDelayedExpansion

REM Input: target version, like 3.10
set "TARGET_VERSION=%1"
for /f "tokens=1,2 delims=." %%a in ("%TARGET_VERSION%") do (
    set /a TARGET_MAJOR=%%a
    set /a TARGET_MINOR=%%b
)

REM Try to get current python version
for /f %%v in ('python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"') do (
    set "VERSION=%%v"
)

for /f "tokens=1,2 delims=." %%a in ("!VERSION!") do (
    set /a MAJOR=%%a
    set /a MINOR=%%b
)

REM Compare versions
if !MAJOR! GTR !TARGET_MAJOR! (
    for %%P in (python.exe) do @echo %%~f$PATH:P
    exit /b 0
) else if !MAJOR! EQU !TARGET_MAJOR! if !MINOR! GTR !TARGET_MINOR! (
    for %%P in (python.exe) do @echo %%~f$PATH:P
    exit /b 0
)

REM Not found
echo No higher Python version found
exit /b 1
