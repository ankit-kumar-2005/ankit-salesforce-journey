# Claude Code — Salesforce Developer Setup

A ready-to-use Claude Code configuration for Salesforce teams. Drop the `.claude` folder into any SFDX project and immediately get AI-assisted development with built-in guardrails for Apex, LWC, metadata, and Flow.

---

## What This Gives You

Fourteen specialized **Skills** that activate automatically based on what you're working on:

| Skill | What it does |
|---|---|
| `apex` | Generates production-grade Apex (Service, Selector, Domain, Batch, Queueable, REST, etc.) |
| `apex-test` | Writes bulk-tested test classes with TestDataFactory, mocking, and fix loops |
| `lwc` | Builds complete LWC component bundles with SLDS, wire, Jest tests |
| `custom-object` | Creates Custom Object metadata XML with correct sharing models |
| `custom-field` | Creates Custom Field metadata with strict validation (Roll-Up Summary, formulas, etc.) |
| `list-view` | Generates List View metadata with filters, columns, and visibility |
| `flow` | Builds Salesforce Flows via a 3-step MCP pipeline (Screen, Record-Triggered, Scheduled) |
| `custom-tab` | Creates Custom Tab metadata (object, web, Visualforce tabs) |
| `custom-application` | Creates Lightning App metadata with navigation, branding, and action overrides |
| `flexipage` | Generates Lightning pages (RecordPage, AppPage, HomePage) via CLI bootstrapping |
| `permission-set` | Generates Permission Set metadata with object, field, and user permissions |
| `validation-rule` | Creates Validation Rule metadata with formula enforcement and error messages |
| `report` | Designs and generates Salesforce Report metadata (Tabular, Summary, Matrix, Joined) |
| `dashboard` | Designs and generates Salesforce Dashboard metadata with charts, metrics, and gauges |

Each skill includes **code templates**, **real-world references**, and **hard-coded guardrails** — so Claude doesn't just generate code, it generates *correct* Salesforce code.

---

## Prerequisites

### 1. Install Claude Code CLI

```bash
npm install -g @anthropic/claude-code
```

Verify:

```bash
claude --version
```

