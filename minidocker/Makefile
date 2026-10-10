# ============================================================
# minidocker Makefile
# 用法：
#   make          - 准备环境 + 编译
#   make setup    - 只准备环境
#   make build    - 只编译
#   make run      - 运行容器
#   make clean    - 清理所有生成的文件
# ============================================================

# Go 编译器路径（如果系统路径里有 go，可以改成 go）
GO := /usr/local/go/bin/go

# 编译环境变量（解决 GOTOOLCHAIN 劫持问题）
GO_ENV := GOTOOLCHAIN=local

# 输出文件名
BINARY := myminidocker

# 默认目标：准备环境 + 编译
.PHONY: all
all: setup build

# 准备 OverlayFS 环境
.PHONY: setup
setup:
	@echo "📦 正在准备 OverlayFS 环境..."
	@chmod +x setup.sh
	@sudo ./setup.sh

# 编译
.PHONY: build
build:
	@echo "🔨 正在编译 $(BINARY)..."
	@sudo env $(GO_ENV) $(GO) build -o $(BINARY) main.go
	@echo "✅ 编译完成！"

# 运行容器
.PHONY: run
run:
	@echo "🚀 正在启动容器..."
	@sudo ./$(BINARY) run /bin/sh

# 清理所有生成的文件
.PHONY: clean
clean:
	@echo "🧹 正在清理..."
	@sudo rm -rf /tmp/overlay
	@sudo rm -f $(BINARY)
	@echo "✅ 清理完成！"

# 查看帮助
.PHONY: help
help:
	@echo "minidocker 构建工具"
	@echo ""
	@echo "可用命令："
	@echo "  make         - 准备环境 + 编译"
	@echo "  make setup   - 只准备 OverlayFS 环境"
	@echo "  make build   - 只编译"
	@echo "  make run     - 运行容器"
	@echo "  make clean   - 清理所有生成的文件"
	@echo "  make help    - 显示此帮助信息"
