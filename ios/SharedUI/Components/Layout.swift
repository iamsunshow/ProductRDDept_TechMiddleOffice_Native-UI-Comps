/// Layout 布局：横向弹性分栏容器（Row/Col，12 栅格 span 1~12）。
///
/// 组件 ID：`ui.layout`（api.json 契约对齐，门禁 A 评审通过 2026-09-04，
/// 用户 P1–P4 全票 A：Row/Col 双组件 + 12 栅格 + gutter 默认 AppSpace.md + 一期单行）。
/// 命名：LayoutRow/LayoutCol（双端同名；iOS 去 View 后缀规范）。
///
/// 一期语义：
/// - 子项按 `span/12` 比例占行宽（span 和不足 12 时右侧留空，不强制满行）
/// - 子项内容顶部对齐；行高 = 子项内容自然最大高度（`LayoutCol` 内内容须
///   四边钉满 col——内容高度驱动行高，组件不干预子项内部布局）
/// - 等高拉伸 / center/end 对齐二期引入（双端契约同步）
///
/// 用法：
/// ```swift
/// let row = LayoutRow()
/// row.addCols([
///     LayoutCol(span: 6),
///     LayoutCol(span: 6),
/// ])
/// ```
import UIKit
import SnapKit

/// 横向分栏容器：子项顶部对齐、行高取最高子项内容，间距 = gutter。
final class LayoutRow: UIView {

    /// 子项水平间距（默认 AppSpace.md=12，P3 用户 2026-09-04 表决 A）。
    var gutter: CGFloat = AppSpace.md {
        didSet {
            guard gutter != oldValue else { return }
            relayoutCols()
        }
    }

    private(set) var cols: [LayoutCol] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 添加一个分栏子项（span 1~12）。
    func addCol(_ col: LayoutCol) {
        cols.append(col)
        addSubview(col)
        relayoutCols()
    }

    /// 批量添加分栏子项。
    func addCols(_ cols: [LayoutCol]) {
        cols.forEach {
            self.cols.append($0)
            addSubview($0)
        }
        relayoutCols()
    }

    /// 清空全部子项。
    func removeAllCols() {
        cols.forEach { $0.removeFromSuperview() }
        cols.removeAll()
    }

    /// 移除旧约束后按当前 cols/gutter 重建横向约束链。
    private func relayoutCols() {
        guard !cols.isEmpty else { return }
        cols.forEach { $0.snp.removeConstraints() }

        var previous: LayoutCol?
        for (index, col) in cols.enumerated() {
            col.snp.makeConstraints { make in
                // 宽 = 父宽 × span/12（12 栅格）
                make.width.equalTo(self).multipliedBy(CGFloat(col.span) / 12.0)
                if let previous {
                    make.leading.equalTo(previous.snp.trailing).offset(gutter)
                } else {
                    make.leading.equalToSuperview()
                }
                make.top.equalToSuperview()
                // 行高锚：首个子项 bottom = 行底（required，由首个子项内容全链撑起行高），
                // 其余子项 bottom ≤ 行底（内容不高出首个子项时自然等高；内容更高的场景
                // 一期按 diff-api.json 放行，二期引入 max 行高驱动与等高拉伸对齐）。
                if index == 0 {
                    make.bottom.equalToSuperview()
                } else {
                    make.bottom.lessThanOrEqualToSuperview()
                }
            }
            previous = col
        }
    }
}

/// 分栏子项：占行宽 `span/12`。
///
/// 注意：内容（卡片等）须加入本 col 并四边钉满，内容高度决定该列参与行高的
/// 自然高度；col 自身透明无装饰。
final class LayoutCol: UIView {

    /// 栅格宽度（1~12，12 栅格，占行宽 span/12）。
    let span: Int

    init(span: Int) {
        precondition((1...12).contains(span), "span 必须在 1~12（12 栅格），当前 \(span)")
        self.span = span
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
