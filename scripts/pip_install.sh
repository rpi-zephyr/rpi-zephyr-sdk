#
# Copyright (c) 2025 Dylan(JunKi) Hong
#
# SPDX-License-Identifier: Apache-2.0
#
pip_install() {
    if ! "python" -m pip show "$1" > /dev/null 2>&1; then
        echo "'"$1"' is not installed. Installing via pip..."
        
        "python" -m pip install --upgrade pip setuptools wheel
        "python" -m pip install "$1" || {
            echo "Failed to install '"$1"'" >&2
            exit 1
        }
    fi
}