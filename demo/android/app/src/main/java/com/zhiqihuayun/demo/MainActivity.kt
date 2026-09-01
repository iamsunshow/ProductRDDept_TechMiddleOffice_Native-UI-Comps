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
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.Cell
import com.zhiqihuayun.sharedui.components.CellStatus

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
        DemoComponent("Button 按钮"),
        DemoComponent("Cell 单元格", reviewed = true, demo = { CellDemo() }),
        DemoComponent("ConfigProvider 全局配置"),
        DemoComponent("Icon 图标"),
        DemoComponent("Image 图片"),
        DemoComponent("Overlay 遮罩层"),
    ),
    "布局组件" to listOf(
        DemoComponent("Divider 分割线"),
        DemoComponent("Grid 宫格"),
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
        DemoComponent("Empty 空状态"),
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
        DemoComponent("Avatar 头像"),
        DemoComponent("CircleProgress 环形进度"),
        DemoComponent("Collapse 折叠面板"),
        DemoComponent("CountDown 倒计时"),
        DemoComponent("Ellipsis 文本省略"),
        DemoComponent("ImagePreview 图片预览"),
        DemoComponent("Indicator 指示器"),
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
    ),
    "特色组件" to listOf(
        DemoComponent("QuickEnter 快捷入口"),
        DemoComponent("AvatarCropper 头像裁剪"),
        DemoComponent("Barrage 弹幕"),
        DemoComponent("Card 商品卡片"),
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

    if (current == null) {
        ComponentList(onOpen = { current = it })
    } else {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(AppColor.bgPage)
        ) {
            TextButton(onClick = { current = null }) {
                Text(text = "← 返回组件列表", color = AppColor.primary, fontSize = AppFont.sizeMd)
            }
            current?.invoke()
        }
    }
}

@Composable
private fun ComponentList(onOpen: (@Composable () -> Unit) -> Unit) {
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
                ComponentRow(comp, onClick = { onOpen(comp.demo!!) })
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
                text = "Cell 组件 v1.18",
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
