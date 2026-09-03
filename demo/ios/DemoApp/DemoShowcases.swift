import UIKit
import SnapKit

// MARK: - Demo 组件索引
// 数据源：docs/组件进度.md 任务清单（7 大类，95 组件）。
// reviewed=true：已通过评审，可点击进入该组件 Demo 页；reviewed=false：未评审，列表置灰不可点。
// 每评审完一个组件：将 reviewed 置 true 并提供 create，Demo 即自动出现。

struct DemoComponent {
    let id: String
    let name: String
    let reviewed: Bool
    let create: (() -> UIViewController)?
}

// MARK: - Demo 首页 · 组件列表（分类 + 组件）

final class DemoListViewController: UITableViewController {

    private let sections: [(category: String, components: [DemoComponent])] = [
        ("基础组件", [
            DemoComponent(id: "ui.button", name: "Button 按钮", reviewed: true, create: { ButtonShowcase() }),
            DemoComponent(id: "ui.cell", name: "Cell 单元格", reviewed: true, create: { CellShowcase() }),
            DemoComponent(id: "ui.config-provider", name: "ConfigProvider 全局配置", reviewed: true, create: { ConfigProviderShowcase() }),
            DemoComponent(id: "ui.icon", name: "Icon 图标", reviewed: true, create: { IconShowcase() }),
            DemoComponent(id: "ui.image", name: "Image 图片", reviewed: true, create: { ImageShowcase() }),
            DemoComponent(id: "ui.overlay", name: "Overlay 遮罩层", reviewed: false, create: nil),
        ]),
        ("布局组件", [
            DemoComponent(id: "ui.divider", name: "Divider 分割线", reviewed: false, create: nil),
            DemoComponent(id: "ui.grid", name: "Grid 宫格", reviewed: false, create: nil),
            DemoComponent(id: "ui.layout", name: "Layout 布局", reviewed: false, create: nil),
            DemoComponent(id: "ui.safe-area", name: "SafeArea 安全区", reviewed: false, create: nil),
            DemoComponent(id: "ui.space", name: "Space 间距", reviewed: false, create: nil),
            DemoComponent(id: "ui.sticky", name: "Sticky 粘性布局", reviewed: false, create: nil),
        ]),
        ("导航组件", [
            DemoComponent(id: "ui.back-top", name: "BackTop 返回顶部", reviewed: false, create: nil),
            DemoComponent(id: "ui.elevator", name: "Elevator 电梯楼层", reviewed: false, create: nil),
            DemoComponent(id: "ui.fixed-nav", name: "FixedNav 悬浮导航", reviewed: false, create: nil),
            DemoComponent(id: "ui.hover-button", name: "HoverButton 悬浮按钮", reviewed: false, create: nil),
            DemoComponent(id: "ui.nav-bar", name: "NavBar 头部导航", reviewed: false, create: nil),
            DemoComponent(id: "ui.side-bar", name: "SideBar 侧边导航", reviewed: false, create: nil),
            DemoComponent(id: "ui.tabbar", name: "Tabbar 标签栏", reviewed: false, create: nil),
            DemoComponent(id: "ui.tabs", name: "Tabs 选项卡", reviewed: false, create: nil),
        ]),
        ("数据录入", [
            DemoComponent(id: "ui.address", name: "Address 地址", reviewed: false, create: nil),
            DemoComponent(id: "ui.calendar", name: "Calendar 日历", reviewed: false, create: nil),
            DemoComponent(id: "ui.calendar-card", name: "CalendarCard 日历卡片", reviewed: false, create: nil),
            DemoComponent(id: "ui.cascader", name: "Cascader 级联选择", reviewed: false, create: nil),
            DemoComponent(id: "ui.checkbox", name: "Checkbox 复选", reviewed: false, create: nil),
            DemoComponent(id: "ui.date-picker", name: "DatePicker 日期选择", reviewed: false, create: nil),
            DemoComponent(id: "ui.date-picker-view", name: "DatePickerView 视图", reviewed: false, create: nil),
            DemoComponent(id: "ui.form", name: "Form 表单", reviewed: false, create: nil),
            DemoComponent(id: "ui.input", name: "Input 输入框", reviewed: false, create: nil),
            DemoComponent(id: "ui.input-number", name: "InputNumber 数字输入", reviewed: false, create: nil),
            DemoComponent(id: "ui.menu", name: "Menu 菜单", reviewed: false, create: nil),
            DemoComponent(id: "ui.number-keyboard", name: "NumberKeyboard 数字键盘", reviewed: false, create: nil),
            DemoComponent(id: "ui.picker", name: "Picker 选择器", reviewed: false, create: nil),
            DemoComponent(id: "ui.picker-view", name: "PickerView 视图", reviewed: false, create: nil),
            DemoComponent(id: "ui.radio", name: "Radio 单选", reviewed: false, create: nil),
            DemoComponent(id: "ui.range", name: "Range 区间选择", reviewed: false, create: nil),
            DemoComponent(id: "ui.rate", name: "Rate 评分", reviewed: false, create: nil),
            DemoComponent(id: "ui.search-bar", name: "SearchBar 搜索栏", reviewed: false, create: nil),
            DemoComponent(id: "ui.short-password", name: "ShortPassword 短密码", reviewed: false, create: nil),
            DemoComponent(id: "ui.signature", name: "Signature 签名", reviewed: false, create: nil),
            DemoComponent(id: "ui.switch", name: "Switch 开关", reviewed: false, create: nil),
            DemoComponent(id: "ui.text-area", name: "TextArea 文本域", reviewed: false, create: nil),
            DemoComponent(id: "ui.uploader", name: "Uploader 上传", reviewed: false, create: nil),
        ]),
        ("操作反馈", [
            DemoComponent(id: "ui.action-sheet", name: "ActionSheet 动作面板", reviewed: false, create: nil),
            DemoComponent(id: "ui.badge", name: "Badge 徽标", reviewed: false, create: nil),
            DemoComponent(id: "ui.dialog", name: "Dialog 对话框", reviewed: false, create: nil),
            DemoComponent(id: "ui.drag", name: "Drag 拖拽", reviewed: false, create: nil),
            DemoComponent(id: "ui.empty", name: "Empty 空状态", reviewed: false, create: nil),
            DemoComponent(id: "ui.infinite-loading", name: "InfiniteLoading 滚动加载", reviewed: false, create: nil),
            DemoComponent(id: "ui.loading", name: "Loading 加载中", reviewed: false, create: nil),
            DemoComponent(id: "ui.notice-bar", name: "NoticeBar 公告栏", reviewed: false, create: nil),
            DemoComponent(id: "ui.notify", name: "Notify 消息通知", reviewed: false, create: nil),
            DemoComponent(id: "ui.popover", name: "Popover 气泡弹出框", reviewed: false, create: nil),
            DemoComponent(id: "ui.popup", name: "Popup 弹出层", reviewed: false, create: nil),
            DemoComponent(id: "ui.pull-to-refresh", name: "PullToRefresh 下拉刷新", reviewed: false, create: nil),
            DemoComponent(id: "ui.result-page", name: "ResultPage 结果反馈", reviewed: false, create: nil),
            DemoComponent(id: "ui.skeleton", name: "Skeleton 骨架屏", reviewed: false, create: nil),
            DemoComponent(id: "ui.swipe", name: "Swipe 滑动", reviewed: false, create: nil),
            DemoComponent(id: "ui.toast", name: "Toast 吐司", reviewed: false, create: nil),
        ]),
        ("展示组件", [
            DemoComponent(id: "ui.animate", name: "Animate 动画", reviewed: false, create: nil),
            DemoComponent(id: "ui.animating-numbers", name: "AnimatingNumbers 数字动画", reviewed: false, create: nil),
            DemoComponent(id: "ui.audio", name: "Audio 音频播放器", reviewed: false, create: nil),
            DemoComponent(id: "ui.avatar", name: "Avatar 头像", reviewed: false, create: nil),
            DemoComponent(id: "ui.circle-progress", name: "CircleProgress 环形进度", reviewed: false, create: nil),
            DemoComponent(id: "ui.collapse", name: "Collapse 折叠面板", reviewed: false, create: nil),
            DemoComponent(id: "ui.count-down", name: "CountDown 倒计时", reviewed: false, create: nil),
            DemoComponent(id: "ui.ellipsis", name: "Ellipsis 文本省略", reviewed: false, create: nil),
            DemoComponent(id: "ui.image-preview", name: "ImagePreview 图片预览", reviewed: false, create: nil),
            DemoComponent(id: "ui.indicator", name: "Indicator 指示器", reviewed: false, create: nil),
            DemoComponent(id: "ui.lottie", name: "Lottie 动画", reviewed: false, create: nil),
            DemoComponent(id: "ui.pagination", name: "Pagination 分页", reviewed: false, create: nil),
            DemoComponent(id: "ui.price", name: "Price 价格", reviewed: false, create: nil),
            DemoComponent(id: "ui.progress", name: "Progress 进度条", reviewed: false, create: nil),
            DemoComponent(id: "ui.segmented", name: "Segmented 分段选择器", reviewed: false, create: nil),
            DemoComponent(id: "ui.steps", name: "Steps 步骤条", reviewed: false, create: nil),
            DemoComponent(id: "ui.swiper", name: "Swiper 轮播", reviewed: false, create: nil),
            DemoComponent(id: "ui.table", name: "Table 表格", reviewed: false, create: nil),
            DemoComponent(id: "ui.tag", name: "Tag 标签", reviewed: false, create: nil),
            DemoComponent(id: "ui.tour", name: "Tour 引导", reviewed: false, create: nil),
            DemoComponent(id: "ui.video", name: "Video 视频播放器", reviewed: false, create: nil),
            DemoComponent(id: "ui.virtual-list", name: "VirtualList 虚拟列表", reviewed: false, create: nil),
        ]),
        ("特色组件", [
            DemoComponent(id: "ui.quick-enter", name: "QuickEnter 快捷入口", reviewed: false, create: nil),
            DemoComponent(id: "ui.avatar-cropper", name: "AvatarCropper 头像裁剪", reviewed: false, create: nil),
            DemoComponent(id: "ui.barrage", name: "Barrage 弹幕", reviewed: false, create: nil),
            DemoComponent(id: "ui.card", name: "Card 商品卡片", reviewed: false, create: nil),
            DemoComponent(id: "ui.time-select", name: "TimeSelect 配送时间", reviewed: false, create: nil),
            DemoComponent(id: "ui.trend-arrow", name: "TrendArrow 趋势箭头", reviewed: false, create: nil),
            DemoComponent(id: "ui.water-mark", name: "WaterMark 水印", reviewed: false, create: nil),
            DemoComponent(id: "ui.calendar-tools", name: "Calendar 日历工具", reviewed: false, create: nil),
            DemoComponent(id: "ui.system-bars", name: "SystemBars 系统栏", reviewed: false, create: nil),
            DemoComponent(id: "ui.design-tokens", name: "DesignTokens 设计令牌", reviewed: false, create: nil),
        ]),
        ("底层能力 foundation", [
            DemoComponent(id: "ui.router", name: "Router 路由", reviewed: false, create: nil),
            DemoComponent(id: "ui.storage", name: "Storage 本地存储", reviewed: false, create: nil),
            DemoComponent(id: "ui.http-client", name: "HTTPClient 网络客户端", reviewed: false, create: nil),
            DemoComponent(id: "ui.money-format", name: "MoneyFormat 金额格式化", reviewed: false, create: nil),
        ]),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TMO 组件 Demo"
        view.backgroundColor = AppColor.bgPage
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
    }

