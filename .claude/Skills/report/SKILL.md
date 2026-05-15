---
name: report
description: >
  Expert Salesforce reporting guidance. Use this skill whenever the user mentions
  Salesforce reports, report builder, report types (tabular, summary, matrix, joined),
  report folders, report metadata XML, dashboards, report filters, cross-filters,
  bucket fields, summary formulas, row-level formulas, conditional highlighting,
  report subscriptions, or asks to create, design, review, or deploy any Salesforce
  report. Also trigger for questions about report folder structure, sharing, naming
  conventions, report best practices, .report-meta.xml, or report-folder-meta.xml files.
---

## Reference Templates

For complete, deployable `.report-meta.xml` and `.reportFolder-meta.xml` templates for all
report types, read `references/sf-report-templates.md`. Load it when generating report XML
or folder metadata.

---

## 1. Report Type Selection Guide

| Report Type | Use When | Groupings | Chart | Subtotals |
|-------------|----------|-----------|-------|-----------|
| Tabular | Simple list, export to Excel, no grouping needed | None | No | No |
| Summary | Group by 1–3 fields, subtotals, most common type | Up to 3 rows | Yes | Yes |
| Matrix | Cross-tab: rows vs columns (e.g. Stage by Month) | Rows + Columns | Yes | Yes |
| Joined | Compare multiple report blocks side-by-side | Per block | No | Per block |

**Decision rule:** Default to Summary unless you need column grouping (→ Matrix) or
multi-block comparison (→ Joined). Never use Tabular when the user needs totals.

---

## 2. Naming Conventions

Standard format: `[Team/Object] — [Purpose] — [Audience/Frequency]`

**Examples:**
- `Sales — Open Opportunities by Stage — Weekly Review`
- `Service — Cases Closed Without Resolution — Manager`
- `HR — Headcount by Department — Q2 2026`

**Rules:**
- Use em dash (—) as separator, not hyphen
- Team/Object first (enables folder-level sorting)
- Avoid vague names: "My Report", "Test", "New Report 1"
- Include audience or frequency when relevant
- Max 80 chars (Salesforce limit is 255 but keep it scannable)
- API name (for metadata): replace spaces/dashes with underscores, no special chars;
  suffix is auto-handled by Salesforce

---

## 3. Folder Structure and Governance

Best practice folder hierarchy:

```
Reports/
├── Sales/
│   ├── Pipeline/
│   ├── Forecasting/
│   └── Performance/
├── Service/
│   ├── Case Management/
│   └── SLA Tracking/
├── Finance/
├── HR/
├── Operations/
└── _Archive/          ← prefix underscore to sort last
```

**Rules:**
- Never store production reports in "My Reports" — not shareable, lost if user leaves
- One folder per team/department at root level
- Sub-folders for functional areas (Pipeline, Forecasting) within team folders
- `_Archive` folder for deprecated reports (don't delete — dashboards may reference them)
- Folder sharing: grant Edit to report owners, View to their managers/leadership
- Folder API names in metadata: `Sales_Reports`, `Sales_Pipeline_Reports` (no spaces)

---

## 4. Report Best Practices

### Filters
- Always set a meaningful date range filter — unbounded reports time out on large orgs
- Use relative ranges ("Current FY", "Current Quarter", "Last 30 Days"), not hardcoded dates
- Cross-filters for "without" logic: *Account WITHOUT Opportunities* is cleaner than workarounds
- Filter logic: use numbered logic `1 AND 2 AND (3 OR 4)` for complex conditions; document
  it in the report description
- Don't over-filter at report level when the report feeds a dashboard — use dashboard filters instead

### Groupings and Columns
- Order groupings from highest to lowest cardinality (Stage → Owner, not Owner → Stage)
- Don't exceed 15–20 columns for display reports; export-heavy reports can go wider
- Put the most important columns left; Salesforce displays left-to-right
- Use Bucket Fields for ad-hoc grouping instead of creating custom fields (e.g. bucket
  Revenue into Small/Medium/Large)

### Formulas and Summaries
- Summary formulas: aggregate across grouped rows (SUM, AVG, MAX, MIN, COUNT) — Summary
  and Matrix only
- Row-level formulas (Spring '21+): calculated per row like a formula field but report-only;
  no custom field needed
- Always set "Where will this formula be displayed?" to the correct grouping level
- Use `NULLVALUE(field, 0)` in formulas to handle blank numeric fields

### Performance
- Avoid reports that return > 2,000 rows for display; use export for large data sets
- Add selective filters early (date range, record type, owner) to reduce scan
- Avoid cross-object formula fields in report columns — they slow row-level processing

### Subscriptions and Scheduling
- Report subscriptions run as the subscriber — ensure they have field access to all columns
- Schedule during off-peak hours (before 7 am or after 7 pm)
- Use "Run report" + "Send email" for scheduled distribution; attach as Excel for
  stakeholders without Salesforce access

---

## 5. Metadata Structure Overview

A report in SFDX lives at:
```
force-app/main/default/reports/<FolderAPIName>/<ReportAPIName>.report-meta.xml
force-app/main/default/reportFolders/<FolderAPIName>.reportFolder-meta.xml
```

Key elements in `.report-meta.xml`:

| Element | Purpose |
|---------|---------|
| `<reportType>` | Base report type (e.g. `Opportunity`, `Case`, custom report types) |
| `<format>` | `TABULAR` \| `SUMMARY` \| `MATRIX` \| `JOINED` |
| `<columns>` | Fields to display (one `<columns>` block per field) |
| `<groupingsDown>` | Row groupings for Summary/Matrix |
| `<groupingsAcross>` | Column groupings for Matrix only |
| `<filter>` | Report filters |
| `<chart>` | Chart definition (optional) |
| `<aggregates>` | Summary formulas |
| `<buckets>` | Bucket field definitions |

*(See `references/sf-report-templates.md` for complete XML templates for all 4 report types)*

---

## 6. Deployment Commands

```bash
# Retrieve a specific report from org (inspect its XML)
sf project retrieve start \
  --metadata "Report:Sales_Reports/Open_Opportunities_by_Stage" \
  --target-org myOrg

# Retrieve an entire report folder
sf project retrieve start \
  --metadata "Report:Sales_Pipeline_Reports" \
  --target-org myOrg

# Deploy all reports
sf project deploy start \
  --source-dir force-app/main/default/reports \
  --target-org myOrg

# Deploy a single report
sf project deploy start \
  --source-dir "force-app/main/default/reports/Sales_Reports/Open_Opportunities_by_Stage.report-meta.xml" \
  --target-org myOrg

# Deploy folder + its reports together
sf project deploy start \
  --metadata "ReportFolder:Sales_Reports" \
  --metadata "Report:Sales_Reports/Open_Opportunities_by_Stage" \
  --target-org myOrg
```

**Note:** Always deploy the `ReportFolder` metadata before or alongside its reports —
deploying a report into a non-existent folder fails.

---

## 7. Output Format

When designing or generating a report, use the appropriate format below.

**Design request** (no XML needed):
1. Recommended report type + reason
2. Suggested name (following naming convention)
3. Suggested folder
4. Columns list (in display order)
5. Groupings (for Summary/Matrix)
6. Filters (with logic)
7. Chart recommendation (if any)

**Metadata generation request:**
- State the file path before each XML block
- Generate `.reportFolder-meta.xml` if the folder doesn't exist yet
- End with deployment commands
- Add a note if the report type is a custom report type (must already exist in target org)