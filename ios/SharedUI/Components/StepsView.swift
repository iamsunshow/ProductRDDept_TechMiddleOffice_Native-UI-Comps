/// Steps 步骤条组件（UIKit 版，对齐 Android Steps）。
///
/// 展示含多个步骤的流程进度——已完成步骤打勾、当前步骤高亮、未到达步骤置灰，
/// 横向或竖向排列。数据驱动 items 数组（每项 title+desc+可选 icon），
/// current 控制当前步骤索引（-1=内部自管理初始 0，≥0=受控），
/// direction 切换横向/竖向，已完成步骤显示对勾并把连线染主色，
/// 当前步骤主色描边高亮，未开始步骤灰色置灰，支持点击已完成步骤回退（onChange）。
///
/// 用法：
/// ```swift
/// let steps = StepsView()
/// steps.items = [
///     StepsItem(title: "已完成", desc: "步骤一"),
///     StepsItem(title: "进行中", desc: "步骤二"),
///     StepsItem(title: "未开始", desc: "步骤三"),
/// ]
/// steps.current = 1   // 当前第 2 步（0-based）
/// steps.direction = .horizontal
/// ```
///
/// 决策（与设计规格 steps-design-spec.html 一致）：
/// - P1-C 混合受控：current=-1=内部自管理，≥0=受控
/// - P2-B 一期可点击已完成步骤回退（onChange 回调），未开始/当前不可点击
/// - P3-A 默认已完成=对勾，当前/未开始=数字；icon 字段可覆盖为自定义图标
/// - P4-A 一期=基础步骤条/横向+竖向/当前步骤高亮/自定义图标+demo 四段

import UIKit
import SnapKit

/// 步骤条方向。
enum StepsDirection {
    case horizontal
    case vertical
}

/// 单个步骤数据。
struct StepsItem {
    let title: String
    let desc: String?
    /// 自定义图标名（SF Symbol 名）；nil=默认数字/对勾。
    let icon: String?

    init(title: String, desc: String? = nil, icon: String? = nil) {
        self.title = title
        self.desc = desc
        self.icon = icon
    }
}

/// 步骤状态（由 current 推导）。
private enum StepState {
    case finished   // index < current
    case active     // index == current
    case inactive   // index > current
}

final class StepsView: UIView {
    // MARK: - 配置属性

    /// 步骤数据数组。设置后重建布局。
    var items: [StepsItem] = [] { didSet { rebuild() } }

    /// 当前步骤索引（0-based）；-1=内部自管理状态（初始 0），≥0=受控。
    var current: Int = -1 {
        didSet {
            if current >= 0 { internalCurrent = current }
            applyState()
        }
    }

    /// 步骤条方向：横向/竖向。
    var direction: StepsDirection = .horizontal { didSet { rebuild() } }

    /// 步骤切换回调（点击已完成步骤回退时触发，返回目标索引）。
    var onChange: ((Int) -> Void)?

    // MARK: - 内部状态

    /// 内部自管理当前步骤（current==-1 时生效）。
    private var internalCurrent: Int = 0

    /// 当前有效步骤索引（受控优先，否则内部）。
    private var effectiveCurrent: Int {
        current >= 0 ? current : internalCurrent
    }

    /// 步骤圆点尺寸（24×24）。
    private let circleSize: CGFloat = 24

    /// 主容器栈。
    private let containerStack: UIStackView = {
        let s = UIStackView()
        s.alignment = .fill
        return s
    }()

