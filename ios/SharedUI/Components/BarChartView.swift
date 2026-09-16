// BarChart 条形图（业务展示区 · ui.bar-chart · #97）通用横向条形图组件。
//
// 组件 ID：`ui.bar-chart`（api.json 待门禁 B 立项登记；门禁 A AI 代评通过 2026-09-16，
// 规格 docs/数据与产物/design-spec/bar-chart-design-spec.html + 评审单
// docs/评审记录/review-bar-chart-A.md，P1–P4 全 A）。
//
// 视觉锚点（与 Android BarChart 同构）：横向条形图 = 白底 bgCard + 行高 24pt + 类别标签
// 64pt 宽 sizeXs=12 textSecondary 右对齐 + 轨道 16pt 高 bgGrayLight=F3F4F6 灰底 +
// 填充按比例 = (value/maxValue) × 轨道宽 + 圆角 4dp（strokeCap=Round）+ 数值标签
// 48pt 宽 sizeSm=14 Semibold textPrimary 左对齐 + 阈值三态颜色（primary 16A34A /
// warning F59E0B ≥0.8 / error DC2626 ≥1.0）+ 0.3s ease-out 过渡。
//
// 划界勿混：#96 LineChart 折线 / #74 Progress 横条进度 / #83 ProgressCircle 圆环 /
// #72 Price 静态排版。
import UIKit
import SnapKit

/// 条形图条目（label/value 一对一）。
public struct BarChartItem {
    public let label: String
    public let value: CGFloat

    public init(label: String, value: CGFloat) {
        self.label = label
        self.value = max(0, value)
    }
}

/// 横向条形图（数据驱动 + 阈值三态颜色 + 0.3s 过渡）。
///
/// 支持：
/// - `items` 条目列表（label/value）
/// - `warnThreshold` warning 阈值（默认 0.8；value/maxValue ≥ warnThreshold 显示 warning）
/// - `dangerThreshold` error 阈值（默认 1.0；≥ 1.0 显示 error）
/// - `maxValue` 自定义 max（默认 = max(items.value)）
public final class BarChartView: UIView {

    /// 数据条目。
    public var items: [BarChartItem] = [] {
        didSet { rebuild() }
    }

    /// warning 阈值（默认 0.8）。
    public var warnThreshold: CGFloat = 0.8

    /// error 阈值（默认 1.0）。
    public var dangerThreshold: CGFloat = 1.0

    /// 自定义 max（默认 = max(items.value)）。
    public var maxValue: CGFloat?

    private let stack = UIStackView()
    private var rowViews: [BarChartRowView] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupStack()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func setupStack() {
        stack.axis = .vertical
        stack.spacing = AppSpace.md
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func rebuild() {
        // 清旧
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowViews.removeAll()
        guard !items.isEmpty else { return }
        // 计算 max
        let m = maxValue ?? items.map(\.value).max() ?? 1
        // 构建行
        for item in items {
            let row = BarChartRowView()
            row.configure(
                label: item.label,
                value: item.value,
                maxValue: m,
                warnThreshold: warnThreshold,
                dangerThreshold: dangerThreshold
            )
            stack.addArrangedSubview(row)
            rowViews.append(row)
        }
    }
}

/// 单行条形（label + 轨道 + 数值）。
private final class BarChartRowView: UIView {

    private let labelView = UILabel()
    private let trackView = UIView()
    private let fillView = UIView()
    private let valueView = UILabel()
    private var fillWidthConstraint: Constraint?

    func configure(label: String, value: CGFloat, maxValue: CGFloat, warnThreshold: CGFloat, dangerThreshold: CGFloat) {
        // label（64pt 宽 sizeXs=12 textSecondary 右对齐）
        labelView.text = label
        labelView.font = .systemFont(ofSize: AppFont.sizeXs)
        labelView.textColor = AppColor.textSecondary
        labelView.textAlignment = .right
        labelView.numberOfLines = 1
        // value（48pt 宽 sizeSm=14 Semibold textPrimary 左对齐）
        valueView.text = "¥\(Int(value))"
        valueView.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        valueView.textColor = AppColor.textPrimary
        valueView.textAlignment = .left
        // 轨道（bgGrayLight=F3F4F6 灰底铺满 + 圆角 4pt）
        trackView.backgroundColor = AppColor.bgGrayLight
        trackView.layer.cornerRadius = 4
        trackView.clipsToBounds = true
        // 填充（初始 0，动画到目标）
        fillView.layer.cornerRadius = 4
        addSubview(labelView)
        addSubview(trackView)
        addSubview(valueView)
        trackView.addSubview(fillView)
        // 布局
        snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        labelView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(64)
        }
        trackView.snp.makeConstraints { make in
            make.leading.equalTo(labelView.snp.trailing).offset(AppSpace.sm)
            make.trailing.equalTo(valueView.snp.leading).offset(-AppSpace.sm)
            make.height.equalTo(16)
            make.centerY.equalToSuperview()
        }
        valueView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(48)
        }
        // 填充颜色（按比例阈值）
        let ratio = maxValue > 0 ? min(1.0, value / maxValue) : 0
        let fillColor: UIColor
        if ratio >= dangerThreshold {
            fillColor = AppColor.error
        } else if ratio >= warnThreshold {
            fillColor = AppColor.warning
        } else {
            fillColor = AppColor.primary
        }
        fillView.backgroundColor = fillColor
        // 初始填充宽度 0
        fillView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            self.fillWidthConstraint = make.width.equalToSuperview().multipliedBy(0).constraint
        }
        // 0.3s ease-out 过渡到目标宽度
        DispatchQueue.main.async {
            self.fillWidthConstraint?.update(offset: 0)
            self.layoutIfNeeded()
            self.fillWidthConstraint?.deactivate()
            fillView.snp.remakeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(ratio)
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                self.layoutIfNeeded()
            }
        }
    }
}