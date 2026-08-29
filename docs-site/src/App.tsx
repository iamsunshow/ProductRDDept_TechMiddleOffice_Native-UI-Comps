import { useCallback, useEffect, useMemo, useState } from "react";
import { Empty, Input, Layout, Menu, Space, Tabs, Tag, Typography } from "antd";
import type { MenuProps } from "antd";
import catalog from "./data/catalog.json";
import type { CatalogData, ComponentDoc } from "./types";
import { vectorSearch } from "./lib/vectorSearch";
import DesignPanel from "./components/DesignPanel";
import ComponentDetail from "./components/ComponentDetail";
import HomePage from "./components/HomePage";
import UsageGuide from "./components/UsageGuide";
import ContractMatrix from "./components/ContractMatrix";
import Changelog from "./components/Changelog";

const { Header, Sider, Content } = Layout;
const data = catalog as unknown as CatalogData;

type TabKey = "design" | "components";
type ViewKey = "home" | "library" | "usage" | "contracts" | "changelog";

function firstWithImage(): string | null {
  return data.components.find((c) => c.image)?.id ?? data.components[0]?.id ?? null;
}

function textSearchComponents(query: string, components: ComponentDoc[]): ComponentDoc[] {
  const lower = query.toLowerCase();
  return components.filter(
    (c) =>
      c.name.includes(query) ||
      c.id.toLowerCase().includes(lower) ||
      c.summary.includes(query) ||
      c.searchText.toLowerCase().includes(lower) ||
      c.capabilities.some((cap) => cap.toLowerCase().includes(lower)),
  );
}

function scoreTextMatch(query: string, comp: ComponentDoc): number {
  const lower = query.toLowerCase();
  let score = 0;
  if (comp.name.toLowerCase() === lower) score += 100;
  if (comp.name.includes(query)) score += 50;
  if (comp.id.toLowerCase().includes(lower)) score += 30;
  if (comp.summary.includes(query)) score += 20;
  if (comp.searchText.toLowerCase().includes(lower)) score += 10;
  for (const cap of comp.capabilities) {
    if (cap.toLowerCase().includes(lower)) score += 15;
  }
  return score;
}

function rankComponentIds(query: string, components: ComponentDoc[]): string[] {
  const q = query.trim();
  if (!q) return [];

  const vecHits = vectorSearch(q, components, 30);
  const textMatched = textSearchComponents(q, components);

  const scoreMap = new Map<string, number>();
  for (const h of vecHits) {
    scoreMap.set(h.id, (scoreMap.get(h.id) ?? 0) + h.score * 10);
  }
  for (const c of textMatched) {
    scoreMap.set(c.id, (scoreMap.get(c.id) ?? 0) + scoreTextMatch(q, c));
  }

  return [...scoreMap.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([id]) => id);
}

function selectComponentCategory(id: string, setOpenKeys: React.Dispatch<React.SetStateAction<string[]>>) {
  const comp = data.components.find((c) => c.id === id);
  if (comp) {
    setOpenKeys((keys) => (keys.includes(comp.category) ? keys : [...keys, comp.category]));
  }
}

const NAV_ITEMS = [
  { key: "home", label: "首页" },
  { key: "library", label: "组件库" },
  { key: "usage", label: "使用指南" },
  { key: "contracts", label: "双端契约" },
  { key: "changelog", label: "版本日志" },
] as const;

