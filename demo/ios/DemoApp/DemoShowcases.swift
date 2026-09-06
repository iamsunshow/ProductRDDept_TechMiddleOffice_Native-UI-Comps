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
            DemoComponent(id: "ui.overlay", name: "Overlay 遮罩层", reviewed: true, create: { OverlayShowcase() }),
        ]),
        ("布局组件", [
            DemoComponent(id: "ui.divider", name: "Divider 分割线", reviewed: true, create: { DividerShowcase() }),
            DemoComponent(id: "ui.grid", name: "Grid 宫格", reviewed: true, create: { GridShowcase() }),
            DemoComponent(id: "ui.layout", name: "Layout 布局", reviewed: true, create: { LayoutShowcase() }),
            DemoComponent(id: "ui.safe-area", name: "SafeArea 安全区", reviewed: true, create: { SafeAreaShowcase() }),
            DemoComponent(id: "ui.space", name: "Space 间距", reviewed: true, create: { SpaceShowcase() }),
            DemoComponent(id: "ui.sticky", name: "Sticky 粘性布局", reviewed: true, create: { StickyShowcase() }),
        ]),
        ("导航组件", [
            DemoComponent(id: "ui.back-top", name: "BackTop 返回顶部", reviewed: true, create: { BackTopShowcase() }),
            DemoComponent(id: "ui.elevator", name: "Elevator 电梯楼层", reviewed: true, create: { ElevatorShowcase() }),
            DemoComponent(id: "ui.fixed-nav", name: "FixedNav 悬浮导航", reviewed: true, create: { FixedNavShowcase() }),
            DemoComponent(id: "ui.hover-button", name: "HoverButton 悬浮按钮", reviewed: true, create: { HoverButtonShowcase() }),
            DemoComponent(id: "ui.nav-bar", name: "NavBar 头部导航", reviewed: true, create: { NavBarShowcase() }),
            DemoComponent(id: "ui.side-bar", name: "SideBar 侧边导航", reviewed: true, create: { SideBarShowcase() }),
            DemoComponent(id: "ui.tabbar", name: "Tabbar 标签栏", reviewed: true, create: { TabbarShowcase() }),
            DemoComponent(id: "ui.tabs", name: "Tabs 选项卡", reviewed: true, create: { TabsShowcase() }),
        ]),
        ("数据录入", [
            DemoComponent(id: "ui.address", name: "Address 地址", reviewed: true, create: { AddressShowcase() }),
            DemoComponent(id: "ui.calendar", name: "Calendar 日历", reviewed: false, create: nil),
            DemoComponent(id: "ui.calendar-card", name: "CalendarCard 日历卡片", reviewed: true, create: { CalendarCardShowcase() }),
            DemoComponent(id: "ui.cascader", name: "Cascader 级联选择", reviewed: true, create: { CascaderShowcase() }),
            DemoComponent(id: "ui.checkbox", name: "Checkbox 复选", reviewed: true, create: { CheckboxShowcase() }),
            DemoComponent(id: "ui.date-picker", name: "DatePicker 日期选择", reviewed: false, create: nil),
            DemoComponent(id: "ui.date-picker-view", name: "DatePickerView 视图", reviewed: false, create: nil),
            DemoComponent(id: "ui.form", name: "Form 表单", reviewed: true, create: { FormShowcase() }),
            DemoComponent(id: "ui.input", name: "Input 输入框", reviewed: true, create: { InputShowcase() }),
            DemoComponent(id: "ui.input-number", name: "InputNumber 数字输入", reviewed: true, create: { InputNumberShowcase() }),
            DemoComponent(id: "ui.menu", name: "Menu 菜单", reviewed: true, create: { MenuShowcase() }),
            DemoComponent(id: "ui.number-keyboard", name: "NumberKeyboard 数字键盘", reviewed: true, create: { NumberKeyboardShowcase() }),
            DemoComponent(id: "ui.picker", name: "Picker 选择器", reviewed: true, create: { PickerShowcase() }),
            DemoComponent(id: "ui.picker-view", name: "PickerView 视图", reviewed: false, create: nil),
            DemoComponent(id: "ui.radio", name: "Radio 单选", reviewed: true, create: { RadioShowcase() }),
            DemoComponent(id: "ui.range", name: "Range 区间选择", reviewed: true, create: { RangeShowcase() }),
            DemoComponent(id: "ui.rate", name: "Rate 评分", reviewed: true, create: { RateShowcase() }),
            DemoComponent(id: "ui.search-bar", name: "SearchBar 搜索栏", reviewed: true, create: { SearchBarShowcase() }),
            DemoComponent(id: "ui.short-password", name: "ShortPassword 短密码", reviewed: true, create: { ShortPasswordShowcase() }),
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
            DemoComponent(id: "ui.empty", name: "Empty 空状态", reviewed: true, create: { EmptyShowcase() }),
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
            DemoComponent(id: "ui.avatar", name: "Avatar 头像", reviewed: true, create: { AvatarShowcase() }),
            DemoComponent(id: "ui.circle-progress", name: "CircleProgress 环形进度", reviewed: false, create: nil),
            DemoComponent(id: "ui.collapse", name: "Collapse 折叠面板", reviewed: false, create: nil),
            DemoComponent(id: "ui.count-down", name: "CountDown 倒计时", reviewed: false, create: nil),
            DemoComponent(id: "ui.ellipsis", name: "Ellipsis 文本省略", reviewed: false, create: nil),
            DemoComponent(id: "ui.image-preview", name: "ImagePreview 图片预览", reviewed: false, create: nil),
            DemoComponent(id: "ui.indicator", name: "Indicator 指示器", reviewed: false, create: nil),
            DemoComponent(id: "ui.line-chart", name: "LineChart 折线图", reviewed: true, create: { LineChartShowcase() }),
            DemoComponent(id: "ui.list", name: "List 分组列表", reviewed: true, create: { ListShowcase() }),
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
            DemoComponent(id: "ui.card", name: "Card 商品卡片", reviewed: true, create: { CardShowcase() }),
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

    /// 在内容区追加一条"可更新文本行"（样式同 addInfo），返回 label 供交互事件回写。
    /// 适用于把点击计数等动态反馈放在对应段下方（与 Android demo 段内 Text 1:1），
    /// 而非堆在页面顶部共享反馈条（滚动后不可见）。
    func addDynamicInfo(_ text: String, color: UIColor = AppColor.textSecondary) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = color
        label.numberOfLines = 0
        contentStack.addArrangedSubview(label)
        return label
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

    /// 创建一个可滚动"内容区"（demo 专用）：返回钉在 container 边缘且高度固定的滚动视图，
    /// 内部按 rows 行生成占位文本，用于演示"悬浮钮浮于滚动内容之上"（内容可滚、钮不动）。
    /// 说明：组件自身不监听滚动；滚动态只是展示宿主把钮放在非滚动覆盖层后的视觉效果。
    func makeScroller(container: UIView, height: CGFloat, rows: Int) -> UIScrollView {
        let scroll = UIScrollView()
        container.addSubview(scroll)
        scroll.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(height)
        }
        let content = UIView()
        scroll.addSubview(content)
        content.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scroll.contentLayoutGuide)
            // 底部必须钉 contentLayoutGuide：与组件库 Sticky iOS 同款修复（StickyView.swift
            // f220dad）——缺底部闭合时 UIScrollView 无法由约束推导 contentSize，内层滚动区
            // contentSize=0、contentOffset 恒 0，BackTop 永不出现。末尾行 bottom 封口 content
            // 只定内容高，需 bottom=guide.bottom 才向滚动域传递尺寸。
            make.bottom.equalTo(scroll.contentLayoutGuide.snp.bottom)
            make.width.equalTo(scroll.frameLayoutGuide)
        }
        var prev: UIView?
        for i in 1...rows {
            let l = UILabel()
            l.text = String(format: "%02d", i) + " · 条目内容第 " + String(i) + " 行"
            l.font = .systemFont(ofSize: AppFont.sizeXs)
            l.textColor = AppColor.textSecondary
            content.addSubview(l)
            l.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.height.equalTo(40)
                if let p = prev {
                    make.top.equalTo(p.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
            }
            prev = l
        }
        if let last = prev {
            last.snp.makeConstraints { make in make.bottom.equalToSuperview() }
        }
        return scroll
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
        // 每次改动 Cell 组件 / 验证后手动递增版本号并更新此时间（§7h 强制），双端保持一致。
        // C2→D 发版闭环 v1.3.10：iOS Simulator 16/16 实跑 + Android 12/12+脚本 4/4 全绿。
        addVersionBadge(version: "v1.3.10", builtAt: "2026-09-03 23:58:00")
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

        // demo 徽标版本 = 组件库正式版本（ui-version.json v1.3.11，§7h 强制：每次 C2/发版必须升徽标版本）。
        // C2→D 发版 v1.3.11：双端 15/15+15/15 全绿 + 用户实机对照 D1/D6/D8。
        addVersionBadge(componentName: "ConfigProvider", version: "v1.3.11", builtAt: "2026-09-03 23:59:00")
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

        // demo 徽标版本 = 组件库正式版本（ui-version.json v1.3.12；§7h 强制：C2/发版必升徽标版本）。
        // C2→D 发版 v1.3.12：三轮实机 11/11 收官 + api.json reviewed=true + platform partial→available 双端。
        addVersionBadge(componentName: "Image", version: "v1.3.12", builtAt: "2026-09-04 00:00:00")
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

// MARK: - Empty Showcase（Empty 空状态组件独立 Demo 页，与 Android EmptyDemo 一一对应）

final class EmptyShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Empty 空状态"
        addVersionBadge(componentName: "Empty", version: "v1.0", builtAt: "")

        addInfo("4 组排查：① 默认空态 ② 自定义文案 ③ 带图标 ④ 固定容器空态。双端 1:1 对齐。")

        // ── Demo 1：默认空态（「暂无数据」）──
        addSection(title: "Demo 1 · 默认空态") { container in
            let empty = EmptyStateView()
            container.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(160)
            }
        }
        addInfo("无任何设置，默认显示「暂无数据」，文案居中。")

        // ── Demo 2：自定义文案 ──
        addSection(title: "Demo 2 · 自定义文案") { container in
            let empty = EmptyStateView()
            empty.setMessage("搜索无结果，换个关键词试试")
            container.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(160)
            }
        }
        addInfo("setMessage 覆盖默认文案，支持多行。")

        // ── Demo 3：带图标空态 ──
        addSection(title: "Demo 3 · 带图标空态") { container in
            let empty = EmptyStateView()
            let config = UIImage.SymbolConfiguration.preferringMonochrome()
            empty.setIcon(UIImage(systemName: "tray", withConfiguration: config), size: 48)
            empty.setMessage("暂无记录")
            container.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(200)
            }
        }
        addInfo("setIcon 设置 SF Symbol（monochrome），图标居中于文案上方。")

        // ── Demo 4：固定容器空态（模拟列表空态场景）──
        addSection(title: "Demo 4 · 固定容器空态") { container in
            let wrapper = UIView()
            wrapper.backgroundColor = AppColor.bgCard
            wrapper.layer.cornerRadius = AppRadius.lg
            wrapper.layer.masksToBounds = true
            container.addSubview(wrapper)
            wrapper.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(240)
            }

            let empty = EmptyStateView()
            let config = UIImage.SymbolConfiguration.preferringMonochrome()
            empty.setIcon(UIImage(systemName: "folder", withConfiguration: config), size: 40)
            empty.setMessage("该文件夹为空")
            wrapper.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("模拟实际场景：圆角容器内嵌空态，图标+文案居中。")
    }
}

// MARK: - Avatar Showcase（Avatar 头像组件独立 Demo 页，与 Android AvatarDemo 一一对应）

final class AvatarShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Avatar 头像"
        addVersionBadge(componentName: "Avatar", version: "v1.0", builtAt: "")

        addInfo("4 组排查：① 文字头像 ② 星座符号头像 ③ 尺寸对比 ④ 头像组合。双端 1:1 对齐。")

        // ── Demo 1：文字头像（无星座，显示昵称首字）──
        addSection(title: "Demo 1 · 文字头像") { container in
            let names = ["张三", "李四", "王五", "赵六"]
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = AppSpace.lg
            for name in names {
                let avatar = ZodiacAvatarView()
                avatar.apply(zodiacName: nil, nickname: name, diameter: 56)
                row.addArrangedSubview(avatar)
            }
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addInfo("无星座信息时，显示昵称首字 + primaryMuted 背景。")

        // ── Demo 2：星座符号头像 ──
        addSection(title: "Demo 2 · 星座符号头像") { container in
            let signs = ["白羊座", "金牛座", "双子座", "巨蟹座"]
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = AppSpace.lg
            for name in signs {
                let avatar = ZodiacAvatarView()
                avatar.apply(zodiacName: name, nickname: name, diameter: 56)
                row.addArrangedSubview(avatar)
            }
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addInfo("星座符号 + 对应 tint 色（0.18 alpha 背景）。")

        // ── Demo 3：尺寸对比 ──
        addSection(title: "Demo 3 · 尺寸对比") { container in
            let sizes: [CGFloat] = [40, 56, 72]
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = AppSpace.xl
            for size in sizes {
                let avatar = ZodiacAvatarView()
                avatar.apply(zodiacName: "狮子座", nickname: "Leo", diameter: size)
                row.addArrangedSubview(avatar)
            }
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addInfo("小(40pt) / 中(56pt) / 大(72pt) 三档对比。")

        // ── Demo 4：头像组合（模拟用户列表行）──
        addSection(title: "Demo 4 · 头像组合") { container in
            let users: [(String?, String?)] = [
                ("白羊座", "白羊"),
                ("金牛座", "金牛"),
                (nil, "王五"),
                ("双子座", "双子"),
            ]
            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .fill
            col.spacing = AppSpace.md
            for (zodiac, name) in users {
                let row = UIStackView()
                row.axis = .horizontal
                row.alignment = .center
                row.spacing = AppSpace.md

                let avatar = ZodiacAvatarView()
                // ⚠️ users 数组是 [(String?, String?)]（A1 类型改 Optional 以支持 (nil, "王五") 行），这里形参 ZodiacAvatarView.apply(zodiacName:nickname:) 要求非 Optional String=必须解包
                avatar.apply(zodiacName: zodiac ?? "", nickname: name ?? "", diameter: 44)
                row.addArrangedSubview(avatar)

                let label = UILabel()
                label.text = name
                label.textColor = AppColor.textPrimary
                label.font = .systemFont(ofSize: AppFont.sizeMd)
                row.addArrangedSubview(label)

                col.addArrangedSubview(row)
            }
            container.addSubview(col)
            col.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addInfo("模拟用户列表：44pt 头像 + 昵称，混合文字/符号头像。")
    }
}

// MARK: - List Showcase（List 分组列表组件独立 Demo 页，与 Android ListDemo 一一对应）

final class ListShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List 分组列表"
        addVersionBadge(componentName: "List", version: "v1.0", builtAt: "")

        addInfo("4 组排查：① 基础行 ② 带值行 ③ 可点击行 ④ 多分组。双端 1:1 对齐。")

        // ── Demo 1：基础列表行（仅标题）──
        addSection(title: "Demo 1 · 基础列表行") { container in
            let group = GroupList()
            let items = [
                self.makeItem(title: "设置", value: nil, showsChevron: false),
                self.makeItem(title: "通用", value: nil, showsChevron: false),
                self.makeItem(title: "关于", value: nil, showsChevron: false),
            ]
            group.setRows(items)
            container.addSubview(group)
            group.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("仅标题，无右侧值/箭头。")

        // ── Demo 2：带值列表行 ──
        addSection(title: "Demo 2 · 带值列表行") { container in
            let group = GroupList()
            let items = [
                self.makeItem(title: "版本", value: "v1.3.5", showsChevron: false),
                self.makeItem(title: "设备", value: "iPhone 15 Pro", showsChevron: false),
                self.makeItem(title: "存储", value: "128 GB", showsChevron: false),
            ]
            group.setRows(items)
            container.addSubview(group)
            group.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("标题 + 右侧值（textSecondary, sizeSm）。")

        // ── Demo 3：可点击列表行（带箭头）──
        addSection(title: "Demo 3 · 可点击列表行") { container in
            let group = GroupList()
            let items = [
                self.makeItem(title: "账号管理", value: "已绑定", showsChevron: true),
                self.makeItem(title: "消息通知", value: "已开启", showsChevron: true),
                self.makeItem(title: "隐私设置", value: nil, showsChevron: true),
            ]
            group.setRows(items)
            container.addSubview(group)
            group.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("标题 + 值 + 右箭头（chevron.right, textSecondary）。")

        // ── Demo 4：多分组列表 ──
        addSection(title: "Demo 4 · 多分组列表") { container in
            let col = UIStackView()
            col.axis = .vertical
            col.spacing = AppSpace.lg

            let group1 = GroupList()
            group1.setRows([
                self.makeItem(title: "个人资料", value: "已完善", showsChevron: true),
                self.makeItem(title: "账号安全", value: nil, showsChevron: true),
            ])
            col.addArrangedSubview(group1)

            let group2 = GroupList()
            group2.setRows([
                self.makeItem(title: "清除缓存", value: "23.5 MB", showsChevron: true),
                self.makeItem(title: "检查更新", value: "最新版", showsChevron: true),
                self.makeItem(title: "退出登录", value: nil, showsChevron: true),
            ])
            col.addArrangedSubview(group2)

            container.addSubview(col)
            col.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("两个独立分组，间距 AppSpace.lg，模拟设置页。")
    }

    private func makeItem(title: String, value: String?, showsChevron: Bool) -> GroupListItem {
        let item = GroupListItem()
        item.apply(title: title, value: value, showsChevron: showsChevron)
        return item
    }
}

// MARK: - Grid Showcase（Grid 宫格组件独立 Demo 页，与 Android GridDemo 一一对应）

final class GridShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grid 宫格"
        addVersionBadge(componentName: "Grid", version: "v2.0", builtAt: "")

        addInfo("4 组排查：① 基础四宫格 ② 带标题分区 ③ 可点击交互 ④ 多分组网格。双端 1:1 对齐。")

        // ── Demo 1：基础四宫格 ──
        addSection(title: "Demo 1 · 基础四宫格") { container in
            let grid = Grid()
            grid.apply(title: "", items: [
                GridItem(title: "列表", symbolName: "list.bullet.rectangle"),
                GridItem(title: "图表", symbolName: "chart.xyaxis.line"),
                GridItem(title: "加号", symbolName: "plus.circle.fill"),
                GridItem(title: "人物", symbolName: "person"),
            ])
            container.addSubview(grid)
            grid.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("4 个入口等分，无标题（title 可选），图标 26pt primary 色 + 标题 sizeXs textPrimary。")

        // ── Demo 2：带标题分区 ──
        addSection(title: "Demo 2 · 带标题分区") { container in
            let grid = Grid()
            grid.apply(title: "小工具", items: [
                GridItem(title: "浏览器", symbolName: "safari"),
                GridItem(title: "手机", symbolName: "iphone"),
                GridItem(title: "邮箱", symbolName: "envelope"),
                GridItem(title: "下拉", symbolName: "arrowtriangle.down.fill"),
            ])
            container.addSubview(grid)
            grid.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("不同图标组合，验证分区标题 + 图标网格布局。")

        // ── Demo 3：可点击交互 ──
        addSection(title: "Demo 3 · 可点击交互") { container in
            let grid = Grid()
            grid.apply(title: "快捷入口", items: [
                GridItem(title: "列表", symbolName: "list.bullet.rectangle"),
                GridItem(title: "图表", symbolName: "chart.xyaxis.line"),
                GridItem(title: "人物", symbolName: "person"),
                GridItem(title: "邮箱", symbolName: "envelope"),
            ])
            grid.onSelect = { index in
                print("Grid Demo3 tapped: \(index)")
            }
            container.addSubview(grid)
            grid.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("onSelect 回调返回索引，点击入口触发（打印 index）。")

        // ── Demo 4：多分组网格 ──
        addSection(title: "Demo 4 · 多分组网格") { container in
            let col = UIStackView()
            col.axis = .vertical
            col.spacing = AppSpace.lg

            let grid1 = Grid()
            grid1.apply(title: "常用功能", items: [
                GridItem(title: "列表", symbolName: "list.bullet.rectangle"),
                GridItem(title: "图表", symbolName: "chart.xyaxis.line"),
                GridItem(title: "加号", symbolName: "plus.circle.fill"),
                GridItem(title: "人物", symbolName: "person"),
            ])

            let grid2 = Grid()
            grid2.apply(title: "小工具", items: [
                GridItem(title: "浏览器", symbolName: "safari"),
                GridItem(title: "手机", symbolName: "iphone"),
                GridItem(title: "邮箱", symbolName: "envelope"),
                GridItem(title: "下拉", symbolName: "arrowtriangle.down.fill"),
            ])

            col.addArrangedSubview(grid1)
            col.addArrangedSubview(grid2)
            container.addSubview(col)
            col.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("两个独立 Grid，间距 AppSpace.lg，模拟发现页。")
    }
}

// MARK: - Layout Showcase（Layout 布局组件独立 Demo 页，与 Android LayoutDemo 一一对应）

final class LayoutShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Layout 布局"
        addVersionBadge(componentName: "Layout", version: "v1.0", builtAt: "")

        addInfo("4 组排查：① 双栏统计卡片 ② 详情 label-value 行 ③ 筛选/工具行 ④ 嵌套组合。双端 1:1 对齐。")

        // ── Demo 1：双栏统计卡片（span 6+6）──
        addSection(title: "Demo 1 · 双栏统计卡片") { container in
            let row = LayoutRow()
            container.addSubview(row)
            row.snp.makeConstraints { $0.edges.equalToSuperview() }

            let colA = LayoutCol(span: 6)
            let colB = LayoutCol(span: 6)
            row.addCols([colA, colB])

            let cardA = makeStatCard(amount: "+¥12,680", amountColor: AppColor.income, label: "本月收入")
            let cardB = makeStatCard(amount: "−¥8,340", amountColor: AppColor.expense, label: "本月支出")
            colA.addSubview(cardA)
            cardA.snp.makeConstraints { $0.edges.equalToSuperview() }
            colB.addSubview(cardB)
            cardB.snp.makeConstraints { $0.edges.equalToSuperview() }
        }

        // ── Demo 2：详情 label-value 行（span 4+8）──
        addSection(title: "Demo 2 · 详情 label-value 行") { container in
            let rows = UIStackView()
            rows.axis = .vertical
            rows.spacing = AppSpace.sm
            container.addSubview(rows)
            rows.snp.makeConstraints { $0.edges.equalToSuperview() }

            rows.addArrangedSubview(makeKVRow(key: "分类", value: "餐饮 · 工作日午餐"))
            rows.addArrangedSubview(makeKVRow(key: "账户", value: "招商银行(4609)"))
            rows.addArrangedSubview(makeKVRow(key: "备注", value: "—"))
        }

        // ── Demo 3：筛选/工具行（span 4+4+4）──
        addSection(title: "Demo 3 · 筛选/工具行") { container in
            let row = LayoutRow()
            container.addSubview(row)
            row.snp.makeConstraints { $0.edges.equalToSuperview() }

            let colA = LayoutCol(span: 4)
            let colB = LayoutCol(span: 4)
            let colC = LayoutCol(span: 4)
            row.addCols([colA, colB, colC])

            colA.addSubview(makePill(title: "周"))
            colB.addSubview(makePill(title: "月"))
            colC.addSubview(makePill(title: "年"))
            colA.subviews.first?.snp.makeConstraints { $0.edges.equalToSuperview() }
            colB.subviews.first?.snp.makeConstraints { $0.edges.equalToSuperview() }
            colC.subviews.first?.snp.makeConstraints { $0.edges.equalToSuperview() }
        }

        // ── Demo 4：嵌套与组合（Row 内嵌 Row）──
        addSection(title: "Demo 4 · 嵌套与组合") { container in
            let row = LayoutRow()
            container.addSubview(row)
            row.snp.makeConstraints { $0.edges.equalToSuperview() }

            let colA = LayoutCol(span: 6)
            let colB = LayoutCol(span: 6)
            row.addCols([colA, colB])

            let cardA = makeKVCard(
                title: "今日账单",
                rows: [("支出", "¥260.00"), ("笔数", "6 笔")]
            )
            let cardB = makeKVCard(
                title: "本月小计",
                rows: [("支出", "¥1,240.00"), ("收入", "¥2,800.00")]
            )
            colA.addSubview(cardA)
            cardA.snp.makeConstraints { $0.edges.equalToSuperview() }
            colB.addSubview(cardB)
            cardB.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }

    // MARK: - Demo 内容构造

    /// 统计卡片（白底圆角边框，数值 + 标签）。
    private func makeStatCard(amount: String, amountColor: UIColor, label: String) -> UIView {
        let shell = makeCardBase()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppSpace.xs
        shell.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(AppSpace.lg) }

        let value = UILabel()
        value.font = .systemFont(ofSize: AppFont.sizeLg, weight: .semibold)
        value.textColor = amountColor
        value.text = amount
        let caption = UILabel()
        caption.font = .systemFont(ofSize: AppFont.sizeXs)
        caption.textColor = AppColor.textSecondary
        caption.text = label
        stack.addArrangedSubview(value)
        stack.addArrangedSubview(caption)
        return shell
    }

    /// kv 卡片（标题 + 多行 label-value），与 makeStatCard 同构等高。
    private func makeKVCard(title: String, rows: [(String, String)]) -> UIView {
        let shell = makeCardBase()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppSpace.sm
        shell.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(AppSpace.lg) }

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.text = title
        stack.addArrangedSubview(titleLabel)

        for (key, value) in rows {
            stack.addArrangedSubview(makeKVRow(key: key, value: value))
        }
        return shell
    }

    /// 卡片底（白底 + 圆角 lg + 细边框）。
    private func makeCardBase() -> UIView {
        let shell = UIView()
        shell.backgroundColor = AppColor.bgCard
        shell.layer.cornerRadius = AppRadius.lg
        shell.layer.borderWidth = 1 / UIScreen.main.scale
        shell.layer.borderColor = AppColor.border.cgColor
        return shell
    }

    /// label-value 单行（LayoutRow span 4+8；key 灰字、value 主色）。
    private func makeKVRow(key: String, value: String) -> UIView {
        let row = LayoutRow()
        let keyCol = LayoutCol(span: 4)
        let valueCol = LayoutCol(span: 8)
        row.addCols([keyCol, valueCol])

        let keyLabel = UILabel()
        keyLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        keyLabel.textColor = AppColor.textSecondary
        keyLabel.text = key
        keyCol.addSubview(keyLabel)
        keyLabel.snp.makeConstraints { $0.edges.equalToSuperview() }

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        valueLabel.textColor = AppColor.textPrimary
        valueLabel.text = value
        valueCol.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        return row
    }

    /// 圆角药丸（primaryMuted 底 + primaryPressed 字，高 32）。
    private func makePill(title: String) -> UIView {
        let pill = UIView()
        pill.backgroundColor = AppColor.primaryMuted
        pill.layer.cornerRadius = 16
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textColor = AppColor.primaryPressed
        label.textAlignment = .center // label 被 leading/trailing 拉宽，默认左对齐会导致文字偏左；对齐 Android Box(Center)
        pill.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpace.sm)
        }
        pill.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        return pill
    }
}

// MARK: - Space Showcase（Space 间距组件独立 Demo 页，与 Android SpaceDemo 一一对应）

final class SpaceShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Space 间距"
        addVersionBadge(componentName: "Space", version: "v1.0", builtAt: "")

        addInfo("5 段排查：① icon+文字 工具组(sm) ② chip 标签组(sm) ③ 区块间隔双卡(xl) ④ 垂直详情行(md) ⑤ 方向对照+嵌套。双端 1:1 对齐。")

        // ── Demo 1：水平 icon+文字 工具组（size=sm 8）──
        addSection(title: "Demo 1 · icon+文字 工具组（sm=8）") { container in
            let space = Space(direction: .horizontal, spacing: AppSpace.sm)
            container.addSubview(space)
            space.snp.makeConstraints { $0.edges.equalToSuperview() }
            space.addItems([
                makeToolItem(text: "记一笔", iconTint: AppColor.primary),
                makeToolItem(text: "扫一扫", iconTint: AppColor.primaryPressed),
                makeToolItem(text: "账单", iconTint: AppColor.textSecondary),
                makeToolItem(text: "设置", iconTint: AppColor.primary),
            ])
        }
        addInfo("相邻子项间距 8pt，首尾无 padding（紧凑工具组默认档位即用）。")

        // ── Demo 2：chip 标签组（size=sm 8）──
        addSection(title: "Demo 2 · chip 标签组（sm=8）") { container in
            let space = Space(direction: .horizontal, spacing: AppSpace.sm)
            container.addSubview(space)
            space.snp.makeConstraints { $0.edges.equalToSuperview() }
            space.addItems(["全部", "餐饮", "交通", "购物", "其他"].map { makeChip(title: $0) })
        }

        // ── Demo 3：区块间隔双卡（horizontal size=xl 24）──
        addSection(title: "Demo 3 · 区块间隔双卡（xl=24）") { container in
            let space = Space(direction: .horizontal, spacing: AppSpace.xl)
            container.addSubview(space)
            space.snp.makeConstraints { $0.edges.equalToSuperview() }
            space.addItems([
                makeBadgeCard(label: "本月收入", value: "¥12,680", valueColor: AppColor.income),
                makeBadgeCard(label: "本月支出", value: "¥8,340", valueColor: AppColor.expense),
            ])
        }
        addInfo("区块级显式间隔：业务按需传 xl=24（内部组默认 sm 即可，档位由调用方定）。")

        // ── Demo 4：垂直详情行（vertical size=md 12）──
        addSection(title: "Demo 4 · 垂直详情行（md=12）") { container in
            let space = Space(direction: .vertical, spacing: AppSpace.md)
            container.addSubview(space)
            space.snp.makeConstraints { $0.edges.equalToSuperview() }
            space.addItems([
                makeKVLine(key: "分类", value: "餐饮 · 工作日午餐"),
                makeKVLine(key: "账户", value: "招商银行(4609)"),
                makeKVLine(key: "时间", value: "2026-09-04 12:30"),
                makeKVLine(key: "备注", value: "—"),
            ])
        }

        // ── Demo 5：方向对照 + 嵌套（同内容 h/v 对照；Space 子项可为任意内容）──
        addSection(title: "Demo 5 · 方向对照与嵌套") { container in
            let outer = Space(direction: .vertical, spacing: AppSpace.lg)
            container.addSubview(outer)
            outer.snp.makeConstraints { $0.edges.equalToSuperview() }

            // 对照一：horizontal sm 概要 chips
            let hChips = Space(direction: .horizontal, spacing: AppSpace.sm)
            hChips.addItems(["本周支出 ¥1,260", "笔数 18", "最大单笔 ¥320"].map { makeChip(title: $0) })
            outer.addItem(hChips)

            // 对照二：同内容 vertical md 的 label-value 行
            let vLines = Space(direction: .vertical, spacing: AppSpace.md)
            vLines.addItems([
                makeKVLine(key: "本周支出", value: "¥1,260"),
                makeKVLine(key: "笔数", value: "18"),
                makeKVLine(key: "最大单笔", value: "¥320"),
            ])
            outer.addItem(vLines)

            // 嵌套：vertical 组内再放垂直卡片组 + 水平工具行
            let inner = Space(direction: .vertical, spacing: AppSpace.md)
            inner.addItems([
                makeBadgeCard(label: "本月小计", value: "支出 ¥8,340 · 收入 ¥12,680", valueColor: AppColor.textPrimary),
                makeToolItem(text: "查看账单明细", iconTint: AppColor.primary),
            ])
            outer.addItem(inner)
        }
    }

    // MARK: - Demo 内容构造

    /// icon+文字 工具项（SpaceToolItemView 自带 intrinsic 内容宽，UIStackView 排布稳定）。
    private func makeToolItem(text: String, iconTint: UIColor) -> UIView {
        SpaceToolItemView(text: text, iconTint: iconTint)
    }

    /// 筛选 chip（SpaceChipView 自带 intrinsic 内容宽）。
    private func makeChip(title: String) -> UIView {
        SpaceChipView(title: title)
    }

    /// 区块双卡（SpaceBadgeCardView 自带 intrinsic 内容宽）。
    private func makeBadgeCard(label: String, value: String, valueColor: UIColor) -> UIView {
        SpaceBadgeCardView(label: label, value: value, valueColor: valueColor)
    }

    /// key-value 单行（key 灰字 + value 主色，行内间距 sm=8；外层可直接进 vertical Space）。
    private func makeKVLine(key: String, value: String) -> UIView {
        let line = Space(direction: .horizontal, spacing: AppSpace.sm)
        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        keyLabel.textColor = AppColor.textSecondary
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        valueLabel.textColor = AppColor.textPrimary
        line.addItems([keyLabel, valueLabel])
        return line
    }
}

