/// Loading 加载中：全屏/区域遮罩加载指示器（操作反馈区 #50，全新立项）。
///
/// 组件 ID：`ui.loading`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
/// 用户"中间任何询问直接通过"总授权；P1–P4 全 A：纯加载指示器模式 +
/// 双类型 circular/spinner + 双方向 horizontal/vertical + 不内置遮罩）。
///
/// 一期语义（对标 NutUI React Loading + Vant Loading）：
/// - [type]：图标类型 .circular（环形旋转，默认）/ .spinner（5 线跳动）
/// - [direction]：图标+文案排列方向 .horizontal（水平，默认）/ .vertical（竖向）
/// - [text]：可选文案（nil=纯图标）
/// - [color]：图标+文案颜色（默认 AppColor.textSecondary，可配 AppColor.primary 等）
/// - [size]：图标尺寸（默认 AppFont.sizeLg 18pt）
/// - [textSize]：文案字号（默认 AppFont.sizeSm 14pt）
/// - 不内置遮罩=宿主组合 Overlay #6 做全屏加载（与 NutUI Loading+Overlay 组合模式一致）
///
/// 用法：
/// ```swift
/// // 基础
/// let loading = LoadingView()
/// // 带文案
/// let loading = LoadingView(text: "加载中...", direction: .vertical)
/// // spinner 类型
/// let loading = LoadingView(type: .spinner, color: AppColor.primary, size: 32)
/// // 全屏遮罩（宿主组合 Overlay）
/// let overlay = Overlay(visible: true) { LoadingView(text: "加载中...", direction: .vertical) }
/// ```
import UIKit
import SnapKit

enum LoadingType {
    case circular, spinner
}

enum LoadingDirection {
    case horizontal, vertical
}

final class LoadingView: UIView {

    private let type: LoadingType
    private let direction: LoadingDirection
    private let text: String?
    private let color: UIColor
    private let size: CGFloat
    private let textSize: CGFloat

    private let stackView = UIStackView()
    private var indicator: UIView?

    init(type: LoadingType = .circular,
         direction: LoadingDirection = .horizontal,
         text: String? = nil,
         color: UIColor = AppColor.textSecondary,
         size: CGFloat = AppFont.sizeLg,
         textSize: CGFloat = AppFont.sizeSm) {
        self.type = type
        self.direction = direction
        self.text = text
        self.color = color
        self.size = size
        self.textSize = textSize
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in make.center.equalToSuperview() }

        // 根据方向设置 stack
        if direction == .horizontal {
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.spacing = AppSpace.sm
        } else {
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = AppSpace.sm
        }

        // 图标
        let iconView: UIView
        switch type {
        case .circular:
            let indicator = LoadingCircularView(size: size, color: color)
            iconView = indicator
        case .spinner:
            iconView = LoadingSpinnerView(size: size, color: color)
        }
        stackView.addArrangedSubview(iconView)
        self.indicator = iconView

        // 文案
        if let text = text {
            let label = UILabel()
            label.text = text
            label.textColor = color
            label.font = .systemFont(ofSize: textSize)
            if direction == .vertical {
                label.textAlignment = .center
            }
            stackView.addArrangedSubview(label)
        }
    }

    override var intrinsicContentSize: CGSize {
        return stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

/// spinner 类型：5 线交替跳动（与 Android Canvas+5 线同构）。
/// 动画：scaleY 0.4↔1，1s ease-in-out infinite，交替延迟 -0.4s~-0s。
private final class LoadingSpinnerView: UIView {
    private let size: CGFloat
    private let color: UIColor
    private var lines: [CAShapeLayer] = []
    private let heightRatios: [CGFloat] = [0.4, 0.7, 1.0, 0.6, 0.35]

    init(size: CGFloat, color: UIColor) {
        self.size = size
        self.color = color
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupLayers()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupLayers() {
        let lineW = max(size / 6, 2)
        let gap = max(size / 6, 2)
        let totalW = lineW * 5 + gap * 4
        let leftPad = (size - totalW) / 2

        for i in 0..<5 {
            let ratio = heightRatios[i]
            let lineH = size * ratio
            let x = leftPad + CGFloat(i) * (lineW + gap)
            let y = (size - lineH) / 2

            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: lineW, height: lineH), cornerRadius: lineW / 2)
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = color.cgColor
            layer.frame = CGRect(x: x, y: y, width: lineW, height: lineH)

            // 初始 scaleY 0.4
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.transform = CATransform3DMakeScale(1.0, 0.4, 1.0)

            self.layer.addSublayer(layer)
            lines.append(layer)

            // 动画
            let anim = CABasicAnimation(keyPath: "transform.scale.y")
            anim.fromValue = 0.4
            anim.toValue = 1.0
            anim.duration = 1.0
            anim.autoreverses = true
            anim.repeatCount = .infinity
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            anim.timeOffset = -0.4 + Double(i) * 0.1
            layer.add(anim, forKey: "spinnerLine")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for layer in lines {
            layer.position = CGPoint(x: layer.position.x, y: layer.position.y)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: size, height: size)
    }
}

/// circular 类型：缺口圆圈旋转（与 Android CircularProgressIndicator 同构）。
/// 绘制一个 ~270° 的弧形描边圆，持续旋转，缺口随旋转移动。
private final class LoadingCircularView: UIView {
    private let size: CGFloat
    private let color: UIColor
    private let arcLayer = CAShapeLayer()

    init(size: CGFloat, color: UIColor) {
        self.size = size
        self.color = color
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupLayer()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupLayer() {
        let strokeWidth = max(size / 8, 2)
        let radius = (size - strokeWidth) / 2
        let center = CGPoint(x: size / 2, y: size / 2)
        // 必须设置 arcLayer 的 frame，否则 bounds 为 .zero，旋转 anchorPoint 在 (0,0) 导致"绕大圈"
        arcLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        // 270° 弧（缺口 90°），起点在顶部
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = startAngle + .pi * 1.5
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        arcLayer.path = path.cgPath
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = color.cgColor
        arcLayer.lineWidth = strokeWidth
        arcLayer.lineCap = .round
        layer.addSublayer(arcLayer)

        // 旋转动画
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 0.8
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        arcLayer.add(rotation, forKey: "circularRotation")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: size, height: size)
    }
}
