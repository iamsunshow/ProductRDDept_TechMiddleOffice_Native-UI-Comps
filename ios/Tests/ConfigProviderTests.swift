import XCTest
import UIKit

/// ConfigProvider 组件测试：门禁 C1 用例映射（详见 `docs/验收流程/component-acceptance-config-provider.md`）。
///
/// Provider 型组件无视觉五态，D 系列为「配置生效测试」——以读取解析层 [AppTheme]
/// 为观测点（消费组件接入读取解析层属后续版本渐进落地，见 ConfigProvider.swift 头注）。
/// 覆盖 D1-D8（配置生效）与 A1-A5（API 契约）；A6/A7（schema/命名对齐）由
/// `scripts/check_component_quality.py` 双端核对。
/// 用例函数命名与验收文档一一对应。
final class ConfigProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ConfigProvider.resetForTesting()
    }

    override func tearDown() {
        ConfigProvider.resetForTesting()
        super.tearDown()
    }

    // MARK: - D 系列：配置生效测试（观测点 = AppTheme 解析层）

    /// D1 默认基准（零行为变化）：未挂 Provider 时解析层返回静态基准 AppTokens 值。
    func test_D1_defaultBaseline() {
        XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
        XCTAssertEqual(AppTheme.radiusSm, AppRadius.sm)
        XCTAssertEqual(AppTheme.radiusMd, AppRadius.md)
        XCTAssertEqual(AppTheme.radiusLg, AppRadius.lg)
        XCTAssertEqual(AppTheme.spaceSm, AppSpace.sm)
        XCTAssertEqual(AppTheme.spaceMd, AppSpace.md)
        XCTAssertEqual(AppTheme.spaceLg, AppSpace.lg)
        XCTAssertEqual(AppTheme.spaceXl, AppSpace.xl)
        XCTAssertEqual(AppTheme.locale, "zh-CN")
    }

    /// D2 主题色覆盖：挂 Provider primaryColor 后，primaryColor 解析变覆盖值，其余 token 不变。
    func test_D2_primaryColorOverride() {
        let overlay = AppConfig(primaryColor: UIColor(hexString: "#4F46E5"))
        ConfigProvider.withScope(overlay) {
            XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#4F46E5"))
            // 其余 token 不受影响
            XCTAssertEqual(AppTheme.radiusMd, AppRadius.md)
            XCTAssertEqual(AppTheme.spaceLg, AppSpace.lg)
            XCTAssertEqual(AppTheme.locale, "zh-CN")
        }
        // 作用域结束后恢复
        XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
    }

    /// D3 紧凑模式：compact 后间距降一档（md→sm，lg→md，xl→lg；sm 不降）。
    func test_D3_compactMode() {
        ConfigProvider.withScope(AppConfig(compact: true)) {
            XCTAssertEqual(AppTheme.spaceSm, AppSpace.sm, "sm 档不降")
            XCTAssertEqual(AppTheme.spaceMd, AppSpace.sm, "md→sm")
            XCTAssertEqual(AppTheme.spaceLg, AppSpace.md, "lg→md")
            XCTAssertEqual(AppTheme.spaceXl, AppSpace.lg, "xl→lg")
            // 颜色/圆角不受影响
            XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
            XCTAssertEqual(AppTheme.radiusMd, AppRadius.md)
        }
    }

    /// D4 圆角模式：rounded 后圆角升一档（sm→md，md→lg，lg 封顶）。
    func test_D4_roundedMode() {
        ConfigProvider.withScope(AppConfig(rounded: true)) {
            XCTAssertEqual(AppTheme.radiusSm, AppRadius.md, "sm→md")
            XCTAssertEqual(AppTheme.radiusMd, AppRadius.lg, "md→lg")
            XCTAssertEqual(AppTheme.radiusLg, AppRadius.lg, "lg 封顶")
            // 间距/颜色不受影响
            XCTAssertEqual(AppTheme.spaceMd, AppSpace.md)
            XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
        }
    }

    /// D5 静态基准不被污染：覆盖只发生在读取解析层，AppTokens 静态常量零改动。
    func test_D5_staticBaselineUnpolluted() {
        ConfigProvider.withScope(
            AppConfig(primaryColor: UIColor(hexString: "#4F46E5"), rounded: true, compact: true)
        ) {
            XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#4F46E5"))
        }
        // 静态 token 常量与覆盖前一致
        XCTAssertEqual(AppColor.primary, UIColor(hex: 0x16A34A))
        XCTAssertEqual(AppRadius.sm, 6)
        XCTAssertEqual(AppRadius.md, 10)
        XCTAssertEqual(AppRadius.lg, 14)
        XCTAssertEqual(AppSpace.sm, 8)
        XCTAssertEqual(AppSpace.md, 12)
        XCTAssertEqual(AppSpace.lg, 16)
        XCTAssertEqual(AppSpace.xl, 24)
        // 解析层已复位
        XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
        XCTAssertFalse(ConfigProvider.current.rounded ?? false)
        XCTAssertFalse(ConfigProvider.current.compact ?? false)
    }

    /// D6 嵌套优先级（内层覆盖 + 继承）：外层 primaryColor、内层 compact → 内层覆盖 compact、
    /// 外层未覆盖项 primaryColor 被继承。
    func test_D6_nestedPriority() {
        let overlayOuter = AppConfig(primaryColor: UIColor(hexString: "#4F46E5"))
        ConfigProvider.withScope(overlayOuter) {
            // 外层生效
            XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#4F46E5"))
            XCTAssertEqual(AppTheme.spaceMd, AppSpace.md)

            ConfigProvider.withScope(AppConfig(compact: true)) {
                // 内层 compact 覆盖外层；primaryColor 外层项被继承
                XCTAssertEqual(ConfigProvider.current.compact, true)
                XCTAssertEqual(AppTheme.spaceMd, AppSpace.sm, "内层 compact 生效")
                XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#4F46E5"), "外层 primaryColor 被继承")
            }

            // 退出内层后恢复外层
            XCTAssertEqual(AppTheme.spaceMd, AppSpace.md)
            XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#4F46E5"))
        }
        // 退出外层后回静态基准
        XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
        XCTAssertEqual(AppTheme.spaceMd, AppSpace.md)
    }

    /// D7 语言切换：locale 覆盖为 'en-US'。
    func test_D7_localeSwitch() {
        ConfigProvider.withScope(AppConfig(locale: "en-US")) {
            XCTAssertEqual(AppTheme.locale, "en-US")
        }
        XCTAssertEqual(AppTheme.locale, "zh-CN")
    }

    /// D8 组合覆盖：primaryColor + rounded + compact 同时生效，互不干扰。
    func test_D8_comboOverride() {
        let combo = AppConfig(
            primaryColor: UIColor(hexString: "#4F46E5"),
            rounded: true,
            compact: true,
            locale: "en-US"
        )
        ConfigProvider.withScope(combo) {
            XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#4F46E5"))
            XCTAssertEqual(AppTheme.radiusMd, AppRadius.lg)
            XCTAssertEqual(AppTheme.spaceLg, AppSpace.md)
            XCTAssertEqual(AppTheme.locale, "en-US")
        }
    }

    // MARK: - A 系列：API 契约测试

    /// A1 默认 props：不传时默认值生效（rounded=false、compact=false、locale='zh-CN'）。
    func test_A1_defaultProps() {
        ConfigProvider.withScope(AppConfig()) {
            XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
            XCTAssertFalse(ConfigProvider.current.rounded ?? false)
            XCTAssertFalse(ConfigProvider.current.compact ?? false)
            XCTAssertEqual(ConfigProvider.current.locale ?? "zh-CN", "zh-CN")
            XCTAssertEqual(AppTheme.locale, "zh-CN")
        }
    }

    /// A2 自定义 props：各覆盖项按传入值生效。
    func test_A2_customProps() {
        let overlay = AppConfig(
            primaryColor: UIColor(hexString: "#DC2626"),
            rounded: false,
            compact: true,
            locale: "en-US"
        )
        ConfigProvider.withScope(overlay) {
            XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#DC2626"))
            XCTAssertEqual(ConfigProvider.current.rounded, false)
            XCTAssertEqual(ConfigProvider.current.compact, true)
            XCTAssertEqual(ConfigProvider.current.locale, "en-US")
            XCTAssertEqual(AppTheme.spaceMd, AppSpace.sm)
        }
    }

    /// A3 作用域-子树读取：配置经上下文穿透，子树内任意深度可读取。
    func test_A3_scopeDescendantRead() {
        // 模拟两层子树（嵌套函数调用栈），每层都能读到覆盖配置
        ConfigProvider.withScope(AppConfig(primaryColor: UIColor(hexString: "#4F46E5"))) {
            func deepRead() -> UIColor { AppTheme.primaryColor }
            XCTAssertEqual(deepRead(), UIColor(hexString: "#4F46E5"))
        }
    }

    /// A4 作用域-作用域外不受影响：Provider 外组件读静态基准。
    func test_A4_outOfScopeUnaffected() {
        // withScope 外（栈底 = 静态基准）
        XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
        ConfigProvider.withScope(AppConfig(primaryColor: UIColor(hexString: "#4F46E5"))) {
            XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#4F46E5"))
        }
        // 弹出后恢复，作用域外不受影响
        XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
    }

    /// A5 能力-覆盖语义：嵌套 Provider + 组合覆盖，与 D6/D8 对应。
    func test_A5_overrideSemantics() {
        let inner = AppConfig(primaryColor: UIColor(hexString: "#DC2626"), rounded: true)
        ConfigProvider.withScope(AppConfig(compact: true)) {
            XCTAssertEqual(AppTheme.spaceMd, AppSpace.sm)
            ConfigProvider.withScope(inner) {
                // 内层：primaryColor 内层覆盖外层 nil（外层未设 → 内层值），
                //        rounded 内层 true；compact 内层 nil → 继承外层 true
                XCTAssertEqual(AppTheme.primaryColor, UIColor(hexString: "#DC2626"))
                XCTAssertEqual(AppTheme.radiusMd, AppRadius.lg)
                XCTAssertEqual(AppTheme.spaceMd, AppSpace.sm, "compact 继承外层")
            }
            // 退出内层：compact 仍生效，primaryColor 回外层（外层未设 → 静态基准）
            XCTAssertEqual(AppTheme.spaceMd, AppSpace.sm)
            XCTAssertEqual(AppTheme.primaryColor, AppColor.primary)
        }
    }

    // MARK: - 附加：解析层基础行为

    /// parseHexColor 对齐：支持 6 位 / 3 位、带/不带 # 前缀。
    func test_hexStringParsing() {
        XCTAssertEqual(UIColor(hexString: "#4F46E5"), UIColor(hexString: "4F46E5"))
        XCTAssertEqual(UIColor(hexString: "#4F46E5"), UIColor(hex: 0x4F46E5))
        XCTAssertEqual(UIColor(hexString: "#abc"), UIColor(hex: 0xAABBCC), "3 位展开为 AABBCC")
        XCTAssertNil(UIColor(hexString: "#12"), "非法长度返回 nil")
        XCTAssertNil(UIColor(hexString: "xyz"), "非法字符返回 nil")
    }

    /// AppConfig.merged 语义：overlay 覆盖同名项、nil 继承外层。
    func test_mergedSemantics() {
        let outer = AppConfig(primaryColor: UIColor(hexString: "#4F46E5"), rounded: true)
        let inner = AppConfig(compact: true)
        let merged = outer.merged(with: inner)
        XCTAssertEqual(merged.primaryColor, UIColor(hexString: "#4F46E5"), "外层 primaryColor 被继承")
        XCTAssertEqual(merged.rounded, true, "外层 rounded 被继承")
        XCTAssertEqual(merged.compact, true, "内层 compact 覆盖")
        XCTAssertNil(merged.locale, "两端未设 → nil")
    }
}
