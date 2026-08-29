# 分类图标（与 iOS SF Symbol 视觉对齐）

由 `scripts/export_sf_category_icons.swift` 从系统 SF Symbol 导出。

- Android：`apps/android/app/src/main/res/drawable/ic_cat_*.png`
- iOS：`apps/ios/Resources/CategoryIcons.xcassets`

重新导出：

```bash
swift scripts/export_sf_category_icons.swift shared/category-icons
# 再复制到 Android drawable 与 iOS imageset
```
