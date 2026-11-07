#!/bin/bash
#
# WhiteSU (legacy branch) for 4.14.
# Manual syscall hooks must already be in the kernel source.

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

curl -LSs "https://raw.githubusercontent.com/White-Society/WhiteSU/dev/kernel/setup.sh" | bash -s legacy
git add . && git commit -am "drivers: KernelSU"
WSU_DIR="drivers/kernelsu"
KSU_git_ver=$(cd $WSU_DIR_DIR && git rev-list --count HEAD)
KSU_ver=$KSU_git_ver

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-WhiteSU${KSU_ver}\"/" "${defconfig_file}"
echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"
echo -e " \nincludes WhiteSU ${KSU_ver}" >> banner_append
echo -e " \nincludes NoMount v2.2.0" >> banner_append
