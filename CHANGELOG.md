# Changelog

Native-UI-Comps 组件库版本日志。本文件是官方文档「版本日志」页的唯一数据源，随每次发布一并更新。

格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/)：

```markdown
## [版本号] - YYYY-MM-DD
### Added / Changed / Fixed / Removed / Security
- 条目
```

***

<!-- 版本号说明（2026-09-12 并发撞号记录，不改史）：① [1.5.4] 两条=Slider（890ec0b，14:00）与 Pagination（4e553f7，14:03）；② [1.5.5] DropDown（ecb4285，14:23）提交时把工作区中 Steps 修复的 CHANGELOG 草稿一并卷入且占用了 Steps 拟用的 1.5.5 号——Steps 代码/测试不受影响、条目顺延改号为 [1.5.6]；③ [1.5.8] Slider（d420032）、[1.5.9] Tag（929401e）、[1.6.0] ImageView（32d8f43）、[1.6.1] DropDown（7d49a65）为同日多会话并发顺延，[1.6.2] VirtualList Demo 滚动收口（原拟 1.6.1 被 7d49a65 占用顺延）。各条内容独立、均已验证。④ [1.7.5] 两条=LineChart #84 三优化（cc09660，Trae）与 iOS Tag 文字不可见第三次修复（5e2a250，他会话）同号并存——他会话提交窗口与 Trae 文档编辑重叠，条目未互相覆盖、内容均有效，v1.7.5 号双主题共用，不改史。 -->

## \[1.9.17] - 2026-09-13（Overlay 双端内容对齐+Demo4 按钮遮挡根治）

### Fixed

- **iOS 内容居左**：Demo1-3/5/6 副标题/描述 `textAlignment` 改 `.left`（v1.9.16 前已改但未提交）；本次补 Demo4 `title.textAlignment=.center`、`sub.textAlignment=.left` 显式对齐。根因=用户反馈"title 居中、内容居左"，iOS 之前内容（副标题/描述）用 `.center`。
- **Android Demo1-3 副标题居中**：`Column(horizontalAlignment=CenterHorizontally)` 导致副标题也居中。修复=副标题 `Text` 加 `fillMaxWidth()`+`textAlign=TextAlign.Start` 使其左对齐，title 仍由 Column 居中。
- **Android Demo4 按钮被遮挡**：底部 padding `48dp`→`64dp`。根因=部分机型 nav bar > 48dp，48dp 不够导致按钮底部仍被系统导航栏遮挡。同时 Demo4 title 加 `textAlign=TextAlign.Center`+`fillMaxWidth` 居中对齐 iOS。
- 验证：Android `./gradlew :app:assembleDebug` BUILD SUCCESSFUL；iOS `xcodebuild` BUILD SUCCEEDED。

## \[1.9.16] - 2026-09-13（Overlay iOS 圆角仍不显示修复）

### Fixed

- **iOS 圆角仍不显示**：v1.9.12 已改 `clipsToBounds=r>0` 但用户反馈"iOS 还是直角"。根因=`layoutSubviews` 未重新应用圆角，`contentContainer` frame 变化后 `cornerRadius`/`clipsToBounds` 可能被系统重置。修复=`layoutSubviews` 中调用 `applyRadius()` 确保每次布局后圆角正确应用；`applyRadius` 中 `r>0` 且 `backgroundColor==nil` 时设默认白色背景防止背景透明导致圆角不可见。
- 验证：iOS `xcodebuild` BUILD SUCCEEDED。

## \[1.9.15] - 2026-09-13（Overlay Demo6 三项双端一致修复）

### Fixed

- **Demo6 title 居中**：Android `Text` 加 `textAlign=Center`+`fillMaxWidth` 对齐 iOS。
- **Demo6 desc 居中+文案对齐**：Android `Text` 加 `textAlign=Center`，文案"只能通过下方按钮关闭"改"只能通过下方「提交」按钮关闭"对齐 iOS。
- **Demo6 form 去掉 title 行**：Android 去掉 `Text("姓名")`+`Text("备注")` 两行 title，直接 input（对齐 iOS `makeFormField` 无 title）；按钮 `AppButton` 改 `Surface`+`Text` 对齐 iOS `makeDialogButton`。
- 验证：Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.14] - 2026-09-13（Overlay Demo5 三项双端一致修复）

### Fixed

- **Demo5 title 居中**：Android `Text` 加 `textAlign=Center`+`fillMaxWidth` 对齐 iOS `textAlignment=.center`。
- **Demo5 content 文案**：Android "任意 Composable 内容" 改 "任意自定义内容" 对齐 iOS。
- **Demo5 按钮主题/尺寸**：Android 用 `AppButton(Secondary/Primary)` 改为 `Surface`+`Text` 自定义样式（cornerRadius 10/font 14 medium/height 40/bg=#E5E7EB+#111827 或 AppColor.primary+white），与 iOS `makeDialogButton` 完全一致。
- 验证：Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.13] - 2026-09-13（Overlay Demo4 按钮被遮挡修复）

### Fixed

- **Demo4 Android 按钮被遮挡**：v1.9.10 错误去掉 `navigationBarsPadding` 追求弹层高度一致，但 iOS 底部有 20px 安全区空白 Android 没有，导致按钮被系统导航栏遮挡。加回 `navigationBarsPadding` 让 Android 底部有安全区空白（对齐 iOS）。
- 验证：Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.12] - 2026-09-13（Overlay 圆角修复）

### Fixed

- **Demo1234 弹层 iOS 显示直角**：根因=v1.9.2 改 `clipsToBounds=false` 防止测量偏小内容被裁掉，但内容用 `stack.edges=container` 紧贴容器边界，内容溢出到圆角外可见，遮挡了圆角背景，视觉上看像直角。修复=`applyRadius` 中 `r>0` 时开启 `clipsToBounds=true` 裁剪内容到圆角区域内（v1.9.10 已用 `greaterThanOrEqualToConstant` 防止测量偏小，开启裁剪不会裁掉内容）。
- 验证：iOS `xcodebuild` BUILD SUCCEEDED。

## \[1.9.11] - 2026-09-13（Popup 六项双端一致修复）

### Fixed

- **D1/D6/D8 文案被截断**：Android `Text` 用 `defaultMinSize(minWidth=208.dp)` 太窄导致文案只显示部分（用户反馈"常规内容"/"带关闭图"/"大圆角弹"），改用 `Box`+`widthIn(min=240.dp)`+`padding(lg)` 包裹 `Text`，文案完整显示。
- **D2/D3 弹层文案没有水平和垂直居中**：`Text` 外加 `Box(contentAlignment=Center)`+`padding(lg)` 实现水平垂直居中。
- **D7 弹出层太窄文案折行**：`widthIn(min=280.dp)`+`padding(lg)` 替代 `defaultMinSize(minWidth=208.dp)`，防止文案折行。
- **D8 文案对齐 iOS**：Android "大圆角弹出层（24dp）" 改用 "大圆角弹出层（24pt）" 对齐 iOS（视觉等价）。
- 验证：Android `assembleDebug` BUILD SUCCESSFUL。

### 已知限制

- **D4 状态栏覆盖**：`Popup.kt WindowPopup` 默认 `decorFitsSystemWindows=true` 不覆盖状态栏，v1.9.6 已在 Activity 启用 edge-to-edge 但 Popup 独立 window 不跟随——此项为 Compose `Popup` 已知限制，后续用 `Dialog` 替代 `WindowPopup` 解决。

## \[1.9.10] - 2026-09-13（Overlay 四项双端一致修复）

### Fixed

- **Demo4 Android 弹层高度太低按钮被截断**：Android D4 去掉 `navigationBarsPadding`（edge-to-edge 已启用 v1.9.6），让 `Column wrapContentHeight` 自适应内容高度，防止按钮被截断。
- **Demo4 iOS 按钮上面文字被遮挡**：iOS D4 `stack.alignment` `.center` → `.fill` 让 title/sub 填满宽度（对齐 Android Column 默认），修复 `closeBtn` 撑满宽度时 stack 整体高度计算异常导致 title 被裁剪。
- **Demo5 iOS 按钮主题与 Android 不一致**：iOS D5 `cancel`/`confirm` 加 `snp.height=40` 对齐 Android `AppButton` 默认高度，修复双端按钮主题不一致导致按钮大小不一样。
- **Demo5 iOS form 无 title**：`Overlay.swift updateContentConstraints` `heightAnchor.constraint(equalToConstant:)` 改用 `greaterThanOrEqualToConstant:` 防止 `systemLayoutSizeFitting` 测量偏小导致 `contentContainer` 高度被钉小、title 在容器外负 Y 看不到。
- 验证：iOS `xcodebuild` BUILD SUCCEEDED + Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.9] - 2026-09-13（Drag 两项双端一致修复）

### Fixed

- **拖拽手柄 icon 不一致**：v1.9.0 误以为 iOS 系统 reorder control 有两端圆点（哑铃状），实际 iOS 系统 reorder control 就是三条等粗水平线（≡）。去掉两端圆点，与 iOS 完全一致。
- **cell 四周横线**：`graphicsLayer.shadowElevation=4f` 在 LazyColumn 紧密排列下渲染成方形边框（用户反馈"四周都是横线"），改用 `Modifier.shadow(2.dp, RectangleShape, clip=false)` 柔和阴影（视觉更接近 iOS `layer.shadow`），拖动态 shadow=8dp 增强层次感，非拖动态 shadow=2dp 轻微底部阴影。
- 验证：Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.8] - 2026-09-13（Swipe 两项双端一致修复）

### Fixed

- **Demo4 右侧红色区块**：`SwipeItem` `BoxWithConstraints` 加 `clipToBounds()` 裁剪底层操作按钮到容器边界内，防止操作按钮超出容器边界导致红色漏出（对齐 iOS `SwipeItem.clipsToBounds=true`）。
- **Demo1/2 左滑无操作栏**：`SwipeItem` 加 `nestedScroll(NestedScrollConnection)` 在 `onPreScroll` 阶段消费水平分量（`available.x != 0`），防止外层 `LazyColumn` 垂直滚动抢占水平拖拽手势，`detectHorizontalDragGestures` 正常收到 DOWN 事件。
- 验证：Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.7] - 2026-09-13（PullToRefresh 两项双端一致修复）

### Fixed

- **Demo4 文案不一致**：iOS D4 `UIRefreshControl` 刷新中不显示文案（系统行为），Android D4 显示"下拉刷新数据"。修复=①iOS `PullRefreshView.applyTitle` 支持 `title=""` 时设 `attributedTitle=nil` 不显示文案；②Android `PullToRefresh.kt` `title.isEmpty()` 时不显示文案；③iOS D4 设 `title=""` 对齐 Android D4 无文案。
- **loading icon 不一致**：Android 已用 `IOSActivityIndicator` 自绘菊花（8 花瓣递进透明度+1s/圈旋转），与 iOS `UIRefreshControl` 系统菊花视觉对齐。本次确认双端菊花视觉一致。
- 验证：iOS `xcodebuild` BUILD SUCCEEDED + Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.6] - 2026-09-13（Popup Demo 六项双端一致修复）

### Fixed

- **Demo1/6/7/8 文字折行**：Android `Text` 默认 `maxLines=Int.MAX_VALUE` 会折行，iOS `UILabel` 默认 `numberOfLines=1` 不折行。Android Demo1/6/7/8 的 `Text` 加 `maxLines=1` 对齐 iOS。
- **Demo3 底部弹层高度太低**：`Popup.kt` BOTTOM position `heightIn(min=120.dp)` → `heightIn(min=160.dp)`，对齐 iOS 实际渲染高度（120 + padding 累加后视觉偏低）。
- **Demo4/5 弹层不覆盖状态栏**：Android `WindowPopup` 默认在状态栏下方，iOS `keyWindow` 覆盖状态栏。`MainActivity.onCreate` 加 `WindowCompat.setDecorFitsSystemWindows(window, false)` 启用 edge-to-edge 让 Popup window 覆盖状态栏。
- 验证：Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.5] - 2026-09-13（Overlay Demo4/5/6 三项双端一致修复）

### Fixed

- **Demo4 iOS 文字看不到 + Android 按钮被遮挡**：①iOS Overlay `applyRadius` 永久 `clipsToBounds=false`（旧 `r > 0` 时 `true` + `layoutSubviews` 的 `CAShapeLayer` mask 双重裁剪，导致 `measureContentSize` 测量偏小时内容被裁掉）；`layoutSubviews` 去掉 `CAShapeLayer` mask（`cornerRadius` 已实现圆角背景，内容溢出可见，与 Android `Modifier.background(shape)` 一致）。②Android Demo4 Column 加 `navigationBarsPadding()` 防止按钮被系统导航栏遮挡。
- **Demo5 iOS 底部弹起 vs Android 弹框**：iOS `showDemo5` 去掉 `container.snp.makeConstraints { make.top=stack.top-20; make.bottom=stack.bottom+20 }` 循环依赖（`stack.center=container.center` + `container.top/bottom=stack` 造成 Auto Layout 循环，`systemLayoutSizeFitting` 返回异常值，内容跑到错误位置），改用 `stack.edges=container`（与 Demo1 一致）。
- **Demo6 iOS form title 看不到**：同 Demo5 循环依赖 + `clipsToBounds` 裁剪，修复同上（去掉循环约束 + `stack.edges=container`）。
- 验证：iOS `xcodebuild` BUILD SUCCEEDED + Android `assembleDebug` BUILD SUCCESSFUL。

## \[1.9.4] - 2026-09-13（标记五组件为重点修复）

### Docs

- **Overlay / Popup / Drag / PullToRefresh / Swipe 标记为重点修复**：用户 2026-09-13 原话「Overlay/Popup/Drag/PullToRefresh/Swipe 标记为重点修复」。同步更新：`组件进度.md` 行 6/47/54/55/58 状态列追加 ⚠️重点修复 标记，备注列追加 C1.5 已修复记录（Overlay v1.9.1 三项/Drag v1.8.7+v1.9.0 四项/Popup v1.8.6 七项/PullToRefresh v1.8.8 两项）+ 用户标记原话。

## \[1.9.3] - 2026-09-13（DropDown / DropDownMenu 双端实机验收通过状态同步）

### Docs

- **DropDown / DropDownMenu 双端实机验收通过**：用户 2026-09-13 原话「DropDown：已通过 / DropDownMenu：已通过」。同步更新：①双端 Demo 组件列表 `passed = true`（iOS `DemoShowcases.swift` 两行 + Android `MainActivity.kt` 两行）；②`组件进度.md` 行 21/22 状态 📋→✅，并追加 C1.5 修复8/9 记录（v1.8.9 对勾 icon 统一+白色容器包裹文案 / v1.9.2 Demo4 通栏）+ 验收原话。
- 验证：Android `assembleDebug` + iOS `xcodebuild` BUILD SUCCEEDED。

## \[1.9.2] - 2026-09-13（iOS DropDown Demo4 灰色触发容器通栏修复）

### Fixed

- **Demo4 灰色触发容器不通栏（Android 通栏）**：根因=Demo4 旧 `dd.snp.makeConstraints width=200` 固定宽度，灰色触发容器（`bgPage` 底色）只占 200pt 不通栏，与 Android DropDown 默认 `fillMaxWidth` 通栏不一致。修复=去掉 `dd width=200` 固定宽度，`stack.alignment = .fill` 让 dd 填满 stack 宽度，stack `leading+trailing` 到 container 边缘实现通栏；btn 用 `setContentHuggingPriority(.required, for: .horizontal)` 防止被 `.fill` 拉伸满宽（保持左对齐紧贴内容宽度对齐 Android TextButton）。
- 验证：iOS `xcodebuild` BUILD SUCCEEDED（iPhone 14 模拟器）。

## \[1.9.1] - 2026-09-13（iOS Overlay 三项双端一致修复）

### Fixed

- **Demo1 标题被遮挡（Android 正常）**：根因=`measureContentSize` 旧逻辑（`measureStackView` 递归 + `sizeThatFits` + edge padding 检测）对 `stack.edges` 到 container 等布局测量偏小，叠加 `clipsToBounds=true` 导致 `contentContainer` 被强制设成偏小尺寸、内容超出部分被裁剪。修复=① `measureContentSize` 改用 `systemLayoutSizeFitting`（Apple 推荐自适应测量）首选，能准确处理 stack intrinsicContentSize、container 依赖 stack 等各种 Auto Layout 约束；旧逻辑作为兜底。② `contentContainer.clipsToBounds` 默认改 `false`（仅圆角时由 `applyRadius` 动态开启裁剪），防御测量偏小导致内容裁剪。
- **Demo4 内容不一致（iOS 只有关闭遮罩，Android 是 title+文案+关闭遮罩）**：根因=iOS Demo4 `handleWrap` 对 `handle` 重复 `snp.makeConstraints` 是 bug（第一次调用时 `handle.superview=nil` 约束挂到自身、第二次覆盖，布局异常导致 title/sub 被遮挡只露 closeBtn）。修复=去掉 `handleWrap`，`handle` 直接作为 stack arrangedSubview，`stack.alignment = .center` 让 handle 40×4 居中不占满宽度，对齐 Android Demo4 的 `Spacer(4dp×40dp).align(CenterHorizontally)`。
- **大部分弹窗内容被遮挡（Demo6 看不到内容）**：同问题1根因（测量偏小 + clipsToBounds=true），修复同上（`systemLayoutSizeFitting` 首选 + `clipsToBounds` 默认 false）。
- 验证：iOS `xcodebuild` BUILD SUCCEEDED（iPhone 14 模拟器）。

## \[1.9.0] - 2026-09-13（Android Drag 三项双端视觉对齐修复）

### Fixed

- **拖拽手柄 icon 仍不一致（Android Material DragIndicator 旋转 90° vs iOS 系统 reorder control）**：根因=`Icons.Default.DragIndicator` 旋转 90° 后仅三条水平两点线、无两端圆点，与 iOS 系统 reorder control（每条线两端有圆点呈哑铃状）视觉仍有差异。新增 `DragHandle` 自绘 `Canvas` 三条水平线+两端圆点（线长 0.6×宽、线粗 0.08×高、圆点半径 0.1×高），精确还原 iOS 系统 reorder control。
- **Cell 默认阴影太弱（用户反馈只有拖动时才有）**：根因=旧 `.shadow(2.dp, RectangleShape, clip=false)` 视觉不明显（2dp 太弱）。改用 `graphicsLayer.shadowElevation=4f`（对齐 iOS `willDisplay` shadowOpacity 0.15/radius 8），非拖拽态持续显示 cell-level 阴影，与 iOS 一致。
- **拖动时 cell 变模糊（用户反馈"整个 cell 变模糊"，iOS 仅降透明度）**：根因=`DragOpacity=0.6f` + 拖动态额外 `shadowElevation=8f` 叠加导致渲染模糊。修复=① `DragOpacity` 0.6→0.9 对齐 iOS 文档头注释 opacity 0.9；② 去掉拖动态额外 `shadowElevation=8f`，仅靠默认阴影+降透明度表达拖动态（与 iOS 一致）。
- 验证：组件库 `compileDebugKotlin` 0 错误；Demo app `assembleDebug` 通过。

## \[1.8.9] - 2026-09-13（DropDown 三项双端一致修复）

### Fixed

- **Demo4 受控下拉按钮非左对齐（iOS 居中 vs Android 左对齐）**：根因=iOS `UIButton` 标题默认居中（`contentHorizontalAlignment = .center`），Android `TextButton` 内容默认左对齐。修复=iOS Demo4 按钮设 `contentHorizontalAlignment = .left`，与 Android `TextButton` 一致。
- **Demo1/2/3 白色容器未包裹说明文案（iOS 文案在容器外 vs Android hint 在 bgCard 内）**：根因=iOS `addInfo` 把说明文案作为独立子视图加到 `contentStack`（白色容器外），Android `DemoSection` 把 `hint` 文案放在 `bgCard` 白色 Column 内部。修复=iOS DropDownMenuShowcase Demo1/2/3 改用 `UIStackView` 纵向包「组件 + 说明文案 UILabel」放进 `addSection` 的 `bgCard` 容器内，stackView edges 到 container（top+md / leading+trailing / bottom-md），组件固定高度、文案自适应多行。
- **选中对勾 icon 不一致（Android Text("✓") 字体对勾 vs iOS accessoryType=.checkmark 系统对勾）**：根因=Android 用 `Text("✓")` 系统字体渲染对勾，字形因平台/字体不同与 iOS 系统 `checkmark` 视觉不一致。修复=Android DropDown + DropDownMenu 两处选中态对勾改用 `Icons.Default.Check` 图标（`tint = AppColor.primary`，`size = 16.dp`），Material Check 图标与 iOS 系统 checkmark 形状最接近。
- 验证：Android `compileDebugKotlin` 0 错误 + `assembleDebug` 通过；iOS `xcodebuild` BUILD SUCCEEDED。

## \[1.8.8] - 2026-09-13（Android PullToRefresh 两项双端一致修复）

### Fixed

- **下拉刷新图标不一致（Android 圆环 vs iOS 菊花）**：根因=`PullToRefresh.kt` 用 `androidx.compose.material3.CircularProgressIndicator`（连续描边圆环），iOS 用系统 `UIRefreshControl`（8 花瓣菊花式 UIActivityIndicator）。新增 `IOSActivityIndicator` 自绘菊花式指示器：8 花瓣绕圆心均布（每 45°）、每花瓣按索引递进透明度（菊花式"追光"效果）、刷新中整体绕圆心 1s/圈线性无限旋转（`rememberInfiniteTransition`+`infiniteRepeatable(tween(1000, LinearEasing))`）；下拉中=静态菊花按 `progress` 整体渐入（`graphicsLayer.alpha`），刷新中=旋转菊花（progress=null）。用 `Canvas` + `drawCircle` 绘制花瓣，半径=0.065×尺寸、轨道半径=0.27×尺寸（22dp → 花瓣直径 2.86dp、外圈直径 11.88dp）。替换两处 `CircularProgressIndicator` 调用。
- **除 D4 外其他列表难触发下拉刷新（iOS 顺畅）**：根因=`onPreScroll` 阻尼 0.7（`available.y * 0.7f`）下拉不跟手，用户需拉更远（56dp/0.7≈80dp）才达阈值；D4 因有 Button 也能触发所以主观"没问题"。阻尼 0.7→0.5，下拉距离与露出空白 1:2，主观"轻拉即触发"，与 iOS `UIRefreshControl` 顺畅度对齐。
- 组件库 `compileDebugKotlin` 0 错误；Demo app `assembleDebug` 通过。PullToRefresh 无单测（v1.4.13 起未补），后续按回归台账补测。

