# orangepi4-ltsuserpatch with optee for armbian/build #
build minimal armbian image for orangepi4-lts with optee.

## usage ##
```
git clone https://github.com/armbian/build
cd build
git clone https://github.com/worstass/armbian-optee-orangepi4-lts
git checkout $(awk -F '\"' '/LIB_TAG/ {print $2}' userpatches/config-phicomm-n1.conf)
./compile.sh
```
