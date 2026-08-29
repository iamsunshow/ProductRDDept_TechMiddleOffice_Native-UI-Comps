import { useMemo, useState } from "react";
import { Input, Select, Table, Tag, Typography } from "antd";
import type { ColumnsType } from "antd/es/table";
import type { ComponentDoc, PlatformState } from "../types";

const PLATFORM_LABEL: Record<string, string> = {
  ios: "iOS",
  android: "Android",
  harmony: "HarmonyOS",
  weixin: "微信",
  alipay: "支付宝",
};

const STATE_META: Record<PlatformState, { color: string; label: string }> = {
  available: { color: "green", label: "可用" },
  partial: { color: "orange", label: "部分" },
  unavailable: { color: "default", label: "未实现" },
  draft: { color: "blue", label: "草稿" },
};

const PLATFORM_COLUMNS = ["ios", "android", "harmony", "weixin", "alipay"];

export default function ContractMatrix({
  data,
}: {
  data: { components: ComponentDoc[]; categories: Record<string, { title: string }>; meta: { platforms: string[] } };
}) {
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState<string>("all");

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return data.components
      .filter((c) => {
        if (status !== "all" && c.status !== status) return false;
        if (!q) return true;
        return (
          c.id.toLowerCase().includes(q) ||
          c.name.toLowerCase().includes(q) ||
          c.summary.toLowerCase().includes(q)
        );
      })
      .map((c) => ({
        key: c.id,
        id: c.id,
        name: c.name,
        category: data.categories[c.category]?.title ?? c.category,
        status: c.status,
        api: c.props.length + c.events.length,
        platforms: c.platforms,
        ios: c.platforms.ios?.state,
        android: c.platforms.android?.state,
        harmony: c.platforms.harmony?.state,
        weixin: c.platforms.weixin?.state,
        alipay: c.platforms.alipay?.state,
      }));
  }, [query, status, data]);

  const columns: ColumnsType<(typeof rows)[number]> = [
    {
      title: "组件",
      dataIndex: "name",
      key: "name",
      fixed: "left",
      width: 180,
      render: (_, r) => (
        <div>
          <div style={{ fontWeight: 600 }}>{r.name}</div>
          <Typography.Text type="secondary" style={{ fontSize: 12 }}>
            {r.id}
          </Typography.Text>
        </div>
      ),
    },
    {
      title: "分类",
      dataIndex: "category",
      key: "category",
      width: 100,
      render: (v) => <Tag>{v}</Tag>,
    },
    ...PLATFORM_COLUMNS.map((p) => ({
      title: PLATFORM_LABEL[p],
      dataIndex: p,
      key: p,
      width: 92,
      align: "center" as const,
      render: (state: PlatformState | undefined) =>
        state ? (
          <Tag color={STATE_META[state]?.color ?? "default"}>{STATE_META[state]?.label ?? state}</Tag>
        ) : (
          <Tag>—</Tag>
        ),
    })),
    {
      title: "API 项",
      dataIndex: "api",
      key: "api",
      width: 80,
      align: "center",
      render: (v) => <span style={{ fontSize: 13 }}>{v}</span>,
    },
    {
      title: "状态",
      dataIndex: "status",
      key: "status",
      width: 80,
      align: "center",
      render: (v: string) => (
        <Tag color={v === "stable" ? "green" : v === "deprecated" ? "default" : "blue"}>
          {v === "stable" ? "稳定" : v === "deprecated" ? "废弃" : "草稿"}
        </Tag>
      ),
    },
  ];

  return (
    <div style={{ padding: "24px 32px 48px" }}>
      <Typography.Title level={2} style={{ marginTop: 0 }}>
        双端 API 契约
      </Typography.Title>
      <Typography.Paragraph type="secondary">
        全部组件在各平台（iOS / Android / HarmonyOS / 小程序）的实现状态矩阵。点击组件可在「组件库」页查看完整
        Props / Events 契约。
      </Typography.Paragraph>

      <div style={{ display: "flex", gap: 12, marginBottom: 16, flexWrap: "wrap" }}>
        <Input.Search
          allowClear
          placeholder="按名称 / ID / 描述筛选组件…"
          style={{ width: 320 }}
          onChange={(e) => setQuery(e.target.value)}
        />
        <Select
          style={{ width: 160 }}
          value={status}
          onChange={setStatus}
          options={[
            { value: "all", label: "全部状态" },
            { value: "stable", label: "稳定" },
            { value: "draft", label: "草稿" },
            { value: "deprecated", label: "废弃" },
          ]}
        />
      </div>

      <Table
        columns={columns}
        dataSource={rows}
        size="small"
        pagination={{ pageSize: 20, showSizeChanger: false }}
        scroll={{ x: 900 }}
        bordered
      />
    </div>
  );
}
