/// Image 图片 · 组件测试
///
/// 验证组件库版本：v1.3.0（契约 `docs/数据与产物/api.json` `ui.image`，门禁 B ✅ 2026-09-03 冻结）。
/// 用例编号对齐 `docs/验收流程/component-acceptance-image.md` D 系列（视觉几何）+ A 系列（API 契约）。
/// 职责分工（防 Cell 盲区教训）：几何数学 = 纯函数 `ImageGeometry.rect` 数学闭环断言（D2/D3/H）；
/// 状态机/回调/默认值 = 本文件；渲染像素级视觉留 demo 实机 C1.5 确认。
/// iOS 单测在模拟器 app host 内跑（v1.2.1 打通 SwiftPM 构建阻塞后可用）。

import UIKit
import XCTest
@testable import KeepAccountsMiddleware

final class ImageTests: XCTestCase {
    // MARK: - 测试图（标记图：宽高比 ≠ 容器 120x90 4:3）

    static func markImage(width: CGFloat, height: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        return renderer.image { ctx in
            UIColor(red: 0.09, green: 0.46, blue: 0.91, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
            UIColor(red: 0.97, green: 0.61, blue: 0.13, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height / 2))
        }
    }

    private static let image320x200 = ImageTests.markImage(width: 320, height: 200)

    private func makeImage(frame: CGRect = CGRect(x: 0, y: 0, width: 120, height: 90)) -> Image {
        let image = Image(frame: frame)
        image.backgroundColor = .white
        return image
    }

    private func assertRect(_ r: CGRect, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat,
                            file: StaticString = #filePath, line: UInt = #line) {
        let eps: CGFloat = 0.001
        XCTAssertEqual(r.origin.x, x, accuracy: eps, file: file, line: line)
        XCTAssertEqual(r.origin.y, y, accuracy: eps, file: file, line: line)
        XCTAssertEqual(r.width, w, accuracy: eps, file: file, line: line)
        XCTAssertEqual(r.height, h, accuracy: eps, file: file, line: line)
    }

    // MARK: - D1 默认渲染 / 加载流程

    func test_D1_defaultStateLoaded() {
        let image = makeImage()
        var loadCount = 0
        var errorCount = 0
        image.onLoad = { loadCount += 1 }
        image.onError = { errorCount += 1 }
        image.src = ImageTests.image320x200
        image.apply()

        XCTAssertEqual(image.state, .loaded)
        XCTAssertEqual(loadCount, 1)
        XCTAssertEqual(errorCount, 0)
        XCTAssertNil(image.displayedOverlay, "loaded 态不应残留占位")
    }

    func test_D5_loadingNullShowsPlaceholder() {
        // src=nil = 加载中占位（D5 慢源模拟路径）
        let image = makeImage()
        image.src = nil
        image.apply()

        XCTAssertEqual(image.state, .loading)
        XCTAssertNotNil(image.displayedOverlay, "loading 态应显示占位")
        XCTAssertEqual(image.accessibilityLabel, "图片加载中", "loading 占位可读语义（alt 兜底）")
    }

    func test_D5_loadingThenLoaded() {
        let image = makeImage()
        var onLoadCount = 0
        image.onLoad = { onLoadCount += 1 }
        image.src = nil
        image.apply()
        XCTAssertEqual(image.state, .loading)

        // 慢源完成 → 切换为有效图 → loaded
        image.src = ImageTests.image320x200
        image.apply()
        XCTAssertEqual(image.state, .loaded)
        XCTAssertEqual(onLoadCount, 1)
        XCTAssertNil(image.displayedOverlay)
    }

    func test_D5b_customLoadingContent() {
        let image = makeImage()
        let custom = UIView(frame: .zero)
        image.loadingContent = custom
        image.src = nil
        image.apply()
        XCTAssertTrue(image.displayedOverlayIs(custom), "自定义 loading 占位应被使用")
    }

    // MARK: - D7 失败态

    func test_D7_errorState() {
        let image = makeImage()
        var onErrorCount = 0
        image.onError = { onErrorCount += 1 }
        image.src = "__no_such_asset__"
        image.apply()

        XCTAssertEqual(image.state, .failed)
        XCTAssertEqual(onErrorCount, 1)
        XCTAssertNotNil(image.displayedOverlay, "失败态应显示错误占位")
        XCTAssertEqual(image.accessibilityLabel, "图片加载失败", "A7: 失败占位可读语义")
    }

