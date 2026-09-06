/// FormView 表单容器（数据录入区 · ui.form · #28）。
///
/// 组件 ID：`ui.form`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/form-design-spec.html + 评审单 review-form-A.md，P1–P4 全 A）。
///
/// 定位：**表单布局容器**——分组卡片 + 字段行排版 + 校验文案渲染管道，不含具体输入控件：
/// - `Form`：单分组卡片（可选 `groupTitle` 分组标题 + N 行字段 + 可选 `submitView` 提交区槽）；
///   多个分组=宿主纵向并列多个 `Form`（间距由宿主用 Space 控制）。
/// - `FormFieldRow`：label（左，区宽 96pt 固定，超长自动折行）+ required 必填星（primary）+ 内容槽
///   （宿主自放输入控件/mock）+ 行内提示槽（error 非空=error 红字；否则 help 灰字；都空=不占位）。
/// - 校验算法与表单状态管理=宿主职责（校验结论经 `error` 文案传入，组件只渲染）。
///
/// 组件为纯内容视图：无弹层/键盘/校验引擎（宿主自理）；行高 min 48pt、行间 hairline 全卡宽分隔
/// （同 Cell 先例）；label 空=内容全宽。内容槽高度来源须可通过 `intrinsicContentSize`
/// 或 `sizeThatFits` 解析（宿主控件/单行文案均满足；内容超高时行随内容增高）。
///
/// 设计锚点（Token 注释锚定）：label Md=16 主色；必填星 Md=16 primary 前置；help/error 字号
/// Xs=12 次色/红 error；卡片=bgCard + 圆角 lg + hairline 边框；行间分隔 hairline iOS 1/scale pt
/// （vs Android 0.5dp 表内放行）。
///
/// 用法：
/// ```swift
/// let row = FormFieldRow(label: "昵称", required: true, help: "选填，2~10 字",
///                        content: mockInput("有鱼记账"))
/// let form = Form(groupTitle: "账户信息", rows: [row])
/// host.addSubview(form)
/// form.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
/// host.snp.makeConstraints { $0.bottom.equalTo(form.snp.bottom) }
/// row.error = "昵称至少 2 个字符"   // 动态校验文案：行下展开红字
/// ```
import UIKit

// MARK: - 字段行

/// 表单字段行：label（96pt 固定区折行）+ 必填星 + 内容槽 + 行内 help/error 提示行。
/// 组件内部用手动 frame 布局（不依赖 Auto Layout 高度链），高度由内容推出
/// （行 min 高 48pt，超高随内容；error/help 非空时行下展开一行提示并随之增高）。
final class FormFieldRow: UIView {

    /// 行内布局规格（Token 对齐注释防魔法值误判；Android 侧同数值不同单位）。
    enum Metrics {
        /// 行最小高（48pt，与 Android 48dp 同构，同 Cell 行高惯例）
        static let minHeight: CGFloat = 48
        /// label 区固定宽（96pt = Md16 约 6 汉字含星，与 Android 96dp 同构）
        static let labelWidth: CGFloat = 96
        /// label 区与内容区间距（12pt = AppSpace.md）
        static let labelContentGap: CGFloat = 12
        /// 行内左右内边距（16pt = AppSpace.lg）
        static let horizontalInset: CGFloat = 16
        /// 提示行与内容行间距（2pt）
        static let hintGap: CGFloat = 2
        /// 提示行下方余白（6pt，视觉收底）
        static let hintBottomPad: CGFloat = 6
        /// 行间 hairline（1/scale pt，与 Android 0.5dp 表内放行的系统级差异）
        static var hairline: CGFloat { 1 / UIScreen.main.scale }
    }

    private let labelText: String?
    private let required: Bool
    private let contentView: UIView
    private let labelLabel = UILabel()
    private let hintLabel = UILabel()
    private let hairline = UIView()
    private let starAttrColor = AppColor.primary

    /// 帮助文案（help 非空且 error 为空时显示，次色小字）。
    var help: String? {
        didSet { refreshHint() }
    }
    /// 校验错误文案（非空=行内红字；此时 help 不显示）。
    var error: String? {
        didSet { refreshHint() }
    }
    /// 提示行当前文案（error 优先，其次 help）。
    private var hintText: String? { error ?? help }

    /// 是否显示内容槽（label 为空串/空 = 内容全宽行）。
    private var showsLabel: Bool {
        if let labelText { return !labelText.isEmpty }
        return false
    }