    /// 每个步骤的视图句柄，按 items 索引对齐。
    private var stepViews: [(circle: UIView, content: UILabel, title: UILabel, line: UIView, tap: UIView)] = []

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("StepsView does not support NSCoder")
    }

    private func setup() {
        addSubview(containerStack)
        containerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 重建布局

    /// 全量重建：清空容器并按 items + direction 重新生成步骤。
    private func rebuild() {
        containerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stepViews = []

        containerStack.axis = (direction == .horizontal) ? .horizontal : .vertical
        containerStack.distribution = (direction == .horizontal) ? .fillEqually : .fill
        containerStack.spacing = 0

        for (index, item) in items.enumerated() {
            let step = makeStep(index: index, item: item)
            containerStack.addArrangedSubview(step.container)
            stepViews.append((circle: step.circle, content: step.content, title: step.title, line: step.line, tap: step.tap))
        }
        applyState()
    }

    /// 构造单个步骤视图。
    private func makeStep(index: Int, item: StepsItem) -> (container: UIView, circle: UIView, content: UILabel, title: UILabel, line: UIView, tap: UIView) {
        let container = UIView()

        // 圆点
        let circle = UIView()
        circle.layer.cornerRadius = circleSize / 2
        circle.clipsToBounds = true
        circle.isUserInteractionEnabled = false
        container.addSubview(circle)

        // 圆点内容（数字或对勾；自定义图标时隐藏）
        let content = UILabel()
        content.textAlignment = .center
        content.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        circle.addSubview(content)

        // 标题
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        titleLabel.textAlignment = (direction == .horizontal) ? .center : .left
        titleLabel.numberOfLines = 1

        // 描述
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = AppSpace.xs
        textStack.alignment = (direction == .horizontal) ? .center : .leading
        textStack.addArrangedSubview(titleLabel)

        if let desc = item.desc {
            let descLabel = UILabel()
            descLabel.text = desc
            descLabel.font = .systemFont(ofSize: AppFont.sizeXs)
            descLabel.textColor = AppColor.textSecondary
            descLabel.textAlignment = (direction == .horizontal) ? .center : .left
            descLabel.numberOfLines = 0
            textStack.addArrangedSubview(descLabel)
        }
        container.addSubview(textStack)

        // 连线（非末项）
        let line = UIView()
        container.addSubview(line)

        // 点击区域（覆盖圆点附近，仅已完成步骤可点）
        let tap = UIView()
        tap.tag = index
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleStepTap(_:)))
        tap.addGestureRecognizer(gesture)
        container.addSubview(tap)

        if direction == .horizontal {
            // 横向：圆点顶部居中，文字在下方，连线从圆右到容器右。
            circle.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.height.equalTo(circleSize)
            }
            content.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            textStack.snp.makeConstraints { make in
                make.top.equalTo(circle.snp.bottom).offset(AppSpace.sm)
                make.leading.trailing.equalToSuperview().inset(AppSpace.xs)
                make.bottom.lessThanOrEqualToSuperview()
            }
            line.snp.makeConstraints { make in
                make.centerY.equalTo(circle)
                make.leading.equalTo(circle.snp.trailing)
                make.trailing.equalToSuperview()
                make.height.equalTo(1)
            }
            tap.snp.makeConstraints { make in
                make.center.equalTo(circle)
                make.width.height.equalTo(circleSize + AppSpace.md)
            }
        } else {
            // 竖向：圆点左上，文字在右，连线从圆下到容器底。
            circle.snp.makeConstraints { make in
                make.top.leading.equalToSuperview()
                make.width.height.equalTo(circleSize)
            }
            content.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            textStack.snp.makeConstraints { make in
                make.top.equalTo(circle).offset(-2)
                make.leading.equalTo(circle.snp.trailing).offset(AppSpace.md)
                make.trailing.equalToSuperview()
                make.bottom.lessThanOrEqualToSuperview()
            }
            line.snp.makeConstraints { make in
                make.centerX.equalTo(circle)
                make.top.equalTo(circle.snp.bottom)
                make.bottom.equalToSuperview()
                make.width.equalTo(1)
            }
            tap.snp.makeConstraints { make in
                make.center.equalTo(circle)
                make.width.height.equalTo(circleSize + AppSpace.md)
            }
        }

        return (container: container, circle: circle, content: content, title: titleLabel, line: line, tap: tap)
    }

    // MARK: - 点击处理

    /// 点击步骤：仅已完成步骤（index < effectiveCurrent）可回退。
    @objc private func handleStepTap(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index >= 0, index < items.count else { return }
        let cur = effectiveCurrent
        guard index < cur else { return } // 只能回退到已完成步骤
        if current < 0 {
            internalCurrent = index
        }
        onChange?(index)
        applyState()
    }

    // MARK: - 状态应用

    /// 按 effectiveCurrent 同步每步视觉态。
    private func applyState() {
        let cur = effectiveCurrent
        for (index, item) in items.enumerated() {
            guard index < stepViews.count else { continue }
            let view = stepViews[index]
            let state: StepState
            if index < cur { state = .finished }
            else if index == cur { state = .active }
            else { state = .inactive }

            // 圆点样式
            switch state {
            case .finished:
                view.circle.backgroundColor = AppColor.primary
                view.circle.layer.borderWidth = 0
            case .active:
                view.circle.backgroundColor = AppColor.bgCard
                view.circle.layer.borderWidth = 2
                view.circle.layer.borderColor = AppColor.primary.cgColor
            case .inactive:
                view.circle.backgroundColor = AppColor.bgCard
                view.circle.layer.borderWidth = 1
                view.circle.layer.borderColor = AppColor.gray6.cgColor
            }

            // 圆点内容：自定义图标 > 对勾(完成) > 数字
            if let iconName = item.icon {
                view.content.text = nil
                // 用 SF Symbol 图标
                if let existing = view.circle.viewWithTag(999) as? UIImageView {
                    existing.removeFromSuperview()
                }
                let iv = UIImageView(image: UIImage(systemName: iconName))
                iv.tag = 999
                iv.tintColor = (state == .finished) ? .white : (state == .active ? AppColor.primary : AppColor.gray25)
                iv.contentMode = .scaleAspectFit
                view.circle.addSubview(iv)
                iv.snp.remakeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(circleSize * 0.6)
                }
            } else {
                // 清除可能存在的图标
                view.circle.viewWithTag(999)?.removeFromSuperview()
                if state == .finished {
                    view.content.text = "✓"
                    view.content.textColor = .white
                } else {
                    view.content.text = "\(index + 1)"
                    view.content.textColor = (state == .active) ? AppColor.primary : AppColor.gray25
                }
            }

            // 标题颜色：已完成/当前=textPrimary，未开始=textSecondary
            view.title.textColor = (state == .inactive) ? AppColor.textSecondary : AppColor.textPrimary

            // 连线颜色：index < cur 则本段为已完成（主色），否则灰色。
            // 末项无连线（line 被隐藏）。
            let isLast = index == items.count - 1
            view.line.isHidden = isLast
            if !isLast {
                view.line.backgroundColor = (index < cur) ? AppColor.primary : AppColor.gray6
            }

            // 可点击性：仅已完成步骤可点
            view.tap.isUserInteractionEnabled = (index < cur)
        }
    }
}
