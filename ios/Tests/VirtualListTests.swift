/// VirtualList 虚拟列表 · 组件测试
///
/// 验证组件库版本：v1.8.2（契约 `docs/数据与产物/api.json` `ui.virtual-list`）。
/// 用例覆盖 1 个历史根因（2026-09-12 调试复盘）：
///   根因1 (#66): items.didSet 只调 tableView.reloadData() 不调 updateEmpty()——
///     setup() 时 items=[] → updateEmpty() 设 tableView.isHidden=true、emptyLabel.isHidden=false；
///     Demo 设 items 后 didSet 只 reload 不刷 hidden，tableView 仍被隐藏、emptyLabel 仍可见。
///
/// 测试策略：tableView/emptyLabel 是 private，@testable import 不能跨 private；
/// 通过遍历 subviews 按类型识别（UILabel=emptyLabel，UITableView=tableView）检查 isHidden
/// 间接验证 updateEmpty 是否被调用——items 非空后 tableView 仍 isHidden=true 即失败。
///
/// 注意：#65（Demo centerY+height 约束不撑 container 高度）是 Demo 代码约束写法问题，
/// 非组件库 bug，组件本身功能正常，单测无法覆盖，只能靠 UI 实机验收。

import UIKit
import XCTest
@testable import TMONativeUIComps

final class VirtualListTests: XCTestCase {

    // MARK: - Helper

    /// 在 subviews 中按类型查找第一个匹配的子视图
    private func findFirst<T: UIView>(_ type: T.Type, in view: UIView) -> T? {
        for sub in view.subviews {
            if let typed = sub as? T { return typed }
        }
        return nil
    }

    // MARK: - 根因1 (#66): items.didSet 不刷 hidden 状态（核心回归用例）

    /// 验证：初始 items=[] 时 tableView 应隐藏、emptyLabel 应可见
    /// 历史 bug 反例：若 setup 的 updateEmpty 没被调用，初始状态就错乱
    func test_初始空态_tableView隐藏且emptyLabel可见() {
        let list = VirtualListView()
        let tableView = findFirst(UITableView.self, in: list)
        let emptyLabel = findFirst(UILabel.self, in: list)

        XCTAssertNotNil(tableView, "必须包含 UITableView")
        XCTAssertNotNil(emptyLabel, "必须包含 UILabel（空态）")
        XCTAssertTrue(tableView!.isHidden, "items=[] 时 tableView 应隐藏")
        XCTAssertFalse(emptyLabel!.isHidden, "items=[] 时 emptyLabel 应可见")
    }

    /// 验证：设 items 非空后 tableView 应可见、emptyLabel 应隐藏（#66 回归点）
    /// 历史 bug：items.didSet 只调 tableView.reloadData()，未调 updateEmpty()
    /// → tableView.isHidden 仍为 true，列表被隐藏看不到数据行
    func test_items赋值后_tableView可见且emptyLabel隐藏() {
        let list = VirtualListView()
        // 赋值 100 条——触发 didSet
        list.items = (1...100).map { VirtualListItem(title: "项目 #\($0)") }

        let tableView = findFirst(UITableView.self, in: list)
        let emptyLabel = findFirst(UILabel.self, in: list)

        XCTAssertFalse(tableView!.isHidden, "items 非空后 tableView 应可见（#66 回归点——didSet 必须调 updateEmpty 刷 hidden）")
        XCTAssertTrue(emptyLabel!.isHidden, "items 非空后 emptyLabel 应隐藏")
    }

    /// 验证：items 从非空再置空后状态应反向切换（防止 didSet 只刷一次的边角）
    func test_items从非空置空_tableView应隐藏且emptyLabel应可见() {
        let list = VirtualListView()
        list.items = (1...50).map { VirtualListItem(title: "项目 #\($0)") }
        // 再置空——触发 didSet 反向切换
        list.items = []

        let tableView = findFirst(UITableView.self, in: list)
        let emptyLabel = findFirst(UILabel.self, in: list)

        XCTAssertTrue(tableView!.isHidden, "items 再置空后 tableView 应隐藏")
        XCTAssertFalse(emptyLabel!.isHidden, "items 再置空后 emptyLabel 应可见")
    }

    // MARK: - 数据源契约

    /// 验证：UITableViewDataSource numberOfRowsInSection 返回 items.count
    func test_数据源行数等于items数量() {
        let list = VirtualListView()
        list.items = (1...30).map { VirtualListItem(title: "通知 #\($0)") }

        let tableView = findFirst(UITableView.self, in: list)!
        let rows = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? -1

        XCTAssertEqual(rows, 30, "numberOfRowsInSection 必须返回 items.count=30")
    }
}
