/// 宫格 Grid：多格图标入口矩阵（卡片壳 + 分区标题 + 等分图标网格）。
///
/// 组件 ID：`ui.grid`（api.json 契约对齐，门禁 A 评审通过 2026-09-04）。
/// 命名：Grid（非 NavigationGrid），与 api.json id 一致，iOS 去 View 后缀规范。

import UIKit
import SnapKit

/// 宫格入口数据项。
struct GridItem {
    let title: String
    let symbolName: String
}

/// 多格图标入口矩阵（卡片壳 + 可选分区标题 + 等分图标网格）。
///
/// 支持：
/// - `column` 列数（默认 4，支持 3/4/5）
/// - `title` 可选（空字符串时不显示标题区域）
/// - 超过 column 数量自动换行
/// - `onSelect` 点击回调（返回索引）
final class Grid: UIView {

    /// 点击回调（返回点击项的索引）。
    var onSelect: ((Int) -> Void)?

    /// 列数（默认 4）。修改后需调用 `apply` 重新绑定。
    var column: Int = 4

    private let titleLabel = UILabel()
    private let gridContainer = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardShell()
        setupTitleLabel()
        setupGridContainer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - 卡片壳

    private func setupCardShell() {
        backgroundColor = .white
        layer.cornerRadius = AppRadius.lg
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = AppColor.border.cgColor
    }

    // MARK: - 分区标题（可选）

    private func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(AppSpace.lg)
        }
    }

    // MARK: - 网格容器

    private func setupGridContainer() {
        gridContainer.axis = .vertical
        gridContainer.spacing = AppSpace.sm
        addSubview(gridContainer)
        gridContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(AppSpace.lg)
        }
    }

    // MARK: - 绑定数据

    /// 绑定分区标题与入口列表。
    ///
    /// - Parameters:
    ///   - title: 分区标题（空字符串=不显示标题区域）
    ///   - items: 入口列表
    func apply(title: String, items: [GridItem]) {
        // 标题：空字符串时隐藏
        titleLabel.text = title
        titleLabel.isHidden = title.isEmpty

        // 标题与网格间距（有标题时生效）
        gridContainer.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(AppSpace.lg)
            if title.isEmpty {
                make.top.equalToSuperview().offset(AppSpace.lg)
            } else {
                make.top.equalTo(titleLabel.snp.bottom).offset(AppSpace.md)
            }
        }

        // 清空旧行
        gridContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 按 column 分行
        let rows = stride(from: 0, to: items.count, by: column).map { start in
            Array(items[start..<min(start + column, items.count)])
        }

        var globalIndex = 0
        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill  // fill 让 control 填满行区域，确保可点击
            gridContainer.addArrangedSubview(rowStack)
            rowStack.snp.makeConstraints { make in
                make.height.equalTo(72)
            }

            // 填充 item
            for item in row {
                let itemView = makeItemView(item, globalIndex: globalIndex)
                rowStack.addArrangedSubview(itemView)
                globalIndex += 1
            }

            // 不足 column 列时用空视图填充（保持等分对齐）
            for _ in row.count..<column {
                let spacer = UIView()
                rowStack.addArrangedSubview(spacer)
            }
        }
    }

    // MARK: - 单个入口项

    private func makeItemView(_ item: GridItem, globalIndex: Int) -> UIView {
        let control = UIControl()
        control.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
        control.addTarget(self, action: #selector(itemTouchDown(_:)), for: .touchDown)
        control.addTarget(self, action: #selector(itemTouchUp(_:)), for: .touchUpOutside)
        control.addTarget(self, action: #selector(itemTouchUp(_:)), for: .touchCancel)
        control.tag = globalIndex
        control.backgroundColor = .clear  // 初始透明背景

        // 图标容器（绿色背景 + 白色图标，与设计规格一致）
        let iconContainer = UIView()
        iconContainer.backgroundColor = AppColor.primary
        iconContainer.layer.cornerRadius = 6
        
        let icon = UIImageView(image: UIImage(systemName: item.symbolName))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        iconContainer.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        let label = UILabel()
        label.text = item.title
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2

        let col = UIStackView(arrangedSubviews: [iconContainer, label])
        col.axis = .vertical
        col.spacing = AppSpace.xs
        col.alignment = .center
        col.distribution = .equalCentering
        col.isLayoutMarginsRelativeArrangement = true
        col.layoutMargins = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        col.isUserInteractionEnabled = false

        control.addSubview(col)
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(26)
        }
        col.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return control
    }

    @objc private func itemTapped(_ sender: UIControl) {
        onSelect?(sender.tag)
        UIView.animate(withDuration: 0.15) {
            sender.backgroundColor = .clear
            sender.alpha = 1.0
        }
    }
    
    @objc private func itemTouchDown(_ sender: UIControl) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor(white: 0, alpha: 0.05)  // 轻微灰色背景
            sender.alpha = 0.7
        }
    }
    
    @objc private func itemTouchUp(_ sender: UIControl) {
        UIView.animate(withDuration: 0.15) {
            sender.backgroundColor = .clear
            sender.alpha = 1.0
        }
    }
}