    override func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].components.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].category
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = AppColor.textSecondary
            header.textLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].components[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.name
        config.textProperties.font = .systemFont(ofSize: AppFont.sizeMd)
        if item.reviewed {
            config.textProperties.color = AppColor.textPrimary
            config.secondaryText = "已评审 ✓"
            config.secondaryTextProperties.color = AppColor.primary
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        } else {
            config.textProperties.color = AppColor.gray25
            config.secondaryText = "未评审"
            config.secondaryTextProperties.color = AppColor.gray25
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }
        cell.contentConfiguration = config
        cell.backgroundColor = .white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].components[indexPath.row]
        guard item.reviewed, let create = item.create else { return }
        navigationController?.pushViewController(create(), animated: true)
    }
}

// MARK: - Showcase Base

class ShowcaseViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgPage
        scrollView.alwaysBounceVertical = true
        contentStack.axis = .vertical
        contentStack.spacing = AppSpace.lg
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppSpace.lg)
            make.bottom.equalToSuperview().offset(-AppSpace.xl)
            make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
            make.width.equalTo(scrollView).offset(-AppSpace.lg * 2)
        }
    }

    func addSection(title: String, _ block: (UIView) -> Void) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        contentStack.addArrangedSubview(titleLabel)

        let container = UIView()
        // 与 Android demo 平铺 bgPage 一致：去掉圆角卡片外框/边框，直接平铺在页面背景上。
        container.backgroundColor = AppColor.bgPage
        container.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentStack.addArrangedSubview(container)

        block(container)
    }

    func addInfo(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.numberOfLines = 0
        contentStack.addArrangedSubview(label)
    }

    /// 在页面顶部（参考块上方）插入一条"常驻反馈条"：点击/长按等事件用它就地更新，
    /// 避免信息追加到页面底部不可见。返回 label，业务通过设置 text 反馈。
    /// 调用时机：须在 addVersionBadge 之后；插入到徽标之后（紧跟高度参考块，若存在）。
    func addFeedbackBar() -> UILabel {
        let label = UILabel()
        label.text = "点击任意 cell 查看按压变色 + 此处反馈"
        label.font = .systemFont(ofSize: AppFont.sizeXs, weight: .medium)
        label.textColor = AppColor.primary
        label.numberOfLines = 0
        label.textAlignment = .left
        // 插到 min(2, count)：有高度参考块时插 index 2（徽标0/参考块1/反馈条2），
        // 无高度参考块时插 index 1（徽标0/反馈条1），避免越界。
        contentStack.insertArrangedSubview(label, at: min(2, contentStack.arrangedSubviews.count))
        return label
    }

    /// 在页面顶部插入"固定高度参考块"（B 方案）：
    /// 一个恰好 56pt 高的色块（= 设计稿「32 号字 cell」单行），旁边标注标准高度，用于目测 cell 是否达标（不依赖模拟器尺寸）。
    /// 位置紧贴版本徽标下方（徽标在 index 0，参考块整体放 index 1）。
    /// 调用时机：须在 addVersionBadge 之后。
    func addHeightReference() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppSpace.xs
        stack.layoutMargins = UIEdgeInsets(top: AppSpace.md, left: 0, bottom: AppSpace.md, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true

        let refLabel = UILabel()
        refLabel.text = "高度参考：下方色块高 = 56pt（= 设计稿单行 cell）"
        refLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        refLabel.textColor = AppColor.textSecondary
        refLabel.numberOfLines = 0
        stack.addArrangedSubview(refLabel)

        let refBlock = UIView()
        refBlock.backgroundColor = AppColor.gray4
        refBlock.snp.makeConstraints { make in
            make.height.equalTo(Cell.minHeight)
        }
        stack.addArrangedSubview(refBlock)

        contentStack.insertArrangedSubview(stack, at: 1)
    }

    /// 在页面最顶部插入组件版本徽标，用于核对实机是否运行最新代码。
    /// 只显示版本号（去掉了时间戳），两端用同一版本号直接对齐即可。
    /// 注意：调用时机在 addSection/addInfo 之后，用 insert(at: 0) 保证置顶。
    func addVersionBadge(componentName: String = "Cell", version: String, builtAt: String) {
        let badge = UIView()
        let label = UILabel()
        label.text = "\(componentName) 组件 \(version)"
        label.font = .systemFont(ofSize: AppFont.sizeXs, weight: .medium)
        label.textColor = AppColor.primary
        label.textAlignment = .center
        badge.backgroundColor = AppColor.primaryMuted
        badge.layer.cornerRadius = AppRadius.sm
        badge.clipsToBounds = true
        badge.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
        }
        contentStack.insertArrangedSubview(badge, at: 0)
    }
}

