/// 记账分类网格（M3.2）。

import UIKit
import SnapKit

/// M3.2 分类选择网格。
///
/// 五列展示收支分类，选中后通过 `onSelect` 回调。
final class CategoryPickerView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onSelect: ((BookkeepingCategory) -> Void)?

    private var categories: [BookkeepingCategory] = []
    private var selectedName: String?
    private let collectionView: UICollectionView

    /// 初始化集合适图与布局。
    ///
    /// - Parameter frame: 初始 frame
    /// - Returns: 无
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = AppSpace.sm
        layout.minimumLineSpacing = AppSpace.md
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)

        backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseId)
        collectionView.showsVerticalScrollIndicator = false
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(AppSpace.lg)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 刷新分类数据与选中态。
    ///
    /// - Parameters:
    ///   - categories: 分类列表
    ///   - selectedName: 当前选中分类名，可为 nil
    /// - Returns: 无
    func apply(categories: [BookkeepingCategory], selectedName: String?) {
        self.categories = categories
        self.selectedName = selectedName
        collectionView.reloadData()
    }

    /// 取消分类选中高亮（弹层取消 / 点空白时调用）。
    func clearSelection() {
        guard selectedName != nil else { return }
        selectedName = nil
        collectionView.reloadData()
    }

    /// 返回 item 数量。
    ///
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - section: Section 索引
    /// - Returns: 分类数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    /// 配置分类 Cell。
    ///
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - indexPath: 索引路径
    /// - Returns: 配置好的 Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseId, for: indexPath) as! CategoryCell
        let item = categories[indexPath.item]
        cell.apply(item, selected: item.name == selectedName)
        return cell
    }

    /// 处理分类选中。
    ///
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - indexPath: 索引路径
    /// - Returns: 无
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = categories[indexPath.item]
        selectedName = item.name
        collectionView.reloadData()
        onSelect?(item)
    }

    /// 计算五列网格 item 尺寸。
    ///
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - collectionViewLayout: 布局
    ///   - indexPath: 索引路径
    /// - Returns: item 尺寸
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = 5
        let spacing = AppSpace.sm * (columns - 1)
        let available = collectionView.bounds.width > 1
            ? collectionView.bounds.width
            : UIScreen.main.bounds.width - AppSpace.lg * 2
        let width = floor((available - spacing) / columns)
        return CGSize(width: max(width, 56), height: 64)
    }
}

/// 分类网格单元 Cell。
private final class CategoryCell: UICollectionViewCell {
    static let reuseId = "CategoryCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    /// 初始化 Cell 布局。
    ///
    /// - Parameter frame: 初始 frame
    /// - Returns: 无
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppColor.textPrimary

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        contentView.addSubview(stack)
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 绑定分类与选中态样式。
    ///
    /// - Parameters:
    ///   - category: 分类实体
    ///   - selected: 是否选中
    /// - Returns: 无
    func apply(_ category: BookkeepingCategory, selected: Bool) {
        titleLabel.text = category.name
        iconView.image = CategoryIconImage.image(assetName: category.assetName, symbolName: category.symbolName)
        iconView.tintColor = selected ? AppColor.primary : AppColor.textSecondary
        titleLabel.textColor = selected ? AppColor.primary : AppColor.textPrimary
        contentView.backgroundColor = selected ? AppColor.primaryMuted : .clear
        contentView.layer.cornerRadius = AppRadius.md
    }
}
