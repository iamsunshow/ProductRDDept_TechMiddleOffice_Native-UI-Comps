export type ComponentDoc = {
  id: string;
  legacyId?: string;
  name: string;
  category: string;
  summary: string;
  industryNames?: string[];
  searchText: string;
  capabilities: string[];
  platforms: Record<string, { state: PlatformState; note?: string }>;
  usedInApps: string[];
  status: string;
  note: string;
  props: [string, string, string, string][];
  events: [string, string, string][];
  demos: [string, string][];
  image: string | null;
  vector: number[] | null;
};

export type DocMeta = {
  name: string;
  fullName: string;
  tagline: string;
  version: string;
  namespaceAndroid: string;
  groupAndroid: string;
  spmProduct: string;
  repo: string;
  platforms: string[];
  sources: Record<string, string>;
};

export type PlatformState = "available" | "partial" | "unavailable" | "draft";

export type ChangelogRelease = {
  version: string;
  date: string;
  groups: Record<string, string[]>;
};

export type CatalogData = {
  meta: DocMeta;
  backend: string;
  dim: number;
  categories: Record<string, { title: string; blurb: string }>;
  categoryOrder: string[];
  tokens: {
    color?: Record<string, string>;
    font?: Record<string, string | number>;
    space?: Record<string, number>;
    radius?: Record<string, number>;
  };
  components: ComponentDoc[];
  platformState: Record<string, Record<PlatformState, number>>;
  changelog: ChangelogRelease[];
};
