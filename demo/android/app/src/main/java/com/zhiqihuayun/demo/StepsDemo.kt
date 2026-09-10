package com.zhiqihuayun.demo

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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.Steps
import com.zhiqihuayun.sharedui.components.StepsDirection
import com.zhiqihuayun.sharedui.components.StepsItem

// ===== Steps 步骤条 Demo 页（独立页面，与 iOS StepsShowcase 一一对应） =====
// 演示点（验收文档 六）：
// ① 基础步骤条（横向 3 步·当前第 2 步）
// ② 横向+竖向（同屏对比方向）
// ③ 当前步骤高亮（4 步·当前第 3 步·前两步已完成）
// ④ 自定义图标（每步自定义 icon）

@Composable
private fun SectionTitle(text: String) {
    Text(
        text = text,
        color = AppColor.textPrimary,
        fontSize = AppFont.sizeMd,
        fontWeight = FontWeight.SemiBold
    )
}

@Composable
private fun Hint(text: String) {
    Text(
        text = text,
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs
    )
}

/** Steps 组件 Demo 页入口（MainActivity 首页 → 信息展示 → Steps 步骤条）。 */
@Composable
fun StepsDemo() {
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
                text = "Steps 组件 v1.4.30",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础步骤条：横向 3 步，当前第 2 步（current=1）
        SectionTitle("D1 基础步骤条（横向 3 步，当前第 2 步）")
        Steps(
            items = listOf(
                StepsItem(title = "已完成", desc = "步骤一"),
                StepsItem(title = "进行中", desc = "步骤二"),
                StepsItem(title = "未开始", desc = "步骤三"),
            ),
            current = 1,
            direction = StepsDirection.Horizontal,
        )
        Hint("排查点：横向 3 步等宽排列；第 1 步 primary 填充+白对勾、连线主色；第 2 步白底 primary 描边+数字高亮；第 3 步灰描边+灰数字；标题已完成/当前 textPrimary，未开始 textSecondary。")

        // D2 横向+竖向：同屏对比两种方向
        SectionTitle("D2 横向+竖向（同屏对比方向）")
        Steps(
            items = listOf(
                StepsItem(title = "横向一"),
                StepsItem(title = "横向二"),
                StepsItem(title = "横向三"),
            ),
            current = 1,
            direction = StepsDirection.Horizontal,
        )
        Spacer(Modifier.height(AppSpace.lg))
        Steps(
            items = listOf(
                StepsItem(title = "竖向一", desc = "竖向描述一"),
                StepsItem(title = "竖向二", desc = "竖向描述二"),
                StepsItem(title = "竖向三", desc = "竖向描述三"),
            ),
            current = 1,
            direction = StepsDirection.Vertical,
        )
        Hint("排查点：上方横向（圆点顶部居中、连线水平向右）；下方竖向（圆点左侧、文字在右、连线竖直向下）。")

        // D3 当前步骤高亮：4 步，当前第 3 步（current=2），前两步已完成
        SectionTitle("D3 当前步骤高亮（4 步，当前第 3 步）")
        Steps(
            items = listOf(
                StepsItem(title = "第一步"),
                StepsItem(title = "第二步"),
                StepsItem(title = "第三步"),
                StepsItem(title = "第四步"),
            ),
            current = 2,
            direction = StepsDirection.Horizontal,
        )
        Hint("排查点：前两步对勾+主色连线；第 3 步主色描边高亮；第 4 步灰色置灰。点击前两步可回退（onChange 触发）。")

        // D4 自定义图标：每步自定义 icon
        SectionTitle("D4 自定义图标（每步自定义 icon）")
        Steps(
            items = listOf(
                StepsItem(title = "收藏", icon = "star.fill"),
                StepsItem(title = "点赞", icon = "heart.fill"),
                StepsItem(title = "分享", icon = "square.and.arrow.up"),
            ),
            current = 1,
            direction = StepsDirection.Horizontal,
        )
        Hint("排查点：第 1 步星标（主色填充白图标）、第 2 步心形（白底主色描边主色图标）、第 3 步分享（白底灰描边灰图标）；自定义图标覆盖默认数字/对勾。")
    }
}