// MARK: - Cell Showcase（Cell 组件独立 Demo 页）

final class CellShowcase: ShowcaseViewController {
    /// 已输出过高度的行（去重，避免重复 addInfo 刷屏）。
    private var reportedRows = Set<IndexPath>()

    /// 顶部常驻反馈条：点击/长按在此就地更新（对标 Android 的 clickInfo 顶部反馈）。
    /// 强引用持有：确保点击时 label 一定存活、可写。虽已被 contentStack 持有，这里显式强持有更稳妥。
    private var feedbackLabel: UILabel?

    /// 自定尺寸 tableView：高度 = 所有 cell 高度之和，副标题两行自然撑开，避免固定行高截断。
    /// 宽度或高度任一变化（横竖屏旋转/内容刷新）都 invalidate intrinsicContentSize，
    /// 否则横屏旋转后宽度变化不触发重算，cell 不随屏幕宽度自适应。
    private final class SelfSizingTableView: UITableView {
        private var lastWidth: CGFloat = 0
        private var reloadScheduled = false

        override var intrinsicContentSize: CGSize { contentSize }

        override func layoutSubviews() {
            super.layoutSubviews()
            if bounds.width != lastWidth {
                lastWidth = bounds.width
                // v1.22：异步调度 reloadData，避免在 layoutSubviews 中同步调用
                // 导致 contentSize 尚未更新就被父视图读取（cell 被压扁的根因）。
                // 下一帧再 reload + layoutIfNeeded + invalidate，contentSize 即为正确值。
                if !reloadScheduled {
                    reloadScheduled = true
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.reloadScheduled = false
                        self.reloadData()
                        self.layoutIfNeeded()
                        self.invalidateIntrinsicContentSize()
                    }
                }
            } else if bounds.height != contentSize.height {
                invalidateIntrinsicContentSize()
            }
        }
    }

    /// 单个排查分组：标题说明 + 一组 Cell（只加一个排查因素）。
    private final class Group {
        let title: String
        let note: String
        let models: [CellModel]
        let tableView = SelfSizingTableView(frame: .zero, style: .plain)
        init(title: String, note: String, models: [CellModel]) {
            self.title = title
            self.note = note
            self.models = models
        }
    }

    /// 逐步递增的单因子排查分组：
    /// ① 空行（仅背景色）→ 验证基础骨架/行高/背景
    /// ② +标题文字 → 验证文字布局/垂直居中
    /// ③ +箭头 → 验证文字+箭头水平布局
    /// ④ 完整形态 → 对照图标+副标题+value+状态
    private let groups: [Group] = [
        Group(
            title: "① 空行（仅背景色，无内容）",
            note: "排查点：cell 基础骨架 / 行高 / 背景色。若此处就不对，是基础布局问题，与文字无关。",
            models: [
                CellModel(title: "", arrow: false),
                CellModel(title: "", arrow: false),
            ]
        ),
        Group(
            title: "② 仅标题文字（无箭头）",
            note: "排查点：标题文字的布局 / 垂直居中。只加文字，无箭头/图标/value。arrow 显式 false，对照 Demo3 验证箭头对文字布局的影响。",
            models: [
                CellModel(title: "默认行标题", arrow: false),
                CellModel(title: "标题较长，用来观察换行与垂直位置", arrow: false),
            ]
        ),
        Group(
            title: "③ 标题 + 箭头",
            note: "排查点：文字与右侧箭头的水平布局。只加箭头。",
            models: [
                CellModel(title: "标题 + 右侧箭头"),
                CellModel(title: "标题较长 + 箭头对齐"),
            ]
        ),
        Group(
            title: "④ 完整形态（对照）",
            note: "排查点：图标 + 副标题 + value + 状态标识的完整组合。",
            models: [
                CellModel(title: "默认行", subtitle: "副标题示例", value: "¥3,850.00"),
                CellModel(title: "带图标", subtitle: "icon 参数显示左侧图标", iconSymbol: "heart.fill", value: "收藏"),
                CellModel(title: "同步成功", value: "正常态", status: .success),
                CellModel(title: "同步失败", value: "错误态", status: .error),
                CellModel(title: "禁用态", value: "不可点", disabled: true),
                CellModel(title: "加载中", value: "骨架动画", loading: true),
            ]
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cell 单元格"

        // 组件版本 + 构建时间戳（精确到秒）：用于核对实机运行的是否为最新代码。
        // 每次改动 Cell 组件后，手动递增版本号并更新此时间，双端（iOS/Android）保持一致。
        addVersionBadge(version: "v1.31", builtAt: "2026-09-02 07:40:00")
        // 固定高度参考块（B 方案）：56pt 色块（= 设计稿单行 cell），跨模拟器目测 cell 高度。须在徽标之后调用。
        addHeightReference()
        // 顶部常驻反馈条：点击/长按就地更新（对标 Android clickInfo，避免追加到底部不可见）。
        // 顺序固定：徽标(0)、高度参考块(1)、反馈条(2)，与 Android 一致。
        feedbackLabel = addFeedbackBar()

        for group in groups {
            addSection(title: group.title) { [weak group] container in
                guard let group else { return }
                let tv = group.tableView
                tv.backgroundColor = AppColor.bgPage
                tv.separatorStyle = .none
                tv.isScrollEnabled = false
                tv.register(Cell.self, forCellReuseIdentifier: Cell.reuseId)
                tv.dataSource = self
                tv.delegate = self
                tv.rowHeight = UITableView.automaticDimension
                tv.estimatedRowHeight = Cell.minHeight
                container.addSubview(tv)
                tv.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                    make.top.bottom.equalToSuperview().inset(AppSpace.md)
                }
            }
            addInfo(group.note)
        }
    }

    // 横竖屏旋转时刷新所有 group tableView 并强制布局：
    // reloadData 让 cell 按新宽度重新布局（文字/箭头自适应），
    // layoutIfNeeded 确保 contentSize 立即更新，避免 invalidateIntrinsicContentSize
    // 读到旧值导致 cell 被压扁。
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            for group in self.groups {
                group.tableView.reloadData()
                group.tableView.layoutIfNeeded()
            }
        })
    }
}