## \[1.8.7] - 2026-09-13（Android Drag 四项双端视觉对齐修复）

### Fixed

- **每个 Cell 缺阴影（只有 1px 横线，iOS 全有阴影）**：根因=`Drag.kt` 仅拖拽态 `graphicsLayer.shadowElevation=8f`，非拖拽态无 cell-level 阴影；对齐 `ios/DragListView.swift` 的 `willDisplay`（shadowOpacity 0.15 / offset 4 / radius 8），给每个 Row 加 `Modifier.shadow(2.dp, RectangleShape, clip=false)` 默认矩形轮廓阴影；DragRow 去掉 1px 分隔线（cell shadow 已替代视觉、避免冗余）。
- **拖拽手柄 icon 不一致（Android 旧用「≡」文本，iOS 用系统 reorder 控件）**：改用 `Icons.Default.DragIndicator` 旋转 90°（旋转后两条垂直三点线→三条水平两点线，与 iOS 系统 reorder 控件视觉一致）。
- **Cell 缺红色圆形删除 icon（iOS isEditing 模式系统减号按钮，Android 缺失）**：Demo `DragRow` 最左侧加 `Box+CircleShape+AppColor.error` 24dp 圆形+白色「−」减号，对齐 iOS UITableView isEditing 模式系统标准控件。
- **拖拽 swap 动画过快（iOS 丝滑顺畅，Android 跳变）**：根因=`animateItemPlacement` 默认 spring 过冲快；改用 `tween(300ms, EaseOut)` 对齐 iOS 标准 reorder 落位动画时长。
- 组件库 `compileDebugKotlin` 0 错误；Demo app `assembleDebug` 通过（仅 `animateItemPlacement` deprecation warning，与本次改动无关）。

## \[1.8.6] - 2026-09-13（Android Popup 七项双端一致修复）

### Fixed

- **内容定位失效（Demo1/3/6/7/8 内容跑到左上角）**：根因=container 的 `.align(Alignment.Center/BottomCenter/...)` 写在 `AnimatedVisibility` 内部，不是 mask Box 的直接子节点，`align` 失效→默认 top-start（左上角）。修复=mask 与 content 改**平级兄弟节点**（Overlay 同款已验证模式），用外层 Box 的 `contentAlignment` 按 position 定位；center 宽度改用 `widthIn(min=240, max=屏宽-32)` 与 iOS 约束一致（根治 Demo7 通栏）。
- **点击蒙层不消失+页面被永久遮住（Demo1/2/3）**：根因=①旧 `animVisible` 只置 true 从不置 false，visible=false 后 WindowPopup（含 mask）永远不卸载；②mask 与 container 嵌套+container 用 `clickable(enabled=false)` 不可靠。修复=用 `MutableTransitionState` 精准控制退出动画结束后卸载 WindowPopup；container 改用 `clickable(onClick={})` 消费点击阻止穿透到 mask；mask 始终挂 `clickable(enabled=closeOnClickOverlay)`。
- Popup 单测 10/10 全绿（center minWidth 240dp / bottom minHeight 120dp / closeable 按钮 / 蒙版点击语义）；组件库 `compileDebugKotlin` 0 错误；Demo app `assembleDebug` 通过。

## \[1.8.5] - 2026-09-12（Tag/Tour/ImagePreview/VirtualList 四组件 C1.5 验收收口）

### Changed

- **四组件验收收口（纯文档，组件代码零改动）**：用户 2026-09-12 双端实机验收通过（原话「Tag：已通过」「Tour：已通过」「ImagePreview：已通过」「VirtualList：已通过」）。① api.json 新建 ui.tag/ui.tour/ui.image-preview/ui.virtual-list 四条目（reviewed=true、双端 state=available+status=stable、props/events/source_refs/note 全量登记），componentCount 77→90；② 回归测试台账 #56（Tag）/#57、#65、#66（VirtualList）/#61（Tour）/#63（ImagePreview）六行补验收结论；③ 双端 Demo 列表 passed=true 已由 3445d46 提前入库，进度表四行 ✅ 已在位。注：本条目无组件代码改动，升版仅为统一登记文档收口批次（先例=LineChart 验收批次 v1.7.6）。

## \[1.8.4] - 2026-09-12（DropDown #68 三项双端一致）

### Fixed

- **Android D2 菜单尺寸**：DropdownMenu 宽度原为内容自适应（窄于列按钮），改用 `BoxWithConstraints` 取列宽 `maxWidth` 并 `width(columnWidth)`，面板与 iOS `matchAnchor` 一样=列按钮宽。
- **Android D4「外部切到 C」按钮**：Material3 `Button`（实心胶囊、默认整行观感）改 `TextButton`（纯文字链接、wrap 宽度紧挨下拉左下方），对齐 iOS `UIButton(type: .system)`；iOS 侧 D4 值居右、按钮紧挨在 v1.8.0 已修复（本次 iPhone 14 Pro 模拟器实证）。
- **D1/D4 浅灰背景观感不一（根因修复）**：iOS 组件灰药丸（bgPage）与 Demo section 容器同色被吞没显白——`addSection` 新增 `containerColor` 参数（默认 bgPage，其余组件零影响），DropDown 四段传 bgCard 白容器形成反差；同时撤销 #64 对 D2 列按钮的 black 4% 临时改色，双端回归设计 token bgPage（白卡上即浅灰药丸，与 Android 一致）。

## \[1.8.3] - 2026-09-12（Android Swipe #67）

### Fixed

- **Android Swipe 没滑动前右侧漏红 + 滑动后看不到操作按钮**：`Swipe.kt` 操作按钮的修饰符链 `.matchParentSize().width(80.dp)` 中，`matchParentSize` 将 `minWidth` 钉为父宽（如 360dp），`width(80.dp)` 被钳到 `minWidth=全宽`（80 < 360 → 钳到 360），按钮变全宽而非 80dp——全宽按钮 offset 到右缘时 80dp 在 bounds 内可见（漏红），滑动后揭示的也是全宽色块而非独立 80dp 按钮（看不到矩形块）。修复：`width(80.dp)` → `requiredWidth(80.dp)`——`requiredWidth` 忽略 incoming constraints 强制 80dp，不被 `matchParentSize` 的 `minWidth` 钳制。左右操作按钮同改。

## \[1.8.2] - 2026-09-12（iOS VirtualList #66）

### Fixed

- **iOS VirtualList Demo1-4 可见但列表仍无数据**（v1.8.1 修复约束后的残留问题）：`items` 的 `didSet` 只调了 `tableView.reloadData()`，**没调 `updateEmpty()`**——`setup()` 时 `items=[]` → `updateEmpty()` 设 `tableView.isHidden=true`；Demo 设 items 后 didSet 只 reloadData 不更新 hidden 状态，tableView 仍被隐藏。修复：`items.didSet` 补 `updateEmpty()` 调用。

## \[1.8.1] - 2026-09-12（iOS VirtualList #65）

### Fixed

- **iOS VirtualList Demo1-4 列表不显示数据**：4 个 Demo 的 list 约束用 `leading/trailing+centerY+height`——`centerY.equalToSuperview()` 不撑开 container 在 UIStackView 中的高度（`UIView` 无 `intrinsicContentSize`），container 高度=0 → `VirtualListView` bounds=0 → `tableView` 不显示；仅 D4 的 `emptyLabel` 用 `center.equalToSuperview()` 在 bounds=0 时仍显示在原点附近，遮蔽了其他 Demo。修复：4 个 Demo 改用 `edges.equalToSuperview() + height.equalTo(N)`（对齐 `EmptyShowcase` 写法），list 填满 container + 固定高度撑开 container=300/300/250/200。

## \[1.7.9] - 2026-09-12（iOS ImagePreview #62）

### Fixed

- **iOS ImagePreview Demo1-4 点击即 crash**：`rebuild()` 中 `page`（新建 `UIView`）在 `contentStack.addArrangedSubview(page)` **之前**就执行 `page.snp.makeConstraints { make in make.width.equalTo(self) }`——此时 `page` 未入视图树，与 `self`（`ImagePreviewView`）无共同祖先，AutoLayout 抛 `"Unable to activate constraint... no common ancestor"` 崩溃。修复：调整为先 `contentStack.addArrangedSubview(page)` 再建 `page.width==self.width` 约束（page→contentStack→scrollView→self 共同祖先=self）；`dot` 同理先 `indicatorStack.addArrangedSubview(dot)` 再建 `size` 约束。另 Demo 4 个 preview 调用顺序调整：先 `window.addSubview(preview)` + 建约束再设 `images`，避免 `rebuild` 时 `bounds=0` 致 `scrollTo` 偏移错。

## \[1.7.8] - 2026-09-12（iOS Tour #58）

### Fixed

- **iOS Tour Demo1-4 点击下一步无反应/无法关闭**：4 个 Demo 均缺 `tour.onChange = { tour.current = $0 }` 回调，导致 `nextTapped()` 调用 `onChange?(current + 1)` 时 `current` 不更新、`updateContent()` 不触发，按钮文字与步骤指示停滞；Demo2（`showSkip=false`）尤为明显——只能走"下一步→完成"路径，但 `isLast` 永远为 `false`，"完成"按钮永不出现，引导层无法关闭。4 个 Demo 统一补 `onChange` 回调，步骤切换与完成/关闭恢复正常。
- **iOS Tour 按钮文字紧贴边缘**：`nextButton`/`prevButton`/`skipButton` 三按钮均未设 `contentEdgeInsets`，文字紧贴按钮边缘（Android Tour `TourButton` 用 `.padding(horizontal = AppSpace.md=12, vertical = AppSpace.sm=8)`）。iOS 三按钮统一加 `contentEdgeInsets = (top: sm=8, left: md=12, bottom: sm=8, right: md=12)` 对齐 Android；同时去掉 `nextButton`/`prevButton` 固定 `height.equalTo(36)` 约束，让按钮按 insets + 文字自适应撑开，与 Android `Box+padding` 行为同构。

## \[1.8.0] - 2026-09-12（DropDown #64 六项视觉/交互统一）

> 版本说明：v1.7.9 已被并发会话 ImagePreview crash 修复（commit 9ecb1b1）占用，本批顺延 v1.8.0。

### Fixed

- **iOS 单列菜单位置**：锚点从整行（左侧标题「排序方式」下）改为右侧「选中值文字+箭头」区域，面板与 Android 一样从选中值文字下方弹出；右缘超屏自动左移。
- **iOS 选项横线**：`tableView.separatorStyle = .none` + `cell.selectionStyle = .none`，去掉每项下方分隔线与点击灰底，对齐 Android DropdownMenu。
- **选中态统一（绿字+对勾）**：Android D1 选项此前仅绿字无对勾（D2 已有），补右侧 ✓——双端四 Demo 统一=primary 绿字 + ✓。
- **D2 按钮灰底统一**：双端列按钮底色由 bgPage（#F9FAFB，白卡上 iOS 侧肉眼≈纯白）统一改为黑 4% 叠加（双端数学一致、可辨识浅灰）。
- **Android D4 点选无反应**：DropDown 新增 `innerValue` 内部选中态（`remember(value)` 同步外部赋值），调用方不传 onValueChange 时点选也即时更新触发器显示，对齐 iOS `valueStorage` 机制；外部按钮赋值仍正常同步。
- **iOS D4 值文字位置**：titleLabel 横向 hugging 提至 required、valueLabel leading 改 ≥ 标题尾部（原为等号，两标签等优先级竞争时值可能停在标题旁=「顺序排列」），值文字恒居箭头左侧右对齐，对齐 Android。

## \[1.7.8] - 2026-09-12（DropDown #17 交互统一）

### Fixed

- **iOS Demo1 面板错位**：openPanel 旧实现 window 为 nil 时把面板挂到 `self`（44pt 触发行内部），面板错位「跑到页面前面」——改为只挂 window（未上屏不弹）+ `bringSubviewToFront`。
- **双端文字-箭头间距恒定 4**：Android 触发行 `width(120.dp)` 固定宽（短文本留大片空白、长文本紧贴）→ `widthIn(max=120.dp)` + `spacedBy(4.dp)`；iOS valueLabel 间隙 8→4；iOS D2 列按钮箭头从钉在按钮 trailing 改为紧跟 title 右缘+4（旧间隙随列宽/文字长变化=「时大时小」）。
- **iOS D2 面板截断**：v1.7.7 误把多列面板宽也收窄为内容自适应（≈81pt<列宽）→文字截断；新增 `PanelWidthMode`（contentAdaptive/matchAnchor），D2 传 matchAnchor=列按钮宽，D1/D3/D4 保持内容自适应。
- **iOS 点空白关闭**：openPanel 时在 window 异步添加 `UITapGestureRecognizer`（cancelsTouchesInView=false，delegate 过滤面板内触摸），点击面板外空白自动关闭，对齐 Android DropdownMenu。
- **Android D2 悬空化**：手写 Column 面板（撑开内容区域）→ Material3 `DropdownMenu` 悬浮层（不撑开内容、点外自动关、面板从列按钮下弹出），对齐 iOS 交互（用户指定以 iOS 为准）。

## \[1.7.7] - 2026-09-12（DropDown #17）

### Fixed

- **Android 三角箭头恢复可见（D1-D4 全部）**：v1.6.7「双端三角统一」把 Android 箭头改成 `Icons.Default.ArrowDropDown + size(8.dp)`——但 Material 图标 24dp 视口内三角形仅占约 1/3，整体缩到 8dp 后三角实际≈2.7dp，真机几乎不可见（用户实机反馈「箭头没有了，之前有」；iOS 8pt 为 ChevronView 自绘整体图形，语义不等同）。修复：Android 新增自绘 `ChevronDown` Composable（Canvas 8×8dp 实心等腰三角、顶点向下、颜色/透明度与原一致），DropDown 触发行与 DropDownMenu 列按钮两处替换，与 iOS ChevronView 像素级同构；删除 ArrowDropDown/Icon 无用 import。
- **iOS 单列面板宽度以 Android 为准**：旧 `panel.width = anchorFrame.width`，而单列触发按钮通栏 → 面板通栏；Android 语义为 DropdownMenu 内容自适应（最长选项文本+内边距）。修复：面板宽改为 `min(按钮宽, 最长选项文本宽(sizeMd 字体实测) + AppSpace.md*2 + 15)`，多列（D2）面板随列按钮锚点本就与 Android 一致、未动。

## \[1.7.6] - 2026-09-12（LineChart #84 验收收口）

### Changed

- **LineChart #84 C1.5 用户实机验收通过**（v1.7.5 实机复验，原话「LineChart：已通过」）：① 双端 Demo 列表 `passed=true` 同步——Android `MainActivity.kt`「图表组件」分组 LineChart 项、iOS `DemoShowcases.swift` 图表组件 section `ui.line-chart`（列表页五态由黄「已评审」转绿「已通过 ✓」）；② 进度表 ui.line-chart 行、台账 #59 补验收原话收口；③ 组件层零改动（v1.7.5 三优化已实机验证：四周留白+网格横线可见+y 域留白）。

## \[1.7.5] - 2026-09-12（LineChart #84）

### Changed

- **LineChart #84 Android 双端视觉对齐三优化**（用户实机复验 v1.6.5 后反馈）。① **内边距**：组件根 Box 补 `padding(top/bottom=AppSpace.sm, start/end=AppSpace.md)`，对齐 iOS `chartView` 的 `edges.inset`（TrendChartView.swift L48-51），数据不再紧贴图表边缘。② **网格横线可见**：旧 `strokeWidth=0.5f` 为裸 px（2.625 密度真机≈0.19dp 亚像素，抗锯齿后不可见——台账 #58「禁止裸 px」禁令的又一案例），改 `0.5.dp→px` 对齐 iOS 默认网格 0.5pt 语义，4+1 条横线恢复可见。③ **y 域留白**：新增 `yFor()` 对齐 DGCharts 默认 `spaceTop/spaceBottom=0.1`（`axisMinimum=0`+自动上限），数据最高点上方与 0 值下方各留 10% 空隙；网格线、Y 轴标签、折线、圆点四处统一映射保持重合。**澄清**：双端 Demo3 数据源码逐值一致——iOS Demo 3 本就是「仅收入」单绿线（`expensePoints: []`），红绿双线在 Demo 1；用户所报 iOS Demo3 红绿两条系段落编号误记，数据零改动。`:components:compileDebugKotlin` BUILD SUCCESSFUL（20s）。

## \[1.7.7] - 2026-09-12（iOS Tag 单测沉淀——11 例覆盖 4 大根因）

### Test

- **iOS Tag 单测沉淀**——补 `TagTests.swift` 11 例覆盖 4 大根因（convenience init didSet 陷阱、layoutSubviews 循环、intrinsicContentSize 椭圆小点、closable closeIcon 尺寸）+ 三形态/四色/三尺寸/运行时 didSet 触发。
- 核心回归用例 `test_convenienceInit_intrinsicContentSize有文字宽度` 直接断言 `intrinsicContentSize.width > paddingH*2=12`，若 didSet 陷阱复发立即失败。
- 用 `@testable import` + 外部可观察的 `intrinsicContentSize`/`backgroundColor`/`layer.borderWidth` 间接验证内部 label.text 已赋值（不直接访问 private 属性，因 @testable 不能跨 private）。
- `xcodebuild test` 全部 11 例真绿（0.205s）。

## \[1.7.6] - 2026-09-12（iOS Tag 文字不可见第四次修复——根因 convenience init didSet 陷阱）

### Fixed

- **iOS Tag 文字不可见第四次修复**——颜色编码法排查确认 TagView 本体渲染但 label 宽度为 0。根因=**Swift 陷阱：convenience init 内对 stored property 赋值不触发 didSet**，`self.text = text` 不触发 `didSet { updateAppearance() }`，label.text 永远是 init 中的空字符串 ""，`intrinsicContentSize` 返回 `paddingH*2=12`（无文字宽度），TagView 渲染为 12×20 椭圆小点。修复=convenience init 末尾手动调用 `updateAppearance()`（与 Carousel UIPageControl 同类陷阱，memory 已记录）。同时移除诊断色。`xcodebuild` 0 错误。

## \[1.7.5] - 2026-09-12（iOS Tag 文字不可见第三次修复）

### Fixed

- **iOS Tag 文字完全看不到（第三次修复）**——根因=`layoutSubviews()` 中调用 `snp.updateConstraints` 每次布局都触发约束更新→布局循环→label 宽度被压成 0。重写 TagView 用内部 `UIStackView`（contentStack）水平排列 label+closeIcon（与 Android Compose Row 同构），删除 `layoutSubviews()` override，closeIcon 改 SnapKit `width/height` 约束，label 补 `.required` hugging+compression resistance 防挤压。`xcodebuild` 0 错误。

## \[1.7.4] - 2026-09-12（ImageView/Segmented/Steps/Table/Calendar 五件 C1.5 验收通过）

### Changed

- **5 件组件用户 C1.5 实机验收通过**（原话「ImageView：已通过 / Segmented：已通过 / Steps：已通过 / Table：已通过 / Calendar日历工具：已通过」）：台账 #44 ImageView 📋→✅、#75 Steps 📋→✅、#74 Segmented/#77 Table/#89 Calendar日历工具补验收原话。双端 Demo 代码 `passed=true` 同步：Android `MainActivity.kt` 5 个组件 + iOS `DemoShowcases.swift` 5 个组件。`xcodebuild` + `gradle` 双端 0 错误。

## \[1.7.3] - 2026-09-12（iOS DropDown 弹层页面返回后残留修复）

### Fixed

- **iOS DropDown 弹层在页面返回后残留组件列表页**——根因=弹层挂载在 `window` 上，页面 pop 后弹层不跟随消失。修复=`ShowcaseViewController` 基类补 `viewWillDisappear` 广播 `scrollViewDidScrollNotification`，复用已有 `DropDownView` 监听机制自动 `closePanel`（与 Android 同步）。`xcodebuild` 0 错误。

## \[1.7.2] - 2026-09-12（Android RowDemo 改用 DemoPage+DemoSection 包装）

### Changed

- **Android `RowDemo` 改用 `DemoPage`+`DemoSection` 包装**——页面水平边距 + 段间 16dp 间距 + 每个 demo 段最小高度 120dp + bgCard 卡片底色 + md 圆角。D1-D4 四个段落独立卡片，与 iOS `addSection` 结构对齐。`DemoPage` 加可选 `title` 参数渲染顶部组件标题。`assembleDebug` 0 错误。

## \[1.7.1] - 2026-09-12（Row #13 C1.5 验收通过）

### Changed

- **Row #13 用户 C1.5 实机验收通过**（原话「Row：已通过」），台账补验收记录。双端 Demo 代码 `passed=true` 同步：Android `MainActivity.kt` `RowDemo` 加 `passed=true`；iOS `DemoShowcases.swift` `ui.row` 加 `passed: true`。`xcodebuild` + `gradle` 双端 0 错误。

## \[1.7.0] - 2026-09-12（Pagination #71 C1.5 验收通过）

### Changed

- **Pagination #71 用户 C1.5 实机验收通过**（原话「Pagination：已通过」），台账补验收记录。双端 Demo 代码 `passed=true` 同步：Android `MainActivity.kt` `PaginationDemo` 加 `passed=true`；iOS `DemoShowcases.swift` `ui.pagination` 加 `passed: true`。`xcodebuild` + `gradle` 双端 0 错误。

## \[1.6.9] - 2026-09-12（PickerView #34 + Slider #45 C1.5 验收通过）