// MARK: - Space Demo 子视图（自带 intrinsic 内容宽：UIStackView 对无 intrinsic 的普通 UIView
// 子项排布时无法确定内容宽度，富余空间被摊给首项致其拉大；提供 intrinsic + required hugging 后
// 按内容宽排布，与 Android Compose wrap_content 对齐）

/// icon+文字 工具项（白底圆角细边框 + 左 icon 色块 + 文字，intrinsic 宽=md+icon14+gap+文字宽+md，高 36）。
private final class SpaceToolItemView: UIView {
    private let label = UILabel()

    init(text: String, iconTint: UIColor) {
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = AppRadius.md
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = AppColor.border.cgColor

        let icon = UIView()
        icon.backgroundColor = iconTint
        icon.layer.cornerRadius = 4
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textColor = AppColor.textPrimary

        addSubview(icon)
        addSubview(label)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.md)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 14, height: 14))
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(AppSpace.xs + 2)
            make.centerY.equalToSuperview()
        }
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SpaceToolItemView 不支持 NSCoder 解码")
    }

    override var intrinsicContentSize: CGSize {
        let w = AppSpace.md + 14 + AppSpace.xs + 2 + label.intrinsicContentSize.width + AppSpace.md
        return CGSize(width: w, height: 36)
    }
}

/// 筛选 chip（primaryMuted 底 + primaryPressed 字，intrinsic 宽=md+文字宽+md，高 28）。
private final class SpaceChipView: UIView {
    private let label = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = AppColor.primaryMuted
        layer.cornerRadius = 14
        label.text = title
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.primaryPressed

        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(AppSpace.md)
        }
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SpaceChipView 不支持 NSCoder 解码")
    }

    override var intrinsicContentSize: CGSize {
        let w = AppSpace.md + label.intrinsicContentSize.width + AppSpace.md
        return CGSize(width: w, height: 28)
    }
}

/// 区块双卡（白底圆角 lg + label/value 纵向堆叠，intrinsic 宽=最宽行+lg×2；高度由内部约束链闭环）。
private final class SpaceBadgeCardView: UIView {
    private let caption = UILabel()
    private let valueLabel = UILabel()

    init(label: String, value: String, valueColor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = AppRadius.lg
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = AppColor.border.cgColor

        caption.text = label
        caption.font = .systemFont(ofSize: AppFont.sizeXs)
        caption.textColor = AppColor.textSecondary
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        valueLabel.textColor = valueColor

        addSubview(caption)
        addSubview(valueLabel)
        caption.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.top.equalToSuperview().offset(AppSpace.md)
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(caption.snp.leading)
            make.top.equalTo(caption.snp.bottom).offset(AppSpace.xs)
            make.bottom.equalToSuperview().offset(-AppSpace.md)
        }
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SpaceBadgeCardView 不支持 NSCoder 解码")
    }

    override var intrinsicContentSize: CGSize {
        let longest = max(caption.intrinsicContentSize.width, valueLabel.intrinsicContentSize.width)
        return CGSize(width: longest + AppSpace.lg * 2, height: UIView.noIntrinsicMetric)
    }
}

// MARK: - Card Showcase（Card 摘要卡片组件独立 Demo 页，与 Android CardDemo 一一对应）

final class CardShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card 商品卡片"
        addVersionBadge(componentName: "Card", version: "v1.0", builtAt: "")

        addInfo("4 组排查：① 基础摘要卡 ② 带颜色数值 ③ 无辅助文案 ④ 可点击卡片。双端 1:1 对齐。")

        // ── Demo 1：基础摘要卡 ──
        addSection(title: "Demo 1 · 基础摘要卡") { container in
            let card = SummaryCardView()
            card.apply(
                title: "本月支出",
                subtitle: "2026 年 9 月 · 餐饮 + 交通 + 购物",
                value: "¥ 3,280.50",
                valueColor: AppColor.textPrimary,
                accessory: "较上月 +5.2%"
            )
            container.addSubview(card)
            card.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("title + subtitle + value（textPrimary）+ accessory，完整四元素。")

        // ── Demo 2：带颜色数值 ──
        addSection(title: "Demo 2 · 带颜色数值") { container in
            let card = SummaryCardView()
            card.apply(
                title: "本月收入",
                subtitle: "工资 + 理财收益",
                value: "¥ 8,500.00",
                valueColor: .systemGreen,
                accessory: "较上月 +12.8%"
            )
            container.addSubview(card)
            card.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("valueColor = systemGreen，数值绿色表示正向。")

        // ── Demo 3：无辅助文案 ──
        addSection(title: "Demo 3 · 无辅助文案") { container in
            let card = SummaryCardView()
            card.apply(
                title: "账户余额",
                subtitle: "可用余额 · 含储蓄卡 + 信用卡",
                value: "¥ 15,420.30",
                valueColor: AppColor.primary,
                accessory: nil
            )
            container.addSubview(card)
            card.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("accessory = nil，隐藏辅助文案，数值左对齐。")

        // ── Demo 4：可点击卡片 ──
        addSection(title: "Demo 4 · 可点击卡片") { container in
            let card = SummaryCardView()
            card.apply(
                title: "预算管理",
                subtitle: "本月预算 ¥ 5,000 · 已用 65.6%",
                value: "¥ 3,280.50",
                valueColor: .systemOrange,
                accessory: "查看详情"
            )
            card.addTarget(self, action: #selector(self.cardTapped), for: .touchUpInside)
            container.addSubview(card)
            card.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("UIControl 整卡可点击，valueColor = systemOrange 警示色。")
    }

    @objc private func cardTapped() {
        print("Card Demo4 tapped")
    }
}

// MARK: - LineChart Showcase（LineChart 折线图组件独立 Demo 页，与 Android LineChartDemo 一一对应）

final class LineChartShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LineChart 折线图"
        addVersionBadge(componentName: "LineChart", version: "v1.0", builtAt: "")

        addInfo("4 组排查：① 基础双折线 ② 仅支出 ③ 仅收入 ④ 空态。双端 1:1 对齐。")

        // ── Demo 1：基础双折线 ──
        addSection(title: "Demo 1 · 基础双折线") { container in
            let chart = TrendChartView()
            chart.apply(
                expensePoints: [
                    ChartPoint(label: "4月", amount: 1200),
                    ChartPoint(label: "5月", amount: 1800),
                    ChartPoint(label: "6月", amount: 1500),
                    ChartPoint(label: "7月", amount: 2200),
                    ChartPoint(label: "8月", amount: 1900),
                    ChartPoint(label: "9月", amount: 2500),
                ],
                incomePoints: [
                    ChartPoint(label: "4月", amount: 3000),
                    ChartPoint(label: "5月", amount: 3500),
                    ChartPoint(label: "6月", amount: 3200),
                    ChartPoint(label: "7月", amount: 4000),
                    ChartPoint(label: "8月", amount: 3800),
                    ChartPoint(label: "9月", amount: 4500),
                ]
            )
            container.addSubview(chart)
            chart.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("支出红 + 收入绿双折线，6 个月数据，含 Y 轴刻度 + X 轴标签。")

        // ── Demo 2：仅支出 ──
        addSection(title: "Demo 2 · 仅支出") { container in
            let chart = TrendChartView()
            chart.apply(
                expensePoints: [
                    ChartPoint(label: "周一", amount: 200),
                    ChartPoint(label: "周二", amount: 350),
                    ChartPoint(label: "周三", amount: 180),
                    ChartPoint(label: "周四", amount: 420),
                    ChartPoint(label: "周五", amount: 380),
                    ChartPoint(label: "周六", amount: 500),
                    ChartPoint(label: "周日", amount: 280),
                ],
                incomePoints: []
            )
            container.addSubview(chart)
            chart.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("仅支出红色折线，7 天数据，验证单序列渲染。")

        // ── Demo 3：仅收入 ──
        addSection(title: "Demo 3 · 仅收入") { container in
            let chart = TrendChartView()
            chart.apply(
                expensePoints: [],
                incomePoints: [
                    ChartPoint(label: "Q1", amount: 8000),
                    ChartPoint(label: "Q2", amount: 9500),
                    ChartPoint(label: "Q3", amount: 7200),
                    ChartPoint(label: "Q4", amount: 11000),
                ]
            )
            container.addSubview(chart)
            chart.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        addInfo("仅收入绿色折线，4 季度数据，验证单序列渲染。")

        // ── Demo 4：空态 ──
        addSection(title: "Demo 4 · 空态") { container in
            let chart = TrendChartView()
            chart.apply(
                expensePoints: [],
                incomePoints: []
            )
            container.addSubview(chart)
            chart.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(140)
            }
        }
        addInfo("无数据时显示空态文案「暂无数据」。")
    }
}

// MARK: - OverlayShowcase（基础组件 #6，四组 Demo 与设计规格 §04 / Android OverlayDemo 1:1 对齐）

final class OverlayShowcase: ShowcaseViewController {

    private var overlayRefs: [Overlay] = []   // 持有强引用，保证闭包外生命周期
    private var feedbackLabel: UILabel!
    // ⚠️ Demo2 气泡点击手势临时弱引用 overlay：UIGestureRecognizer.addAction 需要 iOS 14+，为兼容低版本用 addTarget:action: 老写法=必须把局部 overlay 通过属性挂到 self 上供 @objc selector 读取（避免用 associated object=太重）
    private weak var demo2TapOverlay: Overlay?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Overlay 遮罩层"

        // 组件版本 v2.0（iOS 布局完整修复：递归测量 + 防御重建 + init 顺序），组件库版本 v1.3.13
        addVersionBadge(componentName: "Overlay", version: "v2.0", builtAt: "2026-09-04")
        feedbackLabel = addFeedbackBar()

        addInfo("定位：浮层通用基座。4 组排查：① 默认遮罩+居中确认框；② 透明穿透+新手气泡 top-right；③ 底部抽屉（contentPosition=bottom + radius=lg 顶两圆角）；④ 圆角卡片居中。双端 1:1，点击下方按钮触发对应 Demo。")

        // ── Demo 1：默认遮罩+居中确认框（onClose 由遮罩背景点击触发，onMaskClick 回调解耦）──
        addSection(title: "Demo 1 · 默认遮罩 + 居中确认框") { container in
            let btn = buildDemoButton(title: "打开确认退出弹窗") { [weak self] in
                self?.showDemo1ConfirmDialog()
            }
            container.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(56)
            }
        }
        addInfo("maskColor=default（55% 黑）；closeOnMaskClick=默认 true；contentPosition=center；点击外部→onMaskClick→onClose。")

        // ── Demo 2：透明穿透 + 新手气泡 top-right（clickThrough=true）──
        addSection(title: "Demo 2 · 透明穿透 + 新手气泡（top-right）") { container in
            let btn = buildDemoButton(title: "显示气泡蒙版 3 秒") { [weak self] in
                self?.showDemo2TransparentBubble()
            }
            container.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(56)
            }
        }
        addInfo("maskColor=transparent + clickThrough=true（事件穿透到底层页面；气泡本身仍可点击）；contentPosition=top-right；offset y=状态栏+44pt。")

        // ── Demo 3：底部抽屉（contentPosition=bottom + contentRadius=lg 顶两圆角自动）──
        addSection(title: "Demo 3 · 底部抽屉（顶两圆角 radius=lg）") { container in
            let btn = buildDemoButton(title: "打开日期范围选择器") { [weak self] in
                self?.showDemo3BottomSheet()
            }
            container.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(56)
            }
        }
        addInfo("contentPosition=bottom + contentRadius=lg → 底两角=0（贴边自动保留直角）；点击遮罩空白区 = 触发 onMaskClick + onClose。")

        // ── Demo 4：圆角卡片居中（4 圆角 Radius=lg）──
        addSection(title: "Demo 4 · 圆角卡片居中（4 圆角 radius=lg）") { container in
            let btn = buildDemoButton(title: "显示已保存 3 条记账") { [weak self] in
                self?.showDemo4RoundedCard()
            }
            container.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(56)
            }
        }
        addInfo("contentPosition=center + contentRadius=lg；4 角全 14px；animation=默认 true（fade in/out）。")
    }

    // ============== Demo 内容工厂 ==============

    private func makeOverlay(
        maskColor: OverlayMaskColor = .default,
        closeOnMaskClick: Bool = true,
        clickThrough: Bool = false,
        position: OverlayContentPosition = .center,
        offset: CGPoint = .zero,
        radius: OverlayRadius = .value(0),
        animation: Bool = true,
        tag: String,
        contentBuilder: @escaping (UIView) -> Void
    ) -> Overlay {
        let overlay = Overlay(
            visible: false,
            maskColor: maskColor,
            closeOnMaskClick: closeOnMaskClick,
            clickThrough: clickThrough,
            contentPosition: position,
            contentOffset: offset,
            contentRadius: radius,
            animation: animation,
            content: contentBuilder,
            onClose: { [weak self] in
                self?.feedbackLabel.text = "[\(tag)] onClose 触发 → 已关闭"
            },
            onMaskClick: { [weak self] in
                self?.feedbackLabel.text = "[\(tag)] onMaskClick → onClose 将紧随其后"
            }
        )
        overlayRefs.append(overlay)
        return overlay
    }

    // Demo 1：确认退出弹窗（center + closeOnMaskClick）
    private func showDemo1ConfirmDialog() {
        // ⚠️ 永久钉死变量声明顺序（真 build 第92/93/94/95 条实锤=4条 Closure captures 'overlay' before it is declared 同根因）：
        // 绝对不能写 let overlay = makeOverlay(内容闭包/嵌套闭包里捕获 overlay)= 因为 makeOverlay 的初始化表达式执行时= overlay 这个 let 常量还没绑定（绑定要等表达式返回后才做）= 闭包里捕获 overlay=必然炸！
        // 唯一合法写法=先 var overlay: Overlay? = nil（先声明占位=overlay已经存在于作用域），然后 overlay = makeOverlay(...)（赋值给已声明变量=闭包里捕获 overlay 时=它已经存在=不炸）；函数尾打开 visible=写 overlay?.visible = true（可选链=安全）
        var overlay: Overlay? = nil
        overlay = makeOverlay(position: .center, radius: .lg, tag: "Demo1") { container in
            container.backgroundColor = .white

            let titleLabel = UILabel()
            titleLabel.text = "确认退出？"
            titleLabel.font = .boldSystemFont(ofSize: 16)
            titleLabel.textColor = UIColor(red: 0x11/255, green: 0x18/255, blue: 0x27/255, alpha: 1)

            let subLabel = UILabel()
            subLabel.text = "退出后当前编辑内容不会自动保存"
            subLabel.font = .systemFont(ofSize: 13)
            subLabel.textColor = UIColor(red: 0x6B/255, green: 0x72/255, blue: 0x80/255, alpha: 1)
            subLabel.numberOfLines = 0

            let cancel = self.makeDialogButton(title: "取消", primary: false) { [weak overlay] in
                overlay?.visible = false
            }
            let confirm = self.makeDialogButton(title: "确定", primary: true) { [weak overlay, weak self] in
                overlay?.visible = false
                self?.feedbackLabel.text = "[Demo1] 确定点击 → 手动 visible=false 关（不重复触发 onClose）"
            }

            let btnStack = UIStackView(arrangedSubviews: [cancel, confirm])
            btnStack.axis = .horizontal
            btnStack.spacing = 8
            btnStack.distribution = .fillEqually

            let stack = UIStackView(arrangedSubviews: [titleLabel, subLabel, btnStack])
            stack.axis = .vertical
            stack.spacing = 14
            // ⚠️ 用 center + 固定宽度 + inset padding 代替 edges.equalToSuperview()
            // edges 让子视图尺寸=父容器尺寸→循环依赖→Auto Layout 无法解析高度
            // center + intrinsicContentSize → Auto Layout 能正确解析
            container.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(240) // 280 - 20*2 inset
            }
            // container 宽度由 stack + padding 决定
            container.snp.makeConstraints { make in
                make.width.equalTo(280)
                make.top.equalTo(stack).offset(-20)
                make.bottom.equalTo(stack).offset(20)
            }
        }
        feedbackLabel.text = "[Demo1] 打开遮罩，点击空白区域观察 onMaskClick→onClose 顺序（或点 确定/取消）"
        overlay?.visible = true
    }

    // Demo 2：透明穿透 + 新手气泡 top-right
    private func showDemo2TransparentBubble() {
        // ⚠️ 同上=永久钉死变量声明顺序（必须先 var overlay: Overlay? = nil 再赋值=内容闭包里引用 overlay=才不会捕获前声明）
        var overlay: Overlay? = nil
        overlay = makeOverlay(
            maskColor: .transparent,
            closeOnMaskClick: false,
            clickThrough: true,
            position: .topRight,
            offset: CGPoint(x: -12, y: 88),
            radius: .md,
            tag: "Demo2"
        ) { container in
            container.backgroundColor = UIColor(red: 0x16/255, green: 0xA3/255, blue: 0x4A/255, alpha: 1)
            container.widthAnchor.constraint(equalToConstant: 200).isActive = true

            let text = UILabel()
            text.text = "🎉 新手引导：点击「+」可快速记账哦～"
            text.textColor = .white
            text.numberOfLines = 0
            text.font = .systemFont(ofSize: 12)
            container.addSubview(text)
            text.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(12)
            }
            // 气泡本身点击（非遮罩，clickThrough 不影响子控件）
            // ⚠️ UITapGestureRecognizer.addAction(UIAction) 需要 iOS 14+，为兼容所有 Deployment Target（真 build 第 26 条实锤=低版本 has no member addAction）=改 iOS 2.0+ 通用老写法 addTarget + @objc selector
            // ⚠️ 再补=makeOverlay 的内容闭包是 @escaping=闭包内引用 self 的方法=必须显式写 self.（真 build 第 91 条实锤=Call to method onDemo2BubbleTap in closure requires explicit self → 所以 #selector(...) 里写成 self.onDemo2BubbleTap(_:)）
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.onDemo2BubbleTap(_:)))
            // 把局部 overlay 临时存入 weak 属性（供 selector 读取，避免 associated object 复杂度）
            self.demo2TapOverlay = overlay
            container.addGestureRecognizer(tap)
        }
        feedbackLabel.text = "[Demo2] 已显示气泡 3 秒：遮罩透明+穿透，仍可操作 Demo 列表下方按钮；3s 后自动关闭（或点击气泡立即关）"
        overlay?.visible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak overlay] in
            overlay?.visible = false
        }
    }

    // ⚠️ Demo2 气泡点击 @objc selector（与 UITapGestureRecognizer addTarget:action: 老写法配对=兼容 iOS 所有版本，避免 iOS 14+ addAction 的版本门槛）
    @objc private func onDemo2BubbleTap(_ sender: UITapGestureRecognizer) {
        self.demo2TapOverlay?.visible = false
        self.feedbackLabel.text = "[Demo2] 气泡点击 → 立即关闭"
    }

    // Demo 3：底部抽屉（position=bottom + radius=lg → 顶两圆角）
    private func showDemo3BottomSheet() {
        // ⚠️ 同上=永久钉死变量声明顺序（必须先 var overlay: Overlay? = nil 再赋值=嵌套闭包捕获 overlay=才不会捕获前声明）
        var overlay: Overlay? = nil
        overlay = makeOverlay(position: .bottom, radius: .lg, tag: "Demo3") { container in
            container.backgroundColor = .white
            container.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true

            let handle = UIView()
            handle.backgroundColor = UIColor(red: 0xE5/255, green: 0xE7/255, blue: 0xEB/255, alpha: 1)
            handle.layer.cornerRadius = 2
            handle.snp.makeConstraints { make in
                make.width.equalTo(40)
                make.height.equalTo(4)
            }
            let handleWrap = UIView()
            handleWrap.addSubview(handle)
            handle.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-6)
            }

            let titleLabel = UILabel()
            titleLabel.text = "选择日期范围"
            titleLabel.font = .boldSystemFont(ofSize: 16)

            let sub = UILabel()
            sub.text = "本周 / 本月 / 自定义…"
            sub.font = .systemFont(ofSize: 13)
            sub.textColor = UIColor(red: 0x6B/255, green: 0x72/255, blue: 0x80/255, alpha: 1)

            // ⚠️ 闭包内调用 self.makeOptionRow 必须显式 self（Swift 闭包捕获语义=显式 make capture semantics explicit）+ capture list 加 [weak self] 防循环引用（否则强引用 self=闭包不释放）
            let row1 = self.makeOptionRow(title: "本周") { [weak overlay, weak self] in overlay?.visible = false; self?.feedbackLabel.text = "[Demo3] 选择「本周」" }
            let row2 = self.makeOptionRow(title: "本月") { [weak overlay, weak self] in overlay?.visible = false; self?.feedbackLabel.text = "[Demo3] 选择「本月」" }
            let row3 = self.makeOptionRow(title: "自定义…") { [weak overlay, weak self] in overlay?.visible = false; self?.feedbackLabel.text = "[Demo3] 选择「自定义…」" }

            let stack = UIStackView(arrangedSubviews: [handleWrap, titleLabel, sub, row1, row2, row3])
            stack.axis = .vertical
            stack.spacing = 12
            stack.isLayoutMarginsRelativeArrangement = true
            stack.layoutMargins = .init(top: 6, left: 16, bottom: 24, right: 16)
            container.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        feedbackLabel.text = "[Demo3] 底部抽屉顶两圆角 / 底两直角 = 0（贴边自动掩膜）；点击遮罩空白区 → 关闭"
        overlay?.visible = true
    }

    // Demo 4：圆角卡片居中（4 圆角）
    private func showDemo4RoundedCard() {
        // ⚠️ 同上=永久钉死变量声明顺序（必须先 var overlay: Overlay? = nil 再赋值=嵌套闭包捕获 overlay=才不会捕获前声明）
        var overlay: Overlay? = nil
        overlay = makeOverlay(position: .center, radius: .lg, tag: "Demo4") { container in
            container.backgroundColor = .white
            container.widthAnchor.constraint(equalToConstant: 260).isActive = true

            let emoji = UILabel()
            emoji.text = "💸"
            emoji.font = .systemFont(ofSize: 28)
            emoji.textAlignment = .center

            let title = UILabel()
            title.text = "已保存 3 条记账"
            title.font = .boldSystemFont(ofSize: 16)
            title.textAlignment = .center

            let sub = UILabel()
            sub.text = "总支出 ¥ 328.00"
            sub.font = .systemFont(ofSize: 13)
            sub.textColor = UIColor(red: 0x6B/255, green: 0x72/255, blue: 0x80/255, alpha: 1)
            sub.textAlignment = .center

            let done = self.makeDialogButton(title: "好的", primary: true) { [weak overlay, weak self] in
                _ = self // 显式 capture self=避免编译器警告；闭包捕获语义显式化
                overlay?.visible = false
            }

            let stack = UIStackView(arrangedSubviews: [emoji, title, sub, done])
            stack.axis = .vertical
            stack.spacing = 12
            stack.alignment = .fill
            stack.isLayoutMarginsRelativeArrangement = true
            stack.layoutMargins = .init(top: 24, left: 20, bottom: 20, right: 20)
            container.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            done.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
        }
        feedbackLabel.text = "[Demo4] 已保存 3 条记账（center + 4 圆角 radius=lg）：fade-in 动画 200ms"
        overlay?.visible = true
    }

    // ============== 私有：按钮/选项行 工厂 ==============

    private func buildDemoButton(title: String, onTap: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0x16/255, green: 0xA3/255, blue: 0x4A/255, alpha: 1)
        b.layer.cornerRadius = 10
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.addAction(UIAction { _ in onTap() }, for: .touchUpInside)
        return b
    }

    private func makeDialogButton(title: String, primary: Bool, onTap: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(primary ? .white : UIColor(red: 0x11/255, green: 0x18/255, blue: 0x27/255, alpha: 1), for: .normal)
        b.backgroundColor = primary ? UIColor(red: 0x16/255, green: 0xA3/255, blue: 0x4A/255, alpha: 1)
            : UIColor(red: 0xE5/255, green: 0xE7/255, blue: 0xEB/255, alpha: 1)
        b.layer.cornerRadius = 10
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.addAction(UIAction { _ in onTap() }, for: .touchUpInside)
        return b
    }

    private func makeOptionRow(title: String, onTap: @escaping () -> Void) -> UIView {
        let b = UIButton(type: .system)
        b.contentHorizontalAlignment = .left
        b.setTitle(title, for: .normal)
        b.setTitleColor(UIColor(red: 0x11/255, green: 0x18/255, blue: 0x27/255, alpha: 1), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        b.addAction(UIAction { _ in onTap() }, for: .touchUpInside)
        return b
    }
}

