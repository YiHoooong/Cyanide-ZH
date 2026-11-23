# Cyanide（中文汉化版）

Cyanide 是一个基于 DarkSword 内核读写原语的 iOS 插件运行器。本仓库为其**完全汉化** fork：应用内全部界面文本均已翻译为简体中文。

## 支持的设备

**运行 iOS/iPadOS 17.0 – 18.7.1 或 26.0 – 26.0.1 的 iPhone 与 iPad。**

| | |
| --- | --- |
| ✅ 支持 | iOS/iPadOS **17.0 – 18.7.1** |
| ✅ 支持 | iOS/iPadOS **26.0 – 26.0.1** |
| ❌ 不支持 | iOS 16.x 及更早、**18.7.2 – 25.x**、**26.1 及更高** |
| ❌ 不支持 | **iPhone 17 系列（A19 / A19 Pro）** 与 **M5** —— 内存完整性强制（Memory Integrity Enforcement）会拦截漏洞利用 |

**iOS 15 与 16 是主动放弃而非能力不足。** 这些版本上的设备都能用
[Dopamine](https://github.com/opa334/Dopamine) 越狱，Cyanide 没有可补充的
东西——用那个即可。

iOS 17 被刻意全面支持，包括已有越狱覆盖的版本。具体覆盖取决于设备，
而且 Cyanide 完全不越狱设备：插件只在内存中对本次开机生效，因此
拒绝在越狱设备上运行的应用不受影响。

任何运行受支持版本的 iPhone 或 iPad 都应该可用，包括 A 系列与
M 系列 iPad。没有单独的设备白名单：Cyanide 检查 iOS 版本并通过扫描
寻找内核偏移，从老 A 系列到 A18 的硬件都由同一套代码处理。

已在 iPhone 16 Pro Max（iOS 18.5）、iPhone 15 Pro Max（iOS 17.3.1）
和 M 系列 iPad 上确认可用。

> **注意：** 这些设备会先按机型标识（`iPhone18,x` 及以上、`iPad17,x`
> 及以上）直接拒绝，所以你会看到明确的提示，而不是一次失败的利用。

## 插件

从应用内的安装器（Installer）安装。多数插件在内存中对本次开机生效，
重加载（respring）即可撤销。少数会写入文件或系统设置、跨重加载或重启
保留：OTA 拦截、通话录音提示音、隐藏 Home 条、密码盘样式、锁屏亮屏
时长、手表配对覆盖、监管模式与守护进程管理器会一直生效，直到你在
Cyanide 中关闭；缓存清理器会删除你选择的内容。

### 主屏幕

| 插件 | 作用 |
| --- | --- |
| **SBCustomizer** | 自定义程序坞、网格、应用位置与页数 |
| **Home Layout Extras** | 额外主屏/程序坞边距与逐图标缩放 |
| **Hide Home Bar** | 隐藏底部主屏幕指示条 |

### SpringBoard

| 插件 | 作用 |
| --- | --- |
| **Axon Lite** | 按应用分组通知中心请求 |
| **App Switcher Grid** | 网格样式多任务切换器 |
| **iPad Dock** | 带 App 资源库按钮的 iPad 式程序坞 |
| **Locked App Previews** | Face ID 锁定应用的通知预览（iOS 18+） |
| **CarPlay without Siri** | 在 Siri 保持关闭的情况下解除 iOS 18 的「要使用 CarPlay，请开启 Siri」限制，按连接生效：控制中心按钮、快捷指令操作（可做「连接 CarPlay 时」自动化）、`cyanide://carplay` 链接或运行 |
| **SpringBoard Tools** | 把「设置 → Lara」中的程序坞、文件夹与控制中心外观随其他插件一起应用 |

### 锁屏与安全

| 插件 | 作用 |
| --- | --- |
| **FastLockX Lite** | Face ID 重试与解锁控制 |
| **Passcode Style** | 自定义锁屏密码盘图案 |
| **Lock Screen Duration** | 让锁屏亮得更久 |
| **Double Tap to Lock** | 双击壁纸锁定 |

### 主题

| 插件 | 作用 |
| --- | --- |
| **SnowBoard Lite** | 本地 SnowBoard 风格图标主题 |
| **LiveWP** | 主屏与锁屏视频壁纸 |
| **iOS 6 Theme** | iOS 6 风格图标 |

### 状态栏

| 插件 | 作用 |
| --- | --- |
| **StatBar** | 电池温度 + 可用内存覆盖层 |
| **NSBar** | 状态栏网速覆盖层 |
| **NiceBar Lite** | NiceBar 风格状态栏标签 |

### 系统

| 插件 | 作用 |
| --- | --- |
| **Powercuff** | 按热压力降低 CPU/GPU 频率 |
| **Location Simulator** | CoreLocation 定点模拟，外加定位服务开关 |
| **Watch Pairing Override** | 配对新表或救活旧表 |
| **Call Recording Sound** | 静音通话披露开始/结束提示音 |
| **OTA Updates** | 启用或禁用 OTA 系统更新 |
| **Supervision** | 把设备标记为受监管（组织名「Cyanide」），可安装仅限监管设备的描述文件限制 |

### Beta

| 插件 | 作用 |
| --- | --- |
| **Dynamic Stage Lite** | 两个悬浮应用窗口，iPad 风格 |

## 工具

### 设置 → Lara

灵感来自 rooootdev 的 [lara](https://github.com/rooootdev/lara)，
经其许可移植。

| 工具 | 作用 |
| --- | --- |
| **Performance HUD** | Core Animation 的帧率与 GPU 覆盖层，直到关闭或重启 |
| **Debug Overlay** | Apple 内部 UIKit 检查器；双击状态栏打开 |
| **Upside Down** | 允许主屏与锁屏倒转旋转 |
| **Hidden Settings** | 隐藏的 iOS 偏好设置 |
| **JIT Enabler** | 以 JIT 打开开发签名的应用（模拟器等） |
| **3-App Limit** | 释放免费 Apple ID 自签应用的三应用名额 |
| **Wallet Card Art** | 用自己的图片替换钱包卡片图案（仅外观，可还原） |
| **App Decrypt** | 为已安装的 App Store 应用制作解密 IPA |
| **SpringBoard Tools** | 自定义程序坞、文件夹、控制中心、通知与多任务切换器的着色模糊效果 |
| **Font Overwrite** | 在内存中替换系统字体、斜体与等宽变体或锁屏时钟；普通字体会先在设备上适配 |

### 设置 → Gravity Lite

让主屏图标受重力物理作用坠落，倾斜设备控制方向。不是安装器软件包：
在其设置页面上激活/停用。

### 设置 → 系统

| 工具 | 作用 |
| --- | --- |
| **Process Viewer** | 查看运行中的进程，含详情与操作 |
| **File Browser** | 浏览文件系统，含 plist 编辑器与可选只读 root 访问 |
| **Daemon Manager** | 开关系统守护进程（持久生效） |
| **System Info** | 设备、电池与内核访问详情 |
| **Cache Cleaner** | 删除选中的缓存 |

**定位服务**也可以通过控制中心控件（iOS 18）或快捷指令 / 操作按钮
操作（iOS 17 及更高）切换。

**重加载**与**重启**也是控制中心按钮（iOS 18）和快捷指令 / Siri /
操作按钮操作（iOS 17 及更高），打开「重加载与重启链接」后还可以用
`cyanide://respring` 和 `cyanide://reboot` 链接打开。重启需要之前
运行留下的内核访问。

**无 Siri 使用 CarPlay** 也是控制中心按钮（iOS 18）、快捷指令操作与
`cyanide://carplay` 链接。免提用法：在快捷指令中创建个人自动化
**CarPlay → 连接时 → 立即运行**，使用「无 Siri 使用 CarPlay」操作。
需要开启对应软件包并有之前运行留下的内核访问。

## 选项

位于**设置 → 启动选项**：

| 选项 | |
| --- | --- |
| **A18 漏洞利用路径** | `pe_v3`（默认）、`pe_v1`（兼容）或 `pe_v2`（旧版回退）。仅限 A18/M4。 |
| **A18 交错搜索 / 内存整形 / 有限搜索** | `pe_v1` 路径的微调。仅限 A18/M4。 |
| **自动重试失败的链条运行** | 失手后自动重跑链条，有次数上限。 |
| **注入卡死时受控 panic** | 诊断用：主动写日志并 panic，而非等待看门狗复位。 |
| **插件应用速度** | 兼容 / 快 / 最快。越高则应用插件的远程调用间延迟越小。 |
| **详细日志** | 日志中输出完整 RemoteCall 内部信息，用于错误报告。 |
| **定位服务链接** | 允许 `cyanide://location-services` 链接（默认关闭）。 |
| **重加载与重启链接** | 允许 `cyanide://respring` 和 `cyanide://reboot` 链接（默认关闭）。 |
| **仓库源** | 显示或隐藏「源」标签页与仓库插件。 |
| **立即应用安装器更改** | 有已保存内核访问时，激活/停用插件立即只应用该插件而不排队（默认开启）。 |
| **后台保活** | Cyanide 退后台后仍需持续运行的插件所必需。 |

每个插件安装后都会在设置中有独立分区。

## 项目状态

本仓库是 [`zeroxjf/cyanide`](https://github.com/zeroxjf/cyanide) 的
fork，中文汉化版由 YiHoooong 维护。汉化范围覆盖应用内全部界面文本，
不改变任何功能逻辑。

原始 Cyanide 项目已由 `zeroxjf` 停止维护。任何人都可以在本许可证
条款下 fork 本仓库并继续开发。原作者与上游项目致谢保留在下方。

旧版 README 保留如下，供历史背景与构建细节参考。其中部分信息可能
已过时。

<details>
<summary>归档项目 README（原文）</summary>

<p align="center">
  <img src="https://raw.githubusercontent.com/kolbicz/cyanide/main/Cyanide/Assets.xcassets/AppIcon.appiconset/icon-ios-1024x1024.png" alt="Cyanide" width="160">
</p>

<h1 align="center">Cyanide</h1>

**By [@zeroxjf](https://github.com/zeroxjf)** — an iOS tweak runner built on top of the DarkSword kernel r/w primitive.

Cyanide is a fork of [`wh1te4ever/darksword-kexploit-fun`](https://github.com/wh1te4ever/darksword-kexploit-fun)
for iOS kernel research. It wraps the native DarkSword kernel stages in an
Objective-C iOS app, restructures the UI as an Installer/Settings split, and
adds a few reliability fixes for repeated local testing. It does not ship
the browser-delivered WebKit/dyld parts of the original DarkSword chain.

## Project Status

As of v1.3.6, Patreon integration has been removed. All installable Cyanide
tweaks are free and no tweak access depends on account linking.

Previously unreleased work-in-progress tweak code has been opened under the
same AGPL-3.0 license as the rest of the project. Some unfinished entries remain
visible in the app so contributors can find them, but installation stays
disabled until someone finishes and verifies them.

`zeroxjf` is stepping away from active Cyanide development. The code is now
open under AGPL-3.0 so anyone can fork it, study it, reuse it, or continue it
under the license terms.

## Install

Open this page on your iPhone/iPad and tap one of the buttons below.

<p align="center">
  <a href="https://celloserenity.github.io/altdirect/?url=https://raw.githubusercontent.com/kolbicz/cyanide/main/source.json" target="_blank">
    <img src="https://github.com/CelloSerenity/altdirect/blob/main/assets/png/AltSource_Blue.png?raw=true" alt="Add AltSource" width="200">
  </a>
  <a href="https://github.com/kolbicz/cyanide/releases/latest" target="_blank">
    <img src="https://github.com/CelloSerenity/altdirect/blob/main/assets/png/Download_Blue.png?raw=true" alt="Download .ipa" width="200">
  </a>
</p>

## Feedback

- [Report a bug](https://github.com/kolbicz/cyanide/issues/new?template=bug_report.yml)
- [Request a feature](https://github.com/kolbicz/cyanide/issues/new?template=feature_request.yml)

## Build

```sh
./scripts/build.sh
```

The build script uses the `Cyanide` scheme, disables code signing, and writes
an unsigned IPA to:

```text
build/Cyanide.ipa
```

## License

This repository is licensed under **AGPL-3.0**. See `LICENSE`.

</details>

## 构建

CI（GitHub Actions，`.github/workflows/build.yaml`）为手动触发
（workflow_dispatch），编译产物为未签名 IPA：

```sh
./build.sh        # 产出 build/Cyanide.ipa
```

等价的手动构建：

```sh
xcodebuild \
  -project Cyanide.xcodeproj \
  -scheme Cyanide \
  -sdk iphoneos \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 许可证

本仓库以 **AGPL-3.0** 许可。见 `LICENSE`。汉化部分同样遵循 AGPL-3.0。
