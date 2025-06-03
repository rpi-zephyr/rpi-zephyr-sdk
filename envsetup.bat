@echo off
REM
REM Copyright (c) 2025 Dylan(JunKi) Hong
REM
REM SPDX-License-Identifier: Apache-2.0
REM

REM Config
set "PYTHON_VERSION=3.10"
set "ZEPHYR_RTOS=zephyr"
set "MANIFEST_URL=git@github.com:rpi-zephyr/zephyr.git"

REM Set script path
set SCRIPT_PATH=%~dp0
set SCRIPT_PATH=%SCRIPT_PATH:~0,-1%

REM Get python path (call helper batch script)
for /f "delims=" %%i in ('call scripts\get_python_path.bat 3.10') do set "PYTHON_PATH=%%i"
if "%PYTHON_PATH%"=="" (
    echo No python version higher than %PYTHON_VERSION% found >&2
    exit /b 1
)

REM Check if virtual environment already exists
if not exist "%SCRIPT_PATH%\.venv" (
    echo Virtual environment not found at '%SCRIPT_PATH%\.venv'. Creating...
    echo "PYTHON_PATH: %PYTHON_PATH%"
    "%PYTHON_PATH%" -m venv "%SCRIPT_PATH%\.venv"
    if errorlevel 1 (
        echo Failed to create virtual environment >&2
        exit /b 1
    )
)

REM Activate virtual environment
call "%SCRIPT_PATH%\.venv\Scripts\activate.bat"

REM Install Python dependencies
call "%SCRIPT_PATH%\scripts\pip_install.bat" cmake
call "%SCRIPT_PATH%\scripts\pip_install.bat" west

REM Initialize west and fetch Zephyr if not present
if not exist "%SCRIPT_PATH%\%ZEPHYR_RTOS%" (
    rmdir /s /q "%SCRIPT_PATH%\.west"
    west init -m %MANIFEST_URL%
    west update
    west zephyr-export
    pip install -r zephyr\scripts\requirements.txt
)

REM Read SDK version file
set SDK_VERSION_FILE=%SCRIPT_PATH%\%ZEPHYR_RTOS%\SDK_VERSION
set /p SDK_VERSION=<"%SDK_VERSION_FILE%"

REM Check SDK installation
if not exist "%USERPROFILE%\zephyr-sdk-%SDK_VERSION%" (
    pushd "%SCRIPT_PATH%\%ZEPHYR_RTOS%"
    west sdk install
    popd
)
