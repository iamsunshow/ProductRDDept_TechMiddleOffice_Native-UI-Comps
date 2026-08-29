import { Card, Divider, Typography } from "antd";
import type { CatalogData } from "../types";

const { Title, Paragraph, Text } = Typography;

function Code({ children }: { children: string }) {
  return (
    <pre
      style={{
        background: "#0f172a",
        color: "#e2e8f0",
        padding: "16px 18px",
        borderRadius: 8,
        overflow: "auto",
        fontSize: 13,
        lineHeight: 1.7,
      }}
    >
      {children}
    </pre>
  );
}

function Step({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <Title level={5} style={{ marginTop: 0, marginBottom: 8 }}>
        {title}
      </Title>
      {children}
    </div>
  );
}

export default function UsageGuide({ data }: { data: CatalogData }) {
  const meta = data.meta;
  return (
    <div style={{ padding: "24px 32px 48px", maxWidth: 900, margin: "0 auto" }}>
      <Title level={2} style={{ marginTop: 0 }}>
        使用指南
      </Title>
      <Paragraph type="secondary">
        在业务应用中引入 Native-UI-Comps，覆盖 iOS 与 Android 两端。组件库由中台技术部统一维护，随每次更新在「版本日志」同步发布。
      </Paragraph>
      <Divider />

      <Title level={4}>Android</Title>
      <Step title="1. 配置仓库">
        <Paragraph>
          组件以 <Text code>{meta.groupAndroid}</Text> 发布到 GitHub Packages 或 Maven Local。在工程 <Text code>settings.gradle.kts</Text> 添加仓库与本地模块依赖：
        </Paragraph>
        <Code>{`// settings.gradle.kts
dependencyResolutionManagement {
  repositories {
    google()
    mavenCentral()
    mavenLocal() // 本地调试
    maven { url = uri("https://maven.pkg.github.com/iamsunshow/zhiqihuayun-components") }
  }
}`}</Code>
      </Step>
      <Step title="2. 引入依赖">
        <Code>{`// app/build.gradle.kts
dependencies {
  implementation("${meta.groupAndroid}")
}`}</Code>
      </Step>
      <Step title="3. 导入命名空间">
        <Paragraph>
          所有组件与底层能力统一位于 <Text code>{meta.namespaceAndroid}</Text> 命名空间下：
        </Paragraph>
        <Code>{`import ${meta.namespaceAndroid}.foundation.design.*
import ${meta.namespaceAndroid}.sharedui.components.AppButton
import ${meta.namespaceAndroid}.sharedui.components.AppTextField`}</Code>
      </Step>

      <Divider />

      <Title level={4}>iOS</Title>
      <Step title="1. 添加 SPM 依赖">
        <Paragraph>
          iOS 侧通过 Swift Package Manager 引入。在 <Text code>Package.swift</Text> 中注册依赖：
        </Paragraph>
        <Code>{`.package(url: "https://github.com/iamsunshow/ProductRDDept_TechMiddleOffice_Native-UI-Comps.git", from: "1.0.0")`}</Code>
      </Step>
      <Step title="2. 引入模块">
        <Code>{`import Foundation  // 路由 / 存储 / HTTP / 金额格式等基建
import SharedUI   // 通用 UI 组件`}</Code>
      </Step>

      <Divider />

      <Title level={4}>快速开始</Title>
      <Card size="small" style={{ marginBottom: 12 }}>
        <Typography.Text strong>推荐流程</Typography.Text>
        <Paragraph style={{ marginTop: 8, marginBottom: 0 }}>
          1. 先在「组件库」页检索既有组件（支持语义搜索）；2. 优先复用并遵循「设计规范」中的 token；
          3. 双端能力差异见「双端契约」矩阵；4. 变更随「版本日志」发布。
        </Paragraph>
      </Card>
      <Paragraph type="secondary" style={{ fontSize: 12 }}>
        当前版本 {meta.version} · 仓库 {meta.repo}
      </Paragraph>
    </div>
  );
}
