/// Lottie 动画组件（UIKit 版，对齐 Android Lottie）。
///
/// 渲染 Lottie/Bodymovin JSON 动画的容器——输入动画源（source）、自动播放（autoplay）、
/// 循环（loop）、播放速度（speed）、自定义尺寸（size），提供 play/pause/stop 命令式控制
/// 与 onComplete 播放完成回调（仅 loop=false 触发）。
///
/// 一期占位渲染（与设计规格 lottie-design-spec.html 一致）：
/// - source=动画名称占位（Lottie 库集成=二期，接入 airbnb/lottie-ios 后 source 映射 JSON）
/// - 占位视觉=UIActivityIndicatorView 环形旋转 + UILabel 动画名
/// - API 契约与二期完全一致，二期激活真实渲染时调用方零改动
///
/// 用法：
/// ```swift
/// let lottie = LottieView()
/// lottie.source = "happy"
/// lottie.loop = true
/// lottie.autoplay = true
/// // 自定义尺寸
/// lottie.size = CGSize(width: 80, height: 80)
/// // 命令式控制
/// lottie.play()
/// lottie.pause()
/// lottie.stop()
/// ```
///
/// 决策（与设计规格 lottie-design-spec.html 一致）：
/// - P1-C source 字符串占位（一期零三方依赖，API 契约与二期一致）
/// - P2-A autoplay=true loop=true（与 NutUI/lottie-react 默认一致）
/// - P3-A play/pause/stop 命令式 + autoplay 声明式双模
/// - P4-A 一期占位渲染+全 API+demo 四段（Lottie 库集成=二期）

import UIKit
import SnapKit

final class LottieView: UIView {
    // MARK: - 配置属性

    /// 动画源标识（一期=动画名称占位，二期=Lottie JSON 文件名/路径）。
    var source: String = "" {
        didSet { nameLabel.text = source.isEmpty ? "animation" : source }
    }

    /// 是否循环播放（默认 true）。
    var loop: Bool = true

    /// 是否自动播放（挂载后立即播放，默认 true）。
    var autoplay: Bool = true

    /// 播放速度（1.0=正常，0.5=慢速，2.0=快速）。
    var speed: Float = 1.0

    /// 播放完成回调（仅 loop=false 时触发；循环模式不触发）。
    var onComplete: (() -> Void)?

    /// 自定义动画尺寸；nil=自适应容器。
    var size: CGSize? { didSet { applySize() } }

    // MARK: - 内部状态

    /// 当前是否播放中。
    private(set) var isPlaying: Bool = false

    /// 是否已触发过 onComplete（非循环模式只触发一次，stop 后重置）。
    private var hasCompleted: Bool = false

    /// 占位旋转指示器（一期=Lottie 库未集成的占位视觉）。
    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = AppColor.primary
        indicator.hidesWhenStopped = false
        return indicator
    }()

    /// 动画名称标签（显示 source 占位）。
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "animation"
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    /// 状态标签（播放中/已暂停）。
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "播放中"
        label.font = .systemFont(ofSize: 10)
        label.textColor = AppColor.primary
        label.textAlignment = .center
        return label
    }()

    /// 纵向容器：spinner + 名称 + 状态。
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppSpace.xs
        return stack
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("LottieView does not support NSCoder")
    }

    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = AppRadius.sm
        clipsToBounds = true

        containerStack.addArrangedSubview(spinner)
        containerStack.addArrangedSubview(nameLabel)
        containerStack.addArrangedSubview(statusLabel)
        addSubview(containerStack)
        // edges=包裹内容：LottieView 尺寸由 containerStack 内容驱动；
        // size 非空时由 intrinsicContentSize 固定宽高，stack 填充后内部居中。
        containerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 自定义尺寸优先；nil=由内容（spinner+标签）驱动自适应。
    override var intrinsicContentSize: CGSize {
        if let size = size { return size }
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        // autoplay=true：挂载到窗口后自动播放。
        if window != nil && autoplay && !isPlaying {
            play()
        }
    }

    // MARK: - 播放控制

    /// 从当前位置继续播放（暂停后恢复）。
    func play() {
        guard !isPlaying else { return }
        isPlaying = true
        hasCompleted = false
        spinner.startAnimating()
        statusLabel.text = "播放中"
        statusLabel.textColor = AppColor.primary
        // 一期占位：非循环模式用一个短延时模拟播放完成触发 onComplete
        // （二期接入 Lottie 库后由动画实例的完成回调驱动）。
        if !loop {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0 / Double(max(speed, 0.1))) { [weak self] in
                guard let self = self, self.isPlaying, !self.hasCompleted else { return }
                self.hasCompleted = true
                self.onComplete?()
                // 非循环播完自动停止（不复位，停当前态）。
                self.isPlaying = false
                self.spinner.stopAnimating()
                self.statusLabel.text = "已暂停"
                self.statusLabel.textColor = AppColor.gray25
            }
        }
    }

    /// 暂停在当前帧，不复位。
    func pause() {
        guard isPlaying else { return }
        isPlaying = false
        spinner.stopAnimating()
        statusLabel.text = "已暂停"
        statusLabel.textColor = AppColor.gray25
    }

    /// 停止并复位到首帧。
    func stop() {
        isPlaying = false
        hasCompleted = false
        spinner.stopAnimating()
        statusLabel.text = "已停止"
        statusLabel.textColor = AppColor.gray25
    }

    // MARK: - 尺寸

    /// 应用自定义尺寸：触发 intrinsicContentSize 重算 + 缩放 spinner。
    private func applySize() {
        invalidateIntrinsicContentSize()
        // 自定义尺寸时缩小 spinner，保持视觉比例。
        if let size = size, size.width < 100 {
            spinner.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        } else {
            spinner.transform = .identity
        }
    }
}
