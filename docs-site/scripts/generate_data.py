#!/usr/bin/env python3
"""Generate src/data/catalog.json for the Ant Design docs site."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

DOCS_SITE = Path(__file__).resolve().parents[1]
TMO = DOCS_SITE.parent
CATALOG = TMO / "catalog" / "components.jsonl"
VIS_SRC = TMO / "catalog" / "visuals"
# 唯一 Token 源：组件库 design-token/tokens.json（迁移后统一收口，不再读业务 App 内 tokens）
TOKENS = TMO / "design-token" / "tokens.json"
# 版本日志唯一数据源：组件库根 CHANGELOG.md（官方文档「版本日志」页）
CHANGELOG = TMO / "CHANGELOG.md"
OUT_JSON = DOCS_SITE / "src" / "data" / "catalog.json"
OUT_VIS = DOCS_SITE / "public" / "visuals"

# 官方文档 meta：版本 / 平台 / 命名空间 / 仓库 / 快速引用信息
META = {
  "name": "Native-UI-Comps",
  "fullName": "OPC Native UI Components",
  "tagline": "记账产品线的原生双端组件库（iOS + Android），覆盖基础组件、底层能力与业务拼装",
  "version": "1.0.0",
  "namespaceAndroid": "com.zhiqihuayun",
  "groupAndroid": "com.zhiqihuayun:components",
  "spmProduct": "Native-UI-Comps",
  "repo": "ProductRDDept_TechMiddleOffice_Native-UI-Comps",
  "platforms": ["ios", "android", "harmony", "weixin", "alipay"],
  "sources": {
    "android": "android",
    "ios": "ios",
    "designToken": "design-token/tokens.json",
    "catalog": "catalog/components.jsonl",
  },
}

CAT_META = {
  "basic": {
    "title": "基础组件",
    "blurb": "高度可复用 UI；名称对齐 Ant / Apple 等业内称谓",
  },
  "foundation": {
    "title": "底层能力",
    "blurb": "换 App 仍可复用的路由/存储/主题/网络/金额格式等基建（不含域仓储）",
  },
  "business": {
    "title": "业务组件 / 业务拼装",
    "blurb": "域仓储、页级拼装、本 App 配置与脚手架；跨产品几乎无复用",
  },
}

# props/events/demos keyed by new id
CONTRACTS = {
  "basic.empty": {
    "props": [["message", "string", "是", "空态文案"], ["icon?", "ReactNode", "否", "插图"]],
    "events": [],
    "demos": [["基础", '<Empty description="暂无流水" />']],
  },
  "basic.date-picker-month": {
    "props": [["value", "YearMonth", "是", "当前年月"], ["picker", "'month'", "是", "固定为 month"]],
    "events": [["onChange", "(value) => void", "确认"]],
    "demos": [["月份", '<DatePicker picker="month" value={ym} onChange={...} />']],
  },
  "basic.date-picker-year": {
    "props": [["value", "number", "是", "年"], ["picker", "'year'", "是", "固定为 year"]],
    "events": [["onChange", "(year) => void", "确认"]],
    "demos": [["年份", '<DatePicker picker="year" />']],
  },
  "basic.date-picker": {
    "props": [["value", "Date", "是", "日期"]],
    "events": [["onChange", "(date) => void", "确认"]],
    "demos": [["日期", "<DatePicker value={date} onChange={...} />"]],
  },
  "basic.picker": {
    "props": [["options", "{label,value}[]", "是", "选项"], ["value", "string", "是", "选中值"]],
    "events": [["onChange", "(value) => void", "确认"]],
    "demos": [["选择", "<Picker options={...} value={...} onChange={...} />"]],
  },
  "basic.webview": {
    "props": [["title", "string", "是", "标题"], ["src", "string", "是", "URL"]],
    "events": [],
    "demos": [["H5", '<WebView title="帮助" src={url} />']],
  },
  "basic.segmented": {
    "props": [
      ["options", "{label,value}[]", "是", "分段"],
      ["value", "string", "是", "选中"],
      ["size?", "large|middle|small", "否", "尺寸"],
    ],
    "events": [["onChange", "(value) => void", "切换"]],
    "demos": [
      ["收支", '<Segmented options={["支出","收入"]} value={v} onChange={...} />'],
      ["周月年", '<Segmented options={["周","月","年"]} />'],
    ],
  },
  "basic.list-item": {
    "props": [
      ["title", "ReactNode", "是", "主文案"],
      ["description?", "ReactNode", "否", "描述"],
      ["extra?", "ReactNode", "否", "右侧"],
    ],
    "events": [["onClick", "() => void", "点击"]],
    "demos": [["设置行", '<List.Item extra=">" onClick={...}>设置</List.Item>']],
  },
  "basic.list": {
    "props": [["dataSource", "T[]", "是", "数据"], ["renderItem", "(item)=>Node", "是", "行渲染"]],
    "events": [],
    "demos": [["分组列表", "<List dataSource={rows} renderItem={...} />"]],
  },
  "basic.refresh": {
    "props": [["refreshing", "boolean", "是", "刷新中"]],
    "events": [["onRefresh", "() => void", "下拉触发"]],
    "demos": [["列表", "<PullToRefresh onRefresh={reload}>{list}</PullToRefresh>"]],
  },
  "basic.navbar": {
    "props": [["title", "string", "是", "标题"], ["back?", "boolean", "否", "返回"]],
    "events": [["onBack", "() => void", "返回"]],
    "demos": [["二级页", '<NavigationBar title="账单" back onBack={pop} />']],
  },
  "basic.icon": {
    "props": [["name", "string", "是", "图标名"], ["size?", "number", "否", "尺寸"]],
    "events": [],
    "demos": [["图标", '<Icon name="list" />']],
  },
  "basic.grid": {
    "props": [["column", "number", "否", "列数"], ["data", "{icon,text,id}[]", "是", "项"]],
    "events": [["onClick", "(id) => void", "点击"]],
    "demos": [["宫格", "<Grid column={4} data={shortcuts} onClick={...} />"]],
    "note": "多格入口矩阵；单块容器用 Card",
  },
  "basic.card": {
    "props": [["title", "ReactNode", "是", "标题"], ["extra?", "ReactNode", "否", "右上"], ["children", "ReactNode", "否", "内容"]],
    "events": [["onClick?", "() => void", "整卡点击"]],
    "demos": [["卡片", '<Card title="账单" extra=">" onClick={open}>...</Card>']],
    "note": "单块可点容器；多入口用 Grid",
  },
  "basic.avatar": {
    "props": [["src?", "string", "否", "图片"], ["text?", "string", "否", "文字头像"], ["size?", "number", "否", "尺寸"]],
    "events": [],
    "demos": [["头像", '<Avatar>小</Avatar>']],
  },
  "basic.progress-circle": {
    "props": [["percent", "number", "是", "0-100"], ["type", "'circle'", "是", "环形"]],
    "events": [],
    "demos": [["环形", '<Progress type="circle" percent={35} />']],
  },
  "basic.shortcut-bar": {
    "props": [["items", "{id,icon,text}[]", "是", "入口"], ["columns?", "number", "否", "列数"]],
    "events": [["onClick", "(id) => void", "点击"]],
    "demos": [["快捷栏", "<ShortcutBar / Grid items={...} onClick={...} />"]],
  },
  "basic.grid-picker": {
    "props": [["data", "{id,icon,text}[]", "是", "选项"], ["value?", "string", "否", "选中"], ["column?", "number", "否", "列数"]],
    "events": [["onChange", "(id) => void", "选中"]],
    "demos": [["分类选择", "<GridPicker data={categories} onChange={...} />"]],
  },
  "basic.line-chart": {
    "props": [["series", "{name,data}[]", "是", "序列"], ["xField?", "string", "否", "横轴"]],
    "events": [["onPointClick?", "(p) => void", "点选"]],
    "demos": [["折线", "<LineChart series={[{name:'支出',data:...}]} />"]],
  },
  "basic.split": {
    "props": [["left", "ReactNode", "是", "左侧"], ["right", "ReactNode", "是", "右侧"]],
    "events": [["onClick?", "() => void", "点击"]],
    "demos": [["双栏", '<Split left="07月23日" right="支 23  收 7000" />']],
  },
  "foundation.design-tokens": {
    "props": [["tokens", "TokenSet", "是", "主题变量"]],
    "events": [],
    "demos": [["应用", "applyDesignTokens(tokens)"]],
  },
  "foundation.router": {
    "props": [["to", "Route", "是", "目标"]],
    "events": [["navigate", "(to) => void", "跳转"]],
    "demos": [["跳转", "router.push('/bill')"]],
  },
  "foundation.storage": {
    "props": [],
    "events": [],
    "demos": [["数据库", "Storage.shared / AppDatabase"]],
  },
  "foundation.http-client": {"props": [], "events": [], "demos": [["请求", "http.get('/health')"]]},
  "foundation.money-format": {
    "props": [["value", "number", "是", "金额"], ["currency?", "string", "否", "币种，默认 CNY"]],
    "events": [],
    "demos": [["金额", "formatMoney(230.4)"]],
    "note": "暂为货币工具；完整 i18n 方案后再统一抽象",
  },
  "foundation.calendar": {"props": [], "events": [], "demos": [["区间", "monthRange(2026, 7)"]]},
  "foundation.system-bars": {
    "props": [["style", "light|dark", "是", "样式"]],
    "events": [],
    "demos": [["状态栏", "setSystemBars('light')"]],
  },
  "business.amount-keyboard": {
    "props": [["value", "string", "是", "金额表达式"], ["date", "Date", "是", "日期"]],
    "events": [["onKey", "(k)=>void", "按键"], ["onConfirm", "()=>void", "确认"]],
    "demos": [["记账键盘", "<AmountKeyboard value={expr} onConfirm={save} />"]],
    "note": "业务定制，不作为跨 App 基础组件",
  },
  "business.family-bill-invite": {
    "props": [["mode", "create|join", "是", "模式"]],
    "events": [["onShare", "(key)=>void", "分享"], ["onJoined", "()=>void", "加入"]],
    "demos": [["邀请", "<FamilyBillInvite mode=\"create\" />"]],
    "note": "业务页级拼装（多组件组合）",
  },
  "business.feedback-list": {
    "props": [["items", "Feedback[]", "是", "列表"]],
    "events": [["onOpen", "(id)=>void", "打开"]],
    "demos": [["反馈", "<FeedbackList items={...} />"]],
    "note": "业务页级拼装（多组件组合）",
  },
  "business.repository-transaction": {
    "props": [],
    "events": [],
    "demos": [["查询", "transactionRepo.list(month)"]],
    "note": "记账域仓储，非底层能力",
  },
  "business.repository-budget": {
    "props": [],
    "events": [],
    "demos": [["查询", "budgetRepo.get(month)"]],
    "note": "记账域仓储，非底层能力",
  },
  "business.repository-asset": {
    "props": [],
    "events": [],
    "demos": [["查询", "assetRepo.list()"]],
    "note": "记账域仓储，非底层能力",
  },
  "business.content-config": {
    "props": [],
    "events": [],
    "demos": [["配置", "contentConfig.helpURL"]],
    "note": "本 App 产品配置",
  },
  "business.fixtures": {
    "props": [],
    "events": [],
    "demos": [["种子", "loadFixtures()"]],
    "note": "工程脚手架/演示数据",
  },
  "business.statistic": {
    "props": [["title", "string", "是", "指标名"], ["value", "string|number", "是", "数值"], ["group?", "Statistic[]", "否", "多指标"]],
    "events": [["onPeriodClick?", "() => void", "点周期"]],
    "demos": [["汇总", '<Statistic.Group items={[{title:"收入",value:"¥12000"},{title:"支出",value:"¥230"}]} />']],
    "note": "当前形态强业务，未抽成通用原子前留在 business",
  },
}


_CHANGE_TYPES = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security"]


def parse_changelog(text: str) -> list[dict]:
    """解析 CHANGELOG.md（Keep a Changelog 格式）为结构化版本日志。"""
    releases: list[dict] = []
    current: dict | None = None
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("## ["):
            if current:
                releases.append(current)
            version, date = line[4:].split("] - ")
            version = version.strip()
            # 过滤 CHANGELOG 顶部格式说明里的示例占位行
            if "版本号" in version or "VERSION" in version.upper():
                current = None
                continue
            current = {"version": version, "date": date.strip(), "groups": {}}
        elif current and line.startswith("### "):
            group = line[4:].strip()
            if group in _CHANGE_TYPES:
                current["groups"][group] = []
                current["_group"] = group
        elif current and line.startswith("- "):
            g = current.get("_group")
            if g and g in current["groups"]:
                current["groups"][g].append(line[2:].strip())
    if current:
        releases.append(current)
    return releases


def _extract_used_in_apps(comp: dict) -> list[str]:
    explicit = comp.get("used_in_apps")
    if explicit:
      return explicit
    apps: set[str] = set()
    source_refs = comp.get("source_refs") or {}
    if isinstance(source_refs, dict):
      for key, val in source_refs.items():
        if key == "note" or not isinstance(val, str):
          continue
        parts = val.replace("\\", "/").split("/")
        for i, part in enumerate(parts):
          if part == "App" and i + 1 < len(parts):
            apps.add(parts[i + 1])
            break
    if not apps and source_refs:
      apps.add("KeepAccounts")
    return sorted(apps)


def main() -> None:
  OUT_VIS.mkdir(parents=True, exist_ok=True)
  OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
  if VIS_SRC.exists():
    for p in VIS_SRC.glob("*.png"):
      shutil.copy2(p, OUT_VIS / p.name)

  comps = [json.loads(l) for l in CATALOG.read_text(encoding="utf-8").splitlines() if l.strip()]
  tokens = json.loads(TOKENS.read_text(encoding="utf-8")) if TOKENS.exists() else {}

  docs = []
  for c in comps:
    cid = c["id"]
    contract = CONTRACTS.get(cid, {"props": [], "events": [], "demos": []})
    vrefs = c.get("visual_refs") or []
    vfile = Path(vrefs[0]).name if vrefs else None
    if vfile and not (OUT_VIS / vfile).exists():
      vfile = None

    emb = None
    emb_ref = c.get("embedding_ref")
    if emb_ref:
      emb_path = TMO / emb_ref
      if emb_path.exists():
        emb = json.loads(emb_path.read_text(encoding="utf-8")).get("vector")

    docs.append({
      "id": cid,
      "legacyId": c.get("legacy_id"),
      "name": c["name"],
      "category": c["category"],
      "summary": c["summary"],
      "industryNames": c.get("industry_names") or [],
      "searchText": c.get("search_text") or c["name"],
      "capabilities": c.get("capabilities") or [],
      "platforms": c.get("platforms") or {},
      "usedInApps": _extract_used_in_apps(c),
      "status": c.get("status", "stable"),
      "note": contract.get("note", ""),
      "props": contract.get("props", []),
      "events": contract.get("events", []),
      "demos": contract.get("demos", []),
      "image": f"/visuals/{vfile}" if vfile else None,
      "vector": emb,
    })

  index_path = TMO / "catalog" / "embeddings" / "index.json"
  index = json.loads(index_path.read_text(encoding="utf-8")) if index_path.exists() else {}

  # 平台实现状态统计（用于首页/契约矩阵展示）
  platform_state = {p: {"available": 0, "partial": 0, "unavailable": 0} for p in META["platforms"]}
  for d in docs:
    for p, st in (d.get("platforms") or {}).items():
      if p in platform_state:
        platform_state[p][st.get("state", "unavailable")] += 1

  changelog = parse_changelog(CHANGELOG.read_text(encoding="utf-8")) if CHANGELOG.exists() else []
  for rel in changelog:
    rel.pop("_group", None)

  payload = {
    "meta": META,
    "backend": index.get("backend", "hash-v1"),
    "dim": index.get("dim", 256),
    "categories": CAT_META,
    "categoryOrder": ["basic", "foundation", "business"],
    "tokens": tokens,
    "components": docs,
    "platformState": platform_state,
    "changelog": changelog,
  }
  OUT_JSON.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
  print(f"wrote {OUT_JSON} ({len(docs)} components)")


if __name__ == "__main__":
  main()
