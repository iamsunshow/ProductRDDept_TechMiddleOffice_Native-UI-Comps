package com.zhiqihuayun.demo

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.layout.positionInRoot
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt
import kotlinx.coroutines.launch
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.sharedui.components.SafeArea
import com.zhiqihuayun.sharedui.components.SafeAreaAllEdges
import com.zhiqihuayun.sharedui.components.SafeAreaEdges
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.AppButton
import com.zhiqihuayun.sharedui.components.AppButtonStyle
import com.zhiqihuayun.sharedui.components.AppIcon
import com.zhiqihuayun.sharedui.components.AppIconName
import com.zhiqihuayun.sharedui.components.AppTheme
import com.zhiqihuayun.sharedui.components.Cell
import com.zhiqihuayun.sharedui.components.CellStatus
import com.zhiqihuayun.sharedui.components.ConfigProvider
import com.zhiqihuayun.sharedui.components.Divider
import com.zhiqihuayun.sharedui.components.DividerContentPosition
import com.zhiqihuayun.sharedui.components.DividerDirection
import com.zhiqihuayun.sharedui.components.Grid
import com.zhiqihuayun.sharedui.components.GridItem
import com.zhiqihuayun.sharedui.components.ProfileListGroup
import com.zhiqihuayun.sharedui.components.ProfileListItem
import com.zhiqihuayun.sharedui.components.SummaryCardView
import com.zhiqihuayun.sharedui.components.ChartPoint
import com.zhiqihuayun.sharedui.components.TrendChartView
import com.zhiqihuayun.sharedui.components.Overlay
import com.zhiqihuayun.sharedui.components.EmptyStateView
import com.zhiqihuayun.sharedui.components.AvatarOption
import com.zhiqihuayun.sharedui.components.BackTop
import com.zhiqihuayun.sharedui.components.Elevator
import com.zhiqihuayun.sharedui.components.ElevatorFloor
import com.zhiqihuayun.sharedui.components.FixedNav
import com.zhiqihuayun.sharedui.components.FixedNavItem
import com.zhiqihuayun.sharedui.components.FixedNavType
import com.zhiqihuayun.sharedui.components.HoverButton
import com.zhiqihuayun.sharedui.components.NavBar
import com.zhiqihuayun.sharedui.components.NavBarAction
import com.zhiqihuayun.sharedui.components.TabBarItem
import com.zhiqihuayun.sharedui.components.Tabbar
import com.zhiqihuayun.sharedui.components.TabItem
import com.zhiqihuayun.sharedui.components.Tabs
import com.zhiqihuayun.sharedui.components.SideBar
import com.zhiqihuayun.sharedui.components.SideBarItem
import com.zhiqihuayun.sharedui.components.LayoutCol
import com.zhiqihuayun.sharedui.components.LayoutRow
import com.zhiqihuayun.sharedui.components.Space
import com.zhiqihuayun.sharedui.components.SpaceDirection
import com.zhiqihuayun.sharedui.components.ZodiacAvatar
import com.zhiqihuayun.sharedui.components.stickyHeaderItem
import com.zhiqihuayun.sharedui.components.Address
import com.zhiqihuayun.sharedui.components.AddressResult
import com.zhiqihuayun.sharedui.components.RegionOption
import com.zhiqihuayun.sharedui.components.CalendarCard
import com.zhiqihuayun.sharedui.components.CalendarDate
import com.zhiqihuayun.sharedui.components.Cascader
import com.zhiqihuayun.sharedui.components.CascaderOption
import com.zhiqihuayun.sharedui.components.CascaderResult
import com.zhiqihuayun.sharedui.components.Form
import com.zhiqihuayun.sharedui.components.FormFieldRow

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                TmoDemo()
            }
        }
    }
}

// ===== 组件索引（数据源：docs/组件进度.md 任务清单，7 大类 95 组件） =====
// reviewed=true：已通过评审，可点击进入该组件 Demo 页；reviewed=false：未评审，列表置灰不可点。
// 每评审完一个组件：将 reviewed 置 true 并提供 demo，Demo 即自动出现。

data class DemoComponent(
    val name: String,
    val reviewed: Boolean = false,
    val demo: (@Composable () -> Unit)? = null
)

private val demoSections: List<Pair<String, List<DemoComponent>>> = listOf(
    "基础组件" to listOf(
        DemoComponent("Button 按钮", reviewed = true, demo = { ButtonDemo() }),
        DemoComponent("Cell 单元格", reviewed = true, demo = { CellDemo() }),
        DemoComponent("ConfigProvider 全局配置", reviewed = true, demo = { ConfigProviderDemo() }),
        DemoComponent("Icon 图标", reviewed = true, demo = { IconDemo() }),
        DemoComponent("Image 图片", reviewed = true, demo = { ImageDemo() }),
        DemoComponent("Overlay 遮罩层", reviewed = true, demo = { OverlayDemo() }),
    ),
    "布局组件" to listOf(
        DemoComponent("Divider 分割线", reviewed = true, demo = { DividerDemo() }),
        DemoComponent("Grid 宫格", reviewed = true, demo = { GridDemo() }),
        DemoComponent("Layout 布局", reviewed = true, demo = { LayoutDemo() }),
        DemoComponent("SafeArea 安全区", reviewed = true, demo = { SafeAreaDemo() }),
        DemoComponent("Space 间距", reviewed = true, demo = { SpaceDemo() }),
        DemoComponent("Sticky 粘性布局", reviewed = true, demo = { StickyDemo() }),
    ),
    "导航组件" to listOf(
        DemoComponent("BackTop 返回顶部", reviewed = true, demo = { BackTopDemo() }),
        DemoComponent("Elevator 电梯楼层", reviewed = true, demo = { ElevatorDemo() }),
        DemoComponent("FixedNav 悬浮导航", reviewed = true, demo = { FixedNavDemo() }),
        DemoComponent("HoverButton 悬浮按钮", reviewed = true, demo = { HoverButtonDemo() }),
        DemoComponent("NavBar 头部导航", reviewed = true, demo = { NavBarDemo() }),
        DemoComponent("SideBar 侧边导航", reviewed = true, demo = { SideBarDemo() }),
        DemoComponent("Tabbar 标签栏", reviewed = true, demo = { TabbarDemo() }),
        DemoComponent("Tabs 选项卡", reviewed = true, demo = { TabsDemo() }),
    ),
    "数据录入" to listOf(
        DemoComponent("Address 地址", reviewed = true, demo = { AddressDemo() }),
        DemoComponent("Calendar 日历"),
        DemoComponent("CalendarCard 日历卡片", reviewed = true, demo = { CalendarCardDemo() }),
        DemoComponent("Cascader 级联选择", reviewed = true, demo = { CascaderDemo() }),
        DemoComponent("Checkbox 复选"),
        DemoComponent("DatePicker 日期选择"),
        DemoComponent("DatePickerView 视图"),
        DemoComponent("Form 表单", reviewed = true, demo = { FormDemo() }),
        DemoComponent("Input 输入框"),
        DemoComponent("InputNumber 数字输入"),
        DemoComponent("Menu 菜单"),
        DemoComponent("NumberKeyboard 数字键盘"),
        DemoComponent("Picker 选择器"),
        DemoComponent("PickerView 视图"),
        DemoComponent("Radio 单选"),
        DemoComponent("Range 区间选择"),
        DemoComponent("Rate 评分"),
        DemoComponent("SearchBar 搜索栏"),
        DemoComponent("ShortPassword 短密码"),
        DemoComponent("Signature 签名"),
        DemoComponent("Switch 开关"),
        DemoComponent("TextArea 文本域"),
        DemoComponent("Uploader 上传"),
    ),
    "操作反馈" to listOf(
        DemoComponent("ActionSheet 动作面板"),
        DemoComponent("Badge 徽标"),
        DemoComponent("Dialog 对话框"),
        DemoComponent("Drag 拖拽"),
        DemoComponent("Empty 空状态", reviewed = true, demo = { EmptyDemo() }),
        DemoComponent("InfiniteLoading 滚动加载"),
        DemoComponent("Loading 加载中"),
        DemoComponent("NoticeBar 公告栏"),
        DemoComponent("Notify 消息通知"),
        DemoComponent("Popover 气泡弹出框"),
        DemoComponent("Popup 弹出层"),
        DemoComponent("PullToRefresh 下拉刷新"),
        DemoComponent("ResultPage 结果反馈"),
        DemoComponent("Skeleton 骨架屏"),
        DemoComponent("Swipe 滑动"),
        DemoComponent("Toast 吐司"),
    ),
    "展示组件" to listOf(
        DemoComponent("Animate 动画"),
        DemoComponent("AnimatingNumbers 数字动画"),
        DemoComponent("Audio 音频播放器"),
        DemoComponent("Avatar 头像", reviewed = true, demo = { AvatarDemo() }),
        DemoComponent("CircleProgress 环形进度"),
        DemoComponent("Collapse 折叠面板"),
        DemoComponent("CountDown 倒计时"),
        DemoComponent("Ellipsis 文本省略"),
        DemoComponent("ImagePreview 图片预览"),
        DemoComponent("Indicator 指示器"),
        DemoComponent("LineChart 折线图", reviewed = true, demo = { LineChartDemo() }),
        DemoComponent("Lottie 动画"),
        DemoComponent("Pagination 分页"),
        DemoComponent("Price 价格"),
        DemoComponent("Progress 进度条"),
        DemoComponent("Segmented 分段选择器"),
        DemoComponent("Steps 步骤条"),
        DemoComponent("Swiper 轮播"),
        DemoComponent("Table 表格"),
        DemoComponent("Tag 标签"),
        DemoComponent("Tour 引导"),
        DemoComponent("Video 视频播放器"),
        DemoComponent("VirtualList 虚拟列表"),
        DemoComponent("List 分组列表", reviewed = true, demo = { ListDemo() }),
    ),
    "特色组件" to listOf(
        DemoComponent("QuickEnter 快捷入口"),
        DemoComponent("AvatarCropper 头像裁剪"),
        DemoComponent("Barrage 弹幕"),
        DemoComponent("Card 商品卡片", reviewed = true, demo = { CardDemo() }),
        DemoComponent("TimeSelect 配送时间"),
        DemoComponent("TrendArrow 趋势箭头"),
        DemoComponent("WaterMark 水印"),
        DemoComponent("Calendar 日历工具"),
        DemoComponent("SystemBars 系统栏"),
        DemoComponent("DesignTokens 设计令牌"),
    ),
    "底层能力 foundation" to listOf(
        DemoComponent("Router 路由"),
        DemoComponent("Storage 本地存储"),
        DemoComponent("HTTPClient 网络客户端"),
        DemoComponent("MoneyFormat 金额格式化"),
    ),
)

/**
 * Native-UI-Comps Android Demo。
 * 首页 = 组件列表（分类 + 组件）：已评审组件可点击进入其 Demo 页；未评审置灰不可点。
 */
@Composable
fun TmoDemo() {
    var current by remember { mutableStateOf<(@Composable () -> Unit)?>(null) }
    var currentTitle by remember { mutableStateOf("") }

    if (current == null) {
        ComponentList(onOpen = { name, demo ->
            currentTitle = name
            current = demo
        })
    } else {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(AppColor.bgPage)
                .statusBarsPadding()
        ) {
            // 返回按钮（左对齐，无标题）
            TextButton(
                onClick = { current = null },
                modifier = Modifier.padding(horizontal = AppSpace.sm)
            ) {
                Text(text = "← 返回", color = AppColor.primary, fontSize = AppFont.sizeMd)
            }
            // 大标题（在 Demo 内容上方，版本徽标之上，对齐 iOS 大标题样式）
            Text(
                text = currentTitle,
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeXl,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
            )
            current?.invoke()
        }
    }
}

@Composable
private fun ComponentList(onOpen: (String, @Composable () -> Unit) -> Unit) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .padding(horizontal = AppSpace.md, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
    ) {
        item {
            Text(
                text = "Native-UI-Comps 组件 Demo",
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeXl,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(vertical = AppSpace.sm)
            )
        }
        demoSections.forEach { (category, components) ->
            item {
                Text(
                    text = category,
                    color = AppColor.textSecondary,
                    fontSize = AppFont.sizeSm,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.padding(top = AppSpace.md, bottom = AppSpace.xs)
                )
            }
            items(components) { comp ->
                ComponentRow(comp, onClick = { onOpen(comp.name, comp.demo!!) })
            }
        }
    }
}

@Composable
private fun ComponentRow(comp: DemoComponent, onClick: () -> Unit) {
    val enabled = comp.reviewed && comp.demo != null
    Surface(
        onClick = onClick,
        enabled = enabled,
        color = AppColor.bgCard,
        shape = RoundedCornerShape(AppRadius.sm),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(horizontal = AppSpace.md, vertical = AppSpace.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = comp.name,
                color = if (enabled) AppColor.textPrimary else AppColor.gray25,
                fontSize = AppFont.sizeMd
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = if (enabled) "已评审 ✓" else "未评审",
                color = if (enabled) AppColor.primary else AppColor.gray25,
                fontSize = AppFont.sizeSm
            )
        }
    }
}

// ===== Cell 组件 Demo 页（独立页面） =====

