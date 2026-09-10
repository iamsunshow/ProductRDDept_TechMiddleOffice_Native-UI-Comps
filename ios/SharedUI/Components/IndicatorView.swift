/// Indicator 指示器组件（UIKit 版，对齐 Android Indicator）。
///
/// 页面位置指示器——圆点/数字形态标记当前页与总页数，用于轮播、引导页、分步表单等场景的位置感知。
/// current/total 驱动高亮位置，direction 控制横向/竖向排布，showNumber 切数字形态，
/// block 开长条选中态，color/activeColor/size/gap 自定义视觉。
///
/// 用法：
/// ```swift
/// let indicator = IndicatorView()
/// indicator.current = 1
/// indicator.total = 5
/// // 数字形态：indicator.showNumber = true
/// // 竖向：indicator.direction = .vertical
/// // 长条选中：indicator.block = true
/// ```
///
/// 决策（与设计规格 indicator-design-spec.html 一致）：
/// - P1-A showNumber 布尔切换圆点/数字两形态
/// - P2-C block 开关同时支持色变+长条（false=色变，true=长条）
/// - P3-B 横向+竖向 direction 参数
/// - P4-A 一期=圆点/数字+横向/竖向+block长条+自定义色/大小/间距+demo四段

import UIKit
import SnapKit

/// 指示器排布方向。
enum IndicatorDirection {
    case horizontal
    case vertical
}

final class IndicatorView: UIView {
    // MARK: - 配置属性

    /// 当前页索引（从 0 开始），高亮第 current 个点。
    var current: Int = 0 { didSet { rebuild() } }

    /// 总页数（渲染 total 个点）；total≤0 不渲染。
    var total: Int = 0 { didSet { rebuild() } }

    /// 排布方向：horizontal 横向 / vertical 竖向。
    var direction: IndicatorDirection = .horizontal { didSet { rebuild() } }

    /// 数字形态：true 显示「current+1/total」胶囊，false 显示圆点序列。
    var showNumber: Bool = false { didSet { rebuild() } }

    /// 选中态长条形态：true 选中点变长条，false 选中点仅色变。
    var block: Bool = false { didSet { rebuild() } }

    /// 指示点直径/边长（pt），数字形态忽略。
    var size: CGFloat = 6 { didSet { rebuild() } }

    /// 指示点间距（pt），数字形态忽略。
    var gap: CGFloat = 8 { didSet { rebuild() } }

    /// 未选中点颜色。
    var color: UIColor = AppColor.gray15 { didSet { applyColors() } }

    /// 选中点颜色。
    var activeColor: UIColor = AppColor.primary { didSet { applyColors() } }

    // MARK: - 内部状态

    /// 圆点容器（UIStackView，axis 随 direction 变化）。
    private let dotStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        return stack
    }()

    /// 数字胶囊（showNumber=true 时显示）。
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        label.textColor = AppColor.bgCard
        label.textAlignment = .center
        return label
    }()

    /// 数字胶囊背景容器。
    private lazy var numberContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.primary
        return view
    }()

    /// 当前圆点视图数组（用于 applyColors 刷新色）。
    private var dots: [UIView] = []

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("IndicatorView does not support NSCoder")
    }

    private func setup() {
        addSubview(dotStack)
        dotStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 重建布局

    /// 全量重建：清空容器并按 current/total/direction/showNumber/block 重新生成。
    private func rebuild() {
        // 清空旧内容。
        dotStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dotStack.subviews.forEach { $0.removeFromSuperview() }
        numberContainer.removeFromSuperview()
        dots = []

        // total≤0 不渲染。
        guard total > 0 else { return }

        if showNumber {
            // 数字形态：显示「current+1/total」胶囊。
            let safeCurrent = min(max(current, 0), total - 1)
            numberLabel.text = "\(safeCurrent + 1) / \(total)"
            numberContainer.backgroundColor = activeColor
            numberContainer.addSubview(numberLabel)
            numberContainer.layer.cornerRadius = 10
            numberContainer.clipsToBounds = true
            addSubview(numberContainer)
            numberLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
            }
            numberContainer.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            return
        }

        // 圆点形态：UIStackView 按 direction 排布。
        dotStack.axis = (direction == .horizontal) ? .horizontal : .vertical
        dotStack.spacing = gap

        for index in 0..<total {
            let dot = UIView()
            let isActive = (index == current)
            if isActive && block {
                // 长条选中态：宽=size*2.5，圆角=size/3。
                dot.backgroundColor = activeColor
                dot.layer.cornerRadius = size / 3
                dotStack.addArrangedSubview(dot)
                dot.snp.makeConstraints { make in
                    make.width.equalTo(size * 2.5)
                    make.height.equalTo(size)
                }
            } else {
                // 圆点：size×size，全圆角。
                dot.backgroundColor = isActive ? activeColor : color
                dot.layer.cornerRadius = size / 2
                dotStack.addArrangedSubview(dot)
                dot.snp.makeConstraints { make in
                    make.width.height.equalTo(size)
                }
            }
            dots.append(dot)
        }
    }

    // MARK: - 颜色刷新

    /// 仅刷新圆点颜色（color/activeColor 变化时，无需重建布局）。
    private func applyColors() {
        for (index, dot) in dots.enumerated() {
            dot.backgroundColor = (index == current) ? activeColor : color
        }
        numberContainer.backgroundColor = activeColor
    }
}
