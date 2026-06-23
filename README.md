# 可能森林 / Possible Forest

> 为执行功能障碍与 ADHD 倾向人群设计的弹性任务规划 iOS App
> 苹果移动应用创新赛 · 2026

<p align="center"><em>你的森林没有死胡同。</em></p>

---

## 介绍

主流任务工具假设用户能"启动 → 持续 → 完成"，但 ADHD 人群在"启动"就卡住。卡住后产生羞耻感循环，进而彻底放弃工具。

**可能森林** 把任务工具从"效率工具"重构为"无障碍辅助"：

- 任务有 **3 种有效结局**（完美完成 / 部分完成 / 改天吧）
- 每种结局解锁不同后续分支——**没有失败，只有转向**
- 宠物观察你的选择，**性格动态演化**（勤奋 / 灵活 / 耐心 / 好奇）
- 用户感知不到拓扑结构，只感知宠物建议——**复杂在底层，简单在表层**

## 截图

| 主屏 | 任务卡片 | 性格演化 |
|---|---|---|
| (待补充) | (待补充) | (待补充) |

## 技术栈

- **平台**: iOS 26+ / iPadOS 26+
- **框架**: SwiftUI, Observation
- **视觉**: iOS 26 Liquid Glass + 动森暖色 2D
- **架构**: MVVM + `@Observable`
- **构建**: [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## 快速开始

### 环境要求

- Xcode 26.0+
- iOS 26.0+ Simulator 或真机
- macOS 15.0+

### 安装

```bash
# 1. 安装 xcodegen（若未安装）
brew install xcodegen

# 2. 生成 Xcode 项目
cd PossibleForest
xcodegen generate

# 3. 打开 Xcode
open PossibleForest.xcodeproj

# 4. 在 Xcode 中按 ⌘R 运行
```

或者直接命令行构建：

```bash
xcodebuild -project PossibleForest.xcodeproj \
  -scheme PossibleForest \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build

# 启动模拟器并运行
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/PossibleForest-*/Build/Products/Debug-iphonesimulator/PossibleForest.app 2>/dev/null | head -1)
xcrun simctl install "iPhone 17 Pro" "$APP_PATH"
xcrun simctl launch "iPhone 17 Pro" com.possibleforest.app
```

## 项目结构

```
PossibleForest/
├── project.yml                    # XcodeGen 配置
├── docs/
│   └── design.md                  # 设计文档（产品定位、机制、范围）
└── PossibleForest/
    ├── PossibleForestApp.swift    # App 入口
    ├── Models/
    │   ├── TaskNode.swift         # 任务数据模型 + 分支结局
    │   ├── Pet.swift              # 宠物 + 性格 + 成长阶段
    │   └── TaskLibrary.swift      # Demo 剧情树（3 层深度，9 个终点）
    ├── ViewModels/
    │   └── GameViewModel.swift    # 核心游戏状态 + 分支逻辑
    ├── Views/
    │   ├── HomeView.swift         # 主屏
    │   ├── OnboardingView.swift   # 首次启动引导
    │   ├── TaskCardView.swift     # Liquid Glass 任务卡片
    │   ├── PetCharacterView.swift # SwiftUI 程序化绘制的宠物
    │   └── PetDialogBubble.swift  # 宠物对话气泡
    └── DesignSystem/
        ├── Theme.swift            # 配色、渐变、玻璃材质
        └── GlassCard.swift        # iOS 26 Liquid Glass 组件
```

## 核心机制

### 动态分支任务树

```
        [复习考试]
       ╱    │    ╲
  完美    部分    放弃
   ↓      ↓      ↓
[看电影] [再刷题] [散步]
 奖励    补救    心态
```

每个任务的 3 种结局解锁完全不同的后续路径。拓扑结构随选择动态演化。

### 性格演化

| 选择 | 影响维度 |
|---|---|
| 完美完成 | 勤奋 ↑, 耐心 ↑ |
| 部分完成 | 灵活 ↑, 耐心 ↑ |
| 改天吧 | 灵活 ↑, 好奇 ↑ |

性格影响宠物的对话风格、动画、未来分支倾向。

## 设计文档

详见 [docs/design.md](docs/design.md)。

## 路线图

- [x] Demo 骨架（3 层任务树 + 4 维性格 + Liquid Glass UI）
- [ ] 真实宠物插画资源（32 张：4 阶段 × 4 表情 × 2 动作）
- [ ] App 图标设计
- [ ] 演示视频录制（3 分钟）
- [ ] 海报设计
- [ ] iCloud 同步
- [ ] 自定义任务创建
- [ ] 通知系统

## 人文关怀叙事

每 5 个成年人中就有 1 个受执行功能障碍影响——他们不是懒，是大脑的"CEO"离线了。主流任务工具的红色逾期标记，正在把他们的羞耻感循环放大。

可能森林不是效率工具，是**无障碍辅助工具**。它让每个选择都是有效的。

## License

MIT
