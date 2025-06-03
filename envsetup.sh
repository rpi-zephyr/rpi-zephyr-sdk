#
# Copyright (c) 2025 Dylan(JunKi) Hong
#
# SPDX-License-Identifier: Apache-2.0
#

# Config
python_version="3.10"

# Zephry RTOS
MANIFEST_URL=git@github.com:rpi-zephyr/zephyr.git
zephyr_rtos=zephyr

# Check the script execution path (relative path)
if [ -n "${ZSH_VERSION:-}" ]; then
    script_dir="${(%):-%N}"
else
    script_dir="${BASH_SOURCE[0]}"
fi

# MINGW Environment Check
if uname | grep -q "MINGW"; then
    pwd_opt="-W"
else
    pwd_opt=""
fi

# Check the absolute path of the script 
script_path=$( builtin cd "$( dirname "$dir" )" > /dev/null && pwd ${pwd_opt})
# Free temporary variables
unset script_dir
unset pwd_opt

# get python path
source ${script_path}/scripts/get_python_path.sh
python_path=$(get_higher_python_paths ${python_version})
if [[ -z "$python_path" ]]; then
    echo "No python version higher than ${python_version} found" >&2
    exit 1
fi
# Free temporary variables
unset python_version

# Check if virtual environment already exists
if [[ ! -d "${script_path}/.venv" ]]; then
    echo "Virtual environment not found at '${script_path}/.venv'. Creating..."

    # Create venv
    ${python_path} -m venv "${script_path}/.venv" || {
        echo "Failed to create virtual environment..." >&2
        exit 1
    }
fi
# Free temporary variables
unset python_path

# Activate the virtual environment
source "${script_path}/.venv/bin/activate"

source ${script_path}/scripts/pip_install.sh
# Check if 'cmake' is already installed
pip_install cmake
# Check if 'west' is already installed
pip_install west

# Check if 'zephyr' is already installed
if [[ ! -d "${script_path}/${zephyr_rtos}" ]]; then
    rm -rf ${script_path}/.west
    west init -m ${MANIFEST_URL}
    west update
    west zephyr-export
    pip install -r zephyr/scripts/requirements.txt
fi

# Check if 'sdk' is already installed
SDK_VERSION=$(cat ${script_path}/${zephyr_rtos}/SDK_VERSION)
if [[ ! -d "/home/${USER}/zephyr-sdk-${SDK_VERSION}" ]]; then
    pushd ${script_path}/${zephyr_rtos}
    west sdk install 
    popd
fi
