// MARK: - ShortcutBar Showcase（信息展示区 · #82 · ui.shortcut-bar 快捷栏 Demo 页）
//
// 4 段排查：D1 基础 4 列快捷入口 / D2 5 列扩展 + 长文本省略 / D3 6 列超长横滚 /
/// D4 受控外部驱动（外部 disabled 锁定 + onClick 反馈）。双端 1:1
///（iOS ShortcutBarView vs Android ShortcutBar @Composable）。
final class ShortcutBarShowcase: ShowcaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "ShortcutBar", version: "v1.0", builtAt: "2026-09-16")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · 基础 4 列快捷入口（点击计数）
    private func buildDemo1() {
        addSection(title: "D1 · 基础 4 列快捷入口（点击回调 id）") { container in
            let feedback = addDynamicInfo("4 等分 entry，点击图标返回 entry id；4 列以内等分布局。")
            let bar = ShortcutBarView()
            bar.apply(items: [
                ShortcutBarItem(id: "ledger", icon: "plus.circle", text: "记一笔"),
                ShortcutBarItem(id: "budget", icon: "chart.pie", text: "预算"),
                ShortcutBarItem(id: "report", icon: "chart.bar", text: "报表"),
                ShortcutBarItem(id: "assets", icon: "creditcard", text: "资产"),
            ], columns: 4)
            container.addSubview(bar)
            bar.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(72)
            }
            bar.onClick = { id in
                feedback.text = "D1 点击 entry id: \(id)"
                feedback.textColor = AppColor.primary
            }
        }
        addInfo("基础 4 等分 + 图标 26×26 primary 圆角 6 + 文本 sizeXs=12 textPrimary 单行省略 + 点击命中整 entry 透明 + 灰底按压态。")
    }

    // D2 · 5 列扩展 + 长文本省略
    private func buildDemo2() {
        addSection(title: "D2 · 5 列扩展 + 长文本省略") { container in
            let feedback = addDynamicInfo("5 列等分；第 5 项文本超长触发单行省略（…）。")
            let bar = ShortcutBarView()
            bar.apply(items: [
                ShortcutBarItem(id: "a", icon: "doc.text", text: "明细"),
                ShortcutBarItem(id: "b", icon: "tag", text: "分类"),
                ShortcutBarItem(id: "c", icon: "person", text: "账户"),
                ShortcutBarItem(id: "d", icon: "creditcard", text: "银行卡"),
                ShortcutBarItem(id: "e", icon: "ellipsis.circle", text: "更多更多更多"),
            ], columns: 5)
            container.addSubview(bar)
            bar.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(72)
            }
            bar.onClick = { id in
                feedback.text = "D2 点击 entry id: \(id)"
                feedback.textColor = AppColor.primary
            }
        }
        addInfo("5 列扩展走 columns=5；超长文本 sizeXs=12 byTruncatingTail 单行省略（…）。")
    }

    // D3 · 6 列超长横滚
    private func buildDemo3() {
        addSection(title: "D3 · 6 列超长横滚") { container in
            let feedback = addDynamicInfo("6 entries 超过默认 4 列阈值，自动启用横向滚动。")
            let bar = ShortcutBarView()
            bar.apply(items: [
                ShortcutBarItem(id: "1", icon: "1.circle", text: "项目一"),
                ShortcutBarItem(id: "2", icon: "2.circle", text: "项目二"),
                ShortcutBarItem(id: "3", icon: "3.circle", text: "项目三"),
                ShortcutBarItem(id: "4", icon: "4.circle", text: "项目四"),
                ShortcutBarItem(id: "5", icon: "5.circle", text: "项目五"),
                ShortcutBarItem(id: "6", icon: "6.circle", text: "项目六"),
            ], columns: 4)
            container.addSubview(bar)
            bar.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(72)
            }
            bar.onClick = { id in
                feedback.text = "D3 点击 entry id: \(id)（可横滚查看更多）"
                feedback.textColor = AppColor.primary
            }
        }
        addInfo("超长 entries 走 UIScrollView 横向滚动；>columns 项数不截断，可视即可触达。")
    }

    // D4 · 受控外部 disabled + onClick 反馈回写
    private func buildDemo4() {
        addSection(title: "D4 · 受控外部 disabled 切换") { container in
            let feedback = addDynamicInfo("外部 disable 切换钮：锁定/解锁 4 entry 整条点击。")
            let bar = ShortcutBarView()
            bar.isUserInteractionEnabled = true
            bar.apply(items: [
                ShortcutBarItem(id: "x", icon: "trash", text: "删除"),
                ShortcutBarItem(id: "y", icon: "pencil", text: "编辑"),
                ShortcutBarItem(id: "z", icon: "square.and.arrow.up", text: "分享"),
                ShortcutBarItem(id: "w", icon: "star", text: "收藏"),
            ], columns: 4)
            container.addSubview(bar)
            bar.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(72)
            }
            bar.onClick = { id in
                feedback.text = "D4 点击 entry id: \(id)（未锁定时回调；锁定时不回调）"
                feedback.textColor = AppColor.primary
            }
            let toggle = UIButton(type: .system)
            toggle.setTitle("锁定/解锁", for: .normal)
            toggle.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            toggle.setTitleColor(AppColor.primary, for: .normal)
            container.addSubview(toggle)
            toggle.snp.makeConstraints { make in
                make.top.equalTo(bar.snp.bottom).offset(AppSpace.md)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(36)
            }
            toggle.addAction(UIAction { [weak bar] _ in
                bar?.isUserInteractionEnabled.toggle()
                feedback.text = "D4 锁定状态切换：当前 isUserInteractionEnabled=\(bar?.isUserInteractionEnabled ?? true)"
            }, for: .touchUpInside)
        }
        addInfo("外部 isUserInteractionEnabled 切换锁定整条；锁定时 entry 命中不下钻回调。")
    }
}