#!/bin/bash
# WhiteSU (legacy) for 4.14; manual hooks must already be in the kernel source
export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

curl -LSs "https://raw.githubusercontent.com/White-Society/WhiteSU/dev/kernel/setup.sh" | bash -s legacy
git add . && git commit -am "drivers: WhiteSU"
KSU_ver=$(cd drivers/kernelsu && git rev-list --count HEAD)

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-wsu${KSU_ver}\"/" "${defconfig_file}"
grep 'CONFIG_LOCALVERSION=' "${defconfig_file}"
echo -e " \nincludes WhiteSU (legacy), ver ${KSU_ver}" >> banner_append
