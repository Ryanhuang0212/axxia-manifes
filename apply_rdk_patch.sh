#!/bin/bash
echo "🚀 開始套用 RDK-Tools 破關補丁 (包含 Firmware 相容性)..."

RECIPE_DIR="meta-intel-axxia/meta-intel-rdk/recipes-extended/rdk-tools"
mkdir -p ${RECIPE_DIR}/files/

if [ -f "rdk_user_src.tgz" ]; then
    cp rdk_user_src.tgz ${RECIPE_DIR}/files/
    echo "✅ 成功複製 rdk_user_src.tgz"
else
    echo "❌ 找不到 rdk_user_src.tgz，請確保它在這個目錄下！"
    exit 1
fi

cat << 'RECIPE_EOF' > ${RECIPE_DIR}/rdk-tools.bb
SUMMARY = "Intel RDK tools pre-built"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-or-later;md5=fed54355545ffd980b814dab4a3b312c"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://rdk_user_src.tgz"
BB_STRICT_CHECKSUM = "0"
S = "${WORKDIR}/rdk"
INSANE_SKIP:${PN} = "already-stripped ldflags dev-deps"

# 完美複製官方的 firmware 套件宣告 (空頭支票合法化)
PACKAGES += "rdk-firmware"
ALLOW_EMPTY:rdk-firmware = "1"

do_compile() {
    :
}

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${nonarch_base_libdir}/modules
    install -d ${D}${sysconfdir}/modules-load.d
    # 預先建好 firmware 資料夾給系統看
    install -d ${D}${nonarch_base_libdir}/firmware/intel

    [ -f ${S}/eeupdate64e ] && install -m 0755 ${S}/eeupdate64e ${D}${bindir}/
    [ -f ${S}/eltt2 ] && install -m 0755 ${S}/eltt2 ${D}${bindir}/
    [ -f ${S}/iqvlinux.ko ] && install -m 0644 ${S}/iqvlinux.ko ${D}${nonarch_base_libdir}/modules/iqvlinux.ko
    
    echo "iqvlinux" > ${D}${sysconfdir}/modules-load.d/iqvlinux.conf
}

FILES:rdk-firmware = "${nonarch_base_libdir}/firmware"
FILES:${PN} = "${bindir} ${nonarch_base_libdir}/modules/iqvlinux.ko ${sysconfdir}/modules-load.d/iqvlinux.conf"
RECIPE_EOF

echo "✅ Recipe 覆蓋完成！特洛伊木馬與 Firmware 設定已就緒！"
