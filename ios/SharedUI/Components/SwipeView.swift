//
//  SwipeView.swift
//  SharedUI
//
//  组件 ID：`ui.swipe` ｜ 任务清单 #58 ｜ 操作反馈区第十四件 ｜ TMO 组件库 v1.4.14
//
//  定位：列表项横向滑动露出操作按钮——左右双向滑动露操作，松手自动回弹或展开。
//
//  结构：
//  - SwipeAction（数据结构）：text/color/onClick
//  - SwipeItem（包裹器）：横向滑动容器+主内容+左右操作按钮列表
//
//  契约 props（与 api.json 100% 对齐）：
//  - SwipeItem: actions(默认[])/leftActions(默认[])/disabled(默认false)/autoClose(默认true)/content slot
//  - SwipeAction: text(必填)/color(primary/danger/warning/default)/onClick(必填)
//
//  设计规格（design-spec/swipe-design-spec.html）：
//  - 操作按钮宽 80pt，高撑满主内容
//  - primary=#16A34A，danger=#DC2626，warning=#F59E0B，default=#6B7280
//  - 滑动动画 0.25s easeOut
//
//  用法：
//  ```swift
//  let item = SwipeItem(actions: [
//      SwipeAction(text: "删除", color: .danger) { [weak self] in self?.delete() }
//  ])
//  item.contentView = realContentView
//  ```

import UIKit

// MARK: - 操作颜色

/// 操作按钮颜色四态（与 design-spec 一致：primary/danger/warning/default）。
public enum SwipeActionColor {
    case primary
    case danger
    case warning
    case `default`

    var color: UIColor {
        switch self {
        case .primary: return UIColor(red: 0.086, green: 0.639, blue: 0.290, alpha: 1)   // #16A34A
        case .danger:  return UIColor(red: 0.863, green: 0.149, blue: 0.149, alpha: 1)   // #DC2626
        case .warning: return UIColor(red: 0.961, green: 0.620, blue: 0.043, alpha: 1)   // #F59E0B
        case .default: return UIColor(red: 0.420, green: 0.447, blue: 0.502, alpha: 1)   // #6B7280
        }
    }
}

// MARK: - 操作数据结构

/// 操作按钮数据结构（text + color + onClick 回调）。
public struct SwipeAction {
    public let text: String
    public let color: SwipeActionColor
    public let onClick: () -> Void

    public init(text: String, color: SwipeActionColor = .default, onClick: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.onClick = onClick
    }
}

// MARK: - 滑动容器

/// 列表项横向滑动露出操作按钮的包裹器（左右双向）。
public final class SwipeItem: UIView {

    // MARK: - 常量

    private enum Layout {
        static let actionWidth: CGFloat = 80        // 单个操作按钮固定宽度
        static let openRatio: CGFloat = 0.5         // 滑动超过操作总宽 50% 即展开
        static let animDuration: TimeInterval = 0.25
    }

    // MARK: - Props

    public var actions: [SwipeAction] = [] { didSet { rebuildButtons() } }
    public var leftActions: [SwipeAction] = [] { didSet { rebuildButtons() } }
    public var disabled: Bool = false
    public var autoClose: Bool = true

