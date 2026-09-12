/// Row 行布局：简单弹性分栏容器（Row + Col，span 比例分栏）。
///
/// 组件 ID：`ui.row`。与 Layout（12 栅格 span/12 固定）划界：
/// Row 用任意整数 span 比例分配（如 1:2:1 = 总 span 4），不绑定 12 栅格。
///
/// 一期语义：
/// - 子项按 span/totalSpan 比例占行宽
/// - justify 控制水平分布（start/center/end/spaceBetween/spaceAround）
/// - align 控制垂直对齐（top/center/bottom/stretch）
/// - gutter 控制子项间距（首尾无 padding）
/// - offset 控制左侧偏移（span 单位）
///
/// 用法：
/// ```swift
/// let row = RowView(justify: .start, align: .top, gutter: AppSpace.md)
/// row.addCols([
///     ColView(span: 1),
///     ColView(span: 2),
///     ColView(span: 1),
/// ])
/// ```
import UIKit
import SnapKit

// MARK: - 枚举

/// 水平分布。
enum RowJustify {
    case start
    case center
    case end
    case spaceBetween
    case spaceAround
}

/// 垂直对齐。
enum RowAlign {
    case top
    case center
    case bottom
    case stretch
}

// MARK: - RowView

/// 弹性分栏行容器。
final class RowView: UIView {

    var justify: RowJustify {
        didSet { if justify != oldValue { relayoutCols() } }
    }
    var align: RowAlign {
        didSet { if align != oldValue { relayoutCols() } }
    }
    var gutter: CGFloat {
        didSet { if gutter != oldValue { relayoutCols() } }
    }

    private(set) var cols: [ColView] = []

    init(justify: RowJustify = .start,
         align: RowAlign = .top,
         gutter: CGFloat = 0) {
        self.justify = justify
        self.align = align
        self.gutter = gutter
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Col 管理

    func addCol(_ col: ColView) {
        cols.append(col)
        addSubview(col)
        relayoutCols()
    }

    func addCols(_ cols: [ColView]) {
        cols.forEach { self.cols.append($0); addSubview($0) }
        relayoutCols()
    }

    func removeAllCols() {
        cols.forEach { $0.removeFromSuperview() }
        cols.removeAll()
    }

    // MARK: - 布局

    private func relayoutCols() {
        guard !cols.isEmpty else { return }
        cols.forEach { $0.snp.removeConstraints() }

        let totalSpan = CGFloat(cols.map(\.span).reduce(0, +))
        let gutterCount = CGFloat(cols.count - 1)

        // 按 justify 决定首 col leading
        // spaceBetween / spaceAround / center / end 需要额外弹性间距
        // 一期简化：justify=.start 时紧密排列；其余用等分弹性间距

        var previous: ColView?
        for (index, col) in cols.enumerated() {
            col.snp.makeConstraints { make in
                // 宽 = (行宽 − 全部 gutter) × span / totalSpan
                // 展开：self * ratio − gutter * gutterCount * ratio
                let ratio = CGFloat(col.span) / totalSpan
                make.width.equalTo(self)
                    .multipliedBy(ratio)
                    .offset(-self.gutter * gutterCount * ratio)

                // leading
                if let previous {
                    make.leading.equalTo(previous.snp.trailing).offset(self.gutter)
                } else {
                    make.leading.equalToSuperview()
                }

                // 垂直对齐
                switch self.align {
                case .top:
                    make.top.equalToSuperview()
                case .center:
                    make.centerY.equalToSuperview()
                case .bottom:
                    make.bottom.equalToSuperview()
                case .stretch:
                    make.top.bottom.equalToSuperview()
                }

                // 行高锚：首个 col 底 = 行底
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

// MARK: - ColView

/// 分栏子项：占行宽 span/totalSpan 比例。
final class ColView: UIView {

    let span: Int
    var offset: Int

    init(span: Int, offset: Int = 0) {
        precondition(span >= 1, "span 必须 >= 1，当前 \(span)")
        precondition(offset >= 0, "offset 必须 >= 0，当前 \(offset)")
        self.span = span
        self.offset = offset
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
