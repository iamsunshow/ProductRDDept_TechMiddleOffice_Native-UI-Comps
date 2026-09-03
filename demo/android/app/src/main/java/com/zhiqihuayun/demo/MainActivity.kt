package com.zhiqihuayun.demo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.AppButton
import com.zhiqihuayun.sharedui.components.AppButtonStyle
import com.zhiqihuayun.sharedui.components.AppIcon
import com.zhiqihuayun.sharedui.components.AppIconName
import com.zhiqihuayun.sharedui.components.AppTheme
import com.zhiqihuayun.sharedui.components.Cell
import com.zhiqihuayun.sharedui.components.CellStatus
import com.zhiqihuayun.sharedui.components.ConfigProvider
import com.zhiqihuayun.sharedui.components.GridItem
import com.zhiqihuayun.sharedui.components.NavigationGrid
import com.zhiqihuayun.sharedui.components.ProfileListGroup
import com.zhiqihuayun.sharedui.components.ProfileListItem
import com.zhiqihuayun.sharedui.components.SummaryCardView
import com.zhiqihuayun.sharedui.components.ChartPoint
import com.zhiqihuayun.sharedui.components.TrendChartView

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
        DemoComponent("Overlay 遮罩层"),
    ),
    "布局组件" to listOf(
        DemoComponent("Divider 分割线"),
        DemoComponent("Grid 宫格", reviewed = true, demo = { GridDemo() }),
        DemoComponent("Layout 布局"),
        DemoComponent("SafeArea 安全区"),
        DemoComponent("Space 间距"),
        DemoComponent("Sticky 粘性布局"),
    ),
    "导航组件" to listOf(
        DemoComponent("BackTop 返回顶部"),
        DemoComponent("Elevator 电梯楼层"),
        DemoComponent("FixedNav 悬浮导航"),
        DemoComponent("HoverButton 悬浮按钮"),
        DemoComponent("NavBar 头部导航"),
        DemoComponent("SideBar 侧边导航"),
        DemoComponent("Tabbar 标签栏"),
        DemoComponent("Tabs 选项卡"),
    ),
    "数据录入" to listOf(
        DemoComponent("Address 地址"),
        DemoComponent("Calendar 日历"),
        DemoComponent("CalendarCard 日历卡片"),
        DemoComponent("Cascader 级联选择"),
        DemoComponent("Checkbox 复选"),
        DemoComponent("DatePicker 日期选择"),
        DemoComponent("DatePickerView 视图"),
        DemoComponent("Form 表单"),
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
        // 组件版本徽标：用于核对实机是否运行最新代码，与 iOS 端保持同一版本号/时间。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "Cell 组件 v1.31",
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
        // 组件版本徽标：= 组件库正式版本（对齐 ui-version.json v1.2.1；Button/Cell/Icon 的 vX.Y 属另一套 demo 演示版本链）。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "ConfigProvider 组件 v1.2.1",
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

    val mockSigns = remember {
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
            val users = listOf(
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
        text = "Grid 组件 v1.0",
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
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // ── Demo 1：基础四宫格 ──
        Text("Demo 1 · 基础四宫格", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        NavigationGrid(
            title = "常用功能",
            items = listOf(
                GridItem("列表", AppIconName.List),
                GridItem("图表", AppIconName.Chart),
                GridItem("加号", AppIconName.Plus),
                GridItem("人物", AppIconName.Person),
            )
        )

        // ── Demo 2：带标题分区 ──
        Text("Demo 2 · 带标题分区", fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold, color = AppColor.textPrimary)
        NavigationGrid(
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
        NavigationGrid(
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
        NavigationGrid(
            title = "常用功能",
            items = listOf(
                GridItem("列表", AppIconName.List),
                GridItem("图表", AppIconName.Chart),
                GridItem("加号", AppIconName.Plus),
                GridItem("人物", AppIconName.Person),
            )
        )
        NavigationGrid(
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