    init(label: String? = nil, required: Bool = false, help: String? = nil, error: String? = nil, content: UIView) {
        self.labelText = label
        self.required = required
        self.help = help
        self.error = error
        self.contentView = content
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard

        // label：必填星与标题合并为一段 attr（星 primary、文字 textPrimary），96pt 区内自动折行
        let attributed = NSMutableAttributedString()
        let mdFont = UIFont.systemFont(ofSize: AppFont.sizeMd)
        if required {
            attributed.append(NSAttributedString(
                string: "* ",
                attributes: [.font: mdFont, .foregroundColor: starAttrColor]
            ))
        }
        if showsLabel {
            attributed.append(NSAttributedString(
                string: labelText ?? "",
                attributes: [.font: mdFont, .foregroundColor: AppColor.textPrimary]
            ))
        }
        labelLabel.attributedText = attributed
        labelLabel.numberOfLines = 0
        labelLabel.lineBreakMode = .byWordWrapping
        labelLabel.isHidden = !showsLabel && !required

        hintLabel.numberOfLines = 0
        hintLabel.lineBreakMode = .byWordWrapping
        hintLabel.isHidden = true

        hairline.backgroundColor = AppColor.border

        addSubview(labelLabel)
        addSubview(contentView)
        addSubview(hintLabel)
        addSubview(hairline)
        refreshHint()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("FormFieldRow 不支持 initWithCoder 解码，请使用 init(label:required:help:error:content:)。")
    }

    // MARK: - 尺寸计算（intrinsic 供 Form / 外部布局使用；与 bounds.width 无关因 label 区 96 固定）

    private func attributedHeight(_ attributed: NSAttributedString, width: CGFloat) -> CGFloat {
        guard attributed.length > 0 else { return 0 }
        let bounds = attributed.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(bounds.height)
    }

    private func contentHeight(contentWidth: CGFloat) -> CGFloat {
        let intrinsic = contentView.intrinsicContentSize.height
        if intrinsic > 0 { return intrinsic }
        let fitted = contentView.sizeThatFits(
            CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
        ).height
        return max(fitted, 0)
    }

    /// 计算本行总高（min 48 内容行 + 提示行）。
    func intrinsicHeight(contentWidth: CGFloat) -> CGFloat {
        var body: CGFloat = Metrics.minHeight
        let labelW = max(Metrics.labelWidth, 0)
        if !labelLabel.isHidden, let attr = labelLabel.attributedText, attr.length > 0 {
            body = max(body, attributedHeight(attr, width: labelW))
        }
        let contentW = contentSlotWidth(total: contentWidth)
        body = max(body, contentHeight(contentWidth: contentW))
        var total = body
        if !hintLabel.isHidden, let hint = hintLabel.attributedText, hint.length > 0 {
            let hintW = max(contentWidth - Metrics.horizontalInset * 2, 0)
            let hintH = attributedHeight(hint, width: hintW)
            total = body + Metrics.hintGap + hintH + Metrics.hintBottomPad
        }
        return total
    }

    private func contentSlotWidth(total: CGFloat) -> CGFloat {
        let leading = showsLabel
            ? Metrics.horizontalInset + Metrics.labelWidth + Metrics.labelContentGap
            : Metrics.horizontalInset
        return max(total - leading - Metrics.horizontalInset, 0)
    }

    override var intrinsicContentSize: CGSize {
        let w = bounds.width > 0 ? bounds.width : 375
        return CGSize(width: UIView.noIntrinsicMetric, height: intrinsicHeight(contentWidth: w))
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        guard w > 0 else { return }

        // 内容行（label + content）垂直居中于 minHeight 之上（超高随内容）
        let labelW = max(Metrics.labelWidth, 0)
        var body: CGFloat = Metrics.minHeight
        let attr = labelLabel.attributedText
        let labelH: CGFloat
        if labelLabel.isHidden {
            labelH = 0
        } else {
            labelH = attributedHeight(attr, width: labelW)
            body = max(body, labelH)
        }
        let contentW = contentSlotWidth(total: w)
        let contentH = contentHeight(contentWidth: contentW)
        body = max(body, contentH)

        if !labelLabel.isHidden {
            labelLabel.frame = CGRect(
                x: Metrics.horizontalInset,
                y: (body - labelH) / 2,
                width: labelW,
                height: labelH
            )
        }
        let contentX = showsLabel
            ? Metrics.horizontalInset + Metrics.labelWidth + Metrics.labelContentGap
            : Metrics.horizontalInset
        contentView.frame = CGRect(
            x: contentX,
            y: (body - contentH) / 2,
            width: contentW,
            height: contentH
        )

        var total = body
        if !hintLabel.isHidden {
            let hintW = max(w - Metrics.horizontalInset * 2, 0)
            let hintH = attributedHeight(hintLabel.attributedText, width: hintW)
            hintLabel.frame = CGRect(
                x: Metrics.horizontalInset,
                y: body + Metrics.hintGap,
                width: hintW,
                height: hintH
            )
            total = body + Metrics.hintGap + hintH + Metrics.hintBottomPad
        }
        hairline.frame = CGRect(x: 0, y: total - Metrics.hairline, width: w, height: Metrics.hairline)
    }

    // MARK: - 提示行刷新

