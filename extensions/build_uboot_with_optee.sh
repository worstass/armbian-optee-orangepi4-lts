function build_custom_uboot__with_optee() {
    local uboot_work_dir=""
    uboot_work_dir="$(pwd)"
    
    ATFBRANCH="tag:v2.7"
    target_make="bl31"
    display_alert "Downloading sources" "atf" "git"
    fetch_from_repo "$ATFSOURCE" "$ATFDIR" "$ATFBRANCH" "yes"
    local atf_src_dir=${SRC}/cache/sources/${ATFDIR}/$(branch2dir ${ATFBRANCH})
    
    cd $atf_src_dir || exit
    
    display_alert "Compiling ATF" "" "info"
    run_host_command_logged CCACHE_BASEDIR="$(pwd)" PATH="${toolchain}:${toolchain2}:${PATH}" \
        "CFLAGS='-fdiagnostics-color=always -Wno-error=attributes -Wno-error=incompatible-pointer-types'" \
        make ENABLE_BACKTRACE="0" LOG_LEVEL="40" BUILD_STRING="armbian" $target_make "${CTHREADS}" "CROSS_COMPILE='$CCACHE $ATF_COMPILER'"

#    OPTEEOSSOURCE="https://github.com/OP-TEE/optee_os.git"
#    OPTEEOSBRANCH="tag:3.20.0"
#    OPTEEOSDIR="optee_os"
#    OPTEEOS_COMPILER_64='aarch64-linux-gnu-'
#    OPTEEOS_COMPILER_32='arm-linux-gnueabihf-'
#    OPTEEOS_USE_GCC='> 6.3'
#
#    OPTEEOSSOURCEDIR="${OPTEEOSDIR}/$(branch2dir "${OPTEEOSBRANCH}")"
#    display_alert "Downloading sources" "optee_os" "git"
#    fetch_from_repo "$OPTEEOSSOURCE" "$OPTEEOSDIR" "$OPTEEOSBRANCH" "yes"
#    local opteeosdir="$SRC/cache/sources/$OPTEEOSSOURCEDIR"
#    cd "$opteeosdir" || exit
#    display_alert "Compiling optee os" "" "info"
#    run_host_command_logged CCACHE_BASEDIR="$(pwd)" PATH="${toolchain}:${toolchain2}:${PATH}" \
#        "O=out/arm CFG_USER_TA_TARGETS=ta_arm64 CFG_ARM64_core=y PLATFORM=rockchip-rk3399 CFG_TEE_CORE_LOG_LEVEL=3 DEBUG=0 CFG_TEE_BENCHMARK=n CFG_IN_TREE_EARLY_TAS=trusted_keys/f04a0fe7-1f5d-4b9b-abf7-619b85b4ce8c CFG_ENABLE_EMBEDDED_TESTS=y" \
#        make "${CTHREADS}" "CROSS_COMPILE='$CCACHE $OPTEEOS_COMPILER_64' CROSS_COMPILE_core='$CCACHE $OPTEEOS_COMPILER_64' CROSS_COMPILE_ta_arm64='$CCACHE $OPTEEOS_COMPILER_64' CROSS_COMPILE_ta_arm32='$CCACHE $OPTEEOS_COMPILER_32'"
#
#    cd "$uboot_work_dir" || exit
#    run_host_command_logged cp -pv "${opteeosdir}/out/arm"/*.bin "${opteeosdir}/out/arm"/*.elf ./
#    run_host_command_logged cp -pv "${atf_src_dir}"/*.bin "${atf_src_dir}"/*.elf ./ # only works due to nullglob
#
#    display_alert "Preparing u-boot config" "" "info"
#    run_host_command_logged CCACHE_BASEDIR="$(pwd)" PATH="${toolchain}:${toolchain2}:${PATH}" \
#        "KCFLAGS=-fdiagnostics-color=always" \
#        unbuffer make "$CTHREADS" "$BOOTCONFIG" "CROSS_COMPILE=\"$CCACHE $UBOOT_COMPILER\""
#
#    # armbian specifics u-boot settings
#    [[ -f .config ]] && sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="-armbian"/g' .config
#    [[ -f .config ]] && sed -i 's/CONFIG_LOCALVERSION_AUTO=.*/# CONFIG_LOCALVERSION_AUTO is not set/g' .config
#
#    cross_compile="CROSS_COMPILE=\"$CCACHE $UBOOT_COMPILER\""
#    display_alert "Compiling uboot" "" "info"
#
#    do_with_ccache_statistics run_host_command_logged_long_running \
#        CCACHE_BASEDIR="$(pwd)" PATH="${toolchain}:${toolchain2}:${PATH}" \
#        unbuffer make "$CTHREADS" "${cross_compile}"
    return
}
