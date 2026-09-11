/// Table 表格组件（UIKit 版，对齐 Android Table）。
///
/// 数据表格：行列布局，支持表头吸顶、斑马纹、自定义列宽、对齐方式。

import UIKit
import SnapKit

/// 列定义。
struct TableColumnDef {
    let title: String
    let width: CGFloat?
    let align: NSTextAlignment

    init(title: String, width: CGFloat? = nil, align: NSTextAlignment = .natural) {
        self.title = title
        self.width = width
        self.align = align
    }
}

/// 行数据。
struct TableRowData {
    let cells: [String]
}

/// 表格组件。
final class TableView: UIView {
    // MARK: - 配置

    var columns: [TableColumnDef] = [] { didSet { rebuild() } }
    var data: [TableRowData] = [] { didSet { rebuild() } }
    var striped: Bool = false { didSet { rebuild() } }
    var stickyHeader: Bool = false { didSet { rebuild() } }

    // MARK: - 子视图

    private let container = UIStackView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = AppColor.border.cgColor
        backgroundColor = AppColor.bgCard

        container.axis = .vertical
        container.spacing = 0
        addSubview(container)
        container.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("TableView does not support NSCoder") }

    // MARK: - 重建

    private func rebuild() {
        container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !columns.isEmpty else { return }

        // 表头
        let headerRow = makeRow(
            cells: columns.map { $0.title },
            isHeader: true,
            bgColor: stickyHeader ? AppColor.bgPage : AppColor.bgCard
        )
        container.addArrangedSubview(headerRow)

        // 分隔线
        let sep = UIView()
        sep.backgroundColor = AppColor.border
        sep.snp.makeConstraints { make in make.height.equalTo(0.5) }
        container.addArrangedSubview(sep)

        // 数据行
        for (index, row) in data.enumerated() {
            let bgColor: UIColor = (striped && index % 2 == 1) ? AppColor.bgPage : AppColor.bgCard
            let dataRow = makeRow(cells: row.cells, isHeader: false, bgColor: bgColor)
            container.addArrangedSubview(dataRow)

            if index < data.count - 1 {
                let rowSep = UIView()
                rowSep.backgroundColor = AppColor.border
                rowSep.snp.makeConstraints { make in make.height.equalTo(0.5) }
                container.addArrangedSubview(rowSep)
            }
        }
    }

    // MARK: - 行工厂

    private func makeRow(cells: [String], isHeader: Bool, bgColor: UIColor) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fill
        stack.backgroundColor = bgColor
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: AppSpace.sm, left: AppSpace.sm, bottom: AppSpace.sm, right: AppSpace.sm)

        for (index, cell) in cells.enumerated() {
            let label = UILabel()
            label.text = cell
            label.font = .systemFont(ofSize: AppFont.sizeSm, weight: isHeader ? .semibold : .regular)
            label.textColor = isHeader ? AppColor.textPrimary : AppColor.textSecondary
            label.textAlignment = columns[index].align
            label.numberOfLines = 2
            label.lineBreakMode = .byTruncatingTail

            if let w = columns[index].width {
                label.snp.makeConstraints { make in make.width.equalTo(w) }
            } else {
                label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            }

            stack.addArrangedSubview(label)

            // 列分隔线
            if index < columns.count - 1 {
                let colSep = UIView()
                colSep.backgroundColor = AppColor.border
                colSep.snp.makeConstraints { make in make.width.equalTo(0.5) }
                stack.addArrangedSubview(colSep)
            }
        }
        return stack
    }
}
