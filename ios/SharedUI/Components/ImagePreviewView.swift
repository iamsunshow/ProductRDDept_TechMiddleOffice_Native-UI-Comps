/// ImagePreview 图片预览组件（UIKit 版，对齐 Android ImagePreview）。
///
/// 全屏图片预览：支持多图横滑切换、页码指示器、点击关闭。
/// 一期实现：基础全屏展示 + 横滑翻页 + 指示器。缩放/拖拽关闭二期。

import UIKit
import SnapKit

/// 图片数据源。
struct ImageSource {
    let url: String
}

/// 图片预览组件。
final class ImagePreviewView: UIView {
    // MARK: - 配置

    var images: [ImageSource] = [] { didSet { rebuild() } }
    var initialIndex: Int = 0 { didSet { scrollTo(index: initialIndex, animated: false) } }
    var visible: Bool = false { didSet { isHidden = !visible } }
    var onDismiss: (() -> Void)?
    var onPageChange: ((Int) -> Void)?
    var showIndicator: Bool = true { didSet { updateIndicator() } }

    // MARK: - 子视图

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let indicatorStack = UIStackView()
    private let pageLabel = UILabel()
    private var dots: [UIView] = []

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        isHidden = true

        // 滚动容器
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in make.edges.equalToSuperview() }

        contentStack.axis = .horizontal
        contentStack.spacing = 0
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 页码指示器
        indicatorStack.axis = .horizontal
        indicatorStack.spacing = AppSpace.xs
        indicatorStack.alignment = .center
        addSubview(indicatorStack)
        indicatorStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-AppSpace.xl)
        }

        // 页码文本
        pageLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        pageLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        pageLabel.textAlignment = .center
        addSubview(pageLabel)
        pageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide).offset(AppSpace.xl)
        }

        // 点击关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("ImagePreviewView does not support NSCoder") }

    // MARK: - 重建

    private func rebuild() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        for (index, _) in images.enumerated() {
            // 一期占位：色块 + 序号
            let page = UIView()
            page.backgroundColor = UIColor(red: 0.12, green: 0.16, blue: 0.22, alpha: 1)
            page.snp.makeConstraints { make in make.width.equalTo(snp.width) }

            let numLabel = UILabel()
            numLabel.text = "\(index + 1)"
            numLabel.font = .systemFont(ofSize: AppFont.sizeDisplay, weight: .bold)
            numLabel.textColor = .white
            numLabel.textAlignment = .center
            page.addSubview(numLabel)
            numLabel.snp.makeConstraints { make in make.center.equalToSuperview() }

            contentStack.addArrangedSubview(page)

            // 圆点
            let dot = UIView()
            dot.layer.cornerRadius = 3
            dot.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            dot.snp.makeConstraints { make in make.size.equalTo(6) }
            indicatorStack.addArrangedSubview(dot)
            dots.append(dot)
        }

        updateIndicator()
        scrollTo(index: initialIndex, animated: false)
    }

    // MARK: - 指示器更新

    private func updateIndicator() {
        indicatorStack.isHidden = !showIndicator || images.count <= 1
        pageLabel.isHidden = !showIndicator || images.count <= 1
    }

    private func updateCurrentPage(_ page: Int) {
        for (index, dot) in dots.enumerated() {
            let isCurrent = index == page
            dot.snp.updateConstraints { make in
                // SnapKit updateConstraints 只更新已有约束的 constant
            }
            dot.backgroundColor = isCurrent ? .white : UIColor.white.withAlphaComponent(0.4)
        }
        pageLabel.text = "\(page + 1) / \(images.count)"
        onPageChange?(page)
    }

    // MARK: - 滚动

    private func scrollTo(index: Int, animated: Bool) {
        guard index < images.count else { return }
        let x = CGFloat(index) * bounds.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
        updateCurrentPage(index)
    }

    // MARK: - 点击

    @objc private func tapped() { onDismiss?() }
}

// MARK: - UIScrollViewDelegate

extension ImagePreviewView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / bounds.width)
        updateCurrentPage(page)
    }
}
