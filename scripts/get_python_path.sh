#
# Copyright (c) 2025 Dylan(JunKi) Hong
#
# SPDX-License-Identifier: Apache-2.0
#
get_higher_python_paths() {
    local target_version="$1"
    local target_major=${target_version%%.*}
    local target_minor=${target_version##*.}

    # Pattern to match python3 or python-3.12 like pkg-config names
    local pattern='^python3?$|^python-?[0-9]+\.[0-9]+$'

    for pc in $(pkg-config --list-all | awk '{print $1}' | grep -E "$pattern"); do
        local version_str=""
        if [[ "$pc" == "python3" ]]; then
            version_str=$(pkg-config --modversion python3 2>/dev/null)
        else
            version_str="${pc#python-}"
        fi

        local pc_major=${version_str%%.*}
        local pc_minor=${version_str##*.}

        # Compare major and minor version
        if [[ "$pc_major" -gt "$target_major" ]] || { [[ "$pc_major" -eq "$target_major" ]] && [[ "$pc_minor" -gt "$target_minor" ]]; }; then
            # Get python binary path
            local python_bin=$(pkg-config --variable=exec_prefix "$pc" 2>/dev/null)/bin/python${version_str}
            if [[ -x "$python_bin" ]]; then
                echo "$python_bin"
                return 0   # return immediately after finding the first valid path
            fi
        fi
    done

    return 1  # no higher version found
}
