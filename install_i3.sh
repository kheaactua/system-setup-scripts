#!/bin/bash

function install_i3()
{
    add-apt-repository -y ppa:kgilmer/speed-ricer
    apt-get update
    apt install -qy i3lock feh i3status
    # apt install -qy i3-gaps i3lock feh

    ./install_check.sh
    ./install_rofi.sh
    ./install_i3_gaps.sh
    ./install_i3lock_color.sh
    ./install_i3lock_fancy_rapid.sh
    ./install_rofi-pass.sh
}

install_i3

# vim: ts=2 sw=2 sts=0 expandtab :