    private func refreshHint() {
        let text = hintText
        if let text, !text.isEmpty {
            hintLabel.isHidden = false
            hintLabel.attributedText = NSAttributedString(
                string: text,
                attributes: [
                    .font: UIFont.systemFont(ofSize: AppFont.sizeXs),
                    .foregroundColor: error != nil ? AppColor.error : AppColor.textSecondary,
                ]
            )
        } else {
            hintLabel.isHidden = true
            hintLabel.attributedText = nil
        }
        setNeedsLayout()
        invalidateIntrinsicContentSize()
        superview?.invalidateIntrinsicContentSize()
    }
}

// MARK: - 表单分组卡片

/// 表单分组卡片：卡片容器 + 可选分组标题 + 1~N 字段行 + 可选提交区槽（宿主自放按钮）。
/// 卡片外观=bgCard + 圆角 lg + hairline 边框；高度由内容推出（供宿主闭合底部约束）。
final class Form: UIView {

    enum Metrics {
        /// 分组标题距卡顶（10pt）
        static let titleTop: CGFloat = 10
        /// 分组标题高（16pt，容纳 Xs=12 文本行）
        static let titleHeight: CGFloat = 16
        /// 标题与首行间距（4pt，对应设计稿标题底 pad）
        static let titleBottomGap: CGFloat = 4
        /// 提交区与末行间距（12pt = AppSpace.md）
        static let submitGap: CGFloat = 12
        /// 提交区左右 inset（16pt，提交按钮通卡内容宽）
        static let submitInset: CGFloat = 16
        /// 提交区底 pad（12pt）
        static let submitBottomPad: CGFloat = 12
        /// 卡 hairline 边框（1/scale pt）
        static var hairline: CGFloat { 1 / UIScreen.main.scale }
    }

    private let groupTitle: String?
    private var rows: [FormFieldRow] = []
    private var titleLabel: UILabel?
    private var submit: UIView?

    /// 提交区槽（宿主自放按钮等）；设置后于字段行下方展示。
    var submitView: UIView? {
        didSet {
            if let old = oldValue { old.removeFromSuperview() }
            if let submit {
                addSubview(submit)
            }
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    init(groupTitle: String? = nil, rows: [FormFieldRow]) {
        self.groupTitle = groupTitle
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = AppRadius.lg
        layer.borderWidth = Metrics.hairline
        layer.borderColor = AppColor.border.cgColor
        layer.masksToBounds = true

        if let groupTitle, !groupTitle.isEmpty {
            let label = UILabel()
            label.text = groupTitle
            label.font = .systemFont(ofSize: AppFont.sizeXs)
            label.textColor = AppColor.textSecondary
            addSubview(label)
            titleLabel = label
        }
        rows.forEach { addRow($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Form 不支持 initWithCoder 解码，请使用 init(groupTitle:rows:)。")
    }

    /// 追加字段行（行高变化时会重排卡内布局）。
    func addRow(_ row: FormFieldRow) {
        rows.append(row)
        addSubview(row)
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    /// 卡内容总高（标题 + 行 + 提交槽；宽度仅用于行内内容槽测高）。
    private func contentHeight(contentWidth: CGFloat) -> CGFloat {
        var y: CGFloat = 0
        if titleLabel != nil {
            y = Metrics.titleTop + Metrics.titleHeight + Metrics.titleBottomGap
        }
        let contentW = contentWidth > 0 ? contentWidth : 375
        for row in rows {
            y += row.intrinsicHeight(contentWidth: contentW)
        }
        if let submit {
            y += Metrics.submitGap
            y += submitHeight(submit: submit, width: max(contentW - Metrics.submitInset * 2, 0))
            y += Metrics.submitBottomPad
        }
        return y
    }

    private func submitHeight(submit: UIView, width: CGFloat) -> CGFloat {
        let intrinsic = submit.intrinsicContentSize.height
        if intrinsic > 0 { return intrinsic }
        return max(submit.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height, 0)
    }

    override var intrinsicContentSize: CGSize {
        let w = bounds.width > 0 ? bounds.width : 375
        return CGSize(width: UIView.noIntrinsicMetric, height: contentHeight(contentWidth: w))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        guard w > 0 else { return }

        var y: CGFloat = 0
        if let titleLabel {
            titleLabel.frame = CGRect(
                x: Metrics.submitInset,
                y: Metrics.titleTop,
                width: max(w - Metrics.submitInset * 2, 0),
                height: Metrics.titleHeight
            )
            y = Metrics.titleTop + Metrics.titleHeight + Metrics.titleBottomGap
        }
        for row in rows {
            let rowH = row.intrinsicHeight(contentWidth: w)
            row.frame = CGRect(x: 0, y: y, width: w, height: rowH)
            y += rowH
        }
        if let submit {
            let inset = Metrics.submitInset
            y += Metrics.submitGap
            let sw = max(w - inset * 2, 0)
            let sh = submitHeight(submit: submit, width: sw)
            submit.frame = CGRect(x: inset, y: y, width: sw, height: sh)
            y += sh + Metrics.submitBottomPad
        }
    }
}
