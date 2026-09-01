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
            DemoComponent(id: "ui.button", name: "Button 按钮", reviewed: false, create: nil),
            DemoComponent(id: "ui.cell", name: "Cell 单元格", reviewed: true, create: { CellShowcase() }),
            DemoComponent(id: "ui.config-provider", name: "ConfigProvider 全局配置", reviewed: false, create: nil),
            DemoComponent(id: "ui.icon", name: "Icon 图标", reviewed: false, create: nil),
            DemoComponent(id: "ui.image", name: "Image 图片", reviewed: false, create: nil),
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
    /// 调用时机：须在 addVersionBadge 之后；插入到 index 1（紧跟徽标）。
    func addFeedbackBar() -> UILabel {
        let label = UILabel()
        label.text = "点击任意 cell 查看按压变色 + 此处反馈"
        label.font = .systemFont(ofSize: AppFont.sizeXs, weight: .medium)
        label.textColor = AppColor.primary
        label.numberOfLines = 0
        label.textAlignment = .left
        // 固定插到 index 2：徽标(0)、高度参考块(1)、反馈条(2)，与 Android 顺序一致，不依赖调用顺序。
        contentStack.insertArrangedSubview(label, at: 2)
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
    func addVersionBadge(version: String, builtAt: String) {
        let badge = UIView()
        let label = UILabel()
        label.text = "Cell 组件 \(version)"
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
            title: "② 仅标题文字",
            note: "排查点：标题文字的布局 / 垂直居中。只加文字，无箭头/图标/value。",
            models: [
                CellModel(title: "默认行标题"),
                CellModel(title: "标题较长，用来观察换行与垂直位置"),
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
        addVersionBadge(version: "v1.26", builtAt: "2026-09-02 00:10:00")
        // 固定高度参考块（B 方案）：56pt 色块（= 设计稿单行 cell），跨模拟器目测 cell 高度。须在徽标之后调用。
        addHeightReference()
        // 顶部常驻反馈条：点击/长按就地更新（对标 Android clickInfo，避免追加到底部不可见）。
        // 顺序固定：徽标(0)、高度参考块(1)、反馈条(2)，与 Android 一致。
        feedbackLabel = addFeedbackBar()

        for group in groups {
            addSection(title: group.title) { [weak group] container in
                guard let group else { return }
                let tv = group.tableView
                // v1.25 debug：tableView 背景改紫色，区分 cell 之间的间隙是 tableView 背景（紫色）
                // 还是 cell 内部（红/蓝/黄）。原色：AppColor.bgPage。
                tv.backgroundColor = .systemPurple
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
