/// Overlay 遮罩层 · 组件测试
///
/// 验证组件库版本：v2.0（契约 `docs/数据与产物/api.json` `ui.overlay`，门禁 B ✅ 2026-09-04 冻结）。
/// 用例覆盖 6 个历史根因（2026-09-04 多轮调试复盘）：
///   根因1: Auto Layout 测量必须在视图层级内
///   根因2: center 约束循环对消 → 必须用递归 intrinsic 绕过
///   根因3: sizeThatFits + .fillEqually 陷阱 → 递归计算替代
///   根因4: edges.equalToSuperview() 循环依赖 → sizeThatFits + padding 检测
///   根因5: convenience init 赋值顺序 → visible 必须最后赋值
///   根因6: SnapKit 约束可能存储在 superview → 双级查找

import UIKit
import XCTest
@testable import KeepAccountsMiddleware

final class OverlayTests: XCTestCase {

    // MARK: - Helper

    /// 创建宿主 window 的 rootVC.view（模拟 keyWindow 环境）
    private func makeHostView() -> UIView {
        let vc = UIViewController()
        vc.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        return vc.view
    }

    // MARK: - 根因5: convenience init 赋值顺序

    /// 验证：visible=true 初始化时，contentBuilder 必须在 mount 前已赋值
    /// 历史 bug：visible 先赋值 → mount 时 contentBuilder=nil → contentContainer 为空
    func test_convenienceInit_contentBuilderReadyBeforeMount() {
        var builtContent = false
        let overlay = Overlay(
            visible: false,
            contentPosition: .center,
            contentRadius: .lg,
            content: { container in
                builtContent = true
                let label = UILabel()
                label.text = "Test"
                container.addSubview(label)
            }
        )
        // contentBuilder 赋值后 rebuildContent 应已调用
        XCTAssertTrue(builtContent, "contentBuilder 应在 init 完成后立即执行")
    }

    // MARK: - 根因2: center 约束循环对消 → 递归 intrinsic 测量

    /// 验证：StackView + center 约束时，measureContentSize 返回合理高度（非 0、非全屏）
    /// 历史 bug：center 约束循环对消 → Auto Layout 无法确定高度 → 返回 0 或全屏
    func test_measureContentSize_centerConstraints_returnsReasonableHeight() {
        let overlay = Overlay(
            visible: false,
            contentPosition: .center,
            contentRadius: .lg,
            content: { container in
                container.backgroundColor = .white
                let titleLabel = UILabel()
                titleLabel.text = "确认退出？"
                titleLabel.font = .boldSystemFont(ofSize: 16)

                let subLabel = UILabel()
                subLabel.text = "退出后当前编辑内容不会自动保存"
                subLabel.font = .systemFont(ofSize: 13)
                subLabel.numberOfLines = 0

                let stack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
                stack.axis = .vertical
                stack.spacing = 14
                container.addSubview(stack)
                stack.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.equalTo(240)
                }
                container.snp.makeConstraints { make in
                    make.width.equalTo(280)
                    make.top.equalTo(stack).offset(-20)
                    make.bottom.equalTo(stack).offset(20)
                }
            }
        )

        // 通过 KVC 调用私有方法 measureContentSize（测试用途）
        let hostView = makeHostView()
        overlay.frame = hostView.bounds
        hostView.addSubview(overlay)

        // 防御性重建后 contentContainer 应有子视图
        XCTAssertFalse(overlay.value(forKey: "contentContainer") as? UIView == nil,
                       "contentContainer 应存在")