// MARK: - Cell 排查分组数据源

extension CellShowcase: UITableViewDataSource {
    /// 根据 tableView 找到它所属的分组。
    private func group(for tableView: UITableView) -> Group? {
        groups.first { $0.tableView === tableView }
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        group(for: tableView)?.models.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseId, for: indexPath) as! Cell
        guard let group = group(for: tableView) else { return cell }
        let model = group.models[indexPath.row]
        // 先设 divider/spacing 再 apply，让 apply 能读取 rowSpacing 做居中补偿。
        cell.showsDivider = false
        cell.rowSpacing = AppSpace.lg
        cell.apply(model)
        cell.bind(model, index: indexPath.row)
        cell.onTap = { [weak self, weak cell] _, index in
            guard let self else { return }
            let name = self.rowName(in: group, index: index)
            self.showFeedback("点击了：\(name)", heightPt: cell?.bounds.height)
        }
        cell.onLongPress = { [weak self, weak cell] _, index in
            guard let self else { return }
            let name = self.rowName(in: group, index: index)
            self.showFeedback("长按了：\(name)", heightPt: cell?.bounds.height)
        }

        // D 方案：读取每个 cell 布局后的真实高度（pt），输出数值，跨模拟器精确核对。
        // selfSizing 下高度在布局后才确定，故异步一帧后再读，并按行去重避免刷屏。
        DispatchQueue.main.async { [weak self, weak cell] in
            guard let self, let cell, !self.reportedRows.contains(indexPath) else { return }
            cell.layoutIfNeeded()
            self.reportedRows.insert(indexPath)
            let h = cell.bounds.height
            let label = (model.title.isEmpty ? "空行" : model.title)
            self.addInfo("\(group.title) › \(label)：实测高度 \(String(format: "%.1f", h)) pt")
            // ② 仅标题组：额外输出文字/箭头垂直居中实测偏移（pt，正=偏下），
            // 用于 iOS 实机校准 verticalCenterBaselineOffset（替代纯数学推导）。
            if group.title.hasPrefix("②") && indexPath.row == 0 {
                let titleOffset = cell.debugTitleVerticalOffset()
                let trailingOffset = cell.debugTrailingCenterOffset()
                self.addInfo(
                    "② 垂直居中实测：标题偏移 \(String(format: "%.2f", titleOffset)) pt，"
                    + "trailing 偏移 \(String(format: "%.2f", trailingOffset)) pt（正=偏下，0=居中）"
                )
            }
        }
        return cell
    }
}

// MARK: - Cell 排查分组点击（走 UITableView 系统点击，保证 onTap 触发）

extension CellShowcase: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let group = group(for: tableView), indexPath.row < group.models.count else { return }
        let heightPt = tableView.cellForRow(at: indexPath)?.bounds.height
        showFeedback("点击了：\(rowName(in: group, index: indexPath.row))", heightPt: heightPt)
    }
}

extension CellShowcase {
    /// 更新顶部反馈条；若反馈条未持有（异常兜底），则追加一条 addInfo 到底部，确保点击必有可见反馈。
    /// 主路径更新 feedbackLabel（对标 Android 的顶部 clickInfo）。
    /// - Parameters:
    ///   - text: 反馈文案前缀（如"点击了："）。
    ///   - heightPt: cell 实测高度（pt）。有值则追加"（实测高度 xx.x pt）"，对齐 Android 的"（实测高度 xx dp）"。
    private func showFeedback(_ text: String, heightPt: CGFloat?) {
        var finalText = text
        if let heightPt {
            finalText += "（实测高度 \(String(format: "%.1f", heightPt)) pt）"
        }
        if let feedbackLabel {
            feedbackLabel.text = finalText
        } else {
            addInfo(finalText)
        }
    }

