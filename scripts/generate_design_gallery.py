# -*- coding: utf-8 -*-
"""Build a self-contained HTML design spec for all TMO components.

Uses real tokens from docs/design-token.json. Each component card has:
  - header (category badge + name + id)
  - component visual area (rendered with CSS/flex, no overlap)
  - dimension callouts placed OUTSIDE the visual box (not covering it)
  - a separate 5-state row below the visual
  - token reference footer
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOKENS = json.load(open(os.path.join(ROOT, "docs", "design-token.json"), encoding="utf-8"))
API = json.load(open(os.path.join(ROOT, "docs", "api.json"), encoding="utf-8"))

C = TOKENS["color"]
F = TOKENS["font"]
R = TOKENS["radius"]
S = TOKENS["space"]

SUB_TITLES = {
    "basics": "基础通用", "navigation": "导航", "input": "数据录入",
    "display": "数据展示", "feedback": "操作反馈",
}

CSS_COLORS = {k: v for k, v in C.items()}


def esc(t):
    return (t or "").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


# ---------------------------------------------------------------- shared CSS snippets

def card_css():
    return f"""
.component-card {{
  background: #fff; border: 1px solid {C['border']}; border-radius: {R['lg']}px;
  box-shadow: 0 2px 8px rgba(17,24,39,.05); overflow: hidden;
  display: flex; flex-direction: column;
}}
.card-head {{
  display: flex; justify-content: space-between; align-items: center;
  padding: 12px 16px; border-bottom: 1px solid {C['border']};
}}
.card-name {{ font-size: 15px; font-weight: 600; color: {C['textPrimary']}; }}
.card-badge {{
  font-size: 11px; font-weight: 600; color: #fff; background: {C['primary']};
  padding: 2px 10px; border-radius: 999px;
}}
.card-badge.foundation {{ background: {C['textSecondary']}; }}
.card-id {{ font-size: 12px; color: {C['primary']}; background: {C['primaryMuted']};
  padding: 2px 8px; border-radius: 999px; font-family: ui-monospace, Menlo, monospace; }}
.visual-wrap {{ position: relative; padding: 40px 56px 56px; background: {C['bgPage']};
  border-bottom: 1px solid {C['border']}; display: flex; justify-content: center; }}
