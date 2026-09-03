import XCTest
import UIKit
@testable import KeepAccountsMiddleware

/// Cell 组件测试：门禁 C1 用例映射（详见 `docs/验收流程/component-acceptance-cell.md`）。
///
/// 覆盖 D1-D5/D7-D8（设计测试）与 A1-A5（API 契约测试）的模型/回调逻辑层；
/// 视觉渲染层（像素级）本机受限（SPM 依赖网络不可达时无法完整构建），
/// 由 Android 侧 Robolectric + Roborazzi 快照覆盖，双端行为一致性见 A7。
/// 用例函数命名与验收文档一一对应，由 `scripts/check_component_quality.py` 核对（C1 用例即代码）。
final class CellTests: XCTestCase {

    /// D1 默认态：模型默认值正确。
    func test_D1_defaultState() {
        let model = CellModel(title: "设置", value: "深色模式")
        XCTAssertEqual(model.title, "设置")
        XCTAssertEqual(model.value, "深色模式")
        XCTAssertTrue(model.arrow)
        XCTAssertFalse(model.disabled)
        XCTAssertFalse(model.loading)
        XCTAssertEqual(model.status, .normal)
    }

    /// D2 禁用态：模型字段正确。
    func test_D2_disabledState() {
        let model = CellModel(title: "设置", disabled: true)
        XCTAssertTrue(model.disabled)
    }

    /// D3 加载态：模型字段正确。
    func test_D3_loadingState() {
        let model = CellModel(title: "设置", loading: true)
        XCTAssertTrue(model.loading)
    }

    /// D4 成功态：模型字段正确。
    func test_D4_successState() {
        let model = CellModel(title: "同步", status: .success)
        XCTAssertEqual(model.status, .success)
    }

    /// D5 失败态：模型字段正确。
    func test_D5_errorState() {
        let model = CellModel(title: "同步", status: .error)
        XCTAssertEqual(model.status, .error)
    }

    /// D6 token 硬编码：由 `scripts/check_component_quality.py` 静态扫描（本类无对应函数）。