@Composable
private fun CellDemo() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：ui-version.json v1.3.10（§7h 强制：C2/发版必升徽标版本）；双端一致。
        // C2→D 发版 v1.3.10：Android 12/12+脚本 4/4 + iOS Simulator 16/16 全绿，试点首件 A→D 闭环。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "Cell 组件 v1.3.10 (2026-09-03 23:58)",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // B 方案 - 固定高度参考块：56dp 色块（= 设计稿「32 号字 cell」单行），跨设备目测 cell 高度是否达标。
        Text(
            text = "高度参考：下方色块高 = 56dp（= 设计稿单行 cell）",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .background(AppColor.gray4)
        )

        // 点击反馈：与 iOS 的 addInfo 对齐，让点击态与回调可见可核对。
        // D 方案：实时显示上一次点击 cell 的实测高度（dp）。
        var clickInfo by remember { mutableStateOf("点击任意 cell 查看按压变色 + 此处反馈") }
        Text(
            text = clickInfo,
            color = AppColor.primary,
            fontSize = AppFont.sizeXs,
            fontWeight = FontWeight.Medium
        )
        fun onCellClick(label: String, heightDp: Float? = null) {
            clickInfo = if (heightDp != null) {
                "点击了：$label（实测高度 $heightDp dp）"
            } else {
                "点击了：$label"
            }
        }

        // ===== 逐步递增的单因子排查分组（与 iOS CellShowcase 一一对应）=====
        // ① 空行（仅背景色，无内容）：排查 cell 基础骨架/行高/背景色。
        // 统一用「间隙」分隔（与 iOS 一致）：showsDivider=false 去掉 1px 横线，
        // 间距由外层 Column 的 Arrangement.spacedBy(AppSpace.lg) 承担。
        Text(text = "① 空行（仅背景色，无内容）", color = AppColor.textPrimary, fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold)
        MeasuredCell(label = "① 空行-1") { h ->
            Cell(title = "", arrow = false, showsDivider = false, onClick = { onCellClick("① 空行-1", h) })
        }
        MeasuredCell(label = "① 空行-2") { h ->
            Cell(title = "", arrow = false, showsDivider = false, onClick = { onCellClick("① 空行-2", h) })
        }
        Text(
            text = "排查点：cell 基础骨架 / 行高 / 背景色。若此处就不对，是基础布局问题，与文字无关。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ② 仅标题文字：排查标题文字的布局/垂直居中。
        Text(text = "② 仅标题文字", color = AppColor.textPrimary, fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold)
        MeasuredCell(label = "② 默认行标题") { h ->
            Cell(title = "默认行标题", showsDivider = false, onClick = { onCellClick("② 默认行标题", h) })
        }
        MeasuredCell(label = "② 长标题") { h ->
            Cell(title = "标题较长，用来观察换行与垂直位置", showsDivider = false, onClick = { onCellClick("② 长标题", h) })
        }
        Text(
            text = "排查点：标题文字的布局 / 垂直居中。只加文字，无箭头/图标/value。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ③ 标题 + 箭头：排查文字与右侧箭头的水平布局。
        Text(text = "③ 标题 + 箭头", color = AppColor.textPrimary, fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold)
        MeasuredCell(label = "③ 标题+箭头") { h ->
            Cell(title = "标题 + 右侧箭头", showsDivider = false, onClick = { onCellClick("③ 标题+箭头", h) })
        }
        MeasuredCell(label = "③ 长标题+箭头") { h ->
            Cell(title = "标题较长 + 箭头对齐", showsDivider = false, onClick = { onCellClick("③ 长标题+箭头", h) })
        }
        Text(
            text = "排查点：文字与右侧箭头的水平布局。只加箭头。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ④ 完整形态（对照）：图标 + 副标题 + value + 状态标识。
        Text(text = "④ 完整形态（对照）", color = AppColor.textPrimary, fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold)
        MeasuredCell(label = "④ 默认行") { h ->
            Cell(title = "默认行", subtitle = "副标题示例", value = "¥3,850.00", showsDivider = false, onClick = { onCellClick("④ 默认行", h) })
        }
        MeasuredCell(label = "④ 带图标") { h ->
            Cell(
                title = "带图标",
                subtitle = "icon 参数显示左侧图标",
                icon = rememberVectorPainter(Icons.Filled.Favorite),
                value = "收藏",
                showsDivider = false,
                onClick = { onCellClick("④ 带图标", h) }
            )
        }
        MeasuredCell(label = "④ 同步成功") { h ->
            Cell(title = "同步成功", value = "正常态", status = CellStatus.Success, showsDivider = false, onClick = { onCellClick("④ 同步成功", h) })
        }
        MeasuredCell(label = "④ 同步失败") { h ->
            Cell(title = "同步失败", value = "错误态", status = CellStatus.Error, showsDivider = false, onClick = { onCellClick("④ 同步失败", h) })
        }
        Cell(title = "禁用态", value = "不可点", disabled = true, showsDivider = false)
        Cell(title = "加载中", value = "骨架动画", loading = true, showsDivider = false)
        Text(
            text = "排查点：图标 + 副标题 + value + 状态标识的完整组合。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )
    }
}

/**
 * D 方案 - 可复用的"带高度测量的 Cell 容器"：
 * 用 onSizeChanged 读取子 cell 的真实高度（px→dp），并把它暴露给 content lambda，
 * 这样 demo 里点击 cell 时可带上"实测高度 dp"，跨设备精确核对，不依赖模拟器尺寸。
 * 长期保留作为组件的常规核对工具。
 */
@Composable
private fun MeasuredCell(label: String, content: @Composable (heightDp: Float) -> Unit) {
    var measuredHeightDp by remember { mutableStateOf(0f) }
    val density = LocalDensity.current
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .onSizeChanged { size ->
                measuredHeightDp = size.height.toFloat() / density.density
            }
    ) {
        content(measuredHeightDp)
    }
}

// ===== Button 组件 Demo 页（独立页面，与 iOS ButtonShowcase 一一对应） =====

private data class BtnConfig(
    val style: AppButtonStyle,
    val text: String,
    val enabled: Boolean = true,
    val loading: Boolean = false
)

private data class BtnGroup(
    val title: String,
    val note: String,
    val configs: List<BtnConfig>
)

private val btnGroups: List<BtnGroup> = listOf(
    BtnGroup(
        title = "① 基础形态（仅 Primary）",
        note = "排查点：骨架/高度(48dp)/圆角(lg)/主色填充/白字/按下态反馈。只放 primary 样式，验证基础视觉。",
        configs = listOf(
            BtnConfig(style = AppButtonStyle.Primary, text = "登录"),
            BtnConfig(style = AppButtonStyle.Primary, text = "注册")
        )
    ),
    BtnGroup(
        title = "② style 切换（三样式对照）",
        note = "排查点：primary(主色填充+白字) vs secondary(白底+主色描边+主色字) vs destructive(白底+红色描边+红色字)。",
        configs = listOf(
            BtnConfig(style = AppButtonStyle.Primary, text = "主操作"),
            BtnConfig(style = AppButtonStyle.Secondary, text = "次操作"),
            BtnConfig(style = AppButtonStyle.Destructive, text = "删除")
        )
    ),
    BtnGroup(
        title = "③ 状态（loading + disabled）",
        note = "排查点：loading 态置灰(buttonDisabled)+文案「加载中...」+不可点击；disabled 态置灰+不可点击。",
        configs = listOf(
            BtnConfig(style = AppButtonStyle.Primary, text = "加载中", loading = true),
            BtnConfig(style = AppButtonStyle.Primary, text = "已禁用", enabled = false),
            BtnConfig(style = AppButtonStyle.Secondary, text = "次操作加载", loading = true),
            BtnConfig(style = AppButtonStyle.Destructive, text = "删除禁用", enabled = false)
        )
    ),
    BtnGroup(
        title = "④ 全形态（三样式×三状态组合）",
        note = "排查点：三样式 × 三状态(normal/loading/disabled)完整组合，点击有反馈。",
        configs = listOf(
            BtnConfig(style = AppButtonStyle.Primary, text = "主操作"),
            BtnConfig(style = AppButtonStyle.Primary, text = "主操作加载", loading = true),
            BtnConfig(style = AppButtonStyle.Primary, text = "主操作禁用", enabled = false),
            BtnConfig(style = AppButtonStyle.Secondary, text = "次操作"),
            BtnConfig(style = AppButtonStyle.Secondary, text = "次操作加载", loading = true),
            BtnConfig(style = AppButtonStyle.Secondary, text = "次操作禁用", enabled = false),
            BtnConfig(style = AppButtonStyle.Destructive, text = "删除"),
            BtnConfig(style = AppButtonStyle.Destructive, text = "删除加载", loading = true),
            BtnConfig(style = AppButtonStyle.Destructive, text = "删除禁用", enabled = false)
        )
    )
)

@Composable
private fun ButtonDemo() {
    var clickInfo by remember { mutableStateOf("点击任意按钮查看反馈") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：与 iOS 端保持同一版本号。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "Button 组件 v1.4",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // 点击反馈条
        Text(
            text = clickInfo,
            color = AppColor.primary,
            fontSize = AppFont.sizeXs,
            fontWeight = FontWeight.Medium
        )

        for (group in btnGroups) {
            Text(
                text = group.title,
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeMd,
                fontWeight = FontWeight.SemiBold
            )
            Column(verticalArrangement = Arrangement.spacedBy(AppSpace.md)) {
                for (config in group.configs) {
                    val displayText = config.text
                    AppButton(
                        text = displayText,
                        onClick = { clickInfo = "点击了：$displayText" },
                        style = config.style,
                        enabled = config.enabled,
                        loading = config.loading
                    )
                }
            }
            Text(
                text = group.note,
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeXs
            )
        }
    }
}

// ===== Icon 组件 Demo 页（独立页面，与 iOS IconShowcase 一一对应） =====

@Composable
private fun IconDemo() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：与 iOS 端保持同一版本号。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "Icon 组件 v1.2",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // ① 基础形态：全部 8 个图标，默认尺寸(24dp) + 默认色(textPrimary)
        Text(
            text = "① 基础形态（8 图标默认尺寸 24dp）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            for (name in AppIconName.entries) {
                AppIcon(name = name, size = 24.dp, tint = AppColor.textPrimary)
            }
        }
        Text(
            text = "排查点：8 个图标是否全部渲染（SfApproxIcons）。若缺图说明矢量映射有误。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ② 尺寸因子：同一图标 list 不同尺寸 16/24/32/48dp
        Text(
            text = "② 尺寸因子（list × 16/24/32/48dp）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            for (size in listOf(16.dp, 24.dp, 32.dp, 48.dp)) {
                AppIcon(name = AppIconName.List, size = size, tint = AppColor.textPrimary)
            }
        }
        Text(
            text = "排查点：尺寸缩放是否正比、无变形。16dp 应清晰可辨，48dp 应饱满。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ③ 着色因子：同一图标 person 不同颜色
        Text(
            text = "③ 着色因子（person × 4 色）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            val colors = listOf(
                AppColor.textPrimary to "textPrimary",
                AppColor.primary to "primary",
                AppColor.error to "error",
                AppColor.textSecondary to "textSecondary"
            )
            for ((color, _) in colors) {
                AppIcon(name = AppIconName.Person, size = 32.dp, tint = color)
            }
        }
        Text(
            text = "排查点：tint 是否生效。4 个 person 应分别为深灰/绿/红/浅灰。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ④ 全形态网格：8 图标 × 3 色（textPrimary/primary/error）
        Text(
            text = "④ 全形态网格（8 图标 × 3 色）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        val gridColors = listOf(AppColor.textPrimary, AppColor.primary, AppColor.error)
        for (color in gridColors) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                for (name in AppIconName.entries) {
                    AppIcon(name = name, size = 28.dp, tint = color)
                }
            }
        }
        Text(
            text = "排查点：8 图标 × 3 色完整组合。第 1 行深灰、第 2 行绿、第 3 行红，每行 8 个图标对齐。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )
    }
}

// ===== ConfigProvider 组件 Demo 页（独立页面，与 iOS ConfigProviderShowcase 一一对应） =====
// Provider 型组件无视觉五态（默认/禁用/加载/成功/失败不适用），Demo 用「配置生效对比」演示：
// 消费块直读 AppTheme 解析层，展示解析出的 primaryColor / radiusMd / spaceLg 实际值，
// 同屏对比 覆盖前（基准）vs 覆盖后，嵌套作用域演示「内层优先 + 未设项继承」（门禁 C1.5）。