    /// 生成某一行在反馈条里显示的名字。
    /// 有标题用标题；空行用「组前缀 + 空行-序号」命名（如"① 空行-1"），避免反馈条只显示"点击了："后面没字。
    /// 组前缀取标题首个字符（① / ② / ③ / ④）。
    private func rowName(in group: Group, index: Int) -> String {
        guard group.models.indices.contains(index) else { return "未知行" }
        let model = group.models[index]
        if !model.title.isEmpty { return model.title }
        let seq = String(group.title.prefix(1))
        return "\(seq) 空行-\(index + 1)"
    }
}

// MARK: - Button Showcase（Button 组件独立 Demo 页）

final class ButtonShowcase: ShowcaseViewController {
    /// 顶部常驻反馈条：点击按钮在此就地更新。
    private var feedbackLabel: UILabel?

    /// 单个按钮配置：样式 + 文案 + 状态。
    private struct ButtonConfig {
        let style: AppButtonStyle
        let text: String
        let enabled: Bool
        let loading: Bool
    }

    /// 单个排查分组：标题 + 说明 + 一组按钮配置。
    private struct ButtonGroup {
        let title: String
        let note: String
        let configs: [ButtonConfig]
    }

    /// 逐步递增的单因子排查分组：
    /// ① 基础形态（仅 Primary）→ 验证骨架/高度(48pt)/圆角(lg)/主色填充/白字/按下态
    /// ② style 切换 → 验证三样式视觉差异（primary/secondary/destructive）
    /// ③ 状态（loading + disabled）→ 验证状态色和文案变化
    /// ④ 全形态（三样式×三状态完整组合 + 点击反馈）
    private let groups: [ButtonGroup] = [
        ButtonGroup(
            title: "① 基础形态（仅 Primary）",
            note: "排查点：骨架/高度(48pt)/圆角(lg)/主色填充/白字/按下态反馈。只放 primary 样式，验证基础视觉。",
            configs: [
                ButtonConfig(style: .primary, text: "登录", enabled: true, loading: false),
                ButtonConfig(style: .primary, text: "注册", enabled: true, loading: false),
            ]
        ),
        ButtonGroup(
            title: "② style 切换（三样式对照）",
            note: "排查点：primary(主色填充+白字) vs secondary(白底+主色描边+主色字) vs destructive(白底+红色描边+红色字)。",
            configs: [
                ButtonConfig(style: .primary, text: "主操作", enabled: true, loading: false),
                ButtonConfig(style: .secondary, text: "次操作", enabled: true, loading: false),
                ButtonConfig(style: .destructive, text: "删除", enabled: true, loading: false),
            ]
        ),
        ButtonGroup(
            title: "③ 状态（loading + disabled）",
            note: "排查点：loading 态置灰(buttonDisabled)+文案「加载中...」+不可点击；disabled 态置灰+不可点击。",
            configs: [
                ButtonConfig(style: .primary, text: "加载中", enabled: true, loading: true),
                ButtonConfig(style: .primary, text: "已禁用", enabled: false, loading: false),
                ButtonConfig(style: .secondary, text: "次操作加载", enabled: true, loading: true),
                ButtonConfig(style: .destructive, text: "删除禁用", enabled: false, loading: false),
            ]
        ),
        ButtonGroup(
            title: "④ 全形态（三样式×三状态组合）",
            note: "排查点：三样式 × 三状态(normal/loading/disabled)完整组合，点击有反馈。",
            configs: [
                ButtonConfig(style: .primary, text: "主操作", enabled: true, loading: false),
                ButtonConfig(style: .primary, text: "主操作加载", enabled: true, loading: true),
                ButtonConfig(style: .primary, text: "主操作禁用", enabled: false, loading: false),
                ButtonConfig(style: .secondary, text: "次操作", enabled: true, loading: false),
                ButtonConfig(style: .secondary, text: "次操作加载", enabled: true, loading: true),
                ButtonConfig(style: .secondary, text: "次操作禁用", enabled: false, loading: false),
                ButtonConfig(style: .destructive, text: "删除", enabled: true, loading: false),
                ButtonConfig(style: .destructive, text: "删除加载", enabled: true, loading: true),
                ButtonConfig(style: .destructive, text: "删除禁用", enabled: false, loading: false),
            ]
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Button 按钮"

        addVersionBadge(componentName: "Button", version: "v1.4", builtAt: "2026-09-03 09:05:00")
        feedbackLabel = addFeedbackBar()

        for group in groups {
            addSection(title: group.title) { [weak self] container in
                guard let self else { return }
                let stack = UIStackView()
                stack.axis = .vertical
                stack.spacing = AppSpace.md
                container.addSubview(stack)
                stack.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                    make.top.bottom.equalToSuperview().inset(AppSpace.md)
                }
                for config in group.configs {
                    let button: AppButton
                    switch config.style {
                    case .primary:
                        button = .primary(config.text)
                    case .secondary:
                        button = .secondary(config.text)
                    case .destructive:
                        button = .destructive(config.text)
                    }
                    if !config.enabled {
                        button.setAppEnabled(false)
                    }
                    if config.loading {
                        button.setLoading(true)
                    }
                    button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
                    stack.addArrangedSubview(button)
                    button.snp.makeConstraints { make in
                        make.height.equalTo(AppButton.standardHeight)
                    }
                }
            }
            addInfo(group.note)
        }
    }

    @objc private func buttonTapped(_ sender: AppButton) {
        let title = sender.title(for: .normal) ?? ""
        feedbackLabel?.text = "点击了：\(title)"
    }
}

// MARK: - Icon Showcase（Icon 组件独立 Demo 页）

final class IconShowcase: ShowcaseViewController {
    /// 顶部常驻反馈条。
    private var feedbackLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Icon 图标"

        addVersionBadge(componentName: "Icon", version: "v1.2", builtAt: "2026-09-03 08:30:00")
        feedbackLabel = addFeedbackBar()

        // ① 基础形态：全部 8 个图标，默认尺寸(24pt) + 默认色(textPrimary)
        addSection(title: "① 基础形态（8 图标默认尺寸 24pt）") { container in
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
            for name in AppIconName.allCases {
                let icon = AppIcon.make(name, size: 24, color: AppColor.textPrimary)
                row.addArrangedSubview(icon)
            }
        }
        addInfo("排查点：8 个图标是否全部渲染（SF Symbols）。若缺图说明 SF Symbol 名不匹配。")

