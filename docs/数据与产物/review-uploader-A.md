# Uploader 上传 · 门禁 A 评审单（任务清单 #43 · 全新立项）

> 组件 ID：`ui.uploader` ｜ 设计规格：`design-spec/uploader-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区 #43 顺延单件；用户 2026-09-07 原话「通过，最后一个组件吧，Uploader」在 #42 TextArea 收编后指示接棒启动）
> 评审日期：2026-09-07 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=通用文件/图片上传 UI 组件（网格展示已选文件列表+添加/删除/重试回调，不内置系统选择器和网络上传逻辑=宿主职责）；与 Image 纯图片展示组件划界=Uploader 含上传状态机+交互；与 Avatar 头像圆形裁切划界；五态=pending/uploading/success/failed/disabled；anti_goals=内置选择器/上传逻辑=宿主职责，拖拽排序/大图预览=二期 |
| A2 | Token 零硬编码 | ✅ | 4 列网格 spacing spaceSm(8)、格子正方形 radiusSm(6) bgPage 底、添加格 1px dashed border(textSecondary30%) + 号 textTertiary sizeXl、删除角标 16 圆 rgba(0,0,0,.5) 白×11pt、上传中蒙层 primary 80%+白字+进度条 3pt、失败蒙层 error 80%+白字、进度条底 rgba(255,255,255,.3) 填充 primary、disabled alpha 0.4、maxCount 默认 9；全走 token 非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 纯 UI+交互回调（B 内置选择器平台差异大淘汰/C 内置上传逻辑业务强相关淘汰）；P2-A UploadItem 完整状态机{id,name,size,thumbnailUrl,localPath,status,progress}+value 受控必传（B 仅路径无状态淘汰/C 半受控宿主无数据源淘汰）；P3-A onAdd/onRemove/onRetry 三回调全覆盖（B 无重试体验差淘汰/C 内部状态机宿主无门淘汰）；P4-A 一期=网格+添加+删除+状态+进度+maxCount+disabled+demo 四段（拖拽排序/大图预览二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础多图上传（添加→pending→uploading 进度条→success 流转）；D2 单文件 maxCount=1（已有 1 张隐藏添加按钮+删除后重现）；D3 失败重试+disabled（失败点击 onRetry+整件灰锁）；D4 受控外部驱动（宿主直接改 value 列表同步刷新不触发回调） |
| A5 | 实现现状 | ✅ | 双端均无 Uploader 近似件=纯从零全新立项；api.json 无 ui.uploader 条目待门禁 B 立项登记；任务清单 #43 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：网格布局（UICollectionView vs LazyVerticalGrid）、图片加载库由宿主注入（UIImage vs Coil/Glide）、点击命中机制、状态回写（命令式 reloadData vs 声明式重组）、无障碍；尺寸单位与命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 内置文件选择器（系统相册/相机/文件选择器）=宿主职责；内置网络上传逻辑（URLSession/OkHttp+鉴权+断点续传）=宿主网络层；拖拽排序=二期；图片预览大图=二期或宿主自理；视频上传播放器=宿主自理=全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-07） |
| 下一步 | 门禁 B api.json ui.uploader 双端契约登记 → 双端独立组件实现（UploaderView.swift / Uploader.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
