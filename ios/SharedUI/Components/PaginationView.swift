/// Pagination 分页组件（UIKit 版，对齐 Android Pagination）。
///
/// 受控页码驱动的分页器——当数据总量较大需分页浏览时提供上一页/下一页 + 页码按钮翻页，
/// 或简洁模式（x/y 文本）翻页，页码超量时自动省略号折叠。
/// currentValue 驱动当前页（>0=受控，0=内部自管理初始 defaultValue），total + pageSize
/// 计算总页数，itemSize 控制可见页码按钮数（超出自动省略号折叠），mode 切换 multi/simple。
///
/// 用法：
/// ```swift
/// let pager = PaginationView()
/// pager.total = 100
/// pager.pageSize = 10
/// pager.itemSize = 5
/// // 受控：pager.currentValue = 3
/// pager.onChange = { page in print("翻到第 \(page) 页") }
/// ```
///
/// 决策（与设计规格 pagination-design-spec.html 一致）：
/// - P1-C 混合受控：currentValue > 0=受控，0=内部自管理
/// - P2-A 标准滑动窗口省略号：当前页居中 window + 首尾固定 + 省略号折叠
/// - P3-A 支持简洁模式 simple（x/y 文本）
/// - P4-A 一期=基础翻页/简洁/省略号/自定义按钮数+demo 四段
///
/// 注：标题点击遵循手册禁令——用 UITapGestureRecognizer(target:action:) + objc 方法，
/// 不用 UIAction/addAction(for:) block 新 API（iOS14+）。

import UIKit
import SnapKit

/// 分页模式。
enum PaginationMode {
    /// 按钮模式：上一页/下一页 + 页码按钮（含省略号）。
    case multi
    /// 简洁模式：上一页/下一页 + x/y 文本。
    case simple
}

/// 分页按钮项（页码或省略号）。
enum PaginationButton {
    case page(Int)
    case ellipsis
}

final class PaginationView: UIView {
    // MARK: - 配置属性

    /// 当前页（1-based）；0=内部自管理状态（初始取 defaultValue），>0=受控。
    var currentValue: Int = 0 {
        didSet { applyState() }
    }

    /// 默认当前页（非受控初始值）。
    var defaultValue: Int = 1

    /// 数据总条数。设置后重建按钮。
    var total: Int = 0 { didSet { rebuild() } }

    /// 每页条数。设置后重建按钮。
    var pageSize: Int = 10 { didSet { rebuild() } }

    /// 可见页码按钮数（超出自动省略号折叠）。设置后重建按钮。
    var itemSize: Int = 5 { didSet { rebuild() } }

    /// 分页模式。设置后重建按钮。
    var mode: PaginationMode = .multi { didSet { rebuild() } }

    /// 自定义上一页按钮文案（nil=默认 chevron 箭头）。设置后重建按钮。
    var prevText: String? = nil { didSet { rebuild() } }

    /// 自定义下一页按钮文案（nil=默认 chevron 箭头）。设置后重建按钮。
    var nextText: String? = nil { didSet { rebuild() } }

    /// 翻页回调，返回目标页码。
    var onChange: ((Int) -> Void)?

    // MARK: - 内部状态

    /// 内部自管理当前页（currentValue==0 时生效）。
    private var internalPage: Int = 1

    /// 当前的有效当前页（受控优先，否则内部）。
    private var effectivePage: Int {
        currentValue > 0 ? currentValue : internalPage
    }

