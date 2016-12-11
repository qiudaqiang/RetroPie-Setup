#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="neocd"
rp_module_desc="Neo Geo CD emulator"
rp_module_help="You need to copy bios neocd.bin to $romdir/BIOS."
rp_module_section="exp"
rp_module_flags="!mali !64bit"

function _cdemu_neocd() {
    getDepends bzip2 debhelper devscripts intltool liblzma-dev gtk-doc-tools gobject-introspection libgirepository1.0-dev libao-dev libsndfile1-dev libsamplerate0-dev raspberrypi-kernel-headers dbus-x11
    if [[ "$md_mode" == "install" ]] && ! hasPackage cdemu-client; then
        mkdir -p "$md_build"
        local file
        for file in libmirage-3.0.5 vhba-module-20161009 cdemu-daemon-3.0.5 cdemu-client-3.0.3 ; do
            cd "$md_build"
            wget -O- -q "$__archive_url/cdemu/$file.tar.bz2" | tar -xvj
            cd "$md_build/$file"
            dpkg-buildpackage -b -uc -tc
            if [[ "$file" == "libmirage-3.0.5" ]]; then
                dpkg -i ../libmirage10-dev*.deb ../libmirage10_*.deb
            fi
        done
        cd ..
        rm -rf "$file"
        dpkg -i vhba-dkms_*.deb cdemu-daemon_*.deb cdemu-client_*.deb
        rm -rf *.deb *.changes
    fi
}

function depends_neocd() {
    getDepends libsdl1.2-dev
    _cdemu_neocd
}

function sources_neocd() {
    gitPullOrClone "$md_build/neocdsdl" https://github.com/joolswills/neocdsdl.git
}

function build_neocd() {
    cd "neocdsdl"
    make clean
    make linux -j1
    md_ret_require="$md_build/neocdsdl/neocd"
}

function install_neocd() {
    cp "$md_build/neocdsdl/memcard.bin" "$md_inst/memcard.bin.dist"
    md_ret_files=(
        'neocdsdl/compile.txt'
        'neocdsdl/loading.bmp'
        'neocdsdl/neocd'
        'neocdsdl/patch.prg'
        'neocdsdl/README-SDL.txt'
        'neocdsdl/readme.txt'
        'neocdsdl/startup.bin'
        'neocdsdl/whatsnew.txt'
    )
}

function remove_neocd() {
    dpkg --remove vhba-dkms cdemu-daemon cdemu-client libmirage10-dev 
}

function configure_neocd() {
    mkRomDir "neogeocd"

    copyDefaultConfig "$md_inst/memcard.bin.dist" "$md_conf_root/memcard.bin"
    moveConfigFile "$md_inst/neocd.bin" "$biosdir/neocd.bin"
    moveConfigFile "$md_inst/memcard.bin" "$md_conf_root/memcard.bin"

    cat > "$md_inst/neocd.sh" << _EOF_
#!/bin/bash
cue="\$1"
eval `dbus-launch --auto-syntax`
cdemu load 0 "\$cue" 
pushd "$md_inst"
"$md_inst/neocd"
popd
cdemu unload 0
_EOF_
    chmod +x "$md_inst/neocd.sh"

    addSystem 1 "$md_id" "neogeocd" "$md_inst/neocd.sh %ROM%"
}