You need an Anthropic account. Sign up at [claude.ai](https://claude.ai) and authenticate:

```bash
claude
```

### 2. Salesforce CLI

```bash
npm install -g @salesforce/cli
sf --version
```

### 3. Node.js 18+

```bash
node --version   # must be v18 or higher
```

---

## Setup — 2 Steps

### Step 1: Copy the `.claude` folder

Copy the `.claude` folder from this repo into the **root** of your Salesforce SFDX project:

```
your-sf-project/
├── .claude/          ← copy this entire folder here
│   └── Skills/
│       ├── apex/
│       ├── apex-test/
│       ├── lwc/
│       ├── custom-object/
│       ├── custom-field/
│       ├── list-view/
│       ├── flow/
│       ├── custom-tab/
│       ├── custom-application/
│       ├── flexipage/
│       ├── permission-set/
│       ├── validation-rule/
│       ├── report/
│       └── dashboard/
├── force-app/
├── sfdx-project.json
└── ...
```

That's it. Claude Code will automatically discover and load the Skills.

### Step 2: Start Claude Code in your project

```bash
cd your-sf-project
claude
```

---

## How Skills Work

Skills activate **automatically** — you don't need to invoke them manually. Claude detects what you're working on from your request and loads the right skill, templates, and guardrails.

Examples that trigger each skill:

| What you type | Skill activated |
|---|---|
| "Create an Apex service class for Account management" | `apex` |
| "Write tests for AccountService" | `apex-test` |
| "Build an LWC component that shows related contacts" | `lwc` |
| "Create a custom object for Project Requests" | `custom-object` |
| "Add a Roll-Up Summary field for total contract value" | `custom-field` |
| "Create a list view showing open cases assigned to me" | `list-view` |
| "Build a flow that sends an email when an Opportunity closes" | `flow` |
| "Create a tab for the Project Request object" | `custom-tab` |
| "Set up a Lightning app for the project management team" | `custom-application` |
| "Generate a record page for the Project Request object" | `flexipage` |
| "Create a permission set for read access to invoices" | `permission-set` |
| "Add a validation rule to require Description when Status is Approved" | `validation-rule` |
| "Create a Summary report showing open opportunities by stage" | `report` |
| "Build a sales pipeline dashboard with KPI metrics and charts" | `dashboard` |

---

## Skill Reference

### Apex — Class Generation

**Triggers on**: mentions of Apex, `.cls` files, service/selector/batch/trigger/API class requests.

**Example prompts:**

```
Create an Apex service class for managing Opportunity line items.
Include methods to add, update, and remove line items in bulk.
```

```
Write an Apex batch class that deactivates contacts who haven't
logged in for 180 days. Process 200 records at a time.
```

```
Create a Queueable Apex class that calls an external REST API
to sync Account data, with retry logic using Database.Finalizer.
```

**What you get:**
- `.cls` + `.cls-meta.xml` (API version 66.0)
- Service-Selector-Domain architecture by default
- Bulkified, `with sharing`, no SOQL/DML in loops
- ApexDoc comments on public methods

**Patterns available:** Service, Selector, Domain, Batch, Queueable, Schedulable, Trigger, Invocable, REST Resource, Interface, Abstract, Exception, DTO, Utility

---

### Apex Test — Test Class Generation

**Triggers on**: `*Test.cls` files, test failures, coverage gaps, "write tests for…"

**Example prompts:**

```
Write a test class for AccountService. Cover positive, negative,
and bulk scenarios (200+ records).
```

```
My test class is failing on the bulkification test. Run the tests
and fix any failures, up to 3 attempts.
```

```
Generate a TestDataFactory that creates Accounts, Contacts,
and Opportunities with configurable field overrides.
```

**What you get:**
- Test class with 6+ test methods (positive bulk, negative, edge cases)
- TestDataFactory with bulk record builders
- 75%+ coverage minimum, 90%+ recommended
- `Assert` class assertions (never `System.assert*`)
- Mocking for callouts, SOSL, email, Platform Events

**Workflow:** Generate → Run → Analyze → Fix (max 3 fix loops) → Validate coverage

---

### LWC — Lightning Web Components

**Triggers on**: LWC, Lightning Web Components, `.html/.js/.css/.xml` files, wire adapters, Aura-to-LWC migrations.

**Example prompts:**

```
Build an LWC component that displays a list of Contacts for the
current Account record. Use a wire adapter and show a spinner
while loading. Include a refresh button.
```

```
Create a Flow screen component with a custom picklist input
that validates the selection before allowing the user to proceed.
```

```
Build an LWC modal component that opens when a button is clicked,
shows a form to create a new Case, and dispatches a custom event
on save.
```

**What you get:**
- Complete bundle: `.html`, `.js`, `.css`, `.js-meta.xml`
- Jest test file
- LDS-first approach (wire before custom Apex)
- Correct `@api`/`@track`/`@wire` usage
- SLDS styling, accessibility attributes
- Shadow DOM-safe event handling

**Component types available:** Basic, Form, Modal, Data Table, Flow Screen, GraphQL, Message Channel (LMS), Record Picker, State Store, TypeScript, Workspace API

---

### Custom Object — Object Metadata

**Triggers on**: custom objects, object metadata, `.object-meta.xml`, sharing models.

**Example prompts:**

```
Create a custom object called "Project Request" with a lookup
to Account, auto-number name field, and a validation rule
requiring the description field to be filled in.
```

```
Generate metadata for a "Invoice Line" object that has a
Master-Detail relationship to Invoice__c.
```

**What you get:**
- Valid `CustomObject` XML
- Correct `sharingModel` (`ControlledByParent` for Master-Detail, `Private` otherwise)
- Name field (Text or AutoNumber)
- Standard features enabled (search, reports, activities)
- Validation rules with correct naming (no `__c` suffix)

---

### Custom Field — Field Metadata

**Triggers on**: custom fields, field types, Roll-Up Summary, formula fields, picklists, field deployment errors.

**Example prompts:**

```
Add a Roll-Up Summary field on Account that counts the number
of closed-won Opportunities.
```

```
Create a formula field on Opportunity that calculates the
discount percentage as (1 - Amount / List_Price__c) * 100.
```

```
Add a Master-Detail field on Invoice_Line__c pointing to Invoice__c.
```

**What you get:**
- Valid `CustomField` XML with all required attributes
- Roll-Up Summary: correct `summarizedField` format, no forbidden attributes
- Formula: wrapped in `<![CDATA[...]]>`, correct result type
- Master-Detail: no `required`/`deleteConstraint`/`lookupFilter` (auto-set by platform)

> **Note:** Roll-Up Summary and Master-Detail fields have the highest deployment failure rate. This skill has explicit validation to prevent the most common errors.

---

### List View — List View Metadata

**Triggers on**: list views, "create a view that shows…", "filter records by…", `.listView-meta.xml`.

**Example prompts:**

```
Create a list view on the Case object that shows all open cases
assigned to me, sorted by CreatedDate descending. Columns:
Case Number, Subject, Status, Priority, Account Name.
```

```
Build a list view on Opportunity__c showing opportunities closing
this quarter with Amount > 50000, visible to all users.
```

**What you get:**
- Valid `ListView` XML
- Correct field API names (custom fields as `Field__c`, standard as `FIELD_NAME`)
- Filter operations matched to field types
- File placed at correct path under `objects/{Object}/listViews/`

---

### Flow — Salesforce Flow Automation

**Triggers on**: flow creation, "when a record is created/updated", "send email when", "update field when", "schedule daily at", "automate", "workflow".

**Example prompts:**

```
Create a Record-Triggered flow on Opportunity that sends an email
to the owner when Stage changes to Closed Won.
```

```
Build a Screen flow that walks a user through creating a new
Account, Contact, and Opportunity in 3 steps.
```

```
Create a Scheduled flow that runs every day at 8am and marks
Leads as stale if they haven't been updated in 30 days.
```

**What you get:**
- Complete Flow XML via a strict 3-step MCP pipeline
- Record-Triggered (before/after save), Screen, Autolaunched, or Scheduled
- Element-by-element generation validated against live org metadata

> **Important:** Flow generation requires org connectivity (MCP tools). If you're offline, this skill won't function. For multiple flows, describe them one at a time.

### Custom Tab — Tab Metadata

**Triggers on**: tabs, navigation tabs, object tabs, web tabs, Visualforce tabs, Lightning component tabs.

**Example prompts:**

```
Create a tab for the Project_Request__c custom object.
```

```
Create a web tab called "Company Portal" that opens
https://portal.example.com in a new window.
```

**What you get:**
- Valid `CustomTab` XML with the correct element set per tab type
- Object tabs: `<customObject>true</customObject>` with a unique contextual motif
- Web tabs: `<url>`, encoding key, optional frame height
- Visualforce tabs: references the page API name

> **Note:** Many elements are forbidden by Salesforce depending on tab type. This skill enforces a strict allowlist to prevent deployment errors.

---

### Custom Application — Lightning App Metadata

**Triggers on**: custom apps, Lightning apps, app navigation, "organize tabs into an application".

**Example prompts:**

```
Create a Lightning app called "Project Management" with tabs for
Project_Request__c, Task, and a dashboard. Use a blue header.
```

```
Build a Console-style Lightning app for the Service team
with Case, Contact, and Knowledge tabs.
```

**What you get:**
- Valid `.app-meta.xml` with `uiType: Lightning`
- Correct navigation type: `Standard` (default) or `Console` (multi-tab service workspaces only)
- Mandatory `headerColor` branding in hex format (e.g. `#0070D2`)
- Action overrides for custom object record pages
- `formFactors` set for desktop (`LARGE`)

---

### FlexiPage — Lightning Pages

**Triggers on**: Lightning pages, RecordPage, AppPage, HomePage, "add a component to a page", "customize the record page", `.flexipage-meta.xml`.

**Example prompts:**

```
Generate a record page for Project_Request__c with the record
highlights at the top and related lists on the right.
```

```
Create an App Page for the Project Management app with a
dashboard component in the main region.
```

**What you get:**
- Valid `.flexipage-meta.xml` bootstrapped from the Salesforce CLI template (never hand-crafted)
- Correct field references using `Record.{FieldApiName}` format
- Unique identifiers and region names throughout the file
- Dry-run deployment validation before finalizing

> **Note:** Page XML is always CLI-bootstrapped — this prevents the most common FlexiPage deployment errors caused by hand-authored XML.

---

### Permission Set — Permission Set Metadata

**Triggers on**: permission sets, object permissions, field-level security (FLS), tab visibility, app access.

**Example prompts:**

```
Create a permission set called "Invoice Manager" with read and edit
access to Invoice__c and all its fields. Include tab visibility.
```

```
Build a permission set for read-only access to the Contract object.
```

**What you get:**
- Valid `PermissionSet` XML with object, field, and user permissions
- Least-privilege by default — only permissions explicitly requested
- FLS format: `ObjectName.FieldName` (required and formula fields excluded automatically)
- Tab naming: custom object tabs include `__c`, standard tabs use `standard-` prefix
- User permissions for system capabilities (API access, reports, etc.)

> **Note:** Including FLS for required or formula fields causes deployment failure. This skill validates against those automatically.

---

### Validation Rule — Validation Rule Metadata

**Triggers on**: validation rules, "require field when", "prevent save if", formula validation, data quality rules.

**Example prompts:**

```
Add a validation rule on Opportunity that requires Close Date
to be in the future when Stage is Prospecting.
```

```
Create a validation rule on Case that prevents closing a case
unless the Resolution field is filled in.
```

**What you get:**
- Valid `.validationRule-meta.xml`
- Formula wrapped in `<![CDATA[...]]>` to prevent XML parsing issues
- Correct formula functions: `ISPICKVAL()` for picklists, `DATEVALUE()` for DateTime fields
- Clear, user-friendly error messages (max 255 characters)
- Active by default

---

### Report — Salesforce Report Metadata

**Triggers on**: reports, "create a report that shows…", report types (Tabular, Summary, Matrix, Joined), report folders, `.report-meta.xml`.

**Example prompts:**

```
Create a Summary report showing open Opportunities grouped by
Stage, with a bar chart and a total amount column.
```

```
Build a Matrix report showing Cases closed per month, grouped
by Agent across columns and Month across rows.
```

```
Create a Tabular report of all Contacts created in the last 30 days
with Name, Email, Account, and Created Date columns.
```

**What you get:**
- Valid `.report-meta.xml` for the correct report type
- Report type selection guidance (Tabular, Summary, Matrix, Joined)
- Relative date range filters (never hardcoded dates)
- Named following convention: `[Team] — [Purpose] — [Audience]`
- `.reportFolder-meta.xml` generated if the folder doesn't exist
- Deployment commands included

**Report types available:** Tabular (list/export), Summary (grouped with subtotals), Matrix (cross-tab rows × columns), Joined (multi-block comparison)

---

### Dashboard — Salesforce Dashboard Metadata

**Triggers on**: dashboards, KPI metrics, charts, "build a dashboard that shows…", `.dashboard-meta.xml`, dashboard filters, dynamic dashboards.

**Example prompts:**

```
Build a Sales Pipeline dashboard with a headline Metric showing
total pipeline value, a funnel chart by Stage, and a table of
the top 10 open deals.
```

```
Create a Service Operations dashboard with SLA compliance gauge,
cases-by-type donut chart, and open cases table filtered by team.
```

**What you get:**
- Valid `.dashboard-meta.xml` with the correct component types
- Layout guidance: Metric (top row) → Chart (middle) → Table (bottom)
- Running user mode recommendation (Specific User, Dynamic, or Team)
- Up to 3 dashboard filters with clear labels
- `.dashboardFolder-meta.xml` generated if folder doesn't exist
- Deployment commands included

**Component types available:** Metric, Gauge, Bar/Column Chart, Line Chart, Donut/Pie Chart, Funnel Chart, Scatter Chart, Table

---

## Output File Locations

Claude places generated files in the correct SFDX project paths:

```
force-app/main/default/
├── classes/
│   ├── AccountService.cls
│   └── AccountService.cls-meta.xml
├── lwc/
│   └── myComponent/
│       ├── myComponent.html
│       ├── myComponent.js
│       ├── myComponent.js-meta.xml
│       └── myComponent.css
├── flows/
│   └── Opportunity_Closed_Won_Email.flow-meta.xml
├── flexipages/
│   └── Project_Request_Record_Page.flexipage-meta.xml
├── applications/
│   └── Project_Management.app-meta.xml
├── tabs/
│   └── Project_Request__c.tab-meta.xml
├── permissionsets/
│   └── Invoice_Manager.permissionset-meta.xml
├── reports/
│   └── Sales_Reports/
│       └── Open_Opps_by_Stage.report-meta.xml
├── reportFolders/
│   └── Sales_Reports.reportFolder-meta.xml
├── dashboards/
│   └── Sales_Dashboards/
│       └── Pipeline_Overview.dashboard-meta.xml
├── dashboardFolders/
│   └── Sales_Dashboards.dashboardFolder-meta.xml
└── objects/
    └── Project_Request__c/
        ├── Project_Request__c.object-meta.xml
        ├── fields/
        │   └── Status__c.field-meta.xml
        ├── listViews/
        │   └── All_Open_Requests.listView-meta.xml
        └── validationRules/
            └── Require_Description_When_Approved.validationRule-meta.xml
```

---

## Tips for Best Results

**Be specific about requirements:**
```
# Less effective
"Create an Apex class for accounts"

# More effective  
"Create an Apex selector class for Account that queries Id, Name,
OwnerId, BillingCountry, and AnnualRevenue. Add a method that
returns accounts by OwnerId and another that returns accounts
created in the last 30 days. Use WITH USER_MODE."
```

**Mention architecture patterns explicitly:**
```
"Create a Service class (not a controller) for Lead conversion.
Follow Service-Selector-Domain layering."
```

**Ask for tests separately:**
```
"Now write a test class for the LeadConversionService I just created.
Bulk test 200 records. Mock the external callout."
```

**Include deployment context:**
```
"Generate the custom field metadata for Status__c (Picklist) on
Project_Request__c. Values: New, In Review, Approved, Rejected."
```

---

## Team Adoption Checklist

For leads rolling this out to their team:

- [ ] Share this repo and have each developer copy `.claude/` into their SFDX project
- [ ] Confirm everyone is on Claude Code CLI (latest version)
- [ ] Run a 30-minute walkthrough: generate one Apex class, one LWC, one test class together
- [ ] Set a code review standard: Claude-generated code still gets reviewed in PR
- [ ] Encourage developers to be descriptive in their prompts — specificity = better output
- [ ] For Flow generation, ensure MCP tools are connected to the org

---

## Troubleshooting

**Skill not activating?**
Make sure the `.claude/Skills/` folder is in the **root** of the project you opened Claude Code in. Claude Code reads the `.claude` folder from the current working directory.

**Flow generation failing?**
The flow skill requires live MCP tool access to your Salesforce org to fetch metadata. Check your org connection with `sf org display`.

**Deployment errors on custom fields?**
For Roll-Up Summary fields: verify the `summarizedField` uses the format `ChildObject__c.FieldName__c`. Remove any `precision`, `scale`, `required`, or `length` elements.
For Master-Detail fields: remove `required`, `deleteConstraint`, and `lookupFilter` elements — these are not valid for Master-Detail.

**Test coverage below 75%?**
Ask Claude to run the tests and fix coverage gaps: "Run the test class and fix any methods with less than 75% coverage."

**Custom tab deployment failing?**
The skill enforces a strict element allowlist per tab type. Extra elements like `<sobjectName>`, `<isHidden>`, or `<type>` are forbidden and cause errors. Re-generate the tab using the skill rather than editing the XML by hand.

**Permission set deployment failing?**
Check that you haven't included FLS for required fields or formula fields — these cannot be set via metadata. Remove those `<fieldPermissions>` entries.

**FlexiPage not rendering components?**
Field references must use `Record.{FieldApiName}` format, not `{ObjectName}.{FieldApiName}`. Also confirm all `<identifier>` and region `<name>` values are unique across the entire file.

**Report or Dashboard deploy failing?**
Always deploy the folder metadata (`ReportFolder` / `DashboardFolder`) before or alongside the report/dashboard. Deploying into a non-existent folder fails silently.

---

## What's Inside `.claude/Skills/`

```
.claude/Skills/
├── apex/
│   ├── SKILL.md                    Skill instructions + guardrails
│   ├── assets/                     14 Apex class templates
│   └── references/                 3 real-world Apex examples
├── apex-test/
│   ├── SKILL.md
│   ├── assets/                     Test class + TestDataFactory templates
│   └── references/                 4 testing pattern guides
├── lwc/
│   ├── SKILL.md
│   ├── assets/                     11 LWC component templates
│   └── references/                 16 guides (patterns, accessibility, perf, SLDS)
├── custom-object/
│   └── SKILL.md
├── custom-field/
│   └── SKILL.md
├── list-view/
│   └── SKILL.md
├── flow/
│   └── SKILL.md
├── custom-tab/
│   └── SKILL.md
├── custom-application/
│   └── SKILL.md
├── flexipage/
│   └── SKILL.md
├── permission-set/
│   └── SKILL.md
├── validation-rule/
│   └── SKILL.md
├── report/
│   └── SKILL.md
└── dashboard/
    └── SKILL.md
```

---

## Contributing

To add a new skill or improve an existing one:

1. Create a folder under `.claude/Skills/your-skill-name/`
2. Add a `SKILL.md` with activation triggers, guardrails, and output format
3. Add `assets/` templates and `references/` guides as needed
4. Test by prompting Claude in a project with the updated `.claude/` folder
5. Submit a PR with a before/after example showing the improvement

---

---

## Who Do I Talk To?

**Repo owner / admin:**
- Arpit Vijayvergiya — [arpit.v@techmatrixconsulting.com](mailto:arpit.v@techmatrixconsulting.com)

**Repo Reviwer/Approved:**
-- Saurav Kumar - CTO

**Community & team contacts:**
- For questions on skill usage or prompt examples, reach out to your team lead
- For bugs or improvements, open an issue or submit a PR in this repository
- For Claude Code product questions, visit [claude.ai/code](https://claude.ai/code) or the [Claude Code GitHub](https://github.com/anthropics/claude-code/issues)

---

*Built for Salesforce developers. Claude Code is a product of Anthropic.*
