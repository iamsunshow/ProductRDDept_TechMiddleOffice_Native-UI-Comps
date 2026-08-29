import { Timeline, Typography } from "antd";
import type { CatalogData } from "../types";

const GROUP_COLOR: Record<string, string> = {
  Added: "green",
  Changed: "blue",
  Deprecated: "orange",
  Removed: "red",
  Fixed: "cyan",
  Security: "red",
};

const GROUP_ORDER = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security"];

export default function Changelog({ data }: { data: CatalogData }) {
  const releases = data.changelog;
  return (
    <div style={{ padding: "24px 32px 48px", maxWidth: 900, margin: "0 auto" }}>
      <Typography.Title level={2} style={{ marginTop: 0 }}>
        版本日志
      </Typography.Title>
      <Typography.Paragraph type="secondary">
        数据源为组件库根目录 <Typography.Text code>CHANGELOG.md</Typography.Text>
        ，每次发布随更新一并维护。格式遵循 Keep a Changelog。
      </Typography.Paragraph>

      {releases.length === 0 ? (
        <Typography.Paragraph type="secondary">暂无版本记录。</Typography.Paragraph>
      ) : (
        releases.map((rel) => (
          <div key={rel.version} style={{ marginBottom: 28 }}>
            <div style={{ display: "flex", alignItems: "baseline", gap: 12 }}>
              <Typography.Title level={3} style={{ margin: 0 }}>
                v{rel.version}
              </Typography.Title>
              <Typography.Text type="secondary">{rel.date}</Typography.Text>
            </div>
            {GROUP_ORDER.filter((g) => rel.groups[g]?.length).map((g) => (
              <div key={g} style={{ marginTop: 10 }}>
                <Typography.Text
                  strong
                  style={{
                    color:
                      GROUP_COLOR[g] === "green"
                        ? "#16a34a"
                        : GROUP_COLOR[g] === "blue"
                          ? "#1677ff"
                          : GROUP_COLOR[g] === "orange"
                            ? "#d97706"
                            : GROUP_COLOR[g] === "cyan"
                              ? "#0891b2"
                              : "#dc2626",
                  }}
                >
                  {g}
                </Typography.Text>
                <Timeline
                  style={{ marginTop: 6, marginLeft: 4 }}
                  items={rel.groups[g].map((item, i) => ({
                    key: i,
                    color: GROUP_COLOR[g],
                    children: item,
                  }))}
                />
              </div>
            ))}
          </div>
        ))
      )}
    </div>
  );
}