// MARK: - Divider 分割线 Showcase

final class DividerShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Divider 分割线"
        addVersionBadge(componentName: "Divider", version: "v1.0", builtAt: "")

        addInfo("4 组排查：① 基础分割线 ② 虚线+粗线 ③ 带文本分割线 ④ 垂直分割线。双端 1:1 对齐。")

        // ── Demo 1：基础分割线 ──
        addSection(title: "Demo 1 · 基础分割线") { container in
            let topLabel = self.makeContentBlock("上方内容")
            container.addSubview(topLabel)
            topLabel.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }

            let divider = Divider()
            container.addSubview(divider)
            divider.snp.makeConstraints { make in
                make.top.equalTo(topLabel.snp.bottom)
                make.leading.trailing.equalToSuperview()
            }

            let bottomLabel = self.makeContentBlock("下方内容")
            container.addSubview(bottomLabel)
            bottomLabel.snp.makeConstraints { make in
                make.top.equalTo(divider.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        addInfo("默认 hairline（0.5px 细线），实线，无文本。")

        // ── Demo 2：虚线 + 粗线 ──
        addSection(title: "Demo 2 · 虚线 + 粗线") { container in
            let dashedLabel = UILabel()
            dashedLabel.text = "虚线（dashed=true）"
            dashedLabel.font = .systemFont(ofSize: AppFont.sizeXs)
            dashedLabel.textColor = AppColor.textSecondary
            container.addSubview(dashedLabel)
            dashedLabel.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }

            let dashedDivider = Divider()
            dashedDivider.dashed = true
            container.addSubview(dashedDivider)
            dashedDivider.snp.makeConstraints { make in
                make.top.equalTo(dashedLabel.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview()
            }

            let thickLabel = UILabel()
            thickLabel.text = "粗线（hairline=false）"
            thickLabel.font = .systemFont(ofSize: AppFont.sizeXs)
            thickLabel.textColor = AppColor.textSecondary
            container.addSubview(thickLabel)
            thickLabel.snp.makeConstraints { make in
                make.top.equalTo(dashedDivider.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview()
            }

            let thickDivider = Divider()
            thickDivider.hairline = false
            container.addSubview(thickDivider)
            thickDivider.snp.makeConstraints { make in
                make.top.equalTo(thickLabel.snp.bottom).offset(4)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        addInfo("上：虚线（dashed=true）。下：粗线（hairline=false，1pt）。")

        // ── Demo 3：带文本分割线 ──
        addSection(title: "Demo 3 · 带文本分割线") { container in
            let leftDivider = Divider()
            leftDivider.text = "左侧文本"
            leftDivider.contentPosition = .left
            container.addSubview(leftDivider)
            leftDivider.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }

            let centerDivider = Divider()
            centerDivider.text = "居中"
            centerDivider.contentPosition = .center
            container.addSubview(centerDivider)
            centerDivider.snp.makeConstraints { make in
                make.top.equalTo(leftDivider.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview()
            }

            let rightDivider = Divider()
            rightDivider.text = "右侧"
            rightDivider.contentPosition = .right
            container.addSubview(rightDivider)
            rightDivider.snp.makeConstraints { make in
                make.top.equalTo(centerDivider.snp.bottom).offset(12)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        addInfo("上→下：contentPosition = left / center / right。")

        // ── Demo 4：垂直分割线 ──
        addSection(title: "Demo 4 · 垂直分割线") { container in
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 0
            container.addSubview(row)
            row.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(40)
                make.bottom.equalToSuperview()
            }

            let labels = ["操作A", "操作B", "操作C"]
            for (i, text) in labels.enumerated() {
                let label = UILabel()
                label.text = text
                label.font = .systemFont(ofSize: AppFont.sizeSm)
                label.textColor = AppColor.textPrimary
                row.addArrangedSubview(label)

                if i < labels.count - 1 {
                    let vDivider = Divider()
                    vDivider.direction = .vertical
                    row.addArrangedSubview(vDivider)
                    vDivider.snp.makeConstraints { make in
                        make.width.equalTo(AppSpace.sm * 2)
                        make.height.equalTo(20)
                    }
                }
            }
        }
        addInfo("行内垂直分隔，用于文字/按钮之间。")
    }

    private func makeContentBlock(_ text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = AppColor.gray4
        view.layer.cornerRadius = 6
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
        return view
    }
}

// MARK: - SafeArea Showcase（SafeArea 安全区 Demo 页，布局组件）

/// SafeArea 安全区：内容避让系统安全区（刘海/状态栏/圆角/Home Indicator/手势区）的容器。
/// 语义：内容自动贴安全区四边排布；edges 可裁剪避让边（默认全边）。
/// 说明：本 demo 容器位于导航页中部（上下无系统栏压力），运行时安全区值=0，视觉等同普通容器；
/// 接入页面边缘（沉浸式 header/底部操作条/横屏）时自动生效，见各段标注与 Android demo 对照。
final class SafeAreaShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "SafeArea", version: "v1.0.3", builtAt: "2026-09-05")

        addSection(title: "D1 · SafeAreaView 真实组件（默认全边避让）") { container in
            container.backgroundColor = AppColor.gray4
            container.layer.cornerRadius = AppRadius.md
            container.clipsToBounds = true

            let safe = SafeAreaView()
            container.addSubview(safe)
            safe.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(AppSpace.md)
            }

            let inner = UIView()
            inner.backgroundColor = AppColor.bgCard
            safe.addContent(inner)

            let label = UILabel()
            label.text = "内容在 SafeAreaView 容器内\n（四边自动贴系统安全区）"
            label.font = .systemFont(ofSize: AppFont.sizeXs)
            label.textColor = AppColor.textPrimary
            label.numberOfLines = 0
            label.textAlignment = .center
            inner.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(AppSpace.lg)
            }
        }
        addInfo("页面中部运行时安全区=0（视觉等同普通容器）；接入页面边缘时自动避开状态栏/刘海/Home Indicator/圆角。")

        addSection(title: "D2 · 顶部避让语义对照（示意：模拟系统带）") { container in
            let systemBar = Self.simulatedBar(text: "系统区（状态栏/刘海，示意）")
            container.addSubview(systemBar)
            systemBar.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(28)
            }

            let bad = Self.stripCard(text: "✗ 无 SafeArea：内容紧贴系统区，刘海机型会压字", color: .systemRed.withAlphaComponent(0.06))
            container.addSubview(bad)
            bad.snp.makeConstraints { make in
                make.top.equalTo(systemBar.snp.bottom).offset(AppSpace.sm)
                make.leading.trailing.equalToSuperview()
            }

            let good = Self.stripCard(text: "✓ 内容在 SafeArea 内：从安全区下开始，不压系统区", color: AppColor.primaryMuted)
            container.addSubview(good)
            good.snp.makeConstraints { make in
                make.top.equalTo(bad.snp.bottom).offset(AppSpace.sm)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        addInfo("避让数值取系统实时 insets（零硬编码），真机/不同机型自动适配。")

        addSection(title: "D3 · 沉浸式页面四边避让（示意）") { container in
            let screen = UIView()
            screen.backgroundColor = AppColor.bgCard
            screen.layer.cornerRadius = AppRadius.lg
            screen.layer.borderWidth = 0.5
            screen.layer.borderColor = AppColor.gray4.cgColor
            container.addSubview(screen)
            screen.snp.makeConstraints { make in make.edges.equalToSuperview() }

            let head = UIView()
            head.backgroundColor = AppColor.primary
            head.layer.cornerRadius = AppRadius.lg
            screen.addSubview(head)
            head.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(64)
            }
            let headLabel = Self.pill("沉浸 header（全屏出血，颜色自绘到屏幕边缘）")
            head.addSubview(headLabel)
            headLabel.snp.makeConstraints { make in make.center.equalToSuperview() }

            let safe = SafeAreaView(edges: [.top, .bottom, .left, .right])
            screen.addSubview(safe)
            safe.snp.makeConstraints { make in
                make.top.equalTo(head.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
            let body = Self.stripCard(text: "页面内容在 SafeArea 内：避开刘海/Home Indicator/圆角后正常排版", color: AppColor.primaryMuted)
            safe.addContent(body)
        }
        addInfo("沉浸式页面：颜色层延伸到屏幕边缘，内容层套 SafeArea 保证文字不压系统区。")

        addSection(title: "D4 · edges 边裁剪（仅避顶 / 仅避底）") { container in
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = AppSpace.md
            row.distribution = .fillEqually
            container.addSubview(row)
            row.snp.makeConstraints { make in make.edges.equalToSuperview() }

            row.addArrangedSubview(Self.edgeCard(title: "仅避 top", detail: "顶部自绘背景出血、文字避让；底部内容贴边", edges: [.top]))
            row.addArrangedSubview(Self.edgeCard(title: "仅避 bottom", detail: "底部自绘 tab 背景贴边，内容上移避开手势区", edges: [.bottom]))
        }
        addInfo("edges 裁剪入口：默认四边全避，沉浸式页面按需只避单边。")
    }

    // MARK: helpers

    private static func simulatedBar(text: String) -> UIView {
        let bar = UIView()
        bar.backgroundColor = AppColor.gray4
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        bar.addSubview(label)
        label.snp.makeConstraints { make in make.center.equalToSuperview() }
        return bar
    }

    private static func stripCard(text: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = color
        card.layer.cornerRadius = AppRadius.sm
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textPrimary
        label.numberOfLines = 0
        card.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: AppSpace.md, left: AppSpace.md, bottom: AppSpace.md, right: AppSpace.md))
        }
        return card
    }

    private static func pill(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func edgeCard(title: String, detail: String, edges: SafeAreaView.Edge) -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.bgCard
        card.layer.cornerRadius = AppRadius.md
        card.layer.borderWidth = 0.5
        card.layer.borderColor = AppColor.gray4.cgColor

        let safe = SafeAreaView(edges: edges)
        card.addSubview(safe)
        safe.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        let t = UILabel()
        t.text = title
        t.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        t.textColor = AppColor.textPrimary
        let d = UILabel()
        d.text = detail
        d.font = .systemFont(ofSize: AppFont.sizeXs)
        d.textColor = AppColor.textSecondary
        d.numberOfLines = 0
        safe.addContent(UIView()) // 仅占位；说明文案放 card 直接加
        card.addSubview(t)
        t.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview().inset(AppSpace.md) }
        card.addSubview(d)
        d.snp.makeConstraints { make in
            make.top.equalTo(t.snp.bottom).offset(AppSpace.xs)
            make.leading.trailing.bottom.equalToSuperview().inset(AppSpace.md)
        }
        return card
    }
}

// MARK: - Sticky Showcase（Sticky 粘性布局 Demo 页，布局组件）

/// Sticky 粘性布局：把一行内容在父滚动容器滚动时固定在可视区顶部（对标 Web position:sticky / Android LazyColumn stickyHeader）。
/// 4 段排查：D1 分组列表标题吸顶 / D2 筛选条吸顶 / D3 offset 让位（固定 AppBar 下）/ D4 吸顶行内容任意可交互。
/// 双端 1:1：iOS StickyView（通用滚动 pinned 方案）vs Android LazyColumn stickyHeader。
final class StickyShowcase: ShowcaseViewController {

    /// 页面顶部常驻反馈条（D4 导出按钮点击就地反馈）。
    private var feedbackLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Sticky", version: "v1.0", builtAt: "2026-09-04")
        feedbackLabel = addFeedbackBar()
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · 分组列表标题吸顶（真实 StickyView：组标题随滚动依次吸顶/顶替）
    private func buildDemo1() {
        addSection(title: "D1 · 分组列表标题吸顶（真实组件，多组标题依次顶替）") { container in
            let sticky = Self.makeStickyHost(container: container, height: 260)
            sticky.addStickyHeader(Self.groupBar("今天", trailing: "共 3 笔 · ¥126"), height: 34)
            sticky.addRow(Self.billRow(category: "餐饮", amount: "-¥32"), height: 40)
            sticky.addRow(Self.billRow(category: "交通", amount: "-¥18"), height: 40)
            sticky.addRow(Self.billRow(category: "购物", amount: "-¥76"), height: 40)
            sticky.addStickyHeader(Self.groupBar("昨天", trailing: "共 2 笔 · ¥94"), height: 34)
            sticky.addRow(Self.billRow(category: "餐饮", amount: "-¥58"), height: 40)
            sticky.addRow(Self.billRow(category: "娱乐", amount: "-¥36"), height: 40)
            sticky.addStickyHeader(Self.groupBar("本周更早", trailing: "共 5 笔 · ¥420"), height: 34)
            sticky.addRow(Self.billRow(category: "房租", amount: "-¥300"), height: 40)
            sticky.addRow(Self.billRow(category: "日用", amount: "-¥120"), height: 40)
        }
        addInfo("滚动观察：「今天」吸顶 → 滚过「昨天」边界被顶替 → 「本周更早」再顶替；回滚依次恢复随流排布。")
    }

    // D2 · 筛选条吸顶（通用滚动容器路径：内容从吸顶条下穿过）
    private func buildDemo2() {
        addSection(title: "D2 · 筛选条吸顶（内容行从吸顶条下方穿过）") { container in
            let sticky = Self.makeStickyHost(container: container, height: 240)
            sticky.addStickyHeader(Self.filterBar(), height: 34)
            sticky.addRow(Self.dateRow(date: "09-01", desc: "餐饮", amount: "-¥32"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-02", desc: "工资", amount: "+¥12,000"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-03", desc: "交通", amount: "-¥18"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-04", desc: "购物", amount: "-¥76"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-05", desc: "娱乐", amount: "-¥120"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-06", desc: "日用", amount: "-¥45"), height: 40)
        }
        addInfo("滚动观察：筛选条滚到容器顶即钉住，列表行从条下方穿过（遮挡区在条下，行为正确）。")
    }

    // D3 · offset 让位：吸顶条停于固定 AppBar 下方（让位语义 = 滚动区置于 AppBar 之下，双端一致）
    private func buildDemo3() {
        addSection(title: "D3 · offset 让位（吸顶条停固定 AppBar 下方，不遮挡）") { container in
            let appBar = UIView()
            appBar.backgroundColor = AppColor.gray4
            appBar.layer.cornerRadius = AppRadius.sm
            container.addSubview(appBar)
            appBar.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(34)
            }
            let label = UILabel()
            label.text = "固定 AppBar（高 34）"
            label.font = .systemFont(ofSize: AppFont.sizeXs)
            label.textColor = AppColor.textSecondary
            label.textAlignment = .center
            appBar.addSubview(label)
            label.snp.makeConstraints { make in make.center.equalToSuperview() }

            // 滚动区置于 AppBar 之下：吸顶钉线 = 滚动区顶部 = AppBar 下沿（offset 让位达成）
            let sticky = StickyView()
            container.addSubview(sticky)
            sticky.snp.makeConstraints { make in
                make.top.equalTo(appBar.snp.bottom).offset(AppSpace.sm)
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(196)
            }
            sticky.addStickyHeader(Self.groupBar("吸顶标题", trailing: "offset 让位，停 AppBar 下方"), height: 34)
            sticky.addRow(Self.dateRow(date: "09-04", desc: "餐饮", amount: "-¥32"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-04", desc: "购物", amount: "-¥76"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-03", desc: "交通", amount: "-¥18"), height: 40)
            sticky.addRow(Self.dateRow(date: "09-02", desc: "娱乐", amount: "-¥120"), height: 40)
        }
        addInfo("滚动观察：吸顶标题停 AppBar 下方（AppBar 恒在、不遮挡）；iOS offset 参数可设钉线下移量（本 demo 以容器排布表达让位，与 Android 一致）。")
    }

    // D4 · 吸顶行内容任意：icon+文字+右侧按钮，滚动中整行吸顶且按钮可点
    private func buildDemo4() {
        addSection(title: "D4 · 吸顶行内容任意（icon+文字+右侧按钮，吸顶中可交互）") { container in
            let sticky = Self.makeStickyHost(container: container, height: 260)
            sticky.addStickyHeader(Self.makeSummaryHeader(target: self, action: #selector(exportTapped)), height: 44)
            sticky.addRow(Self.billRow(category: "收入", amount: "+¥18,240"), height: 40)
            sticky.addRow(Self.billRow(category: "支出", amount: "-¥7,960"), height: 40)
            sticky.addRow(Self.billRow(category: "结余", amount: "+¥10,280"), height: 40)
            sticky.addRow(Self.billRow(category: "笔数", amount: "共 26 笔"), height: 40)
            sticky.addRow(Self.billRow(category: "餐饮占比", amount: "32%"), height: 40)
            sticky.addRow(Self.billRow(category: "交通占比", amount: "18%"), height: 40)
        }
        addInfo("滚动观察：汇总条（含可点按钮）吸顶后整行可见可点——Sticky 只是行为容器，内容任意编排。")
    }

    @objc private func exportTapped() {
        feedbackLabel?.text = "已点击「导出」按钮（吸顶态下仍可交互）"
    }

    // MARK: helpers

    /// 在 section 容器中放置固定高 StickyView，返回供内容添加。
    private static func makeStickyHost(container: UIView, height: CGFloat) -> StickyView {
        let sticky = StickyView(rowSpacing: AppSpace.sm)
        container.addSubview(sticky)
        sticky.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(height)
        }
        return sticky
    }

    /// 分组标题条（primaryMuted 底圆角色块）：标题左、计数右。
    private static func groupBar(_ title: String, trailing: String) -> UIView {
        let bar = UIView()
        bar.backgroundColor = AppColor.primaryMuted
        bar.layer.cornerRadius = AppRadius.sm
        let l = UILabel()
        l.text = title
        l.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        l.textColor = AppColor.primary
        bar.addSubview(l)
        l.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.md)
            make.centerY.equalToSuperview()
        }
        let t = UILabel()
        t.text = trailing
        t.font = .systemFont(ofSize: AppFont.sizeXs)
        t.textColor = AppColor.textSecondary
        bar.addSubview(t)
        t.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-AppSpace.md)
            make.centerY.equalToSuperview()
        }
        return bar
    }

    /// 筛选条（吸顶内容 = 文本筛选项行）。
    private static func filterBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = AppColor.primaryMuted
        bar.layer.cornerRadius = AppRadius.sm
        let l = UILabel()
        l.text = "筛选：全部 ｜ 收入 ｜ 支出"
        l.font = .systemFont(ofSize: AppFont.sizeSm, weight: .medium)
        l.textColor = AppColor.primaryPressed
        bar.addSubview(l)
        l.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.md)
            make.centerY.equalToSuperview()
        }
        return bar
    }

    /// 白底圆角账目行：分类左、金额右。
    private static func billRow(category: String, amount: String) -> UIView {
        let row = UIView()
        row.backgroundColor = AppColor.bgCard
        row.layer.cornerRadius = AppRadius.sm
        let l = UILabel()
        l.text = category
        l.font = .systemFont(ofSize: AppFont.sizeXs)
        l.textColor = AppColor.textSecondary
        row.addSubview(l)
        l.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.md)
            make.centerY.equalToSuperview()
        }
        let a = UILabel()
        a.text = amount
        a.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        a.textColor = AppColor.textPrimary
        row.addSubview(a)
        a.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-AppSpace.md)
            make.centerY.equalToSuperview()
        }
        return row
    }

    /// 白底流水行：日期左、摘要中、金额右。
    private static func dateRow(date: String, desc: String, amount: String) -> UIView {
        let row = UIView()
        row.backgroundColor = AppColor.bgCard
        row.layer.cornerRadius = AppRadius.sm
        let d = UILabel()
        d.text = date
        d.font = .systemFont(ofSize: AppFont.sizeXs)
        d.textColor = AppColor.textSecondary
        row.addSubview(d)
        d.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.md)
            make.centerY.equalToSuperview()
        }
        let m = UILabel()
        m.text = desc
        m.font = .systemFont(ofSize: AppFont.sizeXs)
        m.textColor = AppColor.textPrimary
        row.addSubview(m)
        m.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        let a = UILabel()
        a.text = amount
        a.font = .systemFont(ofSize: AppFont.sizeXs, weight: .medium)
        a.textColor = AppColor.textPrimary
        row.addSubview(a)
        a.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-AppSpace.md)
            make.centerY.equalToSuperview()
        }
        return row
    }

    /// D4 汇总吸顶条：icon 容器(26pt 圆角 primary 白图标) + 标题 + 右侧「导出」胶囊按钮。
    private static func makeSummaryHeader(target: Any, action: Selector) -> UIView {
        let bar = UIView()
        bar.backgroundColor = AppColor.bgCard
        bar.layer.cornerRadius = AppRadius.sm

        let iconWrap = UIView()
        iconWrap.backgroundColor = AppColor.primary
        iconWrap.layer.cornerRadius = 6
        bar.addSubview(iconWrap)
        iconWrap.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        let icon = AppIcon.make(.list, size: 16, color: .white)
        iconWrap.addSubview(icon)
        icon.snp.makeConstraints { make in make.center.equalToSuperview() }

        let l = UILabel()
        l.text = "本月账单汇总"
        l.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        l.textColor = AppColor.textPrimary
        bar.addSubview(l)
        l.snp.makeConstraints { make in
            make.leading.equalTo(iconWrap.snp.trailing).offset(AppSpace.sm)
            make.centerY.equalToSuperview()
        }

        let btn = UIButton(type: .system)
        btn.setTitle("导出", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColor.primary
        btn.layer.cornerRadius = 13 // 胶囊：按钮高 26 的一半
        btn.addTarget(target, action: action, for: .touchUpInside)
        bar.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-AppSpace.md)
            make.centerY.equalToSuperview()
            make.height.equalTo(26)
            make.width.equalTo(56)
        }
        return bar
    }
}

// MARK: - BackTop Showcase（BackTop 返回顶部 Demo 页，导航组件 #1）

/// BackTop 返回顶部：长滚动内容右下角"回到顶部"浮层入口，滚动超阈值出现、点击回顶。
/// 4 段排查：D1 默认样式超阈值出现/点击回顶 / D2 自定义内容 / D3 点击回调 / D4 位置宿主摆放+阈值可配。
/// 双端 1:1：iOS BackTopButton（KVO 监听 target.contentOffset）vs Android BackTop（scrollState）。
final class BackTopShowcase: ShowcaseViewController {

    private var d3Feedback: UILabel?
    private var tapCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "BackTop", version: "v1.0", builtAt: "2026-09-04")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · 默认样式：30 行长内容，滚动超阈值（120）右下淡入 ↑ 圆钮，点击回顶
    private func buildDemo1() {
        addSection(title: "D1 · 默认样式（滚动超阈值 120 出现 ↑ 圆钮，点击回顶）") { container in
            let scroll = makeScroller(container: container, height: 240, rows: 30)
            let backtop = BackTopButton(target: scroll, appearAfter: 120)
            container.addSubview(backtop)
            backtop.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
                make.width.height.equalTo(40)
            }
        }
        addInfo("向下滚动列表，右下出现主色 ↑ 按钮；点击回到顶部后按钮淡出。")
    }

    // D2 · 自定义内容：文字胶囊"回顶"
    private func buildDemo2() {
        addSection(title: "D2 · 自定义内容（setFace 文字胶囊，行为不变）") { container in
            let scroll = makeScroller(container: container, height: 200, rows: 16)
            let backtop = BackTopButton(target: scroll, appearAfter: 40)
            let face = Self.makeCapsuleFace(title: "回顶")
            backtop.setFace(face)
            container.addSubview(backtop)
            backtop.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
                make.width.equalTo(72)
                make.height.equalTo(30)
            }
        }
        addInfo("setFace 替换默认 ↑ 圆钮为文字胶囊（点击行为保留）。")
    }

    // D3 · 点击回调：onTap 接管默认回顶（点击只计数、不回顶），反馈回显在段内下方
    private func buildDemo3() {
        addSection(title: "D3 · 点击回调（接管回顶，记录点击次数）") { container in
            let scroll = makeScroller(container: container, height: 200, rows: 16)
            let backtop = BackTopButton(target: scroll, appearAfter: 40) { [weak self] in
                guard let self else { return }
                self.tapCount += 1
                let count = self.tapCount
                self.d3Feedback?.text = "BackTop 已点击 \(count) 次（onTap 接管默认回顶：点击不会自动回顶，与 Android Demo3 同语义）"
                self.d3Feedback?.textColor = AppColor.primary
            }
            container.addSubview(backtop)
            backtop.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
                make.width.height.equalTo(40)
            }
        }
        d3Feedback = addDynamicInfo("向下滚动出现 ↑ 按钮后点击：计数回显在本行。onTap 接管默认回顶 = 不回顶（与 Android 一致）；要默认回顶请不传 onTap（见 D1/D4）。")
    }

    // D4 · 位置由宿主摆放（左下角）+ 阈值 40
    private func buildDemo4() {
        addSection(title: "D4 · 位置宿主摆放（左下）+ 阈值 40（滚动即现）") { container in
            let scroll = makeScroller(container: container, height: 200, rows: 12)
            let backtop = BackTopButton(target: scroll, appearAfter: 40)
            container.addSubview(backtop)
            backtop.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
                make.width.height.equalTo(40)
            }
        }
        addInfo("位置（右下/左下）是宿主责任，组件不代管布局上下文；阈值作为参数可配。")
    }

    /// 胶囊文字 face（setFace 用）
    private static func makeCapsuleFace(title: String) -> UIView {
        let face = UIView()
        face.backgroundColor = AppColor.primaryPressed
        face.layer.cornerRadius = 15
        face.clipsToBounds = true
        let l = UILabel()
        l.text = title
        l.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        l.textColor = .white
        face.addSubview(l)
        l.snp.makeConstraints { make in make.center.equalToSuperview() }
        return face
    }

}

/// 4 段排查：D1 楼层分组（自动索引）/ D2 城市字母（自定义 index）/ D3 分组行点击 / D4 长分组高联稳定。
/// 双端 1:1：iOS ElevatorView（UITableView 扁平数据）vs Android Elevator（LazyColumn）。
final class ElevatorShowcase: ShowcaseViewController {