        // ② 尺寸因子：同一图标 list 不同尺寸 16/24/32/48pt
        addSection(title: "② 尺寸因子（list × 16/24/32/48pt）") { container in
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.distribution = .equalSpacing
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.xl)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
            for size in [16, 24, 32, 48] as [CGFloat] {
                let icon = AppIcon.make(.list, size: size, color: AppColor.textPrimary)
                row.addArrangedSubview(icon)
            }
        }
        addInfo("排查点：尺寸缩放是否正比、无变形。16pt 应清晰可辨，48pt 应饱满。")

        // ③ 着色因子：同一图标 person 不同颜色
        addSection(title: "③ 着色因子（person × 4 色）") { container in
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
            let colors: [(UIColor, String)] = [
                (AppColor.textPrimary, "textPrimary"),
                (AppColor.primary, "primary"),
                (AppColor.error, "error"),
                (AppColor.textSecondary, "textSecondary"),
            ]
            for (color, _) in colors {
                let icon = AppIcon.make(.person, size: 32, color: color)
                row.addArrangedSubview(icon)
            }
        }
        addInfo("排查点：tintColor 是否生效。4 个 person 应分别为深灰/绿/红/浅灰。")

        // ④ 全形态网格：8 图标 × 3 色（textPrimary/primary/error）
        addSection(title: "④ 全形态网格（8 图标 × 3 色）") { container in
            let grid = UIStackView()
            grid.axis = .vertical
            grid.spacing = AppSpace.md
            container.addSubview(grid)
            grid.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
            let gridColors: [UIColor] = [AppColor.textPrimary, AppColor.primary, AppColor.error]
            for color in gridColors {
                let row = UIStackView()
                row.axis = .horizontal
                row.distribution = .fillEqually
                for name in AppIconName.allCases {
                    let icon = AppIcon.make(name, size: 28, color: color)
                    row.addArrangedSubview(icon)
                }
                grid.addArrangedSubview(row)
            }
        }
        addInfo("排查点：8 图标 × 3 色完整组合。第 1 行深灰、第 2 行绿、第 3 行红，每行 8 个图标对齐。")
    }
}

// MARK: - ConfigProvider Showcase（全局配置 · 配置生效对比 Demo）

/// Provider 型组件无视觉五态（默认/禁用/加载/成功/失败不适用），Demo 用「配置生效对比」演示：
/// 消费块在渲染时刻直读 AppTheme 解析层，快照并展示解析出的 primaryColor / radiusMd / spaceLg，
/// 同屏对比 覆盖前（基准）vs 覆盖后，嵌套作用域演示「内层优先 + 未设项继承」（门禁 C1.5）。
final class ConfigProviderShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ConfigProvider 全局配置"

        // demo 徽标版本 = 组件库正式版本（对齐 ui-version.json v1.2.1；Cell 的 v1.31 属另一套 demo 演示版本链）。
        addVersionBadge(componentName: "ConfigProvider", version: "v1.2.1", builtAt: "2026-09-03 09:00:00")
        addInfo("定位：design-token 静态基准之上的运行时覆盖层。消费块渲染时刻直读 AppTheme 解析层，同屏对比覆盖前后实际解析值。")

        // ① 基准区：未挂 Provider → 静态基准（零行为变化，D1）
        addSection(title: "① 基准区（未挂 Provider）") { container in
            addProbes([makeProbe()], into: container)
        }
        addInfo("预期：primary = AppColor.primary（#16A34A）、radiusMd = 10 pt（md 档）、spaceLg = 16 pt（lg 档）。")

        // ② 组合覆盖：primaryColor + rounded + compact 三项同时生效（D8）
        addSection(title: "② 组合覆盖（primaryColor #4F46E5 + rounded + compact）") { container in
            ConfigProvider.withScope(
                AppConfig(
                    primaryColor: UIColor(hexString: "#4F46E5"),
                    rounded: true,
                    compact: true
                )
            ) {
                addProbes([makeProbe()], into: container)
            }
        }
        addInfo("预期：primary → #4F46E5；radiusMd 升档 md→lg（10→14 pt）；spaceLg 降档 lg→md（16→12 pt）；三项互不干扰。")

        // ③ 嵌套作用域：外层 primaryColor → 内层 compact（内层优先 + 未设项继承，D6）
        addSection(title: "③ 嵌套（外层 primaryColor #2563EB → 内层 compact）") { container in
            ConfigProvider.withScope(
                AppConfig(primaryColor: UIColor(hexString: "#2563EB"))
            ) {
                var probes = [makeProbe()]
                ConfigProvider.withScope(AppConfig(compact: true)) {
                    probes.append(makeProbe())
                }
                addProbes(probes, into: container)
            }
        }
        addInfo("预期：两块 primary 均 = #2563EB；外层块 spaceLg = 16 pt（默认 lg 档），内层块 spaceLg = 12 pt（compact 生效，内层优先）。")
    }

    // MARK: - 消费块构建

    /// 将一组消费块垂直排入 section container。
    private func addProbes(_ probes: [UIView], into container: UIView) {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = AppSpace.md
        container.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
            make.top.bottom.equalToSuperview().inset(AppSpace.md)
        }
        for probe in probes {
            vStack.addArrangedSubview(probe)
        }
    }

    /// 构建一个「配置消费块」：渲染（构建）时刻读取 AppTheme 解析层当前值并快照。
    /// 必须在目标作用域内调用（withScope 闭包内 → 覆盖值；闭包外 → 静态基准）。
    private func makeProbe() -> UIView {
        let primary = AppTheme.primaryColor
        let radiusMd = AppTheme.radiusMd
        let spaceLg = AppTheme.spaceLg
        let hex = primary.toHexString() ?? "(非 RGB)"

        // 主色圆角色块：主题色覆盖 + 圆角升档的直接视觉观测点。
        let swatch = UIView()
        swatch.backgroundColor = primary
        swatch.layer.cornerRadius = radiusMd
        swatch.clipsToBounds = true
        swatch.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }

        // 解析读数：等宽数字便于跨区块核对（compact/rounded 生效与否一眼可见）。
        let readout = UIStackView()
        readout.axis = .vertical
        readout.spacing = 2
        readout.addArrangedSubview(makeReadout("primary = \(hex)"))
        readout.addArrangedSubview(makeReadout(String(format: "radiusMd = %.0f pt", radiusMd)))
        readout.addArrangedSubview(makeReadout(String(format: "spaceLg = %.0f pt", spaceLg)))

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = AppSpace.md
        row.addArrangedSubview(swatch)
        row.addArrangedSubview(readout)
        return row
    }

    private func makeReadout(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: AppFont.sizeXs, weight: .regular)
        label.textColor = AppColor.textPrimary
        label.text = text
        return label
    }
}

