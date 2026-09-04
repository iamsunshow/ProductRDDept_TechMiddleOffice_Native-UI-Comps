/// 增强版图片容器：统一 API 渲染图片内容（本地资源名 / 平台图像对象），
/// 提供对象填充模式（fit 五值）/ 内容停靠（position 五值）/ 宽高 / 圆角裁剪
/// （token 档位或任意值，=宽/2 即圆形）/ alt 无障碍 / 加载中·失败占位（可自定义）/
/// onTap·onLoad·onError。
///
/// 对标 NutUI React Image（增强版 img）；不内置预览（属独立 ImagePreview）。
/// 契约：`docs/数据与产物/api.json` `ui.image`（props/events 命名 100% 对齐，组件库 v1.3.1）。
///
/// 设计决策（门禁 A 拍板）：P1=B 网络图 URL 归业务预下载后传图对象（零三方图片加载依赖）；
/// P2=B lazy 一期 N/A；P3=A 圆形 = radius 传宽/2（无魔法值）；P4=B 失败仅 onError（重试=重设 src）。
/// src 语义：`nil` = 加载中占位（供业务模拟慢源/解码窗口）；String = Asset Catalog 资源名
/// （不存在 → 失败态）；UIImage = 平台图像对象直接渲染。
///
/// 几何纯函数 `ImageGeometry.rect`：fill/contain/cover/none/scale-down 绘制矩形统一公式
/// `x = anchorX * (W - dw)`、`y = anchorY * (H - dh)`，与 Android `ImageGeometry.rect`
/// 同公式同数学定义（D2/D3 双端断言用同一组数值向量，防平台盲区——Cell 教训）。

import UIKit

/// 对象填充模式（契约值直通：'fill' | 'contain' | 'cover' | 'none' | 'scale-down'）。
enum ImageFit: String {
    case fill = "fill"
    case contain = "contain"
    case cover = "cover"
    case none = "none"
    case scaleDown = "scale-down"
}

/// 内容停靠（契约值直通：'center' | 'top' | 'right' | 'bottom' | 'left'）。
enum ImagePosition: String {
    case center = "center"
    case top = "top"
    case right = "right"
    case bottom = "bottom"
    case left = "left"
}

/// 绘制矩形纯函数：给定容器与图片尺寸，按 fit/position 计算内容绘制矩形。
///
/// 数学（双端同构）：scale 确定绘制尺寸 dw×dh 后，停靠锚点
/// `x = ax * (W - dw)`、`y = ay * (H - dh)`（ax/ay ∈ {0, 0.5, 1}，由 position 拆分）。
/// - fill: dw=W, dh=H（铺满）
/// - contain: scale = min(W/iw, H/ih)（完整留白）
/// - cover: scale = max(W/iw, H/ih)（等比铺满，超容器部分裁切）
/// - none: dw=iw, dh=ih（原始尺寸，可能超容器）
/// - scale-down: scale = min(containScale, 1)（不放大）
/// 超容器时锚定公式自然表达裁切方位（如 cover+right → x=W-dw<0，保留内容右端），
/// 外层 clipsToBounds/Modifier.clip 完成裁剪。
enum ImageGeometry {
    static func horizontalAnchor(for position: ImagePosition) -> CGFloat {
        switch position {
        case .left: return 0
        case .center: return 0.5
        case .right: return 1
        case .top, .bottom: return 0.5 // 垂直停靠不影响水平锚
        }
    }

    static func verticalAnchor(for position: ImagePosition) -> CGFloat {
        switch position {
        case .top: return 0
        case .center: return 0.5
        case .bottom: return 1
        case .left, .right: return 0.5 // 水平停靠不影响垂直锚
        }
    }

