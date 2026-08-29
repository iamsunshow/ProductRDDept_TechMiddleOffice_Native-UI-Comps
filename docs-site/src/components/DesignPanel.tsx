import { Card, Col, Collapse, Row, Table, Tag, Typography } from "antd";
import type { CatalogData } from "../types";

const { Title, Text, Paragraph } = Typography;

const TAXONOMY = [
  {
    key: "basic",
    title: "基础组件 basic",
    oneLiner: "高度可复用的 UI 组件；换 App 也能用。",
    analogy: "对标 Ant Design / Apple HIG 里的 Button、List、DatePicker、SegmentedControl…",
    examples: "Empty、DatePicker、SegmentedControl（页内分段/口语 Tab）、List/ListItem（设置行）、Grid（多格）、Card（单块）、Avatar、LineChart、NavigationBar",
    reuse: "直接复用；差异靠 props / Design Tokens / variant。",
  },
  {
    key: "foundation",
    title: "底层能力 foundation",
    oneLiner: "换 App 仍可持续复用的基建（调参数即可），不绑定具体业务模型。",
    analogy: "对标 Router、Storage、HTTP Client、Design Tokens；不含流水/预算等域仓储。",
    examples: "Design Tokens、Router、Storage、HTTP Client、MoneyFormat、Calendar、SystemBars",
    reuse: "跨 App 复用；各端实现、接口对齐。多数没有「组件截图」。",
  },
  {
    key: "business",
    title: "业务组件 / 业务拼装 business",
    oneLiner: "纯业务定制；含域仓储、页级拼装、本 App 配置与脚手架。",
    analogy: "只服务当前产品流程；页级拼装是多组件组合，不是原子 UI。",
    examples: "流水/预算/资产仓储、金额键盘、家庭账本邀请、意见反馈、汇总统计、ContentConfig、Fixtures",
    reuse: "不跨产品复用。若其实是通用 ListItem/Grid，应改归 basic。",
  },
];