    private var d3Feedback: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Elevator", version: "v1.0", builtAt: "2026-09-05")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · 楼层分组：不传 index=自动取分组 key；点右侧索引跳转 + 滚动联动高亮
    private func buildDemo1() {
        addSection(title: "D1 · 楼层分组（默认自动索引 + 双向联动）") { container in
            let elevator = ElevatorView(floors: [
                ElevatorFloor(key: "1F", items: ["星巴克", "瑞幸咖啡", "喜茶"]),
                ElevatorFloor(key: "2F", items: ["优衣库", "无印良品", "热风"]),
                ElevatorFloor(key: "3F", items: ["华为体验店", "小米之家"]),
                ElevatorFloor(key: "4F", items: ["乐高", "玩具反斗城"]),
                ElevatorFloor(key: "5F", items: ["万达影城"]),
            ])
            container.addSubview(elevator)
            elevator.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(320)
            }
        }
        addInfo("不传 index 自动取分组 key（1F-5F）：点右侧「5F」即跳 5F 分组；上下滚动内容时右侧高亮当前楼层分组。")
    }

    // D2 · 城市字母索引：显式 index（只出现含数据的字母），与 Android Demo2 同数据
    private func buildDemo2() {
        addSection(title: "D2 · 城市字母索引（index 显式自定义）") { container in
            let elevator = ElevatorView(floors: [
                ElevatorFloor(key: "A", items: ["安庆", "安阳", "鞍山"]),
                ElevatorFloor(key: "B", items: ["北京", "包头", "保定"]),
                ElevatorFloor(key: "G", items: ["广州", "桂林"]),
                ElevatorFloor(key: "S", items: ["上海", "深圳"]),
            ], index: ["A", "B", "G", "S"])
            container.addSubview(elevator)
            elevator.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(260)
            }
        }
        addInfo("index 显式传字母数组：右侧只展示含数据的字母（A/B/G/S），点击字母跳对应城市分组。")
    }

    // D3 · 分组行点击：onSelect 回传 (分组, 行, 名称)，反馈回显在段内下方
    private func buildDemo3() {
        addSection(title: "D3 · 分组行点击（onSelect 回调）") { container in
            let elevator = ElevatorView(floors: [
                ElevatorFloor(key: "餐饮", items: ["火锅店", "面馆", "烧烤店"]),
                ElevatorFloor(key: "娱乐", items: ["电影院", "KTV"]),
            ], onSelect: { [weak self] floor, row, name in
                guard let self else { return }
                self.d3Feedback?.text = "已选择：第 \(floor + 1) 组「\(name)」（该组内第 \(row + 1) 行）"
                self.d3Feedback?.textColor = AppColor.primary
            })
            container.addSubview(elevator)
            elevator.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(240)
            }
        }
        d3Feedback = addDynamicInfo("点击分组内的某一行（火锅店/电影院等）：结果回显在本行（与 Android Demo3 一致）。")
    }

    // D4 · 长分组列表（12 组）：滚动时索引高亮连续稳定，无跳变
    private func buildDemo4() {
        addSection(title: "D4 · 长分组列表（12 组月份，滚动高联稳定）") { container in
            let floors = (1...12).map { month in
                ElevatorFloor(key: "\(month)月", items: ["\(month) 月账单样例 · 支出 ¥1,2xx"])
            }
            let elevator = ElevatorView(floors: floors)
            container.addSubview(elevator)
            elevator.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(440)
            }
        }
        addInfo("12 个月份分组连续滚动：右侧索引随可视首分组连续高亮，验证长列表高亮无跳变。")
    }
}

// MARK: - FixedNav Showcase（FixedNav 悬浮导航 Demo 页，导航组件 #3 · #15）

/// 4 段排查：D1 右侧基本（角标+自动收起）/ D2 左侧 type=left / D3 自定义文案（无图标无角标长文本）/
/// D4 多次开合 + 点面板外收起（状态稳定）。双端 1:1（iOS FixedNavView vs Android FixedNav）。
final class FixedNavShowcase: ShowcaseViewController {

    /// D4：容器（tap 手势作用面，仅"面板外点击"触发收起）+ 组件引用 + 反馈行
    private weak var d4Host: UIView?
    private var d4Nav: FixedNavView?
    private var d4Feedback: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "FixedNav", version: "v1.0", builtAt: "2026-09-05")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · 右侧默认：右下胶囊"快速导航"展开面板（首页 num2/订单/购物车 num5/我的），钮文字切"收起导航"；点项自动收起并回显
    private func buildDemo1() {
        addSection(title: "D1 · 右侧默认（右下胶囊「快速导航」，面板含角标，点项自动收起）") { container in
            makeScroller(container: container, height: 230, rows: 18)
            let feedback = addDynamicInfo("点胶囊展开导航，点某项=选中回传并自动收起。")
            let nav = FixedNavView(items: [
                FixedNavItem(key: "home", text: "首页", icon: "⌂", num: 2),
                FixedNavItem(key: "order", text: "订单", icon: "📄"),
                FixedNavItem(key: "cart", text: "购物车", icon: "🛒", num: 5),
                FixedNavItem(key: "mine", text: "我的", icon: "◎"),
            ]) { item in
                feedback.text = "D1 选中：\(item.text)（key=\(item.key)），面板已自动收起"
                feedback.textColor = AppColor.primary
            }
            container.addSubview(nav)
            nav.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
            }
        }
        addInfo("右下角为悬浮钮（“悬浮”由宿主摆放=非滚动覆盖层右下角）；展开面板随钮右缘向上，内容可滚动不影响钮。")
    }

    // D2 · 左侧摆放（type=.left）：左下胶囊"更多工具"，面板向右展开
    private func buildDemo2() {
        addSection(title: "D2 · 左侧摆放（type=.left，左下胶囊「更多工具」，面板向右展开）") { container in
            makeScroller(container: container, height: 200, rows: 14)
            let feedback = addDynamicInfo("胶囊在左下缘；点某项回传并自动收起。")
            let nav = FixedNavView(items: [
                FixedNavItem(key: "export", text: "导出报表", icon: "⤓"),
                FixedNavItem(key: "filter", text: "筛选视图", icon: "≋"),
                FixedNavItem(key: "share", text: "分享", icon: "↗"),
            ], type: .left, unActiveText: "更多工具") { item in
                feedback.text = "D2 选中：\(item.text)（type=left），面板已自动收起"
                feedback.textColor = AppColor.primary
            }
            container.addSubview(nav)
            nav.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
            }
        }
        addInfo("type 只决定钮靠左/右缘与面板展开方向；钮仍由宿主锚左下/右下。")
    }

    // D3 · 无图标无角标：长文本项自适应宽 + 自定义钮文案（"操作"/"收起"）
    private func buildDemo3() {
        addSection(title: "D3 · 无图标无角标（长文本行自适应宽 + 自定义钮文案「操作 / 收起」）") { container in
            makeScroller(container: container, height: 170, rows: 10)
            let feedback = addDynamicInfo("图标位缺省=不显示不占位；点项自动收起。")
            let nav = FixedNavView(items: [
                FixedNavItem(key: "month", text: "切换为月度视图"),
                FixedNavItem(key: "sync", text: "同步至工作台"),
            ], activeText: "收起", unActiveText: "操作") { item in
                feedback.text = "D3 选中：\(item.text)，面板已自动收起"
                feedback.textColor = AppColor.primary
            }
            container.addSubview(nav)
            nav.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
            }
        }
        addInfo("图标位/角标均为可选数据项；缺省时行不预留空位（行宽=文本+内边距）。")
    }

    // D4 · 多次开合 + 点面板外收起：状态机稳定
    private func buildDemo4() {
        addSection(title: "D4 · 多次开合 + 点面板外收起（状态稳定）") { container in
            makeScroller(container: container, height: 190, rows: 12)
            let feedback = addDynamicInfo("连续开合点选；点面板外空白处=收起且不触发选中。")
            let nav = FixedNavView(items: [
                FixedNavItem(key: "home", text: "回首页", icon: "A"),
                FixedNavItem(key: "logout", text: "退出登录", icon: "B"),
            ], activeText: "收起") { item in
                feedback.text = "D4 选中：\(item.text)（自动收起）"
                feedback.textColor = AppColor.primary
            }
            container.addSubview(nav)
            nav.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
            }
            d4Host = container
            d4Nav = nav
            d4Feedback = feedback
            let tap = UITapGestureRecognizer(target: self, action: #selector(d4TapOutside(_:)))
            // 保险项（非根因）：cancelsTouchesInView=false——容器手势只负责"面板外空白"收起，
            // 不得取消钮/面板行按钮的触摸。真根因=D3/D4"钮可见却点不动"是组件 hitTest 兜底缺失
            // （FixedNavView 无 intrinsic、宿主只锚两角→父 bounds 不含钮→触摸下钻被拦），
            // 已在组件层 override hitTest 显式转发命中（见 FixedNavView.swift hitTest）。
            tap.cancelsTouchesInView = false
            container.addGestureRecognizer(tap)
        }
    }

    @objc private func d4TapOutside(_ gesture: UITapGestureRecognizer) {
        guard let host = d4Host, let nav = d4Nav else { return }
        let point = gesture.location(in: nav)
        // 钮/面板命中区由组件自行处理（钮=开合、行=选中），此处只管"面板外空白"
        // 命中查询基于钮/卡片实际 frame，不依赖 nav 容器尺寸（见 FixedNavView.hitTestInteractiveArea）
        if nav.hitTestInteractiveArea(point: point) { return }
        nav.collapse(animated: true)
        d4Feedback?.text = "点击面板外区域 → 已收起（未触发选中）"
        d4Feedback?.textColor = AppColor.textSecondary
    }
}

// MARK: - HoverButton Showcase（HoverButton 悬浮按钮 Demo 页，导航组件 #4 · #16）

/// 4 段排查：D1 icon-only ✚ 圆钮右侧常驻 / D2 icon+text 胶囊左下 / D3 纯文本长内容胶囊 /
/// D4 与 BackTop 同容器共存（常驻动作钮 vs 滚动触发回顶划界）。双端 1:1（iOS HoverButton vs Android HoverButton）。
final class HoverButtonShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "HoverButton", version: "v1.0", builtAt: "2026-09-05")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · icon-only 圆钮（右侧常驻，点击计数）：默认 ✚（icon/text 均缺省）
    private func buildDemo1() {
        addSection(title: "D1 · icon-only 圆钮（右侧常驻，点击计数）") { container in
            makeScroller(container: container, height: 220, rows: 18)
            let feedback = addDynamicInfo("右下常驻 ✚ 圆钮；滚动内容不影响它；点击计数。")
            var count = 0
            let button = HoverButton {
                count += 1
                feedback.text = "D1 点击：✚ 圆钮（icon-only 常驻），累计 \(count) 次"
                feedback.textColor = AppColor.primary
            }
            container.addSubview(button)
            button.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
            }
        }
        addInfo("icon/text 均缺省 = 默认 ✚ 圆钮（直径 40）；按钮常驻、不随滚动显隐，位置由宿主锚定。")
    }

    // D2 · icon+text 胶囊（左下，业务动作"记一笔"）
    private func buildDemo2() {
        addSection(title: "D2 · 图标+文本胶囊（左下「✎ 记一笔」，点击计数）") { container in
            makeScroller(container: container, height: 200, rows: 14)
            let feedback = addDynamicInfo("左下常驻胶囊；icon 与文本间距 8pt；点击计数。")
            var count = 0
            let button = HoverButton(icon: "✎", text: "记一笔") {
                count += 1
                feedback.text = "D2 点击：胶囊（icon ✎ + text 记一笔），累计 \(count) 次"
                feedback.textColor = AppColor.primary
            }
            container.addSubview(button)
            button.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
            }
        }
        addInfo("含 text 时 = 胶囊（高 40、圆角 full、水平内边距 16pt、宽随内容自适应），icon 与文本间距 8pt。")
    }

    // D3 · 纯文本长内容胶囊（icon 缺省不占位）
    private func buildDemo3() {
        addSection(title: "D3 · 纯文本长内容胶囊（右侧「打开工具书」）") { container in
            makeScroller(container: container, height: 200, rows: 12)
            let feedback = addDynamicInfo("icon 缺省仅 text = 纯文本胶囊（无 icon 位占位）；点击计数。")
            var count = 0
            let button = HoverButton(text: "打开工具书") {
                count += 1
                feedback.text = "D3 点击：纯文本胶囊「打开工具书」，累计 \(count) 次"
                feedback.textColor = AppColor.primary
            }
            container.addSubview(button)
            button.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
            }
        }
        addInfo("胶囊宽度 = 文本自然宽 + 双侧 16pt 内边距，长文本自适应（不写死魔法宽）。")
    }

    // D4 · 与 BackTop 共存：HoverButton 常驻（点计数）vs BackTop 滚动超阈值出现（点回顶）
    private func buildDemo4() {
        addSection(title: "D4 · 与 BackTop 共存（常驻动作钮 vs 滚动触发回顶）") { container in
            let scroll = makeScroller(container: container, height: 220, rows: 40)
            let feedback = addDynamicInfo("向下滚动超阈值：BackTop 出现；HoverButton 始终常驻。")
            var count = 0
            let hover = HoverButton(icon: "✚") {
                count += 1
                feedback.text = "D4 点击：HoverButton 常驻计数 \(count) 次（BackTop 不受影响）"
                feedback.textColor = AppColor.primary
            }
            let backtop = BackTopButton(target: scroll, appearAfter: 120)
            container.addSubview(hover)
            container.addSubview(backtop)
            hover.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-(40 + AppSpace.lg))
            }
            backtop.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.lg)
                make.width.height.equalTo(40)
            }
        }
        addInfo("悬浮族划界对照：HoverButton=单钮常驻自定义动作；BackTop=滚动超阈值才出现的回顶钮（行为互相独立）。")
    }
}

// MARK: - SideBar Showcase（SideBar 侧边导航 Demo 页，导航组件 #5 · #18）

/// 4 段排查：D1 基础两栏目录（选中持久高亮 + 切换 + 回调幂等）/ D2 禁用项 + 长标题省略 /
/// D3 长列表滚动 + 内容联动（点选 ↔ 反向驱动）/ D4 受控复位（外部 value 驱动）。
/// 双端 1:1：iOS SideBarView（UIButton 行轨 + UIScrollView）vs Android SideBar（LazyColumn）。
final class SideBarShowcase: ShowcaseViewController, UIScrollViewDelegate {

    // D1/D2 右区信息卡引用
    private var d1Title: UILabel?
    private var d1Subtitle: UILabel?
    private var d1Count = 0
    private var d1Feedback: UILabel?

    private var d2Rail: SideBarView?
    private var d2Title: UILabel?
    private var d2Subtitle: UILabel?
    private var d2SelectedValue = "数据与隐私"
    private var d2Count = 0
    private var d2Feedback: UILabel?

    // D3：月份轨 + 右区滚动容器
    private var d3Rail: SideBarView?
    private var d3Scroll: UIScrollView?
    private var d3Feedback: UILabel?
    private var d3Count = 0
    private let monthValues = (1...12).map { "\($0)月" }
    private let d3SectionHeight: CGFloat = 64

    // D4
    private var d4Rail: SideBarView?
    private var d4Title: UILabel?
    private var d4Subtitle: UILabel?
    private var d4FirstDesc: String?
    private var d4SelectedValue = "全部"
    private var d4Feedback: UILabel?
    private var d4Count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "SideBar", version: "v1.0", builtAt: "2026-09-05")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // MARK: - 共用小工具

    /// 在 rail 右侧铺一张信息卡（白底圆角边框），返回卡片视图
    private func addInfoPane(container: UIView, rail: UIView, height: CGFloat) -> UIView {
        let pane = UIView()
        pane.backgroundColor = AppColor.bgCard
        pane.layer.cornerRadius = AppRadius.md
        pane.layer.borderWidth = 1.0
        pane.layer.borderColor = AppColor.border.cgColor
        container.addSubview(pane)
        pane.snp.makeConstraints { make in
            make.leading.equalTo(rail.snp.trailing).offset(AppSpace.md)
            make.top.bottom.trailing.equalToSuperview()
            make.height.equalTo(height)
        }
        return pane
    }

    /// 信息卡布局：主标题 + 副题两行，返回两个 label 供外部回写
    @discardableResult
    private func layoutPaneLabels(in pane: UIView, title: String, subtitle: String) -> (UILabel, UILabel) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: AppFont.sizeLg, weight: .bold)
        titleLabel.textColor = AppColor.primary
        let subLabel = UILabel()
        subLabel.text = subtitle
        subLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        subLabel.textColor = AppColor.textSecondary
        subLabel.numberOfLines = 0
        pane.addSubview(titleLabel)
        pane.addSubview(subLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(AppSpace.md)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpace.sm)
            make.leading.equalToSuperview().inset(AppSpace.md)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.md)
            make.bottom.lessThanOrEqualToSuperview().offset(-AppSpace.md)
        }
        return (titleLabel, subLabel)
    }

    // MARK: - D1 · 基础两栏目录（账单分类 5 项）

    private func buildDemo1() {
        let data: [(title: String, desc: String)] = [
            ("全部", "收入 ¥1,285.50 · 支出 ¥823.00"),
            ("餐饮", "本月支出 ¥468.20"),
            ("交通", "本月支出 ¥136.80"),
            ("购物", "本月支出 ¥523.00"),
            ("其他", "本月支出 ¥157.50"),
        ]
        addSection(title: "D1 · 基础两栏目录（账单分类 5 项，选中持久高亮 + 切换）") { [weak self] container in
            guard let self else { return }
            let items = data.map { SideBarItem(title: $0.title, value: $0.title) }
            let sideBar = SideBarView(items: items) { [weak self] value in
                guard let self, let entry = data.first(where: { $0.title == value }) else { return }
                self.d1Count += 1
                self.d1Title?.text = "「\(entry.title)」"
                self.d1Subtitle?.text = entry.desc
                self.d1Feedback?.text = "onChange「\(value)」触发：高亮迁移 + 右侧内容切换（第 \(self.d1Count) 次）"
                self.d1Feedback?.textColor = AppColor.primary
            }
            container.addSubview(sideBar)
            sideBar.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalTo(SideBarView.Metrics.railWidth)
            }
            let pane = self.addInfoPane(container: container, rail: sideBar, height: 260)
            let labels = self.layoutPaneLabels(in: pane, title: "「全部」", subtitle: data[0].desc)
            self.d1Title = labels.0
            self.d1Subtitle = labels.1
        }
        d1Feedback = addDynamicInfo("点不同分类=高亮迁移并切换右侧内容；点当前已激活项不重复回调（计数不增）。")
    }

    // MARK: - D2 · 禁用项 + 长标题省略

    private func buildDemo2() {
        let data: [(title: String, desc: String, disabled: Bool)] = [
            ("账户管理", "账户资料与登录信息", false),
            ("数据与隐私", "数据与隐私授权设置", false),
            ("系统设置", "系统偏好与权限设置（禁用项，点击无反应）", true),
            ("消息通知与提醒偏好配置", "长标题项：单行显示、超长右缘省略（…）", false),
            ("关于我们", "版本信息与帮助中心", false),
        ]
        addSection(title: "D2 · 禁用项 + 长标题省略（选中持久高亮）") { [weak self] container in
            guard let self else { return }
            let items = data.map { SideBarItem(title: $0.title, value: $0.title, disabled: $0.disabled) }
            let sideBar = SideBarView(items: items, selectedValue: self.d2SelectedValue) { [weak self] value in
                guard let self, let entry = data.first(where: { $0.title == value }) else { return }
                // 半受控回写：外部赋值 selectedValue 驱动高亮迁移（同 Android d2Sel 回写语义）
                self.d2SelectedValue = value
                self.d2Rail?.selectedValue = value
                self.d2Count += 1
                self.d2Title?.text = "「\(entry.title)」"
                self.d2Subtitle?.text = entry.desc
                self.d2Feedback?.text = "onChange「\(value)」触发（第 \(self.d2Count) 次）：\(entry.desc)"
                self.d2Feedback?.textColor = AppColor.primary
            }
            self.d2Rail = sideBar
            container.addSubview(sideBar)
            sideBar.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalTo(SideBarView.Metrics.railWidth)
            }
            let pane = self.addInfoPane(container: container, rail: sideBar, height: 300)
            let labels = self.layoutPaneLabels(in: pane, title: "「数据与隐私」", subtitle: data[1].desc)
            self.d2Title = labels.0
            self.d2Subtitle = labels.1
        }
        d2Feedback = addDynamicInfo("点击可用项=高亮迁移并联动右侧说明；点击禁用项「系统设置」无反应不触发 onChange；「消息通知与提醒偏好配置」长标题单行省略（右侧 …）。")
    }

    // MARK: - D3 · 长列表滚动 + 内容联动（点选 ↔ 反向驱动）

    private func buildDemo3() {
        addSection(title: "D3 · 长列表滚动 + 内容联动（12 个月，点选 ↔ 反向驱动）") { [weak self] container in
            guard let self else { return }
            let sideBar = SideBarView(
                items: self.monthValues.map { SideBarItem(title: $0, value: $0) },
                selectedValue: "1月"
            ) { [weak self] value in
                guard let self else { return }
                self.d3Count += 1
                self.d3Feedback?.text = "onChange「\(value)」：右区滚动定位到 \(value) 分段（第 \(self.d3Count) 次）"
                self.d3Feedback?.textColor = AppColor.primary
                if let idx = self.monthValues.firstIndex(of: value) {
                    let y = CGFloat(idx) * self.d3SectionHeight
                    self.d3Scroll?.setContentOffset(CGPoint(x: 0, y: y), animated: true)
                }
            }
            container.addSubview(sideBar)
            sideBar.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalTo(SideBarView.Metrics.railWidth)
            }
            self.d3Rail = sideBar

            // 右区滚动容器：12 个月分段（每段 64pt）
            let scroll = UIScrollView()
            scroll.delegate = self
            scroll.backgroundColor = AppColor.bgCard
            scroll.layer.cornerRadius = AppRadius.md
            scroll.layer.borderWidth = 1.0
            scroll.layer.borderColor = AppColor.border.cgColor
            scroll.showsVerticalScrollIndicator = false
            container.addSubview(scroll)
            scroll.snp.makeConstraints { make in
                make.leading.equalTo(sideBar.snp.trailing).offset(AppSpace.md)
                make.top.bottom.trailing.equalToSuperview()
                make.height.equalTo(300)
            }
            self.d3Scroll = scroll

            let content = UIView()
            scroll.addSubview(content)
            content.snp.makeConstraints { make in
                make.top.leading.trailing.equalTo(scroll.contentLayoutGuide)
                make.bottom.equalTo(scroll.contentLayoutGuide.snp.bottom)
                make.width.equalTo(scroll.frameLayoutGuide)
            }
            var prev: UIView?
            for (index, month) in self.monthValues.enumerated() {
                let block = UIView()
                content.addSubview(block)
                block.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(self.d3SectionHeight)
                    make.top.equalTo(prev?.snp.bottom ?? content.snp.top)
                }
                let title = UILabel()
                title.text = "\(month) 账单"
                title.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
                title.textColor = AppColor.textPrimary
                let desc = UILabel()
                desc.text = "\(month) 账单明细样例 · 支出 ¥1,2xx（第 \(index + 1) 段）"
                desc.font = .systemFont(ofSize: AppFont.sizeXs)
                desc.textColor = AppColor.textSecondary
                block.addSubview(title)
                block.addSubview(desc)
                title.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(AppSpace.sm)
                    make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
                }
                desc.snp.makeConstraints { make in
                    make.top.equalTo(title.snp.bottom).offset(AppSpace.xs)
                    make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
                }
                prev = block
            }
        }
        d3Feedback = addDynamicInfo("点击月份=右侧内容滚动定位；上下拖动右侧内容时轨高亮反向跟随（受控语义，轨选中自动滚入可视）。")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === d3Scroll else { return }
        let y = max(0, scrollView.contentOffset.y)
        let idx = min(max(Int((y / d3SectionHeight).rounded()), 0), monthValues.count - 1)
        let month = monthValues[idx]
        d3Rail?.selectedValue = month
        if scrollView.isDragging || scrollView.isDecelerating {
            d3Feedback?.text = "右侧滚动 → 轨高亮「\(month)」（反向驱动轨选中态）"
            d3Feedback?.textColor = AppColor.textSecondary
        }
    }

    // MARK: - D4 · 受控复位（外部 value 驱动）

    private func buildDemo4() {
        let data: [(title: String, desc: String)] = [
            ("全部", "收入 ¥1,285.50 · 支出 ¥823.00"),
            ("餐饮", "本月支出 ¥468.20"),
            ("交通", "本月支出 ¥136.80"),
            ("购物", "本月支出 ¥523.00"),
            ("其他", "本月支出 ¥157.50"),
        ]
        addSection(title: "D4 · 受控复位（外部 value 驱动，「重置到第一项」）") { [weak self] container in
            guard let self else { return }
            let items = data.map { SideBarItem(title: $0.title, value: $0.title) }
            // 受控模式创建（同 Android d4Sel 全程受控）：外部 selectedValue 驱动高亮，onChange 宿主回写
            let sideBar = SideBarView(items: items, selectedValue: self.d4SelectedValue) { [weak self] value in
                guard let self, let entry = data.first(where: { $0.title == value }) else { return }
                // 半受控回写：外部赋值 selectedValue 驱动高亮迁移（否则受控态点击不迁移=“菜单没法点”）
                self.d4SelectedValue = value
                self.d4Rail?.selectedValue = value
                self.d4Count += 1
                self.d4Title?.text = "「\(entry.title)」"
                self.d4Subtitle?.text = entry.desc
                self.d4Feedback?.text = "onChange「\(value)」触发（第 \(self.d4Count) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            }
            container.addSubview(sideBar)
            sideBar.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalTo(SideBarView.Metrics.railWidth)
            }
            self.d4Rail = sideBar
            let pane = self.addInfoPane(container: container, rail: sideBar, height: 260)
            let labels = self.layoutPaneLabels(in: pane, title: "「全部」", subtitle: data[0].desc)
            self.d4Title = labels.0
            self.d4Subtitle = labels.1
            self.d4FirstDesc = data[0].desc

            let resetButton = UIButton(type: .system)
            resetButton.setTitle("重置到第一项", for: .normal)
            resetButton.setTitleColor(.white, for: .normal)
            resetButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs, weight: .medium)
            resetButton.backgroundColor = AppColor.primary
            resetButton.layer.cornerRadius = 14
            resetButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            resetButton.addTarget(self, action: #selector(d4Reset), for: .touchUpInside)
            pane.addSubview(resetButton)
            resetButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
        }
        d4Feedback = addDynamicInfo("「重置到第一项」= 外部赋值 selectedValue：轨高亮同步 + 选中滚入可视；不触发 onChange（幂等）。")
    }

    @objc private func d4Reset() {
        guard let first = d4Rail?.items.first else { return }
        // 外部赋值受控值 → 高亮同步回第一项（若已为第一项则 didSet 幂等跳过刷新，UI 仍就地更新）
        d4SelectedValue = first.value
        d4Rail?.selectedValue = first.value
        d4Title?.text = "「\(first.title)」"
        d4Subtitle?.text = d4FirstDesc
        d4Feedback?.text = "外部驱动 selectedValue → 第一项「\(first.title)」：高亮已同步（onChange 计数不增，仍为 \(d4Count) 次）"
        d4Feedback?.textColor = AppColor.primary
    }
}

// MARK: - NavBar Showcase（NavBar 头部导航 Demo 页，导航组件 #2 收编 · #17）

