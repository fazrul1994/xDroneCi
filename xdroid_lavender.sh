#!/usr/bin/env bash
# Main
export KBUILD_BUILD_USER=xyzuan # Change with your own name or else.
export KBUILD_BUILD_HOST=xyzscape-clouddroneci # Change with your own hostname.
IMAGE=$(pwd)/xdroid/out/target/product/lavender/xdroid*.zip
DATE=$(date +"%F-%S")
START=$(date +"%s")

# Sync Sources
function sync() {

curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
        -d chat_id="${chat_id}" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>xRomBuilder<b/>jajal"

mkdir xdroid
cd $(pwd)/xdroid
repo init -u https://github.com/xdroid-CAF/xdroid_manifest -b eleven
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
}

# Clone Device Stuff
function clonedevicedep() {
git clone https://github.com/xyz-prjkt/xdroid_device_lavender device/xiaomi/lavender --depth=1 -b -b eleven-caf
git clone https://github.com/xyz-prjkt/xbore_strmbreakr_lavender kernel/xiaomi/lavender -b eleven-caf_eas
git clone https://github.com/xyz-prjkt/hw_media hardware/qcom-caf/msm8998/media -b 11-LA.UM.9.6.2.r1-03600-89xx.0
git clone https://github.com/xyz-prjkt/hw_audio hardware/qcom-caf/msm8998/audio -b 11-LA.UM.9.6.2.r1-03600-89xx.0
git clone https://github.com/xyz-prjkt/hw_display hardware/qcom-caf/msm8998/display -b 11-LA.UM.9.6.2.r1-03600-89xx.0
}

# Compiler
function compile() {
	
	. build/envsetup.sh
	lunch xdroid_lavender-userdebug
	make carthage -j$(nproc)

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi
        git clone --depth=1 https://github.com/xyz-prjkt/AnyKernel3 AnyKernel
	mv $(pwd)/xdroid/out/target/product/lavender/xdroid*.zip $(pwd)
}

# Push kernel to channel
function push() {
    cd $(pwd)
    curl -F document=xdroid*.zip "https://api.telegram.org/bot${token}/sendDocument" \
        -F chat_id="${chat_id}" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi Note 7 (lavender)</b>"

    curl -F document=xdroid*.zip "https://api.telegram.org/bot${token}/sendDocument" \
        -F chat_id="-1001389519102" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi Note 7 (lavender)</b>"

}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
        -d chat_id="${chat_id}" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"

    curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
        -d chat_id="-1001389519102" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"

    exit 1
}

sync
clonedevicedep
compile
END=$(date +"%s")
DIFF=$(($END - $START))
push
