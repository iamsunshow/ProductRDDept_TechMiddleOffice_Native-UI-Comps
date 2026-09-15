/// Tag 标签 · 组件测试
///
/// 验证组件库版本：v1.7.6（契约 `docs/数据与产物/api.json` `ui.tag`，门禁 B ✅ 2026-09-11 冻结）。
/// 用例覆盖 4 个历史根因（2026-09-12 多轮调试复盘）：
///   根因1: convenience init 内赋值 stored property 不触发 didSet → label.text 永远为空 → 渲染椭圆小点
///   根因2: layoutSubviews() 中 snp.updateConstraints 导致布局循环 → label 宽度 0
///   根因3: intrinsicContentSize 无文字宽度时返回 paddingH*2=12（椭圆小点根因）
///   根因4: closable=true 时 closeIcon 应可见且尺寸=iconSize
///
/// 测试策略：通过外部可观察的 intrinsicContentSize / backgroundColor / layer.borderWidth
/// 间接验证内部 label.text 是否已赋值，不直接访问 private 属性（@testable import 不能跨 private）。

import UIKit
import XCTest
@testable import TMONativeUIComps

final class TagTests: XCTestCase {

    // MARK: - 根因1: convenience init didSet 陷阱（核心回归用例）

    /// 验证：convenience init(text:) 初始化后 intrinsicContentSize.width 必须大于 paddingH*2
    /// 历史 bug：self.text=text 不触发 didSet { updateAppearance() }，label.text 永远是 ""
    /// → intrinsicContentSize 返回 paddingH*2=12 → 渲染椭圆小点
    /// 此用例直接断言 intrinsicContentSize——若 didSet 陷阱复发，立即失败
    func test_convenienceInit_intrinsicContentSize有文字宽度() {
        let tag = TagView(text: "测试标签", variant: .filled, color: .primary, size: .sm)
        let intrinsic = tag.intrinsicContentSize
        let paddingOnly = TagSize.sm.paddingH * 2  // 12
        XCTAssertGreaterThan(intrinsic.width, CGFloat(paddingOnly), "有文字时 intrinsicContentSize.width 必须大于 paddingH*2=12（didSet 陷阱回归点——若复发=椭圆小点）")
        XCTAssertEqual(intrinsic.height, TagSize.sm.height, "intrinsicContentSize.height 必须=tagSize.height=20")
    }

    /// 验证：空字符串 vs 非空字符串的 intrinsicContentSize.width 差异
    /// 确保文字确实参与了 intrinsicContentSize 计算（间接验证 label.text 已赋值）
    func test_文字宽度差异验证_labelText已赋值() {
        let emptyTag = TagView(text: "", variant: .filled, color: .primary, size: .sm)
        let textTag = TagView(text: "这是一个比较长的标签文字", variant: .filled, color: .primary, size: .sm)
        let emptyWidth = emptyTag.intrinsicContentSize.width
        let textWidth = textTag.intrinsicContentSize.width
        XCTAssertEqual(emptyWidth, CGFloat(TagSize.sm.paddingH * 2), "空字符串 intrinsicContentSize 应=paddingH*2=12")
        XCTAssertGreaterThan(textWidth, emptyWidth + 20, "有文字时 intrinsicContentSize 应明显大于空字符串（差值>20）")
    }

    // MARK: - 三形态

    /// 验证：filled 实心白字 / outline 描边深色字 / light 浅色底深色字
    /// 间接验证：通过 backgroundColor + layer.borderWidth 区分三形态
    func test_三形态背景与边框() {
        let filled = TagView(text: "filled", variant: .filled, color: .primary, size: .sm)
        let outline = TagView(text: "outline", variant: .outline, color: .primary, size: .sm)
        let light = TagView(text: "light", variant: .light, color: .primary, size: .sm)

        // filled：背景=主色，无边框
        XCTAssertEqual(filled.backgroundColor, AppColor.primary, "filled 背景应=主色")
        XCTAssertEqual(filled.layer.borderWidth, 0, "filled 无边框")

        // outline：背景=透明，有 1px 边框
        XCTAssertEqual(outline.backgroundColor, .clear, "outline 背景应=透明")
        XCTAssertEqual(outline.layer.borderWidth, 1, "outline 有 1px 边框")

        // light：背景=主色 10% 透明，无边框
        let lightBg = light.backgroundColor
        XCTAssertNotNil(lightBg, "light 背景不应为 nil")
        XCTAssertEqual(lightBg, AppColor.primary.withAlphaComponent(0.1), "light 背景应=主色 10%")
        XCTAssertEqual(light.layer.borderWidth, 0, "light 无边框")
    }

    /// 验证：三形态的 intrinsicContentSize 都有文字宽度（didSet 陷阱在三形态都不会复发）
    func test_三形态都有文字宽度() {
        let filled = TagView(text: "filled", variant: .filled, color: .primary, size: .sm)
        let outline = TagView(text: "outline", variant: .outline, color: .primary, size: .sm)
        let light = TagView(text: "light", variant: .light, color: .primary, size: .sm)
        let paddingOnly = CGFloat(TagSize.sm.paddingH * 2)
        XCTAssertGreaterThan(filled.intrinsicContentSize.width, paddingOnly, "filled 应有文字宽度")
        XCTAssertGreaterThan(outline.intrinsicContentSize.width, paddingOnly, "outline 应有文字宽度")
        XCTAssertGreaterThan(light.intrinsicContentSize.width, paddingOnly, "light 应有文字宽度")
    }

