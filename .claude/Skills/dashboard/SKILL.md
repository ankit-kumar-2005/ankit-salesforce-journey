---
name: dashboard
description: >
  Expert Salesforce dashboard guidance. Use this skill whenever the user mentions
  Salesforce dashboards, dashboard components, dashboard builder, dashboard filters,
  dynamic dashboards, dashboard running user, dashboard refresh, dashboard folders,
  dashboard metadata XML, .dashboard-meta.xml, or asks to create, design, review,
  or deploy any Salesforce dashboard. Also trigger for questions about chart types
  (bar, line, donut, funnel, scatter, gauge), KPI metrics, dashboard layout,
  dashboard sharing, dashboard subscriptions, or dashboard best practices.
---

## Reference Templates

Load `references/sf-dashboard-templates.md` whenever generating dashboard XML or folder metadata. That file contains complete `.dashboard-meta.xml` and `.dashboardFolder-meta.xml` examples for every component type.

---

## 1. Dashboard Component Type Guide

| Component | Best For | Source Required | Notes |
|---|---|---|---|
| Metric | Single KPI number (total revenue, open cases) | Summary or Tabular report with aggregate | Shows one value prominently |
| Gauge | Progress toward a target (quota attainment) | Summary or Tabular with aggregate | Set low/medium/high breakpoints |
| Chart — Bar/Column | Compare values across categories | Summary report grouped by 1 field | Horizontal bar for long labels |
| Chart — Line | Trends over time | Summary grouped by date field | Use Calendar Month/Quarter granularity |
| Chart — Donut/Pie | Part-to-whole breakdown (max 5–7 slices) | Summary grouped by 1 field | Avoid pie for > 7 categories |
| Chart — Funnel | Stage progression (pipeline, conversion) | Summary grouped by stage field | Order grouping by stage sequence |
| Chart — Scatter | Correlation between 2 measures | Summary with 2 aggregates | Rarely used; explain axes clearly |
| Table | Top-N list (top deals, worst SLA cases) | Any report type | Max 10 rows for readability |
| Visualforce | Custom embedded component | N/A | Legacy; prefer Lightning components |

**Decision rule:** Lead with Metric for the headline number, use Chart for distribution/trend, Table for actionable lists. Never put more than 2 Metrics side-by-side without a Chart for context.

---

## 2. Naming Conventions

Standard format: `[Team/Function] — [Purpose] — [Audience]`

Examples:
- `Sales — Pipeline Overview — VP of Sales`
- `Service — SLA Compliance — Operations Team`
- `Finance — Monthly Revenue KPIs — Executive`
- `HR — Headcount and Attrition — HR Leadership`

Rules:
- Use em dash (—) as separator (same as reports)
- Team/Function first — enables alphabetical sorting in folder
- Always name the audience — helps future admins know who uses it
- Avoid: "Dashboard 1", "My Dashboard", "New Dashboard", "Test"
- Max 80 chars for readability (Salesforce limit is 255)
- API name in metadata: spaces and dashes become underscores

---

## 3. Folder Structure and Governance

```
Dashboards/
├── Sales/
│   ├── Executive/
│   ├── Manager/
│   └── Rep/
├── Service/
│   ├── Operations/
│   └── Leadership/
├── Finance/
├── Marketing/
├── HR/
├── Operations/
└── _Archive/
```

