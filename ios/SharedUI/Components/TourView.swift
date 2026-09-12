/// Tour 引导组件（UIKit 版，对齐 Android Tour）。
///
/// 步骤式引导浮层：全屏遮罩 + 中央提示卡片。
/// 支持跳过、上一步/下一步、完成。

import UIKit
import SnapKit

/// 引导步骤。
struct TourStep {
    let title: String
    let description: String
}

/// Tour 引导组件。
final class TourView: UIView {
    // MARK: - 配置

    var steps: [TourStep] = [] { didSet { updateContent() } }
    var current: Int = 0 { didSet { updateContent() } }
    var onChange: ((Int) -> Void)?
    var onFinish: (() -> Void)?
    var maskColor: UIColor = UIColor.black.withAlphaComponent(0.7) { didSet { overlayView.backgroundColor = maskColor } }
    var showSkip: Bool = true { didSet { updateContent() } }

    // MARK: - 子视图

    private let overlayView = UIView()
    private let card = UIView()
    private let stepLabel = UILabel()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let skipButton = UIButton(type: .system)
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)

        overlayView.backgroundColor = maskColor
        addSubview(overlayView)
        overlayView.snp.makeConstraints { make in make.edges.equalToSuperview() }

        card.backgroundColor = AppColor.bgCard
        card.layer.cornerRadius = AppRadius.lg
        card.clipsToBounds = true
        addSubview(card)
        card.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpace.xl)
        }

        // 步骤指示
        stepLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        stepLabel.textColor = AppColor.gray25
        card.addSubview(stepLabel)

        // 标题
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.numberOfLines = 0
        card.addSubview(titleLabel)

        // 描述
        descLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        descLabel.textColor = AppColor.textSecondary
        descLabel.numberOfLines = 0
        card.addSubview(descLabel)

        // 跳过
        skipButton.setTitle("跳过", for: .normal)
        skipButton.setTitleColor(AppColor.gray25, for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        card.addSubview(skipButton)

        // 上一步
        prevButton.setTitle("上一步", for: .normal)
        prevButton.setTitleColor(AppColor.textPrimary, for: .normal)
        prevButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .medium)
        prevButton.backgroundColor = AppColor.bgPage
        prevButton.layer.cornerRadius = AppRadius.sm
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        card.addSubview(prevButton)

        // 下一步/完成
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .medium)
        nextButton.backgroundColor = AppColor.primary
        nextButton.layer.cornerRadius = AppRadius.sm
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        card.addSubview(nextButton)

        // 约束
        stepLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppSpace.lg)
            make.leading.equalToSuperview().offset(AppSpace.lg)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(stepLabel.snp.bottom).offset(AppSpace.sm)
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpace.xs)
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
        }
        skipButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.top.equalTo(descLabel.snp.bottom).offset(AppSpace.lg)
            make.bottom.equalToSuperview().offset(-AppSpace.lg)
        }
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
            make.top.equalTo(descLabel.snp.bottom).offset(AppSpace.lg)
            make.bottom.equalToSuperview().offset(-AppSpace.lg)
            make.height.equalTo(36)
        }
        prevButton.snp.makeConstraints { make in
            make.trailing.equalTo(nextButton.snp.leading).offset(-AppSpace.sm)
            make.top.equalTo(nextButton)
            make.bottom.equalTo(nextButton)
            make.height.equalTo(36)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("TourView does not support NSCoder") }

    // MARK: - 更新

    private func updateContent() {
        guard current < steps.count else { return }
        let step = steps[current]
        let isLast = current >= steps.count - 1

        stepLabel.text = "\(current + 1) / \(steps.count)"
        titleLabel.text = step.title
        descLabel.text = step.description

        skipButton.isHidden = !showSkip
        prevButton.isHidden = current <= 0
        nextButton.setTitle(isLast ? "完成" : "下一步", for: .normal)
    }

    // MARK: - 点击

    @objc private func skipTapped() { onFinish?() }
    @objc private func prevTapped() { if current > 0 { onChange?(current - 1) } }
    @objc private func nextTapped() {
        let isLast = current >= steps.count - 1
        if isLast { onFinish?() } else { onChange?(current + 1) }
    }
}
