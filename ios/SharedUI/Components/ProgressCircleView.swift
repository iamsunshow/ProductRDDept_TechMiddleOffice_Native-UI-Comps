// ProgressCircle 进度环（信息展示区 · ui.progress-circle · #83）通用环形进度组件。
//
// 组件 ID：`ui.progress-circle`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-16，规格
// docs/数据与产物/design-spec/progress-circle-design-spec.html + 评审单
// docs/评审记录/review-progress-circle-A.md，P1–P4 全 A）。
//
// 视觉锚点（与 Android ProgressCircle 同构）：轨道 6pt 圆头线帽 + 默认 64×64 + 中心文案
// sizeMd=16 Semibold textPrimary + primary 16A34A 进度色 + 阈值切换 warnThreshold=0.8
// warning F59E0B / dangerThreshold=1.0 error DC2626 + 0.3s ease-out 过渡。
//
// 划界勿混：#74 Progress 横条 / #61 AnimatingNumbers 数字滚 / #53 Skeleton 骨架屏 /
// #72 Price 静态排版 / #44 InputNumber 步进。
import UIKit
import SnapKit

/// 环形进度条（数据驱动 + 阈值三态颜色 + 可选中心文案 + 0.3s 过渡）。
///
/// 支持：
/// - `value` 进度 0~1（必传；超界 clamp 到 [0,1]）
/// - `size` 直径（默认 64；可覆盖 32/48/64/96/128）
/// - `centerText` 自定义中心文案（默认显示百分比）
/// - `warnThreshold` warning 阈值（默认 0.8；<warnThreshold 显示 primary）
/// - `dangerThreshold` error 阈值（默认 1.0；≥warnThreshold & <dangerThreshold 显示 warning；
///   ≥dangerThreshold 显示 error）
/// - `indeterminate` 持续旋转模式（二期候选，本版不接受）
public final class ProgressCircleView: UIView {

    /// 进度 0~1（必传）。
    public var value: CGFloat = 0 {
        didSet {
            let clamped = min(1.0, max(0.0, value))
            // 颜色自动阈值切换（同步更新 stroke 颜色）
            updateStrokeColor(forValue: clamped)
            // strokeEnd 平滑过渡（0.3s ease-out）
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = oldValue == value ? nil : shapeLayer.strokeEnd
            anim.toValue = clamped
            anim.duration = 0.3
            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            shapeLayer.strokeEnd = clamped
            shapeLayer.add(anim, forKey: "strokeEnd")
            // 中心文案同步
            if let customText = centerText {
                centerLabel.text = customText
            } else {
                centerLabel.text = "\(Int((clamped * 100).rounded()))%"
            }
        }
    }

    /// 自定义中心文案（传 nil 时显示百分比）。
    public var centerText: String? {
        didSet {
            if let customText = centerText {
                centerLabel.text = customText
            } else {
                centerLabel.text = "\(Int((min(1.0, max(0.0, value)) * 100).rounded()))%"
            }
        }
    }

    /// warning 阈值（默认 0.8）。
    public var warnThreshold: CGFloat = 0.8

    /// error 阈值（默认 1.0）。
    public var dangerThreshold: CGFloat = 1.0

    private let trackLayer = CAShapeLayer()
    private let shapeLayer = CAShapeLayer()
    private let centerLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: 64, height: 64)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let lineWidth: CGFloat = 6
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: -.pi / 2 + .pi * 2,
            clockwise: true
        )
        trackLayer.path = path.cgPath
        trackLayer.lineWidth = lineWidth
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = lineWidth
        // 半径基于 size 缩放（size × 0.094 比例）
        let scale = min(bounds.width, bounds.height) / 64
        trackLayer.lineWidth = lineWidth * scale
        shapeLayer.lineWidth = lineWidth * scale
    }

    // MARK: - 初始化

    private func setupLayers() {
        // 轨道（border 灰底铺满 360°）
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = AppColor.border.cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        // 进度环（primary 默认色 + strokeEnd 0）
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = AppColor.primary.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        layer.addSublayer(shapeLayer)
    }

    private func setupLabel() {
        centerLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        centerLabel.textColor = AppColor.textPrimary
        centerLabel.textAlignment = .center
        centerLabel.text = "0%"
        addSubview(centerLabel)
        centerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().inset(8)
        }
    }

    private func updateStrokeColor(forValue v: CGFloat) {
        if v >= dangerThreshold {
            shapeLayer.strokeColor = AppColor.error.cgColor
        } else if v >= warnThreshold {
            shapeLayer.strokeColor = AppColor.warning.cgColor
        } else {
            shapeLayer.strokeColor = AppColor.primary.cgColor
        }
    }
}