/// Ellipsis 文本省略组件（UIKit 版，对齐 Android Ellipsis）。
///
/// 文本超出指定行数时自动截断显示省略号，支持点击展开/收起。
/// 纯展示型文本截断组件，content+rows 自动尾部截断，
/// expandText/collapseText 控制展开收起文案，
/// expanded 半受控（nil=内部自持/非 nil=外部驱动），onExpandChange 回调。
///
/// 用法：
/// ```swift
/// // 默认=内部自持，点击自动展开/收起
/// let ellipsis = EllipsisView(content: "长文本…", rows: 3)
///
/// // 受控模式=外部驱动
/// let ellipsis = EllipsisView(content: "长文本…", rows: 2, expanded: false)
/// ellipsis.expanded = true  // 外部驱动展开
/// ```
///
/// 截断规则（与设计规格 ellipsis-design-spec.html 一致）：
/// - 收起态：UILabel numberOfLines=rows + lineBreakMode=.byTruncatingTail 尾部截断
/// - 展开态：UILabel numberOfLines=0 不截断显示全文
/// - expanded=nil：内部自持 state，点击自动切换
/// - expanded!=nil：受控模式，state 由外部驱动，内部不自持

import UIKit
import SnapKit

/// 省略方向（一期仅 tail，middle/head = 二期 anti_goal）。
enum EllipsisDirection {
    case tail
}

final class EllipsisView: UIView {
    // MARK: - 配置属性

    /// 要显示的文本内容。
    var content: String { didSet { updateUI() } }

    /// 最大显示行数，超出时截断显示省略号，默认 1。
    var rows: Int { didSet { updateUI() } }

    /// 省略方向，默认 .tail（一期仅支持尾部）。
    var direction: EllipsisDirection { didSet { updateUI() } }

    /// 展开按钮文案，默认「展开」。
    var expandText: String { didSet { updateUI() } }

    /// 收起按钮文案，默认「收起」。
    var collapseText: String { didSet { updateUI() } }

    /// 半受控展开态：nil=内部自持点击切换，非 nil=外部驱动受控。
    var expanded: Bool? { didSet { updateUI() } }

    /// 展开态变化回调（expanded 新值）。
    var onExpandChange: ((Bool) -> Void)?

    // MARK: - 内部状态

    /// 内部自持展开态（仅 expanded=nil 时使用）。
    private var internalExpanded: Bool = false

    /// 当前展开态（expanded 非 nil 用外部值，nil 用内部值）。
    private var isExpanded: Bool {
        expanded ?? internalExpanded
    }

    // MARK: - 子视图

    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColor.textPrimary
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let toggleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColor.primary
        label.font = .systemFont(ofSize: AppFont.sizeSm, weight: .medium)
        label.isUserInteractionEnabled = false
        return label
    }()

    // MARK: - 初始化

    /// 完整初始化。
    init(
        content: String,
        rows: Int = 1,
        direction: EllipsisDirection = .tail,
        expandText: String = "展开",
        collapseText: String = "收起",
        expanded: Bool? = nil,
        onExpandChange: ((Bool) -> Void)? = nil
    ) {
        self.content = content
        self.rows = rows
        self.direction = direction
        self.expandText = expandText
        self.collapseText = collapseText
        self.expanded = expanded
        self.onExpandChange = onExpandChange
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("EllipsisView does not support NSCoder")
    }

    // MARK: - 布局

    private func setup() {
        // 点击切换：使用老式 UITapGestureRecognizer(target:action:)（兼容低版本）。
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true

        addSubview(textLabel)
        addSubview(toggleLabel)

        textLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        toggleLabel.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(AppSpace.xs)
            make.leading.trailing.bottom.equalToSuperview()
        }

        updateUI()
    }

    // MARK: - 交互

    /// 点击切换展开/收起态。
    /// expanded=nil 时内部自持 state 切换；非 nil 时仅触发回调（外部驱动）。
    @objc private func handleTap() {
        let newValue = !isExpanded
        if expanded == nil {
            internalExpanded = newValue
            updateUI()
        }
        onExpandChange?(newValue)
    }

    // MARK: - UI 更新

    /// 根据 content/rows/expanded 等配置更新文本与展开按钮。
    private func updateUI() {
        textLabel.text = content
        // 收起态=rows 行截断；展开态=0 不截断显示全文。
        textLabel.numberOfLines = isExpanded ? 0 : max(rows, 1)
        // 展开按钮文案
        toggleLabel.text = isExpanded ? collapseText : expandText
    }
}
