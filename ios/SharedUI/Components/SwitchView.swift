/// Switch 开关（数据录入区 · ui.switch · #41）通用二元即时开关核组件。
///
/// 组件 ID：`ui.switch`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/switch-design-spec.html + 评审单 review-switch-A.md，P1–P4 全 A）。
///
/// 视觉锚点（与 Android Switch 同构）：轨道 48×28 radiusFull——on=primary 填充 + 白色滑块居右；
/// off=textSecondary(alpha 0.3) 浅灰填充 + 白色滑块居左；滑块 20pt 白色圆（=CheckboxGlyph/RadioGlyph
/// 20 惯例），轨内上下左右内衬 4（spaceXs），行程 20=48−2×4−20；切换动画 0.18s（滑块位移 + 轨道变色）。
///
/// 语义：checked `Bool?` 半受控——nil=内部自持初始 off（点按翻转并回调）；外部赋值 checked=同步回显
/// （不触发 onChange）；on→off 与 off→on 均回调 `onChange(newValue)`。
/// disabled：整件 40% 灰不可点无回调；on+disabled=灰 primary 轨道灰滑块保留开态（只读回显）。
/// 无内置 label：label 文案=宿主行首（FormFieldRow #28 / Cell 行尾嵌用）。
///
/// 命中=整枚轨道（48×28）；放大命中区=宿主行（Cell/FormFieldRow 行首 label 自带整行可点可选）。
/// 划界勿混：#25 Checkbox 方形复选可多选可取消 / #35 Radio 圆形排他点选即确定 / Switch 二元点按翻转持久开/关。
import UIKit

final class SwitchView: UIView {

    /// 开/关翻转回调（on→off 与 off→on 均回调；disabled 无回调；外部赋值 checked 不触发）。
    var onChange: ((Bool) -> Void)?

    /// 当前开/关；半受控：外部赋值=同步回显（不触发 onChange）。nil=内部自持初始 off。
    var checked: Bool? {
        didSet {
            if let checked, checked != internalChecked {
                internalChecked = checked
                refresh(animated: false)
            }
        }
    }

    /// 禁用（整件 40% 灰不可点；运行期可更新，on+禁用=灰开态保留只读）。
    var disabled: Bool {
        didSet {
            refreshEnabled()
            refresh(animated: false)
        }
    }

    // 轨道/滑块几何：48 宽=交互行基准注释锚定（同 Input #29 / FormFieldRow min48 语义）、
    // 28 高=20 滑块+上下内衬各 4（spaceXs）；滑块 20=对齐 CheckboxGlyph/RadioGlyph 惯例；
    // 行程 20=48−2×4−20；轨道圆角 full=14=半高。
    private static let trackWidth: CGFloat = 48
    private static let trackHeight: CGFloat = 28
    private static let thumbSize: CGFloat = 20
    private static let inset: CGFloat = 4
    private static let duration: TimeInterval = 0.18

    private var internalChecked: Bool
    private let thumbView = UIView()
    private let tapButton = UIButton(type: .custom)

    init(checked: Bool? = nil, disabled: Bool = false, onChange: ((Bool) -> Void)? = nil) {
        self.internalChecked = checked ?? false
        self.disabled = disabled
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = false

        layer.cornerRadius = Self.trackHeight / 2
        layer.masksToBounds = true

        thumbView.backgroundColor = .white
        thumbView.layer.cornerRadius = Self.thumbSize / 2
        thumbView.layer.masksToBounds = true
        addSubview(thumbView)

        tapButton.backgroundColor = .clear
        tapButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        addSubview(tapButton)

        refreshEnabled()
        refresh(animated: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SwitchView 不支持 initWithCoder 解码，请使用 init(checked:disabled:onChange:)。")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: Self.trackWidth, height: Self.trackHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        tapButton.frame = bounds
        thumbView.frame = Self.thumbFrame(on: internalChecked, in: bounds)
    }

    @objc private func tapped() {
        guard !disabled else { return }
        let next = !internalChecked
        internalChecked = next
        refresh(animated: true)
        onChange?(next)
    }

    /// 刷新轨道色 + 滑块位（animated=用户点按/外部切换动画；运行期 disabled 更新走非动画同步）。
    /// disabled 整体灰=refreshEnabled 的整件 alpha 0.4（on+disabled=primary 轨道灰滑块保留开态，不再二次调色）。
    private func refresh(animated: Bool) {
        let targetColor = internalChecked
            ? AppColor.primary
            : AppColor.textSecondary.withAlphaComponent(0.3)
        let targetFrame = Self.thumbFrame(on: internalChecked, in: bounds)

        if animated {
            UIView.animate(withDuration: Self.duration, delay: 0, options: [.curveEaseInOut]) {
                self.backgroundColor = targetColor
                self.thumbView.frame = targetFrame
            }
        } else {
            backgroundColor = targetColor
            thumbView.frame = targetFrame
        }
    }

    private func refreshEnabled() {
        tapButton.isEnabled = !disabled
        alpha = disabled ? 0.4 : 1
    }

    /// 滑块 frame：off=居左（x=4）、on=居右（x=48−4−20=24），垂直居中（y=4）。
    private static func thumbFrame(on: Bool, in bounds: CGRect) -> CGRect {
        let x = on ? trackWidth - inset - thumbSize : inset
        let y = (bounds.height - thumbSize) / 2
        return CGRect(x: x, y: y, width: thumbSize, height: thumbSize)
    }
}