/// 4 段排查：D1 基础返回 / D2 一级页无返回（标题严格居中）/ D3 右动作保存 / D4 长标题省略。
/// 双端 1:1：iOS NavBar（UIView）vs Android NavBar（Row）。
final class NavBarShowcase: ShowcaseViewController {
    private var d1Back = 0
    private var d1Feedback: UILabel?
    private var d3Back = 0
    private var d3Save = 0
    private var d3Feedback: UILabel?
    private var d4Back = 0
    private var d4Save = 0
    private var d4Feedback: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "NavBar", version: "v1.0", builtAt: "")
        addInfo("4 段排查：① 返回钮+标题 ② 一级页无返回（标题严格居中） ③ 右侧动作「保存」 ④ 长标题省略。双端 1:1（iOS NavBar vs Android NavBar）。")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func pinBar(_ bar: UIView, in container: UIView) {
        container.addSubview(bar)
        // 四边闭合：容器普通 UIView 无 intrinsic，若只锚 leading/trailing/top 则高度链断裂，
        // 44pt 导航条溢出压到段下方说明文字（与 Divider 首轮 Demo4 文案重叠同根因）。
        bar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 返回钮 + 标题（点击返回计数）") { [weak self] container in
            guard let self else { return }
            let bar = NavBar(title: "账单明细", onBack: { [weak self] in
                guard let self else { return }
                self.d1Back += 1
                self.d1Feedback?.text = "D1 返回点击：累计 \(self.d1Back) 次（返回槽出现在左侧，标题居中）"
                self.d1Feedback?.textColor = AppColor.primary
            })
            self.pinBar(bar, in: container)
        }
        d1Feedback = addDynamicInfo("左侧返回钮热区 44×44pt，← 主色；点击计数。")
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 一级页无返回（onBack=nil，标题严格居中）") { [weak self] container in
            guard let self else { return }
            let bar = NavBar(title: "资产总览")
            self.pinBar(bar, in: container)
        }
        addInfo("onBack=nil 返回槽不占位，标题严格水平居中（无左侧偏移）。")
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 返回 + 右侧动作「保存」（点击计数）") { [weak self] container in
            guard let self else { return }
            let bar = NavBar(
                title: "编辑分类",
                onBack: { [weak self] in
                    guard let self else { return }
                    self.d3Back += 1
                    self.refreshD3()
                },
                rightAction: NavBarAction(text: "保存") { [weak self] in
                    guard let self else { return }
                    self.d3Save += 1
                    self.refreshD3()
                }
            )
            self.pinBar(bar, in: container)
        }
        d3Feedback = addDynamicInfo("右侧动作 = NavBarAction(text, color?, onTap)，文字默认 textPrimary 14pt。")
    }

    private func refreshD3() {
        d3Feedback?.text = "D3 返回 \(d3Back) 次 / 保存 \(d3Save) 次"
        d3Feedback?.textColor = AppColor.primary
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 长标题省略（返回+保存两侧夹挤）") { [weak self] container in
            guard let self else { return }
            let bar = NavBar(
                title: "这是一条特别特别长的标题用来验证单行省略的效果是否正确展示",
                onBack: { [weak self] in
                    guard let self else { return }
                    self.d4Back += 1
                    self.refreshD4()
                },
                rightAction: NavBarAction(text: "保存") { [weak self] in
                    guard let self else { return }
                    self.d4Save += 1
                    self.refreshD4()
                }
            )
            self.pinBar(bar, in: container)
        }
        d4Feedback = addDynamicInfo("标题最多一行，超出以省略号结尾；返回/动作热区不被长标题侵入。D4 返回 0 次 / 保存 0 次。")
    }

    private func refreshD4() {
        d4Feedback?.text = "标题最多一行，超出以省略号结尾；返回/动作热区不被长标题侵入。D4 返回 \(d4Back) 次 / 保存 \(d4Save) 次。"
        d4Feedback?.textColor = AppColor.primary
    }
}

// MARK: - Tabbar Showcase（Tabbar 标签栏 Demo 页，导航组件 #6 · #19）

/// 4 段排查：D1 基础 5 项等分 / D2 角标+禁用 / D3 纯文字+长标题+品牌红 / D4 受控外部驱动。
/// 双端 1:1：iOS TabbarView（UIStackView 等分）vs Android Tabbar（Row weight）。
final class TabbarShowcase: ShowcaseViewController {
    private var d1Value = "home"
    private var d1Tap = 0
    private var d1Feedback: UILabel?
    private var d1Tab: TabbarView?

    private var d2Value = "home"
    private var d2Feedback: UILabel?
    private var d2Tab: TabbarView?

    private var d3Value = "a"
    private var d3Feedback: UILabel?
    private var d3Tab: TabbarView?

    private var d4Value = "chart"
    private var d4Tap = 0
    private var d4Feedback: UILabel?
    private var d4Tab: TabbarView?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Tabbar", version: "v1.0", builtAt: "")
        addInfo("4 段排查：① 基础 5 项等分 ② 角标数字+禁用 ③ 纯文字长标题+品牌红 activeColor ④ 受控外部驱动。双端 1:1（iOS TabbarView vs Android Tabbar）。")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    /// 造一块模拟页面区：高 height、灰底、居中一行状态文案、底栏钉底部。
    private func makePageArea(container: UIView, height: CGFloat) -> (UIView, UILabel) {
        let holder = UIView()
        holder.backgroundColor = AppColor.bgPage
        container.addSubview(holder)
        holder.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(height)
        }
        let state = UILabel()
        state.font = .systemFont(ofSize: AppFont.sizeXs)
        state.textColor = AppColor.textSecondary
        state.numberOfLines = 2
        state.textAlignment = .center
        holder.addSubview(state)
        state.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(AppSpace.md)
        }
        return (holder, state)
    }

    @discardableResult
    private func addButtonsRow(_ block: (UIStackView) -> Void) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = AppSpace.sm
        contentStack.addArrangedSubview(row)
        block(row)
        return row
    }

    private func makeTextButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
        button.setTitleColor(AppColor.primary, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础 5 项等分（点击切换）") { [weak self] container in
            guard let self else { return }
            let (holder, state) = self.makePageArea(container: container, height: 180)
            state.text = "当前页面：home（自管理选中）"
            let tab = TabbarView(
                items: [
                    TabBarItem(title: "首页", value: "home", icon: "⌂"),
                    TabBarItem(title: "明细", value: "list", icon: "▤"),
                    TabBarItem(title: "记账", value: "add", icon: "✚"),
                    TabBarItem(title: "报表", value: "chart", icon: "☰"),
                    TabBarItem(title: "我的", value: "mine", icon: "☺"),
                ],
                selectedValue: self.d1Value,
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.d1Value = value
                    self.d1Tab?.selectedValue = value // 受控回写：组件高亮跟随（等价 Android state 重组）
                    self.d1Tap += 1
                    state.text = "当前页面：\(value)（点击回调 \(self.d1Tap) 次）"
                    state.textColor = AppColor.primary
                    self.d1Feedback?.text = "D1 点击：\(value)（第 \(self.d1Tap) 次切换）"
                    self.d1Feedback?.textColor = AppColor.primary
                }
            )
            self.d1Tab = tab
            holder.addSubview(tab)
            tab.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        d1Feedback = addDynamicInfo("icon 字符 22pt + 文字 12pt，等分 5 项；激活=主色加粗，默认首启用项自管理。")
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 角标数字 + 禁用项") { [weak self] container in
            guard let self else { return }
            let (holder, state) = self.makePageArea(container: container, height: 180)
            state.text = "当前：home（消息角标 3，我的=禁用）"
            let tab = TabbarView(
                items: [
                    TabBarItem(title: "首页", value: "home", icon: "⌂"),
                    TabBarItem(title: "消息", value: "msg", icon: "✉", badge: 3),
                    TabBarItem(title: "报表", value: "chart", icon: "☰"),
                    TabBarItem(title: "我的", value: "mine", icon: "☺", disabled: true),
                ],
                selectedValue: self.d2Value,
                onChange: { [weak self] value in
                    guard let self, value != "mine" else { return }
                    self.d2Value = value
                    self.d2Tab?.selectedValue = value // 受控回写：组件高亮跟随
                    state.text = "当前：\(value)（消息角标 3，我的=禁用）"
                    state.textColor = AppColor.primary
                    self.d2Feedback?.text = "D2 点击：\(value)（禁用项不可点）"
                    self.d2Feedback?.textColor = AppColor.primary
                }
            )
            self.d2Tab = tab
            holder.addSubview(tab)
            tab.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        d2Feedback = addDynamicInfo("角标=高 16pt 圆角主色白字数字（位于图标右上）；禁用项 40% 透明且不可点（点击不回调）。")
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 纯文字 + 长标题省略 + 品牌红 activeColor") { [weak self] container in
            guard let self else { return }
            let (holder, state) = self.makePageArea(container: container, height: 180)
            state.text = "当前：a（品牌红激活色）"
            let tab = TabbarView(
                items: [
                    TabBarItem(title: "全部账单明细全部明细", value: "a"),
                    TabBarItem(title: "进行中", value: "b"),
                    TabBarItem(title: "我的收藏夹", value: "c"),
                ],
                selectedValue: self.d3Value,
                activeColor: UIColor(red: 0.882, green: 0.114, blue: 0.282, alpha: 1),
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.d3Value = value
                    self.d3Tab?.selectedValue = value // 受控回写：组件高亮跟随
                    state.text = "当前：\(value)（品牌红激活色）"
                    state.textColor = AppColor.primary
                    self.d3Feedback?.text = "D3 点击：\(value)"
                    self.d3Feedback?.textColor = AppColor.primary
                }
            )
            self.d3Tab = tab
            holder.addSubview(tab)
            tab.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        d3Feedback = addDynamicInfo("icon 缺省=纯文字项；长标题单行省略；activeColor 覆盖默认主色（此处品牌红）。")
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 受控外部驱动（selectedValue 由外部状态驱动）") { [weak self] container in
            guard let self else { return }
            let (holder, state) = self.makePageArea(container: container, height: 200)
            state.text = "当前：chart（外部驱动，点击回调 0 次）"
            let tab = TabbarView(
                items: [
                    TabBarItem(title: "首页", value: "home", icon: "⌂"),
                    TabBarItem(title: "报表", value: "chart", icon: "☰"),
                    TabBarItem(title: "我的", value: "mine", icon: "☺"),
                ],
                selectedValue: self.d4Value,
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.d4Value = value
                    self.d4Tab?.selectedValue = value // 受控回写：组件高亮跟随
                    self.d4Tap += 1
                    state.text = "当前：\(value)（外部驱动，点击回调 \(self.d4Tap) 次）"
                    state.textColor = AppColor.primary
                    self.d4Feedback?.text = "D4 点击：\(value)（第 \(self.d4Tap) 次）"
                    self.d4Feedback?.textColor = AppColor.primary
                }
            )
            self.d4Tab = tab
            holder.addSubview(tab)
            tab.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        addButtonsRow { row in
            row.addArrangedSubview(self.makeTextButton(title: "外部切到「报表」", action: #selector(self.d4ToChart)))
            row.addArrangedSubview(self.makeTextButton(title: "外部切到「我的」", action: #selector(self.d4ToMine)))
        }
        d4Feedback = addDynamicInfo("半受控语义：外部 selectedValue 优先级高于自管理；点已激活项幂等（不重复回调）。")
    }

    @objc private func d4ToChart() {
        d4Value = "chart"
        d4Tab?.selectedValue = "chart" // 受控回写：外部驱动组件高亮
        d4Feedback?.text = "外部驱动 selectedValue → chart（未触发 onChange，计数仍为 \(d4Tap) 次）"
        d4Feedback?.textColor = AppColor.primary
    }

    @objc private func d4ToMine() {
        d4Value = "mine"
        d4Tab?.selectedValue = "mine" // 受控回写：外部驱动组件高亮
        d4Feedback?.text = "外部驱动 selectedValue → mine（未触发 onChange，计数仍为 \(d4Tap) 次）"
        d4Feedback?.textColor = AppColor.primary
    }
}

// MARK: - Tabs Showcase（Tabs 选项卡 Demo 页，导航组件 #3 收编 · #20）

/// 4 段排查：D1 基础等分+指示线 / D2 禁用 / D3 长标题省略+品牌红 / D4 受控外部驱动。
/// 双端 1:1：iOS TabsView（替换旧收编业务双 Tab）vs Android Tabs（Row weight）。
final class TabsShowcase: ShowcaseViewController {
    private var d1Value = "in"
    private var d1Tap = 0
    private var d1Feedback: UILabel?
    private var d1Tabs: TabsView?

    private var d2Value = "week"
    private var d2Feedback: UILabel?
    private var d2Tabs: TabsView?

    private var d3Value = "a"
    private var d3Feedback: UILabel?
    private var d3Tabs: TabsView?

    private var d4Value = "draft"
    private var d4Tap = 0
    private var d4Feedback: UILabel?
    private var d4Tabs: TabsView?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Tabs", version: "v1.0", builtAt: "")
        addInfo("4 段排查：① 基础等分+指示线 ② 禁用项 ③ 长标题省略+品牌红 activeColor ④ 受控外部驱动。双端 1:1（iOS TabsView vs Android Tabs）。")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    /// 把 TabsView 钉进容器顶部（条宽=容器宽，高走组件 intrinsic 44）。
    private func embedTabs(_ tabs: TabsView, in container: UIView) {
        container.addSubview(tabs)
        tabs.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }

    /// 段内说明行（钉在条下方，与 Android demo 的说明文字 1:1）。
    private func sectionInfo(_ text: String, topTo tabs: UIView, in container: UIView) -> UILabel {
        let info = UILabel()
        info.text = text
        info.font = .systemFont(ofSize: AppFont.sizeXs)
        info.textColor = AppColor.textSecondary
        info.numberOfLines = 0
        container.addSubview(info)
        info.snp.makeConstraints { make in
            make.top.equalTo(tabs.snp.bottom).offset(AppSpace.sm)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return info
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础等分 + 底部指示线") { [weak self] container in
            guard let self else { return }
            let tabs = TabsView(
                items: [
                    TabItem(title: "支出", value: "in"),
                    TabItem(title: "收入", value: "out"),
                    TabItem(title: "转账", value: "transfer"),
                ],
                selectedValue: self.d1Value,
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.d1Value = value
                    self.d1Tabs?.selectedValue = value // 受控回写：组件高亮跟随（等价 Android state 重组）
                    self.d1Tap += 1
                    self.d1Feedback?.text = "当前页签：\(value)（点击回调 \(self.d1Tap) 次）"
                    self.d1Feedback?.textColor = AppColor.primary
                }
            )
            self.d1Tabs = tabs
            self.embedTabs(tabs, in: container)
            self.d1Feedback = self.sectionInfo("当前页签：in（点击回调 0 次）", topTo: tabs, in: container)
        }
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 禁用项（年视图禁用）") { [weak self] container in
            guard let self else { return }
            let tabs = TabsView(
                items: [
                    TabItem(title: "周视图", value: "week"),
                    TabItem(title: "月视图", value: "month"),
                    TabItem(title: "年视图", value: "year", disabled: true),
                ],
                selectedValue: self.d2Value,
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.d2Value = value
                    self.d2Tabs?.selectedValue = value // 受控回写：组件高亮跟随
                    self.d2Feedback?.text = "当前页签：\(value)"
                    self.d2Feedback?.textColor = AppColor.primary
                }
            )
            self.d2Tabs = tabs
            self.embedTabs(tabs, in: container)
            self.d2Feedback = self.sectionInfo("禁用页签 40% 透明且不可点；激活指示线仍在启用的项下方。", topTo: tabs, in: container)
        }
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 长标题省略 + 品牌红 activeColor") { [weak self] container in
            guard let self else { return }
            let tabs = TabsView(
                items: [
                    TabItem(title: "全部账单明细全部账单", value: "a"),
                    TabItem(title: "已完成", value: "b"),
                    TabItem(title: "个人收藏夹", value: "c"),
                ],
                selectedValue: self.d3Value,
                activeColor: UIColor(red: 0.882, green: 0.114, blue: 0.282, alpha: 1),
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.d3Value = value
                    self.d3Tabs?.selectedValue = value // 受控回写：组件高亮跟随
                    self.d3Feedback?.text = "当前页签：\(value)"
                    self.d3Feedback?.textColor = AppColor.primary
                }
            )
            self.d3Tabs = tabs
            self.embedTabs(tabs, in: container)
            self.d3Feedback = self.sectionInfo("标题单行省略；激活项底部 2pt 指示线（宽=当前项整宽）为 activeColor。", topTo: tabs, in: container)
        }
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 受控外部驱动") { [weak self] container in
            guard let self else { return }
            let tabs = TabsView(
                items: [
                    TabItem(title: "草稿", value: "draft"),
                    TabItem(title: "已发布", value: "published"),
                    TabItem(title: "归档", value: "archive"),
                ],
                selectedValue: self.d4Value,
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.d4Value = value
                    self.d4Tabs?.selectedValue = value // 受控回写：组件高亮跟随
                    self.d4Tap += 1
                    self.d4Feedback?.text = "当前页签：\(value)（点击回调累计 \(self.d4Tap) 次）"
                    self.d4Feedback?.textColor = AppColor.primary
                }
            )
            self.d4Tabs = tabs
            self.embedTabs(tabs, in: container)
            self.d4Feedback = self.sectionInfo("外部 selectedValue 优先级高于自管理；点击回调累计 0 次；点已激活项幂等。", topTo: tabs, in: container)
        }
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = AppSpace.sm
        contentStack.addArrangedSubview(row)
        let toDraft = UIButton(type: .system)
        toDraft.setTitle("外部切到「草稿」", for: .normal)
        toDraft.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
        toDraft.setTitleColor(AppColor.primary, for: .normal)
        toDraft.addTarget(self, action: #selector(d4ToDraft), for: .touchUpInside)
        row.addArrangedSubview(toDraft)
        let toPublished = UIButton(type: .system)
        toPublished.setTitle("外部切到「已发布」", for: .normal)
        toPublished.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
        toPublished.setTitleColor(AppColor.primary, for: .normal)
        toPublished.addTarget(self, action: #selector(d4ToPublished), for: .touchUpInside)
        row.addArrangedSubview(toPublished)
    }

    @objc private func d4ToDraft() {
        d4Value = "draft"
        d4Tabs?.selectedValue = "draft" // 受控回写：外部驱动组件高亮
        d4Feedback?.text = "外部驱动 selectedValue → draft（未触发 onChange，计数仍为 \(d4Tap) 次）"
        d4Feedback?.textColor = AppColor.primary
    }

    @objc private func d4ToPublished() {
        d4Value = "published"
        d4Tabs?.selectedValue = "published" // 受控回写：外部驱动组件高亮
        d4Feedback?.text = "外部驱动 selectedValue → published（未触发 onChange，计数仍为 \(d4Tap) 次）"
        d4Feedback?.textColor = AppColor.primary
    }
}

// MARK: - 数据录入区首批三件 Demo 数据（与 Android MainActivity 同名树 1:1）

/// 省份示例数据（广东省完整三级；北京/上海/重庆=直辖市两级收拢）。
private func demoRegionTree() -> [RegionOption] {
    [
        RegionOption(value: "gd", text: "广东省", children: [
            RegionOption(value: "gd_gz", text: "广州市", children: [
                RegionOption(value: "gd_gz_tianhe", text: "天河区"),
                RegionOption(value: "gd_gz_yuexiu", text: "越秀区"),
                RegionOption(value: "gd_gz_haizhu", text: "海珠区")
            ]),
            RegionOption(value: "gd_sz", text: "深圳市", children: [
                RegionOption(value: "gd_sz_nanshan", text: "南山区"),
                RegionOption(value: "gd_sz_futian", text: "福田区"),
                RegionOption(value: "gd_sz_luohu", text: "罗湖区")
            ]),
            RegionOption(value: "gd_dg", text: "东莞市", children: [
                RegionOption(value: "gd_dg_nancheng", text: "南城街道"),
                RegionOption(value: "gd_dg_changan", text: "长安镇")
            ])
        ]),
        RegionOption(value: "zj", text: "浙江省", children: [
            RegionOption(value: "zj_hz", text: "杭州市", children: [
                RegionOption(value: "zj_hz_xihu", text: "西湖区"),
                RegionOption(value: "zj_hz_shangcheng", text: "上城区"),
                RegionOption(value: "zj_hz_gongshu", text: "拱墅区")
            ]),
            RegionOption(value: "zj_nb", text: "宁波市", children: [
                RegionOption(value: "zj_nb_haishu", text: "海曙区"),
                RegionOption(value: "zj_nb_yinzhou", text: "鄞州区")
            ])
        ]),
        RegionOption(value: "js", text: "江苏省", children: [
            RegionOption(value: "js_nj", text: "南京市", children: [
                RegionOption(value: "js_nj_xuanwu", text: "玄武区"),
                RegionOption(value: "js_nj_gulou", text: "鼓楼区")
            ])
        ]),
        RegionOption(value: "bj", text: "北京市", children: [
            RegionOption(value: "110105", text: "朝阳区"),
            RegionOption(value: "110108", text: "海淀区"),
            RegionOption(value: "110101", text: "东城区")
        ]),
        RegionOption(value: "sh", text: "上海市", children: [
            RegionOption(value: "310104", text: "徐汇区"),
            RegionOption(value: "310101", text: "黄浦区"),
            RegionOption(value: "310106", text: "静安区")
        ]),
        RegionOption(value: "cq", text: "重庆市", children: [
            RegionOption(value: "500103", text: "渝中区"),
            RegionOption(value: "500108", text: "南岸区")
        ])
    ]
}

/// D3 长列表：在省级示例基础上补 14 个模拟省份（共 20 项滚动可验）。
private func demoLongRegionTree() -> [RegionOption] {
    demoRegionTree() + (1...14).map { i in
        RegionOption(value: "demo\(i)", text: "示例省份 \(i)", children: [
            RegionOption(value: "demo\(i)_c1", text: "示例市甲"),
            RegionOption(value: "demo\(i)_c2", text: "示例市乙")
        ])
    }
}

/// 支出分类树（任意深度 + 节点禁用，Cascader D1/D2）。
private func demoCategoryTree() -> [CascaderOption] {
    [
        CascaderOption(value: "living", text: "生活", children: [
            CascaderOption(value: "dining", text: "餐饮", children: [
                CascaderOption(value: "fastfood", text: "快餐"),
                CascaderOption(value: "dinner", text: "正餐"),
                CascaderOption(value: "brunch", text: "早午餐")
            ]),
            CascaderOption(value: "shopping", text: "购物", children: [
                CascaderOption(value: "daily", text: "日用百货"),
                CascaderOption(value: "cloth", text: "衣物鞋包")
            ]),
            CascaderOption(value: "transport", text: "出行", children: [
                CascaderOption(value: "taxi", text: "打车"),
                CascaderOption(value: "metro", text: "地铁")
            ])
        ]),
        CascaderOption(value: "invest", text: "投资", children: [
            CascaderOption(value: "fund", text: "基金", children: [
                CascaderOption(value: "stockfund", text: "股票基金"),
                CascaderOption(value: "bondfund", text: "债券基金"),
                CascaderOption(value: "closedfund", text: "封闭期基金", disabled: true)
            ]),
            CascaderOption(value: "stock", text: "股票")
        ]),
        CascaderOption(value: "medical", text: "医疗", disabled: true)
    ]
}

/// 深层组织架构树（5 层路径 + 横滑回退，Cascader D3）。
private func demoOrgTree() -> [CascaderOption] {
    [
        CascaderOption(value: "group", text: "集团", children: [
            CascaderOption(value: "pl", text: "产品线 A", children: [
                CascaderOption(value: "mobile", text: "移动端", children: [
                    CascaderOption(value: "comps", text: "组件组", children: [
                        CascaderOption(value: "ios", text: "iOS 组件"),
                        CascaderOption(value: "android", text: "Android 组件")
                    ]),
                    CascaderOption(value: "apis", text: "接口组")
                ]),
                CascaderOption(value: "web", text: "Web 端")
            ]),
            CascaderOption(value: "plb", text: "产品线 B", children: [
                CascaderOption(value: "data", text: "数据平台")
            ])
        ])
    ]
}

private func demoWeekdayIndex(_ year: Int, _ month: Int, _ day: Int) -> Int {
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    guard let date = Calendar.current.date(from: comps) else { return 0 }
    let weekday = Calendar.current.component(.weekday, from: date) // 1=周日 … 7=周六
    return (weekday + 6) % 7
}

private func weekdayCN(_ date: CalendarDate) -> String {
    "星期" + ["日", "一", "二", "三", "四", "五", "六"][demoWeekdayIndex(date.year, date.month, date.day)]
}

/// 白色圆角卡片容器（等价 Android demo Box bgCard+圆角+细边框；高度固定由数据需求定）。
private func demoCard(in container: UIView, height: CGFloat) -> UIView {
    let card = UIView()
    card.backgroundColor = AppColor.bgCard
    card.layer.cornerRadius = AppRadius.md
    card.layer.borderWidth = 0.5
    card.layer.borderColor = AppColor.border.cgColor
    card.layer.masksToBounds = true
    container.addSubview(card)
    card.snp.makeConstraints { make in
        make.edges.equalToSuperview()
        make.height.equalTo(height)
    }
    return card
}



// MARK: - Address Showcase（Address 地址 · ui.address · #21）