private extension UIColor {
    /// 转 "#RRGGBB"；非 RGB 颜色（动态/图案）返回 nil。
    func toHexString() -> String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        let resolved = resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        guard resolved.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(format: "#%02X%02X%02X", Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
    }
}

// MARK: - Image Showcase（Image 组件独立 Demo 页，与 Android ImageDemo 一一对应）

/// 演示点（验收文档 六）：
/// ① 基础（本地图 + 显式尺寸 + radius 圆角/圆形头像）
/// ② fit 五模式同屏对比（同一图换 fit，可看清拉伸/裁剪/留白差异）
/// ③ loading/error 占位（src=null 模拟慢源窗口；无效源显示失败占位 + 重试恢复）
/// ④ 事件反馈（onTap 点击反馈条 + onLoad/onError 计数）
final class ImageShowcase: ShowcaseViewController {

    /// 顶部常驻反馈条：onTap 在此就地更新（对标 Android clickInfo）。
    private var feedbackLabel: UILabel?
    /// 事件计数条：onLoad/onError 累计。
    private var eventsLabel: UILabel?

    private var tapCount = 0
    private var loadCount = 0
    private var errorCount = 0

    /// 状态卡引用：③ loading 演示卡（按钮切换 src）。
    private var loadingImage: Image?
    private var loadingStateLabel: UILabel?
    /// ④ 失败演示卡（按钮切换 src；P4=B 重试 = 业务改 src）。
    private var errorImage: Image?
    private var errorStateLabel: UILabel?

    /// 演示素材：320×200 本地样例图（上蓝下橙 + 白色太阳圆），宽高比 3:2 ≠ 容器 4:3。
    private lazy var sampleImage: UIImage = ImageShowcase.makeSampleImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image 图片"

        // demo 徽标版本 = 组件库正式版本（对齐 ui-version.json v1.3.3；Cell 的 v1.31 属另一套 demo 演示版本链）。
        addVersionBadge(componentName: "Image", version: "v1.3.3", builtAt: "2026-09-03 22:45:00")
        feedbackLabel = addFeedbackBar()
        feedbackLabel?.text = "点击任意图片查看回调反馈（onTap）"
        eventsLabel = makeEventsLabel()
        updateEvents()

        // ① 基础形态：本地图 + 显式尺寸 + radius（默认 / lg 圆角 / 圆形 = 半径 24 = 宽 48/2）
        addSection(title: "① 基础形态（本地图 + 尺寸 + 圆角/圆形）") { [weak self] container in
            guard let self else { return }
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.distribution = .equalSpacing
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
            row.addArrangedSubview(self.makeImageCard(
                src: sampleImage, width: 96, height: 64, caption: "默认 fill",
                onTap: { [weak self] in self?.tapFeedback("① 基础-默认") }
            ))
            row.addArrangedSubview(self.makeImageCard(
                src: sampleImage, width: 96, height: 64, caption: "圆角 lg", radius: "lg",
                onTap: { [weak self] in self?.tapFeedback("① 基础-圆角 lg") }
            ))
            row.addArrangedSubview(self.makeImageCard(
                src: sampleImage, width: 48, height: 48, caption: "圆形头像", radius: CGFloat(24),
                onTap: { [weak self] in self?.tapFeedback("① 基础-圆形头像") }
            ))
        }
        addInfo("演示素材=320×200 上蓝下橙+白色太阳圆（8:5，太阳圆心偏左上方，便于肉眼观察 fit 变形/裁切）。排查点：同一本地图三种裁剪——无圆角 / lg 圆角 / 圆形（radius=宽/2=24）；fill 拉伸到与素材不等比的容器时白圆会变形（椭圆），属 fill 语义。点击应触发 onTap 反馈。")

