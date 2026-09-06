/// Uploader 上传（数据录入区 · ui.uploader · #43）通用文件/图片上传 UI 组件。
///
/// 组件 ID：`ui.uploader`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-07，规格
/// design-spec/uploader-design-spec.html + 评审单 review-uploader-A.md，P1–P4 全 A）。
///
/// 视觉锚点（与 Android Uploader 同构）：4 列网格 spacing 8；cell 正方形 radiusSm bgPage；
/// 添加格=dashed border(textSecondary30%) + 号 textTertiary sizeXl 居中；删除角标 16pt 圆
/// rgba(0,0,0,.5) 白×11pt 右上角；uploading=primary 80% 蒙层+白字"上传中"+底部进度条 3pt；
/// failed=error 80% 蒙层+白字"失败"。
///
/// 语义：value [UploadItem] 受控必传（宿主真源），外部赋值=同步刷新；onAdd/onRemove/onRetry
/// 三回调（宿主调起选择器后回写 value、删除 index 项、失败项重置 status 重新上传）；
/// maxCount 默认 9（达上限隐藏添加格）；disabled 整件 alpha0.4 不可点。
///
/// 划界勿混：组件不内置系统选择器（宿主调起 PHPicker/PhotoPicker）和网络上传逻辑
/// （宿主驱动 status+progress）；与 Image 纯展示/Avatar 头像圆形裁切区分。
import UIKit

/// 上传状态机。
enum UploadStatus {
    case pending      // 等待上传（无蒙层）
    case uploading    // 上传中（primary 蒙层+进度条）
    case success      // 成功（无蒙层+删除角标）
    case failed       // 失败（error 蒙层+点击重试）
}

/// 上传文件项（宿主真源，组件纯渲染）。
struct UploadItem {
    let id: String
    let name: String
    let size: Int64?
    let thumbnailUrl: String?   // 网络缩略图 URL
    let localPath: String?      // 本地文件路径
    let status: UploadStatus
    let progress: Float         // 0...1
}

final class UploaderView: UIView {

    // MARK: - 回调

    /// 点击添加按钮（宿主调起选择器后向 value 追加 UploadItem）。
    var onAdd: (() -> Void)?
    /// 点击删除角标（宿主从 value 删除 index 项）。
    var onRemove: ((Int) -> Void)?
    /// 点击失败项（宿主重置 status 为 uploading 重新上传）。
    var onRetry: ((Int) -> Void)?

    // MARK: - 受控属性

    /// 文件列表（受控必传，外部赋值=同步刷新）。
    var value: [UploadItem] {
        didSet { collectionView.reloadData() }
    }

    /// 最大文件数（默认 9，达上限隐藏添加格）。
    var maxCount: Int {
        didSet { collectionView.reloadData() }
    }

    /// 禁用（整件 alpha0.4，添加/删除/重试均不可点）。
    var disabled: Bool {
        didSet {
            alpha = disabled ? 0.4 : 1
            collectionView.isUserInteractionEnabled = !disabled
        }
    }

    // MARK: - 常量

    private static let columns = 4
    private static let spacing: CGFloat = AppSpace.sm  // 8
    private static let cellRadius: CGFloat = AppRadius.sm  // 6
    private static let deleteSize: CGFloat = 16
    private static let progressHeight: CGFloat = 3

    // MARK: - 子视图

    private let layout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView

    // MARK: - init

    init(value: [UploadItem] = [], maxCount: Int = 9, disabled: Bool = false,
         onAdd: (() -> Void)? = nil, onRemove: ((Int) -> Void)? = nil,
         onRetry: ((Int) -> Void)? = nil) {
        self.value = value
        self.maxCount = maxCount
        self.disabled = disabled
        self.onAdd = onAdd
        self.onRemove = onRemove
        self.onRetry = onRetry

        layout.minimumInteritemSpacing = Self.spacing
        layout.minimumLineSpacing = Self.spacing
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)

        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UploaderCell.self, forCellWithReuseIdentifier: "UploaderCell")
        collectionView.register(UploaderAddCell.self, forCellWithReuseIdentifier: "UploaderAddCell")
        addSubview(collectionView)

        alpha = disabled ? 0.4 : 1
        collectionView.isUserInteractionEnabled = !disabled
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("UploaderView 不支持 initWithCoder 解码。")
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        let totalSpacing = Self.spacing * CGFloat(Self.columns - 1)
        let cellSize = (bounds.width - totalSpacing) / CGFloat(Self.columns)
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
    }

    override var intrinsicContentSize: CGSize {
        // 行数 = ceil((value.count + addButtonCount) / columns)
        let addCount = (value.count < maxCount) ? 1 : 0
        let totalItems = value.count + addCount
        let rows = ceil(CGFloat(totalItems) / CGFloat(Self.columns))
        let cellSize: CGFloat = 80  // 估算，实际由 layoutSubviews 计算
        let height = rows * cellSize + (rows - 1) * Self.spacing
        return CGSize(width: UIView.noIntrinsicMetric, height: max(0, height))
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension UploaderView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let addCount = (value.count < maxCount) ? 1 : 0
        return value.count + addCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < value.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploaderCell", for: indexPath) as! UploaderCell
            let item = value[indexPath.item]
            cell.configure(with: item)
            cell.onDelete = { [weak self] in
                self?.onRemove?(indexPath.item)
            }
            cell.onRetry = { [weak self] in
                self?.onRetry?(indexPath.item)
            }
            return cell
        } else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "UploaderAddCell", for: indexPath) as! UploaderAddCell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < value.count {
            let item = value[indexPath.item]
            if item.status == .failed {
                onRetry?(indexPath.item)
            }
        } else {
            onAdd?()
        }
    }
}

