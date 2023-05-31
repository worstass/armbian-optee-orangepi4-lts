function build_custom_uboot__with_optee() {
    local uboot_work_dir=""
    uboot_work_dir="$(pwd)"

    declare -g ATFBRANCH="tag:v2.7"
    declare -g ATFSOURCEDIR=${ATFDIR}/$(branch2dir ${ATFBRANCH})
    compile_atf

    OPTEEOSSOURCE="https://github.com/OP-TEE/optee_os.git"
    OPTEEOSBRANCH="tag:3.21.0"
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
    #run_host_command_logged cp -pv "${opteeosdir}/out/arm/core"/*.bin "${opteeosdir}/out/arm/core"/*.elf ./

    #UBOOT_TARGET_MAP="BL31=bl31.elf idbloader.img u-boot.itb;;idbloader.img u-boot.itb"
    UBOOT_TARGET_MAP="BINMAN_VERBOSE=3 BL31=bl31.elf TEE=tee.elf all;;idbloader.img u-boot.itb"
    loop_over_uboot_targets_and_do compile_uboot_target
}