### Changed

- **PickerView #34 + Slider #45 用户 C1.5 实机验收通过**，状态 📋→✅。双端 Demo 代码 `passed=true` 同步：Android `MainActivity.kt` `PickerViewDemo`/`SliderDemo`（+`StepperDemo` 补 `passed=true`）；iOS `DemoShowcases.swift` `ui.picker-view`/`ui.slider`/`ui.stepper` `passed: true`。台账 #34/#45 状态更新 ✅ + 验收记录。`xcodebuild` + `gradle` 双端 0 错误。

## \[1.6.8] - 2026-09-12（DropDown #21/22 iOS 弹层滚动时不消失）

### Fixed

- **iOS 弹层在页面滚动时悬停不消失（与 Android 不同步）**：根因=iOS `DropDownView` 弹层是 `addSubview` 到 window/keyView 的浮层，不跟随 `scrollView` 滚动，页面滚动时弹层悬停在原屏幕位置。修复：① 新增 `Notification.Name.scrollViewDidScrollNotification` 全局通知；② `ShowcaseViewController` 基类 `viewDidLoad` 给 `scrollView.panGestureRecognizer` 加 `target-action`，手势触发时广播通知（不用 `UIScrollViewDelegate` 避免与 `SideBarShowcase` 子类的 `delegate` 冲突）；③ `DropDownView` `openPanel` 时注册监听、`closePanel` 时移除监听，收到通知自动 `closePanel`。`DropDownMenuView` 的子 `DropDownView` 同样受益（`closeAll` 调 `closePanel` 移除监听）。`xcodebuild` 0 错误。

## \[1.6.7] - 2026-09-12（DropDown #21/22 双端三角大小统一）

### Fixed

- **iOS Demo1 三角太大 + Demo2 三角更大 + 与 Android 不一致**：根因=iOS Demo1 `DropDownView` 用 Unicode `▼` 字符 12pt 字体渲染、iOS Demo2 `DropDownMenuView` 用 Unicode `▼` 跟标题同字体 `AppFont.sizeMd`（更大）、Android 用 Material Icons `ArrowDropDown` 默认 24dp 矢量图标——三处大小都不一样且非等边三角。修复：① iOS 新增 `ChevronView`（自绘等边三角形 `UIBezierPath`，8×8pt 固定，`isUp` 翻转方向）替代所有 Unicode `▼`；`DropDownView` Demo1 + `DropDownMenuView` Demo2 均改用 `ChevronView` 统一 8pt；② Android `DropDown`/`DropDownMenu` 的 `Icon` 加 `Modifier.size(8.dp)` 从 24dp 缩到 8dp。双端三角统一为 8pt 等边三角形。`xcodebuild` 0 错误 + `gradle` BUILD SUCCESSFUL 0 错误。

## \[1.6.6] - 2026-09-12（Android Demo 页面统一容器 DemoPage + DemoSection）

### Changed

- **Android Demo 页面统一容器**：用户反馈很多 Android Demo 页面没有边距直接贴屏幕边缘、demo 段间无间距、demo 段无最小高度，不方便调试排查。新增两个通用 Composable：① `DemoPage`=`Column(fillMaxSize+bgPage+verticalScroll+padding(lg,md)+spacedBy(md))`；② `DemoSection`=`Column(fillMaxWidth+bgCard+clip(md)+padding(md)+defaultMinSize(120dp)+spacedBy(sm))`，可选 `title`/`hint` 自动排版。改造 4 个完全无容器的 Demo：`DropDownMenuDemo`/`SliderDemo`/`StepperDemo`/`ImageViewDemo` 全部改用 `DemoPage`+`DemoSection`。删除旧的 `private fun DemoSection(title, content)` 函数（被新 `DemoSection` 超集替代，旧调用点签名兼容——`OverlayDemo`/`DividerDemo`/`CalendarDemo`/`DatePickerDemo` 等 6 处 `DemoSection(title="...")` 调用无需修改）。`gradle` BUILD SUCCESSFUL 0 错误。

## \[1.6.5] - 2026-09-12（LineChart #83）

### Fixed

- **LineChart #83 Android 纵坐标项与 X 轴第一项挤在一起、数据节点实心小圆（预期空心圆）**：两个根因。① **坐标映射不同**——iOS DGCharts 设置 `axisMinimum = -0.5 / axisMaximum = count - 0.5`，x 域共 count 个单位，首末数据点距图表左右缘各内缩半个步长，首标签不顶 Y 轴；Android 直接 `i * stepX`（stepX=chartW/(count-1)）从图表左缘起画，X 轴首标签 CENTER 在左缘点、左半字伸入 Y 轴标签列与 Y 轴数字挤在一起。② **单位错误**——Android 圆点半径 `5f`/白点 `2f` 为裸 px（2.625 密度真机≈1.9dp/0.76dp），线宽 `4f`≈1.5dp；iOS 基准是 `circleRadius=3pt + circleHoleRadius=1.5pt + circleHoleColor=.white + lineWidth=2pt`（`TrendChartView.swift` makeLineSet），白洞占比 50% 半径视觉为空心圆，Android 白点占比 40% 且整体过小视觉即实心圆。修复（`TrendChartView.kt`）：三处 x 映射统一为 `xFor(i) = yAxisW + (i+0.5)/count * chartW` 内缩域；圆点改 dp→px（彩圆 3dp + 白洞 1.5dp 白色）；线宽 2dp；台账 #58 注释说明。**禁令新增**：图表类 Canvas 组件数据点/圆/线尺寸一律 dp→px、禁止裸 px；坐标域必须与 iOS 同构（含 -0.5 内缩）。iOS 为基准零改动。`:components:compileDebugKotlin` BUILD SUCCESSFUL；`:app` 编译验证被并发会话 DemoPage/DemoSection 重构半成品（ColumnScope unresolved）阻塞，待其完成后复验。

## \[1.6.4] - 2026-09-12（DropDown #21）

### Fixed

- **DropDown #21 iOS Demo1/4 触发区域文字不可见**：根因=`DropDownView.buildUI()` 中 `triggerButton` 设置了 `translatesAutoresizingMaskIntoConstraints = false`，但 `titleLabel`/`valueLabel`/`chevronLabel` 未设置——导致 `NSLayoutConstraint.activate` 中涉及这三个 Label 的约束不生效（UIKit 从 autoresizing mask 自动生成约束覆盖手动约束），Label 宽度为 0 文字不可见；`triggerButton` 约束正常所以点击区域可响应。修复：`titleLabel`/`valueLabel`/`chevronLabel` 各补 `translatesAutoresizingMaskIntoConstraints = false`。`xcodebuild` BUILD SUCCEEDED 0 错误。

## \[1.6.3] - 2026-09-12（ImageView #44 双端图片不一致修复）

### Fixed

- **ImageView #44 iOS Demo1/2/4 图片与 Android 不一致 + Demo2 只显示两个 + Demo4 三个大小不一样**：根因=① iOS 用 SF Symbol（`folder.fill`/`bell.fill`/`heart.fill`）+ Android 用 Material Icons（`Folder`/`Notifications`/`Favorite`），两图标库渲染风格完全不同；② Demo2 `UIStackView` `distribution=.fill` + 三 80×80 + `spacing.md` 总宽 272pt 但 `.fill` 在父宽度不足时按比例压缩到非 80×80 正方形→第三个被挤出可见区；③ Demo4 同 `.fill` 导致三个非 80×80。修复：①双端 Demo1/2/4 全部改用 `sampleImage`/`makeDemoBitmap`（320×200 上蓝下橙+太阳圆，Image 组件已验证双端像素级一致），彻底弃用图标库；②双端 Demo3 改用 `DefaultErrorPlaceholder`/`makeErrorPlaceholder` 自绘破图图形（外框+太阳+山形折线，同数学定义）；③ iOS Demo2/4 `UIStackView` `distribution` 改 `.fillEqually` + 加 bottom 约束确保三等分；④ Android Demo2 full 圆角从 `999.dp` 改 `40.dp`（=宽/2=圆形，与 iOS 40pt 一致）；⑤ Android `DefaultErrorPlaceholder` 从 private 改 public + 加 modifier 参数；⑥ Android `makeDemoBitmap` 从 private 改 internal。`xcodebuild` + `gradle` 双端 0 错误。

## \[1.6.2] - 2026-09-12（VirtualList #81 Demo 滚动收口）

### Fixed

- **VirtualList #81 Android Demo 页无法拖动、D2-D4 不可达（模式性故障第 5 次，全量收口）**：根因与台账 #53（PickerView）完全同病——Demo 宿主详情页 `TmoDemo` 为不带滚动的 `Column`（返回键+大标题后 `current?.invoke()` 直接铺内容），**每个 Demo 页面必须自带滚动容器**；`VirtualListDemo` 自带 `fillMaxSize` Column 但没有 `verticalScroll`，被宿主约束为一屏高，D1-D4 四个列表块（300+300+250+200dp）总高约 1300dp 溢出不可达——用户只能滚动 D1 列表本身，页面整体无法拖动。该故障已反复出现 5 次（Empty Demo 1100 行、Drag Demo 7219/7237 行、PickerView #53、本次 3 个）。本次不再逐个打补丁，**脚本扫描全部 75 个 Demo 函数的页面级容器一次收口**：其余 10 个候选经甄别均为页面级 `LazyColumn`（自带滚动）误报，真缺滚动的共 3 个——① `VirtualListDemo` 补 `verticalScroll`（内层定高 Box 中的 LazyColumn 与外层滚动为 Compose 官方支持模式，nested scroll 自动衔接：列表滚到边界后续滚页面），徽标 v1.4.32→v1.6.2；② `CardDemo` 主体 Column 补 `verticalScroll`；③ `ImageViewDemo` 顶层散排包一层可滚 Column。三处均带台账 #57 注释。组件层（`VirtualList.kt` 等）零改动；iOS Showcase 为 UIScrollView 宿主 + UITableView 定高嵌套，页面本身可滚，不同病无需改。**禁令升级**：Demo 页内容超一屏必须自带 `verticalScroll`（页面级 LazyColumn 亦可），新增 Demo 一律过此门禁。`:app:assembleDebug` BUILD SUCCESSFUL 0 错误。

## \[1.6.1] - 2026-09-12（DropDown #22）

### Fixed

- **DropDown #22 iOS Demo1/3/4 内容不可见（高度坍缩）**：根因=`DropDownView` 约束用 `top.bottom.equalToSuperview()`（等式约束优先级 1000），定义 DropDownView 高度 = container 高度 - md，但 container 高度又依赖 DropDownView 高度（循环依赖），`intrinsicContentSize.height=44`（优先级 250）被等式约束架空导致高度坍缩为 0。Demo2 `DropDownMenuView` 能显示是因为内部 `barStack` 的 `UIButton(system+title)` 有 `intrinsicContentSize` 能打破循环。修复：Demo1/2/3/4 约束加显式 `height(DropDownView.Metrics.triggerHeight=44)`，用 1000 优先级显式高度打破循环依赖。xcodebuild BUILD SUCCEEDED 0 错误。

## \[1.6.0] - 2026-09-12（ImageView #44）

### Fixed

- **ImageView #44 双端 Demo 不一致对齐**：用户实机反馈 iOS ImageView 与 Android 不一致。逐段对比发现 4 处差异，以 Android 为基准对齐 iOS：
  1. **D2 圆角变体**：iOS UIStackView `distribution=.fillEqually` + `height=80`（无宽度约束→矩形）→ 改为 `.fill` + `width.height=80`（正方形），对齐 Android `Modifier.size(80.dp)`
  2. **D3 加载失败占位**：iOS UIImageView 直接 100×100 图标撑满容器 → 改为容器 UIView(100×100) + 内部 UIImageView `inset(20)`，对齐 Android `Box.size(100.dp)` + `Image.fillMaxSize().padding(20.dp)`
  3. **D4 fit 模式**：iOS 缺内边距 + 缺圆角 → 改为容器 UIView(80×80) + `cornerRadius=sm` + 内部 UIImageView `inset(8)`，对齐 Android `Box.size(80.dp).clip(RoundedCornerShape(sm))` + `Image.padding(8.dp)`
  4. **Android D4 contentScale bug**：注释写"fill / fit / cover"但代码第三个写 `ContentScale.FillBounds`（=fill，非 cover）→ 改为 `ContentScale.Crop`（=cover），双端统一 fill/fit/cover 三种不同模式
- `imageEdgeInsets` 在 iOS 16+ SDK 已移除，D3/D4 改用容器 UIView + 内部 UIImageView `edges.inset()` 约束方案实现等价内边距效果。iOS xcodebuild + Android assembleDebug BUILD SUCCEEDED 0 错误。

## \[1.5.9] - 2026-09-12（Tag #78）

### Fixed

- **Tag #78 Android D2/D4 文字（及 D4 关闭叉）没有垂直居中**：根因=固定小高度标签（sm 20dp / md 24dp / lg 28dp，字号 11/12/14sp）内 `Text` 默认行高（≈字号×1.2+）大于字号——`Text` 行盒虽被外层 `Row` 的 `CenterVertically` 几何居中，字形仍按 baseline 在行盒内落位，视觉中线偏离标签几何中心；`Close` 矢量图标本身严格几何居中，故 D4 表现为文字与关闭叉不同轴，D2 纯文字标签同样视觉偏中（同根因对 D1/D3 同样生效，本次一并修复）。修复：① `Text` 收 `lineHeight = fontSize` 并设 `LineHeightStyle(alignment = Center, trim = Trim.Both)`，字形在行盒内几何居中（Compose BOM 2024.12.01 / UI 1.7 下 `includeFontPadding` 已默认 false，无需再设；对齐 iOS `UILabel` centerY 的视觉效果）；② closable 时文字与叉补 `Spacer(2dp)`，对齐 iOS `TagView.intrinsicContentSize` 中 `iconSize + 2` 的 2pt 间隙；③ 补 `tag-text` / `tag-close` 两个 testTag；④ Demo D1/D2 外层 `Row` 补 `verticalAlignment = CenterVertically`（与 D3 一致），徽标 v1.4.32→v1.5.9。新增 `TagTest` 4 例 Robolectric 真绿（三尺寸文字中心 Y=标签中心且高度 20/24/28dp、文字与关闭叉同轴且间隙 2dp 且叉 12dp、点叉触发一次 onClose、非 closable 无叉）。`:app:assembleDebug` BUILD SUCCESSFUL 0 错误（排查期出现的 884 个连锁 Unresolved reference 经定位为多会话并发下复合构建陈旧缓存，`--rerun-tasks` 全量重编后消失，非本次代码问题）。iOS `TagView` 本就是 label centerY + 关闭叉 `(h-iconW)/2` 几何居中，无需改动。

## \[1.5.8] - 2026-09-12（Slider #45）

### Fixed

- **Slider #45 iOS 滑块无法拖动**：根因=`SliderView` 继承 `UIControl` 用 `beginTracking/continueTracking/endTracking` 处理拖拽——这套机制依赖 UIKit touch 事件传递链（touchesBegan→touchesMoved→touchesEnded），而父 `UIScrollView` 默认 `canCancelContentTouches=true`，当用户在 Slider 上按下并拖动时，ScrollView 识别到手势后会调用 `touchesCancelled` 取消子视图的 touch tracking，导致 Slider 的 `continueTracking` 永远收不到 move 事件——Slider 完全无法拖动。修复：弃用 UIControl tracking 机制，改用 `UIPanGestureRecognizer`（拖拽）+ `UITapGestureRecognizer`（点击轨道跳转）——手势识别器由系统手势引擎统一调度，优先级高于 touch tracking，不会被 ScrollView 取消；同时实现 `UIGestureRecognizerDelegate.gestureRecognizerShouldRecognizeSimultaneouslyWith` 返回 `true`，让 Slider 的水平 pan 与父 ScrollView 的纵向 pan 并存（用户在 Slider 上水平拖=滑块移动、在 Slider 外垂直拖=页面滚动）。pan 算法改用 translation 增量计算（`began` 时记录起始 ratio、`changed` 时按平移增量更新 ratio），比旧版绝对坐标更稳定，不受 bounds 宽度抖动影响。xcodebuild BUILD SUCCEEDED 0 错误。

## \[1.5.7] - 2026-09-12（Pagination #71）

### Fixed

- **Pagination #71 iOS 分页数字不可见 + 居右（第 5 次修复=彻底重写）**：经前 4 次修复（c8c6d19/944a8de/639a0f2/4e553f7）均未解决，根因=三段式布局（prevContainer 外层左 / contentRow(UIScrollView) 中 / nextContainer 外层右）+ contentLayoutGuide 约束模型本身不可靠——按钮 `top.bottom.equalTo(clg)` + 自身 `width.height.equalTo(AppSpace.lg)` 在布局传递时被解析为 0 高度，`clipsToBounds=true` 裁切所有页码按钮内容；contentRow 宽度异常时 prev(左)+next(右) 中间空白表现为"居右"。修复：弃用三段式布局，改为与 Android `Row + horizontalScroll` 完全对齐的**单行方案**——所有元素（prev 按钮 + 页码按钮 + next 按钮）在同一个 `UIStackView`（horizontal, spacing=AppSpace.xs, alignment=.center）水平排列、垂直居中；外层 `UIScrollView` 支持横向滚动（页码超出屏幕时可滑动）。约束关键：`stackView.top.bottom → scrollView.frameLayoutGuide`（垂直固定到可见区域、不参与 contentSize 计算）、`stackView.leading.trailing → scrollView.contentLayoutGuide`（水平定义 contentSize.width、超出时滚动）、`stackView.height = AppSpace.lg`（固定按钮高度、垂直不滚动）。xcodebuild BUILD SUCCEEDED 0 错误。

## \[1.5.6] - 2026-09-12（Steps #75）

### Fixed

- **Steps #75 双端连线与步骤节点断开**：设计规格 CSS 原型 `.steps-h .line{left:50%;right:-50%}` 明确连线应**圆心→圆心贯穿**（圆片不透明、层级在线之上盖住线头）。两端旧实现都只把线画到等宽 cell 的边界，与下一圆心空半列；Android 竖向还在连线之外另加 16dp 行外 Spacer 造成竖线断口。Android `Steps.kt`：横向每个 cell 补「左半段（cell 左缘→本圆心）」与相邻 cell 的右半段无缝拼接，左半段颜色随连线 index-1 的完成态（`index-1 < current` 主色）；竖向 56dp 行距全部并入连线高度、删除行外 Spacer；圆/线补 testTag。iOS `StepsView.swift`：横线 `leading=本圆心`，`rebuild()` 全部 cell 建完后跨 cell 约束 `trailing=下一圆点 centerX`（不能用 multiplier 乘自身 centerX，cell 原点非零时会被一起放大），line 先于圆点 `addSubview` 置于圆下层；竖向 fillEqually 本就连到下一圆顶，无需改。新增 `StepsTest` 3 例 Robolectric 真绿：横向 4 圆+左右半段各 3 根（首无左/末无右）、三条连线圆心→圆心无缝拼接且垂直居中、竖向竖线圆底→下一圆顶零间隙。

## \[1.5.5] - 2026-09-12（DropDown，commit ecb4285）

### Fixed

- **DropDown/DropDownMenu iOS Demo 不可见 + 按钮无法点击**：三处根因修复：① Demo 1/2/3 的 DropDownView/DropDownMenuView 缺 `bottom.equalToSuperview()` 约束 → 容器在 UIStackView 中高度 = 0 → DropDownView 不可见、DropDownMenuView 按钮虽渲染但 `hitTest` 的 `point(inside:)` 对 0 高容器返回 false → 触摸不传递 → 按钮无法点击。② `openPanel()` 的 panel 原添加为 DropDownView 自身 subview → 面板超出 DropDownView bounds → `hitTest` 不返回面板内 cell → 面板项不可点击。改为挂载到 `anchorView.window`（key window），用 anchor 的 window 坐标定位。③ `DropDownMenuView.columnTapped` 不再 unhide DropDownView（panel 已挂 window，无需可见），传 `anchor: buttons[idx]` 使面板直接出现在 bar button 下方而非隐藏的 trigger button 下方。

## \[1.5.4] - 2026-09-12（Slider #45，commit 890ec0b）

### Fixed

- **Slider #45 Android thumb 圆形位于横线上方（未与轨道垂直居中）**：`Slider.kt` 灰轨道与 primary 激活段均以 `Alignment.CenterStart` 对齐——在 44dp 高容器内已垂直居中（中心 22dp）——却又叠加 `offset(y = (44-4)/2 = 20dp)`，轨道被二次下移到 y=40 贴底（中心 42dp）；thumb 仅 CenterStart 无 y 偏移（中心 22dp），于是圆形跑到横线上方 20dp。修复：删除轨道/激活段两处多余 y 偏移，三层（thumb/灰轨道/激活段）共用 CenterStart 同轴居中，与 iOS `SliderView`（trackY=20、thumbY=10，中心同为 22pt）一致；同时为三层补 `slider-track/slider-active/slider-thumb` testTag。回归台账 #54 建档，新增 `SliderTest` 7 例 Robolectric 真绿：value 0/50/100 三档三层中心 Y=容器中心、轨道 4dp/thumb 24dp 同轴、点击轨道两端回调 0/100、steps=3 分档点击吸附 50。

<!-- ⚠️ 治理流程回滚+二次回滚记录（2026-09-04）：阶段 1（越界）= AI 违规越过门禁 A/B 用户评审，把 reviewed=True + v1.4.0 + [1.4.0] 段写入 → 用户指出治理回滚；阶段 2（假交付）= A/B 评审单用户 21/21 通过后推进 C2+D，仍未满足新增门禁 L269+1=C1.5 Demo 验收=双端真 build 0 error + 用户亲自 Demo 验收双通过=假交付；用户实际 iOS Xcode build 3 报错（L1382 nil String / L1794 Overlay / L1863 OverlayMaskColor 找不到类型 = DemoShowcases.swift 源码错 1 + XcodeGen 工程未 regenerate=Build Phases 缺 Overlay.swift 编译源 2）→ 本阶段二次回滚：恢复基线 v1.3.12（和阶段 1 回滚后一致），[1.4.0] 整段删除 + reviewed=False 切回 + 基础类 6/6 说法作废。A/B 评审 21/21 通过仍然有效，待 C1.5 Demo 满足 L269+1 后再合法推进 C2/D。⚠️ -->

