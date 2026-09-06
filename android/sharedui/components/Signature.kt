package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.drag
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlin.math.abs

/**
 * Signature 签名（ui.signature，#40）——数据录入区全新立项（规格 signature-design-spec.html，门禁 A P1–P4 全 A）。
 *
 * 内容级手写签名画板：横长白底圆角画板（宽宿主填充、高默认 96dp=2×48 表单交互行基准注释锚定、
 * bgCard 白底 + hairline 描边 + radiusLg 圆角对齐 Input #29 壳语言）+ 底缘引导线（hairline、
 * 左右留 AppSpace.lg、距底 AppSpace.lg）+ 手指/笔自绘圆头笔画（线帽 round、strokeWidth 默认 2、
 * strokeColor 默认 textPrimary=参数可调）+ 空态水印（placeholder 默认「请在此区域签名」
 * textSecondary alpha0.3 sizeMd 画板居中、首笔落下即隐藏、nil/空=无水印）。
 *
 * 状态模型：签名=异步笔迹流（非表单值）=**无受控文本 value**。
 * - onInkChange(Boolean hasInk)：首笔落下（空→非空）=true 一次性回调；clear() 清空（非空→空）=false
 *   一次性回调（=驱动宿主「提交」钮可用态）；其余笔迹过程不重复回调。
 * - clear()=命令式（宿主「重新签名」钮调用）；disabled 期间忽略（=签署提交后锁定语义）。
 * - disabled=整板 40% 灰（含已有笔迹）、不采笔、无任何回调。
 * - SignatureController 可选（默认组件自持）：宿主需外部 clear() 时创建 `remember{SignatureController()}`。
 * - 签名图导出=宿主截取组件渲染（iOS UIGraphicsImageRenderer / Android 根视图截图裁剪），组件不内置图形对象返回。
 *
 * 采集=pointerInput awaitEachGesture 单自旋（Range #36 修复经验）：down 起新 stroke、drag 逐点追加、
 * up/松手收 stroke；disabled 不挂手势。笔画=板内离散 stroke 点集直连+圆帽（同 iOS touches 采集 1:1）。
 *
 * 规格：docs/数据与产物/design-spec/signature-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
private val SIGNATURE_DEFAULT_HEIGHT = 96.dp // 高默认 96=2×48 表单交互行基准（AppSpace 无行高档，注释锚定）
private val SIGNATURE_HAIRLINE = 0.5.dp // hairline=对齐 Grid 先例放行（iOS 1/scale pt vs Android 0.5dp）

/** Signature 命令式操作句柄：宿主创建后传入组件，调 [clear] 触发「重新签名」（disabled 期间忽略）。 */
class SignatureController {
    // 组件（同模块/同文件 composable 读写）需要直接读写 strokes/enabled/onInkChange=保持 internal（public setter 会暴露内部类型，故整属性 internal）
    internal var strokes by mutableStateOf<List<List<Offset>>>(emptyList())
    internal var enabled by mutableStateOf(true)
    internal var onInkChange: ((Boolean) -> Unit)? = null

    /** 清空画板并回 onInkChange(false)；无笔迹=幂等不回调；disabled（签署锁定）=忽略。 */
    fun clear() {
        if (!enabled) return
        if (strokes.isEmpty()) return
        strokes = emptyList()
        onInkChange?.invoke(false)
    }
}

@Composable
fun Signature(
    controller: SignatureController? = null,
    placeholder: String? = "请在此区域签名",
    height: Dp = SIGNATURE_DEFAULT_HEIGHT,
    strokeWidth: Dp = 2.dp,
    strokeColor: Color = AppColor.textPrimary,
    disabled: Boolean = false,
    onInkChange: ((Boolean) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    // 组件自持句柄（宿主不传 controller 时默认内部自持；demo/宿主需「重新签名」则自建传入）。
    val ctrl = controller ?: remember { SignatureController() }
    LaunchedEffect(onInkChange) { ctrl.onInkChange = onInkChange }
    LaunchedEffect(disabled) { ctrl.enabled = !disabled }
    val strokes = ctrl.strokes

    val shape = RoundedCornerShape(AppRadius.lg)
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .alpha(if (disabled) 0.4f else 1f) // disabled=整板 40% 灰（同 Input #29 惯例=签署锁定）
            .clip(shape)
            .background(AppColor.bgCard) // 白底=签名纸直觉（区别于表单 Input 灰底壳）
            .border(SIGNATURE_HAIRLINE, AppColor.border, shape)
            .then(
                if (disabled) {
                    Modifier
                } else {
                    Modifier.pointerInput(Unit) {
                        if (disabled) return@pointerInput
                        awaitEachGesture {
                            val down = awaitFirstDown()
                            down.consume()
                            // 首笔落下（空→非空）=onInkChange(true) 一次性（之后笔迹过程不重复回调）
                            if (ctrl.strokes.isEmpty()) ctrl.onInkChange?.invoke(true)
                            val stroke = mutableListOf(down.position)
                            // strokes 外层须整体重建（snapshot 才 invalidate Canvas 重绘=跟手）
                            ctrl.strokes = ctrl.strokes + listOf(stroke.toList())
                            drag(down.id) { change ->
                                val p = change.position
                                val last = stroke.last()
                                if (abs(p.x - last.x) > 0.5f || abs(p.y - last.y) > 0.5f) {
                                    stroke.add(p)
                                    ctrl.strokes = ctrl.strokes.dropLast(1) + listOf(stroke.toList())
                                }
                                change.consume()
                            }
                        }
                    }
                }
            ),
        contentAlignment = Alignment.Center
    ) {
        // 空态水印：无笔迹且 placeholder 非空=居中 textSecondary 30%（首笔落下随 strokes 非空自动隐藏）
        if (strokes.isEmpty() && !placeholder.isNullOrBlank()) {
            Text(
                text = placeholder,
                fontSize = AppFont.sizeMd,
                color = AppColor.textSecondary.copy(alpha = 0.3f),
                modifier = Modifier.padding(horizontal = AppSpace.lg)
            )
        }
        // 笔画 + 底缘引导线
        Canvas(modifier = Modifier.fillMaxSize()) {
            val lineW = strokeWidth.toPx()
            // 底缘引导线：hairline、左右留 AppSpace.lg、距底 AppSpace.lg（同 iOS draw 1:1）
            val guideY = size.height - AppSpace.lg.toPx()
            drawLine(
                color = AppColor.border,
                start = Offset(AppSpace.lg.toPx(), guideY),
                end = Offset(size.width - AppSpace.lg.toPx(), guideY),
                strokeWidth = SIGNATURE_HAIRLINE.toPx(),
                cap = StrokeCap.Round
            )
            // 逐 stroke 直连绘制（线帽 round=签名顺滑直觉；与 iOS UIBezierPath 采集 1:1）
            for (seg in strokes) {
                if (seg.isEmpty()) continue
                val path = Path()
                path.moveTo(seg[0].x, seg[0].y)
                for (i in 1 until seg.size) path.lineTo(seg[i].x, seg[i].y)
                drawPath(
                    path = path,
                    color = strokeColor,
                    style = Stroke(width = lineW, cap = StrokeCap.Round, join = StrokeJoin.Round)
                )
            }
        }
    }
}