.visual {{ position: relative; background: #fff; }}
"""


def callout_css():
    # Dimension callouts drawn OUTSIDE the visual (in .visual-wrap padding area).
    return """
.callout { position: absolute; font-size: 11px; color: #16A34A; font-weight: 600;
  font-family: ui-monospace, Menlo, monospace; white-space: nowrap; }
.callout.line { color: #16A34A; }
.callout::before, .callout::after { content: ''; position: absolute; height: 1px; background: #16A34A; }
.callout.top { left: 50%; top: 12px; transform: translateX(-50%); }
.callout.bottom { left: 50%; bottom: 10px; transform: translateX(-50%); }
.callout.left { left: 10px; top: 50%; transform: translateY(-50%) rotate(-90deg); }
.callout.right { right: 8px; top: 50%; transform: translateY(-50%) rotate(90deg); }
.callout.top::before, .callout.top::after { top: 50%; width: 40px; }
.callout.top::before { left: -44px; } .callout.top::after { right: -44px; }
.callout.bottom::before, .callout.bottom::after { bottom: 50%; width: 40px; }
.callout.bottom::before { left: -44px; } .callout.bottom::after { right: -44px; }
.callout.left::before, .callout.left::after { left: 50%; width: 1px; height: 40px; }
.callout.left::before { top: -44px; } .callout.left::after { bottom: -44px; }
.callout.right::before, .callout.right::after { left: 50%; width: 1px; height: 40px; }
.callout.right::before { top: -44px; } .callout.right::after { bottom: -44px; }
"""


def states_css():
    return """
.states-row { display: grid; grid-template-columns: repeat(5, 1fr); gap: 8px;
  padding: 16px; background: #fff; border-bottom: 1px solid #E5E7EB; }
.state-item { background: #F9FAFB; border: 1px solid #E5E7EB; border-radius: 8px;
  padding: 12px 8px; display: flex; flex-direction: column; align-items: center; gap: 8px; }
.state-label { font-size: 11px; color: #6B7280; font-weight: 500; }
.demo-btn { width: 96px; height: 32px; border-radius: 10px; display: flex; align-items: center;
  justify-content: center; font-size: 13px; font-weight: 500; color: #fff; }
.demo-btn.default { background: #16A34A; }
.demo-btn.disabled { background: #D1D5DB; color: #9CA3AF; }
.demo-btn.loading { background: #16A34A; }
.demo-btn.success { background: #16A34A; }
.demo-btn.error { background: #DC2626; }
.spinner { width: 14px; height: 14px; border: 2px solid rgba(255,255,255,.4);
  border-top-color: #fff; border-radius: 50%; margin-right: 6px; }
"""


def tokens_footer(comp):
    if comp["category"] == "ui":
        return (f'主色 {C["primary"]} · 文字 {C["textPrimary"]}/{C["textSecondary"]} · 描边 {C["border"]}'
                f' · 圆角 sm 6 / md 10 / lg 14 · 字号 12/14/16/18 · 间距 8/12/16')
    return "底层能力：无独立视觉规范，Token 以 UI 组件为准；接口契约见 docs/api.json"


# ---------------------------------------------------------------- state row

def state_buttons():
    return f"""
<div class="states-row">
  <div class="state-item"><span class="state-label">默认</span>
    <div class="demo-btn default">默认</div></div>
  <div class="state-item"><span class="state-label">禁用</span>
    <div class="demo-btn disabled">禁用</div></div>
  <div class="state-item"><span class="state-label">加载</span>
    <div class="demo-btn loading"><span class="spinner"></span>加载</div></div>
  <div class="state-item"><span class="state-label">成功</span>
    <div class="demo-btn success">成功</div></div>
  <div class="state-item"><span class="state-label">失败</span>
    <div class="demo-btn error">失败</div></div>
</div>
"""


# ---------------------------------------------------------------- dimension callout helpers

def dim_top(w, label, left=None, right=None):
    return f'<span class="callout top" style="width:{w}px">{label}</span>'


def dim_left(h, label):
    return f'<span class="callout left" style="height:{h}px">{label}</span>'


def dim_right(h, label):
    return f'<span class="callout right" style="height:{h}px">{label}</span>'


def dim_bottom(w, label):
    return f'<span class="callout bottom" style="width:{w}px">{label}</span>'


# ---------------------------------------------------------------- component visuals

def v_avatar():
    return f"""
<div class="visual" style="width:320px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;display:flex;align-items:center;gap:16px;">
  <div style="width:48px;height:48px;border-radius:50%;background:{C['primary']};display:flex;align-items:center;justify-content:center;color:#fff;font-size:{F['sizeLg']}px;font-weight:600;flex-shrink:0;">L</div>
  <div>
    <div style="font-size:{F['sizeMd']}px;font-weight:600;color:{C['textPrimary']};">李知遥</div>
    <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};">家庭账本 · 成员</div>
  </div>
</div>
<span class="callout bottom" style="width:320px">48 / 行高 76</span>
"""


def v_card():
    return f"""
<div class="visual" style="width:300px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;">
  <div style="font-size:{F['sizeMd']}px;font-weight:600;color:{C['textPrimary']};margin-bottom:8px;">本月支出</div>
  <div style="font-size:{F['sizeXl']}px;font-weight:600;color:{C['textPrimary']};margin-bottom:12px;">¥ 2,480.00</div>
  <div style="height:8px;border-radius:4px;background:{C['primaryMuted']};overflow:hidden;">
    <div style="width:70%;height:100%;background:{C['primary']};"></div>
  </div>
</div>
<span class="callout bottom" style="width:300px">300 × 圆角 14</span>
"""


def v_icon():
    items = [("☀", "图标·白天"), ("⚙", "图标·设置"), ("＋", "图标·新增"), ("›", "图标·更多")]
    cells = "".join(
        f'<div style="width:56px;height:56px;border-radius:{R["md"]}px;border:1px solid {C["border"]};'
        f'display:flex;align-items:center;justify-content:center;font-size:22px;color:{C["primary"] if i<3 else C["textSecondary"]};'
        f'flex-shrink:0;">{g}</div>'
        for i, (g, _) in enumerate(items)
    )
    return f"""
<div class="visual" style="display:flex;gap:16px;">
  {cells}
</div>
<span class="callout bottom" style="width:272px">图标资源 24×24 / 圆角 10</span>
"""


def v_split():
    rows = "".join(
        f'<div style="height:40px;display:flex;align-items:center;padding:0 12px;border-bottom:1px solid {C["bgPage"]};">'
        f'<span style="flex:1;font-size:{F["sizeSm"]}px;font-weight:600;color:{C["textPrimary"]};">{t}</span>'
        f'<span style="font-size:{F["sizeSm"]}px;color:{C["textSecondary"]};">{v}</span></div>'
        for t, v in [("分区标题", "附属说明"), ("其他分组", "12 项")]
    )
    return f"""
<div class="visual" style="width:340px;border-radius:{R['sm']}px;border:1px solid {C['border']};overflow:hidden;">
  {rows}
</div>
<span class="callout bottom" style="width:340px">行高 40</span>
"""


def v_webview():
    skeleton = "".join(
        f'<div style="height:10px;border-radius:5px;background:{C["border"]};width:{w}px;"></div>'
        for w in [220, 280, 180]
    )
    return f"""
<div class="visual" style="width:320px;border-radius:{R['lg']}px;border:1px solid {C['border']};overflow:hidden;">
  <div style="height:32px;background:{C['bgPage']};display:flex;align-items:center;padding:0 12px;">
    <span style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};">https://example.com</span></div>
  <div style="padding:16px;display:flex;flex-direction:column;gap:12px;">{skeleton}</div>
</div>
<span class="callout bottom" style="width:320px">WKWebView / WebView</span>
"""


def v_grid():
    items = [("记", "记账"), ("报", "报表"), ("预", "预算"), ("设", "设置")]
    cells = "".join(
        f'<div style="display:flex;flex-direction:column;align-items:center;gap:6px;">'
        f'<div style="width:42px;height:42px;border-radius:50%;background:{C["primaryMuted"]};color:{C["primary"]};'
        f'display:flex;align-items:center;justify-content:center;font-size:{F["sizeSm"]}px;font-weight:600;">{g}</div>'
        f'<span style="font-size:{F["sizeXs"]}px;color:{C["textPrimary"]};">{t}</span></div>'
        for g, t in items
    )
    return f"""
<div class="visual" style="width:312px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;">
  <div style="font-size:{F['sizeMd']}px;font-weight:600;color:{C['textPrimary']};margin-bottom:14px;">常用功能</div>
  <div style="display:flex;justify-content:space-between;">{cells}</div>
</div>
<span class="callout bottom" style="width:312px">宫格 4 项 / 图标 42</span>
"""


def v_navbar():
    return f"""
<div class="visual" style="width:360px;height:64px;border-radius:{R['lg']}px;border:1px solid {C['border']};display:flex;align-items:center;padding:0 16px;">
  <span style="font-size:{F['sizeDisplay']}px;color:{C['primary']};font-weight:600;width:36px;cursor:pointer;">‹</span>
  <span style="flex:1;text-align:center;font-size:{F['sizeMd']}px;font-weight:600;color:{C['textPrimary']};">标题</span>
  <div style="display:flex;gap:12px;">
    <div style="width:24px;height:24px;border-radius:50%;border:2px solid {C['primary']};"></div>
    <div style="width:24px;height:24px;border-radius:50%;border:2px solid {C['primary']}"></div>
  </div>
</div>
<span class="callout bottom" style="width:360px">360 × 64</span>
<span class="callout left" style="height:64px">图标 24</span>
"""


def v_segmented():
    return f"""
<div class="visual" style="width:200px;height:32px;border-radius:{R['md']}px;background:{C['bgPage']};padding:4px;display:flex;">
  <div style="flex:1;border-radius:{R['sm']}px;background:#fff;display:flex;align-items:center;justify-content:center;font-size:{F['sizeSm']}px;font-weight:600;color:{C['primary']};">支出</div>
  <div style="flex:1;display:flex;align-items:center;justify-content:center;font-size:{F['sizeSm']}px;font-weight:600;color:{C['textSecondary']};">收入</div>
</div>
<span class="callout bottom" style="width:200px">200 × 32 / 圆角 10</span>
"""


def v_shortcut():
    items = ["明细", "统计", "预算", "设置", "更多"]
    cells = "".join(
        f'<div style="display:flex;flex-direction:column;align-items:center;gap:6px;">'
        f'<div style="width:32px;height:32px;border-radius:50%;background:{C["primaryMuted"]};color:{C["primary"]};'
        f'display:flex;align-items:center;justify-content:center;font-size:{F["sizeSm"]}px;font-weight:600;">{t[0]}</div>'
        f'<span style="font-size:{F["sizeXs"]}px;color:{C["textPrimary"]};">{t}</span></div>'
        for t in items
    )
    return f"""
<div class="visual" style="width:360px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:14px 16px;">
  <div style="display:flex;justify-content:space-between;">{cells}</div>
</div>
<span class="callout bottom" style="width:360px">横向快捷入口</span>
"""


def v_datepicker():
    wd = ["日", "一", "二", "三", "四", "五", "六"]
    head = "".join(f'<span style="width:40px;text-align:center;font-size:{F["sizeXs"]}px;color:{C["textSecondary"]};">{d}</span>' for d in wd)
    # build 5 weeks
    weeks = [[0, 0, 0, 0, 0, 1, 2], [3, 4, 5, 6, 7, 8, 9], [10, 11, 12, 13, 14, 15, 16],
             [17, 18, 19, 20, 21, 22, 23], [24, 25, 26, 27, 28, 29, 30]]
    body = ""
    for wk in weeks:
        cells = ""
        for d in wk:
            if d == 0:
                cells += '<span style="width:40px;"></span>'
            elif d == 20:
                cells += (f'<span style="width:40px;text-align:center;">'
                          f'<span style="display:inline-block;width:22px;height:22px;line-height:22px;border-radius:50%;'
                          f'background:{C["primary"]};color:#fff;font-size:{F["sizeXs"]}px;font-weight:600;">{d}</span></span>')
            else:
                cells += f'<span style="width:40px;text-align:center;font-size:{F["sizeXs"]}px;color:{C["textPrimary"]};">{d}</span>'
        body += f'<div style="display:flex;">{cells}</div>'
    return f"""
<div class="visual" style="width:300px;border-radius:{R['lg']}px;border:1px solid {C['border']};overflow:hidden;">
  <div style="padding:12px 16px;font-size:{F['sizeSm']}px;font-weight:600;color:{C['textPrimary']};display:flex;justify-content:space-between;">
    <span>2026 年 8 月</span><span style="color:{C['textSecondary']};">‹ ›</span></div>
  <div style="display:flex;padding:0 16px;margin-bottom:4px;">{head}</div>
  {body}
  <div style="height:40px;display:flex;align-items:center;border-top:1px solid {C['border']};">
    <span style="flex:1;text-align:center;font-size:{F['sizeSm']}px;color:{C['textSecondary']};">取消</span>
    <span style="flex:1;text-align:center;font-size:{F['sizeSm']}px;font-weight:600;color:{C['primary']};">确定</span>
  </div>
</div>
<span class="callout bottom" style="width:300px">300 × 网格 40</span>
"""


def v_picker():
    opts = ["收入", "支出", "转账"]
    wheel = "".join(
        _picker_row(o, i) for i, o in enumerate(opts)
    )
    return f"""
<div class="visual" style="width:140px;border-radius:{R['md']}px;border:1px solid {C['border']};overflow:hidden;padding:8px 0;position:relative;">
  <div style="position:absolute;left:0;right:0;top:38px;height:26px;border-top:1px solid {C['primary']};border-bottom:1px solid {C['primary']};"></div>
  {wheel}
</div>
<span class="callout bottom" style="width:140px">单列 140 × 行 26</span>
"""


def _picker_row(o, i):
    if i == 1:
        style = (f"color:{C['primary']};font-weight:600;background:{C['primaryMuted']};"
                 f"border-radius:8px;")
    else:
        style = f"color:{C['textSecondary']};"
    return (f'<div style="height:26px;line-height:26px;text-align:center;'
            f'font-size:{F["sizeSm"]}px;{style}">{o}</div>')


def _gridpick_row(o, i):
    if i == 2:
        style = f"background:{C['primary']};color:#fff;font-weight:600;"
    else:
        style = f"border:1px solid {C['border']};color:{C['textPrimary']};"
    return (f'<div style="width:84px;height:28px;border-radius:{R["sm"]}px;'
            f'display:flex;align-items:center;justify-content:center;'
            f'font-size:{F["sizeXs"]}px;{style}">{o}</div>')


def v_grid_picker():
    opts = ["每日", "每周", "每月", "每年", "自定义", "＋"]
    cells = "".join(_gridpick_row(o, i) for i, o in enumerate(opts))
    return f"""
<div class="visual" style="width:288px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:12px;">
  <div style="display:flex;flex-wrap:wrap;gap:10px;width:278px;">{cells}</div>
</div>
<span class="callout bottom" style="width:288px">宫格选择 3 列</span>
"""


def v_empty():
    return f"""
<div class="visual" style="text-align:center;padding:20px 40px;">
  <div style="width:52px;height:52px;border-radius:50%;border:2px solid {C['border']};margin:0 auto 12px;position:relative;">
    <div style="position:absolute;top:14px;left:14px;width:20px;height:20px;border-radius:50%;border:2px solid {C['border']};"></div>
  </div>
  <div style="font-size:{F['sizeMd']}px;color:{C['textSecondary']};">暂无数据</div>
  <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};margin-top:4px;">搜索无结果 / 页面内容为空</div>
</div>
<span class="callout bottom">图标 52 / 文案 16</span>
"""


def v_linechart():
    # SVG inline but only the chart itself (clean, no labels overlay)
    return f"""
<div class="visual" style="width:300px;height:120px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:8px;background:#fff;">
<svg width="100%" height="100%" viewBox="0 0 284 104">
  {''.join(f'<line x1="12" y1="{10+i*21}" x2="272" y2="{10+i*21}" stroke="{C["border"]}" stroke-width="1" stroke-dasharray="4 4"/>' for i in range(1,5))}
  <path d="M 20 84 L 70 58 L 120 70 L 170 36 L 220 46 L 275 18" stroke="{C["primary"]}" stroke-width="2.5" fill="none" stroke-linejoin="round"/>
  <path d="M 20 84 L 70 58 L 120 70 L 170 36 L 220 46 L 275 18 L 275 98 L 20 98 Z" fill="{C["primaryMuted"]}" opacity="0.6"/>
  <circle cx="275" cy="18" r="4" fill="{C["primary"]}"/>
</svg>
</div>
<span class="callout bottom" style="width:300px">300 × 120</span>
"""


def v_list():
    rows = "".join(
        f'<div style="height:34px;display:flex;align-items:center;padding:0 16px;border-bottom:1px solid {C["bgPage"]};">'
        f'<span style="flex:1;font-size:{F["sizeSm"]}px;color:{C["textPrimary"]};">{t}</span>'
        f'<span style="font-size:{F["sizeSm"]}px;color:{C["textSecondary"]};">{v} ›</span></div>'
        for t, v in [("外卖", "¥ 36.00"), ("打车", "¥ 28.50"), ("超市", "¥ 120.30")]
    )
    return f"""
<div class="visual" style="width:340px;border-radius:{R['lg']}px;border:1px solid {C['border']};overflow:hidden;">
  <div style="padding:12px 16px;height:14px;background:{C['border']};opacity:.3;"></div>
  {rows}
</div>
<span class="callout bottom" style="width:340px">行高 34 / 内边距 16</span>
"""


def v_list_item():
    return f"""
<div class="visual" style="width:320px;height:56px;border-radius:{R['lg']}px;border:1px solid {C['border']};display:flex;align-items:center;padding:0 16px;">
  <span style="flex:1;font-size:{F['sizeSm']}px;color:{C['textPrimary']};">设置项</span>
  <span style="font-size:{F['sizeSm']}px;color:{C['textSecondary']};">值 ›</span>
</div>
<span class="callout bottom" style="width:320px">行高 56 / 内边距 16</span>
"""


def v_progress():
    return f"""
<div class="visual" style="width:120px;height:120px;position:relative;text-align:center;">
  <div style="width:88px;height:88px;border-radius:50%;margin:0 auto;position:relative;
       background:conic-gradient({C['primary']} 0 72%, {C['bgPage']} 72% 100%);display:flex;align-items:center;justify-content:center;">
    <div style="width:64px;height:64px;border-radius:50%;background:#fff;display:flex;align-items:center;justify-content:center;
         font-size:{F['sizeMd']}px;font-weight:600;color:{C['textPrimary']};">72%</div>
  </div>
  <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};margin-top:6px;">本月预算</div>
</div>
<span class="callout bottom" style="width:120px">环形 88 / 描边 12</span>
"""


def v_refresh():
    return f"""
<div class="visual" style="text-align:center;padding:20px 40px;">
  <div style="font-size:28px;color:{C['primary']};font-weight:600;margin-bottom:8px;">↓</div>
  <div style="font-size:{F['sizeSm']}px;color:{C['textPrimary']};">松开立即刷新</div>
  <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};margin-top:4px;">对齐 UIRefreshControl / 下拉刷新</div>
</div>
<span class="callout bottom">下拉手势 + 文案</span>
"""


def v_design_tokens():
    swatches = [("primary", C["primary"]), ("income", C["income"]), ("expense", C["expense"]),
                ("warning", C["warning"]), ("primaryMuted", C["primaryMuted"]),
                ("textPrimary", C["textPrimary"]), ("textSecondary", C["textSecondary"]), ("border", C["border"])]
    sw = "".join(
        f'<div style="text-align:center;"><div style="width:44px;height:28px;border-radius:{R["sm"]}px;'
        f'background:{col};border:1px solid {C["border"]};margin:0 auto;"></div>'
        f'<div style="font-size:10px;color:{C["textSecondary"]};margin-top:4px;">{n}</div></div>'
        for n, col in swatches
    )
    return f"""
<div class="visual" style="width:400px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;">
  <div style="font-size:{F['sizeSm']}px;font-weight:600;color:{C['textPrimary']};margin-bottom:12px;">色板 Color</div>
  <div style="display:flex;gap:10px;">{sw}</div>
  <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};margin-top:12px;">
    字号 12/14/16/18/22/32 · 圆角 6/10/14/999 · 间距 4/8/12/16/24</div>
</div>
<span class="callout bottom" style="width:400px">色板 8 + 字阶</span>
"""


def v_calendar():
    wd = ["日", "一", "二", "三", "四", "五", "六"]
    head = "".join(f'<span style="width:38px;text-align:center;font-size:{F["sizeXs"]}px;color:{C["textSecondary"]};">{d}</span>' for d in wd)
    start = 6
    cells = ""
    for day in range(1, 32):
        idx = day + start - 1
        if idx % 7 == 0:
            cells += '</div><div style="display:flex;">'
        if day == 20:
            cells += (f'<span style="width:38px;text-align:center;"><span style="display:inline-block;width:20px;height:20px;'
                      f'line-height:20px;border-radius:50%;background:{C["primary"]};color:#fff;font-size:{F["sizeXs"]}px;font-weight:600;">{day}</span></span>')
        else:
            cells += f'<span style="width:38px;text-align:center;font-size:{F["sizeXs"]}px;color:{C["textPrimary"]};">{day}</span>'
    return f"""
<div class="visual" style="width:300px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:12px 16px;">
  <div style="display:flex;justify-content:space-between;font-size:{F['sizeSm']}px;font-weight:600;color:{C['textPrimary']};margin-bottom:8px;">
    <span>2026 · 08</span><span style="color:{C['textSecondary']};">‹ ›</span></div>
  <div style="display:flex;">{head}</div>
  <div style="display:flex;">{cells}</div>
</div>
<span class="callout bottom" style="width:300px">自然月网格 38</span>
"""


def v_http():
    return f"""
<div class="visual" style="width:400px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;font-family:ui-monospace,Menlo,monospace;">
  <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;">
    <span style="background:{C['primary']};color:#fff;font-size:{F['sizeXs']}px;font-weight:600;padding:2px 8px;border-radius:4px;">GET</span>
    <span style="font-size:{F['sizeXs']}px;color:{C['textPrimary']};">/api/v1/transactions?month=2026-08</span></div>
  <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};margin-bottom:8px;">响应 Response</div>
  <div style="font-size:{F['sizeXs']}px;line-height:1.8;">
    <div><span style="color:{C['primary']};">code</span> <span style="color:{C['textSecondary']};">200</span></div>
    <div><span style="color:{C['primary']};">data</span> <span style="color:{C['textSecondary']};">count: 42</span></div>
    <div><span style="color:{C['primary']};">list</span> <span style="color:{C['textSecondary']};">[ … ]</span></div>
  </div>
</div>
<span class="callout bottom" style="width:400px">HTTP 客户端（Mock）</span>
"""


def v_money():
    return f"""
<div class="visual" style="width:400px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;">
  <div style="font-size:{F['sizeXl']}px;font-weight:600;color:{C['textPrimary']};margin-bottom:8px;">¥ 1,234,567.89</div>
  <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};margin-bottom:12px;">千分位 · 两位小数 · 负号 −</div>
  <div style="font-size:{F['sizeMd']}px;font-weight:600;"><span style="color:{C['income']};">+¥ 36.00</span>  <span style="color:{C['expense']};">−¥ 120.30</span></div>
</div>
<span class="callout bottom" style="width:400px">收入绿 / 支出红</span>
"""


def v_router():
    pages = ["首页", "明细", "编辑"]
    flow = "".join(
        f'<div style="width:90px;height:40px;border-radius:{R["md"]}px;border:2px solid {C["primary"] if i==2 else C["border"]};'
        f'display:flex;align-items:center;justify-content:center;font-size:{F["sizeSm"]}px;'
        f'color:{C["primary"] if i==2 else C["textPrimary"]};font-weight:500;">{p}</div>'
        + (f'<div style="font-size:18px;color:{C["textSecondary"]};">→</div>' if i < 2 else "")
        for i, p in enumerate(pages)
    )
    return f"""
<div class="visual" style="width:400px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;">
  <div style="display:flex;align-items:center;gap:12px;">{flow}</div>
  <div style="font-size:{F['sizeXs']}px;color:{C['textSecondary']};margin-top:12px;">
    push('home') → push('detail', id:) ← 返回 pop</div>
</div>
<span class="callout bottom" style="width:400px">路由 push / pop</span>
"""


def v_storage():
    rows = [("transactions", "id / amount / category / date"),
            ("categories", "id / name / icon / type")]
    r = "".join(
        f'<div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">'
        f'<span style="background:{C["bgPage"]};color:{C["primary"]};font-size:{F["sizeXs"]}px;font-weight:500;'
        f'padding:4px 10px;border-radius:6px;font-family:ui-monospace,Menlo,monospace;width:120px;">{t}</span>'
        f'<span style="font-size:{F["sizeXs"]}px;color:{C["textSecondary"]};font-family:ui-monospace,Menlo,monospace;">{cols}</span></div>'
        for t, cols in rows
    )
    return f"""
<div class="visual" style="width:400px;border-radius:{R['lg']}px;border:1px solid {C['border']};padding:16px;">
  <div style="font-size:{F['sizeSm']}px;font-weight:600;color:{C['textPrimary']};margin-bottom:12px;">SQLite · keepaccounts.db</div>
  {r}
</div>
<span class="callout bottom" style="width:400px">本地数据库封装</span>
"""


def v_system_bars():
    return f"""
<div class="visual" style="width:240px;border-radius:{R['lg']}px;border:1px solid {C['border']};overflow:hidden;">
  <div style="height:30px;background:{C['textPrimary']};display:flex;align-items:center;padding:0 12px;color:#fff;">
    <span style="font-size:{F['sizeSm']}px;font-weight:600;flex:1;">9:41</span>
    <span style="font-size:{F['sizeXs']}px;">▮▮▮</span></div>
  <div style="padding:20px;text-align:center;font-size:{F['sizeXs']}px;color:{C['textSecondary']};">内容区</div>
  <div style="width:100px;height:5px;border-radius:3px;background:{C['textPrimary']};margin:0 auto 12px;"></div>
</div>
<span class="callout bottom" style="width:240px">状态栏 30 / Home 指示</span>
"""


VISUALS = {
    "ui.avatar": v_avatar, "ui.card": v_card, "ui.icon": v_icon, "ui.split": v_split,
    "ui.webview": v_webview, "ui.grid": v_grid, "ui.navbar": v_navbar,
    "ui.segmented": v_segmented, "ui.shortcut-bar": v_shortcut,
    "ui.date-picker": v_datepicker, "ui.date-picker-month": v_picker,
    "ui.date-picker-year": v_picker, "ui.picker": v_picker, "ui.grid-picker": v_grid_picker,
    "ui.empty": v_empty, "ui.line-chart": v_linechart, "ui.list": v_list,
    "ui.list-item": v_list_item, "ui.progress-circle": v_progress, "ui.refresh": v_refresh,
    "foundation.design-tokens": v_design_tokens, "foundation.calendar": v_calendar,
    "foundation.http-client": v_http, "foundation.money-format": v_money,
    "foundation.router": v_router, "foundation.storage": v_storage,
    "foundation.system-bars": v_system_bars,
}

ORDER = [
    ("UI · 基础通用", "ui", ["ui.avatar", "ui.card", "ui.icon", "ui.split", "ui.webview"]),
    ("UI · 导航", "ui", ["ui.navbar", "ui.grid", "ui.segmented", "ui.shortcut-bar"]),
    ("UI · 数据录入", "ui", ["ui.date-picker", "ui.date-picker-month", "ui.date-picker-year", "ui.picker", "ui.grid-picker"]),
    ("UI · 数据展示", "ui", ["ui.empty", "ui.list", "ui.list-item", "ui.line-chart", "ui.progress-circle"]),
    ("UI · 操作反馈", "ui", ["ui.refresh"]),
    ("底层能力", "foundation", ["foundation.design-tokens", "foundation.router", "foundation.storage",
                             "foundation.http-client", "foundation.money-format", "foundation.calendar", "foundation.system-bars"]),
]

NAMES = {
    "ui.avatar": "头像 Avatar", "ui.card": "卡片 Card", "ui.icon": "图标 Icon",
    "ui.split": "双栏行 Split", "ui.webview": "网页容器 WebView",
    "ui.navbar": "导航栏 NavigationBar", "ui.grid": "宫格 Grid",
    "ui.segmented": "分段控制器 SegmentedControl", "ui.shortcut-bar": "快捷栏 ShortcutBar",
    "ui.date-picker": "日期选择 DatePicker", "ui.date-picker-month": "日期选择·月 DatePicker",
    "ui.date-picker-year": "日期选择·年 DatePicker", "ui.picker": "选择器 Picker",
    "ui.grid-picker": "宫格选择 GridPicker", "ui.empty": "空状态 Empty",
    "ui.list": "列表 List", "ui.list-item": "列表项 ListItem",
    "ui.line-chart": "折线图 LineChart", "ui.progress-circle": "环形进度 Progress",
    "ui.refresh": "下拉刷新 Refresh",
    "foundation.design-tokens": "设计令牌 Design Tokens", "foundation.router": "路由 Router",
    "foundation.storage": "本地存储 Storage", "foundation.http-client": "网络客户端 HTTP Client",
    "foundation.money-format": "金额格式化 MoneyFormat", "foundation.calendar": "日历工具 Calendar",
    "foundation.system-bars": "系统栏 SystemBars",
}


def build():
    sections = []
    for title, cat, ids in ORDER:
        cards = []
        for cid in ids:
            visual = VISUALS.get(cid)
            if not visual:
                continue
            comp = next(c for c in API["components"] if c["id"] == cid)
            name = NAMES.get(cid, cid)
            badge_cls = "" if cat == "ui" else " foundation"
            cards.append(f"""
<div class="component-card">
  <div class="card-head">
    <span class="card-name">{name}</span>
    <div>
      <span class="card-badge{badge_cls}">{title.split("· ")[-1]}</span>
      <code class="card-id">{cid}</code>
    </div>
  </div>
  <div class="visual-wrap">{visual()}</div>
  {state_buttons()}
  <div class="tokens" style="padding:12px 16px;font-size:11px;color:{C['textSecondary']};">Token · {tokens_footer(comp)}</div>
</div>""")
        sections.append(f'<h2>{title} <span class="count">({len(cards)})</span></h2>'
                        f'<div class="grid">{"".join(cards)}</div>')

    html = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Native-UI-Comps · 组件设计规范 v1（HTML 版）</title>
<style>
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{ font-family: "PingFang SC","Noto Sans CJK SC","Helvetica Neue",Arial,sans-serif;
         background: {C['bgPage']}; color: {C['textPrimary']}; padding: 32px 40px 80px; }}
  header h1 {{ font-size: 24px; font-weight: 700; }}
  header p {{ color: {C['textSecondary']}; font-size: 14px; margin-top: 8px; line-height: 1.7; }}
  .meta {{ margin: 16px 0; font-size: 13px; color: {C['textSecondary']}; }}
  .meta b {{ color: {C['primary']}; }}
  h2 {{ font-size: 18px; font-weight: 600; margin: 40px 0 16px; padding-left: 12px;
       border-left: 4px solid {C['primary']}; }}
  .count {{ color: {C['textSecondary']}; font-weight: 400; font-size: 14px; }}
  .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(480px, 1fr)); gap: 20px; align-items: start; }}
  {card_css()}
  {callout_css()}
  {states_css()}
  .tokens {{ border-top: 1px solid {C['border']}; }}
  footer {{ margin-top: 48px; padding-top: 16px; border-top: 1px solid {C['border']};
           color: {C['textSecondary']}; font-size: 13px; line-height: 1.8; }}
</style>
</head>
<body>
<header>
  <h1>Native-UI-Comps · 组件设计规范 v1（HTML 版）</h1>
  <p>UI 组件（20）+ 底层能力（7）· 视觉区与状态区分区布局，标注置于视觉区外圈不遮挡组件。<br>
     设计为唯一基准，双端实现与命名以此为准。</p>
  <p class="meta">设计令牌来源 <b>docs/design-token.json</b> · 主色 {C['primary']} · 生成时间 2026-08-29</p>
</header>
{''.join(sections)}
<footer>
  生成脚本 <code>scripts/generate_design_gallery.py</code> · 本页自包含，可直接打印 / 导出<br>
  导入 Figma / Sketch：从本页截图或导出 PNG；设计规格以 H5 规格页为准（如 <code>docs/design-spec/cell-design-spec.html</code>）
</footer>
</body>
</html>
"""
    out = os.path.join(ROOT, "docs", "design-spec", "index.html")
    with open(out, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"Wrote {out}")


if __name__ == "__main__":
    build()