final class AddressShowcase: ShowcaseViewController {
    private var d4Address: AddressView?
    private var d4Feedback: UILabel?
    private var d4Times = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Address", version: "v1.0", builtAt: "2026-09-05")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础省市区三级联动（完整链路 + 结果回显）") { container in
            let card = demoCard(in: container, height: 320)
            var info: UILabel!
            let address = AddressView(options: demoRegionTree(), onChange: { result in
                info?.text = "onChange → \(result.text)，codes=[\(result.codes.joined(separator: ","))]"
                info?.textColor = AppColor.primary
            })
            card.addSubview(address)
            address.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("广东→深圳→南山区 完整链路；选到区（叶子）=回调结构化结果 codes+names+text。")
        }
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 直辖市数据两级自动收拢") { container in
            let card = demoCard(in: container, height: 300)
            var info: UILabel!
            let bj = demoRegionTree().first { $0.value == "bj" }
            let sh = demoRegionTree().first { $0.value == "sh" }
            let cq = demoRegionTree().first { $0.value == "cq" }
            let address = AddressView(options: [
                RegionOption(value: "bj", text: "北京市", children: bj?.children),
                RegionOption(value: "sh", text: "上海市", children: sh?.children),
                RegionOption(value: "cq", text: "重庆市", children: cq?.children)
            ], onChange: { result in
                info?.text = "onChange → \(result.text)"
                info?.textColor = AppColor.primary
            })
            card.addSubview(address)
            address.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("北京/上海/重庆=省层级下 children 直接是区（无市层），选中即两级完成。")
        }
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 20 省大列表滚动 + tab 回退重选") { container in
            let card = demoCard(in: container, height: 230)
            var info: UILabel!
            let address = AddressView(options: demoLongRegionTree(), onChange: { result in
                info?.text = "onChange → \(result.text)"
                info?.textColor = AppColor.primary
            })
            card.addSubview(address)
            address.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("列表区可滚动；点顶部已选层 tab（如「广东省」）可回退到对应层重选。")
        }
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 受控外部驱动（result 预填回显 / 清空）") { container in
            let card = demoCard(in: container, height: 320)
            let address = AddressView(
                options: demoRegionTree(),
                onChange: { [weak self] result in
                    guard let self else { return }
                    self.d4Times += 1
                    self.d4Feedback?.text = "onChange → \(result.text)（触发源：用户点选，累计 \(self.d4Times) 次）"
                    self.d4Feedback?.textColor = AppColor.primary
                }
            )
            self.d4Address = address
            card.addSubview(address)
            address.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        demoButtonRow(
            ("回显 上海市 徐汇区", { [weak self] in
                guard let self else { return }
                self.d4Address?.result = AddressResult(codes: ["sh", "310104"], names: ["上海市", "徐汇区"], text: "上海市 徐汇区")
                self.d4Feedback?.text = "外部 result → 上海市 徐汇区（未触发 onChange，计数仍为 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            }),
            ("清空", { [weak self] in
                guard let self else { return }
                self.d4Address?.result = nil
                self.d4Feedback?.text = "外部清空 result → 回根层（未触发 onChange，计数仍为 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            })
        )
        d4Feedback = addDynamicInfo("外部 result 驱动高亮定位（选中计数 0 次）；清空=回根层。", color: AppColor.textSecondary)
    }
}

// MARK: - CalendarCard Showcase（CalendarCard 日历卡片 · ui.calendar-card）

final class CalendarCardShowcase: ShowcaseViewController {
    private var d4Calendar: CalendarCardView?
    private var d4Feedback: UILabel?
    private var d4Times = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "CalendarCard", version: "v1.0", builtAt: "2026-09-05")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func calendarCard(
        in card: UIView,
        selected: CalendarDate? = nil,
        minDate: CalendarDate? = nil,
        maxDate: CalendarDate? = nil,
        onChange: @escaping (CalendarDate) -> Void
    ) {
        let calendar = CalendarCardView(selected: selected, minDate: minDate, maxDate: maxDate, onChange: onChange)
        card.addSubview(calendar)
        calendar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(AppSpace.sm)
            make.height.equalTo(306) // 44 头 + 22 星期行 + 6×40 网格 = 306
        }
    }

    private func buildDemo1() {
        let today = CalendarDate.today()
        addSection(title: "Demo 1 · 基础当月单选（今日描边 + 点选高亮回显）") { container in
            let card = demoCard(in: container, height: 306 + AppSpace.sm * 2)
            var info: UILabel!
            calendarCard(in: card, onChange: { date in
                info?.text = "onChange → \(date.text)（\(weekdayCN(date))）"
                info?.textColor = AppColor.primary
            })
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("今日 \(today.text)=主色描边圆；点选=主色实心圆白字；点已选中日幂等不重复回调。")
        }
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 月份切换 + 跨月网格稳定") { container in
            let card = demoCard(in: container, height: 306 + AppSpace.sm * 2)
            var info: UILabel!
            calendarCard(in: card, onChange: { date in
                info?.text = "onChange → \(date.text)（\(weekdayCN(date))）"
                info?.textColor = AppColor.primary
            })
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("‹ › 逐月切换，首尾空位占位 7×6 网格稳定不跳行；今日描边跨月仍定位。")
        }
    }

    private func buildDemo3() {
        let today = CalendarDate.today()
        addSection(title: "Demo 3 · 范围禁用（min=当月 1 日 / max=当月 15 日）") { container in
            let card = demoCard(in: container, height: 306 + AppSpace.sm * 2)
            var info: UILabel!
            calendarCard(
                in: card,
                minDate: CalendarDate(year: today.year, month: today.month, day: 1),
                maxDate: CalendarDate(year: today.year, month: today.month, day: 15),
                onChange: { date in
                    info?.text = "onChange → \(date.text)（\(weekdayCN(date))）"
                    info?.textColor = AppColor.primary
                }
            )
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("范围外灰禁不可点；越界翻月=对应箭头置灰禁翻。")
        }
    }

    private func buildDemo4() {
        let today = CalendarDate.today()
        addSection(title: "Demo 4 · 受控外部驱动（selected 预填回显自动切月 / 清空）") { container in
            let card = demoCard(in: container, height: 306 + AppSpace.sm * 2)
            let calendar = CalendarCardView(onChange: { [weak self] date in
                guard let self else { return }
                self.d4Times += 1
                self.d4Feedback?.text = "onChange → \(date.text)（\(weekdayCN(date))）（触发源：用户点选，累计 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            })
            self.d4Calendar = calendar
            card.addSubview(calendar)
            calendar.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(AppSpace.sm)
                make.height.equalTo(306)
            }
        }
        demoButtonRow(
            ("回显 12 月 24 日", { [weak self] in
                guard let self else { return }
                self.d4Calendar?.selected = CalendarDate(year: today.year, month: 12, day: 24)
                self.d4Feedback?.text = "外部 selected → 12-24（自动切 12 月，未触发 onChange，计数仍为 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            }),
            ("清空选中", { [weak self] in
                guard let self else { return }
                self.d4Calendar?.selected = nil
                self.d4Feedback?.text = "外部清空 selected → 网格无选中（保留当前月，未触发 onChange，计数仍为 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            })
        )
        d4Feedback = addDynamicInfo("外部 selected 变化 → 同步高亮并自动切到所属月；清空=网格无选中。", color: AppColor.textSecondary)
    }
}

// MARK: - Cascader Showcase（Cascader 级联选择 · ui.cascader）

final class CascaderShowcase: ShowcaseViewController {
    private var d4Cascader: CascaderView?
    private var d4Feedback: UILabel?
    private var d4Times = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Cascader", version: "v1.0", builtAt: "2026-09-05")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础三级品类树（叶子完成 + 路径回显）") { container in
            let card = demoCard(in: container, height: 320)
            var info: UILabel!
            let cascader = CascaderView(options: demoCategoryTree(), onChange: { result in
                info?.text = "onChange → \(result.text)"
                info?.textColor = AppColor.primary
            })
            card.addSubview(cascader)
            cascader.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("生活→餐饮→正餐 任意三级叶子；选中=回调 values+texts+text（/ 拼接）。")
        }
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 深浅树混合（2~3 层）+ 节点禁用") { container in
            let card = demoCard(in: container, height: 320)
            var info: UILabel!
            let cascader = CascaderView(options: demoCategoryTree(), onChange: { result in
                info?.text = "onChange → \(result.text)"
                info?.textColor = AppColor.primary
            })
            card.addSubview(cascader)
            cascader.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("同树既有 2 层叶（打车/地铁/股票）又有 3 层枝（…/债券基金）；「封闭期基金」「医疗」禁用灰 40% 不可点。")
        }
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 5 层组织路径 + 中间层 tab 回退重选") { container in
            let card = demoCard(in: container, height: 320)
            var info: UILabel!
            let cascader = CascaderView(options: demoOrgTree(), onChange: { result in
                info?.text = "onChange → \(result.text)"
                info?.textColor = AppColor.primary
            })
            card.addSubview(cascader)
            cascader.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            info = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("点「产品线 A」等中间层 tab 回退到该层重选其下枝；树深任意由数据决定。")
        }
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 受控外部驱动（result 预填回显 / 清空）") { container in
            let card = demoCard(in: container, height: 320)
            let cascader = CascaderView(options: demoOrgTree(), onChange: { [weak self] result in
                guard let self else { return }
                self.d4Times += 1
                self.d4Feedback?.text = "onChange → \(result.text)（触发源：用户点选，累计 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            })
            self.d4Cascader = cascader
            card.addSubview(cascader)
            cascader.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        demoButtonRow(
            ("回显 组件组/Android", { [weak self] in
                guard let self else { return }
                self.d4Cascader?.result = CascaderResult(
                    values: ["group", "pl", "mobile", "comps", "android"],
                    texts: ["集团", "产品线 A", "移动端", "组件组", "Android 组件"],
                    text: "集团/产品线 A/移动端/组件组/Android 组件"
                )
                self.d4Feedback?.text = "外部 result → 集团/产品线 A/移动端/组件组/Android 组件（未触发 onChange，计数仍为 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            }),
            ("清空", { [weak self] in
                guard let self else { return }
                self.d4Cascader?.result = nil
                self.d4Feedback?.text = "外部清空 result → 回根层（未触发 onChange，计数仍为 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            })
        )
        d4Feedback = addDynamicInfo("外部 result 按 values 逐层展开高亮；清空=回根层。", color: AppColor.textSecondary)
    }
}

// MARK: - Form Showcase（Form 表单 · ui.form · #28）

final class FormShowcase: ShowcaseViewController {
    private var d2Phone: FormFieldRow?
    private var d2Nick: FormFieldRow?
    private var d2Feedback: UILabel?
    private var d4Feedback: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Form", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    /// 内容槽 mock（宿主控件示意）：右侧值/占位文案，供 FormFieldRow 内容槽嵌入。
    private func valueLabel(_ text: String, color: UIColor = AppColor.textSecondary) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        label.textColor = color
        label.textAlignment = .right
        return label
    }

    private func agreementLabel() -> UILabel {
        let label = UILabel()
        label.text = "我已阅读并同意《用户协议》与《隐私政策》"
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .left
        return label
    }

    /// 宿主提交按钮（全宽主色胶囊），用于 Form.submitView 槽。
    private func primaryButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColor.primary
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: AppSpace.lg, bottom: 10, right: AppSpace.lg)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    /// 把自适应高视图钉入段容器（top/leading/trailing），由内容高推出容器高。
    private func pinFitted(_ view: UIView, in container: UIView, after previous: UIView? = nil) {
        container.addSubview(view)
        view.snp.makeConstraints { make in
            if let previous {
                make.top.equalTo(previous.snp.bottom).offset(AppSpace.md)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
        }
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础字段布局（label 左 + 内容右 + 必填星 + help）") { container in
            let phone = FormFieldRow(label: "手机号", required: true, content: valueLabel("138****8888"))
            let nick = FormFieldRow(label: "昵称", required: true, content: valueLabel("有鱼记账"))
            let intro = FormFieldRow(label: "简介", help: "选填，一句话介绍自己", content: valueLabel("有鱼记账小助手"))
            let form = Form(groupTitle: "登录信息", rows: [phone, nick, intro])
            pinFitted(form, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(form.snp.bottom) }
        }
        addInfo("字段行 label 左内容右 · 必填星主色 · 行间 hairline 全卡宽分隔 · help 行内次色小字。")
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 校验错误渲染（行内红字 + 无错不占位）") { container in
            let phone = FormFieldRow(label: "手机号", required: true, content: valueLabel("请输入手机号", color: AppColor.textPrimary))
            let nick = FormFieldRow(label: "昵称", required: true, content: valueLabel("A"))
            let intro = FormFieldRow(label: "简介", help: "选填，一句话介绍自己", content: valueLabel("已通过", color: AppColor.primary))
            d2Phone = phone
            d2Nick = nick
            let form = Form(rows: [phone, nick, intro])
            pinFitted(form, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(form.snp.bottom) }
        }
        demoButtonRow(
            ("触发校验", { [weak self] in
                guard let self else { return }
                self.d2Phone?.error = "手机号不能为空"
                self.d2Nick?.error = "昵称至少 2 个字符"
                self.d2Feedback?.text = "校验失败：两行 error 红字展开（帮助文案被 error 顶替）"
                self.d2Feedback?.textColor = AppColor.error
            }),
            ("清空校验", { [weak self] in
                guard let self else { return }
                self.d2Phone?.error = nil
                self.d2Nick?.error = nil
                self.d2Feedback?.text = "校验通过：error 清空=红字收起不占位（简介 help 恢复灰字）"
                self.d2Feedback?.textColor = AppColor.primary
            })
        )
        d2Feedback = addDynamicInfo("首屏无错误；点「触发校验」展开 error 行，点「清空校验」收起。", color: AppColor.textSecondary)
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 长 label 折行 + 无 label 行（内容全宽）") { container in
            let longLabel = FormFieldRow(label: "账单导出文件名前缀（支持中文，最长 20 字）", content: valueLabel("2026-09 消费", color: AppColor.textPrimary))
            let agreement = FormFieldRow(label: nil, content: agreementLabel())
            let form = Form(rows: [longLabel, agreement])
            pinFitted(form, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(form.snp.bottom) }
        }
        addInfo("label 超长在 96pt 区内自动折行（行随内容增高）；无 label 字段内容占整行。")
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 多分组卡片 + 提交按钮槽（宿主按钮）") { container in
            let form1 = Form(groupTitle: "账户信息", rows: [
                FormFieldRow(label: "用户名", content: valueLabel("damon88131787")),
                FormFieldRow(label: "邮箱", content: valueLabel("da****@opc.local")),
                FormFieldRow(label: "手机号", content: valueLabel("138****8888")),
            ])
            pinFitted(form1, in: container)
            let form2 = Form(groupTitle: "安全设置", rows: [
                FormFieldRow(label: "登录密码", content: valueLabel("已设置 · 去修改 ›", color: AppColor.primary)),
                FormFieldRow(label: "二次验证", content: valueLabel("已开启 ›", color: AppColor.primary)),
            ])
            form2.submitView = primaryButton(title: "保存修改") { [weak self] in
                guard let self else { return }
                self.d4Feedback?.text = "提交：表单内容与校验结论=宿主职责（本 demo 无业务校验）"
                self.d4Feedback?.textColor = AppColor.primary
            }
            pinFitted(form2, in: container, after: form1)
            container.snp.makeConstraints { $0.bottom.equalTo(form2.snp.bottom) }
        }
        d4Feedback = addDynamicInfo("多分组卡上下排（间距 md）· 提交槽=库内/宿主按钮（置于 Form.submitView）。", color: AppColor.textSecondary)
    }
}

// MARK: - InputNumber Showcase（数字输入 · ui.input-number · #30）

final class InputNumberShowcase: ShowcaseViewController {
    private var d1Feedback: UILabel?
    private var d2Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?
    private var d4Stepper: InputNumberView?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "InputNumber", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    /// 步进行：左侧 label + 右侧步进器（垂直居中）。
    @discardableResult
    private func fieldRow(label: String, input: UIView, in container: UIView, after previous: UIView? = nil) -> UIView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: AppFont.sizeSm)
        labelView.textColor = AppColor.textPrimary
        container.addSubview(labelView)
        container.addSubview(input)
        labelView.snp.makeConstraints { make in
            if let previous {
                make.top.equalTo(previous.snp.bottom).offset(AppSpace.md)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.height.equalTo(32)
        }
        input.snp.makeConstraints { make in
            make.centerY.equalTo(labelView.snp.centerY)
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
        }
        labelView.snp.makeConstraints { make in
            make.trailing.lessThanOrEqualTo(input.snp.leading).offset(-AppSpace.sm)
        }
        return labelView
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 数量步进（min 1 · max 99 · step 1，onChange 回显）") { container in
            let stepper = InputNumberView(value: 1, min: 1, max: 99) { [weak self] newValue in
                guard let self else { return }
                self.d1Feedback?.text = "onChange → 数量 \(Self.trim0(newValue))（边界自动禁用 −/+）"
                self.d1Feedback?.textColor = AppColor.primary
            }
            let last = fieldRow(label: "购买数量", input: stepper, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(last.snp.bottom) }
        }
        d1Feedback = addDynamicInfo("数量 1；点 − / + 步进 1，到 1 / 99 对应钮灰 40% 幂等。", color: AppColor.textSecondary)
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 提前预约人数（min 1 · max 6，value=3）") { container in
            let stepper = InputNumberView(value: 3, min: 1, max: 6) { [weak self] newValue in
                guard let self else { return }
                self.d2Feedback?.text = "onChange → 预约 \(Self.trim0(newValue)) 人"
                self.d2Feedback?.textColor = AppColor.primary
            }
            let last = fieldRow(label: "提前预约人数", input: stepper, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(last.snp.bottom) }
        }
        d2Feedback = addDynamicInfo("初始 3；仅 −/＋ 步进，无键盘直输（一期）。", color: AppColor.textSecondary)
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 体重小数步进（min 20 · max 200 · step 0.5 · precision 1）") { container in
            let stepper = InputNumberView(value: 50, min: 20, max: 200, step: 0.5, precision: 1) { [weak self] newValue in
                guard let self else { return }
                self.d3Feedback?.text = "onChange → \(Self.trimDecimal(newValue, precision: 1)) kg（step 0.5 定点，50.0 保留 1 位）"
                self.d3Feedback?.textColor = AppColor.primary
            }
            let last = fieldRow(label: "体重（kg）", input: stepper, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(last.snp.bottom) }
        }
        d3Feedback = addDynamicInfo("定点运算防浮点尾差（BigDecimal 语义等价 Android）；精度位数=precision。", color: AppColor.textSecondary)
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 组队人数 + 禁用/重置（半受控）") { container in
            let stepper = InputNumberView(value: 2, min: 1, max: 10) { [weak self] newValue in
                guard let self else { return }
                self.d4Feedback?.text = "onChange → 组队 \(Self.trim0(newValue)) 人"
                self.d4Feedback?.textColor = AppColor.primary
            }
            d4Stepper = stepper
            let last = fieldRow(label: "组队人数", input: stepper, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(last.snp.bottom) }
        }
        demoButtonRow(
            ("重置为 2", { [weak self] in
                guard let self else { return }
                self.d4Stepper?.value = 2
                self.d4Feedback?.text = "外部 value=2 回显（不触发 onChange，组件纯回写）"
                self.d4Feedback?.textColor = AppColor.textSecondary
            }),
            ("禁用 / 启用", { [weak self] in
                guard let self, let stepper = self.d4Stepper else { return }
                stepper.disabled.toggle()
                self.d4Feedback?.text = stepper.disabled ? "已禁用：整控件 40% 置灰不可点" : "已启用"
                self.d4Feedback?.textColor = stepper.disabled ? AppColor.textSecondary : AppColor.primary
            })
        )
        d4Feedback = addDynamicInfo("半受控：点按增减=组件自管并 onChange；外部重置 value 仅同步显示。", color: AppColor.textSecondary)
    }

    /// 整数展示（precision=0）去小数点。
    private static func trim0(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : "\(value)"
    }

    private static func trimDecimal(_ value: Double, precision: Int) -> String {
        let f = pow(10, Double(precision))
        return String(format: "%.\(precision)f", (value * f).rounded() / f)
    }
}

// MARK: - Menu Showcase（菜单 · ui.menu · #31）

/// 4 段排查：D1 单列基础（默认取首个启用项）；D2 四列独立筛选来回切（同列收起幂等）；
/// D3 长列表滚动 + 末项禁用；D4 受控外部 selectedValues 驱动（回显/重置，不触发 onChange）。
/// 与 Android MenuDemo 4 段 1:1 同构（嵌入式内联面板：展开会推挤下方宿主内容）。
final class MenuShowcase: ShowcaseViewController {
    private var d2Menu: MenuView?
    private var d3Menu: MenuView?
    private var d4Menu: MenuView?
    private var d1Feedback: UILabel?
    private var d2Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?
    private var d4Times = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Menu", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    /// 数据对齐 design-spec menu-design-spec.html 04 排查段；双端 MenuOption/MenuColumn 同构。
    private func columns1() -> [MenuColumn] {
        [MenuColumn(key: "sort", title: "排序方式", options: [
            MenuOption(value: "latest", text: "时间最新"),
            MenuOption(value: "recommend", text: "推荐排序"),
            MenuOption(value: "price", text: "价格最低"),
        ])]
    }

    private func columns2() -> [MenuColumn] {
        [
            MenuColumn(key: "sort", title: "排序", options: [
                MenuOption(value: "amount", text: "金额最多"),
                MenuOption(value: "latest", text: "时间最新"),
                MenuOption(value: "count", text: "笔数最多"),
            ]),
            MenuColumn(key: "time", title: "时间", options: [
                MenuOption(value: "all", text: "全部"),
                MenuOption(value: "w7", text: "近 7 天"),
                MenuOption(value: "w30", text: "近 30 天"),
                MenuOption(value: "m3", text: "近 3 个月"),
                MenuOption(value: "year", text: "今年"),
            ]),
            MenuColumn(key: "type", title: "类型", options: [
                MenuOption(value: "all", text: "全部"),
                MenuOption(value: "expense", text: "支出"),
                MenuOption(value: "income", text: "收入"),
            ]),
            MenuColumn(key: "status", title: "状态", options: [
                MenuOption(value: "all", text: "全部"),
                MenuOption(value: "cleared", text: "已入账"),
                MenuOption(value: "pending", text: "待入账"),
            ]),
        ]
    }

    private func columns3() -> [MenuColumn] {
        // 12 项 = 超过面板 max 高 220（5 行 × 44），末项禁用演示不可点灰行。
        [MenuColumn(key: "ledger", title: "账本", options: [
            MenuOption(value: "all", text: "全部"),
            MenuOption(value: "home", text: "家庭账本"),
            MenuOption(value: "travel", text: "旅行账本"),
            MenuOption(value: "decorate", text: "装修账本"),
            MenuOption(value: "shopping", text: "购物账本"),
            MenuOption(value: "transport", text: "交通账本"),
            MenuOption(value: "fun", text: "娱乐账本"),
            MenuOption(value: "food", text: "餐饮账本"),
            MenuOption(value: "medical", text: "医疗账本"),
            MenuOption(value: "edu", text: "教育账本"),
            MenuOption(value: "invest", text: "投资账本"),
            MenuOption(value: "deleted", text: "删除的账本", disabled: true),
        ])]
    }

    private func columns4() -> [MenuColumn] {
        [
            MenuColumn(key: "time", title: "时间", options: [
                MenuOption(value: "all", text: "全部"),
                MenuOption(value: "w30", text: "近 30 天"),
                MenuOption(value: "year", text: "今年"),
            ]),
            MenuColumn(key: "type", title: "类型", options: [
                MenuOption(value: "all", text: "全部"),
                MenuOption(value: "expense", text: "支出"),
                MenuOption(value: "income", text: "收入"),
            ]),
            MenuColumn(key: "sort", title: "排序", options: [
                MenuOption(value: "latest", text: "时间最新"),
                MenuOption(value: "amount", text: "金额最多"),
            ]),
        ]
    }

    private func demoMenuCard(in container: UIView, menu: UIView) {
        let card = UIView()
        card.backgroundColor = AppColor.bgCard
        card.layer.cornerRadius = AppRadius.md
        card.layer.borderWidth = 0.5
        card.layer.borderColor = AppColor.border.cgColor
        card.layer.masksToBounds = true
        container.addSubview(card)
        menu.backgroundColor = AppColor.bgCard
        card.addSubview(menu)
        card.snp.makeConstraints { make in make.edges.equalToSuperview() }
        menu.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 单列基础（默认取首个启用项）") { container in
            let menu = MenuView(columns: self.columns1(), onChange: { [weak self] key, value in
                guard let self else { return }
                let text = self.text(forKey: key, in: self.columns1(), value: value)
                self.d1Feedback?.text = "onChange → \(key)=\(value)（\(text)），展开面板已收起"
                self.d1Feedback?.textColor = AppColor.primary
            })
            self.demoMenuCard(in: container, menu: menu)
            d1Feedback = addDynamicInfo("onChange → （未选择，默认=时间最新）", color: AppColor.primary)
            addInfo("点列=展开内联面板（推挤下方内容）；再点=收起；选中小字回显（标题右侧 Sm 值 + 主色高亮）。")
        }
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 四列独立筛选（同列收起幂等，选后自动收起）") { container in
            let menu = MenuView(columns: self.columns2(), onChange: { [weak self] key, value in
                guard let self else { return }
                let text = self.text(forKey: key, in: self.columns2(), value: value)
                self.d2Feedback?.text = "onChange → \(key)=\(value)（\(text)）"
                self.d2Feedback?.textColor = AppColor.primary
            })
            self.d2Menu = menu
            self.demoMenuCard(in: container, menu: menu)
            d2Feedback = addDynamicInfo("onChange → （未选择；每列默认取自身首个启用项）", color: AppColor.primary)
            addInfo("任意两列来回切：展开列自动收起；点当前展开列=幂等收起；选完自动收起并回显。")
        }
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 长列表（12 项，面板超 5 行内部滚动）+ 末项禁用") { container in
            let menu = MenuView(columns: self.columns3(), onChange: { [weak self] key, value in
                guard let self else { return }
                let text = self.text(forKey: key, in: self.columns3(), value: value)
                self.d3Feedback?.text = "onChange → \(key)=\(value)（\(text)）"
                self.d3Feedback?.textColor = AppColor.primary
            })
            self.d3Menu = menu
            self.demoMenuCard(in: container, menu: menu)
            d3Feedback = addDynamicInfo("onChange → （未选择；默认=全部）", color: AppColor.primary)
            addInfo("展开面板 max 高 220pt（5 行×44），12 项内部滚动可触达「删除的账本」灰行=禁用不可点。")
        }
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 受控外部驱动（回显 时间=今年 + 类型=支出 / 重置默认）") { container in
            let menu = MenuView(columns: self.columns4(), onChange: { [weak self] key, value in
                guard let self else { return }
                self.d4Times += 1
                let text = self.text(forKey: key, in: self.columns4(), value: value)
                self.d4Feedback?.text = "onChange → \(key)=\(value)（\(text)）（触发源：用户点选，累计 \(self.d4Times) 次）"
                self.d4Feedback?.textColor = AppColor.primary
            })
            self.d4Menu = menu
            self.demoMenuCard(in: container, menu: menu)
            demoButtonRow(
                ("回显 时间=今年/类型=支出", { [weak self] in
                    guard let self else { return }
                    self.d4Menu?.selectedValues = ["time": "year", "type": "expense"]
                    self.d4Feedback?.text = "外部 selectedValues → 时间=今年、类型=支出（未触发 onChange，累计仍 \(self.d4Times) 次）"
                    self.d4Feedback?.textColor = AppColor.primary
                }),
                ("重置为默认", { [weak self] in
                    guard let self else { return }
                    self.d4Menu?.selectedValues = nil
                    self.d4Feedback?.text = "外部重置 selectedValues=nil → 各列回落首个启用项（未触发 onChange，累计仍 \(self.d4Times) 次）"
                    self.d4Feedback?.textColor = AppColor.primary
                })
            )
            d4Feedback = addDynamicInfo("onChange → （未选择）", color: AppColor.primary)
            addInfo("外部 selectedValues 驱动回显（高亮 + 标题小字），不触发 onChange；仅用户点选才计数。")
        }
    }

    /// 供 onChange 反馈回填 option 文本（双端同构：Android 直接展示列内当前文案）。
    private func text(forKey key: String, in columns: [MenuColumn], value: String) -> String {
        columns.first(where: { $0.key == key })?
            .options.first(where: { $0.value == value })?.text ?? value
    }
}

// MARK: - Checkbox Showcase（复选 · ui.checkbox · #25）

/// 双形态（单只 + 组）：Demo 1 组多选内部自持；Demo 2 单只各态；Demo 3 受控组 + 外部回写；
/// Demo 4 组禁用 + 混入禁用项 + 长标签省略。与 Android CheckboxDemo 4 段 1:1 同构。
final class CheckboxShowcase: ShowcaseViewController {
    private var d1Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?
    private var d3Group: CheckboxGroupView?
    private var d4Group: CheckboxGroupView?