Rules:
- Never store dashboards in "My Personal Dashboards" — not shareable
- Mirror report folder structure where possible (Sales reports → Sales dashboards)
- Sub-folders by audience tier: Executive, Manager, Rep — dashboards differ by data scope
- `_Archive` for deprecated dashboards (keep so bookmarks don't 404)
- Folder sharing: Edit to dashboard owners, View to their audience
- One owner per dashboard who is responsible for keeping it current

---

## 4. Dashboard Best Practices

### Layout and Design
- Top row: 2–3 Metric components showing the most critical KPIs
- Middle rows: Charts providing context and breakdown
- Bottom rows: Tables with actionable row-level data
- Use consistent column widths — 3-column grid is standard (each component spans 1, 2, or 3 columns)
- Group related components visually; use dashboard text components as section headers
- Limit to 20 components per dashboard — split into multiple dashboards if more needed
- Mobile: Lightning dashboards reflow, but test on mobile view; avoid wide tables

### Running User and Dynamic Dashboards

Three running user modes — choose carefully:

| Mode | What User Sees | Use When |
|---|---|---|
| Specific user | That user's data always | Executive dashboard showing org-wide data |
| Logged-in user (Dynamic) | Their own data | Rep-level dashboard filtered to their records |
| Let authorized users change | Viewer selects | Manager dashboards where manager picks a rep |

Dynamic dashboards count against org limits (5 default, up to 10 with add-on) — use them intentionally, not by default.

### Filters
- Dashboard filters (up to 3) let viewers slice data without editing — always add filters for Date Range and Owner/Team
- Filter field must exist on the source report's report type
- Don't use dashboard filters as a replacement for report-level data scoping — filter at report level first, dashboard filter for ad-hoc slicing
- Name filters clearly: "Date Range", "Sales Team", "Record Type" — not "Filter 1"

### Refresh and Subscriptions
- Lightning dashboards refresh on open (if stale) — users see a "Refreshing" indicator
- Schedule refresh for heavy dashboards during off-peak hours
- Dashboard subscriptions: send via email on a schedule; recipient sees a static snapshot
- Always verify the running user has access to all source reports before sharing

### Performance
- Each component = one report query; 20 components = 20 queries on open
- Use pre-aggregated Summary/Matrix reports as sources — never Tabular for charts
- Avoid reports with > 2,000 rows as dashboard sources — they time out
- If a dashboard is slow, check source reports first (add selective filters)

---

## 5. Metadata Structure Overview

```
force-app/main/default/dashboards/<FolderAPIName>/<DashboardAPIName>.dashboard-meta.xml
force-app/main/default/dashboardFolders/<FolderAPIName>.dashboardFolder-meta.xml
```

Key XML elements:
- `<runningUser>` — username of the running user (for specific user mode)
- `<dashboardType>` — `SpecifiedUser` | `LoggedInUser` | `MyTeamUser`
- `<components>` — one block per component (chart, metric, gauge, table)
- `<dashboardFilters>` — up to 3 filter definitions
- `<leftSection>`, `<middleSection>`, `<rightSection>` — 3-column layout containers
- `<header>` — section label text component
- `<title>` — component title

*(See `references/sf-dashboard-templates.md` for complete XML for all component types)*

---

## 6. Deployment Commands

```bash
# Retrieve a dashboard from org
sf project retrieve start \
  --metadata "Dashboard:Sales_Dashboards/Pipeline_Overview" \
  --target-org myOrg

# Retrieve entire dashboard folder
sf project retrieve start \
  --metadata "Dashboard:Sales_Dashboards" \
  --target-org myOrg

# Deploy dashboards (folder must exist first)
sf project deploy start \
  --source-dir force-app/main/default/dashboards \
  --target-org myOrg

# Deploy folder + dashboards together
sf project deploy start \
  --metadata "DashboardFolder:Sales_Dashboards" \
  --metadata "Dashboard:Sales_Dashboards/Pipeline_Overview" \
  --target-org myOrg
```

Note: The running user specified in `<runningUser>` must exist in the target org — use a service/integration user that exists in all environments, not a named employee.

---

## 7. Output Format

**Design request** (no XML needed):
1. Recommended layout — describe the grid row by row
2. Component list — type, title, source report, and key metric for each
3. Suggested running user mode + reason
4. Suggested filters (up to 3)
5. Suggested name and folder
6. Any risks or data access notes

**Metadata generation request:**
- File path before each XML block
- Generate `dashboardFolder-meta.xml` if folder doesn't exist
- End with deployment commands
- Flag if `<runningUser>` needs to be updated per environment