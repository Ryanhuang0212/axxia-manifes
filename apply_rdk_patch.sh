#!/bin/bash
# apply_rdk_patch.sh — 建置前置作業檢查
# 功能：確認 RDK archive 存在並建立 symlink 至 workspace root
# 注意：此 script 不修改任何 recipe 檔案

set -e

WORKSPACE_ROOT="$(cd "$(dirname "$0")" && pwd)"
SEARCH_DIRS=(
    "$WORKSPACE_ROOT"
    "$(dirname "$WORKSPACE_ROOT")"   # parent dir
    "/home/senao/ryan_home"
)

KLM_ARCHIVE="rdk_klm_src.tgz"
TOOLS_ARCHIVE="rdk_user_src.tgz"

find_archive() {
    local name="$1"
    for dir in "${SEARCH_DIRS[@]}"; do
        if [ -f "$dir/$name" ]; then
            echo "$dir/$name"
            return 0
        fi
    done
    return 1
}

echo "=== RDK Build Prerequisite Check ==="

# 找 KLM archive
if KLM_PATH=$(find_archive "$KLM_ARCHIVE"); then
    echo "[OK] KLM archive: $KLM_PATH"
    if [ "$KLM_PATH" != "$WORKSPACE_ROOT/$KLM_ARCHIVE" ] && \
       [ ! -L "$WORKSPACE_ROOT/$KLM_ARCHIVE" ] && \
       [ ! -f "$WORKSPACE_ROOT/$KLM_ARCHIVE" ]; then
        ln -sf "$KLM_PATH" "$WORKSPACE_ROOT/$KLM_ARCHIVE"
        echo "     -> symlink created at workspace root"
    fi
else
    echo "[MISSING] $KLM_ARCHIVE not found in:"
    for dir in "${SEARCH_DIRS[@]}"; do echo "     $dir"; done
    echo "  Please place $KLM_ARCHIVE in the workspace root and re-run."
    exit 1
fi

# 找 Tools archive
if TOOLS_PATH=$(find_archive "$TOOLS_ARCHIVE"); then
    echo "[OK] Tools archive: $TOOLS_PATH"
    if [ "$TOOLS_PATH" != "$WORKSPACE_ROOT/$TOOLS_ARCHIVE" ] && \
       [ ! -L "$WORKSPACE_ROOT/$TOOLS_ARCHIVE" ] && \
       [ ! -f "$WORKSPACE_ROOT/$TOOLS_ARCHIVE" ]; then
        ln -sf "$TOOLS_PATH" "$WORKSPACE_ROOT/$TOOLS_ARCHIVE"
        echo "     -> symlink created at workspace root"
    fi
else
    echo "[MISSING] $TOOLS_ARCHIVE not found in:"
    for dir in "${SEARCH_DIRS[@]}"; do echo "     $dir"; done
    echo "  Please place $TOOLS_ARCHIVE in the workspace root and re-run."
    exit 1
fi

echo ""
echo "=== All prerequisites OK ==="
echo "Next step: make fs META_AXXIA_REL=grr_rdk_2509.01_s_66"
echo "  or:      source poky/oe-init-build-env axxia && bitbake axxia-image-dev"
