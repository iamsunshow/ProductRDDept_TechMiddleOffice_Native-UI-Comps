package com.zhiqihuayun.demo

import androidx.compose.foundation.background
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.AppButton
import com.zhiqihuayun.sharedui.components.Collapse
import com.zhiqihuayun.sharedui.components.CollapseItem

// ===== Collapse 组件 Demo 页（独立页面，与 iOS CollapseShowcase 一一对应） =====
// 演示点（验收文档 六）：
// ① 基础折叠（多项可同时展开）
// ② 手风琴模式（只展一项，展新收旧）
// ③ 禁用项（标题置灰不可展）
// ④ 受控外部驱动（外部 activeKeys 控制展开态）

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
private fun BodyText(text: String) {
    Text(
        text = text,
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeSm
    )
}

/** Collapse 组件 Demo 页入口（MainActivity 首页 → 信息展示 → Collapse 折叠面板）。 */
@Composable
fun CollapseDemo() {
    // ① 基础折叠：内部自管理状态（activeKeys=null）
    val d1Items = remember {
        listOf(
            CollapseItem(key = "1", title = "标题一") { BodyText("NutUI 是一套京东风格的多端组件库，支持 React、Vue、小程序等多端开发，提供建议的组件与业务页面。") },
            CollapseItem(key = "2", title = "标题二") { BodyText("Collapse 折叠面板：可折叠/展开的内容区域，用于将较长内容分组收纳，节省页面纵向空间。") },
            CollapseItem(key = "3", title = "标题三") { BodyText("手风琴模式（accordion）下同时只允许一项展开，展开新项时自动收起旧项。") },
        )
    }

    // ② 手风琴模式：内部自管理 + accordion=true
    val d2Items = remember {
        listOf(
            CollapseItem(key = "a", title = "第一章 概述") { BodyText("本章介绍组件库的整体定位与设计原则。") },
            CollapseItem(key = "b", title = "第二章 安装") { BodyText("本章说明如何引入组件库并初始化主题。") },
            CollapseItem(key = "c", title = "第三章 使用") { BodyText("本章演示基础组件与业务组件的调用方式。") },
        )
    }

    // ③ 禁用项：第二项 disabled=true
    val d3Items = remember {
        listOf(
            CollapseItem(key = "x1", title = "可用项") { BodyText("点击标题可展开/收起此项内容。") },
            CollapseItem(key = "x2", title = "禁用项（不可展开）", disabled = true) { BodyText("此项不可展开。") },
            CollapseItem(key = "x3", title = "可用项") { BodyText("此项正常展开。") },
        )
    }

    // ④ 受控外部驱动：activeKeys 由外部 state 控制，按钮切换
    val d4Items = remember {
        listOf(
            CollapseItem(key = "k1", title = "受控项一") { BodyText("外部 activeKeys 包含此项 key 时展开，否则收起。") },
            CollapseItem(key = "k2", title = "受控项二") { BodyText("点击标题仍可切换，但最终态由外部 state 决定（onChange 回写）。") },
        )
    }
    var d4Active by remember { mutableStateOf(listOf("k1")) }

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
                text = "Collapse 组件 v1.4.27",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础折叠（多项可同时展开）
        SectionTitle("D1 基础折叠（多项可同时展开）")
        Collapse(items = d1Items)
        Hint("排查点：三项均可独立展开/收起，互不影响；右侧箭头展开时由右指旋转为下指；项间有分隔线。")

        // D2 手风琴模式（只展一项）
        SectionTitle("D2 手风琴模式（accordion，只展一项）")
        Collapse(items = d2Items, accordion = true)
        Hint("排查点：展开新项时自动收起旧项，同时最多一项展开。")

        // D3 禁用项
        SectionTitle("D3 禁用项（标题置灰不可展开）")
        Collapse(items = d3Items)
        Hint("排查点：第二项「禁用项」标题置灰、箭头灰、点击无响应不展开。")

        // D4 受控外部驱动
        SectionTitle("D4 受控外部驱动（外部 activeKeys 控制）")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = "只展项一",
                onClick = { d4Active = listOf("k1") },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "只展项二",
                onClick = { d4Active = listOf("k2") },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "全部收起",
                onClick = { d4Active = emptyList() },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        Collapse(
            items = d4Items,
            activeKeys = d4Active,
            onChange = { d4Active = it }
        )
        Hint("排查点：外部按钮切换 activeKeys 驱动面板展开态；点击标题也可切换并通过 onChange 回写外部 state。")
    }
}
