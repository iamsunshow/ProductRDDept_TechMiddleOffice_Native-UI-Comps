package com.zhiqihuayun.demo

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color as AndroidColor
import android.graphics.Paint
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.AppButton
import com.zhiqihuayun.sharedui.components.Image

// ===== Image 组件 Demo 页（独立页面，与 iOS ImageShowcase 一一对应） =====
// 演示点（验收文档 六）：
// ① 基础（本地图 + 显式尺寸 + radius 圆角/圆形头像）
// ② fit 五模式同屏对比（同一图换 fit，可看清拉伸/裁剪/留白差异）
// ③ loading/error 占位（src=null 模拟慢源窗口；无效源显示失败占位 + 重试恢复）
// ④ 事件反馈（onTap 点击反馈条 + onLoad/onError 计数）

/** 演示素材：320×200 本地样例图（上蓝下橙 + 白色太阳圆），宽高比 3:2 ≠ 容器 4:3，便于肉眼判断 fit 缩放/裁切。 */
private fun makeDemoBitmap(w: Int = 320, h: Int = 200): ImageBitmap {
    val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bmp)
    val blue = Paint().apply { color = AndroidColor.rgb(0x17, 0x6D, 0xE8) }
    val orange = Paint().apply { color = AndroidColor.rgb(0xF7, 0x9E, 0x1B) }
    val white = Paint().apply { color = AndroidColor.rgb(0xFF, 0xFF, 0xFF) }
    canvas.drawColor(blue.color)
    canvas.drawRect(0f, h / 2f, w.toFloat(), h.toFloat(), orange)
    canvas.drawCircle(w * 0.62f, h * 0.25f, 26f, white)
    return bmp.asImageBitmap()
}

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

@Composable
private fun DemoImageCard(
    src: Any?,
    width: Int,
    height: Int,
    label: String,
    radius: Any? = null,
    fit: String = "fill",
    onTap: (() -> Unit)? = null,
    onLoad: (() -> Unit)? = null,
    onError: (() -> Unit)? = null,
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Image(
            src = src,
            fit = fit,
            width = width.dp,
            height = height.dp,
            radius = radius,
            alt = label,
            onTap = onTap,
            onLoad = onLoad,
            onError = onError,
        )
        Text(
            text = label,
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs,
            textAlign = TextAlign.Center
        )
    }
}

/** Image 组件 Demo 页入口（MainActivity 首页 → 基础组件 → Image 图片）。 */
@Composable
fun ImageDemo() {
    val sample = remember { makeDemoBitmap() }
    var clickInfo by remember { mutableStateOf("点击任意图片查看回调反馈（onTap）") }
    var tapCount by remember { mutableStateOf(0) }
    var loadCount by remember { mutableStateOf(0) }
    var errorCount by remember { mutableStateOf(0) }

    // ③ 加载中占位演示：null = 慢源/解码窗口
    var loadingSrc by remember { mutableStateOf<Any?>(null) }
    // ④ 失败占位演示：初始无效资源名 → 失败占位；「重试恢复」= 业务重设合法 src（P4=B）
    var failingSrc by remember { mutableStateOf<Any?>("no_such_drawable_xyz") }

    fun onTapOf(name: String) {
        tapCount++
        clickInfo = "点击了：$name"
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：与 iOS 端保持同一版本号（组件库正式版 v1.3.2，对齐 ui-version.json）。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "Image 组件 v1.3.2",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }
        // 事件反馈条（对标 iOS feedbackLabel）
        Text(
            text = clickInfo,
            color = AppColor.primary,
            fontSize = AppFont.sizeXs,
            fontWeight = FontWeight.Medium
        )
        Text(
            text = "事件累计：onTap ×$tapCount · onLoad ×$loadCount · onError ×$errorCount",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // ① 基础形态：本地图 + 显式尺寸 + radius（默认 / lg 圆角 / 圆形=半径 24 = 宽 48/2）
        SectionTitle("① 基础形态（本地图 + 尺寸 + 圆角/圆形）")
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = AppSpace.lg),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.Bottom
        ) {
            DemoImageCard(sample, 96, 64, "默认 fill", onTap = { onTapOf("① 基础-默认") })
            DemoImageCard(sample, 96, 64, "圆角 lg", radius = "lg", onTap = { onTapOf("① 基础-圆角 lg") })
            DemoImageCard(sample, 48, 48, "圆形头像", radius = 24, onTap = { onTapOf("① 基础-圆形头像") })
        }
        Hint("演示素材=320×200 上蓝下橙+白色太阳圆（8:5，太阳圆心偏左上方，便于肉眼观察 fit 变形/裁切）。排查点：同一本地图三种裁剪——无圆角 / lg 圆角 / 圆形（radius=宽/2=24）；fill 拉伸到与素材不等比的容器时白圆会变形（椭圆），属 fill 语义。点击应触发 onTap 反馈。")

        // ② fit 五模式同屏对比（同一 320×200 图，容器 120×90，4:3 vs 3:2）
        SectionTitle("② fit 五模式同屏对比（同一图，容器 120×90）")
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.lg),
            verticalAlignment = Alignment.Bottom
        ) {
            for (fit in listOf("fill", "contain", "cover", "none", "scale-down")) {
                DemoImageCard(
                    sample, 120, 90,
                    label = fit,
                    fit = fit,
                    onTap = { onTapOf("② fit=$fit") },
                )
            }
        }
        Hint("排查点：fill=拉伸铺满；contain=完整等比（上下留白）；cover=等比铺满（左右被裁，居中可见白色太阳圆）；none=原始尺寸（超出被裁）；scale-down=不放大（同 contain）。")

        // ③ 加载中占位（src=null 模拟慢源/解码窗口）
        SectionTitle("③ 加载中占位（src=null 模拟慢源/解码窗口）")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = "模拟加载中（null）",
                onClick = { loadingSrc = null },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "模拟解码完成",
                onClick = { loadingSrc = sample },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.Bottom) {
            DemoImageCard(
                loadingSrc, 120, 90,
                label = if (loadingSrc == null) "loading（默认占位）" else "loaded",
                fit = "contain",
                onLoad = { loadCount++ },
            )
        }
        Hint("预期：src=null 时显示默认灰底+双色转圈占位（占位层无读屏语义，由容器输出 alt）；点「模拟解码完成」立即渲染并触发 onLoad。")

        // ④ 失败占位与重试（P4=B：重试 = 业务重设 src）
        SectionTitle("④ 失败占位与重试（无效源 → 失败占位；重试 = 业务改 src）")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = "置为无效源",
                onClick = { failingSrc = "no_such_drawable_xyz" },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "重试恢复",
                onClick = { failingSrc = sample },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.Bottom) {
            DemoImageCard(
                failingSrc, 120, 90,
                label = if (failingSrc is String) "failed（默认破图占位）" else "loaded",
                fit = "contain",
                onLoad = { loadCount++ },
                onError = { errorCount++ },
            )
        }
        Hint("预期：无效资源名显示默认破图+「加载失败」占位并触发 onError（上方案例图即默认破图视觉）；点「重试恢复」自动重新加载并触发 onLoad（P4=B 语义）。")
    }
}
