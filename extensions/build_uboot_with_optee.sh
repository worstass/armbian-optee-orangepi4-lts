function build_custom_uboot__with_optee() {
    local uboot_work_dir=""
    uboot_work_dir="$(pwd)"

##    ATFBRANCH="tag:v2.7"
##    target_make="bl31"
##    display_alert "Downloading sources" "atf" "git"
##    fetch_from_repo "$ATFSOURCE" "$ATFDIR" "$ATFBRANCH" "yes"
##    local atf_src_dir=${SRC}/cache/sources/${ATFDIR}/$(branch2dir ${ATFBRANCH})
##
##    cd $atf_src_dir || exit
##
##    display_alert "Compiling ATF" "" "info"
##
##    ATF_COMPILER_64="aarch64-linux-gnu-"
##    ATF_COMPILER_32="arm-linux-gnueabihf-"
##
##    run_host_command_logged CCACHE_BASEDIR="$(pwd)" PATH="${toolchain}:${toolchain2}:${PATH}" \
##        "CFLAGS='-fdiagnostics-color=always -Wno-error=attributes -Wno-error=incompatible-pointer-types'" \
##        CROSS_COMPILE="'${CCACHE} ${ATF_COMPILER_64}'" M0_CROSS_COMPILE="$ATF_COMPILER_32" \
##        make ENABLE_BACKTRACE=0 LOG_LEVEL=40 BUILD_STRING=armbian ARCH=aarch64 PLAT=rk3399 SPD=opteed DEBUG=0 $target_make ${CTHREADS}

    OPTEEOSSOURCE="https://github.com/OP-TEE/optee_os.git"
    OPTEEOSBRANCH="tag:3.20.0"
    OPTEEOSDIR="optee_os"
    OPTEEOS_COMPILER_64='aarch64-linux-gnu-'
    OPTEEOS_COMPILER_32='arm-linux-gnueabihf-'
    OPTEEOS_USE_GCC='> 6.3'

    OPTEEOSSOURCEDIR="${OPTEEOSDIR}/$(branch2dir "${OPTEEOSBRANCH}")"
    display_alert "Downloading sources" "optee_os" "git"
    fetch_from_repo "$OPTEEOSSOURCE" "$OPTEEOSDIR" "$OPTEEOSBRANCH" "yes"
    local opteeosdir="$SRC/cache/sources/$OPTEEOSSOURCEDIR"
    cd "$opteeosdir" || exit
    display_alert "Compiling optee os" "" "info"
    run_host_command_logged CCACHE_BASEDIR="$(pwd)" PATH="${toolchain}:${toolchain2}:${PATH}" \
        "O=out/arm CFG_USER_TA_TARGETS=ta_arm64 CFG_ARM64_core=y PLATFORM=rockchip-rk3399 CFG_TEE_CORE_LOG_LEVEL=3 DEBUG=0 CFG_TEE_BENCHMARK=n CFG_IN_TREE_EARLY_TAS=trusted_keys/f04a0fe7-1f5d-4b9b-abf7-619b85b4ce8c CFG_ENABLE_EMBEDDED_TESTS=y" \
        make "${CTHREADS}" "CROSS_COMPILE='$CCACHE $OPTEEOS_COMPILER_64' CROSS_COMPILE_core='$CCACHE $OPTEEOS_COMPILER_64' CROSS_COMPILE_ta_arm64='$CCACHE $OPTEEOS_COMPILER_64' CROSS_COMPILE_ta_arm32='$CCACHE $OPTEEOS_COMPILER_32'"

    cd "$uboot_work_dir" || exit
    display_alert "Copy optee bin to uboot src dir" "" "info"
    run_host_command_logged cp -pv "${opteeosdir}/out/arm/core"/*.bin "${opteeosdir}/out/arm/core"/*.elf ./

    UBOOT_TARGET_MAP="BL31=bl31.elf TEE=tee.elf all;;idbloader.img u-boot.itb"
    loop_over_uboot_targets_and_do compile_uboot_target
}
