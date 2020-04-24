#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-vice"
rp_module_desc="C64 / VIC20 / Plus4 emulator - port of VICE for libretro"
rp_module_help="ROM Extensions: .crt .d64 .g64 .prg .t64 .tap .x64 .zip .vsf\n\nCopy your games to $romdir/c64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vice-libretro/master/vice/COPYING"
rp_module_section="exp"
rp_module_flags=""

function _get_targets_lr-vice() {
    echo x64 xplus4 xvic
}

function sources_lr-vice() {
    gitPullOrClone "$md_build" https://github.com/libretro/vice-libretro.git
}

function build_lr-vice() {
    mkdir -p "$md_build/cores"
    local target
    for target in $(_get_targets_lr-vice); do
        make clean
        make EMUTYPE="$target"
        cp "$md_build/vice_${target}_libretro.so" "cores/"
        md_ret_require+=("$md_build/cores/vice_${target}_libretro.so")
    done
}

function install_lr-vice() {
    md_ret_files=(
        'vice/data'
        'vice/COPYING'
    )
    local target
    for target in $(_get_targets_lr-vice); do
        md_ret_files+=("cores/vice_${target}_libretro.so")
    done
}

function configure_lr-vice() {
    mkRomDir "c64"
    ensureSystemretroconfig "c64"

    cp -R "$md_inst/data" "$biosdir"
    chown -R $user:$user "$biosdir/data"

    local target
    local name
    for target in $(_get_targets_lr-vice); do
        if [[ "$target" == "x64" ]]; then
            name=""
        else
            name="-${target}"
        fi
        addEmulator 1 "$md_id${name}" "c64" "$md_inst/vice_${target}_libretro.so"
    done
    addSystem "c64"
}
