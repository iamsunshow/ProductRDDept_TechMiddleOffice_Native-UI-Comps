/// SafeAreaView 安全区避让容器：把内容限制在系统安全区（刘海/状态栏/圆角/Home Indicator/手势区）之内。
///
/// 组件 ID：`ui.safe-area`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-04，
/// 用户"中间任何询问直接通过"总授权；P1–P4 全 A：容器式 + edges 四边可配默认全边 +
/// iOS safeAreaInsets 实时值零硬编码）。
///
/// 一期语义：
/// - [addContent] 的内容自动贴安全区四边排布（避让数值取系统实时 insets，机型自适应）
/// - [edges] 决定避让哪些边（默认四边全避）；未避让的边内容直接铺满容器
/// - 容器 pass-through：透明零绘制零背景，装饰由内容承担
///
/// 用法：
/// ```swift
/// let safe = SafeAreaView(edges: [.top, .bottom])
/// safe.addContent(页面内容)
/// ```
import UIKit
import SnapKit

/// 安全区避让容器（对应 Android SafeArea / Compose Box + windowInsetsPadding）。
final class SafeAreaView: UIView {

    /// 避让边（P2 全 A：四边可配，默认全边）。
    struct Edge: OptionSet {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }

        static let top = Edge(rawValue: 1 << 0)
        static let bottom = Edge(rawValue: 1 << 1)
        static let left = Edge(rawValue: 1 << 2)
        static let right = Edge(rawValue: 1 << 3)
        static let all: Edge = [.top, .bottom, .left, .right]
    }

    /// 当前避让边集合（一期创建后不可变；如需动态切换 edges 用新容器替换）。
    private let edges: Edge

    /// 内部内容宿主：四边按 [edges] 锚定到自身 safeAreaLayoutGuide 或容器边缘。
    private let contentHost = UIView()

    init(edges: Edge = .all) {
        self.edges = edges
        super.init(frame: .zero)
        backgroundColor = .clear
        contentHost.backgroundColor = .clear
        addSubview(contentHost)
        contentHost.snp.makeConstraints { make in
            make.top.equalTo(edges.contains(.top) ? safeAreaLayoutGuide.snp.top : self.snp.top)
            make.bottom.equalTo(edges.contains(.bottom) ? safeAreaLayoutGuide.snp.bottom : self.snp.bottom)
            make.leading.equalTo(edges.contains(.left) ? safeAreaLayoutGuide.snp.leading : self.snp.leading)
            make.trailing.equalTo(edges.contains(.right) ? safeAreaLayoutGuide.snp.trailing : self.snp.trailing)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SafeAreaView 不支持 initWithCoder 解码，请使用 init(edges:)。")
    }

    /// 添加需要避让的内容（自动铺满安全区容器）。
    func addContent(_ view: UIView) {
        contentHost.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