        // ② fit 五模式同屏对比（同一 320×200 图，容器 120×90，4:3 vs 3:2，可横向滚动）
        addSection(title: "② fit 五模式同屏对比（同一图，容器 120×90）") { [weak self] container in
            guard let self else { return }
            let scroll = UIScrollView()
            scroll.showsHorizontalScrollIndicator = true
            container.addSubview(scroll)
            scroll.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview().inset(AppSpace.md)
                // 显式高度：卡片=图 90 + caption(sizeXs ~14) + spacing 4 ≈ 108，留视觉余量。
                // UIScrollView 自身高度不能由内部内容反推，否则 Auto Layout 高度未定 → 整节塌陷为 0（v1.3.0 实机问题 4）。
                // top + bottom 四向锚 + 显式 height：高度用 height（SnapKit 取最大约束：height 118 优先；top/bottom 保证 section container 被正确撑开
                // 不产生 overflow 叠到 Demo3/Demo4 标题/图片——v1.3.1 Bug4/5 根因：缺 bottom 锚 → container 高度=0，scroll 高度 118 溢出容器
                // 向下覆盖下一节，视觉呈现「Demo2 文字/图与 Demo3 图片重叠」。
                make.height.equalTo(118)
            }
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.alignment = .center
            stack.spacing = AppSpace.lg
            scroll.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.edges.equalTo(scroll.contentLayoutGuide)
            }
            let fits: [(ImageFit, String)] = [
                (.fill, "fill"), (.contain, "contain"), (.cover, "cover"),
                (.none, "none"), (.scaleDown, "scale-down"),
            ]
            for (fit, name) in fits {
                stack.addArrangedSubview(self.makeImageCard(
                    src: sampleImage, width: 120, height: 90, caption: name, fit: fit,
                    onTap: { [weak self] in self?.tapFeedback("② fit=\(name)") }
                ))
            }
        }
        addInfo("排查点：fill=拉伸铺满；contain=完整等比（上下留白）；cover=等比铺满（左右被裁，居中可见白色太阳圆）；none=原始尺寸（超出被裁）；scale-down=不放大（同 contain）。可横向滑动查看后两个。")

        // ③ 加载中占位（src=null 模拟慢源/解码窗口）
        addSection(title: "③ 加载中占位（src=null 模拟慢源/解码窗口）") { [weak self] container in
            guard let self else { return }
            let buttons = UIStackView()
            buttons.axis = .horizontal
            buttons.spacing = AppSpace.sm
            buttons.distribution = .fillEqually
            let loadingButton = AppButton.primary("模拟加载中（null）")
            loadingButton.addTarget(self, action: #selector(self.loadingToNull), for: .touchUpInside)
            let doneButton = AppButton.primary("模拟解码完成")
            doneButton.addTarget(self, action: #selector(self.loadingToDone), for: .touchUpInside)
            buttons.addArrangedSubview(loadingButton)
            buttons.addArrangedSubview(doneButton)
            loadingButton.snp.makeConstraints { make in
                make.height.equalTo(AppButton.standardHeight)
            }
            doneButton.snp.makeConstraints { make in
                make.height.equalTo(AppButton.standardHeight)
            }

            let card = self.makeStateCard(
                src: nil, width: 120, height: 90,
                stateLabel: &self.loadingStateLabel,
                onLoad: { [weak self] in self?.bumpLoad() },
                onError: { [weak self] in self?.bumpError() }
            )
            self.loadingImage = card.image
            self.loadingStateLabel?.text = "loading（默认占位）"

            let stack = UIStackView(arrangedSubviews: [buttons, card.container])
            stack.axis = .vertical
            stack.spacing = AppSpace.md
            container.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addInfo("预期：src=null 时显示默认灰底+双色转圈占位；点「模拟解码完成」立即渲染并触发 onLoad（事件计数条 +1）。")

        // ④ 失败占位与重试（P4=B：重试 = 业务重设 src）
        addSection(title: "④ 失败占位与重试（无效源 → 失败占位；重试 = 业务改 src）") { [weak self] container in
            guard let self else { return }
            let buttons = UIStackView()
            buttons.axis = .horizontal
            buttons.spacing = AppSpace.sm
            buttons.distribution = .fillEqually
            let failButton = AppButton.primary("置为无效源")
            failButton.addTarget(self, action: #selector(self.errorToFail), for: .touchUpInside)
            let retryButton = AppButton.primary("重试恢复")
            retryButton.addTarget(self, action: #selector(self.errorToRetry), for: .touchUpInside)
            buttons.addArrangedSubview(failButton)
            buttons.addArrangedSubview(retryButton)
            failButton.snp.makeConstraints { make in
                make.height.equalTo(AppButton.standardHeight)
            }
            retryButton.snp.makeConstraints { make in
                make.height.equalTo(AppButton.standardHeight)
            }

            let card = self.makeStateCard(
                src: "no_such_image_xyz", width: 120, height: 90,
                stateLabel: &self.errorStateLabel,
                onLoad: { [weak self] in self?.bumpLoad() },
                onError: { [weak self] in self?.bumpError() }
            )
            self.errorImage = card.image
            self.errorStateLabel?.text = "failed（默认破图占位）"

            let stack = UIStackView(arrangedSubviews: [buttons, card.container])
            stack.axis = .vertical
            stack.spacing = AppSpace.md
            container.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addInfo("预期：无效资源名显示默认破图+「加载失败」占位并触发 onError（上方案例图即默认破图视觉）；点「重试恢复」自动重新加载并触发 onLoad（P4=B 语义）。")
    }

    // MARK: - 事件

    private func tapFeedback(_ name: String) {
        tapCount += 1
        updateEvents()
        feedbackLabel?.text = "点击了：\(name)"
    }

    private func bumpLoad() {
        loadCount += 1
        updateEvents()
    }

    private func bumpError() {
        errorCount += 1
        updateEvents()
    }

    private func updateEvents() {
        eventsLabel?.text = "事件累计：onTap ×\(tapCount) · onLoad ×\(loadCount) · onError ×\(errorCount)"
    }

    @objc private func loadingToNull() {
        loadingImage?.src = nil
        loadingImage?.apply()
        loadingStateLabel?.text = "loading（默认占位）"
    }

    @objc private func loadingToDone() {
        loadingImage?.src = sampleImage
        loadingImage?.apply()
        loadingStateLabel?.text = "loaded"
    }

    @objc private func errorToFail() {
        errorImage?.src = "no_such_image_xyz"
        errorImage?.apply()
        errorStateLabel?.text = "failed（默认破图占位）"
    }

    @objc private func errorToRetry() {
        errorImage?.src = sampleImage
        errorImage?.apply()
        errorStateLabel?.text = "loaded"
    }

    // MARK: - 视图工厂

    private func makeEventsLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.numberOfLines = 0
        contentStack.addArrangedSubview(label)
        return label
    }

    /// 静态卡片：图 + 底部小字说明。返回纵向 stack（自带图片固定尺寸约束）。
    private func makeImageCard(
        src: Any?,
        width: CGFloat,
        height: CGFloat,
        caption: String,
        fit: ImageFit = .fill,
        radius: Any? = nil,
        alt: String? = nil,
        onTap: (() -> Void)? = nil,
        onLoad: (() -> Void)? = nil,
        onError: (() -> Void)? = nil
    ) -> UIView {
        let image = Image(frame: .zero)
        image.src = src
        image.fit = fit
        image.radius = radius
        image.alt = alt ?? caption
        image.onTap = onTap
        image.onLoad = onLoad
        image.onError = onError
        image.apply()
        image.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: width, height: height))
        }
        let label = UILabel()
        label.text = caption
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [image, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }

    /// 状态卡：图 + 状态说明小字。`image`/`container` 供外部切换 src 与刷新文案。
    private func makeStateCard(
        src: Any?,
        width: CGFloat,
        height: CGFloat,
        stateLabel: inout UILabel?,
        onLoad: (() -> Void)? = nil,
        onError: (() -> Void)? = nil
    ) -> (image: Image, container: UIView) {
        let image = Image(frame: .zero)
        image.src = src
        image.fit = .contain
        image.onLoad = onLoad
        image.onError = onError
        image.apply()
        image.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: width, height: height))
        }
        let label = UILabel()
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        let container = UIStackView(arrangedSubviews: [image, label])
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 4
        stateLabel = label
        return (image, container)
    }

    /// 生成 320×200 样例图：上蓝下橙 + 白色太阳圆（与 Android makeDemoBitmap 视觉一致）。
    private static func makeSampleImage() -> UIImage {
        let width: CGFloat = 320
        let height: CGFloat = 200
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { ctx in
            let cg = ctx.cgContext
            UIColor(red: 23 / 255.0, green: 109 / 255.0, blue: 232 / 255.0, alpha: 1).setFill()
            cg.fill(CGRect(x: 0, y: 0, width: width, height: height / 2))
            UIColor(red: 247 / 255.0, green: 158 / 255.0, blue: 27 / 255.0, alpha: 1).setFill()
            cg.fill(CGRect(x: 0, y: height / 2, width: width, height: height / 2))
            UIColor.white.setFill()
            let sunCenterX = width * 0.62
            let sunCenterY = height * 0.25
            cg.fillEllipse(in: CGRect(x: sunCenterX - 26, y: sunCenterY - 26, width: 52, height: 52))
        }
    }
}
