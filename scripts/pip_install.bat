@echo off
REM
REM Copyright (c) 2025 Dylan(JunKi) Hong
REM
REM SPDX-License-Identifier: Apache-2.0
REM

setlocal
set "PACKAGE=%~1"

REM Check if the package is already installed
python -m pip show %PACKAGE% >nul 2>&1
if errorlevel 1 (
    echo '%PACKAGE%' is not installed. Installing via pip...

    python -m pip install --upgrade pip setuptools wheel
    if errorlevel 1 (
        echo Failed to upgrade pip and build tools >&2
        exit /b 1
    )

    python -m pip install %PACKAGE%
    if errorlevel 1 (
        echo Failed to install '%PACKAGE%' >&2
        exit /b 1
    )
)
endlocal
