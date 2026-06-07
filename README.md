# Hermes Agent — fnOS 原生应用 fpk 打包

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

[Hermes Agent](https://hermes-agent.nousresearch.com) 是 Nous Research 推出的自改进 AI 智能体，支持编写代码、浏览网页、调用工具，并通过迭代反思不断自我改进。本仓库包含 **fnOS 飞牛原生应用** 的 fpk 打包源码。

## 目录结构

```
hermes-agent-fpk/
├── build.sh              # fpk 打包脚本
├── .gitignore
├── README.md
├── LICENSE
└── src/                  # fpk 源文件
    ├── manifest          # 应用清单
    ├── ICON.PNG          # 应用图标 72x72
    ├── ICON_256.PNG      # 应用图标 256x256
    ├── cmd/              # 生命周期脚本
    │   ├── main          # 启动/停止/状态查询
    │   ├── common        # 公共函数库
    │   ├── install_callback  # 安装后初始化
    │   ├── uninstall_callback # 卸载后清理
    │   └── ...
    ├── config/           # 权限与资源配置
    │   ├── privilege
    │   └── resource
    ├── wizard/           # 安装向导
    │   ├── config
    │   ├── install
    │   └── uninstall
    ├── ui/               # 桌面集成（打开按钮）
    │   ├── config
    │   └── images/icon.png
    ├── shares/           # 共享数据目录定义
    │   └── data
    └── hermes/           # Hermes Agent 完整源码
        └── code/
```

## 构建

```bash
# 安装依赖：fnOS 应用中心需先安装 Python 312

# 构建 fpk
bash build.sh 0.1.5
# 输出: output/com.kevinroy.hermesagent.v0.1.5.fpk
```

## 安装

- **Web UI**: 飞牛管理界面 → 应用中心 → 手动安装 → 选择 `.fpk` 文件
- **CLI**: `sudo appcenter-cli install-fpk --volume 1 output/com.kevinroy.hermesagent.v0.1.5.fpk`

## 注意事项

### 桌面图标/打开按钮

`ui/config` 必须位于 **fpk 根目录**（不是 app.tgz 内），fnOS 桌面才能识别"打开"按钮。
如果桌面图标不显示，检查 `/var/apps/com.kevinroy.hermesagent/ui/config` 是否存在。

### 运行状态

`cmd/main status` 通过 PID 文件检查进程状态。PID 文件路径：`${TRIM_PKGVAR}/hermes-agent.pid`。
如果应用中心显示"需要启动"但进程实际在运行，通常是 PID 文件缺失，重新执行 `cmd/main start` 即可。

### 依赖应用

manifest 中声明了 `install_dep_apps="python312:nodejs_v22"`，安装前确保这两个应用已安装。

## 更新流程

1. 更新 `src/hermes/code/` 中的源码
2. 更新 `src/manifest` 中的版本号和 changelog
3. 运行 `bash build.sh <新版本号>`
4. 在飞牛应用中心卸载旧版 → 安装新版
