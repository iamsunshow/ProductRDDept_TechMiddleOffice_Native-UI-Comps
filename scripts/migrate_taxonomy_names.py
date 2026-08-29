#!/usr/bin/env python3
"""Migrate catalog to 3-way taxonomy + industry-aligned names."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

TMO = Path(__file__).resolve().parents[1]
CATALOG = TMO / "catalog" / "components.jsonl"
EMB_DIR = TMO / "catalog" / "embeddings"
VIS = TMO / "catalog" / "visuals"

# old_id -> new metadata
# category: basic | foundation | business
# name: 「中文 English」业内可识别
# industry: Apple HIG / Ant Design / 通用称谓
MIGRATE = {
  "ui.empty-state": {
    "id": "basic.empty",
    "name": "空状态 Empty",
    "category": "basic",
    "summary": "无数据时的占位提示（对标 Ant Empty / HIG Empty State）",
    "industry": ["Empty", "EmptyState"],
  },
  "ui.month-picker": {
    "id": "basic.date-picker-month",
    "name": "日期选择·月 DatePicker",
    "category": "basic",
    "summary": "按月选择（DatePicker 的 month 变体；对标 Ant DatePicker / UIDatePicker）",
    "industry": ["DatePicker", "MonthPicker", "UIDatePicker"],
  },
  "ui.year-picker": {
    "id": "basic.date-picker-year",
    "name": "日期选择·年 DatePicker",
    "category": "basic",
    "summary": "按年选择（DatePicker 的 year 变体）",
    "industry": ["DatePicker", "YearPicker"],
  },
  "ui.date-picker": {
    "id": "basic.date-picker",
    "name": "日期选择 DatePicker",
    "category": "basic",
    "summary": "选择具体日期（对标 Ant DatePicker / UIDatePicker）",
    "industry": ["DatePicker", "UIDatePicker"],
  },
  "ui.option-picker": {
    "id": "basic.picker",
    "name": "选择器 Picker",
    "category": "basic",
    "summary": "单列选项选择（对标 UIPickerView / Ant Select·Picker）",
    "industry": ["Picker", "Select", "UIPickerView"],
  },
  "ui.web-content": {
    "id": "basic.webview",
    "name": "网页容器 WebView",
    "category": "basic",
    "summary": "内嵌 H5 页面（对标 WKWebView / Android WebView）",
    "industry": ["WebView", "WKWebView"],
  },
  "ui.segment-control": {
    "id": "basic.segmented",
    "name": "分段控制器 SegmentedControl",
    "category": "basic",
    "summary": "页内互斥分段切换（口语常称 Tab；不同于底部 TabBar 多页导航。对标 UISegmentedControl / Ant Segmented）",
    "industry": ["SegmentedControl", "Segmented", "UISegmentedControl", "Tab", "分段 Tab"],
  },
  "ui.list-row": {
    "id": "basic.list-item",
    "name": "列表项 ListItem",
    "category": "basic",
    "summary": "设置类列表单行：左标题 / 右值或箭头（对标 Ant List.Item；不是流水行）",
    "industry": ["List.Item", "ListItem", "UITableViewCell", "Cell"],
  },
  "ui.list-group": {
    "id": "basic.list",
    "name": "列表 List",
    "category": "basic",
    "summary": "分组列表容器（对标 Ant List / UITableView plain/grouped）",
    "industry": ["List", "UITableView"],
  },
  "ui.pull-refresh": {
    "id": "basic.refresh",
    "name": "下拉刷新 Refresh",
    "category": "basic",
    "summary": "列表下拉刷新（对标 UIRefreshControl / PullToRefresh）",
    "industry": ["RefreshControl", "PullToRefresh", "UIRefreshControl"],
  },
  "ui.top-bar": {
    "id": "basic.navbar",
    "name": "导航栏 NavigationBar",
    "category": "basic",
    "summary": "页顶导航（对标 UINavigationBar / Ant PageHeader·AppBar）",
    "industry": ["NavigationBar", "AppBar", "UINavigationBar", "TopAppBar"],
  },
  "ui.sf-icons": {
    "id": "basic.icon",
    "name": "图标 Icon",
    "category": "basic",
    "summary": "图标资源（对标 SF Symbols / Ant Icon）",
    "industry": ["Icon", "SF Symbols"],
  },
  "ui.summary-card-green": {
    "id": "business.statistic",
    "name": "汇总统计 Statistic",
    "category": "business",
    "summary": "记账页汇总头/多指标展示（当前形态强业务；未抽成通用 label+value 前不入 basic）",
    "industry": ["Statistic", "SummaryHeader"],
  },
  "ui.icon-grid-section": {
    "id": "basic.grid",
    "name": "宫格 Grid",
    "category": "basic",
    "summary": "多格图标入口矩阵（对标 Ant Grid / 九宫格；与单块 Card 不同）",
    "industry": ["Grid", "GridView"],
  },
  "ui.discover-summary-card": {
    "id": "basic.card",
    "name": "卡片 Card",
    "category": "basic",
    "summary": "单块可点击内容容器（对标 Ant Card；多入口矩阵用 Grid）",
    "industry": ["Card"],
  },
  "ui.zodiac-avatar": {
    "id": "basic.avatar",
    "name": "头像 Avatar",
    "category": "basic",
    "summary": "用户头像及附带信息行（对标 Ant Avatar）",
    "industry": ["Avatar"],
  },
  "ui.budget-ring": {
    "id": "basic.progress-circle",
    "name": "环形进度 Progress",
    "category": "basic",
    "summary": "环形进度指示（对标 Ant Progress type=circle）",
    "industry": ["Progress", "ProgressCircle", "Ring"],
  },
  # formerly pattern/domain but reusable → basic
  "domain.ledger-nav": {
    "id": "basic.shortcut-bar",
    "name": "快捷栏 ShortcutBar",
    "category": "basic",
    "summary": "横向图标快捷入口（对标宫格/快捷菜单，非「明细」专属）",
    "industry": ["Grid", "ShortcutBar", "ActionBar"],
  },
  "domain.category-picker": {
    "id": "basic.grid-picker",
    "name": "宫格选择 GridPicker",
    "category": "basic",
    "summary": "宫格中单选一项（Grid + Selection）",
    "industry": ["Grid", "Picker", "Select"],
  },
  "domain.trend-chart": {
    "id": "basic.line-chart",
    "name": "折线图 LineChart",
    "category": "basic",
    "summary": "折线数据图（对标 Charts LineChart / Ant Charts）",
    "industry": ["LineChart", "Chart", "DGCharts"],
  },
  # foundation
  "cap.design-tokens": {
    "id": "foundation.design-tokens",
    "name": "设计令牌 Design Tokens",
    "category": "foundation",
    "summary": "色板/字号/间距/圆角等主题变量",
    "industry": ["Design Tokens", "Theme"],
  },
  "cap.router": {
    "id": "foundation.router",
    "name": "路由 Router",
    "category": "foundation",
    "summary": "页面/Tab 导航路由",
    "industry": ["Router", "Navigator", "Navigation"],
  },
  "cap.storage-db": {
    "id": "foundation.storage",
    "name": "本地存储 Storage",
    "category": "foundation",
    "summary": "本地数据库封装（SQLite）",
    "industry": ["Storage", "Database", "SQLite"],
  },
  "cap.repo-transaction": {
    "id": "business.repository-transaction",
    "name": "仓储·流水 Repository",
    "category": "business",
    "summary": "记账流水数据访问层（域模型绑定，换 App 不可复用；通用 Storage 见 foundation.storage）",
    "industry": ["Repository", "DAO", "TransactionRepository"],
  },
  "cap.repo-budget": {
    "id": "business.repository-budget",
    "name": "仓储·预算 Repository",
    "category": "business",
    "summary": "预算数据访问层（记账域业务，非底层能力）",
    "industry": ["Repository", "DAO", "BudgetRepository"],
  },
  "cap.repo-asset": {
    "id": "business.repository-asset",
    "name": "仓储·资产 Repository",
    "category": "business",
    "summary": "资产账户数据访问层（记账域业务，非底层能力）",
    "industry": ["Repository", "DAO", "AssetRepository"],
  },
  "cap.network-mock": {
    "id": "foundation.http-client",
    "name": "网络客户端 HTTP Client",
    "category": "foundation",
    "summary": "HTTP/API 客户端（当前为 Mock）",
    "industry": ["HTTP Client", "API Client", "Networking"],
  },
  "cap.formatters": {
    "id": "foundation.money-format",
    "name": "金额格式化 MoneyFormat",
    "category": "foundation",
    "summary": "货币金额展示格式（暂独立工具；语言/温度/度量等国际化方案落地后再统一抽象）",
    "industry": ["MoneyFormatter", "CurrencyFormat", "NumberFormatter"],
  },
  "cap.calendar-month": {
    "id": "foundation.calendar",
    "name": "日历工具 Calendar",
    "category": "foundation",
    "summary": "自然月/日期区间计算",
    "industry": ["Calendar", "DateUtils"],
  },
  "cap.legal-content-config": {
    "id": "business.content-config",
    "name": "内容配置 ContentConfig",
    "category": "business",
    "summary": "本 App 协议/帮助等 H5 地址配置（产品配置，非可复用基建）",
    "industry": ["App Config", "Legal URLs"],
  },
  "cap.demo-fixtures": {
    "id": "business.fixtures",
    "name": "演示数据 Fixtures",
    "category": "business",
    "summary": "本 App 本地演示/种子数据加载（工程脚手架，非底层能力）",
    "industry": ["Fixtures", "Seed Data"],
  },
  "cap.system-bars": {
    "id": "foundation.system-bars",
    "name": "系统栏 SystemBars",
    "category": "foundation",
    "summary": "状态栏/导航栏外观控制（背景色、图标深浅）；可与 Design Tokens/主题配合",
    "industry": ["StatusBar", "SystemBars"],
  },
  # business — no reuse intent
  "domain.bookkeeping-keyboard": {
    "id": "business.amount-keyboard",
    "name": "金额键盘 AmountKeyboard",
    "category": "business",
    "summary": "记账金额录入专用键盘（强业务，不跨产品复用）",
    "industry": [],
  },
  "domain.family-bill-key": {
    "id": "business.family-bill-invite",
    "name": "家庭账本邀请 FamilyBillInvite",
    "category": "business",
    "summary": "业务页级拼装：密钥生成/分享/加入流程（多组件组合，非原子 UI）",
    "industry": [],
  },
  "domain.feedback-status": {
    "id": "business.feedback-list",
    "name": "意见反馈 FeedbackList",
    "category": "business",
    "summary": "业务页级拼装：反馈列表与回复状态（多组件组合，非原子 UI）",
    "industry": [],
  },
}

# visual file rename map (optional keep old filenames, just update refs)
VIS_BY_OLD = {
  "ui.segment-control": "ui_segment-control.png",
  "ui.list-row": "ui_list-row.png",
  "ui.list-group": "ui_list-group.png",
  "ui.top-bar": "ui_top-bar.png",
  "ui.category-rank-cell": "ui_category-rank-cell.png",
  "ui.summary-card-green": "ui_summary-card-green.png",
  "ui.icon-grid-section": "ui_icon-grid-section.png",
  "ui.discover-summary-card": "ui_discover-summary-card.png",
  "ui.zodiac-avatar": "ui_zodiac-avatar.png",
  "ui.budget-ring": "ui_budget-card.png",
  "domain.ledger-nav": "domain_ledger-nav.png",
  "domain.transaction-cell": "domain_transaction-cell.png",
  "domain.category-picker": "domain_category-picker.png",
  "domain.trend-chart": "domain_trend-chart.png",
}


def main() -> None:
  rows = []
  with CATALOG.open(encoding="utf-8") as f:
    for line in f:
      if line.strip():
        rows.append(json.loads(line))

  out = []
  for c in rows:
    old = c["id"]
    m = MIGRATE.get(old)
    if not m:
      print("WARN unmapped", old)
      out.append(c)
      continue
    new_id = m["id"]
    industry = m.get("industry") or []
    caps = list(dict.fromkeys((c.get("capabilities") or []) + industry + [m["name"], new_id]))
    vfile = VIS_BY_OLD.get(old)
    visual_refs = [f"catalog/visuals/{vfile}"] if vfile and (VIS / vfile).exists() else []
    emb_name = new_id.replace(".", "_") + ".json"
    emb_rel = f"catalog/embeddings/{emb_name}"

    search_bits = [
      new_id,
      m["name"],
      m["summary"],
      m["category"],
      " ".join(industry),
      " ".join(caps),
      old,  # keep legacy searchable
    ]
    nc = {
      **c,
      "id": new_id,
      "legacy_id": old,
      "name": m["name"],
      "category": m["category"],
      "summary": m["summary"],
      "industry_names": industry,
      "capabilities": caps,
      "visual_refs": visual_refs,
      "embedding_ref": emb_rel,
      "search_text": " ".join(x for x in search_bits if x),
    }
    # fix deps ids if any
    deps = []
    for d in c.get("deps") or []:
      deps.append(MIGRATE[d]["id"] if d in MIGRATE else d)
    nc["deps"] = deps
    out.append(nc)

  # add split-row if missing
  if not any(x["id"] == "basic.split" for x in out):
    day = "ui_section-header-day.png"
    out.append({
      "id": "basic.split",
      "legacy_id": "ui.split-row",
      "name": "双栏行 Split",
      "category": "basic",
      "summary": "左主文案 + 右附属文案的行布局（对标 List 分区头/双端对齐行）",
      "industry_names": ["List Subheader", "Split Row"],
      "capabilities": ["Split", "双栏", "日头", "leading", "trailing"],
      "platforms": {
        "ios": {"state": "partial", "note": "明细日头等场景已用"},
        "android": {"state": "partial", "note": ""},
        "harmony": {"state": "unavailable", "note": ""},
        "weixin": {"state": "unavailable", "note": ""},
        "alipay": {"state": "unavailable", "note": ""},
      },
      "apis": "leading + trailing",
      "source_refs": {},
      "deps": [],
      "variants": [],
      "anti_goals": [],
      "visual_tokens": [],
      "visual_refs": [f"catalog/visuals/{day}"] if (VIS / day).exists() else [],
      "status": "draft",
      "embedding_ref": "catalog/embeddings/basic_split.json",
      "search_text": "basic.split 双栏行 Split List Subheader 日头部分组 leading trailing",
    })

  with CATALOG.open("w", encoding="utf-8") as f:
    for c in out:
      f.write(json.dumps(c, ensure_ascii=False) + "\n")

  # rewrite id map for docs
  map_path = TMO / "catalog" / "id-migration.json"
  map_path.write_text(
    json.dumps({k: v["id"] for k, v in MIGRATE.items()}, ensure_ascii=False, indent=2),
    encoding="utf-8",
  )
  print(f"migrated {len(out)} components → {CATALOG}")
  print(f"id map → {map_path}")


if __name__ == "__main__":
  main()
