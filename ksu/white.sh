#!/bin/bash
#
# WhiteSU (legacy branch) for 4.14.
# Manual syscall hooks must already be in the kernel source.

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/env"

curl -LSs "https://raw.githubusercontent.com/White-Society/WhiteSU/dev/kernel/setup.sh" | bash -s legacy
git add . && git commit -am "drivers: WhiteSU"

KSU_ver=$(cd drivers/kernelsu && git rev-list --count HEAD 2>/dev/null || echo 0)

# make sure both options are in the defconfig (safe to repeat)
grep -q '^CONFIG_KSU=y' "${defconfig_file}" || echo "CONFIG_KSU=y" >> "${defconfig_file}"
grep -q '^CONFIG_KSU_MANUAL_HOOK=y' "${defconfig_file}" || echo "CONFIG_KSU_MANUAL_HOOK=y" >> "${defconfig_file}"

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-wsu${KSU_ver}\"/" "${defconfig_file}"
grep 'CONFIG_LOCALVERSION=' "${defconfig_file}"
grep 'CONFIG_KSU' "${defconfig_file}"

echo -e " \nincludes WhiteSU (legacy), ver ${KSU_ver}" >> banner_append