    /// 横向容器：上一页 + 页码/简洁文本 + 下一页。
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = AppSpace.xs
        stack.alignment = .center
        return stack
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("PaginationView does not support NSCoder")
    }

    private func setup() {
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true

        addSubview(containerStack)
        containerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: AppSpace.sm, left: AppSpace.sm, bottom: AppSpace.sm, right: AppSpace.sm))
        }
    }

    // MARK: - 总页数

    /// 计算总页数（向上取整）。
    private var totalPages: Int {
        guard total > 0, pageSize > 0 else { return 0 }
        return (total + pageSize - 1) / pageSize
    }

    // MARK: - 重建布局

    /// 全量重建：清空容器并按当前状态重新生成按钮。
    private func rebuild() {
        containerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let pages = totalPages
        guard pages > 0 else { return }

        // 当前页 clamp 到 [1, pages]。
        let page = min(max(effectivePage, 1), pages)

        // 上一页按钮：page<=1 时禁用。
        let prev = makeNavButton(isPrev: true, disabled: page <= 1)
        containerStack.addArrangedSubview(prev)

        if mode == .simple {
            // 简洁模式：x/y 文本（当前页 primary 高亮）。
            let label = makeSimpleLabel(current: page, total: pages)
            containerStack.addArrangedSubview(label)
        } else {
            // 按钮模式：页码按钮 + 省略号折叠。
            let buttons = Self.computeButtons(current: page, total: pages, itemSize: itemSize)
            for button in buttons {
                switch button {
                case .page(let n):
                    let btn = makePageButton(page: n, selected: n == page)
                    containerStack.addArrangedSubview(btn)
                case .ellipsis:
                    let el = makeEllipsis()
                    containerStack.addArrangedSubview(el)
                }
            }
        }

        // 下一页按钮：page>=pages 时禁用。
        let next = makeNavButton(isPrev: false, disabled: page >= pages)
        containerStack.addArrangedSubview(next)
    }

    /// 状态变化后重建（受控/内部切换均走此处）。
    private func applyState() {
        rebuild()
    }

    // MARK: - 按钮工厂

    /// 上一页/下一页按钮：chevron 箭头或自定义文本。
    private func makeNavButton(isPrev: Bool, disabled: Bool) -> UIView {
        let view = UIView()
        // tag：-1=上一页，-2=下一页（避开页码 1+）。
        view.tag = isPrev ? -1 : -2
        view.isUserInteractionEnabled = !disabled
        // 手册禁令：用 target/action + objc，不用 UIAction block。
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNavTap(_:)))
        view.addGestureRecognizer(tap)

        if let text = isPrev ? prevText : nextText {
            // 自定义文本按钮。
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: AppFont.sizeSm)
            label.textColor = disabled ? AppColor.gray25 : AppColor.textSecondary
            label.textAlignment = .center
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        } else {
            // 默认 chevron 箭头。
            let name = isPrev ? "chevron.left" : "chevron.right"
            let iv = UIImageView(image: UIImage(systemName: name))
            iv.tintColor = disabled ? AppColor.gray25 : AppColor.textSecondary
            iv.contentMode = .scaleAspectFit
            view.addSubview(iv)
            iv.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(AppSpace.lg)
            }
        }
        view.snp.makeConstraints { make in
            make.width.height.equalTo(AppSpace.lg)
        }
        return view
    }

    /// 页码按钮：selected 反白（primary 底白字），非 selected 透明底。
    private func makePageButton(page: Int, selected: Bool) -> UIView {
        let view = UIView()
        view.tag = page
        view.backgroundColor = selected ? AppColor.primary : .clear
        view.layer.cornerRadius = AppRadius.sm
        // 非选中页可点击翻页；选中页不可点（已在当前页）。
        view.isUserInteractionEnabled = !selected
        if !selected {
            // 手册禁令：用 target/action + objc，不用 UIAction block。
            let tap = UITapGestureRecognizer(target: self, action: #selector(handlePageTap(_:)))
            view.addGestureRecognizer(tap)
        }

        let label = UILabel()
        label.text = "\(page)"
        label.font = .systemFont(ofSize: AppFont.sizeSm, weight: selected ? .semibold : .regular)
        label.textColor = selected ? .white : AppColor.textPrimary
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.snp.makeConstraints { make in
            make.width.height.equalTo(AppSpace.lg)
        }
        return view
    }

    /// 省略号占位：gray25，不可点。
    private func makeEllipsis() -> UIView {
        let view = UIView()
        let label = UILabel()
        label.text = "···"
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textColor = AppColor.gray25
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.snp.makeConstraints { make in
            make.width.height.equalTo(AppSpace.lg)
        }
        return view
    }

    /// 简洁模式文本：当前页 primary 高亮 + " / " + 总页数 textPrimary。
    private func makeSimpleLabel(current: Int, total: Int) -> UIView {
        let view = UIView()
        let label = UILabel()
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(
            string: "\(current)",
            attributes: [
                .font: UIFont.systemFont(ofSize: AppFont.sizeSm, weight: .semibold),
                .foregroundColor: AppColor.primary,
            ]
        ))
        attr.append(NSAttributedString(
            string: " / \(total)",
            attributes: [
                .font: UIFont.systemFont(ofSize: AppFont.sizeSm),
                .foregroundColor: AppColor.textPrimary,
            ]
        ))
        label.attributedText = attr
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(AppSpace.lg)
        }
        return view
    }

    // MARK: - 点击处理

    /// 上一页/下一页点击：tag=-1 上一页，tag=-2 下一页。
    @objc private func handleNavTap(_ gesture: UITapGestureRecognizer) {
        let pages = totalPages
        guard pages > 0 else { return }
        var page = min(max(effectivePage, 1), pages)
        if gesture.view?.tag == -1 {
            page -= 1
        } else {
            page += 1
        }
        page = min(max(page, 1), pages)
        goTo(page: page)
    }

    /// 页码按钮点击：tag=目标页码。
    @objc private func handlePageTap(_ gesture: UITapGestureRecognizer) {
        guard let page = gesture.view?.tag, page > 0 else { return }
        goTo(page: page)
    }

    /// 翻到指定页：更新内部态（非受控时）、回调、重建。
    private func goTo(page: Int) {
        if currentValue == 0 {
            internalPage = page
        }
        onChange?(page)
        // 受控态由外部驱动重建（currentValue didSet）；非受控主动重建。
        if currentValue == 0 {
            applyState()
        }
    }

    // MARK: - 省略号折叠算法

    /// 计算页码按钮序列：总页数 ≤ itemSize 全量；否则当前页居中 window + 首尾固定 + 省略号。
    ///
    /// - Parameters:
    ///   - current: 当前页（1-based，已 clamp）。
    ///   - total: 总页数。
    ///   - itemSize: 可见页码按钮数。
    /// - Returns: 按钮序列（页码 or 省略号）。
    static func computeButtons(current: Int, total: Int, itemSize: Int) -> [PaginationButton] {
        guard total > 0 else { return [] }
        // 总页数不超过 itemSize → 全量渲染。
        if total <= itemSize {
            return (1...total).map { PaginationButton.page($0) }
        }
        // 当前页居中 window：left = current - (itemSize-1)/2，right = left + itemSize - 1。
        let half = (itemSize - 1) / 2
        var left = current - half
        var right = left + itemSize - 1
        // 边界 clamp：window 不越过 [1, total]。
        if left < 1 {
            left = 1
            right = itemSize
        }
        if right > total {
            right = total
            left = total - itemSize + 1
        }

        var result: [PaginationButton] = []
        // 左侧：left>1 显首页，left>2 加省略号。
        if left > 1 {
            result.append(.page(1))
            if left > 2 {
                result.append(.ellipsis)
            }
        }
        // window。
        for i in left...right {
            result.append(.page(i))
        }
        // 右侧：right<total 显末页，right<total-1 加省略号。
        if right < total {
            if right < total - 1 {
                result.append(.ellipsis)
            }
            result.append(.page(total))
        }
        return result
    }
}
