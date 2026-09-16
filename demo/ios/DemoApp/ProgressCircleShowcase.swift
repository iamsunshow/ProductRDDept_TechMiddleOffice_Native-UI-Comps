import UIKit
import SnapKit

// MARK: - ProgressCircle Showcase（信息展示区 · #83 · ui.progress-circle 进度环 Demo 页）
//
// 4 段排查：D1 基础 30% primary / D2 进度变化 0.3s 过渡（外部按钮±10%）/ D3 阈值切换
/// （0.6/0.85/1.10 三档按钮）/ D4 中心文案自定义「今日 ¥128」。双端 1:1
///（iOS ProgressCircleView vs Android ProgressCircle @Composable）。
final class ProgressCircleShowcase: ShowcaseViewController {

    private let circle1 = ProgressCircleView()
    private let circle2 = ProgressCircleView()
    private let circle3 = ProgressCircleView()
    private let circle4 = ProgressCircleView()

    override func viewDidLoad() {
        super.viewDidLoad()
        addVersionBadge(componentName: "ProgressCircle", version: "v1.0", builtAt: "2026-09-16")
        buildDemo1()
        buildDemo2()
        buildDemo3()
        buildDemo4()
    }

    // D1 · 基础 30% primary
    private func buildDemo1() {
        addSection(title: "D1 · 基础 30% primary 绿") { container in
            circle1.value = 0.3
            container.addSubview(circle1)
            circle1.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.width.height.equalTo(64)
                // 底部闭合段容器高度链（否则容器高 0、内容溢出盖住下一段标题）
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
        }
        addInfo("D1 基础 value=0.3 primary 绿 + 中心文案「30%」+ 默认 64×64 + 轨道 6pt 圆头。")
    }

    // D2 · 进度变化 0.3s ease-out 过渡
    private func buildDemo2() {
        addSection(title: "D2 · 进度变化 0.3s 过渡（外部±10%）") { container in
            circle2.value = 0.5
            container.addSubview(circle2)
            circle2.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.width.height.equalTo(64)
            }
            let plus = UIButton(type: .system)
            plus.setTitle("进度 +10%", for: .normal)
            plus.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            plus.setTitleColor(AppColor.primary, for: .normal)
            container.addSubview(plus)
            plus.snp.makeConstraints { make in
                make.top.equalTo(circle2.snp.bottom).offset(AppSpace.sm)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(36)
                // 末元素闭合段容器高度链（否则容器高 0、内容溢出盖住下一段标题）
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
            plus.addAction(UIAction { [weak circle2] _ in
                guard let c = circle2 else { return }
                c.value = min(1.0, c.value + 0.1)
            }, for: .touchUpInside)
            let minus = UIButton(type: .system)
            minus.setTitle("进度 -10%", for: .normal)
            minus.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            minus.setTitleColor(AppColor.primary, for: .normal)
            container.addSubview(minus)
            minus.snp.makeConstraints { make in
                make.top.equalTo(circle2.snp.bottom).offset(AppSpace.sm)
                make.leading.equalTo(plus.snp.trailing).offset(AppSpace.md)
                make.height.equalTo(36)
                make.centerY.equalTo(plus)
            }
            minus.addAction(UIAction { [weak circle2] _ in
                guard let c = circle2 else { return }
                c.value = max(0.0, c.value - 0.1)
            }, for: .touchUpInside)
        }
        addInfo("CABasicAnimation on strokeEnd + CAMediaTimingFunction .easeOut + 0.3s 时长。")
    }

    // D3 · 阈值切换（0.6/0.85/1.10）
    private func buildDemo3() {
        addSection(title: "D3 · 阈值切换三档（primary/warning/error）") { container in
            circle3.value = 0.6
            circle3.warnThreshold = 0.8
            circle3.dangerThreshold = 1.0
            container.addSubview(circle3)
            circle3.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.width.height.equalTo(64)
            }
            // 三档按钮
            for (offset, label, value) in [
                (0, "60% primary", 0.6),
                (80, "85% warning", 0.85),
                (160, "110% error", 1.10),
            ] {
                let btn = UIButton(type: .system)
                btn.setTitle(label, for: .normal)
                btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs)
                btn.setTitleColor(AppColor.primary, for: .normal)
                container.addSubview(btn)
                btn.snp.makeConstraints { make in
                    make.top.equalTo(circle3.snp.bottom).offset(AppSpace.sm)
                    make.leading.equalToSuperview().offset(AppSpace.md + CGFloat(offset))
                    // 定宽 76（< 档位间距 80）防三档按钮按文字宽度伸缩后互相重叠
                    make.width.equalTo(76)
                    make.height.equalTo(36)
                    // 末元素闭合段容器高度链（否则容器高 0、内容溢出盖住下一段标题）
                    make.bottom.equalToSuperview().offset(-AppSpace.md)
                }
                btn.addAction(UIAction { [weak circle3] _ in
                    circle3?.value = CGFloat(value)
                }, for: .touchUpInside)
            }
        }
        addInfo("value < warnThreshold primary / warnThreshold ≤ value < dangerThreshold warning / ≥ dangerThreshold error。")
    }

    // D4 · 中心文案自定义「今日 ¥128」
    private func buildDemo4() {
        addSection(title: "D4 · 中心文案自定义（覆盖百分比）") { container in
            circle4.value = 1.1
            circle4.centerText = "今日 ¥128"
            container.addSubview(circle4)
            circle4.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(AppSpace.md)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.width.height.equalTo(80)
            }
            let btn = UIButton(type: .system)
            btn.setTitle("切换/隐藏", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            btn.setTitleColor(AppColor.primary, for: .normal)
            container.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.equalTo(circle4.snp.bottom).offset(AppSpace.sm)
                make.leading.equalToSuperview().offset(AppSpace.md)
                make.height.equalTo(36)
                // 末元素闭合段容器高度链（否则容器高 0、内容溢出盖住下一段标题）
                make.bottom.equalToSuperview().offset(-AppSpace.md)
            }
            btn.addAction(UIAction { [weak circle4] _ in
                circle4?.centerText = (circle4?.centerText == nil) ? "3/10" : nil
            }, for: .touchUpInside)
        }
        addInfo("centerText 自定义覆盖默认百分比；nil 时只显示百分比；切到 nil 即隐藏。")
    }
}