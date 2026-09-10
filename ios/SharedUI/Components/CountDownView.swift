/// CountDown 倒计时组件（UIKit 版，对齐 Android CountDown）。
///
/// 纯展示型倒计时数字组件：输入目标结束时间戳（targetTime，epoch 秒）或剩余秒数（remaining），
/// 组件自驱每秒基于时间戳重算 remaining 并格式化显示（HH:mm:ss / DD 天 HH:mm:ss / mm:ss），
/// 支持半受控暂停（paused）与结束回调（onEnd）。
///
/// 用法：
/// ```swift
/// let cd = CountDownView(remaining: 3600, format: "HH:mm:ss")
/// // 或
/// let cd = CountDownView()
/// cd.remaining = 3600
/// ```
///
/// 设计要点（与 design-spec/countdown-design-spec.html 一致）：
/// - targetTime 优先；为 0 时使用 remaining（内部转 targetTime = now + remaining）
/// - 每秒重算 remaining = target - now + 已累计暂停时长（基于时间戳，无累积误差）
/// - paused=true 暂停（停表保剩余值）；恢复时把暂停时长累加到偏移，剩余值连续不跳秒
/// - format 占位符：DD=天 / HH=时(24h) / mm=分 / ss=秒
/// - remaining ≤ 0 触发 onEnd 一次

import UIKit
import SnapKit

final class CountDownView: UIView {
    // MARK: - 配置属性

    /// 目标结束时间戳（epoch 秒，绝对时间，优先级高于 remaining）。
    var targetTime: TimeInterval {
        didSet { reset() }
    }

    /// 格式串，占位符 DD/HH/mm/ss，默认 "HH:mm:ss"。
    var format: String = "HH:mm:ss" {
        didSet { updateDisplay() }
    }

    /// 是否自动开始倒计时（与 paused 共同决定 running = autoStart && !paused）。
    var autoStart: Bool = true {
        didSet { reset() }
    }

    /// 半受控暂停：true=暂停（停表保剩余值）；false=继续（暂停时长累加到偏移）。
    var paused: Bool = false {
        didSet {
            if paused { pause() } else { resume() }
        }
    }

    /// 剩余时间归零时触发一次；业务结束动作（跳转/提示）由宿主在此处理。
    var onEnd: (() -> Void)?

    // MARK: - 内部状态

    private let label = UILabel()
    private var timer: Timer?
    /// 已累计的暂停时长（秒）：恢复时把暂停期间流逝的时间折叠进偏移，使剩余值连续。
    private var pausedAccum: TimeInterval = 0
    /// 当前正在进行中的暂停起点（epoch 秒），nil=未暂停。
    private var pauseStart: TimeInterval?
    /// 是否已结束（防止 onEnd 多次触发）。
    private var ended = false

    // MARK: - 初始化

    /// 完整初始化。
    init(
        targetTime: TimeInterval = 0,
        remaining: TimeInterval = 0,
        format: String = "HH:mm:ss",
        autoStart: Bool = true,
        paused: Bool = false,
        onEnd: (() -> Void)? = nil
    ) {
        // targetTime 优先；为 0 时使用 remaining 转 targetTime = now + remaining。
        self.targetTime = targetTime > 0 ? targetTime : Date().timeIntervalSince1970 + remaining
        self.format = format
        self.autoStart = autoStart
        self.paused = paused
        self.onEnd = onEnd
        super.init(frame: .zero)
        setup()
        // init 中 didSet 不触发，需手动启动。
        if paused {
            pause()
        } else if autoStart {
            start()
        } else {
            updateDisplay()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("CountDownView does not support NSCoder")
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - 布局

    private func setup() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        label.font = UIFont.monospacedDigitSystemFont(ofSize: AppFont.sizeLg, weight: .semibold)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        updateDisplay()
    }

    /// 透传 label 的固有尺寸，便于在 UIStackView 等场景正确撑开。
    override var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }

    // MARK: - 计时控制

    /// 开始/恢复计时：先把暂停时长折叠进累计偏移，再重建 Timer（与 CarouselView 同款 Timer.scheduledTimer 老写法）。
    private func start() {
        guard !ended else { return }
        // 折叠暂停时长
        if let ps = pauseStart {
            pausedAccum += Date().timeIntervalSince1970 - ps
            pauseStart = nil
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // 立即触发一次，避免初始 1 秒延迟。
        tick()
    }

    /// 暂停计时：记录暂停起点并停表（剩余值冻结）。
    private func pause() {
        guard autoStart, !ended, pauseStart == nil else { return }
        pauseStart = Date().timeIntervalSince1970
        timer?.invalidate()
        timer = nil
    }

    /// 恢复计时（paused 由 false 驱动时调用）。
    private func resume() {
        guard autoStart, !ended else { return }
        start()
    }

    /// 重置内部状态（targetTime/autoStart 变化时调用）。
    private func reset() {
        timer?.invalidate()
        timer = nil
        pausedAccum = 0
        pauseStart = nil
        ended = false
        updateDisplay()
        if autoStart, !paused {
            start()
        }
    }

    // MARK: - tick

    private func tick() {
        let now = Date().timeIntervalSince1970
        // 进行中的暂停时长：暂停期间 now 持续增长，加上 ongoing 后 rem 保持恒定（冻结）。
        let ongoing = pauseStart.map { now - $0 } ?? 0
        let rem = targetTime - now + pausedAccum + ongoing
        if rem <= 0 {
            updateDisplay(remaining: 0)
            if !ended {
                ended = true
                timer?.invalidate()
                timer = nil
                onEnd?()
            }
        } else {
            updateDisplay(remaining: rem)
        }
    }

    // MARK: - 显示

    private func updateDisplay(remaining: TimeInterval) {
        label.text = Self.formatCountDown(remainingSeconds: remaining, format: format)
    }

    /// 用当前时间重算一次显示值（不启动/停止 Timer）。
    private func updateDisplay() {
        let now = Date().timeIntervalSince1970
        let ongoing = pauseStart.map { now - $0 } ?? 0
        let rem = max(0, targetTime - now + pausedAccum + ongoing)
        updateDisplay(remaining: rem)
    }

    // MARK: - 格式化

    /// 倒计时格式化：用占位符 DD/HH/mm/ss 替换为 2 位数字，其余字符原样保留。
    static func formatCountDown(remainingSeconds: TimeInterval, format: String) -> String {
        let total = Int(max(0, remainingSeconds.rounded(.down)))
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return format
            .replacingOccurrences(of: "DD", with: String(format: "%02d", days))
            .replacingOccurrences(of: "HH", with: String(format: "%02d", hours))
            .replacingOccurrences(of: "mm", with: String(format: "%02d", minutes))
            .replacingOccurrences(of: "ss", with: String(format: "%02d", seconds))
    }
}