export default function App() {
  const [view, setView] = useState<ViewKey>("home");
  const [tab, setTab] = useState<TabKey>("design");
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(firstWithImage());
  const [openKeys, setOpenKeys] = useState<string[]>(data.categoryOrder);

  const rankedIds = useMemo(() => {
    const q = query.trim();
    if (!q) return null;
    const sorted = rankComponentIds(q, data.components);
    return sorted.length ? sorted : [];
  }, [query]);

  const visibleComponents = useMemo(() => {
    if (!rankedIds) return data.components;
    const map = new Map(data.components.map((c) => [c.id, c]));
    return rankedIds.map((id) => map.get(id)).filter(Boolean) as ComponentDoc[];
  }, [rankedIds]);

  useEffect(() => {
    if (tab !== "components" || !selectedId) return;
    const doc = data.components.find((c) => c.id === selectedId);
    if (!doc) return;
    setOpenKeys((keys) => (keys.includes(doc.category) ? keys : [...keys, doc.category]));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tab, selectedId]);

  const selected = data.components.find((c) => c.id === selectedId) ?? null;

  const handleJumpToFirst = useCallback(() => {
    const q = query.trim();
    if (!q) return;

    if (rankedIds && rankedIds.length > 0) {
      const firstId = rankedIds[0];
      setSelectedId(firstId);
      selectComponentCategory(firstId, setOpenKeys);
    }
  }, [query, rankedIds]);

  const menuItems: MenuProps["items"] = useMemo(() => {
    return data.categoryOrder
      .map((cat) => {
        const children = visibleComponents.filter((c) => c.category === cat);
        if (!children.length) return null;
        const meta = data.categories[cat];
        return {
          key: cat,
          label: `${meta?.title ?? cat}（${children.length}）`,
          children: children.map((c) => ({
            key: c.id,
            title: `${c.name} (${c.id})`,
            label: (
              <div className="menu-item-label">
                <div className="menu-item-name">
                  {c.name}
                  {c.image ? " · 有图" : ""}
                </div>
                <span className="menu-item-id">
                  {c.id}
                  {c.usedInApps.length > 0 && (
                    <Tag color="purple" style={{ marginLeft: 4, fontSize: 10, lineHeight: "16px", padding: "0 4px" }}>
                      {c.usedInApps.length} App
                    </Tag>
                  )}
                </span>
              </div>
            ),
          })),
        };
      })
      .filter(Boolean) as MenuProps["items"];
  }, [visibleComponents]);

  const onSearchChange = (value: string) => {
    setQuery(value);
    const q = value.trim();
    if (!q) {
      setSelectedId(firstWithImage());
      return;
    }
    if (tab === "components" && rankedIds && rankedIds.length > 0) {
      setSelectedId(rankedIds[0]);
    }
  };

  const onSearchSubmit = (value: string) => {
    setQuery(value);
    setView("library");
    setTab("components");
    const q = value.trim();
    if (!q) {
      setSelectedId(firstWithImage());
      return;
    }
    const bestId = rankComponentIds(q, data.components)[0];
    if (bestId) {
      setSelectedId(bestId);
      selectComponentCategory(bestId, setOpenKeys);
    }
  };

  const switchTab = (k: TabKey) => {
    setTab(k);
    if (k === "components" && !selectedId) {
      const withImg = firstWithImage();
      if (withImg) setSelectedId(withImg);
    }
  };

  const isLibrary = view === "library";

  return (
    <Layout style={{ height: "100vh", overflow: "hidden" }}>
      <Header
        className="docs-header"
        style={{ height: "auto", lineHeight: "normal", flexShrink: 0 }}
      >
        <Space wrap style={{ width: "100%", justifyContent: "space-between" }} size={16} align="center">
          <Space size={24} align="center">
            <div className="docs-brand">
              OPC <span>Component Kit</span>
            </div>
            <Menu
              mode="horizontal"
              selectedKeys={[view]}
              onClick={({ key }) => setView(key as ViewKey)}
              items={NAV_ITEMS.map((n) => ({ key: n.key, label: n.label }))}
              style={{ borderBottom: "none", minWidth: 380 }}
            />
          </Space>
          {isLibrary && (
            <Input.Search
              allowClear
              placeholder={`搜索组件… 例如：路由、月份选择、空态、分段`}
              style={{ width: 380, maxWidth: "100%" }}
              onSearch={onSearchSubmit}
              onChange={(e) => onSearchChange(e.target.value)}
            />
          )}
        </Space>
        {isLibrary && tab === "components" && query.trim() ? (
          <Space style={{ marginTop: 4 }} size={8}>
            <Typography.Text type="secondary" style={{ fontSize: 12 }}>
              搜索「{query}」· 命中 {visibleComponents.length} 项
            </Typography.Text>
            {rankedIds && rankedIds.length > 0 && (
              <a onClick={handleJumpToFirst} style={{ fontSize: 12 }}>
                跳到第一个结果 →
              </a>
            )}
          </Space>
        ) : null}
      </Header>

      {isLibrary ? (
        <Layout style={{ flex: 1, overflow: "hidden", minHeight: 0 }}>
          {tab === "components" ? (
            <Sider
              width={320}
              theme="light"
              className="docs-sider"
              style={{
                borderRight: "1px solid #f0f0f0",
                background: "#fff",
                overflow: "auto",
                height: "100%",
                flexShrink: 0,
              }}
            >
              <Menu
                mode="inline"
                inlineIndent={16}
                selectedKeys={selectedId ? [selectedId] : []}
                openKeys={openKeys}
                onOpenChange={(keys) => setOpenKeys(keys as string[])}
                style={{ borderInlineEnd: 0 }}
                items={menuItems}
                onClick={({ key }) => {
                  if (!data.categoryOrder.includes(key)) setSelectedId(key);
                }}
              />
            </Sider>
          ) : null}

          <Content style={{ background: "#fff", overflow: "auto", minHeight: 0 }}>
            {tab === "design" ? (
              <DesignPanel data={data} />
            ) : selected ? (
              <ComponentDetail
                doc={selected}
                categoryTitle={data.categories[selected.category]?.title ?? selected.category}
              />
            ) : (
              <Empty style={{ marginTop: 80 }} description="从左侧选择组件" />
            )}
          </Content>
        </Layout>
      ) : (
        <Content style={{ background: "#fff", overflow: "auto", minHeight: 0 }}>
          {view === "home" ? <HomePage data={data} /> : null}
          {view === "usage" ? <UsageGuide data={data} /> : null}
          {view === "contracts" ? <ContractMatrix data={data} /> : null}
          {view === "changelog" ? <Changelog data={data} /> : null}
        </Content>
      )}
    </Layout>
  );
}