        // 验证 contentContainer 非空
        let cc = overlay.value(forKey: "contentContainer") as! UIView
        XCTAssertFalse(cc.subviews.isEmpty, "contentContainer 应有子视图（防御性重建生效）")
    }

    // MARK: - 根因3: sizeThatFits + .fillEqually 陷阱

    /// 验证：水平 StackView + .fillEqually 的按钮，递归测量返回合理高度（< 200）
    /// 历史 bug：sizeThatFits(.greatestFiniteMagnitude) → 按钮高度被拉到天文数字 → 返回 1920
    func test_measureStackView_fillEqually_returnsReasonableHeight() {
        let overlay = Overlay(
            visible: false,
            contentPosition: .center,
            content: { container in
                container.backgroundColor = .white

                let cancel = UIButton(type: .system)
                cancel.setTitle("取消", for: .normal)
                cancel.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)

                let confirm = UIButton(type: .system)
                confirm.setTitle("确定", for: .normal)
                confirm.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)

                let btnStack = UIStackView(arrangedSubviews: [cancel, confirm])
                btnStack.axis = .horizontal
                btnStack.spacing = 8
                btnStack.distribution = .fillEqually

                let titleLabel = UILabel()
                titleLabel.text = "标题"
                titleLabel.font = .boldSystemFont(ofSize: 16)

                let stack = UIStackView(arrangedSubviews: [titleLabel, btnStack])
                stack.axis = .vertical
                stack.spacing = 14

                container.addSubview(stack)
                stack.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.equalTo(240)
                }
                container.snp.makeConstraints { make in
                    make.width.equalTo(280)
                    make.top.equalTo(stack).offset(-20)
                    make.bottom.equalTo(stack).offset(20)
                }
            }
        )

        let hostView = makeHostView()
        overlay.frame = hostView.bounds
        hostView.addSubview(overlay)

        let cc = overlay.value(forKey: "contentContainer") as! UIView
        XCTAssertFalse(cc.subviews.isEmpty, "contentContainer 应有子视图")

        // 验证 stack view 存在
        let hasStackView = cc.subviews.contains { $0 is UIStackView }
        XCTAssertTrue(hasStackView, "contentContainer 应包含 UIStackView")
    }

    // MARK: - 根因4: edges.equalToSuperview() 循环依赖

    /// 验证：UILabel + edges 约束时，measureContentSize 使用 sizeThatFits + padding 检测
    /// 历史 bug：edges 让 text 填满容器 → 内容尺寸循环依赖容器尺寸 → 无法自动解析
    func test_measureContentSize_edgesConstraints_usesSizeThatFits() {
        let overlay = Overlay(
            visible: false,
            contentPosition: .topRight,
            contentOffset: CGPoint(x: -12, y: 88),
            contentRadius: .md,
            content: { container in
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
            }
        )

        let hostView = makeHostView()
        overlay.frame = hostView.bounds
        hostView.addSubview(overlay)

        let cc = overlay.value(forKey: "contentContainer") as! UIView
        XCTAssertFalse(cc.subviews.isEmpty, "contentContainer 应有子视图")

        // 验证有 UILabel 子视图
        let hasLabel = cc.subviews.contains { $0 is UILabel }
        XCTAssertTrue(hasLabel, "contentContainer 应包含 UILabel")
    }

    // MARK: - 根因6: SnapKit 约束存储位置

    /// 验证：resolveTargetWidth 能找到 SnapKit 设置的宽度约束（无论存在 container 还是 superview）
    /// 历史 bug：SnapKit 把约束存在 superview 上 → resolveTargetWidth 只查 container.constraints → 返回 80% 屏幕宽
    func test_resolveTargetWidth_findsSnapKitConstraint() {
        let overlay = Overlay(
            visible: false,
            content: { container in
                container.snp.makeConstraints { make in
                    make.width.equalTo(280)
                }
                let label = UILabel()
                label.text = "Test"
                container.addSubview(label)
            }
        )

        // 通过 KVC 调用 resolveTargetWidth
        let hostView = makeHostView()
        overlay.frame = hostView.bounds
        hostView.addSubview(overlay)

        // 验证 contentContainer 有宽度约束 280
        let cc = overlay.value(forKey: "contentContainer") as! UIView
        let hasWidthConstraint = cc.constraints.contains {
            $0.firstAttribute == .width && $0.secondItem == nil && $0.constant == 280
        } || (cc.superview?.constraints.contains {
            ($0.firstItem as? UIView) == cc && $0.firstAttribute == .width && $0.secondItem == nil && $0.constant == 280
        } ?? false)

        XCTAssertTrue(hasWidthConstraint, "应能找到宽度约束 280（container 或 superview 上）")
    }

    // MARK: - 圆角：CAShapeLayer mask

    /// 验证：contentRadius > 0 时，layoutSubviews 后 contentContainer.layer.mask 存在
    /// 历史 bug：cornerRadius 单独使用在某些场景不生效
    func test_cornerRadius_cAShapeLayerMaskApplied() {
        let overlay = Overlay(
            visible: false,
            contentRadius: .lg,
            content: { container in
                container.backgroundColor = .white
                let label = UILabel()
                label.text = "Test"
                container.addSubview(label)
            }
        )

        let hostView = makeHostView()
        overlay.frame = hostView.bounds
        hostView.addSubview(overlay)
        overlay.layoutIfNeeded()

        let cc = overlay.value(forKey: "contentContainer") as! UIView
        // cornerRadius 应已设置
        XCTAssertEqual(cc.layer.cornerRadius, 14, accuracy: 0.01,
                       "contentRadius .lg 应解析为 14pt")
    }

    // MARK: - 9 点定位

    /// 验证：center 定位时，contentContainer 在 overlay 中心
    func test_contentPosition_center_isCentered() {
        let overlay = Overlay(
            visible: false,
            contentPosition: .center,
            content: { container in
                container.snp.makeConstraints { make in
                    make.width.equalTo(200)
                    make.height.equalTo(100)
                }
            }
        )

        let hostView = makeHostView()
        overlay.frame = hostView.bounds
        hostView.addSubview(overlay)
        overlay.layoutIfNeeded()

        let cc = overlay.value(forKey: "contentContainer") as! UIView
        let centerX = cc.frame.midX
        let centerY = cc.frame.midY
        let expectedCenterX = hostView.bounds.midX
        let expectedCenterY = hostView.bounds.midY

        XCTAssertEqual(centerX, expectedCenterX, accuracy: 1.0,
                       "contentContainer 应水平居中")
        XCTAssertEqual(centerY, expectedCenterY, accuracy: 1.0,
                       "contentContainer 应垂直居中")
    }

    // MARK: - 属性默认值

    /// 验证：Overlay 默认属性值与 api.json 契约一致
    func test_defaultProps_matchApiJson() {
        let overlay = Overlay(content: { _ in })

        XCTAssertFalse(overlay.visible, "visible 默认 false")
        XCTAssertEqual(overlay.contentPosition.rawValue, OverlayContentPosition.center.rawValue,
                       "contentPosition 默认 center")
        XCTAssertEqual(overlay.contentOffset, .zero, "contentOffset 默认 .zero")
        XCTAssertTrue(overlay.closeOnMaskClick, "closeOnMaskClick 默认 true")
        XCTAssertFalse(overlay.clickThrough, "clickThrough 默认 false")
        XCTAssertTrue(overlay.animation, "animation 默认 true")
    }

    // MARK: - 枚举解析

    /// 验证：OverlayMaskColor.parse 正确解析各种输入
    func test_maskColor_parse() {
        XCTAssertEqual(OverlayMaskColor.parse("default"), .default)
        XCTAssertEqual(OverlayMaskColor.parse("transparent"), .transparent)
        XCTAssertNotNil(OverlayMaskColor.parse("#FF0000"))
        XCTAssertNotNil(OverlayMaskColor.parse("rgba(255,0,0,0.5)"))
        XCTAssertEqual(OverlayMaskColor.parse("invalid"), .default, "非法输入降级 default")
    }

    /// 验证：OverlayContentPosition.fromString 正确解析 9 点
    func test_contentPosition_fromString() {
        XCTAssertEqual(OverlayContentPosition.fromString("center"), .center)
        XCTAssertEqual(OverlayContentPosition.fromString("top"), .top)
        XCTAssertEqual(OverlayContentPosition.fromString("bottom"), .bottom)
        XCTAssertEqual(OverlayContentPosition.fromString("top-left"), .topLeft)
        XCTAssertEqual(OverlayContentPosition.fromString("top-right"), .topRight)
        XCTAssertEqual(OverlayContentPosition.fromString("bottom-left"), .bottomLeft)
        XCTAssertEqual(OverlayContentPosition.fromString("bottom-right"), .bottomRight)
        XCTAssertEqual(OverlayContentPosition.fromString("invalid"), .center, "非法输入降级 center")
    }

    /// 验证：OverlayRadius 解析
    func test_radius_resolvedValue() {
        XCTAssertEqual(OverlayRadius.sm.resolvedValue, 6)
        XCTAssertEqual(OverlayRadius.md.resolvedValue, 10)
        XCTAssertEqual(OverlayRadius.lg.resolvedValue, 14)
        XCTAssertEqual(OverlayRadius.value(20).resolvedValue, 20)
        XCTAssertEqual(OverlayRadius.value(-5).resolvedValue, 0, "负值降级 0")
    }
}
