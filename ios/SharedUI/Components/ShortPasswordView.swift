import UIKit

/// ShortPassword 短密码（ui.short-password，#39）——数据录入区全新立项组件。
///
/// 定位：定长数字短密码/PIN 输入内容组件（支付/交易/二次验证短密码场景）：
/// 无壳水平居中掩码点行（UITextField secureTextEntry 系统掩码点随字号、无灰底壳/清除钮/明文显隐切换）；
/// 输入=纯数字（keyboardType .numberPad + delegate 滤除粘贴/输入非数字）、定长 length 字符满=自动触发一次
/// onComplete(明文字符串)、满后继续输入拒收；行高 min 48=对齐库内 FormFieldRow/Input 交互行基准（注释锚定）；
/// 空态 placeholder 居中灰字（默认「请输入 N 位数字密码」）。
///
/// 半受控：`value: String?`=nil 内部自持输入（宿主拿 onChange 每字符即可，无需回写）；
/// 外部赋值=仅同步回显（不触发 onChange/onComplete=外部满位也不触发，仅输入路径触发）；
/// disabled=整行 40% 灰不可输入无任何回调。真实校验/错误提示/重试
/// （校验失败宿主外部 value="" 清空重输）/键盘与弹层组合（可配 #32 NumberKeyboard）=宿主自理。
///
/// 视觉锚点：字号 sizeXl 22（系统掩码点/占位随字号、两端一致）、textPrimary 掩码 / textSecondary 占位；
/// 内容水平居中（textAlignment = .center）。
///
/// 规格：docs/数据与产物/design-spec/short-password-design-spec.html（门禁 A，P1–P4 全 A）。
/// 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
final class ShortPasswordView: UIView, UITextFieldDelegate {
    /// 每字符实时直通（含满位第 length 位=最后一次输入即回调明文）；disabled 无回调。
    var onChange: ((String) -> Void)?

    /// 字符满 length 自动触发一次（仅键盘输入路径）；宿主接走真实校验；disabled 无回调。
    var onComplete: ((String) -> Void)?

    /// 半受控 value：nil=内部自持（输入无需外部回写）；外部赋值=仅同步回显（不触发 onChange/onComplete）。
    var value: String? {
        didSet {
            guard let v = value, v != textField.text else { return }
            textField.text = v
            setNeedsLayout()
        }
    }

    /// 禁用（整行 40% 灰、不可输入、无任何回调）。
    var disabled: Bool {
        didSet { refreshDisabled() }
    }

    private let textField = UITextField()
    private let digitCount: Int

    private enum Metrics {
        static let height: CGFloat = 48 // 行高 min 48=对齐库内 FormFieldRow/Input 交互行基准（注释锚定）
    }

    init(
        value: String? = nil,
        length: Int = 6,
        placeholder: String? = nil,
        disabled: Bool = false,
        onChange: ((String) -> Void)? = nil,
        onComplete: ((String) -> Void)? = nil
    ) {
        self.digitCount = max(length, 1)
        self.value = value
        self.disabled = disabled
        self.onChange = onChange
        self.onComplete = onComplete
        super.init(frame: .zero)
        backgroundColor = .clear

        textField.text = value ?? ""
        textField.font = .systemFont(ofSize: AppFont.sizeXl)
        textField.textColor = AppColor.textPrimary
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .never
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.smartQuotesType = .no
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "请输入 \(digitCount) 位数字密码",
            attributes: [
                .foregroundColor: AppColor.textSecondary,
                .font: UIFont.systemFont(ofSize: AppFont.sizeXl),
            ]
        )
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addSubview(textField)

        refreshDisabled()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("ShortPasswordView 不支持 initWithCoder 解码。")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = bounds
    }

    // MARK: - 内部

    @objc private func textDidChange() {
        apply(textField.text ?? "")
    }

    /// 统一落值：收敛为纯数字前 length 位（防文本与回调不一致），再走 onChange/满位 onComplete。
    private func apply(_ raw: String) {
        let plain = String(raw.filter { $0.isNumber }.prefix(digitCount))
        if plain != textField.text {
            textField.text = plain
        }
        onChange?(plain)
        if plain.count == digitCount {
            onComplete?(plain)
        }
    }

    private func refreshDisabled() {
        alpha = disabled ? 0.4 : 1
        textField.isEnabled = !disabled
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !disabled else { return false }
        guard let current = textField.text else { return true }
        let candidate = (current as NSString).replacingCharacters(in: range, with: string)
        let plain = String(candidate.filter { $0.isNumber })
        let limited = String(plain.prefix(digitCount))
        if limited == candidate {
            // 纯数字且未超长：交系统处理（删除/追加/原位替换）；满位追加=超长落入下方手动收敛被拒
            return true
        }
        // 含非数字（粘贴过滤）或超长（含满位后追加）：手动收敛重设（与 editingChanged 同链路），不放行
        if limited != textField.text {
            apply(limited)
        }
        return false
    }
}