    // MARK: - 四色

    /// 验证：primary / success / warning / error 四种主题色
    func test_四色主题色() {
        let cases: [(TagColor, UIColor)] = [
            (.primary, AppColor.primary),
            (.success, AppColor.success),
            (.warning, AppColor.warning),
            (.error, AppColor.error),
        ]
        for (color, expected) in cases {
            let tag = TagView(text: "test", variant: .filled, color: color, size: .sm)
            XCTAssertEqual(tag.backgroundColor, expected, "\(color) filled 背景应=对应主题色")
        }
    }

    // MARK: - 三尺寸

    /// 验证：sm / md / lg 三种尺寸的 intrinsicContentSize.height
    func test_三尺寸高度() {
        let sm = TagView(text: "sm", size: .sm)
        let md = TagView(text: "md", size: .md)
        let lg = TagView(text: "lg", size: .lg)

        XCTAssertEqual(sm.intrinsicContentSize.height, TagSize.sm.height, "sm 高度应=20")
        XCTAssertEqual(md.intrinsicContentSize.height, TagSize.md.height, "md 高度应=24")
        XCTAssertEqual(lg.intrinsicContentSize.height, TagSize.lg.height, "lg 高度应=28")
    }

    // MARK: - closable

    /// 验证：closable=true 时 intrinsicContentSize 比 closable=false 大（多了 closeIcon 宽度+spacing）
    /// 间接验证 closeIcon 已添加到 contentStack
    func test_closable_intrinsicContentSize更大() {
        let noClose = TagView(text: "测试", size: .sm, closable: false)
        let closable = TagView(text: "测试", size: .sm, closable: true)
        let noCloseWidth = noClose.intrinsicContentSize.width
        let closableWidth = closable.intrinsicContentSize.width
        // closable 应比非 closable 多出 closeIcon 宽度（iconSize=12）+ spacing（2）
        let expectedDiff = CGFloat(TagSize.sm.iconSize + 2)  // 14
        let actualDiff = closableWidth - noCloseWidth
        XCTAssertEqual(actualDiff, expectedDiff, "closable=true 应比 closable=false 多 \(expectedDiff)pt（closeIcon+spacing），实际差=\(actualDiff)")
    }

    /// 验证：点击 closeIcon 触发 onClose 回调
    /// 直接调用 closeTapped()（通过 Selector 模拟手势触发）
    func test_点击closeIcon触发onClose() {
        var clicked = 0
        let tag = TagView(text: "可关闭", size: .sm, closable: true)
        tag.onClose = {
            clicked += 1
        }
        // 模拟手势触发——直接 perform closeTapped
        tag.perform(NSSelectorFromString("closeTapped"))
        XCTAssertEqual(clicked, 1, "点击 closeIcon 应触发一次 onClose")
    }

    // MARK: - 根因2 回归：layoutSubviews 无 updateConstraints 循环

    /// 验证：TagView 在 superview 中 layoutSubviews 后不会崩溃或宽度为 0
    /// 历史 bug：layoutSubviews() 中 snp.updateConstraints 导致布局循环
    func test_layoutSubviews后宽度大于0且不崩溃() {
        let tag = TagView(text: "布局测试", variant: .filled, color: .primary, size: .md)
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        host.addSubview(tag)
        tag.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        // 多次 layoutSubviews 验证不循环
        for _ in 0..<5 {
            host.layoutIfNeeded()
        }
        XCTAssertGreaterThan(tag.bounds.width, 0, "layoutSubviews 后 TagView 宽度应>0")
        XCTAssertGreaterThan(tag.intrinsicContentSize.width, CGFloat(TagSize.md.paddingH * 2), "layoutSubviews 后 intrinsicContentSize 应有文字宽度")
    }

    // MARK: - 变更属性触发 didSet 回归

    /// 验证：运行时修改 text 属性触发 didSet → intrinsicContentSize 更新
    /// 防止未来重构破坏 didSet 机制
    func test_运行时修改text触发didSet更新() {
        let tag = TagView(text: "短", variant: .filled, color: .primary, size: .sm)
        let shortWidth = tag.intrinsicContentSize.width
        tag.text = "这是一个更长的标签文字"
        let longWidth = tag.intrinsicContentSize.width
        XCTAssertGreaterThan(longWidth, shortWidth + 20, "运行时修改 text 应触发 didSet→intrinsicContentSize 更新，长文字应明显大于短文字")
    }

    /// 验证：运行时修改 variant 触发 didSet → 边框更新
    func test_运行时修改variant触发didSet更新() {
        let tag = TagView(text: "test", variant: .filled, color: .primary, size: .sm)
        XCTAssertEqual(tag.layer.borderWidth, 0, "初始 filled 应无边框")
        tag.variant = .outline
        XCTAssertEqual(tag.layer.borderWidth, 1, "修改为 outline 应触发 didSet→边框=1")
        tag.variant = .light
        XCTAssertEqual(tag.layer.borderWidth, 0, "修改为 light 应触发 didSet→边框=0")
    }
}
