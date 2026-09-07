/// 设计令牌：颜色、字号、间距与圆角常量，供全 App 复用。

import UIKit

/// 品牌与语义色板。
enum AppColor {
    static let primary = UIColor(hex: 0x16A34A)
    static let primaryPressed = UIColor(hex: 0x15803D)
    static let primaryMuted = UIColor(hex: 0xDCFCE7)
    static let income = UIColor(hex: 0x16A34A)
    static let expense = UIColor(hex: 0xDC2626)
    static let error = UIColor(hex: 0xDC2626)
    static let success = UIColor(hex: 0x16A34A)
    static let gray4 = UIColor(hex: 0xF5F5F5)
    static let gray6 = UIColor(hex: 0xE5E5E5)
    static let gray10 = UIColor(hex: 0xD9D9D9)
    static let gray15 = UIColor(hex: 0xBFBFBF)
    static let gray25 = UIColor(hex: 0x8C8C8C)
    static let warning = UIColor(hex: 0xF59E0B)
    static let textPrimary = UIColor(hex: 0x111827)
    static let textSecondary = UIColor(hex: 0x6B7280)
    static let border = UIColor(hex: 0xE5E7EB)
    static let bgPage = UIColor(hex: 0xF9FAFB)
    static let bgCard = UIColor.white
    /// 按钮禁用/加载态填充色（灰阶 400 区间，介于 gray15 与 gray25 之间）。
    static let buttonDisabled = UIColor(hex: 0x9CA3AF)
}

/// 字号阶梯。
enum AppFont {
    static let sizeXs: CGFloat = 12
    static let sizeSm: CGFloat = 14
    static let sizeMd: CGFloat = 16
    static let sizeLg: CGFloat = 18
    static let sizeXl: CGFloat = 22
    static let sizeDisplay: CGFloat = 32
}

/// 间距阶梯。
enum AppSpace {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24

    /// 列表行(Cell)上下内边距，来自设计稿「32 号字 cell」：32px@2x = 16pt。
    static let cellVertical: CGFloat = 16
}

/// 圆角阶梯。
enum AppRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 14
}

/// 多行文本排版间距（与 docs/design/tokens.json `text` 对齐）。
enum AppText {
    /// 相邻文本行间距。
    static let lineSpacing = AppSpace.sm
    /// 段落块间距（如说明与列表之间）。
    static let paragraphSpacing = AppSpace.md
    /// Compose 行高倍率。
    static let lineHeightMultiple: CGFloat = 1.8

    /// 列表行(Cell)主标题行高，来自设计稿「32 号字 cell」：48px@2x = 24pt。
    static let cellTitleLineHeight: CGFloat = 24
    /// 列表行(Cell)副标题行高，来自设计稿「32 号字 cell」：36px@2x = 18pt。
    static let cellSubtitleLineHeight: CGFloat = 18

    /// 计算「让文字在指定行高内垂直居中」的 baselineOffset 补偿值（pt）。
    ///
    /// ⚠️ v1.18 校准结论：**返回 0，不补偿**。
    /// 背景：v1.1.0 曾用 `(lineHeight - naturalLineHeight)/2` 做补偿，但：
    /// 1. iOS 原生 `minimumLineHeight = maximumLineHeight` 撑行高时，文字在行框内
    ///    已经接近垂直居中（macOS TextKit 像素级实测：质心偏差仅 +0.5pt）；
    /// 2. 叠加 baselineOffset 会把**整个文本绘制整体下移**（非行内微调），反而把
    ///    文字推到偏下（实测 +3.5pt，与用户实测"文字偏下"完全吻合）；
    /// 3. baselineOffset 会放大 `UILabel.intrinsicContentSize`，把 textStack/cell
    ///    高度撑大，导致箭头（centerY 锚定 textStack）同步偏下（用户实测"箭头偏下"）。
    /// 因此移除补偿，让 iOS 原生行高分配决定文字位置，与 Android 视觉对齐。
    ///
    /// - Parameters:
    ///   - lineHeight: 设计稿行高（pt，如主标题 24、副标题 18）。
    ///   - fontSize: 字号（pt）。
    ///   - font: 字体；默认按 `fontSize` 取系统字体。
    /// - Returns: baselineOffset 值（0 = 不补偿）。若未来某个 iOS 版本实测仍有
    ///   行内偏移，可在此返回实测差值（正=下移，负=上移）。
    static func verticalCenterBaselineOffset(
        lineHeight: CGFloat,
        fontSize: CGFloat,
        font: UIFont? = nil
    ) -> CGFloat {
        // v1.18：实测 iOS 原生 min/max 行高已居中，无需补偿（详见上方注释）。
        0
    }

    static func paragraphStyle(alignment: NSTextAlignment = .natural) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.paragraphSpacing = paragraphSpacing
        style.alignment = alignment
        return style
    }

    static func attributes(
        fontSize: CGFloat,
        color: UIColor,
        alignment: NSTextAlignment = .natural
    ) -> [NSAttributedString.Key: Any] {
        [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle(alignment: alignment)
        ]
    }
}

extension UILabel {
    /// 应用标准多行文本间距。
    func setContentText(
        _ text: String,
        fontSize: CGFloat = AppFont.sizeMd,
        color: UIColor = AppColor.textPrimary,
        alignment: NSTextAlignment = .natural
    ) {
        numberOfLines = 0
        attributedText = NSAttributedString(
            string: text,
            attributes: AppText.attributes(fontSize: fontSize, color: color, alignment: alignment)
        )
    }

    /// 设置显式行高（pt）。两端行高对齐设计稿时使用：
    /// 系统字体默认行高（iOS≈19 / Android≈20）因字体度量不同而漂移，
    /// 用设计稿逻辑值显式固定（如主标题 24、副标题 18），保证双端一致。
    /// 注意：只设 font + paragraphStyle，不设 foregroundColor，
    /// 颜色交由 label.textColor 属性控制（禁用态可正常置灰）。
    ///
    /// v1.19：改用 `lineHeightMultiple` 替代 `minimumLineHeight/maximumLineHeight`。
    /// 原因：`minimumLineHeight` 在 iOS 上将多余行高空间加在行框**顶部**，
    /// 导致单行文字偏下、不居中（用户实测复现）。`lineHeightMultiple` 按比例
    /// 缩放自然行高，iOS TextKit 会在行框内更均匀地分配空间，文字接近居中。
    /// 同时移除 `baselineOffset` 补偿——`lineHeightMultiple` 不需要额外补偿，
    /// 且 baselineOffset 会放大 intrinsicContentSize 引发布局级联偏移。
    func setLineHeight(_ lineHeight: CGFloat, fontSize: CGFloat) {
        let paragraph = NSMutableParagraphStyle()
        let naturalLineHeight = UIFont.systemFont(ofSize: fontSize).lineHeight
        // 用倍率方式设行高：desired / natural。若 lineHeight <= natural 则不放大。
        let multiple = max(lineHeight / naturalLineHeight, 1.0)
        paragraph.lineHeightMultiple = multiple
        attributedText = NSAttributedString(
            string: text ?? "",
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize),
                .paragraphStyle: paragraph,
            ]
        )
    }
}

extension UIColor {
    /// 由十六进制 RGB 构造颜色。
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
