import UIKit
import SnapKit

// MARK: - BarChart Showcase（业务展示区 · #97 · ui.bar-chart 条形图 Demo 页）
//
// 4 段排查：D1 基础 5 类别 / D2 阈值切换（60/85/110）/ D3 7 类别 Top 排行 / D4 重置动画
/// （外部按钮重设 value 触发 0.3s ease-out 过渡）。双端 1:1
///（iOS BarChartView vs Android BarChart @Composable）。
final class BarChartShowcase: ShowcaseViewController {

    private let chart1 = BarChartView()
    private let chart2 = BarChartView()
    private let chart3 = BarChartView()
    private let chart4 = BarChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "BarChart", version: "v1.0", builtAt: "2026-09-16")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · 基础 5 类别
    private func buildDemo1() {
        addSection(title: "D1 · 基础 5 类别（餐饮/交通/购物/娱乐/其他）") { container in
            chart1.items = [
                BarChartItem(label: "餐饮", value: 800),
                BarChartItem(label: "交通", value: 500),
                BarChartItem(label: "购物", value: 1200),
                BarChartItem(label: "娱乐", value: 300),
                BarChartItem(label: "其他", value: 600),
            ]
            container.addSubview(chart1)
            chart1.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                // 底部闭合段容器高度链（否则容器高 0、内容溢出盖住下一段标题）；
                // 组件 height 走 BarChartView.intrinsicContentSize（5 行 × 24 + 4 × 12 = 168）。
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
        }
        addInfo("maxValue 自动 = 1200；按比例 primary 填充 + 数值标签 sizeSm=14 Semibold。")
    }

    // D2 · 阈值切换（0.6/0.85/1.10）
    private func buildDemo2() {
        addSection(title: "D2 · 阈值切换（warnThreshold=0.8/dangerThreshold=1.0）") { container in
            chart2.items = [
                BarChartItem(label: "餐饮", value: 240),
                BarChartItem(label: "交通", value: 180),
                BarChartItem(label: "购物", value: 320),
                BarChartItem(label: "娱乐", value: 100),
                BarChartItem(label: "其他", value: 200),
            ]
            chart2.warnThreshold = 0.8
            chart2.dangerThreshold = 1.0
            container.addSubview(chart2)
            chart2.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
        }
        addInfo("maxValue=320 → 240/320=75% primary / 320/320=100% error；阈值按 value/maxValue 比例切换。")
    }

    // D3 · 7 类别 Top 排行
    private func buildDemo3() {
        addSection(title: "D3 · 7 类别 Top 排行（降序）") { container in
            chart3.items = [
                BarChartItem(label: "餐饮", value: 1000),
                BarChartItem(label: "交通", value: 800),
                BarChartItem(label: "购物", value: 600),
                BarChartItem(label: "娱乐", value: 500),
                BarChartItem(label: "其他", value: 400),
                BarChartItem(label: "医疗", value: 300),
                BarChartItem(label: "教育", value: 200),
            ]
            container.addSubview(chart3)
            chart3.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
        }
        addInfo("7 项多类别渲染 + 等高对齐 + 数值标签。")
    }

    // D4 · 0.3s 过渡（外部按钮重设 value 触发）
    private func buildDemo4() {
        addSection(title: "D4 · 0.3s 过渡（外部按钮重置 items）") { container in
            chart4.items = [
                BarChartItem(label: "餐饮", value: 100),
                BarChartItem(label: "交通", value: 200),
                BarChartItem(label: "购物", value: 300),
                BarChartItem(label: "娱乐", value: 150),
                BarChartItem(label: "其他", value: 250),
            ]
            container.addSubview(chart4)
            chart4.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
            }
            let btn = UIButton(type: .system)
            btn.setTitle("重置动画", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            btn.setTitleColor(AppColor.primary, for: .normal)
            container.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.equalTo(chart4.snp.bottom).offset(AppSpace.sm)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(36)
                // 末元素闭合段容器高度链（按钮为容器内最后一个子视图）
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
            btn.addAction(UIAction { [weak chart4] _ in
                // 重置 items 触发 didSet → rebuild + 0.3s 过渡
                chart4?.items = [
                    BarChartItem(label: "餐饮", value: 500),
                    BarChartItem(label: "交通", value: 100),
                    BarChartItem(label: "购物", value: 800),
                    BarChartItem(label: "娱乐", value: 200),
                    BarChartItem(label: "其他", value: 400),
                ]
            }, for: .touchUpInside)
        }
        addInfo("items didSet 触发 rebuild + UIView.animate withDuration 0.3s curveEaseOut 过渡。")
    }
}