#!/bin/bash

# ============================================================
# minidocker 环境准备脚本
# 功能：自动创建 OverlayFS 分层目录，并准备基础镜像文件
# ============================================================

set -e  # 任何命令失败，立即退出

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  minidocker 环境准备脚本${NC}"
echo -e "${YELLOW}========================================${NC}"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误：请使用 sudo 运行此脚本！${NC}"
    echo -e "用法：sudo ./setup.sh"
    exit 1
fi

# 配置路径
OVERLAY_BASE="/tmp/overlay"
LOWER_DIR="$OVERLAY_BASE/lower"
UPPER_DIR="$OVERLAY_BASE/upper"
WORK_DIR="$OVERLAY_BASE/work"
MERGED_DIR="$OVERLAY_BASE/merged"

# 需要放进基础镜像的命令列表
BASIC_COMMANDS=("/bin/sh" "/bin/ls" "/bin/echo" "/bin/cat" "/bin/mkdir")

# ============================================================
# 第 1 步：清理旧目录
# ============================================================
echo -e "\n${YELLOW}[1/5] 清理旧目录...${NC}"
rm -rf "$OVERLAY_BASE"
echo -e "${GREEN}✅ 清理完成${NC}"

# ============================================================
# 第 2 步：创建分层目录结构
# ============================================================
echo -e "\n${YELLOW}[2/5] 创建 OverlayFS 目录结构...${NC}"
mkdir -p "$LOWER_DIR"/{bin,lib,lib64,proc,tmp,usr/bin,usr/lib,etc}
mkdir -p "$LOWER_DIR/lib/x86_64-linux-gnu"
mkdir -p "$UPPER_DIR" "$WORK_DIR" "$MERGED_DIR"
echo -e "${GREEN}✅ 目录结构创建完成${NC}"

# ============================================================
# 第 3 步：复制基础命令到 lower 层
# ============================================================
echo -e "\n${YELLOW}[3/5] 复制基础命令到 lower 层...${NC}"
for cmd in "${BASIC_COMMANDS[@]}"; do
    if [ -f "$cmd" ]; then
        cp -L "$cmd" "$LOWER_DIR/bin/"
        echo -e "  复制 $cmd"
    fi
done
echo -e "${GREEN}✅ 基础命令复制完成${NC}"

# ============================================================
# 第 4 步：复制动态链接库（关键！）
# ============================================================
echo -e "\n${YELLOW}[4/5] 复制动态链接库...${NC}"
for cmd in "${BASIC_COMMANDS[@]}"; do
    if [ -f "$cmd" ]; then
        # 复制依赖库到 /lib
        ldd "$cmd" 2>/dev/null | grep "=> /" | awk '{print $3}' | while read lib; do
            if [ -f "$lib" ]; then
                cp -L "$lib" "$LOWER_DIR/lib/" 2>/dev/null || true
                cp -L "$lib" "$LOWER_DIR/lib/x86_64-linux-gnu/" 2>/dev/null || true
            fi
        done
    fi
done

# 复制动态链接器（最关键）
if [ -f "/lib64/ld-linux-x86-64.so.2" ]; then
    cp -L /lib64/ld-linux-x86-64.so.2 "$LOWER_DIR/lib64/"
    echo -e "  复制动态链接器 ld-linux-x86-64.so.2"
fi

# 复制 NSS 相关库（某些命令需要）
for lib in /lib/x86_64-linux-gnu/libnss_files.so.2 /lib/x86_64-linux-gnu/libnss_dns.so.2; do
    if [ -f "$lib" ]; then
        cp -L "$lib" "$LOWER_DIR/lib/x86_64-linux-gnu/" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✅ 动态链接库复制完成${NC}"

# ============================================================
# 第 5 步：验证
# ============================================================
echo -e "\n${YELLOW}[5/5] 验证环境...${NC}"
echo -e "  lower/bin 内容："
ls "$LOWER_DIR/bin/" | sed 's/^/    /'
echo -e "  lower/lib64 内容："
ls "$LOWER_DIR/lib64/" 2>/dev/null | sed 's/^/    /' || echo "    (空)"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 环境准备完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n现在可以运行："
echo -e "  ${YELLOW}sudo ./myminidocker run /bin/sh${NC}"
