# Cell Demo 调试经验沉淀 · 回归用例映射（自动化门禁）

> 目的：把 2026-08-31 双端 Cell Demo 调试一整天的教训固化为**可自动执行的回归测试**，
> 避免重复人工双端截图对比，降低沟通成本、提升实现效率与质量。
>
> 三条防线：**组件层单测**（Android `CellTest.kt` / iOS `CellTests.swift`，D/A 用例）
> ＋ **demo 编排层门禁**（`scripts/check_demo_parity.py` 新增 `ui.cell.orch`，ORC 系列）
> ＋ **双端测试对等门禁**（ORC6）。
>
> 本节所有 ORC 检查由 `python3 scripts/check_demo_parity.py` 自动执行，已做**负向自测**确认能捕获回归。

---

## 一、今天踩的坑（时间线）

| # | 现象 | 根因 | 修复版本 |
|---|------|------|---------|
| ① | iOS 与 Android Cell 之间用「横线 vs 间隙」不统一 | 组件能力差异（分隔方式），需两端选一致方案 | v1.3 |
| ② | iOS 点击有点击态，Android 点击无点击态 | Android demo 每个 `Cell(...)` 没传 `onClick` → `enabled=false` → 不产生 PressInteraction | v1.8 |
| ③ | 两端模拟器尺寸不同，cell 高度无法对比 | 缺少可读高度的手段 | v1.7（D+B 核对工具） |
| ④ | iOS 顶部元素顺序与 Android 不一致 | iOS 三个 `insertArrangedSubview(at:)` 索引冲突（feedback 又插 index 1 挤掉 ref） | v1.13 |
| ⑤ | iOS 点击反馈只显示「点击了：」后面无字 | `onTap`（手势）路径直接拼 `title`，空行 cell 的 title 为空串，无兜底命名；`didSelectRowAt` 有兜底而 `onTap` 没有，双路径不对称 | v1.15 |
| ⑥ | iOS 反馈条缺实测高度，与 Android 文案不一致 | iOS 反馈文案未带 `（实测高度 xx pt）`，Android 带 `（实测高度 xx dp）` | v1.16 |

---

## 二、通用根因归类（举一反三）

这 6 个坑可归纳为 3 类，是**双端组件调试最容易反复踩**的：

### 类 A：双端路径不对称
> 坑 ②⑤ 属于这一类。
- **②**：iOS demo 传了 `onTap`，Android demo 没传 `onClick` → 一端点击态失效。
- **⑤**：iOS 内部两条路径 `didSelectRowAt` / `onTap` 只有一条做空行兜底 → 文案尾部缺失。

> **教训**：**两条（或多条）路径写同一个状态时，逻辑必须抽成同一个函数**，禁止各写各的。
> 双端对比时，优先比对「生成文案 / 触发回调」的**那段代码**，而不是显示层。

### 类 B：布局/约束系统性差异
> 坑 ①③④ 属于这一类。
- **①** 分隔方式、**③** 尺寸对比、**④** 元素插入顺序，本质都是**编排/布局在不同平台用不同机制**。

> **教训**：先确认**统一的方案**（横线 or 间隙、固定参考、固定插入索引），再落两端；
> 用**固定的索引/顺序常量**而不是依赖调用先后。

### 类 C：文案/内容生成为空
> 坑 ⑤⑥ 的显示根因。
- **⑤**：`title` 为空串拼进文案。
- **⑥**：缺高度字段。

> **教训**：**"文案少了一段"先查写入的字符串内容**（尤其空串/缺失字段），
> 而不是 label 引用、布局、遮挡。两端差异优先比对生成文案的代码段。

---

## 三、自动回归用例映射（重点交付）

### 3.1 组件层（D/A 用例，已有，双端对等）

今天的坑 ①② 已在组件层被覆盖（Android `CellTest.kt` 双端一致）：

| 坑 | 组件用例 | 断言 |
|----|---------|------|
| ② 点击态失效 | D7 / A3 | 可点 cell `onClick` 触发；`assertIsEnabled` |
| ② 禁用态 | D2 / A4 | disabled 时 `onClick` 不触发；`assertIsNotEnabled` |
| ① 分隔方式 | D8 | 相邻两行 1px border，无重叠 |

### 3.2 demo 编排层门禁（`ui.cell.orch`，本次新增）

由 `python3 scripts/check_demo_parity.py` 自动执行，覆盖今天 ④⑤⑥ 三个坑：

| 用例 | 坑 | 静态断言 |
|------|----|---------|
| ORC1 | ④ | iOS `insert at:` 索引 徽标(0)<参考块(1)<反馈条(2)；viewDidLoad 先 `addHeightReference` 后 `addFeedbackBar`；Android「高度参考」文字在「点击任意 cell」之前 |
| ORC2 | ⑥ | iOS 反馈含 `（实测高度 … pt）`；Android 含 `（实测高度 … dp）` |
| ORC3 | ⑤ | iOS `rowName` 对空行做兜底命名（含 `空行-`）；Android 空行 cell 显式命名 `空行-1` 且保留空 title |
| ORC4 | ② | Android 可点击 Cell 必带 `onClick`；禁用/加载态不带 |
| ORC5 | 版本 | 双端版本号一致（iOS `addVersionBadge` vs Android `Cell 组件 vX.Y`） |
| ORC6 | 对等 | iOS `CellTests.swift` 与 Android `CellTest.kt` 的 **D/A 用例 ID 集合一致**（H 系列为平台特有用例不比对：iOS H3/H3b token 层断言不补偿 + 实测辅助，Android H4 渲染层断言垂直居中） |

### 3.3 手工核对清单（无法自动化的部分）

以下仍需实机/截图人工核对（已登记，不承诺自动化）：

| 项 | 说明 |
|----|------|
| 点击态视觉（灰底出现/恢复） | 依赖模拟器交互，门禁只查「传了 onClick」 |
| cell 实际高度 | 用 D+B 工具：反馈条报 `实测高度 xx pt/dp`，两端数值应一致 |
| 真实渲染像素级对齐 | 需双端截图对比 |

---

## 四、使用方法

```bash
# 一键跑双端一致性门禁（含组件场景 diff + demo 编排层 ORC 检查）
python3 scripts/check_demo_parity.py

# 单独列出已登记组件
python3 scripts/check_demo_parity.py --list

# Android 组件单测（本机可跑，不依赖外网）
./gradlew :components:testDebugUnitTest

# iOS 组件单测（受本机 SPM 网络限制，需宿主环境）
swift test
```

**负向自测记录**（证明门禁有效）：
- 改坏 Android 版本号 → ORC5 捕获 `版本号不一致`，退出码 1；
- 删改 Android `test_D8_divider` 用例名 → ORC6 捕获 `iOS 有而 Android 缺失: ['D8_divider']`，退出码 1；
- 均恢复后全绿。

---

## 五、给后续双端组件调试的 checklist（降低沟通成本）

1. **改任何双端 demo/组件**：先跑 `python3 scripts/check_demo_parity.py` 确认 ORC1-6 全绿。
2. **文案类 bug**：先看写入的字符串内容（空串/缺失字段），别查 label 引用/布局。
3. **多路径写同一状态**：抽成同一个函数，禁止各写各的（防 ⑤ 复发）。
4. **固定顺序/索引**：用常量索引，不依赖调用先后（防 ④ 复发）。
5. **点击态失效**：先确认 demo 是否传了 `onClick`/`onTap`（防 ② 复发）。
6. **版本号**：双端同步递增，用徽标核对实机是否最新代码（防白调）。
7. **高度对比**：靠反馈条实测高度数字，不靠目测截图（两端 pt/dp 应相等）。
