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
