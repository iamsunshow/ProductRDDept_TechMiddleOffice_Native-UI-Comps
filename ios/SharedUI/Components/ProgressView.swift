/// Progress 进度条组件（UIKit 版，对齐 Android Progress）。
///
/// 展示操作当前进度的横向进度条——一条带填充色的横向轨道，填充宽度按百分比（0-100）自适应，
/// 支持自定义填充色/轨道色/高度、右侧百分比文字显示、动态进度变化过渡动画。
///
/// 用法：
/// ```swift
/// let progress = ProgressView(percentage: 30)
/// // 或
/// let progress = ProgressView()
/// progress.percentage = 75
/// progress.showText = true
/// ```
///
/// 决策（与设计规格 progress-design-spec.html 一致）：
/// - P1-A percentage 0-100 clamp（越界自动钳制，UI 不溢出）
/// - P2-C animated 参数开关，默认 true（0.3s ease 过渡动画），false 瞬切
/// - P3-A 百分比文字右侧外部显示（showText 开关，文字不被条遮挡）
/// - P4-A 一期=基础进度/自定义颜色+高度/百分比文字/动态进度+demo 四段
///
/// 视觉：轨道(trackView) gray6 圆角(height/2) + 填充条(barView) color 圆角(height/2)；
/// showText=true 时右侧 UILabel 显示「xx%」（sizeSm/textPrimary），与条间距 AppSpace.sm。

import UIKit
import SnapKit

/// 横向进度条视图。
final class ProgressView: UIView {
    // MARK: - 配置属性

    /// 进度百分比（0-100，越界自动 clamp）。
    var percentage: Double = 0 {
        didSet { updateBar(animated: animated) }
    }

    /// 进度条填充色，默认 primary 主色绿。
    var color: UIColor = AppColor.primary {
        didSet { barView.backgroundColor = color }
    }

    /// 轨道底色，默认 gray6 灰。
    var trackColor: UIColor = AppColor.gray6 {
        didSet { trackView.backgroundColor = trackColor }
    }

    /// 进度条高度，默认 8。
    var height: CGFloat = 8 {
        didSet {
            trackView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            let radius = height / 2
            trackView.layer.cornerRadius = radius
            barView.layer.cornerRadius = radius
        }
    }

    /// 是否显示右侧百分比文字，默认 false。
    var showText: Bool = false {
        didSet { updateTextVisibility() }
    }

    /// 百分比文字颜色，默认 textPrimary。
    var textColor: UIColor = AppColor.textPrimary {
        didSet { textLabel.textColor = textColor }
    }

    /// 进度变化是否带过渡动画（0.3s ease），默认 true。
    var animated: Bool = true

    // MARK: - 子视图

    /// 横向容器：轨道 + 可选文字。
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = AppSpace.sm
        return stack
    }()

    /// 轨道（底层灰条）。
    private let trackView = UIView()

    /// 填充条（上层彩条，宽度按百分比）。
    private let barView = UIView()

    /// 右侧百分比文字。
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    /// 填充条宽度约束（按百分比更新）。
    private var barWidthConstraint: Constraint?

    // MARK: - 初始化

    init(percentage: Double = 0) {
        self.percentage = percentage
        super.init(frame: .zero)
        setup()
        // init 中赋值不触发 didSet，手动同步一次。
        updateBar(animated: false)
        updateTextVisibility()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("ProgressView does not support NSCoder")
    }

    // MARK: - 布局

    private func setup() {
        addSubview(containerStack)
        containerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 轨道
        trackView.backgroundColor = trackColor
        trackView.layer.cornerRadius = height / 2
        trackView.clipsToBounds = true
        containerStack.addArrangedSubview(trackView)
        trackView.snp.makeConstraints { make in
            make.height.equalTo(height)
        }

        // 填充条（置于轨道内部，宽度由百分比驱动）
        barView.backgroundColor = color
        barView.layer.cornerRadius = height / 2
        trackView.addSubview(barView)
        barView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            barWidthConstraint = make.width.equalToSuperview().multipliedBy(clampedPercentage / 100.0).constraint
        }

        // 文字（默认隐藏）
        containerStack.addArrangedSubview(textLabel)
    }

    /// 透传固有尺寸：高度=max(height, 文字行高)，宽度由外部决定（无固有宽度）。
    override var intrinsicContentSize: CGSize {
        let h = max(height, textLabel.font.lineHeight)
        return CGSize(width: UIView.noIntrinsicMetric, height: h)
    }

    // MARK: - 状态更新

    /// clamp 后的百分比（0-100）。
    private var clampedPercentage: Double {
        min(max(percentage, 0), 100)
    }

    /// 更新填充条宽度，animated=true 时走 0.3s 过渡动画。
    private func updateBar(animated: Bool) {
        let ratio = clampedPercentage / 100.0
        // 重新安装宽度约束：multipliedBy 不可增量改，故卸载旧约束重建。
        barWidthConstraint?.deactivate()
        barView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            barWidthConstraint = make.width.equalToSuperview().multipliedBy(ratio).constraint
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
        textLabel.text = "\(Int(clampedPercentage.rounded()))%"
    }

    /// 文字显隐：showText=true 显示，否则从 arrangedSubviews 移除（UIStackView 自动收起空间）。
    private func updateTextVisibility() {
        if showText {
            if textLabel.superview == nil {
                containerStack.addArrangedSubview(textLabel)
            }
            textLabel.isHidden = false
        } else {
            textLabel.isHidden = true
        }
    }
}
