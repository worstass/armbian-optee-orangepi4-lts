function armbian_kernel_config__enable_optee_in_kernel() {
    if [[ -f .config ]]; then
        display_alert "Enabling tee and optee" "armbian-kernel" "debug"
        kernel_config_set_y CONFIG_TEE
        kernel_config_set_y CONFIG_OPTEE
    fi
}
