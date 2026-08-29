/// 趋势折线图组件（M2.3）：支出/收入双折线。

import UIKit
import SnapKit
import Charts

/// 双色折线图（支出红、收入绿）。
final class TrendChartView: UIView {
    private let chartView = LineChartView()
    private let emptyLabel = UILabel()

    /// 初始化图表与空态布局。
    ///
    /// - Parameter frame: 初始 frame
    /// - Returns: 无
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.labelFont = .systemFont(ofSize: AppFont.sizeXs)
        chartView.leftAxis.labelTextColor = AppColor.textSecondary
        chartView.leftAxis.gridColor = AppColor.border
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelFont = .systemFont(ofSize: AppFont.sizeXs)
        chartView.xAxis.labelTextColor = AppColor.textSecondary
        chartView.xAxis.granularity = 1
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.minOffset = 0

        emptyLabel.text = EmptyStateView.defaultMessage
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = AppColor.textSecondary
        emptyLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        emptyLabel.isHidden = true

        addSubview(chartView)
        addSubview(emptyLabel)
        chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(top: AppSpace.sm, left: AppSpace.md, bottom: AppSpace.sm, right: AppSpace.md)
            )
            make.height.equalTo(140)
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 绑定支出/收入双序列并刷新折线图。
    ///
    /// - Parameters:
    ///   - expensePoints: 支出趋势点
    ///   - incomePoints: 收入趋势点（与支出同标签轴）
    /// - Returns: 无
    func apply(expensePoints: [ChartPoint], incomePoints: [ChartPoint]) {
        let labels = expensePoints.map(\.label).isEmpty ? incomePoints.map(\.label) : expensePoints.map(\.label)
        let count = labels.count
        let hasValue = expensePoints.contains { $0.amount > 0 } || incomePoints.contains { $0.amount > 0 }
        emptyLabel.isHidden = hasValue
        chartView.isHidden = !hasValue
        guard hasValue, count > 0 else {
            chartView.data = nil
            return
        }

        let expenseEntries = (0..<count).map { index in
            let amount = index < expensePoints.count ? expensePoints[index].amount : 0
            return ChartDataEntry(x: Double(index), y: amount)
        }
        let incomeEntries = (0..<count).map { index in
            let amount = index < incomePoints.count ? incomePoints[index].amount : 0
            return ChartDataEntry(x: Double(index), y: amount)
        }

        let expenseSet = makeLineSet(entries: expenseEntries, label: "支出", color: AppColor.expense)
        let incomeSet = makeLineSet(entries: incomeEntries, label: "收入", color: AppColor.primary)

        let data = LineChartData(dataSets: [expenseSet, incomeSet])
        chartView.xAxis.axisMinimum = -0.5
        chartView.xAxis.axisMaximum = Double(count) - 0.5
        chartView.data = data
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chartView.xAxis.labelCount = min(count, 8)
        chartView.notifyDataSetChanged()
        chartView.animate(xAxisDuration: 0.25, yAxisDuration: 0.35)
    }

    /// 配置折线数据集样式。
    private func makeLineSet(entries: [ChartDataEntry], label: String, color: UIColor) -> LineChartDataSet {
        let set = LineChartDataSet(entries: entries, label: label)
        set.colors = [color]
        set.lineWidth = 2
        set.circleColors = [color]
        set.circleHoleColor = .white
        set.circleRadius = entries.count <= 14 ? 3 : 0
        set.circleHoleRadius = entries.count <= 14 ? 1.5 : 0
        set.drawCirclesEnabled = entries.count <= 14
        set.drawValuesEnabled = false
        set.mode = .linear
        set.drawFilledEnabled = false
        set.highlightEnabled = false
        return set
    }
}