    private static let displayNames: [String: String] = [
        "tv": "电视", "phone": "手机", "laptop": "笔记本", "pad": "平板",
    ]
    private var selected3: Set<String> = ["tv", "phone"]

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Checkbox", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · CheckboxGroup 多选（内部自持 · 整行命中）") { container in
            let group = CheckboxGroupView(options: [
                CheckboxOption(value: "apple", label: "苹果 Apple"),
                CheckboxOption(value: "banana", label: "香蕉 Banana"),
                CheckboxOption(value: "orange", label: "橙子 Orange"),
            ]) { [weak self] value, checked in
                guard let self else { return }
                self.d1Feedback?.text = "onChange → \(value)（\(checked ? "勾选" : "取消勾选")）"
                self.d1Feedback?.textColor = AppColor.primary
            }
            pinFullWidth(group, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(group.snp.bottom) }
        }
        d1Feedback = addDynamicInfo("三选项组：勾选行=整行 40pt 命中（非仅勾选框）；选中集内部自持。", color: AppColor.textSecondary)
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 单只 CheckboxView 各态") { container in
            var previous: UIView?
            let rows: [(String, Bool?, Bool)] = [
                ("未勾选（可点切换）", false, false),
                ("默认已勾选", true, false),
                ("已勾选 · 禁用（灰勾保留不可点）", true, true),
                ("未勾选 · 禁用", false, true),
            ]
            for (label, checked, disabled) in rows {
                let cb = CheckboxView(label: label, checked: checked, disabled: disabled)
                container.addSubview(cb)
                cb.snp.makeConstraints { make in
                    make.top.equalTo(previous?.snp.bottom ?? container.snp.top).offset(previous == nil ? 0 : AppSpace.sm)
                    make.leading.equalToSuperview().offset(AppSpace.lg)
                    make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
                }
                previous = cb
            }
            container.snp.makeConstraints { $0.bottom.equalTo(previous?.snp.bottom ?? container.snp.top) }
        }
        _ = addDynamicInfo("单只=20 方形 radiusSm + label 后置间距 8；禁用态统一灰、已选禁用保留勾形。", color: AppColor.textSecondary)
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 受控组 + 外部回写（半受控）") { container in
            let group = CheckboxGroupView(
                options: [
                    CheckboxOption(value: "tv", label: "电视"),
                    CheckboxOption(value: "phone", label: "手机"),
                    CheckboxOption(value: "laptop", label: "笔记本"),
                    CheckboxOption(value: "pad", label: "平板"),
                ],
                selected: ["tv", "phone"]
            ) { [weak self] value, checked in
                guard let self else { return }
                if checked { self.selected3.insert(value) } else { self.selected3.remove(value) }
                let names = Self.displayNames[value] ?? value
                self.d3Feedback?.text = "onChange → \(value)（\(names)\(checked ? "已选" : "已取消")；当前=\(Self.summary(of: self.selected3))）"
                self.d3Feedback?.textColor = AppColor.primary
            }
            d3Group = group
            pinFullWidth(group, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(group.snp.bottom) }
        }
        demoButtonRow(
            ("重置 A：电视 + 手机", { [weak self] in
                guard let self else { return }
                self.selected3 = ["tv", "phone"]
                self.d3Group?.selected = self.selected3
                self.d3Feedback?.text = "外部 selected=电视/手机 回写（半受控同步勾选，不触发 onChange）"
                self.d3Feedback?.textColor = AppColor.textSecondary
            }),
            ("重置 B：仅笔记本", { [weak self] in
                guard let self else { return }
                self.selected3 = ["laptop"]
                self.d3Group?.selected = self.selected3
                self.d3Feedback?.text = "外部 selected=仅笔记本 回写"
                self.d3Feedback?.textColor = AppColor.textSecondary
            })
        )
        d3Feedback = addDynamicInfo("半受控：点行=组件自管并 onChange 上报；外部 selected 赋值仅同步刷新勾选。", color: AppColor.textSecondary)
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 组禁用开关 + 混入禁用项 + 长标签省略") { container in
            let group = CheckboxGroupView(
                options: [
                    CheckboxOption(value: "a", label: "普通选项 A"),
                    CheckboxOption(value: "b", label: "禁用选项 B（单项灰 40% 不可点）", disabled: true),
                    CheckboxOption(
                        value: "long",
                        label: "很长很长的演示标签很长很长的演示标签很长很长的演示标签很长很长的演示标签 单行省略验证…"
                    ),
                    CheckboxOption(value: "c", label: "普通选项 C"),
                ],
                disabled: false
            ) { [weak self] value, checked in
                guard let self else { return }
                self.d4Feedback?.text = "onChange → \(value)（\(checked ? "勾选" : "取消")）"
                self.d4Feedback?.textColor = AppColor.primary
            }
            d4Group = group
            pinFullWidth(group, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(group.snp.bottom) }
        }
        demoButtonRow(
            ("禁用 / 启用整组", { [weak self] in
                guard let self, let group = self.d4Group else { return }
                group.disabled.toggle()
                self.d4Feedback?.text = group.disabled
                    ? "整组禁用：统一 40% 置灰、全部行不可点"
                    : "整组已启用（选项 B 仍单项禁用）"
                self.d4Feedback?.textColor = group.disabled ? AppColor.textSecondary : AppColor.primary
            })
        )
        d4Feedback = addDynamicInfo("组 disabled=整体 40% 灰；option.disabled 单项独立生效（B）；长标签单行省略。", color: AppColor.textSecondary)
    }

    /// 「电视/手机」摘要。
    private static func summary(of values: Set<String>) -> String {
        let ordered = ["tv", "phone", "laptop", "pad"].filter { values.contains($0) }
        let names = ordered.map { displayNames[$0] ?? $0 }
        return names.isEmpty ? "无" : names.joined(separator: "、")
    }
}

// MARK: - Radio Showcase（单选 · ui.radio · #35）

/// 通用排他单选：Demo 1 单只点选/外部取消驱动；Demo 2 组排他内部自持；
/// Demo 3 组禁用+禁用项+已选禁用保留；Demo 4 受控外部 value 驱动。与 Android RadioDemo 4 段 1:1 同构。
final class RadioShowcase: ShowcaseViewController {
    private var d1Feedback: UILabel?
    private var d2Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?
    private var d1Radio: RadioView?
    private var d3Group: RadioGroupView?
    private var d4Group: RadioGroupView?

    private static let languageNames: [String: String] = [
        "zh": "中文", "en": "English", "ja": "日本語",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Radio", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 单只 Radio（点选置 true · 取消仅外部驱动）") { container in
            let radio = RadioView(label: "设为默认账本", checked: false) { [weak self] checked in
                guard let self else { return }
                self.d1Feedback?.text = checked ? "onChange → true（点选即确定）" : "onChange → false"
                self.d1Feedback?.textColor = AppColor.primary
            }
            d1Radio = radio
            container.addSubview(radio)
            radio.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.sm)
                make.leading.equalToSuperview().offset(AppSpace.lg)
                make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
            }
            container.snp.makeConstraints { $0.bottom.equalTo(radio.snp.bottom).offset(AppSpace.sm) }
        }
        demoButtonRow(
            ("取消选中", { [weak self] in
                guard let self else { return }
                self.d1Radio?.checked = false
                self.d1Feedback?.text = "外部 checked=false 驱动取消回显（不触发 onChange）"
                self.d1Feedback?.textColor = AppColor.textSecondary
            })
        )
        d1Feedback = addDynamicInfo("单只=圆形点 20 + label 后置；半受控：点选置 true、已选再点幂等忽略（无 toggle 取消）。", color: AppColor.textSecondary)
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · RadioGroup 排他单选（内部自持 · 未选态合法）") { container in
            let group = RadioGroupView(options: [
                RadioOption(value: "male", label: "男"),
                RadioOption(value: "female", label: "女"),
            ]) { [weak self] value in
                guard let self else { return }
                let name = value == "male" ? "男" : "女"
                self.d2Feedback?.text = "onChange → \(value)（\(name)）；当前选中行圆点亮"
                self.d2Feedback?.textColor = AppColor.primary
            }
            pinFullWidth(group, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(group.snp.bottom) }
        }
        d2Feedback = addDynamicInfo("无初值=合法未选态（不自动回填首项）；点未选行=排他切中并回调；再点已选中行=幂等忽略。", color: AppColor.textSecondary)
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 禁用态（组开关 + 禁用项 + value 指向禁用灰保留）") { container in
            let group = RadioGroupView(
                options: [
                    RadioOption(value: "express", label: "快递"),
                    RadioOption(value: "store", label: "到店自提（暂停服务 · value 初始指向=灰点灰圈保留）", disabled: true),
                    RadioOption(value: "reserve", label: "预约配送（已停用）", disabled: true),
                ],
                value: "store"
            ) { [weak self] value in
                guard let self else { return }
                self.d3Feedback?.text = value == "express" ? "onChange → express（快递）" : "onChange → \(value)"
                self.d3Feedback?.textColor = AppColor.primary
            }
            d3Group = group
            pinFullWidth(group, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(group.snp.bottom) }
        }
        demoButtonRow(
            ("禁用 / 启用整组", { [weak self] in
                guard let self, let group = self.d3Group else { return }
                group.disabled.toggle()
                self.d3Feedback?.text = group.disabled
                    ? "整组禁用：统一 40% 置灰、全部行不可点"
                    : "整组已启用（禁用项仍单项灰）"
                self.d3Feedback?.textColor = group.disabled ? AppColor.textSecondary : AppColor.primary
            }),
            ("外部选快递", { [weak self] in
                guard let self else { return }
                self.d3Group?.value = "express"
                self.d3Feedback?.text = "外部 value=快递 切走（原选中禁用项灰圈熄灭）"
                self.d3Feedback?.textColor = AppColor.textSecondary
            })
        )
        d3Feedback = addDynamicInfo("禁用项不可点；value 指向 disabled 项=灰点灰圈只读保留；label 选中行加粗。", color: AppColor.textSecondary)
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 受控外部 value 驱动回显（半受控）") { container in
            let group = RadioGroupView(
                options: [
                    RadioOption(value: "zh", label: "中文"),
                    RadioOption(value: "en", label: "English"),
                    RadioOption(value: "ja", label: "日本語"),
                ],
                value: "zh"
            ) { [weak self] value in
                guard let self else { return }
                let name = Self.languageNames[value] ?? value
                self.d4Feedback?.text = "onChange → \(value)（\(name)）"
                self.d4Feedback?.textColor = AppColor.primary
            }
            d4Group = group
            pinFullWidth(group, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(group.snp.bottom) }
        }
        demoButtonRow(
            ("选 English", { [weak self] in
                guard let self else { return }
                self.d4Group?.value = "en"
                self.d4Feedback?.text = "外部 value=English 回写（同步点亮，不触发 onChange）"
                self.d4Feedback?.textColor = AppColor.textSecondary
            }),
            ("重置中文", { [weak self] in
                guard let self else { return }
                self.d4Group?.value = "zh"
                self.d4Feedback?.text = "外部 value=中文 重置回显（不触发 onChange）"
                self.d4Feedback?.textColor = AppColor.textSecondary
            })
        )
        d4Feedback = addDynamicInfo("受控：外部 value 赋值仅同步刷新高亮（不触发 onChange）；点行=组件上报并宿主回写。", color: AppColor.textSecondary)
    }
}

// MARK: - Range Showcase（区间选择 · ui.range · #36）

/// 横向双钮区间滑块：D1 基础区间拖动实时回显/重置外部驱动；D2 step5 离散吸附+点轨跳最近钮；
/// D3 min 越界 clamp+禁用开关；D4 受控外部 value 驱动。与 Android RangeDemo 4 段 1:1 同构。
final class RangeShowcase: ShowcaseViewController {
    private var d1Feedback: UILabel?
    private var d2Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?
    private var d1Range: RangeView?
    private var d2Range: RangeView?
    private var d3Range: RangeView?
    private var d4Range: RangeView?

    private static func fmt(_ v: Double) -> String {
        v.rounded() == v ? String(Int(v)) : String(v)
    }

    private func rangeText(_ v: RangeValue, suffix: String = "") -> String {
        "onChange → start \(Self.fmt(v.start)) · end \(Self.fmt(v.end))" + suffix
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Range", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础区间（min 0 · max 100 · step 1 · 初始 25–75）") { container in
            let range = RangeView(value: RangeValue(start: 25, end: 75)) { [weak self] v in
                self?.d1Feedback?.text = self?.rangeText(v)
                self?.d1Feedback?.textColor = AppColor.primary
            }
            d1Range = range
            pinFullWidth(range, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(range.snp.bottom) }
        }
        demoButtonRow(
            ("重置 25–75", { [weak self] in
                guard let self else { return }
                self.d1Range?.value = RangeValue(start: 25, end: 75)
                self.d1Feedback?.text = "外部 value=(25,75) 赋值=同步回显（不触发 onChange）"
                self.d1Feedback?.textColor = AppColor.textSecondary
            })
        )
        d1Feedback = addDynamicInfo("拖动任一端钮=step 对齐后连续回调；start/end 硬钳制不可互相越过；点已激活区域外轨道=最近钮吸附。", color: AppColor.textSecondary)
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 离散步进（min 0 · max 100 · step 5 · 初始 20–60）") { container in
            let range = RangeView(value: RangeValue(start: 20, end: 60), step: 5) { [weak self] v in
                self?.d2Feedback?.text = self?.rangeText(v, suffix: "（按 5 吸附）")
                self?.d2Feedback?.textColor = AppColor.primary
            }
            d2Range = range
            pinFullWidth(range, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(range.snp.bottom) }
        }
        d2Feedback = addDynamicInfo("拖动按 step5 档位吸附；点击轨道空段=吸附最近滑块跳到点击档位（如点 0–20 间=动 start）。", color: AppColor.textSecondary)
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 值域与禁用（min 10→60 越界自动 clamp · step 10 · 初始 10–40）") { container in
            let range = RangeView(value: RangeValue(start: 10, end: 40), min: 10, max: 90, step: 10) { [weak self] v in
                self?.d3Feedback?.text = self?.rangeText(v)
                self?.d3Feedback?.textColor = AppColor.primary
            }
            d3Range = range
            pinFullWidth(range, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(range.snp.bottom) }
        }
        demoButtonRow(
            ("改 min=60", { [weak self] in
                guard let self else { return }
                self.d3Range?.min = 60
                self.d3Feedback?.text = "外部 min=60：start/end 越界端自动 clamp 回调（零宽单点 60=合法）"
                self.d3Feedback?.textColor = AppColor.textSecondary
            }),
            ("禁用 / 启用", { [weak self] in
                guard let self, let range = self.d3Range else { return }
                range.disabled.toggle()
                self.d3Feedback?.text = range.disabled
                    ? "整条禁用：textSecondary 40% 灰、不可拖不可点无回调"
                    : "整条已启用"
                self.d3Feedback?.textColor = range.disabled ? AppColor.textSecondary : AppColor.primary
            }),
            ("重置", { [weak self] in
                guard let self, let range = self.d3Range else { return }
                range.min = 10
                range.value = RangeValue(start: 10, end: 40)
                self.d3Feedback?.text = "重置 min=10 value=(10,40)（外部回显不触发 onChange）"
                self.d3Feedback?.textColor = AppColor.textSecondary
            })
        )
        d3Feedback = addDynamicInfo("min/max 动态改=越界端自动 clamp（start/end 贴 min 边界=零宽单点合法）；disabled 整条灰。", color: AppColor.textSecondary)
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 受控外部 value 驱动（min 0 · max 100 · 初始 40–80）") { container in
            let range = RangeView(value: RangeValue(start: 40, end: 80)) { [weak self] v in
                self?.d4Feedback?.text = self?.rangeText(v, suffix: "（宿主回写）")
                self?.d4Feedback?.textColor = AppColor.primary
            }
            d4Range = range
            pinFullWidth(range, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(range.snp.bottom) }
        }
        demoButtonRow(
            ("预设 0–30", { [weak self] in
                guard let self else { return }
                self.d4Range?.value = RangeValue(start: 0, end: 30)
                self.d4Feedback?.text = "外部 value=(0,30) 预设=仅同步回显（不触发 onChange）"
                self.d4Feedback?.textColor = AppColor.textSecondary
            }),
            ("预设 60–100", { [weak self] in
                guard let self else { return }
                self.d4Range?.value = RangeValue(start: 60, end: 100)
                self.d4Feedback?.text = "外部 value=(60,100) 预设=仅同步回显（不触发 onChange）"
                self.d4Feedback?.textColor = AppColor.textSecondary
            })
        )
        d4Feedback = addDynamicInfo("半受控：外部 value 赋值仅同步刷新滑块位置与激活段（不触发 onChange）；拖动=组件上报并宿主回写。", color: AppColor.textSecondary)
    }
}

// MARK: - SearchBar Showcase（搜索栏 · ui.search-bar · #38）

/// 搜索输入壳+放大镜+非空清除钮+软键盘「搜索」键 onSearch+trailing 尾槽双路径：
/// Demo 1 基础搜索输入（半受控内部自持+清除钮）；Demo 2 键盘搜索键 onSearch+宿主列表过滤；
/// Demo 3 禁用+外部 value 驱动；Demo 4 trailing 尾槽宿主搜索按钮（与键盘搜索键双路径）。
/// 与 Android SearchBarDemo 4 段 1:1 同构。
final class SearchBarShowcase: ShowcaseViewController {
    private var d1Search: SearchBarView?
    private var d2Search: SearchBarView?
    private var d3Search: SearchBarView?
    private var d4Search: SearchBarView?
    private var d1Feedback: UILabel?
    private var d2Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?
    private var d2List: UIStackView?
    private var d2Keyword = ""
    private var d3Count = 0
    private let d2Foods = ["苹果", "香蕉", "橙子", "猕猴桃", "米饭", "面条", "酸奶"]

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "SearchBar 搜索栏", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func emit(_ label: UILabel?, _ text: String, color: UIColor = AppColor.primary) {
        label?.text = text
        label?.textColor = color
    }

    /// 段内容贴顶放搜索栏（48 高由 intrinsicContentSize 提供），容器底闭合到底部视图。
    private func attach(_ search: SearchBarView, into container: UIView, bottomItem: UIView? = nil) {
        container.addSubview(search)
        search.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        let tail = bottomItem ?? search
        container.snp.makeConstraints { make in
            make.bottom.equalTo(tail.snp.bottom)
        }
    }

    // MARK: Demo 1 · 基础搜索输入（半受控内部自持 · 清除钮）

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础搜索输入（半受控内部自持 · 清除钮）") { container in
            let search = SearchBarView(
                placeholder: "请输入搜索关键词（软键盘=搜索键）",
                onTextChange: { [weak self] text in
                    let t = text.isEmpty ? "清除钮点击 → 回传空串并清空" : "onTextChange → \(text)"
                    self?.emit(self?.d1Feedback, t)
                }
            )
            d1Search = search
            attach(search, into: container)
        }
        d1Feedback = addDynamicInfo(
            "value=nil=内部自持（宿主拿回调词即可无需回写）；非空即显示清除钮（点击清空回传空串）。",
            color: AppColor.textSecondary
        )
    }

    // MARK: Demo 2 · 键盘搜索键 onSearch + 宿主列表过滤

    private func buildDemo2() {
        addSection(title: "Demo 2 · 键盘搜索键 onSearch + 宿主列表过滤") { container in
            let search = SearchBarView(
                placeholder: "输入过滤示例数据（软键盘搜索键=提交检索）",
                onTextChange: { [weak self] text in self?.updateD2(text) },
                onSearch: { [weak self] kw in self?.runD2(kw) }
            )
            container.addSubview(search)
            search.snp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperview()
            }
            d2Search = search

            let list = UIStackView()
            list.axis = .vertical
            list.spacing = 0
            container.addSubview(list)
            list.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(search.snp.bottom).offset(AppSpace.md)
            }
            d2List = list
            container.snp.makeConstraints { make in
                make.bottom.equalTo(list.snp.bottom)
            }
        }
        d2Feedback = addDynamicInfo(
            "下方列表=宿主 onTextChange 实时过滤示例（输入即筛，检索/结果=宿主自理）。",
            color: AppColor.textSecondary
        )
        rebuildD2List()
    }

    private func updateD2(_ text: String) {
        d2Keyword = text
        emit(d2Feedback, "下方列表=宿主 onTextChange 实时过滤示例（输入即筛，检索/结果=宿主自理）。", color: AppColor.textSecondary)
        rebuildD2List()
    }

    private func runD2(_ raw: String) {
        let kw = raw.trimmingCharacters(in: .whitespaces)
        emit(
            d2Feedback,
            kw.isEmpty ? "onSearch →（空串，宿主自行忽略）" : "onSearch → 「\(kw)」（键盘搜索键触发，宿主执行真实检索）"
        )
    }

    private func rebuildD2List() {
        guard let list = d2List else { return }
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let kw = d2Keyword.trimmingCharacters(in: .whitespaces)
        let hits = kw.isEmpty ? d2Foods : d2Foods.filter { $0.contains(kw) }
        if hits.isEmpty {
            let empty = UILabel()
            empty.text = "无命中（宿主空态自理）"
            empty.font = .systemFont(ofSize: AppFont.sizeXs)
            empty.textColor = AppColor.textSecondary
            list.addArrangedSubview(empty)
            return
        }
        for (index, item) in hits.enumerated() {
            let row = UILabel()
            row.text = item
            row.font = .systemFont(ofSize: AppFont.sizeSm)
            row.textColor = AppColor.textPrimary
            row.heightAnchor.constraint(equalToConstant: 29).isActive = true
            list.addArrangedSubview(row)
            if index != hits.count - 1 {
                let hair = UIView()
                hair.backgroundColor = AppColor.border
                hair.heightAnchor.constraint(equalToConstant: 1).isActive = true
                list.addArrangedSubview(hair)
            }
        }
    }

    // MARK: Demo 3 · 禁用 + 外部 value 驱动

    private func buildDemo3() {
        addSection(title: "Demo 3 · 禁用 + 外部 value 驱动") { container in
            let search = SearchBarView(
                value: "春天",
                placeholder: "禁用态演示",
                onTextChange: { [weak self] _ in
                    guard let self else { return }
                    self.d3Count += 1
                    self.refreshD3("")
                }
            )
            d3Search = search
            attach(search, into: container)
        }
        demoButtonRow(
            ("外部赋值=记账", { [weak self] in
                guard let self else { return }
                self.d3Search?.value = "记账"
                self.refreshD3("外部 value 赋值=仅回显（onTextChange 不触发、计数不变）")
            }),
            ("外部置空", { [weak self] in
                guard let self else { return }
                self.d3Search?.value = ""
                self.refreshD3("外部 value=空串=仅回显清空（不触发 onTextChange）")
            }),
            ("禁用/启用", { [weak self] in
                guard let self, let search = self.d3Search else { return }
                search.disabled.toggle()
                self.refreshD3(
                    search.disabled
                        ? "已禁用：整行 40% 灰、不可输入、清除钮隐藏、无任何回调"
                        : "已启用（可输入）"
                )
            })
        )
        d3Feedback = addDynamicInfo("", color: AppColor.textSecondary)
        refreshD3("外部赋值=仅回显不触发 onTextChange。")
    }

    private func refreshD3(_ message: String, color: UIColor = AppColor.textSecondary) {
        guard let label = d3Feedback else { return }
        let prefix = "onTextChange 触发次数：\(d3Count)（外部赋值不计数）。"
        label.text = message.isEmpty ? prefix + "外部赋值=仅回显不触发 onTextChange。" : prefix + message
        label.textColor = color
    }

    // MARK: Demo 4 · trailing 尾槽宿主搜索按钮（与键盘搜索键双路径）

    private func buildDemo4() {
        addSection(title: "Demo 4 · trailing 尾槽宿主搜索按钮（与键盘搜索键双路径）") { container in
            let button = UIButton(type: .system)
            button.setTitle("搜索", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = AppColor.primary
            button.layer.cornerRadius = 14
            button.clipsToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            button.addTarget(self, action: #selector(d4TrailingTapped), for: .touchUpInside)

            let search = SearchBarView(
                placeholder: "尾槽「搜索」按钮与键盘搜索键双路径",
                trailing: button,
                onTextChange: { [weak self] _ in
                    guard let self else { return }
                    self.emit(
                        self.d4Feedback,
                        "组件不内置提交钮=trailing 槽宿主自放「搜索」按钮，点击与软键盘搜索键同走 onSearch 语义。",
                        color: AppColor.textSecondary
                    )
                },
                onSearch: { [weak self] kw in self?.runD4(kw) }
            )
            d4Search = search
            attach(search, into: container)
        }
        d4Feedback = addDynamicInfo(
            "组件不内置提交钮=trailing 槽宿主自放「搜索」按钮，点击与软键盘搜索键同走 onSearch 语义。",
            color: AppColor.textSecondary
        )
    }

    private func runD4(_ raw: String) {
        let kw = raw.trimmingCharacters(in: .whitespaces)
        emit(
            d4Feedback,
            "搜索动作 →「\(kw.isEmpty ? "（空）" : kw)」（按钮点击=调用 onSearch 同语义，宿主执行检索）"
        )
    }

    @objc private func d4TrailingTapped() {
        runD4(d4Search?.currentText ?? "")
    }
}

// MARK: - Rate Showcase（评分 · ui.rate · #37）

/// 行内五角星整数评分：Demo 1 点选+再点清空；Demo 2 横滑连选松手定值；Demo 3 只读+禁用；
/// Demo 4 自定义 count+受控外部驱动。与 Android RateDemo 4 段 1:1 同构。
final class RateShowcase: ShowcaseViewController {
    private var d1Rate: RateView?
    private var d2Rate: RateView?
    private var d3Rate: RateView?
    private var d4Rate: RateView?
    private var d1Feedback: UILabel?
    private var d2Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Rate 评分", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func emit(_ label: UILabel?, _ text: String, color: UIColor = AppColor.primary) {
        label?.text = text
        label?.textColor = color
    }

    private func attach(_ rate: RateView, into container: UIView) {
        container.addSubview(rate)
        rate.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        container.snp.makeConstraints { $0.bottom.equalTo(rate.snp.bottom) }
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础评分点选（count 5 · 初始 0 未评）") { container in
            let rate = RateView(count: 5) { [weak self] v in
                let text = v == 0 ? "onChange → 0（清空=评价可取消）" : "onChange → \(v)（点选定值）"
                self?.emit(self?.d1Feedback, text)
            }
            d1Rate = rate
            attach(rate, into: container)
        }
        demoButtonRow(
            ("重置外部 value=0", { [weak self] in
                guard let self else { return }
                self.d1Rate?.value = 0
                self.emit(self.d1Feedback, "外部 value=0 赋值=同步回显（不触发 onChange）", color: AppColor.textSecondary)
            })
        )
        d1Feedback = addDynamicInfo("点击第 k 颗=点亮到该颗并回调 k；再点当前值同一颗=清空归 0（评价可取消）；未评=全灰合法态。", color: AppColor.textSecondary)
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 滑动连选（count 5 · 随指点亮/收回松手定值）") { container in
            let rate = RateView(count: 5) { [weak self] v in
                self?.emit(self?.d2Feedback, "onChange → \(v)（滑定回写）")
            }
            d2Rate = rate
            attach(rate, into: container)
        }
        d2Feedback = addDynamicInfo("手指横向滑动=星随位置连续点亮/收回（拖出左缘=熄灭归 0），松手一次性回调定值。", color: AppColor.textSecondary)
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 只读与禁用（初始 readonly 展示 value=4 彩色不可点）") { container in
            let rate = RateView(count: 5, value: 4, readonly: true) { [weak self] v in
                self?.emit(self?.d3Feedback, "onChange → \(v)（只读/禁用无回调）")
            }
            d3Rate = rate
            attach(rate, into: container)
        }
        demoButtonRow(
            ("退出只读", { [weak self] in
                guard let self, let rate = self.d3Rate else { return }
                let next = !rate.readonly
                rate.readonly = next
                let text = next ? "已切换为只读：primary 彩色仅展示不可交互" : "已退出只读（可点选）"
                self.emit(self.d3Feedback, text)
            }),
            ("禁用", { [weak self] in
                guard let self, let rate = self.d3Rate else { return }
                let next = !rate.disabled
                rate.disabled = next
                let text = next ? "已禁用：整行 40% 灰星不可交互（与 readonly 并存=disabled 压过灰）" : "已启用（可交互）"
                self.emit(self.d3Feedback, text)
            }),
            ("重置", { [weak self] in
                guard let self, let rate = self.d3Rate else { return }
                rate.value = 2
                rate.readonly = false
                rate.disabled = false
                self.emit(self.d3Feedback, "外部 value=2 赋值=同步回显（不触发 onChange），同时恢复可交互", color: AppColor.textSecondary)
            })
        )
        d3Feedback = addDynamicInfo("readonly=primary 彩色仅展示不可点（详情评分场景）；disabled=点亮灰填 40%/未点亮 20% 描边不可点。", color: AppColor.textSecondary)
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 自定义 count 与受控（count 10 十分制 · 初始 7）") { container in
            let rate = RateView(count: 10, value: 7) { [weak self] v in
                self?.emit(self?.d4Feedback, "onChange → \(v)/10（宿主回写）")
            }
            d4Rate = rate
            attach(rate, into: container)
        }
        demoButtonRow(
            ("外部 value=10", { [weak self] in
                guard let self else { return }
                self.d4Rate?.value = 10
                self.emit(self.d4Feedback, "外部 value=10 赋值=仅同步回显（不触发 onChange）", color: AppColor.textSecondary)
            }),
            ("重置 0", { [weak self] in
                guard let self else { return }
                self.d4Rate?.value = 0
                self.emit(self.d4Feedback, "外部 value=0 赋值=仅同步回显（不触发 onChange）", color: AppColor.textSecondary)
            })
        )
        d4Feedback = addDynamicInfo("count 可配（十分制等）：星数=count；外部赋值仅回显不触发 onChange；点/滑=组件上报宿主回写。", color: AppColor.textSecondary)
    }
}

// MARK: - ShortPassword Showcase（短密码 · ui.short-password · #39）