    /// - Parameters:
    ///   - container: 容器尺寸（pt；Android 侧为 px，单位一致即可同公式）
    ///   - image: 图片原始尺寸（与 container 同单位）
    ///   - fit: 对象填充模式
    ///   - position: 内容停靠
    /// - Returns: 内容绘制矩形（可超容器，由外层裁剪）
    static func rect(
        container: CGSize,
        image: CGSize,
        fit: ImageFit,
        position: ImagePosition
    ) -> CGRect {
        let W = container.width, H = container.height
        let iw = image.width, ih = image.height
        guard iw > 0, ih > 0, W > 0, H > 0 else { return .zero }

        var dw: CGFloat, dh: CGFloat
        switch fit {
        case .fill:
            dw = W; dh = H
        case .contain:
            let s = min(W / iw, H / ih)
            dw = iw * s; dh = ih * s
        case .cover:
            let s = max(W / iw, H / ih)
            dw = iw * s; dh = ih * s
        case .none:
            dw = iw; dh = ih
        case .scaleDown:
            let s = min(min(W / iw, H / ih), 1)
            dw = iw * s; dh = ih * s
        }

        let ax = horizontalAnchor(for: position)
        let ay = verticalAnchor(for: position)
        return CGRect(x: ax * (W - dw), y: ay * (H - dh), width: dw, height: dh)
    }
}

/// 组件（iOS 类名与 Android 顶层函数同名，跨端组件调用形式一致）。
final class Image: UIView {
    /// 加载状态（外部只读；测试/业务观测状态机）。
    enum LoadState {
        case loading, loaded, failed
    }

    // MARK: - 事件回调（契约 events：onTap/onLoad/onError）

    var onTap: (() -> Void)?
    var onLoad: (() -> Void)?
    var onError: (() -> Void)?

    /// 当前加载状态（只读）。
    private(set) var state: LoadState = .loading

    /// 当前占位层（internal 测试口：nil = 无占位，即 loaded 成功态）。
    var displayedOverlay: UIView? { overlay }

    // MARK: - 配置（契约 props，命名与 api.json ui.image 100% 对齐）

    /// 图片来源：nil=加载中占位；String=Asset Catalog 资源名；UIImage=平台图对象。
    var src: Any?
    /// 对象填充模式，默认 'fill'。
    var fit: ImageFit = .fill
    /// 内容停靠，默认 'center'。
    var position: ImagePosition = .center
    /// 圆角：token 档位名 'sm'/'md'/'lg' 或数值 pt；nil/0=无圆角；=宽/2 即圆形（P3=A）。
    var radius: Any?
    /// 无障碍描述（iOS accessibilityLabel）。
    var alt: String?
    /// 加载中占位自定义内容视图（默认内置：bgCard 底 + 双色转圈指示器）。
    var loadingContent: UIView?
    /// 失败占位自定义内容视图（默认内置：破图图形 + 「加载失败」文案）。
    var errorContent: UIView?

    // MARK: - 视图树

    private let imageView = UIImageView()
    private var overlay: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isUserInteractionEnabled = true
        backgroundColor = AppColor.bgCard

