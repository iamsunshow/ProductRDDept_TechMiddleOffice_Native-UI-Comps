import { Card, Col, Progress, Row, Statistic, Tag, Typography } from "antd";
import type { CatalogData } from "../types";

const PLATFORM_LABEL: Record<string, string> = {
  ios: "iOS",
  android: "Android",
  harmony: "HarmonyOS",
  weixin: "微信小程序",
  alipay: "支付宝小程序",
};

const PLATFORM_COLOR: Record<string, string> = {
  ios: "#1677ff",
  android: "#3ddc84",
  harmony: "#00a6fb",
  weixin: "#07c160",
  alipay: "#1677ff",
};

function SectionTitle({ children }: { children: React.ReactNode }) {
  return (
    <Typography.Title level={4} style={{ marginTop: 28, marginBottom: 16 }}>
      {children}
    </Typography.Title>
  );
}

export default function HomePage({ data }: { data: CatalogData }) {
  const meta = data.meta;
  const total = data.components.length;
  const stableCount = data.components.filter((c) => c.status === "stable").length;
  const withImage = data.components.filter((c) => c.image).length;

  const stats = [
    { title: "组件总数", value: total, suffix: "个" },
    { title: "稳定组件", value: stableCount, suffix: "个" },
    { title: "设计 Token", value: Object.values(data.tokens).reduce((n, t) => n + Object.keys(t ?? {}).length, 0), suffix: "个" },
    { title: "带预览图", value: withImage, suffix: "个" },
  ];

  return (
    <div style={{ padding: "24px 32px 48px", maxWidth: 1080, margin: "0 auto" }}>
      {/* Hero */}
      <div style={{ background: "linear-gradient(135deg,#0ea5e9 0%,#16a34a 100%)", borderRadius: 12, padding: "36px 32px", color: "#fff" }}>
        <Typography.Title level={2} style={{ color: "#fff", margin: 0 }}>
          {meta.fullName}
        </Typography.Title>
        <div style={{ opacity: 0.92, fontSize: 16, marginTop: 8, maxWidth: 720 }}>{meta.tagline}</div>
        <div style={{ marginTop: 16, display: "flex", gap: 12, flexWrap: "wrap", alignItems: "center" }}>
          <Tag style={{ background: "rgba(255,255,255,0.2)", color: "#fff", border: "none", borderRadius: 4 }}>v{meta.version}</Tag>
          <Tag style={{ background: "rgba(255,255,255,0.2)", color: "#fff", border: "none", borderRadius: 4 }}>
            {meta.namespaceAndroid}（Android）
          </Tag>
          <Tag style={{ background: "rgba(255,255,255,0.2)", color: "#fff", border: "none", borderRadius: 4 }}>
            {meta.spmProduct}（iOS）
          </Tag>
        </div>
      </div>

      {/* Stats */}
      <Row gutter={[16, 16]} style={{ marginTop: 20 }}>
        {stats.map((s) => (
          <Col xs={12} md={6} key={s.title}>
            <Card>
              <Statistic title={s.title} value={s.value} suffix={s.suffix} />
            </Card>
          </Col>
        ))}
      </Row>

      {/* 平台覆盖 */}
      <SectionTitle>平台覆盖</SectionTitle>
      <Row gutter={[16, 16]}>
        {data.meta.platforms.map((p) => {
          const st = data.platformState[p] ?? { available: 0, partial: 0, unavailable: 0 };
          const covered = st.available + st.partial;
          const percent = total ? Math.round((covered / total) * 100) : 0;
          return (
            <Col xs={24} md={12} lg={8} key={p}>
              <Card size="small">
                <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                  <Typography.Text strong style={{ color: PLATFORM_COLOR[p] }}>
                    {PLATFORM_LABEL[p] ?? p}
                  </Typography.Text>
                  <span style={{ fontSize: 12, color: "rgba(0,0,0,0.45)" }}>
                    {covered}/{total} 覆盖
                  </span>
                </div>
                <Progress
                  percent={percent}
                  size="small"
                  strokeColor={PLATFORM_COLOR[p]}
                  format={(v) => `${v}%`}
                  style={{ marginTop: 6 }}
                />
                <div style={{ fontSize: 12, color: "rgba(0,0,0,0.45)", marginTop: 4 }}>
                  <span style={{ color: "#16a34a" }}>{st.available} 可用</span>
                  <span style={{ margin: "0 8px" }}>·</span>
                  <span style={{ color: "#d97706" }}>{st.partial} 部分</span>
                  <span style={{ margin: "0 8px" }}>·</span>
                  <span style={{ color: "rgba(0,0,0,0.35)" }}>{st.unavailable} 未实现</span>
                </div>
              </Card>
            </Col>
          );
        })}
      </Row>

      {/* 分类概览 */}
      <SectionTitle>能力分层</SectionTitle>
      <Row gutter={[16, 16]}>
        {data.categoryOrder.map((cat) => {
          const metaCat = data.categories[cat];
          const comps = data.components.filter((c) => c.category === cat);
          const available = comps.filter((c) => c.platforms.ios?.state !== "unavailable").length;
          return (
            <Col xs={24} md={8} key={cat}>
              <Card
                title={
                  <span>
                    {metaCat?.title ?? cat}
                    <Tag style={{ marginLeft: 8 }}>{comps.length}</Tag>
                  </span>
                }
              >
                <Typography.Paragraph type="secondary" style={{ minHeight: 44 }}>
                  {metaCat?.blurb}
                </Typography.Paragraph>
                <div style={{ fontSize: 12, color: "rgba(0,0,0,0.45)" }}>
                  iOS 可用 {available} / Android 可用{" "}
                  {comps.filter((c) => c.platforms.android?.state !== "unavailable").length}
                </div>
              </Card>
            </Col>
          );
        })}
      </Row>
    </div>
  );
}
