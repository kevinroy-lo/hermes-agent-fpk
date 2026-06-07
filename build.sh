#!/bin/bash
# Hermes Agent fnOS fpk 打包脚本
# 使用: bash build.sh [version]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/src"
OUTPUT_DIR="${SCRIPT_DIR}/output"
VERSION="${1:-0.1.5}"
PKG_NAME="com.kevinroy.hermesagent"
PKG_FILE="${OUTPUT_DIR}/${PKG_NAME}.v${VERSION}.fpk"

echo "=== 构建 ${PKG_NAME} v${VERSION} ==="

# 清理
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

# 1. 构建 app.tgz（Hermes 源码 + ui 桌面配置）
echo ">>> 打包 app.tgz ..."
cd "${SRC_DIR}"
tar czf "${OUTPUT_DIR}/app.tgz" \
  hermes/ \
  ui/config ui/images/icon.png

echo "     app.tgz: $(ls -lh ${OUTPUT_DIR}/app.tgz | awk '{print $5}')"

# 2. 将 app.tgz 复制到源目录（以便包含在 fpk 的根目录）
cp "${OUTPUT_DIR}/app.tgz" "${SRC_DIR}/app.tgz"

# 3. 构建 fpk（未压缩）
echo ">>> 打包 fpk ..."
TARBALL="${OUTPUT_DIR}/${PKG_NAME}.v${VERSION}.tar"
rm -f "${TARBALL}"

cd "${SRC_DIR}"
tar cf "${TARBALL}" \
  manifest \
  cmd/common cmd/main \
  cmd/install_init cmd/install_callback \
  cmd/config_init cmd/config_callback \
  cmd/uninstall_init cmd/uninstall_callback \
  cmd/upgrade_init cmd/upgrade_callback \
  config/privilege config/resource \
  wizard/config wizard/install wizard/uninstall \
  shares/data \
  ui/config ui/images/icon.png \
  ICON.PNG ICON_256.PNG \
  LICENSE

# 追加 app.tgz 到 tar
tar rf "${TARBALL}" app.tgz

# 清理源目录中的 app.tgz
rm -f "${SRC_DIR}/app.tgz"

# GZip 压缩得到 fpk
gzip -c "${TARBALL}" > "${PKG_FILE}"
rm -f "${TARBALL}"

echo ""
echo "=== 构建完成 ==="
echo "输出: ${PKG_FILE}"
ls -lh "${PKG_FILE}"
echo ""
echo "文件清单:"
tar tf "${PKG_FILE}" | sort
echo ""
echo "安装命令:"
echo "  sudo appcenter-cli install-fpk --volume 1 ${PKG_FILE}"
echo "  或在飞牛 Web 管理界面 -> 应用中心 -> 手动安装"