        imageView.contentMode = .scaleToFill
        addSubview(imageView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - 布局

    /// 布局时刻按几何纯函数计算图片绘制矩形（fit/position 变化实时生效）。
    override func layoutSubviews() {
        super.layoutSubviews()
        // radius → 圆角裁剪（D4：token 档位/数值/=宽/2 圆形）。cornerRadius 在每次布局
        // 重算，radius 变化后 setNeedsLayout 即生效；clipsToBounds 已开，连带裁剪占位层。
        layer.cornerRadius = Image.radiusValue(from: radius)
        overlay?.frame = bounds
        if state == .loaded, let imageSize = imageView.image?.size {
            imageView.frame = ImageGeometry.rect(
                container: bounds.size,
                image: imageSize,
                fit: fit,
                position: position
            )
        } else {
            imageView.frame = .zero
        }
    }

    // MARK: - 配置入口

    /// 用契约属性配置并渲染（src 变化 → 状态机 loading → loaded/error）。
    /// 失败后重设合法 src 自动恢复渲染（P4=B 重试语义）。
    func apply() {
        state = .loading
        imageView.image = nil
        imageView.isHidden = true
        if src == nil {
            // nil = 加载中占位（业务模拟慢源/解码窗口，D5 用例路径）。
            showLoadingPlaceholder()
            return
        }
        if let uiImage = src as? UIImage {
            render(uiImage)
            return
        }
        if let name = src as? String, !name.isEmpty, let named = UIImage(named: name) {
            render(named)
            return
        }
        fail()
    }

    // MARK: - 状态渲染

    private func render(_ image: UIImage) {
        state = .loaded
        imageView.image = image
        imageView.isHidden = false
        removeOverlay()
        setNeedsLayout()
        layoutIfNeeded()
        updateAccessibility()
        onLoad?()
    }

    private func fail() {
        state = .failed
        removeOverlay()
        installOverlay(failed: true)
        updateAccessibility()
        onError?()
    }

    private func showLoadingPlaceholder() {
        installOverlay(failed: false)
        updateAccessibility()
    }

    private func installOverlay(failed: Bool) {
        removeOverlay()
        let view = failed
            ? (errorContent ?? Image.makeErrorPlaceholder())
            : (loadingContent ?? Image.makeLoadingPlaceholder())
        overlay = view
        view.frame = bounds
        addSubview(view)
        setNeedsLayout()
    }

    private func removeOverlay() {
        overlay?.removeFromSuperview()
        overlay = nil
    }

    // MARK: - 无障碍

    private func updateAccessibility() {
        isAccessibilityElement = true
        switch state {
        case .loaded:
            accessibilityLabel = alt
            accessibilityTraits = onTap != nil ? [.button] : .none
        case .loading:
            accessibilityLabel = alt ?? "图片加载中"
            accessibilityTraits = .none
        case .failed:
            accessibilityLabel = alt ?? "图片加载失败"
            accessibilityTraits = .none
        }
    }

    /// 点击处理（internal 供单测直调；生产路径 = 手势识别器 target，D8）。
    @objc internal func handleTap() {
        // 点击区域 = 容器内全部（D8）。
        onTap?()
    }

    // MARK: - 默认占位视图（内置绘制，deps=[]，不依赖未完成 Icon/Loading 组件）

    /// 加载中占位：bgCard 底 + 中央双色转圈指示器（gray.15 轨道 + primary 弧段，ø14）。
    /// 对齐规格页 token 表：占位底 bgCard、指示器描边 gray.15 + 主色 primary。
    static func makeLoadingPlaceholder() -> UIView {
        let holder = UIView()
        holder.backgroundColor = AppColor.bgCard
        // 占位层自身不参与读屏（语义由 Image 容器按状态统一输出，防读屏重复）。
        holder.isAccessibilityElement = false
        holder.accessibilityElementsHidden = true

        let size: CGFloat = 14
        let ring = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        ring.isUserInteractionEnabled = false
        ring.accessibilityElementsHidden = true

        let track = CAShapeLayer()
        track.path = UIBezierPath(
            ovalIn: CGRect(x: 1, y: 1, width: size - 2, height: size - 2)
        ).cgPath
        track.strokeColor = AppColor.gray15.cgColor
        track.fillColor = UIColor.clear.cgColor
        track.lineWidth = 2
        ring.layer.addSublayer(track)

        let progress = CAShapeLayer()
        progress.path = UIBezierPath(
            ovalIn: CGRect(x: 1, y: 1, width: size - 2, height: size - 2)
        ).cgPath
        progress.strokeColor = AppColor.primary.cgColor
        progress.fillColor = UIColor.clear.cgColor
        progress.lineWidth = 2
        progress.lineCap = .round
        progress.strokeStart = 0
        progress.strokeEnd = 0.25
        ring.layer.addSublayer(progress)

        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue = 0
        spin.toValue = CGFloat.pi * 2
        spin.duration = 0.9
        spin.repeatCount = .infinity
        ring.layer.add(spin, forKey: "spin")

        holder.addSubview(ring)
        ring.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ring.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
            ring.widthAnchor.constraint(equalToConstant: size),
            ring.heightAnchor.constraint(equalToConstant: size),
        ])
        return holder
    }

    /// 失败占位：bgCard 底 + 破图图形（自绘矩形外框+左上角太阳圆+右下山形折线，gray.25，
    /// 与 Android DefaultErrorPlaceholder 视窗 40×32 / 线宽 2 / 太阳 r=2.5 / 山峰坐标比例完全一致）
    /// +「加载失败」（textSecondary/sizeSm）。双端同一数学定义绘制，解除 iOS SF Symbol
    /// photo 依赖造成的失败占位单端差异（v1.3.1 Bug6）。
    static func makeErrorPlaceholder() -> UIView {
        let holder = UIView()
        holder.backgroundColor = AppColor.bgCard
        // 占位层自身不参与读屏（语义由 Image 容器按状态统一输出，防读屏重复）。
        holder.isAccessibilityElement = false
        holder.accessibilityElementsHidden = true

        // 破图图形：40×32 视窗（与 Android Canvas(Modifier.size(40.dp, 32.dp) 同尺寸）
        let iconW: CGFloat = 40
        let iconH: CGFloat = 32
        let line: CGFloat = 2
        let icon = ErrorGraphicImageView(frame: CGRect(x: 0, y: 0, width: iconW, height: iconH))
        icon.lineWidth = line
        icon.foregroundColor = AppColor.gray25
        icon.backgroundColor = .clear
        icon.isAccessibilityElement = false

        let caption = UILabel()
        caption.text = "加载失败"
        caption.font = .systemFont(ofSize: AppFont.sizeSm)
        caption.textColor = AppColor.textSecondary
        caption.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [icon, caption])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppSpace.sm

        holder.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: iconW),
            icon.heightAnchor.constraint(equalToConstant: iconH),
        ])
        return holder
    }
}