## \[1.5.4] - 2026-09-12（Pagination #71，commit 4e553f7）

### Fixed

- **Pagination iOS 分页数字不可见**：`PaginationView.setup()` 中 `prevContainer`（普通 UIView）只有 `leading.top.bottom` 无宽度约束，`contentRow`（UIScrollView）只有 `leading` 无 `trailing` 约束，`nextContainer` 只有 `trailing` 无宽度约束 → 三者宽度均不确定，Auto Layout 将 `contentRow` 宽度解析为 0 → `clipsToBounds` 裁切内部所有页码按钮，用户只看到 chevron 箭头看不到数字。修复：`prevContainer`/`nextContainer` 补 `width.equalTo(AppSpace.lg)` 显式宽度，`contentRow` 补 `trailing.equalTo(nextContainer.snp.leading).offset(-AppSpace.xs)` 完成宽度链。

## \[1.5.3] - 2026-09-12

### Fixed

- **Row Demo 1-3 iOS 色块不可见**：`RowShowcase` Demo 1-3 的 `RowView` 仅用 `top + bottom.equalToSuperview()` 约束填满容器，但容器是 `UIStackView` 中的 `UIView` 无固有高度→高度链断裂→`makeBox` 的 `UIView`（无 intrinsicContentSize）坍缩为 0 高→浅绿色（`primaryMuted`）和深绿色（`primary`）色块不可见，与 Android `DemoColBox` 的 `.height(40.dp)` 不一致。修复：Demo 1-3 的 `RowView` 约束补 `make.height.equalTo(40)`，与 Android `DemoColBox` 40dp 固定高度对齐；Demo 4 不受影响（已用 `height.equalTo(60)`）。补充（工作区遗留改动随提交）：外层 RowView 定高后内层 `makeBox` 色块经 ColView 传递仍可能坍缩，Demo 1-3 内层色块约束追加 `$0.height.equalTo(40)` 双保险。

## \[1.5.2] - 2026-09-12

### Fixed

- **PickerView #34 Android Demo 整页无法拖动**：`PickerViewDemo`（注册名「PickerView 多列选择器」）直接堆叠 4 个完整 Picker（工具栏 44 + 滚轮 220=各 264dp）与文案，总高远超一屏；而宿主详情页 `TmoDemo` 是不带滚动的普通 `Column`、Demo 自身也无 `verticalScroll`，导致整页拖不动、D3 禁用态 / D4 受控驱动不可达。修复：`PickerViewDemo` 外层补 `Column.fillMaxWidth().verticalScroll(rememberScrollState()).padding(...)`，与已通过 C1.5 的 `PickerDemo`（#33）同构；内层定高 LazyColumn 滚轮与外层页面同向嵌套滚动可正常工作（PickerDemo 已实机验证）。回归台账 #53 建档（L4 实机拖页+滚轮双手势）。

## \[1.5.1] - 2026-09-12

### Fixed

- **DropDownMenu #22 iOS 编译错误修复**：`DropDownMenuView.columnTapped`（DropDownMenuView.swift:331）调用 `DropDownView.openPanel()` 编译报错 `'openPanel' is inaccessible due to 'private' protection level`。根因：2026-09-12 C1.5 修复「Demo2 点击菜单无反应」时在 columnTapped 补了 `openPanel()` 调用，但 `openPanel()` 仍声明为 `private`，跨类不可见。修复：`openPanel()` 由 `private` 改为 internal（同模块可调用），与已公开的 `closePanel()` 配套，供 `DropDownMenuView` 容器统一管理展开/收起。

## \[1.4.31] - 2026-09-11

信息展示区三组件合并发版（Price 价格 #72 + Progress 进度条 #73 + Steps 步骤条 #75，MINOR）。

### Added

- **Price 价格双端组件入库（#72 ui.price）**：
  - iOS `PriceView.swift`（UIKit）：UIStackView 水平排列 prefix/symbol/int/dec/suffix，alignment=.lastBaseline 底部对齐；NumberFormatter 千分位+maximumFractionDigits 小数位+四舍五入；PriceSize（small/medium/large）映射整数/符号字号；PriceSymbolPosition（front/after）；默认 AppColor.error，前后缀 textSecondary+sizeXs。
  - Android `Price.kt`（Compose）：Row(Alignment.Bottom) 顺序渲染 Text，DecimalFormat 千分位+小数位四舍五入；与 iOS 同构的 PriceSize/PriceSymbolPosition 枚举、API 对齐。
  - 门禁 A：`price-design-spec.html`+`review-price-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.price` 条目（reviewed=true）。
- **Progress 进度条双端组件入库（#73 ui.progress）**：
  - iOS `ProgressView.swift`（UIKit）：轨道+填充条双层，percentage didSet 驱动 0.3s 动画；颜色/轨道色/高度/显示文字/文字色/动画开关。
  - Android `Progress.kt`（Compose）：animateFloatAsState tween 300 驱动填充宽度；同 API 契约。
  - 门禁 A：`progress-design-spec.html`+`review-progress-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.progress` 条目（reviewed=true）。
- **Steps 步骤条双端组件入库（#75 ui.steps）**：
  - iOS `StepsView.swift`（UIKit）：三态（已完成 primary 填充+白对勾 / 当前白底 primary 描边+数字 / 未开始白底灰描边+灰数字），连线已完成段主色/未完成段灰色；items+current(-1=自管理/≥0=受控)+direction(horizontal/vertical)+onChange。
  - Android `Steps.kt`（Compose）：同三态逻辑+同 API 契约。
  - 门禁 A：`steps-design-spec.html`+`review-steps-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.steps` 条目（reviewed=true）。
- **三件双端 Demo 4 段 1:1**：Price（D1 基础价格/D2 千分位+小数位/D3 符号大小位置/D4 前后缀）/ Progress（D1 基础进度条/D2 自定义颜色+高度/D3 百分比文字/D4 动态进度）/ Steps（D1 基础步骤条/D2 横向+竖向/D3 当前步骤高亮/D4 自定义图标）。

### Fixed

- **api.json componentCount 修正**：三子 agent 各自+1导致 48/49/51/75 冲突，统一修正为 77（实际 ui.* 条目数）。

### Patched

- 组件库全局版本 1.4.30 → 1.4.31。

***

## \[1.4.30] - 2026-09-11

信息展示区三组件合并发版（Indicator 指示器 #69 + Lottie 动画 #70 + Pagination 分页 #71，MINOR）。

### Added

- **Indicator 指示器双端组件入库（#69 ui.indicator）**：
  - iOS `IndicatorView.swift`（UIKit）：UIView 子类+UIStackView（axis 随 direction 变化）排布圆点；showNumber=true 渲染数字胶囊 UILabel「current+1/total」；block=false 选中点色变（gray15→primary），block=true 选中点变长条（width=size*2.5）；SnapKit 约束。
  - Android `Indicator.kt`（Compose）：Row/Column（Arrangement）排布圆点；showNumber=true 渲染数字胶囊 Text；block=false 选中点色变，block=true 选中点变长条 Box；CircleShape/RoundedCornerShape 圆角。
  - 门禁 A：`indicator-design-spec.html`+`review-indicator-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.indicator` 条目（reviewed=true）。
- **Lottie 动画双端组件入库（#70 ui.lottie）**：
  - iOS `LottieView.swift`（UIKit）：一期占位渲染（UIActivityIndicatorView 环形旋转）+source=动画名称占位；API 契约与二期（Lottie 库集成）完全一致；play()/pause()/stop() 命令式控制；onComplete 回调（仅 loop=false 触发）。
  - Android `Lottie.kt`（Compose）：一期占位渲染（CircularProgressIndicator 环形旋转）；同样 API 契约；play()/pause()/stop() 命令式控制。
  - 门禁 A：`lottie-design-spec.html`+`review-lottie-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.lottie` 条目（reviewed=true）。
  - 备注：一期占位渲染，二期 Lottie 库集成后激活真实渲染，调用方零改动。
- **Pagination 分页双端组件入库（#71 ui.pagination）**：
  - iOS `PaginationView.swift`（UIKit）：UIStackView 横向排布+UITapGestureRecognizer+objc 遵手册禁令；省略号折叠算法=当前页居中 window+首尾固定+省略号（双端纯函数一致）。
  - Android `Pagination.kt`（Compose）：Row+RoundedCornerShape 遵安卓禁令；省略号折叠算法同 iOS。
  - 核心 API：currentValue(0=内部自管理/>0=受控)、total、pageSize、itemSize、mode(multi/simple)、onChange。
  - 门禁 A：`pagination-design-spec.html`+`review-pagination-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.pagination` 条目（reviewed=true）。
- **三件双端 Demo 4 段 1:1**：Indicator（D1 基础指示器/D2 数字总页数/D3 竖向/D4 自定义样式）/ Lottie（D1 基础循环播放/D2 单次播放+回调/D3 播放控制/D4 自定义尺寸）/ Pagination（D1 基础分页/D2 简洁模式/D3 显示省略号/D4 自定义按钮数）。
- **api.json componentCount 45→48**（+3 新组件）。

### Patched

- 组件库全局版本 1.4.29 → 1.4.30。

***

## \[1.4.29] - 2026-09-10

TrendChartView 双端视觉对齐修复（PATCH）。

### Fixed

- **Android TrendChartView 4 处视觉差异对齐 iOS**：
  - ① **数据节点圆圈恢复显示**：原 Canvas padLeft=40f(px) 远小于 Y 轴标签 40dp(≈105px@density=2.625)，数据点圆圈画在 Y 轴标签区域内被文字覆盖；重构后单 Canvas 统一绘制，圆圈不再被覆盖。
  - ② **起始点不再跑进纵坐标**：原第一个数据点 x=40px 落在 Y 轴标签 40dp 区域内；重构后 yAxisWPx=40dp 经 LocalDensity 转 px，第一个数据点在 Y 轴标签右侧。
  - ③ **X 轴标签上方圆圈对齐**：原数据点 x 坐标与 X 轴标签 x 坐标不对齐；重构后 X 轴标签用 nativeCanvas 居中绘制到数据点 x 坐标，与 iOS Charts labelCount 对齐。
  - ④ **数据区域底部横线恢复显示**：原底部网格线 y=canvasH-24px 被 X 轴标签 Row 覆盖；重构后网格线+X 轴标签在同一 Canvas 内统一绘制，底部网格线（gridCount=4 i=4）正常显示。
- **核心改动**：原 Box(Canvas+Y轴标签Row+X轴标签Row 三层叠加) → 单 Canvas 统一绘制网格线+Y轴标签+折线+圆点+X轴标签，padLeft/padBottom 从 40f/24f 像素值改为 40.dp/24.dp 经 LocalDensity 转 px，Y轴标签用 nativeCanvas+Paint 精确对齐网格线 y 坐标，X轴标签用 nativeCanvas 居中对齐数据点 x 坐标。

### Patched

- 组件库全局版本 1.4.28 → 1.4.29。

***

## \[1.4.28] - 2026-09-10

信息展示区三组件合并发版（Collapse 折叠面板 #65 + CountDown 倒计时 #66 + Ellipsis 文本省略 #67，MINOR）。

### Added

- **Collapse 折叠面板双端组件入库（#65 ui.collapse）**：
  - iOS `CollapseView.swift`（UIKit）：UIStackView 垂直布局+tap 手势+chevron 旋转+contentContainer 显隐；混合受控 activeKeys（nil=内部自管理，非空=受控）；accordion 手风琴互斥。
  - Android `Collapse.kt`（Compose）：混合受控（activeKeys null 走内部状态）+accordion 手风琴+chevron 旋转 90°+disabled 置灰+分隔线。
  - 门禁 A：`collapse-design-spec.html`+`review-collapse-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.collapse` 条目（reviewed=true）。
- **CountDown 倒计时双端组件入库（#66 ui.count-down）**：
  - iOS `CountDownView.swift`（UIKit）：UIView 子类+SnapKit 内嵌 UILabel；Timer.scheduledTimer 每秒基于时间戳重算 remaining=target-now+pausedAccum+ongoing（无累积误差）；targetTime/remaining 双入口（targetTime 优先）；paused 半受控（pause 记 pauseStart+invalidate，resume 折叠暂停时长进 pausedAccum+重建 Timer）；format replacingOccurrences DD/HH/mm/ss；onEnd 逃逸闭包 [weak self]+显式 self. 前缀+ended 防重；monospacedDigitSystemFont 等宽数字防秒数抖动。
  - Android `CountDown.kt`（Compose）：LaunchedEffect+delay(1000) 每秒同算法重算；targetTime/remaining 双入口；paused 半受控（running=autoStart&&!paused）；format replace DD/HH/mm/ss；onEnd 在 remMs≤0 触发一次。
  - 门禁 A：`countdown-design-spec.html`+`review-countdown-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.count-down` 条目（reviewed=true）。
- **Ellipsis 文本省略双端组件入库（#67 ui.ellipsis）**：
  - iOS `EllipsisView.swift`（UIKit）：UIView 子类包裹 UILabel+展开按钮 UILabel；收起态 numberOfLines=rows+lineBreakMode=.byTruncatingTail；展开态 numberOfLines=0；UITapGestureRecognizer(target:action:) 老式点击（兼容低版本）；expanded didSet 响应式更新；半受控 expanded（nil=内部自持）。
  - Android `Ellipsis.kt`（Compose）：Column 包裹 Text+展开按钮 Text；收起态 maxLines=rows+overflow=TextOverflow.Ellipsis；展开态 maxLines=Int.MAX_VALUE；expanded=null 内部 remember mutableStateOf 自持/非 null 外部驱动；Modifier.clickable 点击切换。
  - 门禁 A：`ellipsis-design-spec.html`+`review-ellipsis-A.md`（AI 代评 A1-A7 全 ✅）；门禁 B：api.json `ui.ellipsis` 条目（reviewed=true）。
- **三件双端 Demo 4 段 1:1**：Collapse（D1 基础折叠/D2 手风琴/D3 禁用项/D4 受控外部驱动）/ CountDown（D1 基础倒计时/D2 跨天格式/D3 暂停继续/D4 结束回调）/ Ellipsis（D1 单行省略/D2 多行省略 rows=3/D3 自定义文案/D4 受控外部驱动）。
- **api.json componentCount 42→45**（+3 新组件）。

### Fixed

- **CountDown iOS 编译错误修复**：`Date.timeIntervalSince1970` 是实例属性非静态属性，需用 `Date().timeIntervalSince1970`（创建 Date 实例后访问）。全文件 5 处替换。

### Patched

- 组件库全局版本 1.4.27 → 1.4.28。

## \[1.4.27] - 2026-09-10

Carousel iOS 指示器恢复正式绿色 + 清理调试代码（PATCH）。

### Fixed

- 去掉 applyIndicatorColors 中的红色调试 tint，恢复正式色（indicatorColor + 30% 透明）。
- 去掉 rebuildIndicators 中的 print 调试日志。

### Patched

- 组件库全局版本 1.4.26 → 1.4.27。

## \[1.4.26] - 2026-09-10

Carousel iOS 指示器根因修复——init 内赋值 stored property 不触发 didSet（PATCH）。

### Fixed

- **Carousel iOS 指示器 numberOfPages 不生效根因修复**：Swift 语言特性——convenience init 内 `self.items = items` 赋值 stored property **不触发 didSet**，导致 `rebuildIndicators()` 从未被调用，pageControl.numberOfPages 保持 0，dot 不可见。修复：convenience init 内 items 赋值后显式调用 `rebuildIndicators() + collectionView.reloadData() + resetToStartPosition()`。

### Patched

- 组件库全局版本 1.4.25 → 1.4.26。

## \[1.4.25] - 2026-09-10

Carousel iOS 指示器恢复正式色 + backgroundStyle=minimal（PATCH）。

### Fixed

- **Carousel iOS 指示器 dot 不可见修复**：色彩调试法验证 pageControl 渲染正常（红色横条可见），根因=系统默认 backgroundStyle 气泡干扰 dot 可见性。去掉红色调试背景，恢复正式色（indicatorColor + 30% 透明），iOS 14+ 显式设 `backgroundStyle = .minimal`。

### Patched

- 组件库全局版本 1.4.24 → 1.4.25。

## \[1.4.24] - 2026-09-10

Carousel iOS 指示器改用 UIPageControl + 红色调试背景（DEBUG）。

### Changed

- **Carousel iOS 指示器彻底换方案**：放弃自定义 dot + 手动布局（多次尝试 UIStackView/UIView+手动布局/startX 计算均不可见），改用 iOS 原生 UIPageControl。
- **色彩调试法**：pageControl 加红色背景 + width=100，验证是否渲染（用户反馈多轮修改均不可见，需排查是否根本未渲染）。

### Patched

- 组件库全局版本 1.4.23 → 1.4.24。

## \[1.4.23] - 2026-09-10

Carousel iOS 指示器不可见修复（PATCH）。

### Fixed

- **Carousel iOS 指示器不可见修复**：UIStackView 无 intrinsicContentSize（UIView 无 intrinsicContentSize）导致 size=0×0，dot 不可见。改用 UIView + 手动布局 dot：leading offset 逐个排列（i × (8+8)）+ indicatorContainer width=总宽度约束 + height=8 约束。

### Changed

- 组件库全局版本 1.4.22 → 1.4.23（PATCH，iOS 指示器修复）。

## \[1.4.22] - 2026-09-10

Carousel iOS Demo 统一（PATCH）。

### Fixed

- **Carousel iOS Demo 统一**：`makeBannerImage` 去掉白色大圆，改为纯色背景+居中文字，与 Android `makeCarouselPage` 1:1 对齐。之前 iOS 参考了 ImageShowcase 的样例图（带白色大圆），Android 是纯色+文字，导致双端 Demo 不一致。

### Changed

- 组件库全局版本 1.4.21 → 1.4.22（PATCH，Carousel Demo 统一）。

## \[1.4.21] - 2026-09-10

Carousel 轮播组件全新立项（MINOR，信息展示区 #59）。

### Added

- **Carousel 轮播组件双端实现**（门禁 A→B→C1 全走）：
  - 门禁 A 设计规格：`design-spec/carousel-design-spec.html`（SCQA/PREP/ACE/平台差异/anti_goals 全覆盖）
  - 门禁 B api.json 契约：items/autoPlay/duration/loop/showIndicators/indicatorColor/currentIndex/onChange（componentCount 41→42）
  - 门禁 C1 双端实现：
    - iOS `CarouselView.swift`：UICollectionView+isPagingEnabled+Timer 自动播放+10000 倍假循环+8×8 圆点指示器
    - Android `Carousel.kt`：HorizontalPager+rememberPagerState+LaunchedEffect+delay 自动播放+Int.MAX_VALUE 假循环
  - 双端 Demo：D1 基础轮播/D2 关闭自动播放/D3 关闭循环/D4 自定义指示器颜色（红色）
  - 双端编译 BUILD SUCCEEDED

### Fixed

- iOS CarouselView convenience init 默认参数引用 internal `AppColor` 编译错误：改 `indicatorColor: UIColor? = nil` + 内部赋值。

### Changed

- 组件库全局版本 1.4.20 → 1.4.21（MINOR，新组件 Carousel 立项）。

## \[1.4.20] - 2026-09-10

Skeleton D1 约束冲突+容器高度+红色调试背景彻底修复（PATCH）。

### Fixed

- **Skeleton D1 stack 约束冲突修复**：realView 的 stack 约束 `edges.equalToSuperview()` + `height.equalTo(40)` 冲突——edges 含 top/bottom/leading/trailing 撑满 64pt row，加 height=40 矛突，Auto Layout 破坏布局导致骨架灰色文案盖住真实内容。修复：改为 `leading.trailing+centerY+height=40` 消除冲突。
- **Skeleton D1 容器高度不足修复**：3 行 row 用手动约束排列，最后一行（i==3）无 `bottom` 约束，container 无底部锚点高度为 0，Demo2 直接盖住 Demo1。修复：i==3 时加 `make.bottom.equalToSuperview()` 让 container 撑开到 3×64=192pt。
- **Skeleton D3 红色调试背景彻底清除**：上次 Edit 未真正生效（skeletonContainer 红色背景仍在），本次重新删除，红色调试色已彻底清除。

### Changed

- 组件库全局版本 1.4.19 → 1.4.20（PATCH，Skeleton D1 约束+容器高度+调试色彻底修复）。

## \[1.4.19] - 2026-09-10

Skeleton 三处布局修复 + 调试颜色清除（PATCH）。

### Fixed

- **Skeleton D1 文字重叠修复**：Demo1 realView 的 stack 约束冲突——`edges.equalToSuperview()`（撑满 row 64pt）+ `height.equalTo(40)` 矛突，Auto Layout 破坏布局导致文字错位。修复：改为 `leading.trailing.equalToSuperview()` + `centerY.equalToSuperview()` + `height.equalTo(40)`，消除冲突。
- **Skeleton D3 调试颜色清除**：SkeletonRow 组件代码 `updateSkeletonLayout()` 残留色彩调试法标记——skeletonContainer 红色背景 + textCol 蓝色背景，影响所有 SkeletonRow 用户（D1/D3）。已删除两行调试背景色。
- **Skeleton D4 圆形盖住 title 修复**：Demo4 圆形 row 用 `make.center.equalToSuperview()`，64pt 圆形以容器中心定位，向上超出容器边界盖住 title。修复：改为 `make.top.bottom.equalToSuperview().inset(AppSpace.sm)` + `make.centerX.equalToSuperview()`，圆形 row 受容器边界约束。

### Changed

- 组件库全局版本 1.4.18 → 1.4.19（PATCH，Skeleton 布局修复+调试颜色清除）。

## \[1.4.18] - 2026-09-10

List/SummaryCard/TrendChart Demo 滚动修复（PATCH）。

