function pre_config_uboot_target__copy-tee-bin() {
    run_host_command_logged cp -pv $USERPATCHES_PATH/overlay/tee.bin $SRC/cache/sources/$BOOTSOURCEDIR
    declare -g UBOOT_TARGET_MAP="BL31=bl31.elf TEE=tee.bin all;;idbloader.img u-boot.itb"
}