/// 失败占位破图图形自绘：与 Android DefaultErrorPlaceholder Canvas 同数学定义（像素级对齐）。
/// 参数来自 Android 端：40×32 视窗、线宽 2dp（iOS pt=2）、灰色 AppColor.gray25。
/// 比例（与 Android 代码 float 比例 1:1）：
///   - 外框：topLeft=(line, line)，size=(w-2*line, h-2*line)（stroke）
///   - 太阳圆：center=(w*0.34, h*0.38)，r=2.5（stroke，非填充——与 Android drawCircle style=Stroke 一致）
///   - 山折线：峰值 peak=(w*0.58, h*0.42)，左底=(w*0.36, h*0.72)，右底=(w*0.80, h*0.72)
final class ErrorGraphicImageView: UIView {
    var lineWidth: CGFloat = 2
    var foregroundColor: UIColor = .gray

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let w = rect.width
        let h = rect.height
        let line = lineWidth
        ctx.setLineWidth(line)
        ctx.setStrokeColor(foregroundColor.cgColor)
        ctx.setFillColor(UIColor.clear.cgColor)

        // 1. 外框（drawRect stroke）
        let frameRect = CGRect(x: line, y: line, width: w - line * 2, height: h - line * 2)
        ctx.stroke(frameRect)

        // 2. 太阳圆（stroke 非填充，与 Android drawCircle style=Stroke 完全一致）
        let sunR: CGFloat = 2.5
        let sunC = CGPoint(x: w * 0.34, y: h * 0.38)
        ctx.strokeEllipse(in: CGRect(x: sunC.x - sunR, y: sunC.y - sunR, width: sunR * 2, height: sunR * 2))

        // 3. 山折线：左底 → 峰值 → 右底（两条 drawLine，与 Android 两段 drawLine 一致）
        let peak = CGPoint(x: w * 0.58, y: h * 0.42)
        let leftBase = CGPoint(x: w * 0.36, y: h * 0.72)
        let rightBase = CGPoint(x: w * 0.80, y: h * 0.72)
        ctx.beginPath()
        ctx.move(to: leftBase)
        ctx.addLine(to: peak)
        ctx.addLine(to: rightBase)
        ctx.strokePath()
    }
}

extension Image {
    /// 圆角解析：'sm'/'md'/'lg' → token 档位；NSNumber/CGFloat → 数值（pt）；nil/0 → 无圆角。
    static func radiusValue(from raw: Any?) -> CGFloat {
        guard let raw else { return 0 }
        if let string = raw as? String {
            switch string {
            case "sm": return AppRadius.sm
            case "md": return AppRadius.md
            case "lg": return AppRadius.lg
            default: return 0
            }
        }
        if let number = raw as? NSNumber {
            return CGFloat(number.doubleValue)
        }
        return 0
    }
}