export default function DesignPanel({ data }: { data: CatalogData }) {
  const colors = data.tokens.color ?? {};
  const font = data.tokens.font ?? {};
  const space = data.tokens.space ?? {};
  const radius = data.tokens.radius ?? {};

  return (
    <div style={{ padding: 24, maxWidth: 1100 }}>
      <Title level={3} style={{ marginTop: 0 }}>
        设计规范
      </Title>
      <Paragraph type="secondary">
        来源 KeepAccounts <Text code>packages/design-tokens/tokens.json</Text> · 中台{" "}
        <Text code>foundation.design-tokens</Text>
      </Paragraph>

      <Title level={4}>组件怎么分类？（三类）</Title>
      <Paragraph type="secondary" style={{ marginBottom: 12 }}>
        按复用价值划分；组件中文名旁的英文与 Ant Design / Apple 等业内称谓对齐，便于检索与沟通。
      </Paragraph>
      <Collapse
        defaultActiveKey={["basic", "foundation", "business"]}
        items={TAXONOMY.map((t) => ({
          key: t.key,
          label: <Text strong>{t.title}</Text>,
          children: (
            <div style={{ fontSize: 13, lineHeight: 1.7 }}>
              <div>
                <Text type="secondary">一句话：</Text>
                {t.oneLiner}
              </div>
              <div>
                <Text type="secondary">怎么理解：</Text>
                {t.analogy}
              </div>
              <div>
                <Text type="secondary">例子：</Text>
                {t.examples}
              </div>
              <div>
                <Text type="secondary">复用方式：</Text>
                {t.reuse}
              </div>
            </div>
          ),
        }))}
        style={{ marginBottom: 28 }}
      />

      <Title level={4}>色彩 Color</Title>
      <Row gutter={[12, 12]}>
        {Object.entries(colors).map(([k, v]) => (
          <Col key={k} xs={12} sm={8} md={6}>
            <Card size="small">
              <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                <div
                  style={{
                    width: 36,
                    height: 36,
                    borderRadius: 8,
                    background: v,
                    border: "1px solid #f0f0f0",
                  }}
                />
                <div>
                  <div>{k}</div>
                  <Text type="secondary" code>
                    {v}
                  </Text>
                </div>
              </div>
            </Card>
          </Col>
        ))}
      </Row>

      <Title level={4} style={{ marginTop: 28 }}>
        字号 Font
      </Title>
      <Table
        size="small"
        pagination={false}
        rowKey="k"
        dataSource={Object.entries(font).map(([k, v]) => ({ k, v: String(v) }))}
        columns={[
          { title: "Token", dataIndex: "k", render: (k) => <Text code>font.{k}</Text> },
          { title: "值", dataIndex: "v" },
        ]}
      />

      <Title level={4} style={{ marginTop: 28 }}>
        间距 Space
      </Title>
      <Table
        size="small"
        pagination={false}
        rowKey="k"
        dataSource={Object.entries(space).map(([k, v]) => ({ k, v: String(v) }))}
        columns={[
          { title: "Token", dataIndex: "k", render: (k) => <Text code>space.{k}</Text> },
          { title: "值", dataIndex: "v" },
        ]}
      />

      <Title level={4} style={{ marginTop: 28 }}>
        圆角 Radius
      </Title>
      <Table
        size="small"
        pagination={false}
        rowKey="k"
        dataSource={Object.entries(radius).map(([k, v]) => ({ k, v: String(v) }))}
        columns={[
          { title: "Token", dataIndex: "k", render: (k) => <Text code>radius.{k}</Text> },
          { title: "值", dataIndex: "v" },
        ]}
      />

      <Title level={4} style={{ marginTop: 32 }}>
        🔄 跨 App 复用分析
      </Title>
      <Paragraph type="secondary">
        基于 <Text code>usedInApps</Text> 自动追踪。仅在单一 App 中使用的组件，复用场景有限，可能不适合作为基础组件。
      </Paragraph>
      {(() => {
        const singleApp = data.components.filter((c) => c.usedInApps.length <= 1);
        const multiApp = data.components.filter((c) => c.usedInApps.length > 1);
        const noApp = data.components.filter((c) => c.usedInApps.length === 0);
        return (
          <>
            <Row gutter={[12, 12]} style={{ marginBottom: 16 }}>
              <Col xs={8}>
                <Card size="small" style={{ textAlign: "center" }}>
                  <Title level={3} style={{ margin: 0, color: "#16A34A" }}>
                    {multiApp.length}
                  </Title>
                  <Text type="secondary">多 App 复用</Text>
                </Card>
              </Col>
              <Col xs={8}>
                <Card size="small" style={{ textAlign: "center" }}>
                  <Title level={3} style={{ margin: 0, color: "#FA8C16" }}>
                    {singleApp.length}
                  </Title>
                  <Text type="secondary">单 App 使用</Text>
                </Card>
              </Col>
              <Col xs={8}>
                <Card size="small" style={{ textAlign: "center" }}>
                  <Title level={3} style={{ margin: 0, color: "#8c8c8c" }}>
                    {noApp.length}
                  </Title>
                  <Text type="secondary">尚未使用</Text>
                </Card>
              </Col>
            </Row>
            <Collapse
              items={[
                {
                  key: "single",
                  label: (
                    <Text>
                      <Tag color="warning">单 App</Tag> 仅在单一 App 中使用的组件（共 {singleApp.length} 个）
                    </Text>
                  ),
                  children: (
                    <Table
                      size="small"
                      pagination={false}
                      rowKey="id"
                      dataSource={singleApp}
                      columns={[
                        {
                          title: "组件",
                          dataIndex: "name",
                          render: (v: string, r: any) => (
                            <div>
                              {v}
                              <br />
                              <Text type="secondary" code>{r.id}</Text>
                            </div>
                          ),
                        },
                        {
                          title: "分类",
                          dataIndex: "category",
                          render: (v: string) => (
                            <Tag color={v === "basic" ? "blue" : v === "foundation" ? "cyan" : "default"}>
                              {v}
                            </Tag>
                          ),
                        },
                        {
                          title: "使用 App",
                          dataIndex: "usedInApps",
                          render: (apps: string[]) =>
                            apps.length > 0 ? (
                              apps.map((a) => <Tag key={a}>{a}</Tag>)
                            ) : (
                              <Text type="secondary">—</Text>
                            ),
                        },
                        { title: "说明", dataIndex: "summary", ellipsis: true },
                      ]}
                    />
                  ),
                },
                {
                  key: "multi",
                  label: (
                    <Text>
                      <Tag color="success">多 App</Tag> 跨 App 复用的组件（共 {multiApp.length} 个）
                    </Text>
                  ),
                  children: (
                    <Table
                      size="small"
                      pagination={false}
                      rowKey="id"
                      dataSource={multiApp}
                      columns={[
                        {
                          title: "组件",
                          dataIndex: "name",
                          render: (v: string, r: any) => (
                            <div>
                              {v}
                              <br />
                              <Text type="secondary" code>{r.id}</Text>
                            </div>
                          ),
                        },
                        {
                          title: "分类",
                          dataIndex: "category",
                          render: (v: string) => (
                            <Tag color={v === "basic" ? "blue" : v === "foundation" ? "cyan" : "default"}>
                              {v}
                            </Tag>
                          ),
                        },
                        {
                          title: "使用 App",
                          dataIndex: "usedInApps",
                          render: (apps: string[]) =>
                            apps.map((a) => <Tag key={a}>{a}</Tag>),
                        },
                        { title: "说明", dataIndex: "summary", ellipsis: true },
                      ]}
                    />
                  ),
                },
              ]}
            />
          </>
        );
      })()}
    </div>
  );
}
