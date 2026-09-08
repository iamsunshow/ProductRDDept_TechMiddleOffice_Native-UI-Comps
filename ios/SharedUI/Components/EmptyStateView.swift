/// 通用空态视图，无业务依赖。

import UIKit
import SnapKit

/// 空态自绘图标种类（双端共用，不依赖任何图标库，v1.4.3 新增）。
///
/// 用于 EmptyStateView.setIconDrawable(_:size:) 方法。双端各自用 UIBezierPath/Canvas
/// 自绘相同形状的 Path，根治 SF Symbol vs Material Icons vs emoji
/// 三套图标库视觉差异（用户 2026-09-08 反馈）。
enum EmptyIconKind {
    /// 铃铛（用于「暂无通知/记录」类空态）。
    case bell
    /// 文件夹（用于「该文件夹为空」类空态）。
    case folder
}

/// 可复用空态组件。
///
/// 未设置文案时默认「暂无数据」；调用 `setMessage` 可覆盖为业务文案。
/// 可选设置图标 `setIcon`，图标居中于文案上方。
final class EmptyStateView: UIView {
    /// 列表空态默认文案。
    static let defaultMessage = "暂无数据"

    private let iconView = UIImageView()
    private let iconTextLabel = UILabel()
    private let label = UILabel()
    private let stack = UIStackView()

    /// 初始化空态布局（默认「暂无数据」）。
    ///
    /// - Parameter frame: 初始 frame
    /// - Returns: 无
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false

        iconView.isHidden = true
        iconView.tintColor = AppColor.textSecondary
        iconView.contentMode = .scaleAspectFit

        iconTextLabel.isHidden = true
        iconTextLabel.textAlignment = .center
        iconTextLabel.textColor = AppColor.textSecondary

        label.text = Self.defaultMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppColor.textSecondary
        label.font = .systemFont(ofSize: AppFont.sizeMd)

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppSpace.md
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(iconTextLabel)
        stack.addArrangedSubview(label)
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 设置空态提示文案；传空字符串则回退为默认「暂无数据」。
    ///
    /// - Parameter text: 展示文本
    /// - Returns: 无
    func setMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        label.text = trimmed.isEmpty ? Self.defaultMessage : text
    }

    /// 设置空态图标（可选）；传 nil 隐藏图标。
    ///
    /// - Parameter image: 图标图片
    /// - Parameter size: 图标尺寸（pt），默认 48
    /// - Returns: 无
    func setIcon(_ image: UIImage?, size: CGFloat = 48) {
        iconTextLabel.isHidden = true
        iconView.image = image
        iconView.isHidden = (image == nil)
        iconView.snp.remakeConstraints { make in
            make.width.height.equalTo(size)
        }
    }

    /// 设置空态文本图标（emoji 文本，跨图标库一致）；传 nil 隐藏。
    ///
    /// 用于双端统一图标显示（iOS SF Symbol vs Android Material Icons 差异大时，
    /// 用 emoji 文本替代，保证视觉一致）。
    ///
    /// - Parameter text: emoji 文本（如 "🔔"、"📂"）
    /// - Parameter size: 字号（pt），默认 48
    /// - Returns: 无
    func setIconText(_ text: String?, size: CGFloat = 48) {
        iconView.isHidden = true
        iconTextLabel.text = text
        iconTextLabel.isHidden = (text == nil)
        iconTextLabel.font = .systemFont(ofSize: size)
    }

    /// 设置空态自绘矢量图标（v1.4.3 根治方案）；不依赖任何图标库。
    ///
    /// 用 UIBezierPath 自绘 Bell/Folder 形状，与 Android EmptyStateView 的
    /// Canvas+Path 路径 1:1 对齐（相同坐标系、相同比例、相同描边粗细），
    /// 根治 SF Symbol vs Material Icons vs emoji 三套图标库视觉差异。
    ///
    /// - Parameter kind: 图标种类（.bell / .folder）
    /// - Parameter size: 图标尺寸（pt），默认 48
    /// - Returns: 无
    func setIconDrawable(_ kind: EmptyIconKind, size: CGFloat = 48) {
        iconTextLabel.isHidden = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            let path = Self.makeIconPath(kind: kind, size: size)
            AppColor.textSecondary.setStroke()
            path.lineWidth = size / 16
            path.stroke()

            // 铃舌小圆（Bell 独有）
            if kind == .bell {
                let tongueRect = CGRect(
                    x: size * 0.5 - size * 0.06,
                    y: size * 0.87 - size * 0.06,
                    width: size * 0.12,
                    height: size * 0.12
                )
                let tonguePath = UIBezierPath(ovalIn: tongueRect)
                tonguePath.lineWidth = size / 16
                tonguePath.stroke()
            }
        }
        iconView.image = image
        iconView.isHidden = false
        iconView.snp.remakeConstraints { make in
            make.width.height.equalTo(size)
        }
    }

    /// 生成自绘图标的 UIBezierPath（与 Android drawBellPath/drawFolderPath 路径 1:1 对齐）。
    private static func makeIconPath(kind: EmptyIconKind, size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        switch kind {
        case .bell:
            // 钟体（倒 U 形：左下→左上→顶部圆弧→右上→右下）
            path.move(to: CGPoint(x: size * 0.25, y: size * 0.75))
            path.addLine(to: CGPoint(x: size * 0.25, y: size * 0.45))
            path.addCurve(
                to: CGPoint(x: size * 0.75, y: size * 0.45),
                controlPoint1: CGPoint(x: size * 0.25, y: size * 0.15),
                controlPoint2: CGPoint(x: size * 0.75, y: size * 0.15)
            )
            path.addLine(to: CGPoint(x: size * 0.75, y: size * 0.75))
            // 钟口横线（独立子路径）
            path.move(to: CGPoint(x: size * 0.15, y: size * 0.75))
            path.addLine(to: CGPoint(x: size * 0.85, y: size * 0.75))
            // 顶部挂钩小弧
            path.move(to: CGPoint(x: size * 0.42, y: size * 0.15))
            path.addCurve(
                to: CGPoint(x: size * 0.58, y: size * 0.15),
                controlPoint1: CGPoint(x: size * 0.45, y: size * 0.02),
                controlPoint2: CGPoint(x: size * 0.55, y: size * 0.02)
            )
        case .folder:
            // 文件夹轮廓（左上标签 + 主体矩形，闭合）
            path.move(to: CGPoint(x: size * 0.1, y: size * 0.25))
            path.addLine(to: CGPoint(x: size * 0.4, y: size * 0.25))
            path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.35))
            path.addLine(to: CGPoint(x: size * 0.9, y: size * 0.35))
            path.addLine(to: CGPoint(x: size * 0.9, y: size * 0.8))
            path.addLine(to: CGPoint(x: size * 0.1, y: size * 0.8))
            path.close()
        }
        return path
    }
}