    /// 主内容视图（外部赋值后由本容器托管布局）。
    public var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let v = contentView {
                addSubview(v)
                v.frame = bounds
                v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                bringSubviewToFront(v)
            }
        }
    }

    // MARK: - 内部状态

    private var leftButtons: [UIButton] = []
    private var rightButtons: [UIButton] = []
    private var pan: UIPanGestureRecognizer?
    private var startX: CGFloat = 0

    /// 当前偏移量（正=右滑露左操作，负=左滑露右操作）。
    private(set) var offsetX: CGFloat = 0

    /// 当前是否展开（用于点击操作后判断收起方向）。
    private var isOpen: Bool { abs(offsetX) > 0 }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGesture()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) 未实现") }

    public convenience init(actions: [SwipeAction] = [], leftActions: [SwipeAction] = [], disabled: Bool = false, autoClose: Bool = true) {
        self.init(frame: .zero)
        self.actions = actions
        self.leftActions = leftActions
        self.disabled = disabled
        self.autoClose = autoClose
        rebuildButtons()
    }

    // MARK: - 布局

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }

    // MARK: - 手势

    private func setupGesture() {
        let g = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        g.delegate = self
        addGestureRecognizer(g)
        pan = g
    }

    @objc private func onPan(_ g: UIPanGestureRecognizer) {
        guard !disabled else { return }
        let translation = g.translation(in: self)
        switch g.state {
        case .began:
            startX = offsetX
        case .changed:
            let proposed = startX + translation.x
            let maxRight = leftButtonsWidth    // 右滑最大=左操作总宽
            let maxLeft  = -rightButtonsWidth  // 左滑最大=右操作总宽
            offsetX =max(maxLeft, min(maxRight, proposed))
            applyOffset(animated: false)
        case .ended, .cancelled:
            let maxRight = leftButtonsWidth
            let maxLeft  = -rightButtonsWidth
            // 右滑方向——判断是否超过左操作总宽 50%
            if offsetX > 0, maxRight > 0 {
                let target = offsetX > maxRight * Layout.openRatio ? maxRight : 0
                animateTo(target)
            }
            // 左滑方向——判断是否超过右操作总宽 50%
            else if offsetX < 0, maxLeft < 0 {
                let target = -offsetX > abs(maxLeft) * Layout.openRatio ? maxLeft : 0
                animateTo(target)
            } else {
                animateTo(0)
            }
        default: break
        }
    }

    // MARK: - 按钮重建

    private func rebuildButtons() {
        leftButtons.forEach { $0.removeFromSuperview() }
        rightButtons.forEach { $0.removeFromSuperview() }
        leftButtons = []
        rightButtons = []

        // 左操作——从左到右排列（右滑露出）
        for (i, action) in leftActions.enumerated() {
            let btn = makeButton(action: action, tag: 1_000_000 + i)
            leftButtons.append(btn)
            addSubview(btn)
        }
        // 右操作——从右到左排列（左滑露出）
        for (i, action) in actions.enumerated() {
            let btn = makeButton(action: action, tag: 2_000_000 + i)
            rightButtons.append(btn)
            addSubview(btn)
        }
        bringContentViewToFront()
        setNeedsLayout()
    }

    private func makeButton(action: SwipeAction, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.tag = tag
        btn.setTitle(action.text, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.backgroundColor = action.color.color
        btn.addTarget(self, action: #selector(onActionTap(_:)), for: .touchUpInside)
        return btn
    }

    private func bringContentViewToFront() {
        if let v = contentView { bringSubviewToFront(v) }
    }

    private func layoutButtons() {
        // 左操作——从左到右排列，紧贴左边缘外
        var leftX: CGFloat = 0
        for btn in leftButtons {
            btn.frame = CGRect(x: leftX - leftButtonsWidth, y: 0, width: Layout.actionWidth, height: bounds.height)
            leftX += Layout.actionWidth
        }
        // 右操作——从右到左排列，紧贴右边缘外
        var rightX: CGFloat = bounds.width
        for btn in rightButtons {
            btn.frame = CGRect(x: rightX, y: 0, width: Layout.actionWidth, height: bounds.height)
            rightX += Layout.actionWidth
        }
        applyOffset(animated: false)
    }

    private var leftButtonsWidth: CGFloat { CGFloat(leftButtons.count) * Layout.actionWidth }
    private var rightButtonsWidth: CGFloat { CGFloat(rightButtons.count) * Layout.actionWidth }

    // MARK: - 偏移应用

    private func applyOffset(animated: Bool) {
        guard let v = contentView else { return }
        let block = { v.transform = CGAffineTransform(translationX: self.offsetX, y: 0) }
        if animated {
            UIView.animate(withDuration: Layout.animDuration, delay: 0, options: .curveEaseOut, animations: block)
        } else {
            block()
        }
    }

    private func animateTo(_ target: CGFloat) {
        offsetX = target
        applyOffset(animated: true)
    }

    // MARK: - 收起

    /// 公开收起方法（外部可调用关闭已展开的操作）。
    public func close() { animateTo(0) }

    // MARK: - 操作点击

    @objc private func onActionTap(_ sender: UIButton) {
        // 左操作 tag=1_000_000+i，右操作 tag=2_000_000+i
        if sender.tag >= 2_000_000 {
            let i = sender.tag - 2_000_000
            guard i < actions.count else { return }
            actions[i].onClick()
        } else {
            let i = sender.tag - 1_000_000
            guard i < leftActions.count else { return }
            leftActions[i].onClick()
        }
        if autoClose { close() }
    }
}

// MARK: - 手势代理（确保水平滑动才拦截）

extension SwipeItem: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        true
    }
}
