#!/bin/bash

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/env"

[ -z "$NJOBS" ] && export NJOBS=$(nproc --all) || :

pack() {
  # work on a copy so the AnyKernel3 folder in the kernel tree stays untouched
  rm -rf "${zipper}"
  cp -a "${maindir}/${AK3_DIR}" "${zipper}" || exit 1
  cd "${zipper}" || exit 1

  cp -af "${out_image}" "${zipper}/Image"

  if [ -e "${maindir}/banner_append" ]; then
    cat "${maindir}/banner_append" >> "${zipper}/banner"
  fi

  zip -r9 "$1" . -x '.git/*' '*.md' '*placeholder'

  rm -f "${maindir}/banner_append" "${out_image}"
  cd "${maindir}"
}

FAILED=0

for toolchain in $1; do

  bash -x "${outside}/toolchains/${toolchain}.sh" setup

  BUILD_START=$(date +"%s")
  export CUR_TOOLCHAIN="${toolchain}"

  if bash -x "${outside}/toolchains/${toolchain}.sh" build "${defconfig}" && [ -e "${out_image}" ]; then
    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))
    pack "${zip_name}"
    echo "build succeeded in $((DIFF / 60))m, $((DIFF % 60))s" > "${zip_name}.info"
    echo "md5: <code>$(md5sum "${zip_name}" | cut -d' ' -f1)</code>" >> "${zip_name}.info"
    echo "compiler: $(cat ${toolchain}.info)" >> "${zip_name}.info"

    echo "build succeeded in $((DIFF / 60))m, $((DIFF % 60))s" > "${toolchain}.log.info"
    echo "ak3 zip file: <code>${zip_name}</code>" >> "${toolchain}.log.info"
    echo "compiler: $(cat ${toolchain}.info)" >> "${toolchain}.log.info"
  else
    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))
    echo "build failed in $((DIFF / 60))m, $((DIFF % 60))s" > "${toolchain}.log.info"
    echo "compiler: $(cat ${toolchain}.info 2>/dev/null)" >> "${toolchain}.log.info"
    FAILED=1
  fi
done

exit $FAILED