    func test_D7b_customErrorContent() {
        let image = makeImage()
        let custom = UIView(frame: .zero)
        image.errorContent = custom
        image.src = "__no_such_asset__"
        image.apply()
        XCTAssertTrue(image.displayedOverlayIs(custom))
    }

    func test_D7c_retryAfterError() {
        // P4=B：失败仅 onError，重试 = 重设 src
        let image = makeImage()
        var onLoadCount = 0
        var onErrorCount = 0
        image.onLoad = { onLoadCount += 1 }
        image.onError = { onErrorCount += 1 }
        image.src = "__no_such_asset__"
        image.apply()
        XCTAssertEqual(onErrorCount, 1)

        image.src = ImageTests.image320x200
        image.apply()
        XCTAssertEqual(image.state, .loaded)
        XCTAssertEqual(onLoadCount, 1)
        XCTAssertNil(image.displayedOverlay)
    }

    // MARK: - D2/D3 几何纯函数（数学闭环；Android 同公式同向量，见 ImageTest.kt）

    func test_D2_fitGeometryAllValues() {
        // 容器 120x90，图 320x200（3:2 ≠ 4:3）
        let c = CGSize(width: 120, height: 90)
        let img = CGSize(width: 320, height: 200)

        // fill: 铺满容器
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .fill, position: .center), 0, 0, 120, 90)

        // contain: scale = min(120/320, 90/200) = 0.375 → 120x75，垂直留空 15 居中
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .contain, position: .center), 0, 7.5, 120, 75)

        // cover: scale = max(0.375, 0.45) = 0.45 → 144x90，水平超 24 居中裁两边
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .cover, position: .center), -12, 0, 144, 90)

        // none: 原始尺寸 320x200，居中（超容器，外层裁剪）
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .none, position: .center), -100, -55, 320, 200)

        // scale-down（图大）：scale = min(0.375, 1) = 0.375，同 contain
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .scaleDown, position: .center), 0, 7.5, 120, 75)
    }

    func test_D2b_scaleDownSmallImageNotEnlarged() {
        // scale-down 语义：不放大。小图 60x40 于 120x90 容器 → 原尺寸居中
        let c = CGSize(width: 120, height: 90)
        let small = CGSize(width: 60, height: 40)
        assertRect(ImageGeometry.rect(container: c, image: small, fit: .scaleDown, position: .center), 30, 25, 60, 40)
        // contain 会放大（对照）
        assertRect(ImageGeometry.rect(container: c, image: small, fit: .contain, position: .center), 0, 0, 120, 90)
    }

    func test_D3_positionAnchorMath() {
        // contain 垂直留空场景：容器 160x240、图 80x60 → scale=min(2,4)=2 → 160x120，垂直留空 120
        let c = CGSize(width: 160, height: 240)
        let img = CGSize(width: 80, height: 60)
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .contain, position: .top), 0, 0, 160, 120)
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .contain, position: .center), 0, 60, 160, 120)
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .contain, position: .bottom), 0, 120, 160, 120)

        // 水平留空场景：容器 240x160、图 80x60 → scale=min(3, 2.667) ≈ 2.667 → 213.33x160，right 锚右缘
        let c2 = CGSize(width: 240, height: 160)
        let r = ImageGeometry.rect(container: c2, image: img, fit: .contain, position: .right)
        XCTAssertEqual(r.maxX, 240, accuracy: 0.01)
        XCTAssertEqual(r.minY, 0, accuracy: 0.01)
    }

    func test_D3b_coverOversizeAnchor() {
        // cover 超容器锚定：容器 100x100、图 200x50 → scale=2 → 400x100，水平超 300
        let c = CGSize(width: 100, height: 100)
        let img = CGSize(width: 200, height: 50)
        // right: 内容右端对齐容器右端 → x = 100 - 400 = -300（显示内容右端）
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .cover, position: .right), -300, 0, 400, 100)
        // left: x=0（显示内容左端）
        assertRect(ImageGeometry.rect(container: c, image: img, fit: .cover, position: .left), 0, 0, 400, 100)
    }

    func test_H1_zeroSizedGuard() {
        // 容器或图为零 → .zero（防除零）
        let z = CGRect.zero
        XCTAssertEqual(ImageGeometry.rect(container: .zero, image: CGSize(width: 10, height: 10), fit: .contain, position: .center), z)
        XCTAssertEqual(ImageGeometry.rect(container: CGSize(width: 10, height: 10), image: .zero, fit: .cover, position: .center), z)
    }

    // MARK: - D4 圆角 / D8 点击与无障碍

    func test_D4_radiusTokenAndNumeric() {
        XCTAssertEqual(Image.radiusValue(from: nil), 0)
        XCTAssertEqual(Image.radiusValue(from: "sm"), 6)
        XCTAssertEqual(Image.radiusValue(from: "md"), 10)
        XCTAssertEqual(Image.radiusValue(from: "lg"), 14)
        XCTAssertEqual(Image.radiusValue(from: 24), 24)
        XCTAssertEqual(Image.radiusValue(from: 24.5), 24.5)
    }

    func test_D4b_circleSemantics() {
        // P3=A：圆形 = radius 传宽/2，无魔法值 —— 不强制、不改写用户数值
        let image = makeImage()
        image.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        image.radius = 24
        image.src = ImageTests.image320x200
        image.apply()
        XCTAssertEqual(image.layer.cornerRadius, 24)
        XCTAssertTrue(image.clipsToBounds)
    }

    func test_D8_tapEvent() {
        let image = makeImage()
        var tapCount = 0
        image.onTap = { tapCount += 1 }
        image.src = ImageTests.image320x200
        image.apply()
        image.handleTap()
        image.handleTap()
        XCTAssertEqual(tapCount, 2, "点击容器内全部区域触发 onTap（D7）")
    }

    func test_D8_altAccessibility() {
        let image = makeImage()
        image.alt = "用户头像"
        image.src = ImageTests.image320x200
        image.apply()
        XCTAssertEqual(image.accessibilityLabel, "用户头像", "loaded: accessibilityLabel = alt")
        XCTAssertFalse(image.accessibilityTraits.contains(.button), "未设 onTap 时不暴露 button 特性")

        image.onTap = {}
        image.apply()
        XCTAssertTrue(image.accessibilityTraits.contains(.button), "设 onTap 后暴露 button 特性")
    }

    // MARK: - A 系列 API 契约

    func test_A1_defaults() {
        let image = makeImage()
        XCTAssertEqual(image.fit, .fill)
        XCTAssertEqual(image.position, .center)
        XCTAssertEqual(Image.radiusValue(from: image.radius), 0)
        XCTAssertNil(image.alt)
        XCTAssertNil(image.loadingContent)
        XCTAssertNil(image.errorContent)
        XCTAssertEqual(image.state, .loading, "未配置 src 时应处于 loading 初始态")
    }

    func test_A2_customProps() {
        let image = makeImage()
        image.fit = .cover
        image.position = .right
        image.radius = "md"
        image.alt = "封面"
        image.src = ImageTests.image320x200
        image.apply()
        XCTAssertEqual(image.fit, .cover)
        XCTAssertEqual(image.position, .right)
        XCTAssertEqual(Image.radiusValue(from: image.radius), 10)
        XCTAssertEqual(image.layer.cornerRadius, 10)
    }

    func test_A3_callbacksIndependent() {
        let image = makeImage()
        var loadCount = 0
        var errorCount = 0
        var tapCount = 0
        image.onLoad = { loadCount += 1 }
        image.onError = { errorCount += 1 }
        image.onTap = { tapCount += 1 }

        image.src = "__missing__"
        image.apply()
        XCTAssertEqual(errorCount, 1)
        XCTAssertEqual(loadCount, 0)

        image.src = ImageTests.image320x200
        image.apply()
        XCTAssertEqual(loadCount, 1)
        XCTAssertEqual(errorCount, 1, "onError 不应被成功加载重置")

        image.handleTap()
        XCTAssertEqual(tapCount, 1)
    }
}

extension Image {
    /// 测试辅助：占位层是否就是指定视图（自定义插槽生效断言）。
    func displayedOverlayIs(_ view: UIView) -> Bool {
        displayedOverlay === view
    }
}