@Composable
private fun ConfigProviderDemo() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：= 组件库正式版本 v1.3.11（对齐 ui-version.json v1.3.11；§7h 强制 C2/发版必升）。
        // C2→D 发版 v1.3.11：双端 15/15+15/15 全绿 + 用户实机对照 D1/D6/D8。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "ConfigProvider 组件 v1.3.11 (2026-09-03 23:59)",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }
        Text(
            text = "定位：design-token 静态基准之上的运行时覆盖层。消费块直读 AppTheme 解析层，同屏对比覆盖前后实际解析值。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ① 基准区：未挂 Provider → 静态基准（零行为变化，D1）
        Text(
            text = "① 基准区（未挂 Provider）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        ConfigProbe()
        Text(
            text = "预期：primary = AppColor.primary（#16A34A）、radiusMd = 10 dp（md 档）、spaceLg = 16 dp（lg 档）。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ② 组合覆盖：primaryColor + rounded + compact 三项同时生效（D8）
        Text(
            text = "② 组合覆盖（primaryColor #4F46E5 + rounded + compact）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        ConfigProvider(primaryColor = "#4F46E5", rounded = true, compact = true) {
            ConfigProbe()
        }
        Text(
            text = "预期：primary → #4F46E5；radiusMd 升档 md→lg（10→14 dp）；spaceLg 降档 lg→md（16→12 dp）；三项互不干扰。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ③ 嵌套作用域：外层 primaryColor → 内层 compact（内层优先 + 未设项继承，D6）
        Text(
            text = "③ 嵌套（外层 primaryColor #2563EB → 内层 compact）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        ConfigProvider(primaryColor = "#2563EB") {
            ConfigProbe()
            ConfigProvider(compact = true) {
                ConfigProbe()
            }
        }
        Text(
            text = "预期：两块 primary 均 = #2563EB；外层块 spaceLg = 16 dp（默认 lg 档），内层块 spaceLg = 12 dp（compact 生效，内层优先）。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )
    }
}

/** 配置消费块：渲染时刻读取 AppTheme 解析层当前值（未挂 Provider → 静态基准）。 */
@Composable
private fun ConfigProbe() {
    val primary = AppTheme.primaryColor()
    val radiusMd = AppTheme.radiusMd()
    val spaceLg = AppTheme.spaceLg()
    Row(verticalAlignment = Alignment.CenterVertically) {
        // 主色圆角色块：主题色覆盖 + 圆角升档的直接视觉观测点。
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(RoundedCornerShape(radiusMd))
                .background(primary)
        )
        Spacer(modifier = Modifier.width(AppSpace.md))
        Column {
            Text(
                text = "primary = ${colorToHex(primary)}",
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeXs
            )
            Text(
                text = "radiusMd = ${radiusMd.value.toInt()} dp",
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeXs
            )
            Text(
                text = "spaceLg = ${spaceLg.value.toInt()} dp",
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeXs
            )
        }
    }
}

/** 解析色值转 "#RRGGBB"（仅用于 Demo 读数展示）。 */
private fun colorToHex(color: Color): String =
    String.format("#%06X", 0xFFFFFF and color.toArgb())

// ===== Empty 组件 Demo 页（独立页面，与 iOS EmptyShowcase 一一对应） =====

@Composable
private fun EmptyDemo() {
    // 版本徽标
    Text(
        text = "Empty 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )

    Text(
        text = "4 组排查：① 默认空态 ② 自定义文案 ③ 带图标 ④ 固定容器空态。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：默认空态 ──
        Text("Demo 1 · 默认空态", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Box(modifier = Modifier.fillMaxWidth().height(160.dp)) {
            EmptyStateView()
        }

        // ── Demo 2：自定义文案 ──
        Text("Demo 2 · 自定义文案", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Box(modifier = Modifier.fillMaxWidth().height(160.dp)) {
            EmptyStateView(message = "搜索无结果，换个关键词试试")
        }

        // ── Demo 3：带图标空态 ──
        Text("Demo 3 · 带图标空态", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Box(modifier = Modifier.fillMaxWidth().height(200.dp)) {
            EmptyStateView(
                message = "暂无记录",
                icon = Icons.Default.Favorite
            )
        }

        // ── Demo 4：固定容器空态 ──
        Text("Demo 4 · 固定容器空态", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
                .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
        ) {
            EmptyStateView(
                message = "该文件夹为空",
                icon = Icons.Default.Favorite,
                iconSize = 40
            )
        }
    }
}

// ===== Avatar 组件 Demo 页（独立页面，与 iOS AvatarShowcase 一一对应） =====

@Composable
private fun AvatarDemo() {
    // 版本徽标
    Text(
        text = "Avatar 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )

    Text(
        text = "4 组排查：① 文字头像 ② 星座符号头像 ③ 尺寸对比 ④ 头像组合。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    // ⚠️ AvatarDemo 里 remember 的泛型列表必须显式标注类型（真 build 第 31-40 条实锤=Cannot infer T/V + iterator ambiguous + take overload ambiguity）
    // Kotlin remember + listOf() 的组合=当 listOf 元素里包含 null（Pair 首元素 null）或多种推断候选时=编译器推断不出 T=必须显式写 List<Type>
    val mockSigns: List<AvatarOption> = remember {
        listOf(
            AvatarOption("白羊座", "♈", 0xDC2626),
            AvatarOption("金牛座", "♉", 0x16A34A),
            AvatarOption("双子座", "♊", 0x2563EB),
            AvatarOption("巨蟹座", "♋", 0x7C3AED),
            AvatarOption("狮子座", "♌", 0xEA580C),
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：文字头像 ──
        Text("Demo 1 · 文字头像", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(
            horizontalArrangement = Arrangement.spacedBy(AppSpace.lg),
            modifier = Modifier.fillMaxWidth().padding(vertical = AppSpace.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            for (name in listOf("张三", "李四", "王五", "赵六")) {
                ZodiacAvatar(option = null, nickname = name, size = 56.dp)
            }
        }

        // ── Demo 2：星座符号头像 ──
        Text("Demo 2 · 星座符号头像", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(
            horizontalArrangement = Arrangement.spacedBy(AppSpace.lg),
            modifier = Modifier.fillMaxWidth().padding(vertical = AppSpace.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            for (sign in mockSigns.take(4)) {
                ZodiacAvatar(option = sign, nickname = sign.name, size = 56.dp)
            }
        }

        // ── Demo 3：尺寸对比 ──
        Text("Demo 3 · 尺寸对比", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(
            horizontalArrangement = Arrangement.spacedBy(AppSpace.xl),
            modifier = Modifier.fillMaxWidth().padding(vertical = AppSpace.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            ZodiacAvatar(option = mockSigns[4], nickname = "Leo", size = 40.dp)
            ZodiacAvatar(option = mockSigns[4], nickname = "Leo", size = 56.dp)
            ZodiacAvatar(option = mockSigns[4], nickname = "Leo", size = 72.dp)
        }

        // ── Demo 4：头像组合 ──
        Text("Demo 4 · 头像组合", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Column(
            modifier = Modifier.fillMaxWidth().padding(vertical = AppSpace.md),
            verticalArrangement = Arrangement.spacedBy(AppSpace.md)
        ) {
            // ⚠️ users 列表里有 (null to "王五")=Pair 首元素是 AvatarOption?=必须显式标注类型 List<Pair<AvatarOption?, String>>
            // 否则 Kotlin 编译器在 for ((sign,name) in users) 解构时=泛型参数 V 推断不出=报 Cannot infer type for V（真 build 990/993 实锤）
            val users: List<Pair<AvatarOption?, String>> = listOf(
                mockSigns[0] to "白羊",
                mockSigns[1] to "金牛",
                null to "王五",
                mockSigns[2] to "双子",
            )
            for ((sign, name) in users) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(AppSpace.md),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    ZodiacAvatar(option = sign, nickname = name, size = 44.dp)
                    Text(text = name, color = AppColor.textPrimary, fontSize = AppFont.sizeMd)
                }
            }
        }
    }
}

// ===== List 组件 Demo 页（独立页面，与 iOS ListShowcase 一一对应） =====

@Composable
private fun ListDemo() {
    Text(
        text = "List 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )

    Text(
        text = "4 组排查：① 基础行 ② 带值行 ③ 可点击行 ④ 多分组。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：基础列表行 ──
        Text("Demo 1 · 基础列表行", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        ProfileListGroup(
            items = listOf(
                ProfileListItem("设置"),
                ProfileListItem("通用"),
                ProfileListItem("关于"),
            )
        )

        // ── Demo 2：带值列表行 ──
        Text("Demo 2 · 带值列表行", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        ProfileListGroup(
            items = listOf(
                ProfileListItem("版本", value = "v1.3.5"),
                ProfileListItem("设备", value = "iPhone 15 Pro"),
                ProfileListItem("存储", value = "128 GB"),
            )
        )

        // ── Demo 3：可点击列表行 ──
        Text("Demo 3 · 可点击列表行", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        ProfileListGroup(
            items = listOf(
                ProfileListItem("账号管理", value = "已绑定", onClick = {}),
                ProfileListItem("消息通知", value = "已开启", onClick = {}),
                ProfileListItem("隐私设置", onClick = {}),
            )
        )

        // ── Demo 4：多分组列表 ──
        Text("Demo 4 · 多分组列表", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        ProfileListGroup(
            items = listOf(
                ProfileListItem("个人资料", value = "已完善", onClick = {}),
                ProfileListItem("账号安全", onClick = {}),
            )
        )
        ProfileListGroup(
            items = listOf(
                ProfileListItem("清除缓存", value = "23.5 MB", onClick = {}),
                ProfileListItem("检查更新", value = "最新版", onClick = {}),
                ProfileListItem("退出登录", onClick = {}),
            )
        )
    }
}

// ===== Grid 组件 Demo 页（独立页面，与 iOS GridShowcase 一一对应） =====

@Composable
private fun GridDemo() {
    Text(
        text = "Grid 组件 v2.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )

    Text(
        text = "4 组排查：① 基础四宫格 ② 带标题分区 ③ 可点击交互 ④ 多分组网格。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：基础四宫格 ──
        Text("Demo 1 · 基础四宫格", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Grid(
            title = "",
            items = listOf(
                GridItem("列表", AppIconName.List),
                GridItem("图表", AppIconName.Chart),
                GridItem("加号", AppIconName.Plus),
                GridItem("人物", AppIconName.Person),
            )
        )

        // ── Demo 2：带标题分区 ──
        Text("Demo 2 · 带标题分区", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Grid(
            title = "小工具",
            items = listOf(
                GridItem("浏览器", AppIconName.Safari),
                GridItem("手机", AppIconName.Smartphone),
                GridItem("邮箱", AppIconName.Mail),
                GridItem("下拉", AppIconName.ArrowDown),
            )
        )

        // ── Demo 3：可点击交互 ──
        Text("Demo 3 · 可点击交互", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Grid(
            title = "快捷入口",
            items = listOf(
                GridItem("列表", AppIconName.List),
                GridItem("图表", AppIconName.Chart),
                GridItem("人物", AppIconName.Person),
                GridItem("邮箱", AppIconName.Mail),
            ),
            onSelect = { index ->
                println("Grid Demo3 tapped: $index")
            }
        )

        // ── Demo 4：多分组网格 ──
        Text("Demo 4 · 多分组网格", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Grid(
            title = "常用功能",
            items = listOf(
                GridItem("列表", AppIconName.List),
                GridItem("图表", AppIconName.Chart),
                GridItem("加号", AppIconName.Plus),
                GridItem("人物", AppIconName.Person),
            )
        )
        Grid(
            title = "小工具",
            items = listOf(
                GridItem("浏览器", AppIconName.Safari),
                GridItem("手机", AppIconName.Smartphone),
                GridItem("邮箱", AppIconName.Mail),
                GridItem("下拉", AppIconName.ArrowDown),
            )
        )
    }
}

// ===== Layout 布局组件 Demo 页（独立页面，与 iOS LayoutShowcase 一一对应） =====

@Composable
private fun LayoutDemo() {
    Text(
        text = "Layout 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 组排查：① 双栏统计卡片 ② 详情 label-value 行 ③ 筛选/工具行 ④ 嵌套组合。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：双栏统计卡片（span 6+6）──
        Text("Demo 1 · 双栏统计卡片", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        LayoutRow {
            LayoutCol(span = 6) {
                DemoStatCard(amount = "+¥12,680", amountColor = AppColor.income, label = "本月收入")
            }
            LayoutCol(span = 6) {
                DemoStatCard(amount = "−¥8,340", amountColor = AppColor.expense, label = "本月支出")
            }
        }

        // ── Demo 2：详情 label-value 行（span 4+8）──
        Text("Demo 2 · 详情 label-value 行", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            DemoKVRow(key = "分类", value = "餐饮 · 工作日午餐")
            DemoKVRow(key = "账户", value = "招商银行(4609)")
            DemoKVRow(key = "备注", value = "—")
        }

        // ── Demo 3：筛选/工具行（span 4+4+4）──
        Text("Demo 3 · 筛选/工具行", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        LayoutRow {
            LayoutCol(span = 4) { DemoPill(title = "周") }
            LayoutCol(span = 4) { DemoPill(title = "月") }
            LayoutCol(span = 4) { DemoPill(title = "年") }
        }

        // ── Demo 4：嵌套与组合（Row 内嵌 Row）──
        Text("Demo 4 · 嵌套与组合", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        LayoutRow {
            LayoutCol(span = 6) {
                DemoKVCard(title = "今日账单", rows = listOf("支出" to "¥260.00", "笔数" to "6 笔"))
            }
            LayoutCol(span = 6) {
                DemoKVCard(title = "本月小计", rows = listOf("支出" to "¥1,240.00", "收入" to "¥2,800.00"))
            }
        }
    }
}

@Composable
private fun DemoStatCard(amount: String, amountColor: Color, label: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.lg))
            .padding(AppSpace.lg)
    ) {
        Text(amount, fontSize = AppFont.sizeLg, fontWeight = FontWeight.SemiBold, color = amountColor)
        Spacer(modifier = Modifier.height(AppSpace.xs))
        Text(label, fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

@Composable
private fun DemoKVCard(title: String, rows: List<Pair<String, String>>) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.lg))
            .padding(AppSpace.lg),
        verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
    ) {
        Text(title, fontSize = AppFont.sizeSm, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        rows.forEach { (key, value) ->
            LayoutRow {
                LayoutCol(span = 4) {
                    Text(key, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                }
                LayoutCol(span = 8) {
                    Text(value, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
                }
            }
        }
    }
}

@Composable
private fun DemoKVRow(key: String, value: String) {
    LayoutRow {
        LayoutCol(span = 4) {
            Text(key, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
        }
        LayoutCol(span = 8) {
            Text(value, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
        }
    }
}

@Composable
private fun DemoPill(title: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(32.dp)
            .background(AppColor.primaryMuted, RoundedCornerShape(16.dp)),
        contentAlignment = Alignment.Center
    ) {
        Text(title, fontSize = AppFont.sizeSm, color = AppColor.primaryPressed)
    }
}

// ===== Space 间距组件 Demo 页（独立页面，与 iOS SpaceShowcase 一一对应） =====

@Composable
private fun SpaceDemo() {
    Text(
        text = "Space 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "5 段排查：① icon+文字 工具组(sm) ② chip 标签组(sm) ③ 区块间隔双卡(xl) ④ 垂直详情行(md) ⑤ 方向对照+嵌套。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：水平 icon+文字 工具组（size=sm 8）──
        Text("Demo 1 · icon+文字 工具组（sm=8）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Space(direction = SpaceDirection.Horizontal, size = AppSpace.sm) {
            SpaceDemoToolItem(text = "记一笔", iconTint = AppColor.primary)
            SpaceDemoToolItem(text = "扫一扫", iconTint = AppColor.primaryPressed)
            SpaceDemoToolItem(text = "账单", iconTint = AppColor.textSecondary)
            SpaceDemoToolItem(text = "设置", iconTint = AppColor.primary)
        }

        // ── Demo 2：chip 标签组（size=sm 8）──
        Text("Demo 2 · chip 标签组（sm=8）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Space(direction = SpaceDirection.Horizontal, size = AppSpace.sm) {
            listOf("全部", "餐饮", "交通", "购物", "其他").forEach { SpaceDemoPill(title = it) }
        }

        // ── Demo 3：区块间隔双卡（horizontal size=xl 24）──
        Text("Demo 3 · 区块间隔双卡（xl=24）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Space(direction = SpaceDirection.Horizontal, size = AppSpace.xl) {
            SpaceDemoBadgeCard(label = "本月收入", value = "¥12,680", valueColor = AppColor.income)
            SpaceDemoBadgeCard(label = "本月支出", value = "¥8,340", valueColor = AppColor.expense)
        }

        // ── Demo 4：垂直详情行（vertical size=md 12）──
        Text("Demo 4 · 垂直详情行（md=12）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Space(direction = SpaceDirection.Vertical, size = AppSpace.md) {
            SpaceDemoKVLine(key = "分类", value = "餐饮 · 工作日午餐")
            SpaceDemoKVLine(key = "账户", value = "招商银行(4609)")
            SpaceDemoKVLine(key = "时间", value = "2026-09-04 12:30")
            SpaceDemoKVLine(key = "备注", value = "—")
        }

        // ── Demo 5：方向对照 + 嵌套（同内容 h/v 对照；Space 子项可为任意内容）──
        Text("Demo 5 · 方向对照与嵌套", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Space(direction = SpaceDirection.Vertical, size = AppSpace.lg) {
            Space(direction = SpaceDirection.Horizontal, size = AppSpace.sm) {
                listOf("本周支出 ¥1,260", "笔数 18", "最大单笔 ¥320").forEach { SpaceDemoPill(title = it) }
            }
            Space(direction = SpaceDirection.Vertical, size = AppSpace.md) {
                SpaceDemoKVLine(key = "本周支出", value = "¥1,260")
                SpaceDemoKVLine(key = "笔数", value = "18")
                SpaceDemoKVLine(key = "最大单笔", value = "¥320")
            }
            Space(direction = SpaceDirection.Vertical, size = AppSpace.md) {
                SpaceDemoBadgeCard(label = "本月小计", value = "支出 ¥8,340 · 收入 ¥12,680", valueColor = AppColor.textPrimary)
                SpaceDemoToolItem(text = "查看账单明细", iconTint = AppColor.primary)
            }
        }
    }
}

@Composable
private fun SpaceDemoToolItem(text: String, iconTint: Color) {
    Row(
        modifier = Modifier
            .height(36.dp)
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.md))
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
            .padding(horizontal = AppSpace.md),
        horizontalArrangement = Arrangement.spacedBy(AppSpace.xs + 2.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(14.dp)
                .background(iconTint, RoundedCornerShape(4.dp))
        )
        Text(text, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
    }
}

@Composable
private fun SpaceDemoPill(title: String) {
    Box(
        modifier = Modifier
            .height(28.dp)
            .background(AppColor.primaryMuted, RoundedCornerShape(14.dp))
            .padding(horizontal = AppSpace.md),
        contentAlignment = Alignment.Center
    ) {
        Text(title, fontSize = AppFont.sizeXs, color = AppColor.primaryPressed)
    }
}

@Composable
private fun SpaceDemoBadgeCard(label: String, value: String, valueColor: Color) {
    Column(
        modifier = Modifier
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.lg))
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.xs)
    ) {
        Text(label, fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
        Text(value, fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = valueColor)
    }
}

@Composable
private fun SpaceDemoKVLine(key: String, value: String) {
    Space(direction = SpaceDirection.Horizontal, size = AppSpace.sm) {
        Text(key, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
        Text(value, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
    }
}

// ===== Card 组件 Demo 页（独立页面，与 iOS CardShowcase 一一对应） =====

@Composable
private fun CardDemo() {
    Text(
        text = "Card 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )

    Text(
        text = "4 组排查：① 基础摘要卡 ② 带颜色数值 ③ 无辅助文案 ④ 可点击卡片。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：基础摘要卡 ──
        Text("Demo 1 · 基础摘要卡", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        SummaryCardView(
            title = "本月支出",
            subtitle = "2026 年 9 月 · 餐饮 + 交通 + 购物",
            value = "¥ 3,280.50",
            valueColor = AppColor.textPrimary,
            accessory = "较上月 +5.2%"
        )

        // ── Demo 2：带颜色数值 ──
        Text("Demo 2 · 带颜色数值", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        SummaryCardView(
            title = "本月收入",
            subtitle = "工资 + 理财收益",
            value = "¥ 8,500.00",
            valueColor = Color(0xFF34C759),
            accessory = "较上月 +12.8%"
        )

        // ── Demo 3：无辅助文案 ──
        Text("Demo 3 · 无辅助文案", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        SummaryCardView(
            title = "账户余额",
            subtitle = "可用余额 · 含储蓄卡 + 信用卡",
            value = "¥ 15,420.30",
            valueColor = AppColor.primary,
            accessory = null
        )

        // ── Demo 4：可点击卡片 ──
        Text("Demo 4 · 可点击卡片", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        SummaryCardView(
            title = "预算管理",
            subtitle = "本月预算 ¥ 5,000 · 已用 65.6%",
            value = "¥ 3,280.50",
            valueColor = Color(0xFFFF9500),
            accessory = "查看详情",
            onClick = {
                println("Card Demo4 tapped")
            }
        )
    }
}

// ===== LineChart 组件 Demo 页（独立页面，与 iOS LineChartShowcase 一一对应） =====

@Composable
private fun LineChartDemo() {
    Text(
        text = "LineChart 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )

    Text(
        text = "4 组排查：① 基础双折线 ② 仅支出 ③ 仅收入 ④ 空态。双端 1:1 对齐。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：基础双折线 ──
        Text("Demo 1 · 基础双折线", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        TrendChartView(
            expensePoints = listOf(
                ChartPoint("4月", 1200.0),
                ChartPoint("5月", 1800.0),
                ChartPoint("6月", 1500.0),
                ChartPoint("7月", 2200.0),
                ChartPoint("8月", 1900.0),
                ChartPoint("9月", 2500.0),
            ),
            incomePoints = listOf(
                ChartPoint("4月", 3000.0),
                ChartPoint("5月", 3500.0),
                ChartPoint("6月", 3200.0),
                ChartPoint("7月", 4000.0),
                ChartPoint("8月", 3800.0),
                ChartPoint("9月", 4500.0),
            )
        )

        // ── Demo 2：仅支出 ──
        Text("Demo 2 · 仅支出", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        TrendChartView(
            expensePoints = listOf(
                ChartPoint("周一", 200.0),
                ChartPoint("周二", 350.0),
                ChartPoint("周三", 180.0),
                ChartPoint("周四", 420.0),
                ChartPoint("周五", 380.0),
                ChartPoint("周六", 500.0),
                ChartPoint("周日", 280.0),
            ),
            incomePoints = emptyList()
        )

        // ── Demo 3：仅收入 ──
        Text("Demo 3 · 仅收入", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        TrendChartView(
            expensePoints = emptyList(),
            incomePoints = listOf(
                ChartPoint("Q1", 8000.0),
                ChartPoint("Q2", 9500.0),
                ChartPoint("Q3", 7200.0),
                ChartPoint("Q4", 11000.0),
            )
        )

        // ── Demo 4：空态 ──
        Text("Demo 4 · 空态", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        TrendChartView(
            expensePoints = emptyList(),
            incomePoints = emptyList()
        )
    }
}

// ===== OverlayDemo（基础组件 #6，与 OverlayShowcase 1:1 对齐）=====

@Composable
private fun OverlayDemo() {
    // 组件版本 v2.0（iOS 布局完整修复），组件库版本 v1.3.13
    Text(
        text = "Overlay v2.0 (lib v1.3.13)",
        fontSize = AppFont.sizeSm,
        color = Color.White,
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFF111827))
            .padding(horizontal = 12.dp, vertical = 6.dp)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        Text(
            text = "定位：浮层通用基座。4 组排查：① 默认遮罩+居中确认框；② 透明穿透+新手气泡 top-right；③ 底部抽屉（contentPosition=bottom + radius=lg 顶两圆角）；④ 圆角卡片居中。双端 1:1，点击下方按钮触发对应 Demo。",
            fontSize = AppFont.sizeSm, color = AppColor.textSecondary
        )

        // 反馈栏（对应 iOS addFeedbackBar）
        var feedback by remember { mutableStateOf("点击下方按钮触发 Demo，这里会显示 onMaskClick / onClose 回调顺序。") }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFFF0FDF4), RoundedCornerShape(8.dp))
                .clip(RoundedCornerShape(8.dp))
                .padding(12.dp)
        ) {
            Text(feedback, fontSize = AppFont.sizeSm, color = Color(0xFF065F46))
        }

        // Demo 1：默认遮罩+居中确认框
        var d1Visible by remember { mutableStateOf(false) }
        DemoSection(title = "Demo 1 · 默认遮罩 + 居中确认框") {
            AppButton(text = "打开确认退出弹窗", style = AppButtonStyle.Primary, onClick = { d1Visible = true })
        }
        Text("maskColor=default（55% 黑）；closeOnMaskClick=默认 true；contentPosition=center；点击外部→onMaskClick→onClose。", fontSize = AppFont.sizeSm, color = AppColor.textSecondary)

        // Demo 2：透明穿透 + 新手气泡
        var d2Visible by remember { mutableStateOf(false) }
        DemoSection(title = "Demo 2 · 透明穿透 + 新手气泡（top-right）") {
            AppButton(text = "显示气泡蒙版 3 秒", style = AppButtonStyle.Primary, onClick = { d2Visible = true })
        }
        Text("maskColor=transparent + clickThrough=true（Dialog 独占 window 的限制：近似=背景透明 + 不挂遮罩点击，事件穿透取决于宿主；气泡本身仍可点击）；contentPosition=top-right；offset y=状态栏+44dp。", fontSize = AppFont.sizeSm, color = AppColor.textSecondary)

        // Demo 3：底部抽屉（顶两圆角）
        var d3Visible by remember { mutableStateOf(false) }
        DemoSection(title = "Demo 3 · 底部抽屉（顶两圆角 radius=lg）") {
            AppButton(text = "打开日期范围选择器", style = AppButtonStyle.Primary, onClick = { d3Visible = true })
        }
        Text("contentPosition=bottom + contentRadius=lg → 底两角=0（贴边自动保留直角）；点击遮罩空白区 = 触发 onMaskClick + onClose。", fontSize = AppFont.sizeSm, color = AppColor.textSecondary)

        // Demo 4：圆角卡片居中（4 圆角）
        var d4Visible by remember { mutableStateOf(false) }
        DemoSection(title = "Demo 4 · 圆角卡片居中（4 圆角 radius=lg）") {
            AppButton(text = "显示已保存 3 条记账", style = AppButtonStyle.Primary, onClick = { d4Visible = true })
        }
        Text("contentPosition=center + contentRadius=lg；4 角全 14dp；animation=默认 true（fade in/out）。", fontSize = AppFont.sizeSm, color = AppColor.textSecondary)

        Spacer(Modifier.height(24.dp))

        // ⚠️ 永久钉死=下面 4 个 Overlay() 实例声明=必须放在本 Column { } 闭包的**内部**（不能写在 Column 结束大括号之后=真 build 35 条 d1Visible/d4Visible/feedback Unresolved=跨作用域根因）
        // 因为 L1349/L1361-L1380 用 remember { mutableStateOf } 声明的 feedback + d1~d4Visible=作用域是 Column content lambda（remember {} 仅在当前 Composable 子树作用域可见）
        // —— 下面 4 个 Overlay 和 feedback/Visible 同作用域=才能读写 state ——

        // ──── Overlay 实例声明（4 个）────
        Overlay(
            visible = d1Visible,
            contentRadius = "lg",
            onClose = { d1Visible = false; feedback = "[Demo1] onClose 触发 → 已关闭" },
            onMaskClick = { feedback = "[Demo1] onMaskClick → onClose 将紧随其后" }
        ) {
            Surface(
                color = Color.White,
                shape = RoundedCornerShape(14.dp),
                modifier = Modifier.width(280.dp)
            ) {
                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Text("确认退出？", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = Color(0xFF111827))
                    Text("退出后当前编辑内容不会自动保存", fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        TextButton(onClick = { d1Visible = false }, modifier = Modifier.weight(1f)) { Text("取消", color = Color(0xFF111827)) }
                        AppButton(text = "确定", style = AppButtonStyle.Primary, onClick = {
                            d1Visible = false
                            feedback = "[Demo1] 确定点击 → 手动 visible=false 关（不重复触发 onClose）"
                        }, modifier = Modifier.weight(1f))
                    }
                }
            }
        }

        Overlay(
            visible = d2Visible,
            maskColor = "transparent",
            closeOnMaskClick = false,
            clickThrough = true,
            contentPosition = "top-right",
            contentOffsetY = 88,
            contentOffsetX = -12,
            contentRadius = "md",
            onClose = { d2Visible = false },
            onMaskClick = { /* clickThrough=true 近似：忽略 */ }
        ) {
            Box(
                modifier = Modifier
                    .width(200.dp)
                    // ⚠️ 永久钉死=**绝不使用 Modifier.clip(shape) 扩展来做形状裁切**（用户 gradle 真 build 连续 5 条实锤=Unresolved reference clip×N 连炸=与 Overlay.kt L321-L324 永久禁令完全对齐）
                    // Compose Modifier.background 的 shape 参数=除了画背景色=还会自动把后面内容按 shape 裁切=效果与 iOS clipsToBounds 完全等价=0 新 import=绝对稳=所以这里直接 background(color, shape) 一次搞定=不需要再单独 .clip()
                    .background(Color(0xFF16A34A), RoundedCornerShape(10.dp))
                    .clickable {
                        d2Visible = false
                        feedback = "[Demo2] 气泡点击 → 立即关闭"
                    }
                    .padding(12.dp)
            ) {
                Text("🎉 新手引导：点击「+」可快速记账哦～", color = Color.White, fontSize = AppFont.sizeSm)
            }
            // 3 秒自动关闭
            if (d2Visible) {
                LaunchedEffect(Unit) {
                    feedback = "[Demo2] 已显示气泡 3 秒：遮罩透明+近似穿透；3s 后自动关闭（或点击气泡立即关）"
                    kotlinx.coroutines.delay(3000)
                    d2Visible = false
                }
            }
        }

        Overlay(
            visible = d3Visible,
            contentPosition = "bottom",
            contentRadius = "lg",
            onClose = { d3Visible = false; feedback = "[Demo3] onClose 触发 → 已关闭" },
            onMaskClick = { feedback = "[Demo3] onMaskClick → 关闭" }
        ) {
            Surface(color = Color.White, shape = RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp)) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(start = 16.dp, end = 16.dp, top = 10.dp, bottom = 24.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // 把手
                    Spacer(
                        Modifier
                            .height(4.dp)
                            .width(40.dp)
                            .background(Color(0xFFE5E7EB), RoundedCornerShape(2.dp))
                            .align(Alignment.CenterHorizontally)
                    )
                    Text("选择日期范围", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = Color(0xFF111827))
                    Text("本周 / 本月 / 自定义…", fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                    BottomSheetRow(title = "本周") { d3Visible = false; feedback = "[Demo3] 选择「本周」" }
                    BottomSheetRow(title = "本月") { d3Visible = false; feedback = "[Demo3] 选择「本月」" }
                    BottomSheetRow(title = "自定义…") { d3Visible = false; feedback = "[Demo3] 选择「自定义…」" }
                }
            }
        }

        Overlay(
            visible = d4Visible,
            contentRadius = "lg",
            onClose = { d4Visible = false },
            onMaskClick = { feedback = "[Demo4] onMaskClick → onClose 将紧随其后" }
        ) {
            Surface(color = Color.White, shape = RoundedCornerShape(14.dp), modifier = Modifier.width(260.dp)) {
                Column(
                    modifier = Modifier.padding(top = 24.dp, start = 20.dp, end = 20.dp, bottom = 20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text("💸", fontSize = AppFont.sizeXl)
                    Text("已保存 3 条记账", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = Color(0xFF111827), textAlign = TextAlign.Center)
                    Text("总支出 ¥ 328.00", fontSize = AppFont.sizeSm, color = AppColor.textSecondary, textAlign = TextAlign.Center)
                    AppButton(text = "好的", style = AppButtonStyle.Primary, onClick = {
                        d4Visible = false
                    }, modifier = Modifier.fillMaxWidth())
                }
            }
            if (d4Visible) {
                LaunchedEffect(Unit) {
                    feedback = "[Demo4] 已保存 3 条记账（center + 4 圆角 radius=lg）：fade-in 动画 200ms"
                }
            }
        }
    } // —— Column { } 结束大括号=**必须在这里才闭合**（把 4 个 Overlay 实例全部包进 Column 作用域=与 remember 的 5 个 state 同作用域=解决 35 条 Unresolved）
}

@Composable
private fun DemoSection(title: String, content: @Composable () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
        Text(title, fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = Color(0xFF111827))
        content()
    }
}

@Composable
private fun BottomSheetRow(title: String, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(44.dp)
            .clickable { onClick() },
        contentAlignment = Alignment.CenterStart
    ) {
        Text(title, fontSize = AppFont.sizeMd, color = Color(0xFF111827))
    }
}

// ── Divider 分割线 Demo ──

@Composable
private fun DividerDemo() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：基础分割线 ──
        DemoSection(title = "Demo 1 · 基础分割线") {
            ContentBlock("上方内容")
            Divider()
            ContentBlock("下方内容")
        }
        Text(
            text = "默认 hairline（0.5dp 细线），实线，无文本。",
            fontSize = AppFont.sizeXs,
            color = AppColor.textSecondary
        )

        // ── Demo 2：虚线 + 粗线 ──
        DemoSection(title = "Demo 2 · 虚线 + 粗线") {
            Text("虚线（dashed=true）", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
            Spacer(modifier = Modifier.height(4.dp))
            Divider(dashed = true)
            Spacer(modifier = Modifier.height(12.dp))
            Text("粗线（hairline=false）", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
            Spacer(modifier = Modifier.height(4.dp))
            Divider(hairline = false)
        }
        Text(
            text = "上：虚线（dashed=true）。下：粗线（hairline=false，1dp）。",
            fontSize = AppFont.sizeXs,
            color = AppColor.textSecondary
        )

        // ── Demo 3：带文本分割线 ──
        DemoSection(title = "Demo 3 · 带文本分割线") {
            Divider(text = "左侧文本", contentPosition = DividerContentPosition.Left)
            Spacer(modifier = Modifier.height(12.dp))
            Divider(text = "居中", contentPosition = DividerContentPosition.Center)
            Spacer(modifier = Modifier.height(12.dp))
            Divider(text = "右侧", contentPosition = DividerContentPosition.Right)
        }
        Text(
            text = "上→下：contentPosition = left / center / right。",
            fontSize = AppFont.sizeXs,
            color = AppColor.textSecondary
        )

        // ── Demo 4：垂直分割线 ──
        DemoSection(title = "Demo 4 · 垂直分割线") {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(40.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("操作A", fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
                Divider(
                    direction = DividerDirection.Vertical,
                    modifier = Modifier.height(20.dp)
                )
                Text("操作B", fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
                Divider(
                    direction = DividerDirection.Vertical,
                    modifier = Modifier.height(20.dp)
                )
                Text("操作C", fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
            }
        }
        Text(
            text = "行内垂直分隔，用于文字/按钮之间。",
            fontSize = AppFont.sizeXs,
            color = AppColor.textSecondary
        )
    }
}

@Composable
private fun ContentBlock(text: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColor.gray4, RoundedCornerShape(6.dp))
            .padding(vertical = 8.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(text = text, fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

// ===== SafeArea 安全区 Demo 页（与 iOS SafeAreaShowcase 一一对应，布局组件） =====

@Composable
private fun SafeAreaDemo() {
    Text(
        text = "SafeArea 组件 v1.0.3 · 2026-09-05 用户双端实机验收通过",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① SafeArea 真实组件(全边避让) ② 顶部避让语义对照 ③ 沉浸式四边避让 ④ edges 边裁剪。双端 1:1 对齐。页面中部运行时安全区=0，边缘接入自动生效。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        SafeAreaProbe()

        Text("Demo 1 · SafeArea 真实组件（默认全边避让）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.gray4)
                .padding(AppSpace.md)
                // demo 区中部模拟"普通页面内容区"：消费 safeDrawing 后此处安全区=0（v1.0.3 组件
                // 走 insets 传播链，消费对组件生效），与 iOS 中部容器（safeAreaLayoutGuide=0）语义 1:1
                .consumeWindowInsets(WindowInsets.safeDrawing)
        ) {
            SafeArea {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppColor.bgCard)
                        .padding(AppSpace.lg),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "内容在 SafeArea 容器内\n（四边自动贴系统安全区）",
                        fontSize = AppFont.sizeXs,
                        color = AppColor.textPrimary,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }

        Text("Demo 2 · 顶部避让语义对照（示意：模拟系统带）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        SafeAreaSimulatedBand()

        Text("Demo 3 · 沉浸式页面四边避让（示意）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        SafeAreaImmersionCard()

        Text("Demo 4 · edges 边裁剪（仅避顶 / 仅避底）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                // 消费 safeDrawing：本卡处于"普通页面中部"=0，与 iOS 中部容器 1:1；
                // 沉浸页接入后 edges 指定单边自动让出系统 inset
                .consumeWindowInsets(WindowInsets.safeDrawing),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.md)
        ) {
            SafeAreaEdgeCard(
                title = "仅避 top",
                detail = "顶部自绘背景出血、文字避让；底部内容贴边",
                edges = setOf(SafeAreaEdges.Top),
                modifier = Modifier.weight(1f)
            )
            SafeAreaEdgeCard(
                title = "仅避 bottom",
                detail = "底部自绘 tab 背景贴边，内容上移避开手势区",
                edges = setOf(SafeAreaEdges.Bottom),
                modifier = Modifier.weight(1f)
            )
        }
    }
}

/** SafeArea 色块调试探针（C1.5 差异排查临时段，闭环后整段移除）。 */
@Composable
private fun SafeAreaProbe() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(AppRadius.md))
            .background(Color(0xFFFFF3E0))
            .border(1.dp, Color(0xFFFB8C00), RoundedCornerShape(AppRadius.md))
            .padding(AppSpace.sm),
        verticalArrangement = Arrangement.spacedBy(AppSpace.xs)
    ) {
        Text(
            "诊断探针 v1.0.3 · 量 SafeArea 实际避让（白卡距色块顶，Logcat tag SafeAreaDbg）：详情页壳已 statusBarsPadding 消费顶部 → 红/绿 top 均应=0（同 iOS 中部容器 safeAreaLayoutGuide=0）。红=不额外 consume：底部 inset 未消费 → 组件加底部避让（红底可见）；绿=外层 consume(safeDrawing) 全边：四边剩余均 0（无避让红/绿边）→ 证明组件逐边感知祖先消费",
            color = Color(0xFFE65100),
            fontSize = AppFont.sizeXs,
            fontWeight = FontWeight.Bold
        )
        SafeAreaProbeBand("P0 不额外消费（红）", Color(0xFFEF9A9A), debugWrap = Modifier)
        SafeAreaProbeBand("P1 额外 consume 全边（绿）", Color(0xFFA5D6A7), debugWrap = Modifier.consumeWindowInsets(WindowInsets.safeDrawing))
    }
}

/** 探针色块：白卡相对色块顶的位置差 − 色块内边距(2dp) = SafeArea 组件实际顶部避让 px。 */
@Composable
private fun SafeAreaProbeBand(label: String, color: Color, debugWrap: Modifier) {
    val density = LocalDensity.current
    var bandTopY by remember { mutableStateOf(0f) }
    var contentTopY by remember { mutableStateOf(0f) }
    var bandHeightPx by remember { mutableStateOf(0) }
    var lastLoggedPadPx by remember { mutableStateOf(-1) }

    fun actualTopPadPx(): Int {
        val raw = (contentTopY - bandTopY) - with(density) { 2.dp.toPx() }
        return raw.roundToInt().coerceAtLeast(0)
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(AppRadius.sm))
            .background(color)
            .padding(2.dp)
            .then(debugWrap)
            .onSizeChanged { size -> bandHeightPx = size.height }
            .onGloballyPositioned { bandTopY = it.positionInRoot().y }
    ) {
        SafeArea {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(40.dp)
                    .background(Color.White)
                    .onGloballyPositioned { contentTopY = it.positionInRoot().y },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "$label · 实际避让 top ${(actualTopPadPx() / density.density).roundToInt()}dp",
                    fontSize = AppFont.sizeXs,
                    color = Color.Black,
                    textAlign = TextAlign.Center
                )
            }
        }
    }

    LaunchedEffect(bandTopY, contentTopY, bandHeightPx) {
        val padTopPx = actualTopPadPx()
        if (padTopPx != lastLoggedPadPx) {
            lastLoggedPadPx = padTopPx
            Log.d(
                "SafeAreaDbg",
                "$label => SafeArea 实际顶部避让=${padTopPx}px(${(padTopPx / density.density).roundToInt()}dp) 外层色块高=${bandHeightPx}px"
            )
        }
    }
}

/** Demo 2：顶部避让语义对照（模拟系统带 + 无避让/避让双卡）。 */
@Composable
private fun SafeAreaSimulatedBand() {
    Column(Modifier.fillMaxWidth()) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(28.dp)
                .background(AppColor.gray4),
            contentAlignment = Alignment.Center
        ) {
            Text("系统区（状态栏/刘海，示意）", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = AppSpace.sm)
                .clip(RoundedCornerShape(AppRadius.sm))
                .background(AppColor.expense.copy(alpha = 0.08f))
                .padding(AppSpace.md)
        ) {
            Text("✗ 无 SafeArea：内容紧贴系统区，刘海机型会压字", fontSize = AppFont.sizeXs, color = AppColor.textPrimary)
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = AppSpace.sm)
                .clip(RoundedCornerShape(AppRadius.sm))
                .background(AppColor.primaryMuted)
                .padding(AppSpace.md)
        ) {
            Text("✓ 内容在 SafeArea 内：从安全区下开始，不压系统区", fontSize = AppFont.sizeXs, color = AppColor.textPrimary)
        }
    }
}

/** Demo 3：沉浸式页面四边避让示意（深色 header 全屏出血 + SafeArea 内容层）。 */
@Composable
private fun SafeAreaImmersionCard() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(AppRadius.lg))
            .background(AppColor.bgCard)
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.lg))
            // 模拟沉浸页"页面中部内容层"：消费 safeDrawing 后此处 SafeArea=0（v1.0.3 组件
            // 走 insets 传播链，消费对组件生效），与 iOS 中部容器（safeAreaLayoutGuide=0）1:1
            .consumeWindowInsets(WindowInsets.safeDrawing)
    ) {
        // 内层两块各带独立圆角，与 iOS D3 同构（深绿 header lg、浅绿 body sm，均四角圆角）；
        // 不做仅靠外层卡片 clip 的裁剪（那样圆弧只落在整卡外沿，中间两角成直角）
        Column {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp)
                    .clip(RoundedCornerShape(AppRadius.lg))
                    .background(AppColor.primary),
                contentAlignment = Alignment.Center
            ) {
                Text("沉浸 header（全屏出血，颜色自绘到屏幕边缘）", fontSize = AppFont.sizeXs, color = Color.White, textAlign = TextAlign.Center)
            }
            SafeArea {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(AppRadius.sm))
                        .background(AppColor.primaryMuted)
                        .padding(AppSpace.lg)
                ) {
                    Text("页面内容在 SafeArea 内：避开刘海/Home Indicator/圆角后正常排版", fontSize = AppFont.sizeXs, color = AppColor.textPrimary)
                }
            }
        }
    }
}

/** Demo 4：edges 边裁剪卡片（SafeArea 真实组件 + edges 组合）。 */
@Composable
private fun SafeAreaEdgeCard(title: String, detail: String, edges: Set<SafeAreaEdges>, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(AppRadius.md))
            .background(AppColor.bgCard)
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
    ) {
        SafeArea(edges = edges, modifier = Modifier.fillMaxWidth()) {
            Column(Modifier.padding(AppSpace.md)) {
                Text(title, fontSize = AppFont.sizeXs, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
                Text(detail, fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
            }
        }
    }
}

// ===== Sticky 粘性布局 Demo 页（与 iOS StickyShowcase 一一对应，布局组件） =====

@Composable
private fun StickyDemo() {
    Text(
        text = "Sticky 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 分组列表标题吸顶 ② 筛选条吸顶 ③ offset 让位(固定 AppBar 下) ④ 吸顶行内容任意可交互。双端 1:1 对齐（Android LazyColumn 原生 stickyHeader）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        Text("Demo 1 · 分组列表标题吸顶（真实组件，多组标题依次顶替）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        LazyColumn(
            modifier = Modifier.fillMaxWidth().height(260.dp),
            verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            stickyHeaderItem(key = "today") { GroupBar("今天", "共 3 笔 · ¥126") }
            items(listOf("餐饮" to "-¥32", "交通" to "-¥18", "购物" to "-¥76")) { (c, a) -> BillRow(c, a) }
            stickyHeaderItem(key = "yesterday") { GroupBar("昨天", "共 2 笔 · ¥94") }
            items(listOf("餐饮" to "-¥58", "娱乐" to "-¥36")) { (c, a) -> BillRow(c, a) }
            stickyHeaderItem(key = "earlier") { GroupBar("本周更早", "共 5 笔 · ¥420") }
            items(listOf("房租" to "-¥300", "日用" to "-¥120")) { (c, a) -> BillRow(c, a) }
        }
        Text("滚动观察：「今天」吸顶 → 滚过「昨天」边界被顶替 → 「本周更早」再顶替；回滚依次恢复随流排布。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        Text("Demo 2 · 筛选条吸顶（内容行从吸顶条下方穿过）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        LazyColumn(
            modifier = Modifier.fillMaxWidth().height(240.dp),
            verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            stickyHeaderItem(key = "filter") { FilterBar() }
            items(
                listOf(
                    Triple("09-01", "餐饮", "-¥32"), Triple("09-02", "工资", "+¥12,000"),
                    Triple("09-03", "交通", "-¥18"), Triple("09-04", "购物", "-¥76"),
                    Triple("09-05", "娱乐", "-¥120"), Triple("09-06", "日用", "-¥45")
                )
            ) { (d, m, a) -> DateRow(d, m, a) }
        }
        Text("滚动观察：筛选条滚到容器顶即钉住，列表行从条下方穿过（遮挡区在条下，行为正确）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        Text("Demo 3 · offset 让位（吸顶条停固定 AppBar 下方，不遮挡）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Column(Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(34.dp)
                    .clip(RoundedCornerShape(AppRadius.sm))
                    .background(AppColor.gray4),
                contentAlignment = Alignment.Center
            ) {
                Text("固定 AppBar（高 34）", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
            }
            // 滚动区置于 AppBar 之下：吸顶钉线 = 滚动区顶部 = AppBar 下沿（offset 让位达成）
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = AppSpace.sm)
                    .height(196.dp),
                verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
            ) {
                stickyHeaderItem(key = "title") { GroupBar("吸顶标题", "offset 让位，停 AppBar 下方") }
                items(
                    listOf(
                        Triple("09-04", "餐饮", "-¥32"), Triple("09-04", "购物", "-¥76"),
                        Triple("09-03", "交通", "-¥18"), Triple("09-02", "娱乐", "-¥120")
                    )
                ) { (d, m, a) -> DateRow(d, m, a) }
            }
        }
        Text("滚动观察：吸顶标题停 AppBar 下方（AppBar 恒在、不遮挡）；Android offset 以容器排布表达（LazyColumn 置于 AppBar 下），与 iOS 一致。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        Text("Demo 4 · 吸顶行内容任意（icon+文字+右侧按钮，吸顶中可交互）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var exported by remember { mutableStateOf(false) }
        LazyColumn(
            modifier = Modifier.fillMaxWidth().height(260.dp),
            verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            stickyHeaderItem(key = "summary") {
                SummaryHeader(onExport = { exported = true })
            }
            items(
                listOf(
                    "收入" to "+¥18,240", "支出" to "-¥7,960", "结余" to "+¥10,280",
                    "笔数" to "共 26 笔", "餐饮占比" to "32%", "交通占比" to "18%"
                )
            ) { (c, a) -> BillRow(c, a) }
        }
        Text(
            text = if (exported) "已点击「导出」按钮（吸顶态下仍可交互）" else "滚动观察：汇总条（含可点按钮）吸顶后整行可见可点——Sticky 只是行为容器，内容任意编排。",
            fontSize = AppFont.sizeXs,
            color = if (exported) AppColor.primary else AppColor.textSecondary
        )
    }
}

/** 分组标题条（primaryMuted 底圆角色块）：标题左、计数右。 */
@Composable
private fun GroupBar(title: String, trailing: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(34.dp)
            .clip(RoundedCornerShape(AppRadius.sm))
            .background(AppColor.primaryMuted),
        contentAlignment = Alignment.CenterStart
    ) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.md),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(title, fontSize = AppFont.sizeSm, fontWeight = FontWeight.SemiBold, color = AppColor.primary)
            Text(trailing, fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
        }
    }
}

/** 筛选条（吸顶内容 = 文本筛选项行）。 */
@Composable
private fun FilterBar() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(34.dp)
            .clip(RoundedCornerShape(AppRadius.sm))
            .background(AppColor.primaryMuted),
        contentAlignment = Alignment.CenterStart
    ) {
        Text(
            text = "筛选：全部 ｜ 收入 ｜ 支出",
            fontSize = AppFont.sizeSm,
            fontWeight = FontWeight.Medium,
            color = AppColor.primaryPressed,
            modifier = Modifier.padding(start = AppSpace.md)
        )
    }
}

/** 白底圆角账目行：分类左、金额右。 */
@Composable
private fun BillRow(category: String, amount: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(40.dp)
            .clip(RoundedCornerShape(AppRadius.sm))
            .background(AppColor.bgCard)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.md),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(category, fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
            Text(amount, fontSize = AppFont.sizeXs, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        }
    }
}

/** 白底流水行：日期左、摘要中、金额右。 */
@Composable
private fun DateRow(date: String, desc: String, amount: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(40.dp)
            .clip(RoundedCornerShape(AppRadius.sm))
            .background(AppColor.bgCard)
    ) {
        Box(modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.md)) {
            Text(date, fontSize = AppFont.sizeXs, color = AppColor.textSecondary, modifier = Modifier.align(Alignment.CenterStart))
            Text(desc, fontSize = AppFont.sizeXs, color = AppColor.textPrimary, modifier = Modifier.align(Alignment.Center))
            Text(amount, fontSize = AppFont.sizeXs, fontWeight = FontWeight.Medium, color = AppColor.textPrimary, modifier = Modifier.align(Alignment.CenterEnd))
        }
    }
}

/** D4 汇总吸顶条：icon 容器(26dp 圆角 primary 白图标) + 标题 + 右侧「导出」胶囊按钮。 */
@Composable
private fun SummaryHeader(onExport: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(44.dp)
            .clip(RoundedCornerShape(AppRadius.sm))
            .background(AppColor.bgCard)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(26.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(AppColor.primary),
                contentAlignment = Alignment.Center
            ) {
                AppIcon(name = AppIconName.List, size = 16.dp, tint = Color.White)
            }
            Text(
                text = "本月账单汇总",
                fontSize = AppFont.sizeSm,
                fontWeight = FontWeight.SemiBold,
                color = AppColor.textPrimary,
                modifier = Modifier.padding(start = AppSpace.sm).weight(1f)
            )
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(50))
                    .background(AppColor.primary)
                    .clickable { onExport() }
                    .padding(horizontal = AppSpace.lg, vertical = 5.dp)
            ) {
                Text("导出", fontSize = AppFont.sizeXs, fontWeight = FontWeight.SemiBold, color = Color.White)
            }
        }
    }
}

// ===== BackTop 返回顶部 Demo 页（与 iOS BackTopShowcase 一一对应，导航组件） =====

@Composable
private fun BackTopDemo() {
    Text(
        text = "BackTop 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 默认样式（滚动超阈值出现 ↑ 圆钮，点击回顶）② 自定义内容（文字胶囊）③ 点击回调（不自动回顶）④ 位置宿主摆放 + 阈值可配。双端 1:1 对齐（iOS KVO contentOffset vs Android snapshotFlow scrollState）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // D1 · 默认样式：30 行长内容，滚动超阈值（120dp）右下淡入 ↑ 圆钮，点击回顶
        Text("Demo 1 · 默认样式（滚动超阈值 120dp 出现 ↑ 圆钮，点击回顶）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        val s1 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
        ) {
            BackTopContent(rows = 30, scrollState = s1)
            BackTop(
                scrollState = s1,
                appearAfterPx = BackTopThresholdPx(120),
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text("向下滚动列表，右下出现主色 ↑ 按钮；点击回到顶部后按钮淡出。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 自定义内容：文字胶囊"回顶"（内容替换，行为不变）
        Text("Demo 2 · 自定义内容（content 文字胶囊「回顶」，行为不变）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        val s2 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
        ) {
            BackTopContent(rows = 16, scrollState = s2)
            BackTop(
                scrollState = s2,
                appearAfterPx = BackTopThresholdPx(40),
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            ) {
                BackTopCapsuleFace()
            }
        }
        Text("content 整体替换默认 ↑ 圆钮为文字胶囊（点击行为保留：回顶）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 点击回调：记录次数不自动回顶
        Text("Demo 3 · 点击回调（接管回顶，记录点击次数）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var tapCount by remember { mutableStateOf(0) }
        val s3 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
        ) {
            BackTopContent(rows = 16, scrollState = s3)
            BackTop(
                scrollState = s3,
                appearAfterPx = BackTopThresholdPx(40),
                onClick = { tapCount++ },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = if (tapCount > 0) "BackTop 已点击 $tapCount 次（onTap 接管，未自动回顶）" else "传入 onClick 即接管默认回顶；点击后此处计数。",
            fontSize = AppFont.sizeXs,
            color = if (tapCount > 0) AppColor.primary else AppColor.textSecondary
        )

        // D4 · 位置宿主摆放（左下角）+ 阈值 40dp（滚动即现）
        Text("Demo 4 · 位置宿主摆放（左下）+ 阈值 40dp（滚动即现）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        val s4 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
        ) {
            BackTopContent(rows = 12, scrollState = s4)
            BackTop(
                scrollState = s4,
                appearAfterPx = BackTopThresholdPx(40),
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(start = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text("位置（右下/左下）是宿主责任，组件不代管布局上下文；阈值作为参数可配。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

/** FixedNavDemo：4 段排查（D1 右侧基本/D2 左侧 type=Left/D3 自定义文案长文本/D4 点面板外收起），与 iOS FixedNavShowcase 1:1。 */
@Composable
private fun FixedNavDemo() {
    Text(
        text = "FixedNav 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 右侧基本（角标+自动收起）② 左侧 type=Left ③ 自定义钮文案 / 无图标无角标长文本 ④ 多次开合 + 点面板外收起。双端 1:1（iOS FixedNavView vs Android FixedNav，展开态受控）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // D1 · 右侧默认：右下胶囊"快速导航"展开面板（首页 num2/订单/购物车 num5/我的），钮文字切"收起导航"；点项自动收起并回显
        Text("Demo 1 · 右侧默认（右下胶囊「快速导航」，面板含角标，点项自动收起）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1Expanded by remember { mutableStateOf(false) }
        var d1Picked by remember { mutableStateOf(false) }
        var d1Info by remember { mutableStateOf("点胶囊展开导航，点某项=选中回传并自动收起。") }
        val s1 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
        ) {
            BackTopContent(rows = 26, scrollState = s1)
            FixedNav(
                items = listOf(
                    FixedNavItem("home", "首页", icon = "⌂", num = 2),
                    FixedNavItem("order", "订单", icon = "📄"),
                    FixedNavItem("cart", "购物车", icon = "🛒", num = 5),
                    FixedNavItem("mine", "我的", icon = "◎"),
                ),
                expanded = d1Expanded,
                onExpandedChange = { d1Expanded = it },
                onSelect = {
                    d1Picked = true
                    d1Info = "D1 选中：${it.text}（key=${it.key}），面板已自动收起"
                },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = d1Info,
            fontSize = AppFont.sizeXs,
            color = if (d1Picked) AppColor.primary else AppColor.textSecondary
        )
        Text("右下角为悬浮钮（“悬浮”=宿主摆放=非滚动覆盖层右下角），面板随钮右缘向上弹出，内容可滚动不影响钮。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 左侧摆放（type=Left）
        Text("Demo 2 · 左侧摆放（type=Left，左下胶囊「更多工具」，面板向右展开）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2Expanded by remember { mutableStateOf(false) }
        var d2Picked by remember { mutableStateOf(false) }
        var d2Info by remember { mutableStateOf("胶囊在左下缘；点某项回传并自动收起。") }
        val s2 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(210.dp)
        ) {
            BackTopContent(rows = 22, scrollState = s2)
            FixedNav(
                items = listOf(
                    FixedNavItem("export", "导出报表", icon = "⤓"),
                    FixedNavItem("filter", "筛选视图", icon = "≋"),
                    FixedNavItem("share", "分享", icon = "↗"),
                ),
                type = FixedNavType.Left,
                unActiveText = "更多工具",
                expanded = d2Expanded,
                onExpandedChange = { d2Expanded = it },
                onSelect = {
                    d2Picked = true
                    d2Info = "D2 选中：${it.text}（type=Left），面板已自动收起"
                },
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(start = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = d2Info,
            fontSize = AppFont.sizeXs,
            color = if (d2Picked) AppColor.primary else AppColor.textSecondary
        )
        Text("type 只决定钮靠左/右缘与面板展开方向；钮由宿主锚左下/右下。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 无图标无角标：长文本项自适应宽 + 自定义钮文案（"操作"/"收起"）
        Text("Demo 3 · 无图标无角标（长文本行自适应宽 + 自定义钮文案「操作 / 收起」）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3Expanded by remember { mutableStateOf(false) }
        var d3Picked by remember { mutableStateOf(false) }
        var d3Info by remember { mutableStateOf("图标位缺省=不显示不占位；点项自动收起。") }
        val s3 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(190.dp)
        ) {
            BackTopContent(rows = 18, scrollState = s3)
            FixedNav(
                items = listOf(
                    FixedNavItem("month", "切换为月度视图"),
                    FixedNavItem("sync", "同步至工作台"),
                ),
                unActiveText = "操作",
                activeText = "收起",
                expanded = d3Expanded,
                onExpandedChange = { d3Expanded = it },
                onSelect = {
                    d3Picked = true
                    d3Info = "D3 选中：${it.text}，面板已自动收起"
                },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = d3Info,
            fontSize = AppFont.sizeXs,
            color = if (d3Picked) AppColor.primary else AppColor.textSecondary
        )
        Text("图标位/角标均为可选数据项；缺省时行不预留空位（行宽=文本+内边距）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 多次开合 + 点面板外收起：状态机稳定
        Text("Demo 4 · 多次开合 + 点面板外收起（状态稳定）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4Expanded by remember { mutableStateOf(false) }
        var d4Picked by remember { mutableStateOf(false) }
        var d4Info by remember { mutableStateOf("连续开合点选；点面板外空白处=收起且不触发选中。") }
        val s4 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
                .pointerInput(Unit) {
                    detectTapGestures {
                        // 面板外点击=收起（不触发选中）；行/钮内点击被子组件消费，不会走到这里
                        if (d4Expanded) {
                            d4Expanded = false
                            d4Picked = false
                            d4Info = "点击面板外区域 → 已收起（未触发选中）"
                        }
                    }
                }
        ) {
            BackTopContent(rows = 20, scrollState = s4)
            FixedNav(
                items = listOf(
                    FixedNavItem("home", "回首页", icon = "A"),
                    FixedNavItem("logout", "退出登录", icon = "B"),
                ),
                activeText = "收起",
                expanded = d4Expanded,
                onExpandedChange = { d4Expanded = it },
                onSelect = {
                    d4Picked = true
                    d4Info = "D4 选中：${it.text}（自动收起）"
                },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = d4Info,
            fontSize = AppFont.sizeXs,
            color = if (d4Picked) AppColor.primary else AppColor.textSecondary
        )
        Text("点钮多次开合稳定；面板/钮内命中由组件消费，点空白仅收起不选中。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

/** NavBarDemo：4 段排查（D1 基础返回 / D2 一级页无返回 / D3 右动作保存 / D4 长标题省略），与 iOS NavBarShowcase 1:1。 */
@Composable
private fun NavBarDemo() {
    Text(
        text = "NavBar 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 返回钮+标题 ② 一级页无返回（标题严格居中） ③ 右侧动作「保存」 ④ 长标题省略。双端 1:1（iOS NavBar vs Android NavBar）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        // D1 · 基础返回
        Text("Demo 1 · 返回钮 + 标题（点击返回计数）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1Back by remember { mutableStateOf(0) }
        NavBar(title = "账单明细", onBack = { d1Back++ })
        Text(
            text = if (d1Back > 0) "D1 返回点击：累计 $d1Back 次（返回槽出现在左侧，标题居中）" else "左侧返回钮热区 44×44dp，← 主色；点击计数。",
            fontSize = AppFont.sizeXs,
            color = if (d1Back > 0) AppColor.primary else AppColor.textSecondary
        )

        // D2 · 一级页无返回
        Text("Demo 2 · 一级页无返回（onBack=nil，标题严格居中）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        NavBar(title = "资产总览")
        Text("onBack=nil 返回槽不占位，标题严格水平居中（无左侧偏移）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 右动作保存
        Text("Demo 3 · 返回 + 右侧动作「保存」（点击计数）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3Back by remember { mutableStateOf(0) }
        var d3Save by remember { mutableStateOf(0) }
        NavBar(
            title = "编辑分类",
            onBack = { d3Back++ },
            rightAction = NavBarAction(text = "保存") { d3Save++ }
        )
        Text(
            text = when {
                d3Back > 0 || d3Save > 0 -> "D3 返回 $d3Back 次 / 保存 $d3Save 次"
                else -> "右侧动作 = NavBarAction(text, color?, onTap)，文字默认 textPrimary 14dp。"
            },
            fontSize = AppFont.sizeXs,
            color = if (d3Back > 0 || d3Save > 0) AppColor.primary else AppColor.textSecondary
        )

        // D4 · 长标题省略
        Text("Demo 4 · 长标题省略（返回+保存两侧夹挤）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4Back by remember { mutableStateOf(0) }
        var d4Save by remember { mutableStateOf(0) }
        NavBar(
            title = "这是一条特别特别长的标题用来验证单行省略的效果是否正确展示",
            onBack = { d4Back++ },
            rightAction = NavBarAction(text = "保存") { d4Save++ }
        )
        Text(
            text = "标题最多一行，超出以省略号结尾；返回/动作热区不被长标题侵入。D4 返回 $d4Back 次 / 保存 $d4Save 次。",
            fontSize = AppFont.sizeXs,
            color = AppColor.textSecondary
        )
    }
}

/** TabbarDemo：4 段排查（D1 基础 5 项 / D2 角标+禁用 / D3 纯文字+长标题+品牌红 / D4 受控外部驱动），与 iOS TabbarShowcase 1:1。 */
@Composable
private fun TabbarDemo() {
    Text(
        text = "Tabbar 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 基础 5 项等分 ② 角标数字+禁用 ③ 纯文字长标题+品牌红 activeColor ④ 受控外部驱动。双端 1:1（iOS TabbarView vs Android Tabbar）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        // D1 · 基础 5 项
        Text("Demo 1 · 基础 5 项等分（点击切换）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1 by remember { mutableStateOf("home") }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text("当前页面：${d1}（自管理选中）", color = AppColor.textSecondary, fontSize = AppFont.sizeXs)
            Tabbar(
                items = listOf(
                    TabBarItem("首页", "home", icon = "⌂"),
                    TabBarItem("明细", "list", icon = "▤"),
                    TabBarItem("记账", "add", icon = "✚"),
                    TabBarItem("报表", "chart", icon = "☰"),
                    TabBarItem("我的", "mine", icon = "☺"),
                ),
                selectedValue = d1,
                onChange = { d1 = it },
                modifier = Modifier.align(Alignment.BottomCenter),
            )
        }
        Text("icon 字符 22dp + 文字 12dp，等分 5 项；激活=主色加粗，默认首启用项自管理。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 角标 + 禁用
        Text("Demo 2 · 角标数字 + 禁用项", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2 by remember { mutableStateOf("home") }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text("当前：${d2}（消息角标 3，我的=禁用）", color = AppColor.textSecondary, fontSize = AppFont.sizeXs)
            Tabbar(
                items = listOf(
                    TabBarItem("首页", "home", icon = "⌂"),
                    TabBarItem("消息", "msg", icon = "✉", badge = 3),
                    TabBarItem("报表", "chart", icon = "☰"),
                    TabBarItem("我的", "mine", icon = "☺", disabled = true),
                ),
                selectedValue = d2,
                onChange = { if (it != "mine") d2 = it },
                modifier = Modifier.align(Alignment.BottomCenter),
            )
        }
        Text("角标=高 16dp 圆角主色白字数字（位于图标右上）；禁用项 40% 透明且不可点（点击不回调）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 纯文字 + 长标题省略 + 品牌红
        Text("Demo 3 · 纯文字 + 长标题省略 + 品牌红 activeColor", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3 by remember { mutableStateOf("a") }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text("当前：${d3}（品牌红激活色）", color = AppColor.textSecondary, fontSize = AppFont.sizeXs)
            Tabbar(
                items = listOf(
                    TabBarItem("全部账单明细全部明细", "a"),
                    TabBarItem("进行中", "b"),
                    TabBarItem("我的收藏夹", "c"),
                ),
                activeColor = Color(0xFFE11D48),
                selectedValue = d3,
                onChange = { d3 = it },
                modifier = Modifier.align(Alignment.BottomCenter),
            )
        }
        Text("icon 缺省=纯文字项；长标题单行省略；activeColor 覆盖默认主色（此处品牌红）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 受控外部驱动
        Text("Demo 4 · 受控外部驱动（selectedValue 由外部状态驱动）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4 by remember { mutableStateOf("chart") }
        var d4Tap by remember { mutableStateOf(0) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text("当前：${d4}（外部驱动，外部点击回调 $d4Tap 次）", color = AppColor.textSecondary, fontSize = AppFont.sizeXs)
            Tabbar(
                items = listOf(
                    TabBarItem("首页", "home", icon = "⌂"),
                    TabBarItem("报表", "chart", icon = "☰"),
                    TabBarItem("我的", "mine", icon = "☺"),
                ),
                selectedValue = d4,
                onChange = { d4 = it; d4Tap++ },
                modifier = Modifier.align(Alignment.BottomCenter),
            )
        }
        Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            TextButton(onClick = { d4 = "chart" }) { Text("外部切到「报表」", fontSize = AppFont.sizeXs) }
            TextButton(onClick = { d4 = "mine" }) { Text("外部切到「我的」", fontSize = AppFont.sizeXs) }
        }
        Text("半受控语义：外部 selectedValue 优先级高于自管理；点已激活项幂等（不重复回调）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

/** TabsDemo：4 段排查（D1 基础 / D2 禁用 / D3 长标题省略+品牌红 / D4 受控外部驱动），与 iOS TabsShowcase 1:1。 */
@Composable
private fun TabsDemo() {
    Text(
        text = "Tabs 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 基础等分+指示线 ② 禁用项 ③ 长标题省略+品牌红 activeColor ④ 受控外部驱动。双端 1:1（iOS TabsView vs Android Tabs）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        // D1 · 基础
        Text("Demo 1 · 基础等分 + 底部指示线", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1 by remember { mutableStateOf("in") }
        var d1Tap by remember { mutableStateOf(0) }
        Tabs(
            items = listOf(
                TabItem("支出", "in"),
                TabItem("收入", "out"),
                TabItem("转账", "transfer"),
            ),
            selectedValue = d1,
            onChange = { d1 = it; d1Tap++ },
        )
        Text(
            text = "当前页签：${d1}（点击回调 $d1Tap 次）",
            fontSize = AppFont.sizeXs,
            color = if (d1Tap > 0) AppColor.primary else AppColor.textSecondary
        )

        // D2 · 禁用
        Text("Demo 2 · 禁用项（年视图禁用）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2 by remember { mutableStateOf("week") }
        Tabs(
            items = listOf(
                TabItem("周视图", "week"),
                TabItem("月视图", "month"),
                TabItem("年视图", "year", disabled = true),
            ),
            selectedValue = d2,
            onChange = { d2 = it },
        )
        Text("禁用页签 40% 透明且不可点；激活指示线仍在启用的项下方。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 长标题省略 + 品牌红
        Text("Demo 3 · 长标题省略 + 品牌红 activeColor", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3 by remember { mutableStateOf("a") }
        Tabs(
            items = listOf(
                TabItem("全部账单明细全部账单", "a"),
                TabItem("已完成", "b"),
                TabItem("个人收藏夹", "c"),
            ),
            activeColor = Color(0xFFE11D48),
            selectedValue = d3,
            onChange = { d3 = it },
        )
        Text("标题单行省略；激活项底部 2dp 指示线（宽=当前项整宽）为 activeColor。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 受控外部驱动
        Text("Demo 4 · 受控外部驱动", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4 by remember { mutableStateOf("draft") }
        var d4Tap by remember { mutableStateOf(0) }
        Tabs(
            items = listOf(
                TabItem("草稿", "draft"),
                TabItem("已发布", "published"),
                TabItem("归档", "archive"),
            ),
            selectedValue = d4,
            onChange = { d4 = it; d4Tap++ },
        )
        Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            TextButton(onClick = { d4 = "draft" }) { Text("外部切到「草稿」", fontSize = AppFont.sizeXs) }
            TextButton(onClick = { d4 = "published" }) { Text("外部切到「已发布」", fontSize = AppFont.sizeXs) }
        }
        Text("外部 selectedValue 优先级高于自管理；点击回调累计 $d4Tap 次；点已激活项幂等。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

/** HoverButtonDemo：4 段排查（D1 icon-only 圆钮右侧常驻 / D2 icon+text 胶囊左下 / D3 纯文本长内容胶囊 / D4 与 BackTop 共存划界），与 iOS HoverButtonShowcase 1:1。 */
@Composable
private fun HoverButtonDemo() {
    Text(
        text = "HoverButton 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① icon-only ✚ 圆钮右侧常驻 ② icon+text 胶囊左下 ③ 纯文本长内容胶囊 ④ 与 BackTop 共存（常驻动作钮 vs 滚动触发回顶）。双端 1:1（iOS HoverButton vs Android HoverButton）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // D1 · icon-only 圆钮（右侧常驻，点击计数）：默认 ✚（icon/text 均缺省）
        Text("Demo 1 · icon-only 圆钮（右侧常驻，点击计数）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1Count by remember { mutableStateOf(0) }
        val s1 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(220.dp)
        ) {
            BackTopContent(rows = 18, scrollState = s1)
            HoverButton(
                onTap = { d1Count++ },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = if (d1Count > 0) "D1 点击：✚ 圆钮（icon-only 常驻），累计 $d1Count 次" else "右下常驻 ✚ 圆钮；滚动内容不影响它；点击计数。",
            fontSize = AppFont.sizeXs,
            color = if (d1Count > 0) AppColor.primary else AppColor.textSecondary
        )
        Text("icon/text 均缺省 = 默认 ✚ 圆钮（直径 40dp）；按钮常驻、不随滚动显隐，位置由宿主锚定。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · icon+text 胶囊（左下，业务动作"记一笔"）
        Text("Demo 2 · 图标+文本胶囊（左下「✎ 记一笔」，点击计数）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2Count by remember { mutableStateOf(0) }
        val s2 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
        ) {
            BackTopContent(rows = 14, scrollState = s2)
            HoverButton(
                icon = "✎",
                text = "记一笔",
                onTap = { d2Count++ },
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(start = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = if (d2Count > 0) "D2 点击：胶囊（icon ✎ + text 记一笔），累计 $d2Count 次" else "左下常驻胶囊；icon 与文本间距 8dp；点击计数。",
            fontSize = AppFont.sizeXs,
            color = if (d2Count > 0) AppColor.primary else AppColor.textSecondary
        )
        Text("含 text 时 = 胶囊（高 40dp、圆角 full、水平内边距 16dp、宽随内容自适应），icon 与文本间距 8dp。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 纯文本长内容胶囊（icon 缺省不占位）
        Text("Demo 3 · 纯文本长内容胶囊（右侧「打开工具书」）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3Count by remember { mutableStateOf(0) }
        val s3 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
        ) {
            BackTopContent(rows = 12, scrollState = s3)
            HoverButton(
                text = "打开工具书",
                onTap = { d3Count++ },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = if (d3Count > 0) "D3 点击：纯文本胶囊「打开工具书」，累计 $d3Count 次" else "icon 缺省仅 text = 纯文本胶囊（无 icon 位占位）；点击计数。",
            fontSize = AppFont.sizeXs,
            color = if (d3Count > 0) AppColor.primary else AppColor.textSecondary
        )
        Text("胶囊宽度 = 文本自然宽 + 双侧 16dp 内边距，长文本自适应（不写死魔法宽）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 与 BackTop 共存：HoverButton 常驻（点计数）vs BackTop 滚动超阈值出现（点回顶）
        Text("Demo 4 · 与 BackTop 共存（常驻动作钮 vs 滚动触发回顶）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4Count by remember { mutableStateOf(0) }
        val s4 = rememberScrollState()
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(220.dp)
        ) {
            BackTopContent(rows = 40, scrollState = s4)
            HoverButton(
                icon = "✚",
                onTap = { d4Count++ },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = 40.dp + AppSpace.lg)
            )
            BackTop(
                scrollState = s4,
                appearAfterPx = BackTopThresholdPx(120),
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = AppSpace.md, bottom = AppSpace.lg)
            )
        }
        Text(
            text = if (d4Count > 0) "D4 点击：HoverButton 常驻计数 $d4Count 次（BackTop 不受影响）" else "向下滚动超阈值：BackTop 出现；HoverButton 始终常驻。",
            fontSize = AppFont.sizeXs,
            color = if (d4Count > 0) AppColor.primary else AppColor.textSecondary
        )
        Text("悬浮族划界对照：HoverButton=单钮常驻自定义动作；BackTop=滚动超阈值才出现的回顶钮（行为互相独立）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

/** BackTopDemo 滚动内容：rows 条等高文本行，行高 40dp（与 iOS makeScroller 40pt 1:1）。 */
@Composable
private fun BackTopContent(rows: Int, scrollState: ScrollState) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(scrollState)
    ) {
        repeat(rows) { i ->
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(40.dp)
                    .padding(horizontal = AppSpace.md),
                contentAlignment = Alignment.CenterStart
            ) {
                Text(
                    text = String.format("%02d", i + 1) + " · 条目内容第 " + (i + 1) + " 行",
                    fontSize = AppFont.sizeXs,
                    color = AppColor.textSecondary
                )
            }
        }
    }
}

/** BackTopDemo 阈值换算：dp 视觉阈值 → px（组件 appearAfterPx 为 px 参数，与 scroll px 一致）。 */
@Composable
private fun BackTopThresholdPx(dpValue: Int): Int {
    val density = LocalDensity.current
    return with(density) { dpValue.dp.toPx().roundToInt() }
}

/** D2 文字胶囊 face（对齐 iOS makeCapsuleFace：primaryPressed 底圆角 15 + 白字「回顶」，72×30）。 */
@Composable
private fun BackTopCapsuleFace() {
    Box(
        modifier = Modifier
            .width(72.dp)
            .height(30.dp)
            .clip(RoundedCornerShape(15.dp))
            .background(AppColor.primaryPressed),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "回顶",
            fontSize = AppFont.sizeXs,
            fontWeight = FontWeight.SemiBold,
            color = Color.White
        )
    }
}

// ===== Elevator 电梯楼层 · Demo（4 段 1:1 对齐 iOS ElevatorShowcase：自动索引/自定义 index/行点击/长列表） =====
@Composable
private fun ElevatorDemo() {
    Text(
        text = "Elevator 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 楼层分组（默认自动索引）② 城市字母（显式自定义 index）③ 分组行点击（onSelect 回调）④ 12 组月份长列表滚动高亮稳定。双端 1:1（iOS ElevatorView UITableView vs Android Elevator LazyColumn）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // D1 · 楼层分组：不传 index=自动取分组 key
        Text("Demo 1 · 楼层分组（默认自动索引 + 双向联动）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Elevator(
            floors = listOf(
                ElevatorFloor("1F", listOf("星巴克", "瑞幸咖啡", "喜茶")),
                ElevatorFloor("2F", listOf("优衣库", "无印良品", "热风")),
                ElevatorFloor("3F", listOf("华为体验店", "小米之家")),
                ElevatorFloor("4F", listOf("乐高", "玩具反斗城")),
                ElevatorFloor("5F", listOf("万达影城"))
            ),
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
        )
        Text("不传 index 自动取分组 key（1F-5F）：点右侧「5F」即跳 5F 分组；上下滚动内容时右侧高亮当前楼层分组。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 城市字母索引：显式 index
        Text("Demo 2 · 城市字母索引（index 显式自定义）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Elevator(
            floors = listOf(
                ElevatorFloor("A", listOf("安庆", "安阳", "鞍山")),
                ElevatorFloor("B", listOf("北京", "包头", "保定")),
                ElevatorFloor("G", listOf("广州", "桂林")),
                ElevatorFloor("S", listOf("上海", "深圳"))
            ),
            index = listOf("A", "B", "G", "S"),
            modifier = Modifier
                .fillMaxWidth()
                .height(260.dp)
        )
        Text("index 显式传字母数组：右侧只展示含数据的字母（A/B/G/S），点击字母跳对应城市分组。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 分组行点击：onSelect 回传
        Text("Demo 3 · 分组行点击（onSelect 回调）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var selectText by remember { mutableStateOf("点击分组内的某一行（火锅店/电影院等）：结果回显在本行（与 iOS Demo3 一致）。") }
        Elevator(
            floors = listOf(
                ElevatorFloor("餐饮", listOf("火锅店", "面馆", "烧烤店")),
                ElevatorFloor("娱乐", listOf("电影院", "KTV"))
            ),
            onSelect = { floor, row, name ->
                selectText = "已选择：第 ${floor + 1} 组「$name」（该组内第 ${row + 1} 行）"
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
        )
        Text(
            text = selectText,
            fontSize = AppFont.sizeXs,
            color = if (selectText.startsWith("已选择")) AppColor.primary else AppColor.textSecondary
        )

        // D4 · 长分组列表（12 组）
        Text("Demo 4 · 长分组列表（12 组月份，滚动高联稳定）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Elevator(
            floors = (1..12).map { month ->
                ElevatorFloor("${month}月", listOf("$month 月账单样例 · 支出 ¥1,2xx"))
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(440.dp)
        )
        Text("12 个月份分组连续滚动：右侧索引随可视首分组连续高亮，验证长列表高亮无跳变。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

// ===== SideBar 侧边导航 · Demo（4 段 1:1 对齐 iOS SideBarShowcase：基础两栏/禁用长标题/长列表联动/受控复位） =====
@Composable
private fun SideBarDemo() {
    Text(
        text = "SideBar 组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 基础两栏目录（选中持久高亮+切换+回调幂等）② 禁用项+长标题省略 ③ 12 项长列表滚动+内容联动（点选↔反向驱动）④ 受控复位（外部 value 驱动）。双端 1:1（iOS SideBarView vs Android SideBar）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // D1 · 基础两栏目录（账单分类 5 项）
        val d1Data = listOf(
            "全部" to "收入 ¥1,285.50 · 支出 ¥823.00",
            "餐饮" to "本月支出 ¥468.20",
            "交通" to "本月支出 ¥136.80",
            "购物" to "本月支出 ¥523.00",
            "其他" to "本月支出 ¥157.50",
        )
        var d1Sel by remember { mutableStateOf("全部") }
        var d1Count by remember { mutableStateOf(0) }
        Text("Demo 1 · 基础两栏目录（账单分类 5 项，选中持久高亮 + 切换）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(modifier = Modifier.fillMaxWidth().height(260.dp)) {
            SideBar(
                items = d1Data.map { SideBarItem(it.first, it.first) },
                onChange = { value ->
                    d1Sel = value
                    d1Count += 1
                },
                modifier = Modifier.width(96.dp).fillMaxHeight()
            )
            val cur = d1Data.first { it.first == d1Sel }
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(AppRadius.md))
                    .background(AppColor.bgCard)
                    .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
                    .padding(AppSpace.md)
            ) {
                Column {
                    Text("「${cur.first}」", fontSize = AppFont.sizeLg, fontWeight = FontWeight.Bold, color = AppColor.primary)
                    Text(cur.second, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                }
            }
        }
        Text("点不同分类=高亮迁移并切换右侧内容；onChange 已触发 $d1Count 次（点当前已激活项不重复回调，计数不增）。", fontSize = AppFont.sizeXs, color = if (d1Count > 0) AppColor.primary else AppColor.textSecondary)

        // D2 · 禁用项 + 长标题省略
        val d2Data = listOf(
            "账户管理" to "账户资料与登录信息",
            "数据与隐私" to "数据与隐私授权设置",
            "系统设置" to "系统偏好与权限设置（禁用项，点击无反应）",
            "消息通知与提醒偏好配置" to "长标题项：单行显示、超长右缘省略（…）",
            "关于我们" to "版本信息与帮助中心",
        )
        val d2Disabled = setOf("系统设置")
        var d2Sel by remember { mutableStateOf("数据与隐私") }
        var d2Count by remember { mutableStateOf(0) }
        Text("Demo 2 · 禁用项 + 长标题省略（选中持久高亮）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(modifier = Modifier.fillMaxWidth().height(300.dp)) {
            SideBar(
                items = d2Data.map { SideBarItem(it.first, it.first, disabled = it.first in d2Disabled) },
                selectedValue = d2Sel,
                onChange = { value ->
                    d2Sel = value
                    d2Count += 1
                },
                modifier = Modifier.width(96.dp).fillMaxHeight()
            )
            val cur2 = d2Data.first { it.first == d2Sel }
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(AppRadius.md))
                    .background(AppColor.bgCard)
                    .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
                    .padding(AppSpace.md)
            ) {
                Column {
                    Text("「${cur2.first}」", fontSize = AppFont.sizeLg, fontWeight = FontWeight.Bold, color = AppColor.primary)
                    Text(cur2.second, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                }
            }
        }
        Text("onChange 已触发 $d2Count 次（点击禁用项「系统设置」无反应）；「消息通知与提醒偏好配置」长标题单行省略（右侧 …）。", fontSize = AppFont.sizeXs, color = if (d2Count > 0) AppColor.primary else AppColor.textSecondary)

        // D3 · 长列表滚动 + 内容联动（12 个月，点选 ↔ 反向驱动）
        val months = (1..12).map { "${it}月" }
        val sectionPx = with(LocalDensity.current) { 64.dp.roundToPx() }
        var d3Clicked by remember { mutableStateOf("1月") }
        var d3Msg by remember { mutableStateOf("点击月份=右侧内容滚动定位；拖动右侧内容=轨高亮反向跟随（选中自动滚入可视）。") }
        val d3Scroll = rememberScrollState()
        val d3Scope = rememberCoroutineScope()
        val d3ScrollSec = if (sectionPx > 0) d3Scroll.value / sectionPx else 0
        val d3Current = months[d3ScrollSec.coerceIn(0, months.lastIndex)]
        val d3IsReverse = d3Current != d3Clicked
        Text("Demo 3 · 长列表滚动 + 内容联动（12 个月，点选 ↔ 反向驱动）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(modifier = Modifier.fillMaxWidth().height(300.dp)) {
            SideBar(
                items = months.map { SideBarItem(it, it) },
                selectedValue = d3Current,
                onChange = { value ->
                    d3Clicked = value
                    d3Msg = "onChange「$value」：右区已滚动定位到 $value 分段"
                    val idx = months.indexOf(value)
                    if (idx >= 0) d3Scope.launch { d3Scroll.animateScrollTo(idx * sectionPx) }
                },
                modifier = Modifier.width(96.dp).fillMaxHeight()
            )
            Column(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .verticalScroll(d3Scroll)
                    .clip(RoundedCornerShape(AppRadius.md))
                    .background(AppColor.bgCard)
                    .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
            ) {
                months.forEach { month ->
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(64.dp)
                            .padding(horizontal = AppSpace.lg, vertical = AppSpace.sm)
                    ) {
                        Text("$month 账单", fontSize = AppFont.sizeSm, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
                        Text("$month 账单明细样例 · 支出 ¥1,2xx", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
                    }
                }
            }
        }
        Text(
            text = if (d3IsReverse) "右侧滚动 → 轨高亮「$d3Current」（反向驱动轨选中态）" else d3Msg,
            fontSize = AppFont.sizeXs,
            color = if (d3IsReverse) AppColor.textSecondary else AppColor.primary
        )

        // D4 · 受控复位（外部 value 驱动）
        var d4Sel by remember { mutableStateOf("餐饮") }
        var d4Count by remember { mutableStateOf(0) }
        var d4External by remember { mutableStateOf(false) }
        var d4Msg by remember { mutableStateOf("「重置到第一项」= 外部赋值 selectedValue：轨高亮同步 + 选中滚入可视；不触发 onChange（幂等）。") }
        Text("Demo 4 · 受控复位（外部 value 驱动，「重置到第一项」）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Row(modifier = Modifier.fillMaxWidth().height(260.dp)) {
            SideBar(
                items = d1Data.map { SideBarItem(it.first, it.first) },
                selectedValue = d4Sel,
                onChange = { value ->
                    d4Sel = value
                    d4Count += 1
                    d4External = false
                    d4Msg = "onChange「$value」触发（第 $d4Count 次）"
                },
                modifier = Modifier.width(96.dp).fillMaxHeight()
            )
            val cur4 = d1Data.first { it.first == d4Sel }
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(AppRadius.md))
                    .background(AppColor.bgCard)
                    .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
                    .padding(AppSpace.md)
            ) {
                Column {
                    Text("「${cur4.first}」", fontSize = AppFont.sizeLg, fontWeight = FontWeight.Bold, color = AppColor.primary)
                    Text(cur4.second, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                }
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(AppSpace.md)
                        .clip(RoundedCornerShape(14.dp))
                        .background(AppColor.primary)
                        .clickable {
                            d4Sel = d1Data.first().first
                            d4External = true
                            d4Msg = "外部驱动 selectedValue → 第一项「${d1Data.first().first}」：高亮已同步（onChange 计数不增，仍为 $d4Count 次）"
                        }
                        .padding(horizontal = AppSpace.md, vertical = 6.dp)
                ) {
                    Text("重置到第一项", fontSize = AppFont.sizeXs, fontWeight = FontWeight.Medium, color = Color.White)
                }
            }
        }
        Text(
            text = d4Msg,
            fontSize = AppFont.sizeXs,
            color = if (d4External) AppColor.primary else AppColor.textSecondary
        )
    }
}

// ===== 数据录入区首批三件 Demo（#21 Address / #23 CalendarCard / #24 Cascader，规格与双端 iOS 1:1） =====

private fun weekday0Ex(year: Int, month: Int, day: Int): Int {
    val c = java.util.Calendar.getInstance()
    c.clear()
    c.set(year, month - 1, day)
    return (c.get(java.util.Calendar.DAY_OF_WEEK) + 6) % 7
}

private fun weekdayCN(d: CalendarDate): String =
    "星期" + listOf("日", "一", "二", "三", "四", "五", "六")[weekday0Ex(d.year, d.month, d.day)]

/** 省级示例数据（广东省完整三级；北京/上海/重庆=直辖市两级收拢）。 */
private val demoRegionTree: List<RegionOption> = listOf(
    RegionOption("gd", "广东省", children = listOf(
        RegionOption("gd_gz", "广州市", children = listOf(
            RegionOption("gd_gz_tianhe", "天河区"),
            RegionOption("gd_gz_yuexiu", "越秀区"),
            RegionOption("gd_gz_haizhu", "海珠区")
        )),
        RegionOption("gd_sz", "深圳市", children = listOf(
            RegionOption("gd_sz_nanshan", "南山区"),
            RegionOption("gd_sz_futian", "福田区"),
            RegionOption("gd_sz_luohu", "罗湖区")
        )),
        RegionOption("gd_dg", "东莞市", children = listOf(
            RegionOption("gd_dg_nancheng", "南城街道"),
            RegionOption("gd_dg_changan", "长安镇")
        ))
    )),
    RegionOption("zj", "浙江省", children = listOf(
        RegionOption("zj_hz", "杭州市", children = listOf(
            RegionOption("zj_hz_xihu", "西湖区"),
            RegionOption("zj_hz_shangcheng", "上城区"),
            RegionOption("zj_hz_gongshu", "拱墅区")
        )),
        RegionOption("zj_nb", "宁波市", children = listOf(
            RegionOption("zj_nb_haishu", "海曙区"),
            RegionOption("zj_nb_yinzhou", "鄞州区")
        ))
    )),
    RegionOption("js", "江苏省", children = listOf(
        RegionOption("js_nj", "南京市", children = listOf(
            RegionOption("js_nj_xuanwu", "玄武区"),
            RegionOption("js_nj_gulou", "鼓楼区")
        ))
    )),
    RegionOption("bj", "北京市", children = listOf(
        RegionOption("110105", "朝阳区"),
        RegionOption("110108", "海淀区"),
        RegionOption("110101", "东城区")
    )),
    RegionOption("sh", "上海市", children = listOf(
        RegionOption("310104", "徐汇区"),
        RegionOption("310101", "黄浦区"),
        RegionOption("310106", "静安区")
    )),
    RegionOption("cq", "重庆市", children = listOf(
        RegionOption("500103", "渝中区"),
        RegionOption("500108", "南岸区")
    ))
)

/** D3 长列表：在省级示例基础上补 14 个模拟省份（共 20 项滚动可验）。 */
private fun demoLongRegionTree(): List<RegionOption> {
    val extra = (1..14).map { i ->
        RegionOption("demo$i", "示例省份 $i", children = listOf(
            RegionOption("demo${i}_c1", "示例市甲"),
            RegionOption("demo${i}_c2", "示例市乙")
        ))
    }
    return demoRegionTree + extra
}

/** 支出分类树（任意深度 + 节点禁用，Cascader D1/D2）。 */
private val demoCategoryTree: List<CascaderOption> = listOf(
    CascaderOption("living", "生活", children = listOf(
        CascaderOption("dining", "餐饮", children = listOf(
            CascaderOption("fastfood", "快餐"),
            CascaderOption("dinner", "正餐"),
            CascaderOption("brunch", "早午餐")
        )),
        CascaderOption("shopping", "购物", children = listOf(
            CascaderOption("daily", "日用百货"),
            CascaderOption("cloth", "衣物鞋包")
        )),
        CascaderOption("transport", "出行", children = listOf(
            CascaderOption("taxi", "打车"),
            CascaderOption("metro", "地铁")
        ))
    )),
    CascaderOption("invest", "投资", children = listOf(
        CascaderOption("fund", "基金", children = listOf(
            CascaderOption("stockfund", "股票基金"),
            CascaderOption("bondfund", "债券基金"),
            CascaderOption("closedfund", "封闭期基金", disabled = true)
        )),
        CascaderOption("stock", "股票")
    )),
    CascaderOption("medical", "医疗", disabled = true)
)

/** 深层组织架构树（5 层路径 + 横滑回退，Cascader D3）。 */
private val demoOrgTree: List<CascaderOption> = listOf(
    CascaderOption("group", "集团", children = listOf(
        CascaderOption("pl", "产品线 A", children = listOf(
            CascaderOption("mobile", "移动端", children = listOf(
                CascaderOption("comps", "组件组", children = listOf(
                    CascaderOption("ios", "iOS 组件"),
                    CascaderOption("android", "Android 组件")
                )),
                CascaderOption("apis", "接口组")
            )),
            CascaderOption("web", "Web 端")
        )),
        CascaderOption("plb", "产品线 B", children = listOf(
            CascaderOption("data", "数据平台")
        ))
    ))
)

/** AddressDemo：4 段排查（D1 基础三级 / D2 直辖市两级 / D3 长列表+回退 / D4 受控外部驱动）。 */
@Composable
private fun AddressDemo() {
    Text(
        text = "Address 地址组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 基础省市区三级 ② 直辖市两级收拢 ③ 长列表+层级 tab 回退重选 ④ 受控外部驱动。双端 1:1（iOS AddressView vs Android Address）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        // D1 · 基础省市区三级
        Text("Demo 1 · 基础省市区三级联动（完整链路 + 结果回显）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1Result by remember { mutableStateOf<AddressResult?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Address(
                options = demoRegionTree,
                onChange = { d1Result = it },
                modifier = Modifier.fillMaxSize()
            )
        }
        Text(
            text = "onChange → ${d1Result?.text ?: "（未选择）"}${if (d1Result != null) "，codes=[${d1Result!!.codes.joinToString(",")}]" else ""}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("广东→深圳→南山区 完整链路；选到区（叶子）=回调结构化结果 codes+names+text。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 直辖市两级收拢
        Text("Demo 2 · 直辖市数据两级自动收拢", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2Result by remember { mutableStateOf<AddressResult?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(300.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Address(
                options = listOf(
                    RegionOption("bj", "北京市", children = demoRegionTree.first { it.value == "bj" }.children),
                    RegionOption("sh", "上海市", children = demoRegionTree.first { it.value == "sh" }.children),
                    RegionOption("cq", "重庆市", children = demoRegionTree.first { it.value == "cq" }.children)
                ),
                onChange = { d2Result = it },
                modifier = Modifier.fillMaxSize()
            )
        }
        Text(
            text = "onChange → ${d2Result?.text ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("北京/上海/重庆=省层级下 children 直接是区（无市层），选中即两级完成。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 长列表滚动 + 层级 tab 回退重选
        Text("Demo 3 · 20 省大列表滚动 + tab 回退重选", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3Result by remember { mutableStateOf<AddressResult?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(230.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Address(
                options = remember { demoLongRegionTree() },
                onChange = { d3Result = it },
                modifier = Modifier.fillMaxSize()
            )
        }
        Text(
            text = "onChange → ${d3Result?.text ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("列表区可滚动；点顶部已选层 tab（如「广东省」）可回退到对应层重选。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 受控外部驱动（回显既有地址 / 清空）
        Text("Demo 4 · 受控外部驱动（result 预填回显 / 清空）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4Result by remember { mutableStateOf<AddressResult?>(null) }
        var d4Times by remember { mutableStateOf(0) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Address(
                options = demoRegionTree,
                result = d4Result,
                onChange = { d4Result = it; d4Times++ },
                modifier = Modifier.fillMaxSize()
            )
        }
        Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            TextButton(onClick = {
                d4Result = AddressResult(listOf("sh", "310104"), listOf("上海市", "徐汇区"), "上海市 徐汇区")
            }) { Text("回显 上海市 徐汇区", fontSize = AppFont.sizeXs) }
            TextButton(onClick = { d4Result = null }) { Text("清空", fontSize = AppFont.sizeXs) }
        }
        Text(
            text = "外部 result 驱动高亮定位（选中计数 $d4Times 次）；清空=回根层。",
            fontSize = AppFont.sizeXs,
            color = AppColor.textSecondary
        )
    }
}

/** CalendarCardDemo：4 段排查（D1 基础 / D2 翻月+今日 / D3 范围禁用 / D4 受控外部驱动）。 */
@Composable
private fun CalendarCardDemo() {
    val today = remember { CalendarDate.today() }
    Text(
        text = "CalendarCard 日历卡片组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 基础单选 ② 翻月+今日定位 ③ min/maxDate 范围禁用 ④ 受控外部驱动。双端 1:1（iOS CalendarCardView vs Android CalendarCard）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        // D1 · 基础当月单选
        Text("Demo 1 · 基础当月单选（今日描边 + 点选高亮回显）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1 by remember { mutableStateOf<CalendarDate?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            CalendarCard(selected = d1, onChange = { d1 = it }, modifier = Modifier.padding(vertical = AppSpace.sm))
        }
        Text(
            text = "onChange → ${d1?.let { "${it.text}（${weekdayCN(it)}）" } ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("今日 ${today.text}=主色描边圆；点选=主色实心圆白字；点已选中日幂等不重复回调。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 月份切换 + 今日定位
        Text("Demo 2 · 月份切换 + 跨月网格稳定", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2 by remember { mutableStateOf<CalendarDate?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            CalendarCard(selected = d2, onChange = { d2 = it }, modifier = Modifier.padding(vertical = AppSpace.sm))
        }
        Text(
            text = "onChange → ${d2?.let { "${it.text}（${weekdayCN(it)}）" } ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("‹ › 逐月切换，首尾空位占位 7×6 网格稳定不跳行；今日描边跨月仍定位。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · min/maxDate 范围禁用
        Text("Demo 3 · 范围禁用（min=当月 1 日 / max=当月 15 日）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3 by remember { mutableStateOf<CalendarDate?>(null) }
        val rangeMax = remember { today.copy(day = 15) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            CalendarCard(
                selected = d3,
                minDate = today.copy(day = 1),
                maxDate = rangeMax,
                onChange = { d3 = it },
                modifier = Modifier.padding(vertical = AppSpace.sm)
            )
        }
        Text(
            text = "onChange → ${d3?.let { "${it.text}（${weekdayCN(it)}）" } ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("范围外灰禁不可点；越界翻月=对应箭头置灰禁翻。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 受控外部驱动（回显 12-24 / 清空）
        Text("Demo 4 · 受控外部驱动（selected 预填回显自动切月 / 清空）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4 by remember { mutableStateOf<CalendarDate?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            CalendarCard(selected = d4, onChange = { d4 = it }, modifier = Modifier.padding(vertical = AppSpace.sm))
        }
        Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            TextButton(onClick = { d4 = CalendarDate(today.year, 12, 24) }) { Text("回显 12 月 24 日", fontSize = AppFont.sizeXs) }
            TextButton(onClick = { d4 = null }) { Text("清空选中", fontSize = AppFont.sizeXs) }
        }
        Text("外部 selected 变化 → 同步高亮并自动切到所属月；清空=网格无选中（保留当前月）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

/** CascaderDemo：4 段排查（D1 基础三级 / D2 深浅混合+禁用 / D3 深层回退 / D4 受控外部驱动）。 */
@Composable
private fun CascaderDemo() {
    Text(
        text = "Cascader 级联选择组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 基础三级品类树 ② 深浅树混合+节点禁用 ③ 深层路径 tab 回退 ④ 受控外部驱动。双端 1:1（iOS CascaderView vs Android Cascader）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        // D1 · 基础三级品类树
        Text("Demo 1 · 基础三级品类树（叶子完成 + 路径回显）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d1Result by remember { mutableStateOf<CascaderResult?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Cascader(
                options = demoCategoryTree,
                onChange = { d1Result = it },
                modifier = Modifier.fillMaxSize()
            )
        }
        Text(
            text = "onChange → ${d1Result?.text ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("生活→餐饮→正餐 任意三级叶子；选中=回调 values+texts+text（/ 拼接）。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 深浅树混合 + 禁用节点
        Text("Demo 2 · 深浅树混合（2~3 层）+ 节点禁用", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2Result by remember { mutableStateOf<CascaderResult?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Cascader(
                options = demoCategoryTree,
                onChange = { d2Result = it },
                modifier = Modifier.fillMaxSize()
            )
        }
        Text(
            text = "onChange → ${d2Result?.text ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("同树既有 2 层叶（打车/地铁/股票）又有 3 层枝（…/债券基金）；「封闭期基金」「医疗」禁用灰 40% 不可点。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D3 · 深层路径 + tab 回退
        Text("Demo 3 · 5 层组织路径 + 中间层 tab 回退重选", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d3Result by remember { mutableStateOf<CascaderResult?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Cascader(
                options = demoOrgTree,
                onChange = { d3Result = it },
                modifier = Modifier.fillMaxSize()
            )
        }
        Text(
            text = "onChange → ${d3Result?.text ?: "（未选择）"}",
            fontSize = AppFont.sizeXs,
            color = AppColor.primary
        )
        Text("点「产品线 A」等中间层 tab 回退到该层重选其下枝；树深任意由数据决定。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 受控外部驱动
        Text("Demo 4 · 受控外部驱动（result 预填回显 / 清空）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4Result by remember { mutableStateOf<CascaderResult?>(null) }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgCard)
                .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.md))
        ) {
            Cascader(
                options = demoOrgTree,
                result = d4Result,
                onChange = { d4Result = it },
                modifier = Modifier.fillMaxSize()
            )
        }
        Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            TextButton(onClick = {
                d4Result = CascaderResult(
                    listOf("group", "pl", "mobile", "comps", "android"),
                    listOf("集团", "产品线 A", "移动端", "组件组", "Android 组件"),
                    "集团/产品线 A/移动端/组件组/Android 组件"
                )
            }) { Text("回显 组件组/Android", fontSize = AppFont.sizeXs) }
            TextButton(onClick = { d4Result = null }) { Text("清空", fontSize = AppFont.sizeXs) }
        }
        Text("外部 result 按 values 逐层展开高亮；清空=回根层。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)
    }
}

/** FormDemo：4 段排查（D1 基础字段布局 / D2 校验错误渲染 / D3 长 label 与无 label / D4 多分组提交）。 */
@Composable
private fun FormDemo() {
    Text(
        text = "Form 表单组件 v1.0",
        color = AppColor.primary,
        fontSize = AppFont.sizeXs,
        fontWeight = FontWeight.Medium,
        modifier = Modifier.padding(horizontal = AppSpace.xl, vertical = AppSpace.sm)
    )
    Text(
        text = "4 段排查：① 基础字段布局 ② 校验错误渲染（行内红字+无错不占位）③ 长 label 折行+无 label 行 ④ 多分组卡片+提交槽。双端 1:1（iOS FormView vs Android Form）。",
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs,
        modifier = Modifier.padding(horizontal = AppSpace.xl)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        // D1 · 基础字段布局
        Text("Demo 1 · 基础字段布局（label 左 + 内容右 + 必填星 + help）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Form(groupTitle = "登录信息") {
            FormFieldRow(label = "手机号", required = true) {
                Text("138****8888", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textSecondary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = "昵称", required = true) {
                Text("有鱼记账", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textSecondary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = "简介", help = "选填，一句话介绍自己") {
                Text("有鱼记账小助手", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textSecondary, textAlign = TextAlign.End)
            }
        }
        Text("字段行 label 左内容右 · 必填星主色 · 行间 hairline 全卡宽分隔 · help 行内次色小字。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D2 · 校验错误渲染
        Text("Demo 2 · 校验错误渲染（行内红字 + 无错不占位）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d2PhoneError by remember { mutableStateOf<String?>(null) }
        var d2NickError by remember { mutableStateOf<String?>(null) }
        Form {
            FormFieldRow(label = "手机号", required = true, error = d2PhoneError) {
                Text("请输入手机号", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textPrimary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = "昵称", required = true, error = d2NickError) {
                Text("A", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textPrimary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = "简介", help = "选填，一句话介绍自己") {
                Text("已通过", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.primary, textAlign = TextAlign.End)
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            TextButton(onClick = {
                d2PhoneError = "手机号不能为空"
                d2NickError = "昵称至少 2 个字符"
            }) { Text("触发校验", fontSize = AppFont.sizeXs) }
            TextButton(onClick = {
                d2PhoneError = null
                d2NickError = null
            }) { Text("清空校验", fontSize = AppFont.sizeXs) }
        }
        Text(
            text = if (d2PhoneError != null) {
                "校验失败：两行 error 红字展开（帮助文案被 error 顶替）"
            } else {
                "首屏无错误：点「触发校验」展开 error 行；「清空校验」红字收起不占位（简介 help 恢复灰字）。"
            },
            fontSize = AppFont.sizeXs,
            color = if (d2PhoneError != null) AppColor.error else AppColor.textSecondary
        )

        // D3 · 长 label 折行 + 无 label 行
        Text("Demo 3 · 长 label 折行 + 无 label 行（内容全宽）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        Form {
            FormFieldRow(label = "账单导出文件名前缀（支持中文，最长 20 字）") {
                Text("2026-09 消费", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textPrimary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = null) {
                Text(
                    "我已阅读并同意《用户协议》与《隐私政策》",
                    modifier = Modifier.weight(1f),
                    fontSize = AppFont.sizeXs,
                    color = AppColor.textSecondary,
                    textAlign = TextAlign.Start
                )
            }
        }
        Text("label 超长在 96dp 区内自动折行（行随内容增高）；无 label 字段内容占整行。", fontSize = AppFont.sizeXs, color = AppColor.textSecondary)

        // D4 · 多分组卡片 + 提交按钮槽
        Text("Demo 4 · 多分组卡片 + 提交按钮槽（宿主按钮）", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        var d4Msg by remember { mutableStateOf<String?>(null) }
        Form(groupTitle = "账户信息") {
            FormFieldRow(label = "用户名") {
                Text("damon88131787", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textSecondary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = "邮箱") {
                Text("da****@opc.local", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textSecondary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = "手机号") {
                Text("138****8888", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.textSecondary, textAlign = TextAlign.End)
            }
        }
        Form(groupTitle = "安全设置") {
            FormFieldRow(label = "登录密码") {
                Text("已设置 · 去修改 ›", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.primary, textAlign = TextAlign.End)
            }
            FormFieldRow(label = "二次验证") {
                Text("已开启 ›", modifier = Modifier.weight(1f), fontSize = AppFont.sizeMd, color = AppColor.primary, textAlign = TextAlign.End)
            }
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
                contentAlignment = Alignment.Center
            ) {
                AppButton(
                    text = "保存修改",
                    style = AppButtonStyle.Primary,
                    onClick = { d4Msg = "提交：表单内容与校验结论=宿主职责（本 demo 无业务校验）" },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
        Text(
            text = d4Msg ?: "多分组卡上下排（间距 md）· 提交槽=库内 Button 置于 Form content 内。",
            fontSize = AppFont.sizeXs,
            color = if (d4Msg != null) AppColor.primary else AppColor.textSecondary
        )
    }
}
