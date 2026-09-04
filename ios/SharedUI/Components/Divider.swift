/// 分割线 Divider：区隔内容的分割线（水平/垂直 + 实线/虚线 + 可选文本）。
///
/// 组件 ID：`ui.divider`（api.json 契约对齐，门禁 A 评审通过 2026-09-04）。
/// 命名：Divider（iOS 去 View 后缀规范），与 api.json id 一致。

import UIKit

/// 分割线方向。
enum DividerDirection {
    case horizontal
    case vertical
}

/// 带文本时文本位置。
enum DividerContentPosition {
    case left
    case center
    case right
}

/// 区隔内容的分割线（水平/垂直 + 实线/虚线 + 可选文本）。
///
/// 支持：
/// - `direction` 方向（horizontal / vertical）
/// - `dashed` 虚线样式
/// - `hairline` 细线模式（0.5px）
/// - `contentPosition` 文本位置（left / center / right）
/// - `text` 内嵌文本（空=纯线条）
final class Divider: UIView {

    /// 方向（默认 horizontal）。修改后需 setNeedsLayout。
    var direction: DividerDirection = .horizontal { didSet { setNeedsLayout(); invalidateIntrinsicContentSize() } }

    /// 是否虚线（默认 false）。
    var dashed: Bool = false { didSet { setNeedsLayout() } }

    /// 是否细线（默认 true，0.5px）。
    var hairline: Bool = true { didSet { setNeedsLayout() } }

    /// 文本位置（默认 center，有 text 时生效）。
    var contentPosition: DividerContentPosition = .center { didSet { setNeedsLayout() } }

    /// 内嵌文本（空=纯线条）。
    var text: String = "" {
        didSet {
            textLabel.text = text
            textLabel.isHidden = text.isEmpty
            setNeedsLayout()
        }
    }

    private let textLabel = UILabel()
    private let lineLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextLabel()
        layer.addSublayer(lineLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setupTextLabel() {
        textLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        textLabel.textColor = AppColor.textSecondary
        textLabel.textAlignment = .center
        textLabel.isHidden = true
        addSubview(textLabel)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let lineWidth: CGFloat = hairline ? (1.0 / UIScreen.main.scale) : 1.0
        let dashPattern: [NSNumber] = dashed ? [4, 3] : []

        if direction == .horizontal {
            layoutHorizontal(lineWidth: lineWidth, dashPattern: dashPattern)
        } else {
            layoutVertical(lineWidth: lineWidth, dashPattern: dashPattern)
        }
    }

    private func layoutHorizontal(lineWidth: CGFloat, dashPattern: [NSNumber]) {
        let y = bounds.midY
        let textGap: CGFloat = AppSpace.sm

        if text.isEmpty || textLabel.isHidden {
            // 纯线条
            lineLayer.strokeColor = AppColor.border.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = lineWidth
            lineLayer.lineDashPattern = dashPattern.isEmpty ? nil : dashPattern

            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.maxX, y: y))
            lineLayer.path = path.cgPath
        } else {
            // 带文本：左线 + 文本 + 右线
            textLabel.sizeToFit()
            let textSize = textLabel.bounds.size
            let textX: CGFloat
            let leftLineEnd: CGFloat
            let rightLineStart: CGFloat

            switch contentPosition {
            case .left:
                textX = textGap
                leftLineEnd = textX + textSize.width + textGap
                rightLineStart = leftLineEnd
            case .center:
                textX = (bounds.width - textSize.width) / 2
                leftLineEnd = textX - textGap
                rightLineStart = textX + textSize.width + textGap
            case .right:
                textX = bounds.width - textSize.width - textGap
                leftLineEnd = textX - textGap
                rightLineStart = textX + textSize.width + textGap
            }

            textLabel.frame = CGRect(x: textX, y: (bounds.height - textSize.height) / 2,
                                     width: textSize.width, height: textSize.height)

            // 画线
            lineLayer.strokeColor = AppColor.border.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = lineWidth
            lineLayer.lineDashPattern = dashPattern.isEmpty ? nil : dashPattern

            let path = UIBezierPath()
            // 左线
            if leftLineEnd > 0 {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: max(0, leftLineEnd), y: y))
            }
            // 右线
            if rightLineStart < bounds.maxX {
                path.move(to: CGPoint(x: min(bounds.maxX, rightLineStart), y: y))
                path.addLine(to: CGPoint(x: bounds.maxX, y: y))
            }
            lineLayer.path = path.cgPath
        }
    }

    private func layoutVertical(lineWidth: CGFloat, dashPattern: [NSNumber]) {
        let x = bounds.midX

        lineLayer.strokeColor = AppColor.border.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.lineDashPattern = dashPattern.isEmpty ? nil : dashPattern

        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: bounds.maxY))
        lineLayer.path = path.cgPath
    }

    // MARK: - Intrinsic Size

    override var intrinsicContentSize: CGSize {
        let minHeight = max(1, AppSpace.sm * 2)
        if direction == .horizontal {
            // 带文本时行高随文本撑高（与 Android heightIn(min) 行为 1:1），避免文字被截断
            let textHeight: CGFloat = (text.isEmpty || textLabel.isHidden) ? 0 : ceil(textSize().height)
            return CGSize(width: UIView.noIntrinsicMetric, height: max(minHeight, textHeight))
        } else {
            return CGSize(width: minHeight, height: UIView.noIntrinsicMetric)
        }
    }

    private func textSize() -> CGSize {
        let size = (text as NSString).size(withAttributes: [.font: textLabel.font as Any])
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
}
