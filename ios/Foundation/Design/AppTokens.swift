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
    static let gray25 = UIColor(hex: 0x8C8C8C)
    static let warning = UIColor(hex: 0xF59E0B)
    static let textPrimary = UIColor(hex: 0x111827)
    static let textSecondary = UIColor(hex: 0x6B7280)
    static let border = UIColor(hex: 0xE5E7EB)
    static let bgPage = UIColor(hex: 0xF9FAFB)
    static let bgCard = UIColor.white
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
    /// 背景：iOS 用 `minimumLineHeight/maximumLineHeight` 撑行高时，额外行高
    /// （行高 − 字体自然行高）由系统按字体度量分配，**不保证行内文字垂直居中**，
    /// 导致文字偏上/偏下；而 Android Compose 的 `lineHeight` 以 baseline 为中心
    /// 均匀扩展，天然居中（双端差异根因）。这里用 `baselineOffset` 把文字下移
    /// 半个额外高度，使其在行高内视觉居中，对齐 Android 行为。
    ///
    /// - Parameters:
    ///   - lineHeight: 设计稿行高（pt，如主标题 24、副标题 18）。
    ///   - fontSize: 字号（pt）。
    ///   - font: 字体；默认按 `fontSize` 取系统字体。
    /// - Returns: baselineOffset 值（正=文字下移）。若实机发现文字偏下，取负即可。
    static func verticalCenterBaselineOffset(
        lineHeight: CGFloat,
        fontSize: CGFloat,
        font: UIFont? = nil
    ) -> CGFloat {
        let f = font ?? UIFont.systemFont(ofSize: fontSize)
        // 字体自然行高 = ascender - descender（descender 为负，相减得正）。
        let naturalLineHeight = f.ascender - f.descender
        // 行高需要补的额外高度，取一半作为 baselineOffset 下移补偿。
        return (lineHeight - naturalLineHeight) / 2
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
    func setLineHeight(_ lineHeight: CGFloat, fontSize: CGFloat) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        attributedText = NSAttributedString(
            string: text ?? "",
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize),
                .paragraphStyle: paragraph,
                // 让文字在行高内垂直居中（对齐 Android Compose lineHeight 的居中行为）：
                // iOS 的 minimumLineHeight 不保证行内文字居中，用 baselineOffset 补偿。
                .baselineOffset: AppText.verticalCenterBaselineOffset(
                    lineHeight: lineHeight,
                    fontSize: fontSize
                ),
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