    /// D7 按压态：Cell 可绑定点击回调，触发时回调收到数据+索引。
    func test_D7_pressedState() {
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseId)
        var tapped = false
        cell.onTap = { _, _ in tapped = true }
        cell.apply(CellModel(title: "设置"))
        cell.onTap?(nil, 0)
        XCTAssertTrue(tapped)
    }

    /// D8 分隔线：默认显示，可关闭。
    func test_D8_divider() {
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseId)
        XCTAssertTrue(cell.showsDivider)
        cell.showsDivider = false
        XCTAssertFalse(cell.showsDivider)
    }

    /// A1 默认 props：不传时默认值生效。
    func test_A1_defaultProps() {
        let model = CellModel(title: "设置")
        XCTAssertEqual(model.title, "设置")
        XCTAssertTrue(model.arrow)
        XCTAssertNil(model.value)
        XCTAssertEqual(model.status, .normal)
    }

    /// A2 自定义 props：全字段模型。
    func test_A2_customProps() {
        let model = CellModel(
            title: "账号",
            subtitle: "副标题",
            iconSymbol: "person",
            value: "值",
            arrow: false,
            status: .success
        )
        XCTAssertEqual(model.subtitle, "副标题")
        XCTAssertEqual(model.iconSymbol, "person")
        XCTAssertEqual(model.value, "值")
        XCTAssertFalse(model.arrow)
        XCTAssertEqual(model.status, .success)
    }

    /// A3 点击事件：onTap 回调携带数据+索引。
    func test_A3_clickEvent() {
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseId)
        var receivedItem: Any?
        var receivedIndex = -1
        cell.onTap = { item, index in
            receivedItem = item
            receivedIndex = index
        }
        let model = CellModel(title: "甲")
        cell.apply(model)
        cell.onTap?(model, 0)
        XCTAssertEqual(receivedIndex, 0)
        XCTAssertNotNil(receivedItem)
    }

    /// A4 禁用拦截：disabled 后整行不可交互。
    func test_A4_disabledIntercept() {
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseId)
        cell.apply(CellModel(title: "设置", disabled: true))
        XCTAssertFalse(cell.isUserInteractionEnabled)
    }

    /// A5 五态覆盖：模型五态互不干扰。
    func test_A5_stateCoverage() {
        let models = [
            CellModel(title: "a"),
            CellModel(title: "b", disabled: true),
            CellModel(title: "c", loading: true),
            CellModel(title: "d", status: .success),
            CellModel(title: "e", status: .error),
        ]
        XCTAssertEqual(models.count, 5)
        XCTAssertTrue(models[1].disabled)
        XCTAssertTrue(models[2].loading)
        XCTAssertEqual(models[3].status, .success)
        XCTAssertEqual(models[4].status, .error)
    }

    // ---------- H 系列：pt/dp 机制 · 设计稿「32 号字 cell」高度契约 ----------
    // 设计稿（375pt 逻辑基准，@2x）：单行 = 16pt 内边距×2 + 24pt 主标题行高 = 56pt；
    // 副标题行 = 56 + 2pt 间距 + 18pt 副标题行高 = 76pt。两端（iOS pt / Android dp）应一致。
    // 像素级由 Android Robolectric 断言（CellTest H1/H2），本类验证 token 契约值。

    /// H1 单行高度契约：最小行高 = 56，上下内边距 = 16，主标题行高 = 24。
    func test_H1_singleLineHeight() {
        XCTAssertEqual(Cell.minHeight, 56)
        XCTAssertEqual(AppSpace.cellVertical, 16)
        XCTAssertEqual(AppText.cellTitleLineHeight, 24)
        // 单行高度 = 16 + 24 + 16 = 56，与最小行高一致。
        XCTAssertEqual(2 * AppSpace.cellVertical + AppText.cellTitleLineHeight, Cell.minHeight)
    }

    /// H2 副标题行高度契约：副标题行高 = 18，主副间距 = 2。
    func test_H2_subtitleHeight() {
        XCTAssertEqual(AppText.cellSubtitleLineHeight, 18)
        // 副标题行 = 单行(56) + 间距(2) + 副标题行高(18) = 76。
        XCTAssertEqual(Cell.minHeight + 2 + AppText.cellSubtitleLineHeight, 76)
    }

    /// H3 文字行内垂直居中契约（v1.18 校准版）：**不补偿**，iOS 原生 min/max 行高已居中。
    ///
    /// 背景（v1.18 修正）：v1.1.0 曾用 `baselineOffset = (L-n)/2` 补偿，但 macOS TextKit
    /// 像素级实测 + iOS 用户实测双重证实：
    /// 1. iOS 原生 `minimumLineHeight = maximumLineHeight` 撑行高时，文字在行框内
    ///    已接近垂直居中（macOS 实测质心偏差仅 +0.5pt）；
    /// 2. 叠加 baselineOffset 会把**整段文本绘制整体下移**，反而偏下（macOS 实测 +3.5pt，
    ///    与用户实测「文字偏下」完全吻合）；且会放大 UILabel intrinsicContentSize，
    ///    撑高 textStack → 箭头（centerY 锚定 textStack）同步偏下；
    /// 3. 故 v1.18 移除补偿（函数返回 0），让 iOS 原生行高分配决定位置，对齐 Android。
    /// 真值校准：demo 用 `Cell.debugTitleVerticalOffset()` 在 iOS 实机输出实测偏移。
    func test_H3_verticalCenter() {
        // 1) v1.18 校准结论：任何合法字号/行高，补偿值恒为 0（不补偿）。
        let titleOffset = AppText.verticalCenterBaselineOffset(lineHeight: 24, fontSize: 16)
        XCTAssertEqual(titleOffset, 0, "v1.18 起不补偿：iOS 原生 min/max 行高已居中")

        // 2) 主/副标题行高契约不变（24 / 18），内边距 16，单行 56 契约仍成立。
        XCTAssertEqual(AppText.cellTitleLineHeight, 24)
        XCTAssertEqual(AppText.cellSubtitleLineHeight, 18)
        XCTAssertEqual(2 * AppSpace.cellVertical + AppText.cellTitleLineHeight, Cell.minHeight)
    }

    /// H3b 垂直居中实测辅助可用性：demo 依赖 `debugTitleVerticalOffset()` 在 iOS 实机
    /// 输出文字中心相对 cell 内容区中心的偏移（0=居中），用于校准而非纯数学推导。
    /// 本机只验证辅助方法存在且返回有限值（真值需 iOS 实机，见验收文档）。
    func test_H3b_debugVerticalOffsetAvailable() {
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseId)
        cell.apply(CellModel(title: "默认行标题"))
        cell.layoutIfNeeded()
        let offset = cell.debugTitleVerticalOffset()
        XCTAssertTrue(offset.isFinite, "实测辅助必须返回有限偏移值（pt）")
        let trailing = cell.debugTrailingCenterOffset()
        XCTAssertTrue(trailing.isFinite, "trailing 实测辅助必须返回有限偏移值（pt）")
    }
}
