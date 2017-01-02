#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-scummvm"
rp_module_desc="ScummVM - port for libretro"
rp_module_help="Copy your ScummVM games to $romdir/scummvm"
rp_module_licence="https://raw.githubusercontent.com/libretro/scummvm/master/COPYING"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-scummvm() {
    getDepends libsdl1.2-dev libjpeg8-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libmad0-dev libpng12-dev libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev zlib1g-dev
}

function sources_lr-scummvm() {
    gitPullOrClone "$md_build" https://github.com/libretro/scummvm.git
}

function build_lr-scummvm() {
    make -C backends/platform/libretro/build clean
    make -C backends/platform/libretro/build
    md_ret_require="$md_build/backends/platform/libretro/build/scummvm_libretro.so"
}

function install_lr-scummvm() {
    md_ret_files=(
        'COPYING'
        'AUTHORS'
        'LIBRETRO_CMDLINE'
        'backends/platform/libretro/build/scummvm_libretro.so'
    )
}

function configure_lr-scummvm() {
    mkRomDir "scummvm"
    ensureSystemretroconfig "scummvm"

    addEmulator 1 "$md_id" "scummvm" "$md_inst/scummvm_libretro.so"
    addSystem "scummvm"
}