### Fixed

- **List/SummaryCard/TrendChart 三处 Demo 外层 Column 补 verticalScroll**：与 AvatarDemo 同一根因（#55），4 组 Demo 超出屏幕无法下滑。本次一次性批量排查修掉 MainActivity 中所有漏 verticalScroll 的 Demo（List L1244 / SummaryCard L1668 / TrendChart L1738）。

### Changed

- 组件库全局版本 1.4.17 → 1.4.18（PATCH，Demo 滚动批量修复）。

## \[1.4.17] - 2026-09-10

Avatar 测试用例沉淀 + 标记已通过（PATCH）。

### Added

- **Avatar #53~#55 自动化单测 AvatarTest.kt（8 用例全绿）**：覆盖 2026-09-10 多轮调试复盘的三个根因，防复发：
  - #53 iOS UIView 在 UIStackView 中无 intrinsicContentSize 退化成 0 → L1 容器尺寸=size 参数校验（3 用例：option=null/非null/自定义40dp）
  - #54 Android Color(tintHex) RGB 3字节当 ARGB=alpha=0 透明 → L1 avatarTintColor 补 0xFF alpha 校验（2 用例：单色+五星座色）+ 文字节点存在校验（2 用例：昵称首字+星座符号）
  - #55 AvatarDemo 外层漏 verticalScroll → 容器尺寸用例间接保证内容可渲染
- **ProfileAvatarComponents.kt 加 testTag + 提取 avatarTintColor 为 internal 函数**：供单测定位节点与直接验证颜色不透明。

### Changed

- Avatar 双端标记 passed=true（已通过）。
- 组件库全局版本 1.4.16 → 1.4.17（PATCH，测试用例沉淀）。

## \[1.4.16] - 2026-09-10

Avatar Android 星座符号透明修复 + Demo 可滚动（PATCH）。

### Fixed

- **Avatar Android 星座符号文字透明修复**：`ZodiacAvatar` 内 `Color(option.tintHex)` 把 `0xDC2626`（RGB 3字节）当成 ARGB 4字节处理，alpha=0x00 透明，导致 Demo2/Demo3 星座符号 ♈♉♊♋♌ 看不见（背景 `.copy(alpha=0.18f)` 会覆盖 alpha 所以可见，文字没 .copy 所以透明）。修复：加 `tintColor(hex) = Color(0xFF000000 or hex)` helper 补 0xFF alpha 前缀，与 iOS `UIColor(hex:alpha:)` RGB 语义对齐。
- **AvatarDemo Android 可滚动**：外层 Column 漏加 `verticalScroll(rememberScrollState())`，4 组 Demo 超出屏幕无法下滑看 Demo4。修复：补加 verticalScroll。

### Changed

- 组件库全局版本 1.4.15 → 1.4.16（PATCH，Avatar Android 星座符号透明+Demo 滚动修复）。

## \[1.4.15] - 2026-09-10

Avatar iOS 尺寸缺陷修复（PATCH）。

### Fixed

- **Avatar iOS 尺寸退化修复**：`ZodiacAvatarView.apply()` 之前只给 `symbolLabel` 加 `edges.equalToSuperview()`，未给自身设 width/height 约束——UIView 在 UIStackView 中无 `intrinsicContentSize` 会退化成 0，导致 iOS 头像明显小于 Android `.size(diameter)`。修复：`apply` 时调用 `snp.remakeConstraints { make.width.height.equalTo(diameter) }`，与 Android `.size(size)` 1:1 对齐。

### Changed

- 组件库全局版本 1.4.14 → 1.4.15（PATCH，Avatar iOS 尺寸缺陷修复）。

## \[1.4.14] - 2026-09-09

Popup 回归测试用例沉淀（PATCH）。

### Added

- **Popup #54 自动化单测 PopupTest.kt（10 用例全绿）**：覆盖回归台账 #47~#52 六个历史根因：
  - #47 蒙版透明度：蒙版节点存在 + closeOnClickOverlay 点击语义（alpha 实机比对=L4）
  - #48 center 气泡尺寸：center 容器 minWidth ≥ 240dp
  - #49 bottom 高度：bottom 容器 minHeight ≥ 120dp（content 高度不含 navigationBarsPadding）
  - #50 padding 对齐：closeable 容器高度 ≥ 40dp（顶部留白）+ 非 closeable 对比
  - #51 fillMaxWidth 通栏：center minWidth 反向校验（不通栏）
  - #52 closeable 关闭按钮：24dp 按钮存在 / 非 closeable 不存在
- **Popup.kt 加内部 testTag**：`PopupTestTags.MASK/CONTAINER/CLOSE_BUTTON`，供单测定位蒙版/容器/关闭按钮。

### Changed

- 组件库全局版本 1.4.12 → 1.4.13（PATCH，回归测试用例沉淀）。

## \[1.4.12] - 2026-09-08

Popup Demo 通栏修复 + Demo2 底部高度对齐（PATCH，色彩调试法定位）。

### Fixed

- **Popup #54 Demo1/3/4 Android 文字 fillMaxWidth 导致弹层通栏**：v1.4.11 给 Text 加了 `Modifier.fillMaxWidth()` 实现 `textAlign=Center`，但 Popup 用 `androidx.compose.ui.window.Popup`（全屏约束），`fillMaxWidth` 让 Text 占满全屏宽度 → 容器 `defaultMinSize(minWidth=240.dp)` 取 `max(全屏, 240dp)` = 全屏 = "通栏"。修复=去掉 `fillMaxWidth`，改用 `defaultMinSize(minWidth=208.dp)`，Text 固定 208dp 宽（= iOS UILabel 240-32=208pt），`textAlign=Center` 生效且容器保持 240dp 不通栏。

- **Popup #54 Demo2 bottom 弹层高度不一致（被导航栏遮挡）**：v1.4.11 去掉 `navigationBarsPadding()` 后弹层贴到屏幕底部，被系统导航栏遮挡，可见高度 = 120dp - 导航栏高度(~48dp) = 72dp ≈ 1.5 个按钮。iOS 用 `safeAreaLayoutGuide` 贴到安全区底部（不被遮挡）= 120pt ≈ 3 个按钮。修复=`navigationBarsPadding()` 放在 `heightIn(min=120.dp)` **之前**（更外层），让 `heightIn` 限制的是 content 高度（不含 padding），`clip`+`background` 放最后（最内层）只覆盖 content 区域，padding 区域透明——弹层贴到安全区底部，可见高度 = content 高度 = 120dp，与 iOS 一致。

### Changed

- 组件库全局版本 1.4.11 → 1.4.12（PATCH，Popup Demo 通栏+高度修复）。

## \[1.4.11] - 2026-09-08

Popup Demo 文字居中 + Demo2 底部高度对齐（PATCH）。

### Fixed

- **Popup #54 Demo Android 文字左对齐 → 水平居中**：iOS `makeLabel` 用 `label.textAlignment = .center`，Android `Text` 默认左对齐。修复=4 个 Popup 的 Text 加 `textAlign = TextAlign.Center` + `modifier = Modifier.fillMaxWidth()`（fillMaxWidth 让 Text 占满容器宽度，textAlign 才能生效）。

- **Popup #54 Demo2 底部弹层高度不一致**：iOS 用 `safeAreaLayoutGuide.snp.bottom` 贴到安全区底部（不额外加 padding），Android 旧版 `navigationBarsPadding()` 额外加安全区高度（~24-48dp）导致 Android 比 iOS 高一个安全区。修复=Android BOTTOM 容器去掉 `navigationBarsPadding()`，与 iOS 一致贴到安全区底部。

### Changed

- 组件库全局版本 1.4.10 → 1.4.11（PATCH，Popup Demo 对齐）。

## \[1.4.10] - 2026-09-08

Popup 气泡尺寸 padding 统一（PATCH，色彩调试法定位）。

### Fixed

- **Popup #54 Android 弹层尺寸与 iOS 不一致（色彩调试法定位）**：两端 padding 结构不同导致弹层总高度差 12dp。色彩调试法拆解 padding 层级对比：
  - **iOS（PopupContainerView.replaceContent）**：content 约束 `leading/trailing=AppSpace.lg(16)` + `top=closeable?40(24+8*2):4(AppSpace.sm)` + `bottom=AppSpace.sm(4)`
  - **Android 旧版**：center 容器有 `.padding(horizontal=AppSpace.lg(16))` + content 槽 `.padding(top=closeable?32:0)` + 无 bottom padding
  - **差异**：顶部 closeable 差 8dp（40 vs 32）、非 closeable 差 4dp（4 vs 0）、底部差 4dp（4 vs 0）= 总高度差 12dp（closeable）或 8dp（非 closeable）
  - **修复**：Android 容器去掉 `horizontal=AppSpace.lg` padding（center），统一在 content 槽设置 `.padding(top=closeable?40dp:AppSpace.sm, start=AppSpace.lg, end=AppSpace.lg, bottom=AppSpace.sm)`，与 iOS 完全一致。bottom/top 容器也去掉残留 `.padding(bottom=AppSpace.sm)`，统一由 content 槽处理。

### Changed

- 组件库全局版本 1.4.9 → 1.4.10（PATCH，Popup padding 统一）。

## \[1.4.9] - 2026-09-08

Popup 去系统 dim / Popover 气泡尺寸 + Demo 统一 / Drag z-order 修复（PATCH，跨端一致性 v3）。

### Fixed

- **Popup #54 Android 蒙版透明度明显高于 iOS（根因修复）**：Android 用 `Dialog` 组件，`Dialog` 系统级会添加 dim 层（~0.6 alpha）叠加在我们的 `Color.Black.copy(alpha = 0.45f)` 蒙版上，总暗度远超 iOS 的 0.45。改为 `androidx.compose.ui.window.Popup` + `FullScreenPopupPositionProvider`（`IntOffset(0,0)` + `fillMaxSize()`），Popup 不添加系统 dim，只有我们的 0.45 黑色蒙版，与 iOS 完全一致。`PopupProperties(focusable=true, dismissOnBackPress=closeOnClickOverlay, dismissOnClickOutside=false)`——`dismissOnClickOutside=false` 由蒙版 `clickable` 自行处理。

- **Popup #54 Demo 气泡尺寸不一致**：Android Demo 的 `Text` 有 `Modifier.padding(AppSpace.xl)`(24dp) 额外 padding，iOS `UILabel` 无 padding。容器自带 `horizontal=AppSpace.lg`(16dp) padding，Android 叠加后内容区=240-16*2-24*2=160dp，iOS=240-16*2=208pt，差异 48dp。去掉 Android Text 的 `padding(AppSpace.xl)` 后两端一致。

- **Popover #53 iOS 气泡尺寸太小（还没内容大）**：根因=`arrowView.translatesAutoresizingMaskIntoConstraints=false`（在 `setupViews` 中设置），Auto Layout 覆盖 `layoutBubbleFrame()` 中的 `arrowView.frame=arrowRect` 赋值。修复=`show()` 中加 `arrowView.translatesAutoresizingMaskIntoConstraints=true`。同时 `content` 尺寸从 `sizeToFit()` 改为 `intrinsicContentSize`（`UIStackView.sizeToFit()` 返回 `.zero`），`sizeToFit()` 作 fallback。加最小气泡尺寸 `80x30` 防止 content 尺寸为 0 时气泡不可见。

- **Popover #53 Demo 内容统一**：iOS D1-D3 用 label "气泡提示内容"、D4 用 UIStackView 菜单(复制/删除/分享)；Android D1-D4 全部用菜单。改为 iOS D1-D4 全部用菜单（与 Android 一致）。`makeMenuContent()` 从 `UIStackView` 改为 `UILabel + attributedText`(numberOfLines=0)，因为 `UIStackView.intrinsicContentSize` 返回 `.zero` 导致气泡尺寸计算为 0。用 `NSMutableParagraphStyle.lineSpacing=4` 控制行间距。

- **Drag #47 Android 被拖动项 z-order 置顶**：LazyColumn 中被拖动项被相邻项遮挡（iOS 无此问题）。修复=加 `Modifier.zIndex(if (isDragging) 1f else 0f)`，zIndex 大的 item 渲染在上层（与 iOS `bringSubviewToFront` 一致）。

### Changed

- 组件库全局版本 1.4.8 → 1.4.9（PATCH，三组件跨端一致性 v3）。

## \[1.4.8] - 2026-09-08

Drag z-order / Popover frame 定位 / Popup 内容 padding / ResultPage 图标尺寸四项修复（PATCH，跨端一致性 v2）。

### Fixed

- **Drag #47 Android 被拖动项 z-order 置顶**：LazyColumn 中被拖动项被相邻项遮挡（iOS 无此问题）。根因=LazyColumn 的 item 按声明顺序渲染，后渲染的项覆盖先渲染的项；被拖动项因 translationY 移动到相邻项位置时被覆盖。修复=加 `Modifier.zIndex(if (isDragging) 1f else 0f)`，zIndex 大的 item 渲染在上层（与 iOS `bringSubviewToFront` 一致）。

- **Popover #53 iOS 气泡位置跑到容器外/最底部（根因修复 v2）**：v1.4.7 的修复（show() 显式 layoutBubble()+layoutIfNeeded()）仍然无效，根因=SnapKit AutoLayout 约束需额外 layout pass 才能应用到 `bubbleView.frame`，而 `show()` 添加到 window 后 `self` 的 layout 尚未完成 → 约束解析到错误坐标。改为**直接计算 `bubbleView.frame`**（不用 AutoLayout），与 Android `PopoverPositionProvider` 一致：`content.sizeToFit()` 获取内容自然尺寸 → 计算 bubble 宽高(content+padding) → 按 placement 计算 bubble 原点 → 屏幕边缘裁剪 → 直接赋值 `bubbleView.frame`。同时兼容 iOS 13+ 用 `connectedScenes` 获取 keyWindow（`UIApplication.shared.keyWindow` 在 iOS 13+ 已废弃）。`content` 和 `arrowView` 也改为 frame 定位。

- **Popup #54 iOS Demo2 底部弹层行高过高 + Android 圆角裁剪**：① iOS 内容 padding 从 `AppSpace.lg`(16pt) 上下改为 `AppSpace.sm`(4pt) 与 Android `contentTopPadding=0 + padding(bottom=AppSpace.sm)` 一致，不再出现 iOS 底部弹层比 Android 高一个行高的视觉差异；② Android 容器加 `.clip(shape)` 确保 `RoundedCornerShape(topStart, topEnd)` 只圆顶两角（旧版仅 `.background(color, shape)` 不裁剪内容，可能导致四角都圆）；③ 蒙版透明度两端均为 0.45 已对齐。

- **ResultPage #56 Android 图标尺寸只有 iOS 的 1/2**：根因=`iconSize = radius * iconScale = (canvasSize/2) * 0.5 = canvasSize/4`，而 iOS 用 `rect.width * 0.5 = canvasSize * 0.5`。修复=改为 `canvasSize.minDimension * iconScale`，图标占圆形直径 50%（与 iOS 一致）。同时 info 图标坐标对齐：dot Y 从 `0.2f` 改为 `0.1f`（与 iOS 一致）、line end 从 `0.85f` 改为 `0.9f`（与 iOS `maxY - h*0.1` 一致）。

### Changed

- 组件库全局版本 1.4.7 → 1.4.8（PATCH，四组件跨端一致性 v2）。

## \[1.4.7] - 2026-09-08

Drag/ResultPage/Popover/Popup 跨端一致性修复（PATCH，对齐 iOS 标准 reorder + 弹层尺寸/位置一致性）。

### Fixed

- **Drag #47 Android 拖拽体验对齐 iOS 标准 reorder**：① 手柄位置从左侧移到右侧（与 iOS UITableView reorder 控件 ≡ 在右侧一致）；② 拖拽时被拖动项直接定位到目标位置 → 改用 `graphicsLayer.translationY = dragOffset` 让被拖动项跟随手指平滑移动；③ swap 阈值从固定 10f 改为实测 `itemHeight/2`，swap 后 `dragOffset` 减/加 `itemHeight`（而非 10f），保持手指与项的相对位置；④ 拖动透明度 0.9 → 0.6 加大可见度（与 iOS 被拖动 cell 有明显透明度细节一致）；⑤ `Modifier.onSizeChanged` 实测 item 高度并缓存到 `itemHeight` 状态供 swap 阈值/步长使用。修复后 Android Drag 行为与 iOS UITableView 标准 reorder 视觉/交互一致。

- **ResultPage #56 iOS 按钮宽度充满容器**：iOS `buttonStack.distribution` 从 `.equalSpacing`（按钮随内容宽度）改为 `.fillEqually`，`leading/trailing` 从 `greaterThanOrEqualTo/lessThanOrEqualTo` 改为 `equalTo`，让按钮组充满容器宽度、按钮等分容器宽度（单按钮充满容器，多按钮等分）。与 Android `AppButton.fillMaxWidth` 默认行为一致。

- **Popover #53 iOS 气泡位置跑到容器外/最底部**：根因=`show()` 调用 `setNeedsLayout()+layoutIfNeeded()` 触发 `layoutSubviews` → `layoutBubble()` 内 `bubbleView.snp.remakeConstraints` 设置新约束，但新约束需另一次 layout pass 才能应用到 `bubbleView.frame`，`UIView.animate` 捕获到旧 frame（气泡停留在 .zero 或旧位置=容器外/最底部）。修复=`show()` 显式调用 `layoutBubble()` 设置约束后立即 `bubbleView.setNeedsLayout()+bubbleView.layoutIfNeeded()` 同步应用约束到 frame，再启动 scale+淡入动画；同时 `offset` 从 `transform.translationX/Y`（与 scale 动画 transform 冲突）烘焙进约束（anchor.minX/maxX/minY/maxY/midX/midY 加 offset）。

- **Popup #54 Android center 弹层尺寸与 iOS 不一致**：Android `PopupPosition.CENTER` 容器无最小宽度约束，内容短时弹层宽度=内容+padding（如 Demo1 "居中弹层内容" ~150dp），iOS 同位置 `width.greaterThanOrEqualTo(240)` 弹层宽度=240dp，两端差异 90dp。修复=Android center 容器加 `.defaultMinSize(minWidth=240.dp)`，与 iOS `width.greaterThanOrEqualTo(240)` 一致。Demo2（bottom）圆角已对齐（Android `RoundedCornerShape(topStart,topEnd)` + iOS `maskedCorners=[layerMinXMinYCorner,layerMaxXMinYCorner]` 均为顶两角圆），蒙版透明度均 0.45 已对齐。

### Changed

- 组件库全局版本 1.4.6 → 1.4.7（PATCH，四组件跨端一致性修复）。

## \[1.4.6] - 2026-09-08

InfiniteLoading iOS Demo 修复（PATCH，tableFooterView 高度 + 数据源遗漏）。

### Fixed

- **InfiniteLoading #57 iOS tableFooterView 高度为 0 导致文案截断/点击重试无响应**：InfiniteLoadingView 初始化用 `snp.makeConstraints { make.height.equalTo(44) }` 设置自约束高度，SnapKit 同时设 `translatesAutoresizingMaskIntoConstraints = false`。当视图被赋值为 `tableView.tableFooterView` 时，UITableView 通过 `systemLayoutSizeFitting` 计算 footer 高度，但在视图无 superview 上下文时可能返回 0 高度，导致加载中文案、完成文案、错误文案均不可见，且 error 态点击重试手势区域为 0 无法接收触摸。修复=将 `snp.makeConstraints(height=44)` 改为 `frame = CGRect(0,0,375,44)`，保持 `translatesAutoresizingMaskIntoConstraints = true`（默认值），UITableView 直接用 frame.height=44 作为 footer 高度。子视图（spinner/label）仍用 SnapKit 约束居中，不受影响。

- **InfiniteLoading Demo2/Demo3 遗漏 `tv.dataSource = self`**：Demo2（加载完成）和 Demo3（加载失败+点击重试）的 UITableView 仅设了 `delegate` 未设 `dataSource`，导致 numberOfRowsInSection/cellForRowAt 不被调用，列表数据完全不显示。Android 端 LazyColumn 无此问题（items 直接声明在 Composable 内）。修复=补 `tv.dataSource = self`，与 Demo1/Demo4 一致。

### Changed

- 组件库全局版本 1.4.5 → 1.4.6（PATCH，iOS Demo 修复）。

## \[1.4.5] - 2026-09-08

三组件新增（MINOR，操作反馈区扩展）。

### Added

- **#53 Popover 气泡弹出框组件（双端）**：操作反馈区第八件，对齐设计规格。受控 `visible` + `content` 内容槽 + `placement` 六向（top/bottom/left/right/start/end）+ `anchor` 锚点定位 + `closeOnClickOutside` + `offset` 微调 + 箭头自绘 8×8 旋转方块 + 自动翻转防边缘溢出 + 淡入缩放 150ms。iOS 用 `keyWindow` 挂载 + `CAShapeLayer` 自绘箭头 + `UITapGestureRecognizer` 外部捕获 + `UIScreen.bounds` 自动翻转；Android 用 `androidx.compose.ui.window.Popup` + `Canvas` 自绘箭头 + `dismissOnClickOutside` + `LocalView` bounds 自动翻转。

- **#54 Popup 弹出层组件（双端）**：操作反馈区第九件，对齐设计规格。通用弹出层容器，受控 `visible` + `content` 内容槽 + `position` 三向（center/bottom/top）+ `closeable` 关闭按钮 + `closeOnClickOverlay` 遮罩点击收起 + `radius` 圆角（center=四角/bottom=顶两角/top=底两角）+ 遮罩 + 动画（center=淡入缩放 200ms/bottom+top=滑入 250ms easeOut）。iOS 用 `keyWindow` 挂载 + `UIView.animate` 动画 + 遮罩 `UITapGestureRecognizer` + closeable 关闭按钮 24×24 圆形灰底白叉；Android 用 `androidx.compose.ui.window.Dialog` + `Alignment` 定位 + scrim clickable + closeable `Icon` + `animateFloatAsState`。