// MARK: - 文件 Cell

private final class UploaderCell: UICollectionViewCell {

    var onDelete: (() -> Void)?
    var onRetry: (() -> Void)?

    private let thumbnailView = UIImageView()
    private let deleteButton = UIButton(type: .custom)
    private let statusLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let maskView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = AppColor.bgPage
        contentView.layer.cornerRadius = UploaderView.cellRadius
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppColor.border.cgColor

        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        contentView.addSubview(thumbnailView)

        // 删除角标
        deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        deleteButton.setTitle("×", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 11)
        deleteButton.layer.cornerRadius = UploaderView.deleteSize / 2
        deleteButton.layer.masksToBounds = true
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)

        // 状态蒙层
        maskView.isHidden = true
        contentView.addSubview(maskView)

        statusLabel.textColor = .white
        statusLabel.font = .systemFont(ofSize: 10)
        statusLabel.textAlignment = .center
        maskView.addSubview(statusLabel)

        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressView.progressTintColor = AppColor.primary
        progressView.isHidden = true
        maskView.addSubview(progressView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailView.frame = contentView.bounds
        let ds = UploaderView.deleteSize
        deleteButton.frame = CGRect(x: contentView.bounds.width - ds - 2, y: 2, width: ds, height: ds)
        maskView.frame = contentView.bounds
        statusLabel.frame = CGRect(x: 0, y: 0, width: maskView.bounds.width, height: maskView.bounds.height - UploaderView.progressHeight)
        progressView.frame = CGRect(x: 0, y: maskView.bounds.height - UploaderView.progressHeight,
                                    width: maskView.bounds.width, height: UploaderView.progressHeight)
    }

    func configure(with item: UploadItem) {
        // 缩略图
        if let path = item.localPath, let image = UIImage(contentsOfFile: path) {
            thumbnailView.image = image
        } else if let url = item.thumbnailUrl, let nsurl = URL(string: url) {
            // 网络图片：宿主可注入图片库，此处仅占位（实际由宿主预处理 localPath）
            thumbnailView.image = nil
            // 简单异步加载（生产环境建议宿主用 SDWebImage/Kingfisher）
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: nsurl), let img = UIImage(data: data) {
                    DispatchQueue.main.async { self.thumbnailView.image = img }
                }
            }
        } else {
            thumbnailView.image = nil
        }

        // 状态
        switch item.status {
        case .pending, .success:
            maskView.isHidden = true
            progressView.isHidden = true
            deleteButton.isHidden = (item.status == .pending)
        case .uploading:
            maskView.isHidden = false
            maskView.backgroundColor = AppColor.primary.withAlphaComponent(0.8)
            statusLabel.text = "上传中"
            progressView.isHidden = false
            progressView.progress = item.progress
            deleteButton.isHidden = true
        case .failed:
            maskView.isHidden = false
            maskView.backgroundColor = AppColor.error.withAlphaComponent(0.8)
            statusLabel.text = "失败"
            progressView.isHidden = true
            deleteButton.isHidden = true
        }
    }

    @objc private func deleteTapped() { onDelete?() }
}

// MARK: - 添加 Cell

private final class UploaderAddCell: UICollectionViewCell {

    private let plusLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = AppColor.bgPage
        contentView.layer.cornerRadius = UploaderView.cellRadius
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppColor.border.cgColor

        // dashed border
        let border = CAShapeLayer()
        border.strokeColor = AppColor.textSecondary.withAlphaComponent(0.3).cgColor
        border.fillColor = nil
        border.lineDashPattern = [4, 4]
        border.lineWidth = 1
        contentView.layer.addSublayer(border)

        plusLabel.text = "+"
        plusLabel.textColor = AppColor.textSecondary
        plusLabel.font = .systemFont(ofSize: AppFont.sizeXl)
        plusLabel.textAlignment = .center
        contentView.addSubview(plusLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        plusLabel.frame = contentView.bounds
        if let border = contentView.layer.sublayers?.first as? CAShapeLayer {
            border.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: UploaderView.cellRadius).cgPath
            border.frame = contentView.bounds
        }
    }
}
