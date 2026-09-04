# TMO 组件库 · 评审意见单 · Image 图片（门禁 A）

> 模板：`docs/验收流程/评审清单.md`。评审人直接在下方勾选 + 填备注，评审后在 `组件进度.md` 归档。

---

## 组件信息

| 项 | 值 |
|----|-----|
| 组件名 / id | 图片 Image / `ui.image`（历史：无 legacy） |
| 分类（subcategory） | 基础组件（api.json subcategory=basics，待门禁 B 定稿） |
| 阶段 | ☐ 设计评审（门禁 A）　☐ API 评审（门禁 B） |
| 评审人 | 用户（OPC 所有者） |
| 评审日期 | 2026-09-03 |
| 评审结论 | 待评审 |
| 评审产物位置 | `docs/数据与产物/design-spec/image-design-spec.html`（浏览器打开） |

---

## 一、设计评审清单（门禁 A）

> 验收方式：打开 HTML 设计规格页（浏览器），逐项目视打勾。

| # | 检查项 | 结论 |
|---|--------|------|
| 1 | 组件用途与场景描述清晰，与分类表一致（基础组件 / Image 图片，定位 = 增强版图片容器；不越界预览/裁剪/上传，预览归 #68 ImagePreview） | ☐ 通过　☐ 打回 |
| 2 | 能力范围表完整：fit 五值 / position 五值 / width/height / radius（token 档位+任意值+圆形）/ alt / loading/error 占位（可自定义）/ onTap/onLoad/onError（规格页 01 节）；lazy 与 URL 加载按决策点定范围 | ☐ 通过　☐ 打回 |
| 3 | 视觉可感知（04 节 fit 五模式同图对比渲染：fill 拉伸 / contain 留白 / cover 裁剪 / none 原尺寸 / scale-down 取小；position 停靠说明） | ☐ 通过　☐ 打回 |
| 4 | 五态齐全或 N/A 有依据（02 节：默认 / 禁用 N/A（无图片禁用语义）/ 加载 / 成功=加载完成态（视觉同默认）/ 失败占位+onError） | ☐ 通过　☐ 打回 |
| 5 | 尺寸规格全引 token（03/08 节：radius 档 6/10/14、占位灰阶 gray.6/15/25、字号 font.sizeSm、间距 space.sm；宽高为业务值非硬编码） | ☐ 通过　☐ 打回 |
| 6 | 交互细节完整（04 节：onTap 可选无默认按压态 / 占位不抖版 / 失败重设 src 自动重载 / hover、3D Touch、长按 N/A 归外层） | ☐ 通过　☐ 打回 |
| 7 | 双端差异已说明（05 节：contentMode vs ContentScale 映射、cornerRadius+masksToBounds vs Modifier.clip、Asset Catalog vs @DrawableRes；登记 `docs/平台差异.md`） | ☐ 通过　☐ 打回 |
| 8 | 与现有组件无重复（06 节：deps=[]；分类表 #5 双端未实现唯一入口；Cell/Avatar/Card 等消费方；ImagePreview #68 独立编号不重复） | ☐ 通过　☐ 打回 |
| 9 | 设计参考图可查看（本 H5：02 节五态渲染 + 03 节尺寸标注 + 04 节 fit 对比） | ☐ 通过　☐ 打回 |
| 10 | 决策点已给出建议与理由（07 节 P1–P4），评审拍板后写入 API 契约 / anti_goals | ☐ 通过　☐ 打回 |

**评审结论（门禁 A）：** ☐ ✅ 通过，冻结设计，进入 API 阶段　☐ ❌ 打回，返工设计

**备注 / 修改意见：**

**决策点结论（由评审人勾选，进入 API 契约）：**
| 决策点 | 结论 |
|--------|------|
| P1 网络图 URL 加载 | ☐ A 一期支持（iOS URLSession+NSCache；Android 引 Coil）　☐ B 一期仅本地，URL 归业务预下载　☐ C iOS 支持 / Android N/A |
| P2 lazy 懒加载 | ☐ A 一期实现　☐ B 一期 N/A（标注缺口） |
| P3 圆形快捷方式 | ☐ A 仅 radius=数值（=宽/2 即圆形）　☐ B 增 radius="circle" |
| P4 失败重试 | ☐ A 占位可点重试　☐ B 仅 onError，重试由业务改 src |

---

## 评审记录（归档用）

| 轮次 | 日期 | 阶段 | 结论 | 关键修改 |
|------|------|------|------|----------|
| 1 | 2026-09-03 | A | 待评审 | 设计规格 `image-design-spec.html` + 验收文档 `component-acceptance-image.md` 产出；决策点 P1–P4 待拍板 |