- **#56 ResultPage 结果反馈组件（双端）**：操作反馈区第十件，对齐设计规格。整页/区域级操作结果反馈，`type` 四态（success/error/warning/info）+ `title` + `description` + `actions` 列表数据驱动 `ResultAction{text,style,onClick}` + `ResultActionStyle{primary/ghost/text}` + icon 自定义槽。双端自绘四态图标 56×56 圆形 type 对应色 alpha 0.1 底 + 实色字。按钮复用 AppButton #1。iOS 用 `UIStackView` 垂直居中 + `UIBezierPath` 自绘四态图标；Android 用 `Column` horizontalCenter + `Canvas drawPath` 自绘四态图标。

### Changed

- 组件库全局版本 1.4.4 → 1.4.5（MINOR，三组件新增）。

## \[1.4.4] - 2026-09-08

三组件新增（MINOR，操作反馈区 + 信息展示区扩展）。

### Added

- **#50 Loading 加载组件（双端）**：操作反馈区第五件，对齐设计规格。支持 `type` 圆形/Spinner 两种样式，`direction` 水平/垂直两种布局，可选文案。iOS 用 `UIActivityIndicatorView`（系统原生旋转）+ CAShapeLayer 自绘 Spinner；Android 用 `CircularProgressIndicator` + `Canvas` 自绘 Spinner。双端动画频率对齐（系统默认 60fps）。

- **#51 NoticeBar 公告栏组件（双端）**：信息展示区，支持横向滚动（单条公告）与纵向轮播（多条公告）两种模式，可关闭。iOS 用 `CADisplayLink` 驱动横向滚动（平滑无跳变）+ `Timer` 驱动纵向轮播；Android 用 `LaunchedEffect` + `rememberInfiniteTransition` 驱动两种动画。可配置背景色、文本色、左右图标。

- **#52 Notify 通知组件（双端）**：操作反馈区，命令式 API（`Notify.show(text, type, duration)`），不占用布局。iOS 挂载到 `keyWindow`，Android 挂载到 `Activity contentHost`，自动 dismiss（默认 3s）。支持 success/warning/error 三种类型，对应颜色与图标。

### Changed

- 组件库全局版本 1.4.3 → 1.4.4（MINOR，三组件新增）。

## \[1.4.3] - 2026-09-08

两组件跨平台一致性根治（PATCH，v1.4.2 方案不彻底的二次修复）。

### Fixed

- **Android Drag #47 拖拽无响应（v1.4.2 方案不彻底的根治）**：v1.4.2 用 nestedScroll + pointerInput key 改 index 的方案不够彻底——nestedScroll 的 `onPreScroll` 只消费"预滚动"阶段，拦不住外层 `Column.verticalScroll` 在长按等待期（~500ms）抢先消费 DOWN 事件导致 `detectDragGesturesAfterLongPress` 收不到 DOWN 的根因。v1.4.3 根治方案=Drag 内部从普通 `Column` 改为 `LazyColumn` 自管滚动，LazyColumn 自身是滚动容器，通过 nestedScroll 协议与外层 verticalScroll 协作，长按等待期手指不动则两层都不消费，`detectDragGesturesAfterLongPress` 正常收到 DOWN 并等待长按。落位后 LazyColumn 按 key 重组自动刷新顺序。移除 nestedScroll connection（不再需要）。

- **Empty #42 Demo3/Demo4 图标跨平台一致性根治（v1.4.2 emoji 方案不彻底的根治）**：v1.4.2 用 emoji 文本（🔔/📂）替代 SF Symbol/Material Icons，但 emoji 依赖系统字体（iOS Apple Color Emoji vs Android Noto Color Emoji），视觉外观本身就不一致，用户 2026-09-08 反馈仍不满足"一套图标库"要求。v1.4.3 根治方案=双端弃用 emoji，改为各自 `Canvas`（Android Compose）/`UIGraphicsImageRenderer`+`UIBezierPath`（iOS）自绘矢量图标（Bell 铃铛 + Folder 文件夹），相同坐标系（24x24 比例缩放）+相同三次贝塞尔曲线控制点+相同描边粗细（size/16），不依赖任何图标库。新增 `EmptyIconKind` 枚举（.bell/.folder）+ Android `EmptyStateView(iconKind:)` 参数 + iOS `EmptyStateView.setIconDrawable(_:size:)` 方法，双端 Demo3/Demo4 改用 iconKind 调用。

### Changed

- 组件库全局版本 1.4.2 → 1.4.3（PATCH，两组件跨平台一致性根治）。

## \[1.4.2] - 2026-09-07

三组件跨平台一致性修复（PATCH）。

### Fixed

- **Empty 空状态 #42 iOS 图标不一致**：iOS EmptyStateView 仅有 setIcon(UIImage?) 走 SF Symbol，Android 用 Material Icons，两端图标视觉差异大。新增 `setIconText(_ text: String?, size: CGFloat = 48)` 方法用 UILabel 渲染 emoji 文本图标，Demo3/Demo4 双端统一为 🔔/📂，根治跨图标库差异。

- **Android Drag #47 拖拽无响应**：根因=外层 Demo Column 的 verticalScroll 在长按等待期（~500ms）消费触摸事件，detectDragGesturesAfterLongPress 被取消。修复=Drag 根 Column 添加 nestedScroll 连接消费父级预滚动事件，阻断父级滚动手势干扰；pointerInput key 从 Unit 改为 index，修复 reorder 后 index 过期导致手势定位错乱。

- **iOS AppButton Destructive 红色边框不一致**：iOS AppButton.destructive 有 `AppColor.error` 红色边框，Android 已改为 null 无边框。iOS 同步改为 `nil` 无边框，双端统一。

- **Android Dialog 按钮尺寸不一致**：iOS Dialog 按钮高 44pt、圆角 AppRadius.md(10)，Android Dialog 经 AppButton 默认高 48dp、圆角 AppRadius.lg(14)。Android Dialog 按钮渲染传入 `height=44.dp, radius=AppRadius.md` 对齐 iOS 设计规格。

### Changed

- 组件库全局版本 1.4.1 → 1.4.2（PATCH，三组件跨平台一致性修复）。

## \[1.4.1] - 2026-09-07

Dialog 对话框 #46 iOS 点击无响应修复（PATCH）。

### Fixed

- **Dialog 对话框 #46 iOS 点击无响应**：根因=DialogViewController.show() 仅把 view 挂载到 keyWindow 根视图，但 DialogViewController 自身无强引用持有者——调用方（Demo showD1-D4）用局部变量 `let dialog = ...; dialog.show()` 构造弹窗，函数返回后局部变量释放，DialogViewController 立即被回收；而 UIButton.addTarget 与 UITapGestureRecognizer 对 target 持弱引用（assign/weak），target 变 nil 后按钮/遮罩点击全部失效（view 仍挂载在 keyWindow 视觉可见但事件失联）。修复=新增 `selfRetainer: DialogViewController?` 自保留引用，show() 末尾置 `selfRetainer = self` 强引用自身，dismiss 动画完成回调内置 `selfRetainer = nil` 释放，既保证弹窗存活期内事件可达又避免泄漏。swiftc -parse 语法通过，需 Xcode 实机复验 D1-D4 点击与遮罩回弹。

### Changed

- 组件库全局版本 1.4.0 → 1.4.1（PATCH，Dialog iOS 点击无响应修复）。

## \[1.4.0] - 2026-09-04

基础组件 6/6 收官（Overlay 遮罩层 v2.0 iOS 完整修复）；操作反馈区首件 ActionSheet 动作面板 #44 双端实现入库。

### Added

- **ActionSheet 动作面板 #44（操作反馈区首件）**：底部弹出的动作选择面板=遮罩+面板+操作列表+取消按钮，受控 visible+onSelect(index)/onCancel 回调；iOS ActionSheetView.swift（UIKit keyWindow 挂载+UIView.animate 滑入滑出）/ Android ActionSheet.kt（Compose ModalBottomSheet skipPartiallyExpanded）；4 组 Demo 1:1（D1 基础/D2 destructive/D3 disabled/D4 无标题）。门禁 A 全 A 通过；Android assembleDebug --rerun-tasks BUILD SUCCESSFUL（0 error，仅 ClickableText/SystemBars/HoverButton 既有 deprecation 警告）；iOS swiftc -parse 语法检查通过，SPM 全量 build 受沙箱 sandbox_apply 限制无法在 Agent 终端完成（非代码问题），需用户在 Xcode 实机验证。验证版本 v1.4.0；待 C1.5 Demo 实机验收 + C1 单测 + C2 CR/CI + D 发版。

- **Overlay 遮罩层 v2.0**：iOS 完整修复（递归测量 stack view / 非栈内容 sizeThatFits / 防御性重建 / init 顺序 / CAShapeLayer mask / 4 角统一圆角）；Android Demo 1/3 Surface shape 补齐圆角；双端 build 0 error + 用户 Demo 4 组验收通过。

- api.json `ui.action-sheet`：`reviewed=true`；双端 platform=available（C1 编译通过）；source_refs 双端文件路径；props 8 项+events 2 项与设计规格 100% 对齐。

- demo pbxproj 注册 ActionSheetView.swift（PBXBuildFile/PBXFileReference/PBXGroup/PBXSourcesBuildPhase 四段）。

### Changed

- 组件库全局版本 1.3.12 → 1.4.0（MINOR，基础组件 6/6 收官 + 操作反馈区首件入库）。

## \[1.3.12] - 2026-09-03

Image 图片 C2 CR/CI + D 发版（v1.3.3 → 发版 v1.3.12，三轮实机 11/11 收官）；api.json reviewed=true + platform partial→available。

### Changed

- **C2 CR/CI + D 发版通过（Image 图片）**：完成"设计→API→实现→Demo 实机三轮→C2→发版"全流程，阶段从 💻 C1.5 收官 → ✅ 已发版。

- api.json `ui.image`：`reviewed=true`；双端 platform 从 `partial` → **`available`**（C2 验证）；ios note 重写（含 layoutSubviews cornerRadius v1.3.1 Bugfix）；android note 重写（含 density 单位域 v1.3.3 Bugfix + Robolectric 50/50）。

- 组件库全局版本 1.3.11 → 1.3.12（PATCH，reviewed 发版）。

- 双端 Image Demo 徽标 **v1.3.12**（C2 发版基线：三轮修复 v1.3.0 → v1.3.3 收敛，v1.3.12=发版版号）。

### Tested（C2 CR/CI 验证清单）

- C1 绿：Android ImageTest 20/20 + 质量脚本 4/4 + Robolectric 50/50；iOS ImageTests（SPM 构建正常后已通过）。

- C1.5 实机三轮：v1.3.0(6 项)→v1.3.1(4 项)→v1.3.2(1 项)→v1.3.3 全修复，用户未再报问题，11/11 闭环（明细见验收文档 component-acceptance-image.md）。

## \[1.3.11] - 2026-09-03

ConfigProvider 全局配置 C2 CR/CI + D 发版（门禁 A/B/C1/C1.5 全过，双端 15/15+15/15 全绿 + 用户实机确认）；api.json reviewed=true。

### Changed

- **C2 CR/CI + D 发版通过（ConfigProvider）**：完成全流程，阶段从「门禁 C1/C1.5 全过待 C2/发版」 → ✅ 已发版。

- api.json `ui.config-provider`：`reviewed=true`；双端 platform note 补「C2 CR/CI + D 发版通过（v1.3.11），双端 15/15+15/15 全绿 + 用户实机确认对照 D1/D6/D8」。

- 组件库全局版本 1.3.10 → 1.3.11（PATCH，reviewed 发版）。

- 双端 ConfigProvider Demo 徽标 **v1.3.11**（C2 发版基线 v1.2.1）。

### Tested（C2 CR/CI 验证清单）

- 门禁 A/B/C1 ✅（2026-09-03 用户确认）；门禁 C1 ✅（ConfigProviderTest 15/15 + iOS ConfigProviderTests 模拟器实跑 15/15 全绿，SPM 阻塞根治后首跑 v1.2.1 基线）。

- 门禁 C1.5 ✅（用户实机确认 2026-09-03：前后对比/嵌套优先级/继承符合预期对照 D1/D6/D8）。

## \[1.3.10] - 2026-09-03

Cell 单元格 C2 CR/CI + D 发版（试点首组件：门禁 A/B/C1/C1.5 全过，双端 12/12 + iOS 模拟器 16/16 全绿）；api.json reviewed=true。

### Changed

- **C2 CR/CI + D 发版通过（Cell 单元格 · 试点首组件）**：完成设计→API→实现→Demo→C2→发版全流程，阶段从「已实现+测试通过待发版」 → ✅ 已发版。

- api.json `ui.cell`：`reviewed=true`；双端 platform note 补「C2 CR/CI + D 发版通过（2026-09-03，v1.3.10），双端测试全绿 + ListCell.swift 近似迁移废弃」。

- 组件库全局版本 1.3.9 → 1.3.10（PATCH，reviewed 发版）。

- 双端 Cell Demo 徽标 **v1.3.10**（C2 发版基线 v1.2.1）。

### Tested（C2 CR/CI 验证清单）

- 门禁 A/B/C1 全部通过（2026-08-30 用户 0-4 项确认：目标/设计/API/测试用例/代码）。

- 门禁 C1 ✅：Android Compose UI 测试 12/12（Robolectric） + 质量脚本 4/4；iOS CellTests **模拟器实跑 16/16 全绿**（SPM 构建阻塞根治后首跑，iPhone 14 模拟器，v1.2.1 基线）。

- 门禁 C1.5 ✅：iOS CellShowcase + Android CellDemo 首页注册，用户实机查看确认；onLongPress 双端承诺差异已登记（差异豁免白名单 `docs/数据与产物/diff-api.json`）。

## \[1.3.9] - 2026-09-03

LineChart v1.0 双端 reviewed：Android sharedui 新增 TrendChartView（Compose Canvas）+ Demo 4 组排查 + api.json reviewed=true。

### Added

- **Android sharedui 新增** **`TrendChartView.kt`**：`TrendChartView` Composable + `ChartPoint` 数据类，对齐 iOS API（expensePoints/incomePoints 双序列），使用 Compose Canvas 绘制双色折线（支出红 expense + 收入绿 primary），含 Y 轴刻度（4 等分）、X 轴标签、网格线（border 色）、圆点标记（≤14 点显示）、空态「暂无数据」。

- **LineChart Demo 4 组排查（双端 1:1 对齐）**：① 基础双折线（6 个月支出+收入）② 仅支出（7 天红色单序列）③ 仅收入（4 季度绿色单序列）④ 空态（无数据占位文案）。

- 双端 Demo 列表注册 `ui.line-chart`（展示组件分类，reviewed=true）。

### Changed

- api.json `ui.line-chart` source\_refs 补全 Android 路径（TrendChartView\.kt），reviewed=true。

- 组件库全局版本 1.3.8 → 1.3.9（PATCH）。

- 双端 LineChart Demo 徽标 v1.0（首次 reviewed）。

- MainActivity.kt 补全 import（ChartPoint/TrendChartView）。

## \[1.3.8] - 2026-09-03

Card v1.0 双端 reviewed：Android sharedui 补全 SummaryCardView + Demo 4 组排查 + api.json reviewed=true。

### Added

- **Android sharedui 新增** **`SummaryCardView.kt`**：`SummaryCardView` Composable，对齐 iOS API（title/subtitle/value/valueColor/accessory/onClick 参数），布局卡片壳（bgCard/cornerRadius lg/border 0.5dp）+ 标题行（标题 + 右箭头 14dp）+ 副标题 + 数值行（主数值 sizeXl semibold + 辅助文案 sizeXs textSecondary）。

- **Card Demo 4 组排查（双端 1:1 对齐）**：① 基础摘要卡（本月支出 textPrimary 色）② 带颜色数值（本月收入 systemGreen 绿色）③ 无辅助文案（账户余额 accessory=nil 隐藏）④ 可点击卡片（预算管理 systemOrange 警示色 + onClick 回调）。

### Changed

- api.json `ui.card` android state `partial` → `available`，source\_refs 修正 iOS `DiscoverSummaryCardView.swift` → `SummaryCardView.swift` + 补全 Android 路径，reviewed=true。

- 组件库全局版本 1.3.7 → 1.3.8（PATCH）。

- 双端 Card Demo 徽标 v1.0（首次 reviewed）。

- MainActivity.kt 补全 import（SummaryCardView）。

## \[1.3.7] - 2026-09-03

Grid v1.0 双端 reviewed：Android sharedui 补全 NavigationGrid + Demo 4 组排查 + api.json reviewed=true。

### Added

- **Android sharedui 新增** **`NavigationGrid.kt`**：`NavigationGrid` Composable + `GridItem` 数据类，对齐 iOS API（onSelect 索引回调 + title/items 参数），复用 `AppIcon`/`AppIconName` 双端统一图标系统，布局卡片壳（bgCard/cornerRadius lg/border 0.5dp）+ 标题 + Row 等分图标网格（height 72dp，icon 26dp primary 色）。

- **Grid Demo 4 组排查（双端 1:1 对齐）**：① 基础四宫格（列表/图表/加号/人物）② 带标题分区（浏览器/手机/邮箱/下拉）③ 可点击交互（onSelect 打印 index）④ 多分组网格（常用功能 + 小工具，模拟发现页）。

### Changed

- api.json `ui.grid` android state `partial` → `available`，source\_refs 补全双端路径（iOS NavigationGrid.swift + Android NavigationGrid.kt），reviewed=true。

- 组件库全局版本 1.3.6 → 1.3.7（PATCH）。

- 双端 Grid Demo 徽标 v1.0（首次 reviewed）。

- MainActivity.kt 补全缺失 import（ProfileListGroup/ProfileListItem/NavigationGrid/GridItem）。

## \[1.3.6] - 2026-09-03

List v1.0 双端 reviewed：分组列表 Demo 4 组排查 + api.json reviewed=true。

### Added

- **List Demo 4 组排查（双端 1:1 对齐）**：① 基础列表行（设置/通用/关于，仅标题）② 带值列表行（版本 v1.3.5/设备 iPhone 15 Pro/存储 128 GB）③ 可点击列表行（账号管理/消息通知/隐私设置 + 右箭头 chevron）④ 多分组列表（个人资料组 + 系统设置组，模拟设置页）。

- **api.json** **`ui.list`** **reviewed=true**，双端 state=available 确认（iOS GroupList/GroupListItem + Android ProfileListGroup 复用既有实现）。

### Changed

- 组件库全局版本 1.3.5 → 1.3.6（PATCH）。

- 双端 List Demo 徽标 v1.0（首次 reviewed）。

- Demo 2 设备名双端统一为 "iPhone 15 Pro"（原 Android "Pixel 8 Pro" 与 iOS 不一致，影响排查比对）。

## \[1.3.5] - 2026-09-03

Avatar v1.0 双端 reviewed：Demo 4 组排查 + api.json reviewed=true。

### Added

- **Avatar Demo 4 组排查（双端 1:1 对齐）**：① 文字头像（4 个昵称首字 + primaryMuted 背景）② 星座符号头像（白羊/金牛/双子/巨蟹 + tint 色 0.18 alpha 背景）③ 尺寸对比（40/56/72pt 三档，狮子座符号）④ 头像组合（4 行 44pt 头像 + 昵称，混合文字/符号头像）。

- **api.json** **`ui.avatar`** **reviewed=true**，双端 state=available 确认。

### Changed

- 组件库全局版本 1.3.4 → 1.3.5（PATCH）。

- 双端 Avatar Demo 徽标 v1.0（首次 reviewed）。

## \[1.3.4] - 2026-09-03

Empty v1.0 双端 reviewed：EmptyStateView 新增可选 icon 支持 + Demo 4 组排查 + api.json reviewed=true。

### Added

- **EmptyStateView 双端新增可选 icon 参数**：iOS 新增 `setIcon(_ image: UIImage?, size: CGFloat = 48)` 方法 + `UIImageView`（hidden by default，tintColor = textSecondary，monochrome 配合 SF Symbol）；Android 新增 `icon: ImageVector? = null` + `iconSize: Int = 48` 参数，Icon 居中于文案上方，双端间距 `AppSpace.md`。

- **Empty Demo 4 组排查（双端 1:1 对齐）**：① 默认空态（"暂无数据"）② 自定义文案（"搜索无结果，换个关键词试试"）③ 带图标空态（iOS tray / Android Favorite + "暂无记录"）④ 固定容器空态（圆角 bgCard 容器内嵌空态，iOS folder / Android Favorite + "该文件夹为空"）。

- **api.json** **`ui.empty`** **reviewed=true**，双端 state=available 确认。

### Changed

- 组件库全局版本 1.3.3 → 1.3.4（PATCH）。

- 双端 Empty Demo 徽标 v1.0（首次 reviewed）。

## \[1.3.3] - 2026-09-03

Image v1.3.2 实机：Demo2 倒数 2 卡（none / scale-down）双端尺寸 + 太阳位置不一致修复 + 徽标 v1.3.3。

### Fixed

- **Android Demo 演示素材物理像素未按密度放大（单位域错位 → none/scale-down 与 iOS 完全相反）**：v1.3.2 及之前 `makeDemoBitmap(320,200)` 生成的是固定 320×200 px Bitmap，无论屏幕密度；而 `ImageGeometry.rect` 在 Android 端用容器物理像素（Canvas.size.width）参与计算。结果：xxhdpi (density=3) 容器 120dp×90dp = 360×270px，原图 320×200px < 容器 → **none/scale-down 表现为四周留白不裁切**（太阳整体居中，r=26 像素偏小）。而 iOS 侧 `UIGraphicsImageRenderer(size:)` 生成 UIImage.size=320×200 pt，`ImageGeometry.rect` 用 pt 空间计算：容器 120×90 pt < 原图 320×200 pt → **none/scale-down 表现为中心裁切（太阳被裁到容器顶外，仅露底部 20pt）**。用户实机报告"倒数第一个和第二个 demo 与 android 展现不一致，主要是尺寸也不一样，内部圆的位置也不一样"——两端完全相反。修复：

  - Android `ImageDemo.kt` 新增 `LocalDensity.current.density`，`makeDemoBitmap(logicalWidthDp:logicalHeightDp:density:)` 按 **(320*density,200*density) 物理像素**生成 Bitmap（density=3 → 960×600 px；density=2 → 640×400 px），与 iOS 320pt×200pt 对容器 120pt×90pt 的 contain/cover/none/scale-down **所有缩放系数 s=0.375/裁切比例/太阳位置 1:1 同构**（Python 双端数值模拟已验证：xxhdpi density=3 时 rect 输出与 iOS 完全按比例对齐）。

  - 太阳绝对半径 26 同步按 density 放大（`sunR=26f*density`）保证原图内视觉比例与 iOS 一致；太阳坐标按相对比例（w*0.62, h*0.25）已随尺寸放大自然等比对齐。

  - remember 由 `{ makeDemoBitmap() }` 改为 `remember(density) { makeDemoBitmap(density = density) }`，密度变化时自动重新生成（覆盖折叠屏/连接副屏等 case）。

