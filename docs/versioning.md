# 版本规范（Versioning）

> **铁律：双端永远同一版本号。** iOS 与 Android 的版本号必须完全一致，
> 由根目录 `ui-version.json` 作为**全局唯一版本源**，禁止两端或业务工程手写版本号。

---

## 一、全局唯一版本源

- 文件：`ui-version.json`（组件库仓库根目录）。
- 结构：

```json
{
  "version": "1.0.0",
  "versionKey": "v1.0.0",
  "releaseDate": "2026-08-29",
  "changelog": "本次变更说明"
}
```

- **业务工程、iOS Package.swift、Android gradle、CI 一律从该文件读取版本号，禁止各自定义。**

---

## 二、语义化版本规则（SemVer）

版本号格式 `MAJOR.MINOR.PATCH`：

| 变更类型 | 版本段 | 示例 | 说明 |
|----------|:------:|------|------|
| Bug 修复 / 微调样式 | PATCH | `1.0.0 → 1.0.1` | 兼容，可静默升级 |
| 新增组件 / 新增属性（向后兼容） | MINOR | `1.0.0 → 1.1.0` | 兼容，新增能力 |
| 不兼容 API / 大规模重构 | MAJOR | `1.0.0 → 2.0.0` | 需业务配合改造 |

---

## 三、双端同步铁律

1. **一端变更，另一端即使无代码改动，也必须同步升版本**，保证双端版本号永远一致。
2. 以较大那端的版本段为准统一升级。
3. 任何一次发版，`ui-version.json` 的 `version` 与两端产物版本号三者完全一致。
4. 禁止双端出现 `1.0.1` / `1.0.0` 这样的错位。

---

## 四、版本应用位置（统一读取 `ui-version.json`）

| 端 | 应用位置 | 来源 |
|----|----------|------|
| iOS | `Package.swift` 的版本常量 | 读 `ui-version.json` |
| iOS | SPM Git Tag `vX.Y.Z` | 读 `ui-version.json` |
| Android | Gradle `versionName`/`versionCode` | 读 `ui-version.json` |
| Android | Maven 坐标版本号 | 读 `ui-version.json` |
| CI | 发布流水线校验 Tag == 配置版本 | 读 `ui-version.json` |

---

## 五、发版流程（含版本动作）

```
1. 修改 ui-version.json → 新版本号 + changelog
2. 运行 scripts/version_sync 同步全仓库版本引用
3. 子模块内单独 commit 全部变更
4. 打 Tag vX.Y.Z 并推送（触发 CI）
5. CI 校验 Tag == ui-version.json.version，不一致则拒绝发版
6. 回到 OPC 主仓，更新子模块指针（bump 提交）
```

---

## 六、禁止行为

- ❌ 双端版本号不一致。
- ❌ 业务工程手写版本号。
- ❌ 使用 `latest` / 动态模糊版本。
- ❌ 跳过 `ui-version.json` 直接改两端版本。
- ❌ 发版 Tag 与 `ui-version.json` 不一致仍强行发布。
