import { Alert, Space, Table, Tag, Typography } from "antd";
import type { ComponentDoc } from "../types";

const { Title, Text, Paragraph } = Typography;

const PLAT: Record<string, string> = {
  ios: "iOS",
  android: "Android",
  harmony: "鸿蒙",
  weixin: "微信",
  alipay: "支付宝",
};

function platColor(state: string) {
  if (state === "available") return "success";
  if (state === "partial") return "warning";
  if (state === "draft") return "processing";
  return "default";
}

function platText(state: string) {
  if (state === "available") return "已实现";
  if (state === "partial") return "部分";
  if (state === "draft") return "提案";
  return "未做";
}

export default function ComponentDetail({
  doc,
  categoryTitle,
}: {
  doc: ComponentDoc;
  categoryTitle: string;
}) {
  return (
    <div style={{ padding: 24 }}>
      <Text type="secondary">
        {categoryTitle} / {doc.name}
      </Text>
      <Space align="baseline" wrap style={{ marginTop: 4, marginBottom: 8 }}>
        <Title level={3} style={{ margin: 0 }}>
          {doc.name}
        </Title>
        <Text code>{doc.id}</Text>
      </Space>
      <Paragraph type="secondary">{doc.summary}</Paragraph>

      <Space wrap style={{ marginBottom: 16 }}>
        {(doc.industryNames ?? []).map((n) => (
          <Tag key={n} color="blue">
            {n}
          </Tag>
        ))}
        {(doc.usedInApps ?? []).map((app) => (
          <Tag key={app} color="purple">
            📦 {app}
          </Tag>
        ))}
        {Object.entries(PLAT).map(([k, label]) => {
          const st = doc.platforms[k]?.state ?? "unavailable";
          return (
            <Tag key={k} color={platColor(st)}>
              {label} · {platText(st)}
            </Tag>
          );
        })}
        <Tag>{doc.status}</Tag>
      </Space>

      {doc.note ? (
        <Alert type="warning" showIcon style={{ marginBottom: 16 }} message={doc.note} />
      ) : null}

      {doc.legacyId ? (
        <Paragraph type="secondary" style={{ fontSize: 12 }}>
          旧 id：<Text code>{doc.legacyId}</Text>
        </Paragraph>
      ) : null}

      <Title level={5}>展现</Title>
      <div className="preview-box" style={{ marginBottom: 20 }}>
        {doc.image ? (
          <>
            <img src={doc.image} alt={doc.name} />
            <div style={{ marginTop: 8 }}>
              <Text type="secondary" style={{ fontSize: 12 }}>
                {doc.image}
              </Text>
            </div>
          </>
        ) : (
          <Text type="secondary">
            暂无局部截图（该组件尚未入库视觉稿；可点左侧「绿色汇总卡 / 明细快捷导航 / 分段控件」等有图项查看）
          </Text>
        )}
      </div>

      <Title level={5}>属性 Props</Title>
      <Table
        size="small"
        pagination={false}
        style={{ marginBottom: 20 }}
        rowKey={(r) => r[0]}
        dataSource={doc.props}
        locale={{ emptyText: "暂无（底层能力或待补契约）" }}
        columns={[
          { title: "属性", dataIndex: 0, render: (v) => <Text code>{v}</Text> },
          { title: "类型", dataIndex: 1, render: (v) => <Text code>{v}</Text> },
          { title: "必填", dataIndex: 2, width: 72 },
          { title: "说明", dataIndex: 3 },
        ]}
      />

      <Title level={5}>事件 Events</Title>
      <Table
        size="small"
        pagination={false}
        style={{ marginBottom: 20 }}
        rowKey={(r) => r[0]}
        dataSource={doc.events}
        locale={{ emptyText: "无（纯展示 / 工具）" }}
        columns={[
          { title: "事件", dataIndex: 0, render: (v) => <Text code>{v}</Text> },
          { title: "签名", dataIndex: 1, render: (v) => <Text code>{v}</Text> },
          { title: "说明", dataIndex: 2 },
        ]}
      />

      <Title level={5}>代码 Demo</Title>
      {doc.demos.length === 0 ? (
        <Text type="secondary">暂无 Demo</Text>
      ) : (
        doc.demos.map(([label, code]) => (
          <div key={label} style={{ marginBottom: 12 }}>
            <Text type="secondary" style={{ fontSize: 12 }}>
              {label}
            </Text>
            <pre
              style={{
                margin: "6px 0 0",
                background: "#0b1220",
                color: "#e5e7eb",
                padding: "12px 14px",
                borderRadius: 8,
                overflow: "auto",
                fontSize: 12.5,
                lineHeight: 1.55,
              }}
            >
              {code}
            </pre>
          </div>
        ))
      )}
    </div>
  );
}