### Changed

- **双端 Image Demo 版本徽标**：iOS `DemoShowcases.swift` v1.3.2 → v1.3.3，builtAt 2026-09-03 22:45:00；Android `ImageDemo.kt` v1.3.2 → v1.3.3。

- **ui-version.json**：组件库版本 1.3.2 → 1.3.3（PATCH：demo 代码改动必升版本，治理规范 §6.5 / 开发规则 §1.5）。

## \[1.3.2] - 2026-09-03

Image v1.3.1 实机 4 项修复（Bug1 / Bug4-5 / Bug6）+ 双端徽标 v1.3.2。

### Fixed

- **Bug1 Android Demo1 三张卡片间距不等分（iOS equalSpacing vs Android spacedBy）**：Android `Row` 原 `Arrangement.spacedBy(AppSpace.lg)`（固定间距，内容整体偏左，右留大片空白）vs iOS `UIStackView distribution = .equalSpacing`（内容+留白均分）。修复：Row `horizontalArrangement = Arrangement.SpaceEvenly` + `modifier.padding(horizontal = AppSpace.lg)`（两侧等量 padding=SpaceEvenly 在两端留空，与 iOS equalSpacing + inset(lg) 的布局语义一一对应）。

- **Bug4/Bug5 iOS Demo2 文字与图片错位重叠 + Demo3 图片与 Demo2 图片重叠**：根因 = Demo2 fit 五模式 `UIScrollView` 在 `addSection` 的 container 内仅约束了 `leading/trailing/top + height.equalTo(118)`，**缺 bottom 锚** → container（被 `contentStack.addArrangedSubview` 推入的 UIView）**高度=0**（内部 scroll 的 top 只声明位置，无法反推 container 高度）。scroll 以 origin.y=0 为起点 118pt 高，**溢出 container 边界**，在 Auto Layout 上看起来 Demo2 scroll 内容+Demo3 section 标题/Demo3 图片起点都在 Demo3 的 title 位置附近（Demo3 title 紧贴 Demo2 container 的 y=0 底部），实机视觉：Demo2 文字/图盖在 Demo3/Demo4 card/button 上（Demo4 默认占位图因此被压到 Demo3 下）。修复：scroll 补 `make.bottom.equalToSuperview().inset(AppSpace.md)`，container 被 top/bottom 双向锚定，高度被 SnapKit 计算为 `md + 118 + md`，正确撑开，scroll 不再溢出。

- **Bug6 iOS/Android 失败占位默认图形不一致**：原 iOS `Image.makeErrorPlaceholder` 用 SF Symbol `photo`（相框+左上角太阳+右下山形，SF 多色/单色由系统决定，图形定义不可控），Android `DefaultErrorPlaceholder` 用 `Canvas(40×32)` 自绘（外框stroke + 太阳圆stroke r=2.5 at (0.34,0.38) + 左底(0.36,0.72)→peak(0.58,0.42)→右底(0.80,0.72) 折线）。双端图形太阳位置/山形/外框细节 1:1 不对等，Demo4 默认失败占位（无效资源 `no_such_image_xyz` / `no_such_drawable_xyz`）实测视觉差异明显。修复：iOS 替换为 `ErrorGraphicImageView` 自绘（Image.swift 同文件追加 class，零新文件），视窗 40×32 / 线宽 2pt / 太阳圆 r=2.5 / 比例完全同构 Android Canvas 参数（pt=dp 同 1x 逻辑尺寸），双端失败占位图形进入「同一数学定义」路径，解除 SF Symbol 单端依赖。

### Changed

- **双端 Image Demo 版本徽标**：iOS `DemoShowcases.swift` v1.3.1 → v1.3.2，builtAt 2026-09-03 22:20:00；Android `ImageDemo.kt` v1.3.1 → v1.3.2。

- **ui-version.json**：组件库版本 1.3.1 → 1.3.2（SemVer PATCH，bugfix 递增；治理规范 §6.5 / 开发规则 §1.5：即使 demo 代码改动也必升版本）。

## \[1.3.1] - 2026-09-03

C1.5 实机验收问题修复（双端 demo 徽标同步 v1.3.1）。

### Fixed

- **iOS Image radius 圆角未落地（实机问题 2/3）**：`Image.swift` 仅有 `radiusValue` 解析器与单测断言（D4b/A2 断言 `layer.cornerRadius`），但 `layoutSubviews` 从未应用圆角——iOS 单测受本机 SPM/UIKit 约束从未实跑，"纸面绿"掩盖实现缺失，实机表现为：圆角 lg 卡无圆角、48×48 radius=24 卡为正方形而非圆形（Android clip 正常）。修复：`layoutSubviews` 每次布局重算 `layer.cornerRadius = Image.radiusValue(from: radius)`，clipsToBounds 连带裁剪图与占位层，radius 变化后 setNeedsLayout 即生效。

- **iOS demo2 fit 五模式区整节空白（实机问题 4）**：`UIScrollView` 在 `addSection` 无固有高度的 container 内只有 edges 约束，自身高度无定义 → Auto Layout 塌陷为 0。修复：显式 `height = 118`（卡片 90 + caption + 余量）。

- **Android demo3/4 卡片布局与 iOS 不一致（实机问题 5/6 位置部分）**：Android `ImageDemo.kt` demo3/4 卡片 Row 未撑满全宽 → 卡片居左；且未传 fit 用默认 fill（iOS makeStateCard 为 contain）→ loaded 后拉伸。修复：Row `fillMaxWidth + Center` 与 iOS 居中布局对齐，卡片 `fit = "contain"` 与 iOS 一致（loaded 后等比展示、白圆不变形）。

- **Demo1 素材无引导文案（实机问题 1）**：双端 demo1 Hint/addInfo 补充素材说明（320×200 上蓝下橙+白太阳圆；fill 拉伸致圆变形属语义，非 bug）。

### Verified（验证版本 v1.3.1，2026-09-03）

- Android 组件单测回归：ImageTest 20/20 绿（iOS demo2 scroll/demo1 hint 均 demo 层改动，组件 Image.kt 无逻辑变更）。

- iOS 修复为本机不可编译验证项：`Image.swift` cornerRadius 修复由实机复核（问题 2/3），demo2 scroll 高度由实机复核（问题 4）。

## \[1.3.0] - 2026-09-03

ui.image 图片组件双端实现（门禁 C1，契约 `docs/api.json` `ui.image`，门禁 B ✅ 2026-09-03 冻结）。

### Added

- **Image（ui.image）双端实现**：iOS `ios/SharedUI/Components/Image.swift`（UIView + 状态机 LoadState loading/loaded/failed）+ Android `android/sharedui/components/Image.kt`（Compose 顶层函数，规避 foundation.Image 命名冲突，破图占位零图标依赖）。契约 props 9（src/fit/position/width/height/radius/alt/loadingContent/errorContent）+ events 3（onTap/onLoad/onError）；fit 五值（fill/contain/cover/none/scale-down）、position 三值锚点、radius token 档位与数值。src 语义：iOS `Any?`=UIImage/String 资源/nil，Android=ImageBitmap/Int resId/String 资源名/null。

- **几何纯函数双端同构** `ImageGeometry.rect`：`x = ax*(W-dw)` / `y = ay*(H-dh)`（ax/ay ∈ {0,0.5,1}）；scale-down=不放大、cover 超裁随 position 锚定、H1 零尺寸防御。向量同组断言在 iOS `Tests/ImageTests.swift` 与 Android `ImageTest.kt`（D2/D2b/D3/D3b/H1）。

- **双端单测**：iOS ImageTests（状态机/几何/radius/点击/无障碍/A1-A3，纯函数数学闭环）；Android ImageTest **20/20 绿**（Robolectric，结构/状态/语义断言；根节点 mergeDescendants 下子节点统一 `useUnmergedTree`）。像素采样（captureToImage）在 Robolectric 窗口捕获不产帧，移除并归 C1.5 实机视觉验收。

- **质量门禁脚本组件化** `scripts/check_component_quality.py`：`--component cell|image`，D6 token 扫描/A6 契约 schema/A7 双端命名/C1 用例映射按组件参数化；Cell/Image 两组 4/4 全绿。用例编号保留位（D6/A6/A7=脚本型）与 Image 验收文档对齐（D6=Token、D7=失败、D8=点击+无障碍；A4/A5 空号）。

- **设计 token 落地**：占位色 `AppColor.gray6`（#E5E5E5）/`gray15`（#BFBFBF）补入双端 AppTokens（gray4/gray25 同族）。

- **api.json**：`ui.image` platforms ios/android → partial（C1 已实现，C1.5 实机确认后转 available）。

- **双端 Demo Showcase（门禁 C1.5 前置）**：Android `demo/android/app/.../ImageDemo.kt`（新建文件 + MainActivity 索引挂载，编译通过）+ iOS `demo/ios/DemoApp/DemoShowcases.swift` 追加 `ImageShowcase`（对照 Button/Icon Showcase 既有模式；本机 SPM 约束未编译，实机验证时关注）。演示点①②③④ 与验收文档「六」一一对应：基础/圆角圆形、fit 五模式同屏、loading/error 占位与恢复（P4=B 重试）、onTap 反馈条 + onLoad/onError 计数。demo 版本徽标 = 组件库正式版 v1.3.0。

### Fixed

- **Cell Error 徽标缺可读语义（v1.30c 自绘引入回归）**：`Cell.kt` Error 态改自绘 `ErrorCircleBadge` 后未补 `contentDescription("失败")`，与 CellTest D5（`CellTest.kt:93`）断言冲突，自 v1.2.0 起 CellTest 全量无法全绿（CHANGELOG v1.2.0 已登记遗留）。本次在徽标 modifier 补 `.semantics { contentDescription = "失败" }`，与 Success「成功」配对，a11y 对齐 iOS badge；**CellTest 15/15 恢复全绿**。

- **Image.kt 编译修正**：设计 token 导入包名 `com.zhiqihuayun.design` → `com.zhiqihuayun.foundation.design`（与 Cell 一致）；`matchParentSize`/`drawImage` 为 BoxScope/DrawScope 接口成员，移除错误 import；material icons-core 无 `Icons.Filled.Image`，破图占位改 Canvas 自绘（画框+太阳+山形，对齐 iOS SF Symbol "photo" 语义）。

### Changed

- **ui-version.json**：组件库版本 1.2.1 → 1.3.0（新组件新增 + 修复，SemVer MINOR）。

### Verified（验证版本 v1.3.0，2026-09-03）

- Android Robolectric 全量 **50/50 绿**：ImageTest 20/20 + CellTest 15/15（含 D5\_errorState 修复验证）+ ConfigProviderTest 15/15。

- 质量门禁脚本 Cell 与 Image 两组各 4/4（D6/A6/A7/C1）全绿。

- iOS 本机仍受 Xcode/UIKit 环境约束无法跑全量 XCTest（历史遗留，见 v1.2.1 根治记录未覆盖的编译链），iOS 侧以纯函数测试 + 代码评审为 C1 依据；真实 iOS 渲染/实机确认归 C1.5。

## \[1.2.1] - 2026-09-03

打通 iOS 工程 SwiftPM 构建阻塞（历史遗留根治），iOS 测试首次真机模拟器实跑全绿。

### Fixed

- **【根治】ios/Package.swift GRDB 依赖引用键错误**：`.product(name: "GRDB", package: "GRDB")` → `package: "GRDB.swift"`。v1.30c 曾按「子包 name 字段」写作 `"GRDB"`，但 Xcode 14.2 实测本地 path 依赖以**目录名**（`GRDB.swift`）为引用键，报 `unknown package 'GRDB'`，导致 iOS 包自 2026-08-30 起一直无法构建/测试（此前误判为"SPM 网络不可达"，实为引用键错误 + 陈旧缓存）。

- **【根治】ios/Package.swift exclude 补** **`"Vendor"`**：Vendor/GRDB.swift 自带 Demo App 资源（Main/LaunchScreen.storyboard、Assets.xcassets、PerformanceModel.xcdatamodeld 等），主 target `path: "."` 未排除 Vendor 时被当资源扫描，报 `multiple resources named ...` 重复错误。补排除后主 target 只扫 Foundation/SharedUI。

- **iOS 测试补** **`@testable import KeepAccountsMiddleware`**：`Tests/CellTests.swift` 与 `Tests/ConfigProviderTests.swift` 均缺模块导入，首次真编译即报 `cannot find 'Cell'/'CellModel'/'ConfigProvider' in scope`（此前从未真正编译过测试）。补导入后全部编译通过。

- **删除 ios/Package.resolved**：纯本地 path 依赖无需锁定文件（`swift package resolve` 自动清除陈旧远程 URL pins），xcodebuild 实测无此文件可正常构建测试。

### Changed

- **ui-version.json**：组件库版本 1.2.0 → 1.2.1（工程编译修复，SemVer PATCH，§6.5「.pbxproj/编译修正 → PATCH」先例对齐 v1.30c）。

### Verified（首次模拟器实跑，验证版本 v1.2.0 代码基线）

- **iOS ConfigProviderTests 15/15 绿**（D1-D8 + A1-A5 + hexStringParsing + mergedSemantics，iPhone 14 模拟器 XCTest）。

- **iOS CellTests 16/16 绿**（D1-D8 + A1-A5 + H1/H2/H3/H3b，iPhone 14 模拟器 XCTest）——历史遗留"iOS 测试从未实跑"自此闭环。

## \[1.2.0] - 2026-09-03

ConfigProvider 全局配置组件 v1.0 双端实现落地（门禁 C1 进行中，Android 实现完成、iOS 代码就位）。

### Added

- **ConfigProvider（ui.config-provider）双端实现**：设计规格（门禁 A ✅ 2026-09-03）与 API 契约（门禁 B ✅ 2026-09-03，用户「继续」确认）通过后进入门禁 C1 实现。组件定位为 design-token 静态基准（AppTokens）之上的**运行时覆盖层**，四项配置：`primaryColor`（hex 字符串）/ `rounded`（圆角升档）/ `compact`（间距降档）/ `locale`（文案语言），覆盖语义 = 内层优先、未设项继承、静态基准不被污染（D5）。

- **Android** **`android/sharedui/components/ConfigProvider.kt`**：`@Stable data class AppConfig`（四字段全可空 + `merged(overlay)` 合并 + `Baseline`）、`parseHexColor`（6/3 位 hex 解析）、`CompositionLocal` 上下文注入（`ProvidableCompositionLocal`，对齐 Compose 1.7 成员扩展 `provides`）、`@Composable ConfigProvider`、读取解析层 `AppTheme`（primaryColor/radiusSm/Md/Lg/spaceSm/Md/Lg/Xl/locale 解析函数）。Robolectric 单测 **15/15 绿**（D1-D8 + A1-A5 + hex 解析 + merged 语义，验证版本 v1.2.0）。

- **iOS** **`ios/SharedUI/Components/ConfigProvider.swift`**：按平台差异登记（iOS 命令式 UIKit），`AppConfig` + 命令式**作用域栈** `ConfigProvider`（push/pop/withScope/current + resetForTesting，表达嵌套 Provider 语义）+ 读取解析层 `AppTheme` + `UIColor(hexString:)` 解析。`Tests/ConfigProviderTests.swift` D1-D8/A1-A5 用例就位（XCTest 逻辑层，本机 UIKit 受限待实机跑）。

### Changed

- **ui-version.json**：组件库版本 1.1.11 → 1.2.0（新组件新增，SemVer MINOR）。

> 遗留（非本次引入）：CellTest `test_D5_errorState` 失败——Cell v1.30c 将 Error 态改为自绘 `ErrorCircleBadge`（Canvas）后未补 `contentDescription("失败")`，与 CellTest 93 行断言冲突；Cell.kt/CellTest.kt 均无本地改动，已单独验证与 ConfigProvider 无关，待 Cell 门禁 C2 时修复。

## \[1.1.11] - 2026-09-03

补录 Button v1.0 三轮发布后漏掉的 4 轮 bugfix 版本递增（治理规范 §6.5 合规补齐）。

### Changed

- **iOS ButtonShowcase 版本徽标**：`addVersionBadge(componentName: "Button", version: "v1.0", builtAt: "2026-09-02 19:00:00")` → `version: "v1.4"`，`builtAt` → `2026-09-03 09:05:00`。对应 4 轮 bugfix 徽标步长（每轮 +0.1）：

  - v1.1：iOS Demo `addFeedbackBar` `insertArrangedSubview(at: 2)` 越界 → `min(2, contentStack.arrangedSubviews.count)` 防越界。

  - v1.2：Android AppButton Box 显式补 `.background(container, shape)`（计算了 `container` 却没写 modifier，导致 Demo1 按钮透明只显文字）；secondary 样式背景由透明改 `AppColor.bgCard` 对齐 iOS。

  - v1.3：iOS AppButton `setLoading(true)` 分支补 `updateBackground()`，原只 setTitle 不置灰 → 双端 Demo3/Demo4 loading 态顺序一致（iOS 原顺序正确绿灰白灰，Android 全灰；修完双端同序）。

  - v1.4：Android Demo 子页面补 `statusBarsPadding()` + 自定义返回按钮行 + 内容区大标题组件名，修复返回按钮撞状态栏 + 缺大标题 + 标题在 title bar 不在内容区。

- **Android ButtonDemo 版本徽标**：`text = "Button 组件 v1.0"` → `"Button 组件 v1.4"`。

- **ui-version.json**：组件库版本 1.1.10 → 1.1.11（demo 代码改动同样触发版本递增，见治理规范 §6.5 / 开发规则 §1.5）。

## \[1.1.10] - 2026-09-03

Icon v1.1 iOS SF Symbol 多色渲染修复（monochrome 强制单色轮廓）+ Demo 徽标 v1.1→v1.2。

### Fixed

- **iOS AppIcon SF Symbol 强制单色渲染**：`iphone.gen3` 等多色符号默认保留内部屏幕渐变/Home Indicator 颜色细节，`tintColor` 仅作用于轮廓，导致 Demo ①/④ 手机图标 iOS 有内部颜色 vs Android 纯白色（与 Android SfApproxIcons ColorFilter.tint 语义不一致）。修复：`UIImage(systemName: name.sfSymbol, withConfiguration: .preferringMonochrome())`，8 图标全程仅受 tintColor 控制。

### Changed

- **iOS IconShowcase 版本徽标**：`version: "v1.1"` → `version: "v1.2"`，`builtAt` → `2026-09-03 08:30:00`。

- **Android IconDemo 版本徽标**：`text = "Icon 组件 v1.1"` → `"Icon 组件 v1.2"`。

- **ui-version.json**：组件库版本 1.1.9 → 1.1.10。

## \[1.1.9] - 2026-09-03

Icon Demo 双端徽标版本同步 v1.0→v1.1（组件级版本必升）。

### Changed

- **iOS IconShowcase 版本徽标**：`addVersionBadge(version: "v1.0")` → `version: "v1.1"`，`builtAt` 2026-09-02 → 2026-09-03 08:00:00。

- **Android IconDemo 版本徽标**：`text = "Icon 组件 v1.0"` → `"Icon 组件 v1.1"`。

- **ui-version.json**：组件库版本 1.1.8 → 1.1.9（demo 代码改动同样触发版本递增，见治理规范 §6.5）。

## \[1.1.8] - 2026-09-03

Icon v1.0 iOS bugfix：SF Symbol 名错误 + Demo ② 间距 + .pbxproj 编译引用。

### Fixed

- **iOS AppIconName.smartphone SF Symbol 名修复**：`"smartphone"` 非系统 SF Symbol（`UIImage(systemName:)` 返回 nil）→ 改为 `"iphone.gen3"`（iOS 16+ 存在的手机造型符号，与 demo deploymentTarget iOS 16 一致）。修复 Demo ① 基础形态第 7 列、Demo ④ 全形态网格每行第 7 列（smartphone）图标空白。

- **iOS IconShowcase Demo ② 尺寸因子间距对齐 Android**：UIStackView `spacing = AppSpace.xl`（24pt 固定）→ `distribution = .equalSpacing`；容器 leading/trailing inset `lg(16pt)` → `xl(24pt)`。Android 用 `Arrangement.SpaceEvenly`（子视图间 + 两端空白自动均分），`.equalSpacing` 是 UIStackView 对应语义近似。

- **iOS Demo .pbxproj 手动补 AppIcon.swift 4 处编译引用**：PBXBuildFile / PBXFileReference / PBXGroup(Components) / PBXSourcesBuildPhase 四处。xcodegen 未安装，新建 AppIcon.swift 后 .pbxproj 未更新，导致 Xcode 编译期 6 处 `Cannot find 'AppIconName'/'AppIcon' in scope`。

### Changed

- **ui-version.json**：组件库版本 1.1.7 → 1.1.8。

## \[1.1.7] - 2026-09-02

Icon 组件 v1.0 新增：双端 AppIcon 代码落地 + API 契约完善 + 双端 Demo。

### Added

