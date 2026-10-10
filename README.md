# minidocker: 手写一个微型容器引擎
## 项目简介

这是一个基于 Go 语言从零实现的微型容器引擎。它通过调用 Linux 内核的底层系统调用（Namespace、Cgroups、OverlayFS），实现了一个功能完备的、类似 Docker 的容器运行时。
## 核心功能

- **进程隔离**：基于 Namespace 实现 UTS（主机名）、PID（进程号）、Mount（文件系统）、Network（网络）四大核心隔离。
- **资源限制**：基于 Cgroups v2 实现内存资源限制（默认 50MB）。
- **文件系统隔离**：基于 OverlayFS + chroot 实现镜像分层与容器可写层，保证容器与宿主机文件系统互不干扰。
- **网络配置**：手动创建 veth pair 虚拟网卡对，配置 IP、路由和 NAT 转发，让容器拥有独立网络并能访问外网。

## 技术栈

- **语言**：Go 1.22
- **核心技术**：Linux Namespace、Cgroups v2、OverlayFS、veth pair、iptables NAT
- **开发环境**：WSL2 (Ubuntu 22.04)

## 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/Xu-kunqi/minidocker2.0.git
cd minidocker

# 2. 一键准备环境 + 编译
make

# 3. 运行容器
sudo make run