/// 无壳居中掩码点行：Demo 1 基础 6 位满位 onComplete+外部清空；Demo 2 定长 4 位+外部预填仅回显
/// 不触发 onComplete；Demo 3 禁用（40% 灰无回调）+粘贴非数字过滤说明；Demo 4 宿主校验（正确码 123456）
/// + NumberKeyboard #32 组装示意。与 Android ShortPasswordDemo 4 段 1:1 同构。
final class ShortPasswordShowcase: ShowcaseViewController {
    private var d1SP: ShortPasswordView?
    private var d2SP: ShortPasswordView?
    private var d3SP: ShortPasswordView?
    private var d4SP: ShortPasswordView?
    private var d1Feedback: UILabel?
    private var d2Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "ShortPassword 短密码", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func emit(_ label: UILabel?, _ text: String, color: UIColor = AppColor.primary) {
        label?.text = text
        label?.textColor = color
    }

    private func attach(_ sp: ShortPasswordView, into container: UIView) {
        container.addSubview(sp)
        sp.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        container.snp.makeConstraints { make in
            make.bottom.equalTo(sp.snp.bottom)
        }
    }

    // MARK: Demo 1 · 基础 6 位输入（默认 length=6 · 半受控内部自持）

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础 6 位输入（默认 length=6 · 半受控内部自持）") { container in
            let sp = ShortPasswordView(
                onChange: { [weak self] v in
                    let t = v.isEmpty ? "onChange → 空串（外部清空回显）" : "onChange → \(v.count)/6 位（掩码点随位递增）"
                    self?.emit(self?.d1Feedback, t)
                },
                onComplete: { [weak self] v in
                    self?.emit(self?.d1Feedback, "onComplete → \(v)（6 位已满，宿主执行校验；请实机软键盘输满 6 位触发）")
                }
            )
            d1SP = sp
            attach(sp, into: container)
        }
        demoButtonRow(("清空（外部 value=\"\"）", { [weak self] in
            guard let self else { return }
            self.d1SP?.value = ""
            self.emit(self.d1Feedback, "外部 value=\"\"=仅同步回显清空（不触发回调）", color: AppColor.textSecondary)
        }))
        d1Feedback = addDynamicInfo("实机点字段=numberPad 数字键盘；输入=掩码点随位递增（密文）；非数字（含粘贴）一律不进入；满 6 位自动 onComplete。", color: AppColor.textSecondary)
    }

    // MARK: Demo 2 · 定长 4 位 + 受控外部驱动（外部预填 1234）

    private func buildDemo2() {
        addSection(title: "Demo 2 · 定长 4 位 + 受控外部驱动（length=4 · 外部预填 1234）") { container in
            let sp = ShortPasswordView(
                value: "1234",
                length: 4,
                onChange: { [weak self] v in
                    self?.emit(self?.d2Feedback, "onChange → \(v.count)/4 位")
                },
                onComplete: { [weak self] v in
                    self?.emit(self?.d2Feedback, "onComplete → \(v)（4 位已满=仅键盘输入路径触发）")
                }
            )
            d2SP = sp
            attach(sp, into: container)
        }
        demoButtonRow(("清空重输", { [weak self] in
            guard let self else { return }
            self.d2SP?.value = ""
            self.emit(self.d2Feedback, "外部 value=\"\"=清空重输", color: AppColor.textSecondary)
        }))
        d2Feedback = addDynamicInfo("外部预填 4 位=同步回显满位但不触发 onComplete（证仅输入路径触发）；清空后键盘重输满 4 位将触发。", color: AppColor.textSecondary)
    }

    // MARK: Demo 3 · 禁用与粘贴过滤

    private func buildDemo3() {
        addSection(title: "Demo 3 · 禁用与粘贴过滤") { container in
            let sp = ShortPasswordView(
                onChange: { [weak self] v in
                    self?.emit(self?.d3Feedback, "onChange → \(v.count)/6 位（禁用无回调）")
                }
            )
            d3SP = sp
            attach(sp, into: container)
        }
        demoButtonRow(("禁用 / 启用", { [weak self] in
            guard let self, let sp = self.d3SP else { return }
            sp.disabled.toggle()
            let text = sp.disabled ? "已禁用：整行 40% 灰、不可输入、无任何回调" : "已启用（可输入）"
            self.emit(self.d3Feedback, text, color: sp.disabled ? AppColor.textSecondary : AppColor.primary)
        }))
        d3Feedback = addDynamicInfo("disabled=整行 40% 灰不可输入无回调；粘贴「ab3#9x」=仅取数字按位截断（39）并入（实机验证非数字不进入）。", color: AppColor.textSecondary)
    }

    // MARK: Demo 4 · 宿主校验流程 + NumberKeyboard #32 组装示意

    private func buildDemo4() {
        addSection(title: "Demo 4 · 宿主校验流程（正确码 123456）+ NumberKeyboard #32 组装示意") { container in
            let sp = ShortPasswordView(
                length: 6,
                onChange: { [weak self] v in
                    self?.emit(self?.d4Feedback, "onChange → \(v.count)/6 位")
                },
                onComplete: { [weak self] v in
                    guard let self else { return }
                    if v == "123456" {
                        self.emit(self.d4Feedback, "onComplete → \(v)：校验通过 ✓")
                    } else {
                        self.emit(self.d4Feedback, "onComplete → \(v)：错误码，宿主自动清空重输（外部 value=\"\"）")
                        self.d4SP?.value = ""
                    }
                }
            )
            d4SP = sp
            attach(sp, into: container)
        }
        demoButtonRow(
            ("外部注入 999999", { [weak self] in
                guard let self else { return }
                self.d4SP?.value = "999999"
                self.emit(self.d4Feedback, "外部注入 999999=满位仅回显（证外部不触发 onComplete）；真实错误触发请软键盘输满 6 位（onComplete→宿主校验失败→自动清空）。", color: AppColor.textSecondary)
            }),
            ("清空重输", { [weak self] in
                guard let self else { return }
                self.d4SP?.value = ""
                self.emit(self.d4Feedback, "外部 value=\"\"=清空重输", color: AppColor.textSecondary)
            })
        )
        d4Feedback = addDynamicInfo("组件可嵌入宿主弹层并与 #32 NumberKeyboard 组装（由键盘回调驱动 value=宿主自理）；满 6 位 onComplete=宿主校验：123456=通过 / 其它=自动清空重输。", color: AppColor.textSecondary)
    }
}

// MARK: - Input Showcase（输入框 · ui.input · #29）

/// 受控单行输入：Demo 1 基础回显/清除钮；Demo 2 键盘类型；Demo 3 密码掩码 + maxLength；
/// Demo 4 禁用 + trailing 尾槽 + 外部赋值。与 Android InputDemo 4 段 1:1 同构。
final class InputShowcase: ShowcaseViewController {
    private var d1Feedback: UILabel?
    private var d3Feedback: UILabel?
    private var d4Feedback: UILabel?
    private var d4Input: InputView?
    private var d4DisableTarget: InputView?

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Input", version: "v1.0", builtAt: "2026-09-06")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    private func buildDemo1() {
        addSection(title: "Demo 1 · 基础输入（受控 · 清除钮 · 回显）") { container in
            let input = InputView(value: "", placeholder: "请输入昵称（实时直通 onTextChange）") { [weak self] text in
                guard let self else { return }
                self.d1Feedback?.text = text.isEmpty
                    ? "onTextChange → 空串（清除钮点击回传 \"\"）"
                    : "onTextChange → \(text)"
                self.d1Feedback?.textColor = AppColor.primary
            }
            pinFullWidth(input, in: container)
            container.snp.makeConstraints { $0.bottom.equalTo(input.snp.bottom) }
        }
        d1Feedback = addDynamicInfo("受控 value + onTextChange 直通；非空即显示清除钮（点击回传空串）。", color: AppColor.textSecondary)
    }

    private func buildDemo2() {
        addSection(title: "Demo 2 · 键盘类型（number / phone / email）") { container in
            let num = InputView(value: "", placeholder: "数字键盘：请输入购买数量", keyboard: "number")
            let phone = InputView(value: "", placeholder: "电话键盘：请输入手机号", keyboard: "phone")
            let email = InputView(value: "", placeholder: "邮箱键盘：请输入邮箱", keyboard: "email")
            pinFullWidth(num, in: container)
            pinFullWidth(phone, in: container, after: num)
            pinFullWidth(email, in: container, after: phone)
            container.snp.makeConstraints { $0.bottom.equalTo(email.snp.bottom) }
        }
        _ = addDynamicInfo("聚焦实机可见对应键盘：number=数字、phone=电话、email=邮箱；placeholder 灰字。", color: AppColor.textSecondary)
    }

    private func buildDemo3() {
        addSection(title: "Demo 3 · 密码掩码 + maxLength=6 截断") { container in
            let pwd = InputView(value: "", placeholder: "登录密码（secure 掩码，回调仍传原文）", secure: true) { [weak self] text in
                guard let self else { return }
                self.d3Feedback?.text = "secure 回调原文 → \(text.isEmpty ? "（空）" : text)"
                self.d3Feedback?.textColor = AppColor.primary
            }
            let code = InputView(value: "", placeholder: "优惠券码（最多 6 位，超长截断）", maxLength: 6)
            pinFullWidth(pwd, in: container)
            pinFullWidth(code, in: container, after: pwd)
            container.snp.makeConstraints { $0.bottom.equalTo(code.snp.bottom) }
        }
        d3Feedback = addDynamicInfo("secure=视觉掩码、onTextChange 仍传原文（一期无显隐切换钮）；maxLength 仅输入路径截断。", color: AppColor.textSecondary)
    }

    private func buildDemo4() {
        addSection(title: "Demo 4 · 禁用 + trailing 尾槽 + 外部赋值（半受控）") { container in
            let amount = InputView(value: "", placeholder: "金额（trailing 尾槽=元）", keyboard: "number", trailing: unitLabel("元"))
            let external = InputView(value: "") { [weak self] text in
                guard let self else { return }
                self.d4Feedback?.text = "onTextChange → \(text.isEmpty ? "（空）" : text)"
                self.d4Feedback?.textColor = AppColor.primary
            }
            d4Input = external
            d4DisableTarget = amount
            pinFullWidth(amount, in: container)
            pinFullWidth(external, in: container, after: amount)
            container.snp.makeConstraints { $0.bottom.equalTo(external.snp.bottom) }
        }
        demoButtonRow(
            ("外部赋值：你好 Native", { [weak self] in
                guard let self, let input = self.d4Input else { return }
                input.value = "你好 Native"
                self.d4Feedback?.text = "外部 value 赋值=同步回显（半受控不触发 onChange）"
                self.d4Feedback?.textColor = AppColor.textSecondary
            }),
            ("禁用 / 启用首行", { [weak self] in
                guard let self, let input = self.d4DisableTarget else { return }
                input.disabled.toggle()
                self.d4Feedback?.text = input.disabled ? "首行已禁用：40% 置灰、清除钮隐藏、不可编辑" : "首行已启用"
                self.d4Feedback?.textColor = input.disabled ? AppColor.textSecondary : AppColor.primary
            })
        )
        d4Feedback = addDynamicInfo("trailing=宿主尾槽（本例「元」）；disabled 40% 置灰；外部 value 赋值仅同步显示。", color: AppColor.textSecondary)
    }

    /// 「元」尾槽标签。
    private func unitLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        label.textColor = AppColor.textSecondary
        label.sizeToFit()
        return label
    }
}

// MARK: - Demo 通用：外部驱动按钮行（contentStack 独立行，等价 Android Row spacedBy + TextButton）

private extension ShowcaseViewController {
    func demoButtonRow(_ items: (String, () -> Void)...) {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = AppSpace.sm
        row.distribution = .fillEqually
        for (title, action) in items {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
            button.setTitleColor(AppColor.primary, for: .normal)
            button.backgroundColor = AppColor.primaryMuted
            button.layer.cornerRadius = AppRadius.sm
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
            button.addAction(UIAction { _ in action() }, for: .touchUpInside)
            row.addArrangedSubview(button)
        }
        contentStack.addArrangedSubview(row)
    }

    /// 整宽行：先入容器再 leading/trailing 内缩 lg 铺满（Input/CheckboxGroup 等占满容器宽的组件）。
    /// 必须先 addSubview 再建约束：SnapKit equalToSuperview 依赖已有 superview，
    /// 缺 addSubview 会在运行期 fatal "Expected superview but found nil"。
    func pinFullWidth(_ view: UIView, in container: UIView, after previous: UIView? = nil) {
        container.addSubview(view)
        view.snp.makeConstraints { make in
            if let previous {
                make.top.equalTo(previous.snp.bottom).offset(AppSpace.md)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
        }
    }
}

/// NumberKeyboard 数字键盘 Demo（任务清单 #32，验证组件库 v1.4.0，demo 徽标 v1.0）。
/// D1 金额录入（底行首格 .）/ D2 短信验证码（纯整数限 6 位，showDot=false 首格空占位）/
/// D3 身份证（extraKey="X" 底键上屏，限 18 位）/ D4 禁用态 + 确认列外部驱动。
final class NumberKeyboardShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "NumberKeyboard 数字键盘", version: "v1.0", builtAt: "2026-09-06")
        addInfo("内嵌式数字键盘面板：4 行×4 列键格（1~9 + 底行/0/删除 + 右列确认竖条），纯事件回调零状态，值由宿主持有。")
        addInfo("禁用：disabled=整键盘 40% 灰不可点；confirmDisabled=仅确认列灰不可点。")

        // D1 金额录入（小数 + 确认置灰）
        addSection(title: "Demo 1 · 金额录入") { container in
            let field = NumberKeyboardShowcase.makeField()
            self.pinFullWidth(field, in: container)
            field.snp.makeConstraints { $0.height.equalTo(56) }

            var value = "" {
                didSet { field.text = value.isEmpty ? "¥0" : "¥\(value)" }
            }
            value = ""
            var keyboard: NumberKeyboardView!
            keyboard = NumberKeyboardView(
                onInput: { ch in
                    guard value.count < 9 else { return }
                    if ch == "." {
                        guard !value.contains("."), !value.isEmpty else { return }
                    }
                    value.append(ch)
                    keyboard.confirmDisabled = value.isEmpty
                },
                onDelete: {
                    if !value.isEmpty { value.removeLast(); keyboard.confirmDisabled = value.isEmpty }
                },
                onConfirm: {
                    keyboard.confirmDisabled = false
                    self.setD1Message("确认金额：¥\(value.isEmpty ? "0" : value)")
                }
            )
            self.pinFullWidth(keyboard, in: container, after: field)
            keyboard.snp.makeConstraints { make in
                make.height.equalTo(208)
                make.bottom.equalToSuperview()
            }
            keyboard.confirmDisabled = true
        }
        feedbackLabel1 = addDynamicInfo("金额输入为 0 或空时「确认」置灰不可点。")

        // D2 短信验证码（纯整数 6 位，无小数点）
        addSection(title: "Demo 2 · 短信验证码（6 位）") { container in
            let field = NumberKeyboardShowcase.makeField()
            self.pinFullWidth(field, in: container)
            field.snp.makeConstraints { $0.height.equalTo(56) }

            var value = "" {
                didSet { field.text = value }
            }
            value = ""
            var keyboard: NumberKeyboardView!
            keyboard = NumberKeyboardView(
                onInput: { ch in
                    guard value.count < 6 else { return }
                    guard ch != "." else { return }
                    value.append(ch)
                    keyboard.confirmDisabled = value.count != 6
                },
                onDelete: {
                    if !value.isEmpty { value.removeLast(); keyboard.confirmDisabled = value.count != 6 }
                },
                onConfirm: {
                    keyboard.confirmDisabled = false
                    self.setD2Message("验证码确认：\(value)")
                },
                showDot: false
            )
            self.pinFullWidth(keyboard, in: container, after: field)
            keyboard.snp.makeConstraints { make in
                make.height.equalTo(208)
                make.bottom.equalToSuperview()
            }
            keyboard.confirmDisabled = true
        }
        feedbackLabel2 = addDynamicInfo("showDot=false → 底行首格空占位；满 6 位确认转 primary。")

        // D3 身份证（extraKey="X"，限 18 位）
        addSection(title: "Demo 3 · 身份证号（18 位，含 X）") { container in
            let field = NumberKeyboardShowcase.makeField()
            self.pinFullWidth(field, in: container)
            field.snp.makeConstraints { $0.height.equalTo(56) }

            var value = "" {
                didSet { field.text = value }
            }
            value = ""
            var keyboard: NumberKeyboardView!
            keyboard = NumberKeyboardView(
                onInput: { ch in
                    guard value.count < 18 else { return }
                    value.append(ch)
                    keyboard.confirmDisabled = value.isEmpty
                },
                onDelete: {
                    if !value.isEmpty { value.removeLast(); keyboard.confirmDisabled = value.isEmpty }
                },
                onConfirm: {
                    keyboard.confirmDisabled = false
                    self.setD3Message("已录入身份证号：\(value)（共 \(value.count) 位）")
                },
                extraKey: "X"
            )
            self.pinFullWidth(keyboard, in: container, after: field)
            keyboard.snp.makeConstraints { make in
                make.height.equalTo(208)
                make.bottom.equalToSuperview()
            }
            keyboard.confirmDisabled = true
        }
        feedbackLabel3 = addDynamicInfo("extraKey=\"X\" 替换底行首格，X 与数字同走 onInput。")

        // D4 禁用态 + 确认列外部驱动
        addSection(title: "Demo 4 · 禁用态 + 外部驱动") { container in
            let field = NumberKeyboardShowcase.makeField()
            self.pinFullWidth(field, in: container)
            field.snp.makeConstraints { $0.height.equalTo(56) }

            var value = "" {
                didSet { field.text = value.isEmpty ? "135****4737" : value }
            }
            value = ""
            var keyboard: NumberKeyboardView!
            keyboard = NumberKeyboardView(
                onInput: { ch in
                    guard value.count < 11 else { return }
                    if ch == "." { return }
                    value.append(ch)
                },
                onDelete: {
                    if !value.isEmpty { value.removeLast() }
                },
                onConfirm: {
                    keyboard.confirmDisabled = false
                    self.setD4Message("确认：\(value.isEmpty ? "135****4737" : value)")
                }
            )
            self.pinFullWidth(keyboard, in: container, after: field)

            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = AppSpace.sm
            row.distribution = .fillEqually
            let disableButton = UIButton(type: .system)
            disableButton.setTitle("禁用键盘", for: .normal)
            disableButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            disableButton.addAction(UIAction { [weak disableButton] _ in
                keyboard.disabled.toggle()
                disableButton?.setTitle(keyboard.disabled ? "启用键盘" : "禁用键盘", for: .normal)
            }, for: .touchUpInside)
            let confirmButton = UIButton(type: .system)
            confirmButton.setTitle("确认列置灰", for: .normal)
            confirmButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            confirmButton.addAction(UIAction { [weak confirmButton] _ in
                keyboard.confirmDisabled.toggle()
                confirmButton?.setTitle(keyboard.confirmDisabled ? "确认列恢复" : "确认列置灰", for: .normal)
            }, for: .touchUpInside)
            row.addArrangedSubview(disableButton)
            row.addArrangedSubview(confirmButton)
            self.pinFullWidth(row, in: container, after: keyboard)
            row.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
        }
        feedbackLabel4 = addDynamicInfo("disabled=整键盘 40% 灰不可点；confirmDisabled=仅确认列灰（其余键可用）。")
    }

    private func setD1Message(_ text: String) { feedbackText1 = text }
    private func setD2Message(_ text: String) { feedbackText2 = text }
    private func setD3Message(_ text: String) { feedbackText3 = text }
    private func setD4Message(_ text: String) { feedbackText4 = text }
    private var feedbackText1 = "" { didSet { if !feedbackText1.isEmpty { feedbackLabel1?.text = feedbackText1 } } }
    private var feedbackText2 = "" { didSet { if !feedbackText2.isEmpty { feedbackLabel2?.text = feedbackText2 } } }
    private var feedbackText3 = "" { didSet { if !feedbackText3.isEmpty { feedbackLabel3?.text = feedbackText3 } } }
    private var feedbackText4 = "" { didSet { if !feedbackText4.isEmpty { feedbackLabel4?.text = feedbackText4 } } }
    private var feedbackLabel1: UILabel?
    private var feedbackLabel2: UILabel?
    private var feedbackLabel3: UILabel?
    private var feedbackLabel4: UILabel?

    private static func makeField() -> UILabel {
        let label = UILabel()
        label.backgroundColor = AppColor.bgCard
        label.textColor = AppColor.textPrimary
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }
}


// MARK: - Picker 选择器（ui.picker #33）

/// 宿主弹层载体（Demo D4）：系统 pageSheet 承载 Picker 内容块（弹层机制=宿主职责，组件无遮罩无自绘浮层）
private final class PickerSheetHostViewController: UIViewController {
    private let options: [PickerOption]
    private let initialValue: String
    private let sheetTitle: String
    private let onSelect: ((String) -> Void)?

    init(options: [PickerOption], value: String, title: String, onSelect: @escaping (String) -> Void) {
        self.options = options
        self.initialValue = value
        self.sheetTitle = title
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) 未支持") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgCard
        let picker = PickerView(
            options: options,
            value: initialValue,
            title: sheetTitle,
            onChange: { [weak self] v in
                self?.dismiss(animated: true) { self?.onSelect?(v) }
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16)
        ])
    }
}

final class PickerShowcase: ShowcaseViewController {
    private let payOptions: [PickerOption] = [
        PickerOption(value: "wechat", text: "微信支付"),
        PickerOption(value: "alipay", text: "支付宝"),
        PickerOption(value: "bank", text: "银行卡"),
        PickerOption(value: "cash", text: "现金")
    ]
    private let ledgers: [PickerOption] = [
        PickerOption(value: "all", text: "全部"),
        PickerOption(value: "home", text: "家庭账本"),
        PickerOption(value: "trip", text: "旅行账本"),
        PickerOption(value: "decor", text: "装修账本"),
        PickerOption(value: "food", text: "餐饮账本"),
        PickerOption(value: "daily", text: "日用账本"),
        PickerOption(value: "trans", text: "交通账本"),
        PickerOption(value: "medical", text: "医疗账本"),
        PickerOption(value: "edu", text: "教育账本"),
        PickerOption(value: "fun", text: "娱乐账本"),
        PickerOption(value: "social", text: "人情账本"),
        PickerOption(value: "deleted", text: "删除的账本", disabled: true)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "Picker 选择器", version: "v1.0", builtAt: "2026-09-06")
        addInfo("单列滚轮选择器内容块=工具栏 44（取消/标题/确定）+滚轮 220=5 行×44；受控 value 初始滚停+外部回滚定位；确定=onChange、取消=滚回 value 行不回调（宿主依 onCancel 自理关闭）。")
        addInfo("选项 disabled：行灰 40% 且滚掠不可停靠（自动吸附最近可用行）；与 Menu（平铺下拉）/Cascader（级联）划界。")

        // D1 单列基础（确定提交 / 取消不提交）
        addSection(title: "Demo 1 · 单列基础（确定提交 / 取消不提交）") { container in
            var current = "alipay"
            let picker = PickerView(
                options: self.payOptions,
                value: current,
                title: "付款方式",
                onChange: { [weak self] v in
                    current = v
                    self?.setD1Message("确定 → \(self?.label(of: self!.payOptions, value: v) ?? v)（value 受控同步）")
                }
            )
            picker.backgroundColor = AppColor.bgCard
            self.pinFullWidth(picker, in: container)
            picker.snp.makeConstraints { $0.bottom.equalToSuperview() }
        }
        feedbackLabel1 = addDynamicInfo("初始支付宝居中高亮：滚轮改选→「确定」回调回显并保持选中；点「取消」滚回 value 行不回调。")

        // D2 长列表 + 选项禁用（掠行不可停靠）
        addSection(title: "Demo 2 · 长列表 + 选项禁用（掠行不可停靠）") { container in
            var current = "all"
            let picker = PickerView(
                options: self.ledgers,
                value: current,
                title: "选择账本",
                onChange: { [weak self] v in
                    current = v
                    self?.setD2Message("确定 → \(self?.label(of: self!.ledgers, value: v) ?? v)")
                }
            )
            picker.backgroundColor = AppColor.bgCard
            self.pinFullWidth(picker, in: container)
            picker.snp.makeConstraints { $0.bottom.equalToSuperview() }
        }
        feedbackLabel2 = addDynamicInfo("12 项滚动；末项「删除的账本」灰显滚掠不可停靠（停靠自动吸附最近可用行）。")

        // D3 受控外部驱动（外部 value 回滚定位）
        addSection(title: "Demo 3 · 受控外部驱动（外部 value 回滚定位）") { container in
            var current = "bank"
            let picker = PickerView(
                options: self.payOptions,
                value: current,
                title: "付款方式",
                onChange: { [weak self] v in
                    current = v
                    self?.setD3Message("确定 → \(self?.label(of: self!.payOptions, value: v) ?? v)（内部确认路径正常）")
                }
            )
            picker.backgroundColor = AppColor.bgCard
            self.pinFullWidth(picker, in: container)

            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = AppSpace.xs
            row.distribution = .fillEqually
            let toCash = UIButton(type: .system)
            toCash.setTitle("外部回显：现金", for: .normal)
            toCash.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
            toCash.addAction(UIAction { _ in current = "cash"; picker.value = "cash" }, for: .touchUpInside)
            let toWechat = UIButton(type: .system)
            toWechat.setTitle("外部回显：微信支付", for: .normal)
            toWechat.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
            toWechat.addAction(UIAction { _ in current = "wechat"; picker.value = "wechat" }, for: .touchUpInside)
            row.addArrangedSubview(toCash)
            row.addArrangedSubview(toWechat)
            self.pinFullWidth(row, in: container, after: picker)
            row.snp.makeConstraints { $0.bottom.equalToSuperview() }
        }
        feedbackLabel3 = addDynamicInfo("外部 set value → 滚轮 animate 定位对应行并高亮（不触发 onChange）；「确定」仍走内部确认。")

        // D4 宿主 sheet 弹层用法（系统承载内容块）
        addSection(title: "Demo 4 · 宿主 sheet 弹层用法（系统承载内容块）") { container in
            var current = "cash"
            let open = UIButton(type: .system)
            open.setTitle("打开选择支付方式（pageSheet）", for: .normal)
            open.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
            open.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                let host = PickerSheetHostViewController(
                    options: self.payOptions,
                    value: current,
                    title: "选择支付方式"
                ) { v in
                    current = v
                    self.setD4Message("已选：\(self.label(of: self.payOptions, value: v))")
                }
                host.modalPresentationStyle = .pageSheet
                if let sheet = host.sheetPresentationController {
                    sheet.detents = [.custom(resolver: { _ in 300 })]
                    sheet.prefersGrabberVisible = true
                }
                self.present(host, animated: true)
            }, for: .touchUpInside)
            self.pinFullWidth(open, in: container)
            open.snp.makeConstraints { $0.bottom.equalToSuperview() }
        }
        feedbackLabel4 = addDynamicInfo("弹层机制=宿主职责：本组件无遮罩无自绘浮层，host 用系统 sheet 承载内容块，确定/取消按回调自理关闭。")
    }

    private func label(of options: [PickerOption], value: String) -> String {
        options.first(where: { $0.value == value })?.text ?? value
    }

    private func setD1Message(_ text: String) { feedbackText1 = text }
    private func setD2Message(_ text: String) { feedbackText2 = text }
    private func setD3Message(_ text: String) { feedbackText3 = text }
    private func setD4Message(_ text: String) { feedbackText4 = text }
    private var feedbackText1 = "" { didSet { if !feedbackText1.isEmpty { feedbackLabel1?.text = feedbackText1 } } }
    private var feedbackText2 = "" { didSet { if !feedbackText2.isEmpty { feedbackLabel2?.text = feedbackText2 } } }
    private var feedbackText3 = "" { didSet { if !feedbackText3.isEmpty { feedbackLabel3?.text = feedbackText3 } } }
    private var feedbackText4 = "" { didSet { if !feedbackText4.isEmpty { feedbackLabel4?.text = feedbackText4 } } }
    private var feedbackLabel1: UILabel?
    private var feedbackLabel2: UILabel?
    private var feedbackLabel3: UILabel?
    private var feedbackLabel4: UILabel?
}