- **Icon 组件（ui.icon）正式纳入组件库**：中台基础图标组件，封装 iOS SF Symbols / Android SfApproxIcons 矢量，统一双端图标使用方式。8 个通用图标（list/chart/plus/safari/person/arrowDown/smartphone/mail），支持自定义尺寸与着色（对标 NutUI Icon / Ant Design Icon）。

- **iOS AppIcon.swift 新增**：AppIconName 枚举 8 个图标映射 SF Symbol 系统名；AppIcon 类（UIImageView）封装 SF Symbols + 工厂方法 `make(name/size/color)` + `setColor()` 着色更新。

- **Android AppIcon.kt 新增**：AppIconName 枚举 8 个图标（与 iOS 同名）映射 SfApproxIcons ImageVector；AppIcon Composable 封装 Image + ColorFilter.tint + ContentScale.Fit；`sfSymbolName()` 供跨端文档参考。

- **api.json ui.icon 契约完善**：platforms.ios state unavailable→available；source\_refs 双端（iOS AppIcon.swift + Android AppIcon.kt）；props 3 项（name/size/color）、demos 4 项（列表图标/主色加号/红色邮箱/全图标网格）、anti\_goals 3 项（不做品牌图标/图标字体/动效图标）、visual\_tokens 4 项、deps 引用 foundation.design-tokens、industry\_names 新增 AppIcon。

- **iOS IconShowcase Demo**：4 组递增单因子排查（① 基础形态 8 图标默认尺寸 24pt → ② 尺寸因子 list × 16/24/32/48pt → ③ 着色因子 person × 4 色 → ④ 全形态网格 8 图标 × 3 色），版本徽标 Icon v1.0。

- **Android IconDemo**：与 iOS IconShowcase 一一对应的 4 组排查，版本徽标 Icon v1.0。

### Changed

- **DemoShowcases.swift**：ui.icon 条目 reviewed=false → true，create=nil → `{ IconShowcase() }`。

- **MainActivity.kt**：Icon 条目 reviewed=false → true，demo=nil → `{ IconDemo() }`；新增 AppIcon / AppIconName import。

- **ui-version.json**：组件库版本 1.1.6 → 1.1.7（双端 iOS / Android 永远同版本，禁止手工改工程内版本）。

## \[1.1.6] - 2026-09-02

Button 组件 v1.0 新增：双端代码对齐 + API 契约 + 设计令牌 + 双端 Demo。

### Added

- **Button 组件（ui.button）正式纳入组件库**：中台基础按钮，48pt 高、圆角 lg、三样式（primary/secondary/destructive），统一登录/注册/弹窗/表单等主操作按钮视觉（对标 NutUI Button / Ant Design Button）。

- **api.json 新增 ui.button 契约**：props 7 项（text/onClick/style/fontSize/height/enabled/loading）、events 1 项（onClick）、demos 5 项（主操作/次要操作/破坏性操作/加载态/禁用态）、status=stable、anti\_goals 3 项（不做图标按钮/FAB/按钮组）、source\_refs 双端源码路径、visual\_tokens 8 项；componentCount 27→28。

- **design-token.json 新增 buttonDisabled**：`#9CA3AF`（灰阶 400 区间，介于 gray15 `#BFBFBF` 与 gray25 `#8C8C8C` 之间），用于按钮禁用/加载态填充色，与 AppTokens.swift / AppTokens.kt 已有定义对齐。

- **iOS ButtonShowcase Demo**：4 组递增单因子排查（① 基础形态仅 Primary → ② style 三样式对照 → ③ loading+disabled 状态 → ④ 三样式×三状态全形态组合），点击反馈条就地更新，版本徽标 Button v1.0。

- **Android ButtonDemo**：与 iOS ButtonShowcase 一一对应的 4 组排查，版本徽标 Button v1.0。

- **DemoShowcases.swift addVersionBadge 泛化**：新增 `componentName` 参数（默认 "Cell"），支持 Button 等其他组件复用版本徽标方法，现有 CellShowcase 调用无需改动。

### Changed

- **iOS AppButton.swift**：禁用/加载态填充色由硬编码 `UIColor(hex: 0x9CA3AF)` 改为设计令牌 `AppColor.buttonDisabled`。

- **Android AppButton.kt**：新增 `loading` 参数（对齐 iOS `setLoading`）；禁用/加载态填充色改用 `AppColor.buttonDisabled` 令牌；secondary 样式背景色由透明改 `AppColor.bgCard` 对齐 iOS 实现。

- **DemoShowcases.swift**：ui.button 条目 reviewed=false → true，create=nil → `{ ButtonShowcase() }`。

- **MainActivity.kt**：ui.button 条目 reviewed=false → true，demo=nil → `{ ButtonDemo() }`。

- **ui-version.json**：组件库版本 1.1.5 → 1.1.6（双端 iOS / Android 永远同版本，禁止手工改工程内版本）。

## \[1.1.5] - 2026-09-02

Cell v1.31 恢复诊断色到设计令牌色 + 补录 v1.30–v1.30c Demo4 三项未入库修复 + 根治 SwiftPM 缓存漂移。

### Fixed

- **iOS Cell 移除 v1.29 诊断色（9 处 systemColor 赋值 + 1 处 tableView 背景）**：按「组件分色排查法」第 6 步收尾流程，Demo4 4 项问题定位修复完毕后移除临时诊断色。还原：`backgroundColor & contentView.backgroundColor` → `AppColor.bgCard`；`iconView / titleLabel / subtitleLabel / valueLabel / arrowView / statusBadge / textStack.backgroundColor` → 透明（不设值）；`skeletonView.backgroundColor` → `AppColor.border`（与 Android 骨架灰底一致）；`tableView.backgroundColor`（Demo 页面内）→ `AppColor.bgPage`。

- **iOS Cell setHighlighted 禁用态错位修复**：`model.disabled` 为 true 时，`apply()` 已把 `contentView.backgroundColor = AppColor.gray4`（置灰语义）；之前 `setHighlighted` 无条件在松手恢复为蓝（诊断蓝 / bgCard），导致「禁用 cell 按住变灰 → 松手变白」视觉错位；本版补 `guard !model.disabled else { return }`，禁用态全程保持 gray4。

- **【补录 v1.30】iOS Demo4 行 1/2 底部无内边距**：`rowSpacing=16pt` 的 divider 间隙占据 contentView 底部 16pt bgPage 色，`hasSubtitle` 分支 `textStack.bottom = contentView.bottom - cellVertical` 恰好落在灰色间隙区（视觉上蓝色内边距=0），与 top 不对称。修复：两处 bottom `-cellVertical` → `-(cellVertical + rowSpacing)`（完整形态与「无 icon+副标题」两分支同步）。

- **【补录 v1.30】Android Demo4 行 6 loading 态箭头未右对齐**：loading 分支 `SkeletonTitle()` 按 `fillMaxWidth(0.4f)` 显示固有宽度，Row 尾部 arrow 紧贴骨架右侧。修复：外包 `Box(Modifier.weight(1f))`，撑满中间剩余空间，箭头被推到整行最右（与正常态 `Column(weight(1f))` 对称）。

- **【补录 v1.30c】Android Demo4 行 4 Error 图标与 iOS 不一致**：Material Icons 标准集无「圆+!」向量（仅有 `Warning`=三角!、`Cancel`=圆×），而 iOS 使用 SF Symbols `exclamationmark.circle.fill`（红圆+白!）。v1.30b 曾误入 `ImageVector.Builder + VectorConfig + SolidColor` 组合（Compose 无此 API），导致 `:android:components:compileDebugKotlin` 编译失败。v1.30c 修复为 Compose Canvas 直接绘制 `ErrorCircleBadge()`：drawCircle 红填充 + drawRect 白竖条 + drawRect 白圆点（24×24dp 视窗按短边缩放），颜色直接取 `AppColor.error` 设计令牌；双端令牌已核对：iOS `UIColor(hex: 0xDC2626)` ≡ Android `Color(0xFFDC2626)`，与 Success 色 `0x16A34A` 配对一致。

- **【根治】ios/Package.swift SwiftPM 依赖缓存漂移**：4 条依赖（Alamofire 5.9.1 / GRDB.swift 6.29.3 / Charts 4.1.0 / SnapKit 5.6.0）由 `.package(url:, exact:)` 远程 URL 改为 `.package(path: "Vendor/…")` 本地路径；`targets.dependencies` 中 GRDB 引用由 `package: "GRDB.swift"` → `package: "GRDB"`（本地路径依赖以子包自身 Package.swift 的 `name:` 字段为引用键，GRDB 自身 `name="GRDB"` 非目录名）；`targets.exclude` 移除 `"Vendor"`（远程+本地两份冲突时需要屏蔽，改纯本地后必须解除屏蔽以便 SwiftPM 直接扫描 Vendor 下 manifest）；Vendor 内部依赖链闭合：Charts → `../swift-algorithms` → `../swift-numerics` 均为相对本地路径引用，不产生任何远程 checkout。根治目的：终结 2026-08-30 起反复出现的「Charts/Package.swift:25 Extra arguments at positions #3, #4 / Reference to member 'produ' cannot be resolved」——根因是 SwiftPM 读取 `.build/checkouts/Charts` 下远程缓存脏 manifest，本地 Vendor 修复从未生效。

### Changed

- **双端 Demo 版本徽标**：v1.30 → v1.31。

- **ui-version.json**：组件库版本 1.1.4 → 1.1.5（双端 iOS / Android 永远同版本，禁止手工改工程内版本）。

## \[1.1.4] - 2026-09-02

Cell v1.28 修复无箭头无状态时 valueLabel trailing 锚点错误导致文字消失。

### Fixed

- **iOS Cell 无箭头无状态时文字消失**：v1.27 Demo2 改 `arrow: false` 后文字消失，Demo3（有箭头）正常。根因：`apply()` 中 valueLabel 的 trailing 锚点逻辑——当 `showArrow=false` 且 `hasStatus=false` 时，`valueTrailingTarget=contentView`，用 `.snp.leading` 锚点导致 `valueLabel.trailing = contentView.leading - lg`（左边外），进而 `textStack.trailing <= valueLabel.leading - sm` 变负数，textStack 宽度为负，文字被压缩消失。修复：拆分为三分支（有状态贴 statusBadge.leading / 有箭头贴 arrowView\.leading / 都没有贴 `contentView.trailing - lg`），消除 `.snp.leading` 方向错误。此 bug 一直潜伏，v1.27 之前所有 Demo 都带箭头（arrow 默认 true）从未触发。

### Changed

- **iOS Demo 版本徽标**：v1.27 → v1.28。

## \[1.1.3] - 2026-09-02

Cell v1.26 修复横屏 contentView 没充满 cell（safeArea inset 导致）+ Demo2 箭头配置修正。

### Fixed

- **iOS Cell 横屏 contentView 没充满 cell**：`UITableViewCell.insetsContentViewsToSafeArea` 默认 true（iOS 11+），横屏时 iPhone X+ 系列 safeArea 左右各 44pt，系统把 contentView inset 到 safeArea 内，cell 两侧（safeArea 外）露出 `cell.backgroundColor`，形成"白色块点击不变灰"现象（区块在 contentView 外不受 setHighlighted 影响）。竖屏 safeArea 左右=0 故无此问题。v1.26 诊断色（cell=红/contentView=蓝/tableView=紫）确认区块为红色=cell 自身背景。修复：重写 `layoutSubviews`，在 `super.layoutSubviews()` 后强制 `contentView.frame = bounds`，让 contentView 充满 cell 覆盖红色背景。内容子视图仍受 leading/trailing offset 约束在 safeArea 内，不被刘海遮挡。

- **iOS Demo2 箭头配置 bug**：`CellModel.arrow` 默认 true，Demo2「仅标题文字」未显式设 `arrow: false`，导致 Demo2 与 Demo3 配置完全一致（都带箭头），失去「纯标题无箭头」对照价值。修正：Demo2 显式 `arrow: false`，标题改「② 仅标题文字（无箭头）」，与 Demo3「标题+箭头」形成真正的单因子对照。

### Changed

- **iOS Cell 移除诊断色**：v1.25-v1.26 为排查横屏问题临时设 cell/contentView/textStack/titleLabel/tableView 为红/蓝/黄/橙/紫诊断色，本版恢复 `AppColor.bgCard` / `AppColor.bgPage`。

- **iOS Demo 版本徽标**：v1.25 → v1.27。

## \[1.1.2] - 2026-09-01

Cell v1.24 修复横屏"绿色块"问题（debug 副作用）+ 仅标题分支行高对齐设计稿。

### Fixed

- **iOS Cell 横屏"绿色块"问题**：v1.23 为排查横屏白色块临时将 `backgroundColor` / `contentView.backgroundColor` 设为 `.systemGreen`，暴露了 cell 56pt 内 textStack 只占 \~19pt、上下空白 \~24pt 的 layout 真相（横屏 cell 宽度变宽，绿色空白横向铺满变明显）。本版改回 `AppColor.bgCard`，绿色块变白色，视觉恢复正常。**非横屏特有 layout bug**，divider 始终在 cell 内部底部 16pt（bgPage 间隙色，不透明），不受影响。

### Changed

- **iOS Cell 仅标题分支行高对齐设计稿**：`apply()` 中仅标题分支（hasSubtitle=false）也调用 `titleLabel.setLineHeight(AppText.cellTitleLineHeight, fontSize: AppFont.sizeMd)`，让 textStack 行高 = 24pt（设计稿 cellTitleLineHeight）。v1.20 曾注释"仅标题不设 attributedText 让 UILabel 原生垂直居中"，但实测发现行高退化到系统默认 \~19pt，导致 cell 内部上下空白 \~24pt（偏离设计稿 cellVertical=16pt）。设行高 24pt 后 textStack 24pt，centerY 居中到 divider 上方可见区（0-40pt），上下空白各 8pt（divider 占下方 16pt，故可见区上下内边距折半为 8pt，符合设计稿逻辑）。

- **iOS Demo 版本徽标**：v1.23 → v1.24。

## \[1.1.1] - 2026-09-01

修正 v1.1.0 的错误垂直居中补偿：iOS 原生 `minimumLineHeight = maximumLineHeight` 撑行高时文字已接近居中，v1.1.0 额外加的 `baselineOffset` 补偿反而把文字整体下推（且放大 `UILabel.intrinsicContentSize`，撑高 textStack → 箭头同步偏下）。本版移除补偿，恢复原生行高分配，对齐 Android Compose 视觉。

### Fixed

- **iOS Cell 文字/箭头垂直居中（v1.18 修正）**：`AppText.verticalCenterBaselineOffset` 由 `(lineHeight - naturalLineHeight)/2` 改为返回 `0`（不补偿）。依据：macOS TextKit 像素级实测 + iOS 用户实测双重确认——原生 min/max 行高下文字质心偏差仅 +0.5pt，叠加补偿后 +3.5pt（偏下，复现用户实测）。同时 `baselineOffset` 会增大 `UILabel.intrinsicContentSize`，撑高 `textStack`（箭头 `centerY` 锚定它）导致箭头同步偏下，移除补偿一并解决。

- **iOS Demo 横屏不适配**：`SelfSizingTableView.intrinsicContentSize` 原只在高度变化时 invalidate，横屏旋转后宽度变化不触发重算，cell 不随屏幕宽度自适应。现宽度/高度任一变化均刷新。

- **iOS 垂直居中实测辅助**：新增 `Cell.debugTitleVerticalOffset()` / `debugTrailingCenterOffset()`，demo「② 仅标题」组输出标题/箭头相对 cell 内容区中心的实测偏移（pt），供 iOS 实机校准真值（替代纯数学推导）。

### Changed

- **iOS** **`CellTests`** **H3**：断言改为 v1.18 校准结论（补偿值恒为 0，行高契约 24/18 + 单行 56 不变）。

- **新增 iOS** **`CellTests`** **H3b**：实测辅助方法可用性断言（返回有限值）。

## \[1.1.0] - 2026-09-01

修复 Cell 单行标题在行内文字未垂直居中（iOS 平台独有，Android Compose `lineHeight` 天然居中）。

### Fixed

- **iOS Cell 标题行内文字垂直居中**：`AppText.setLineHeight` 使用 `minimumLineHeight/maximumLineHeight` 撑行高时，额外行高由系统按字体度量分配，不保证行内文字居中（用户实测 Demo2 标题偏上/偏下）。新增 `AppText.verticalCenterBaselineOffset(lineHeight:fontSize:font:)` 计算基线补偿，以 `baselineOffset` 下移半个额外高度，使文字在行高内视觉居中，对齐 Android Compose `lineHeight` 行为。

- 双端行高契约保持一致（单行 56 / 副标题 76），本次仅修正行高内文字垂直位置，不改动行高数值。

### Added

- **iOS** **`CellTests`** **H3**：断言 `verticalCenterBaselineOffset` 使「文字中心 = 行高中点」，固化行内垂直居中契约（token 层）。

- **Android** **`CellTest`** **H4**：渲染层断言单行标题节点垂直中心 ≈ cell-root 中心，防回归（Robolectric 可跑）。

## \[Unreleased]

### Removed

- **视觉资产淘汰（svg/截图 → H5 规格页）**：删除 `docs/design-spec/svg/`（27 个 SVG 设计图）、`docs/visuals/` 与 `www/public/visuals/`（组件截图）；`api.json` 移除 `visual_refs` 字段；删除生成脚本 `generate_design_svgs.py`、`build_design_gallery.py`、`migrate_taxonomy_names.py`。设计规格统一以 H5 规格页为准（`docs/design-spec/cell-design-spec.html` 等）。

- **一次性迁移产物清理**：删除 `docs/id-migration.json`（分类改名迁移已完成，历史在 git 可查）。

### Changed

- **验收流程收拢**：验收四件套移入 `docs/验收流程/`（`验收标准.md` / `flow.html` / `验收模板.md` / `评审清单.md`），新增 `docs/验收流程/README.md` 流程索引。

- **规范文档合并（8 → 3）**：`component-rules.md` + `api-contract.md` + `component-schema.md` → `docs/开发规则.md`；`design-spec.md` + `design-token-README.md` → `docs/设计规范.md`；`component-governance.md` + `versioning.md` + `containment.md` → `docs/治理规范.md`。新增 `docs/README.md` 目录导航与 `docs/平台差异.md`（补齐历史悬空引用）。

- **文档中文命名**：docs 内人工阅读文档统一中文命名（`开发规则.md`/`设计规范.md`/`治理规范.md`/`组件分类.md`/`组件进度.md`/`平台差异.md`/`组件审计.md`/`验收流程/` 等），机器消费数据源（`*.json`/`embeddings/`/`*.html`）保留英文。

- **验收标准增强**：五阶段 + 门禁 A/B/C1/C2/D（依赖优先、用例即代码、快照比对、业务落地验证、季度复查/回归清单）。

- **目录收敛（方案 B）**：组件 metadata 收口为 `docs/api.json`（由 `catalog/components.jsonl` 转换，含命名/作用/API 契约 props/events/demos/平台状态/设计 token）；样式数据收口为 `docs/design-token.json`（原 `design-token/tokens.json`）；版本号收口为 `docs/ui-version.json`（原根目录）。

- **目录更名**：`docs-site/` → `www/`（组件文档站，构建时读 `docs/api.json` 生成）；`catalog/`、`design-token/` 目录并入 `docs/`，旧目录删除。

- **组件分类重构**：顶层两大类 `ui`（UI 组件）/ `foundation`（底层能力）；`ui` 新增 `subcategory` 五子类（基础通用 `basics` / 导航 `navigation` / 数据录入 `input` / 数据展示 `display` / 操作反馈 `feedback`，对齐 NutUI 分类）。

- **业务组件剥离**：原 `business.*` 9 个组件移出组件库 `components`（`componentCount` 36 → 27），登记于 api.json 顶层 `businessExtensions`（标注 `tier: business-extension`，为继承基础组件二次开发的业务层产物），不再进入 catalog / embeddings / audit。

- **ID 迁移**：`basic.*` → `ui.*`（如 `basic.empty` → `ui.empty`），`legacy_id` 记录旧值；迁移已完成，迁移表已随 2026-08-30 清理删除（历史在 git 中可查）。

## \[1.0.0] - 2026-08-29

首次以独立组件库仓库发布。完成从 OPC monorepo 到独立仓库 + submodule 的拆分，命名空间统一为 `com.zhiqihuayun.*`。

### Changed

- **命名空间统一**：Android 端 `com.tmo.*` → `com.zhiqihuayun.*`。

  - namespace / groupId：`com.tmo` → `com.zhiqihuayun`

  - 包路径：`com.tmo.foundation.*` → `com.zhiqihuayun.foundation.*`，`com.tmo.sharedui.*` → `com.zhiqihuayun.sharedui.*`

  - 工程名：`tmo-android` → `zhiqihuayun-android`，`tmo-demo-android` → `zhiqihuayun-demo-android`

  - 依赖坐标：`com.tmo:components` → `com.zhiqihuayun:components`

  - iOS Demo：`TMODemo` → `ZhiqihuayunDemo`（bundle id 已为 `com.zhiqihuayun.demo`）

- **仓库拆分**：`packages/*` 迁移为 `Native-UI-Comps` 独立仓（ios / android / shared / design-token / adapters / docs-site），OPC 以 submodule 挂载。

- **文档升级**：docs-site 升级为官方组件库文档（首页 / 使用指南 / 双端契约 / 版本日志 / 设计规范）。

### Added

- 官方文档站正式发布：新增首页、使用指南、双端平台契约矩阵、版本日志页面。

- `com.zhiqihuayun` 命名空间下的统一构建配置。

### Fixed

- 清理 Android 构建产物（`.class` / `.flat` / `.len`）入仓问题，独立仓只保留源码与配置。

## \[0.9.0] - 2026-08-11

> 注：0.9.x 为迁移前 OPC monorepo 内的 `packages/*` 演进记录，供追溯；独立仓以 1.0.0 为起点。

### Added

- 双端组件库收敛为 `packages`（ios + android + design-token + shared）。

- 组件 catalog（`components.jsonl`）与 docs-site 检索站点雏形。

- iOS SPM 产物（Foundation / SharedUI）与 Android AAR（components）。

