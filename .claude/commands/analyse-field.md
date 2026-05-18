# Field Usage Analysis

Analyse the end-to-end usage of an existing Salesforce field across the org.
Run with: `/analyse-field <Object>.<FieldApiName>`
Example: `/analyse-field Account.Customer_Tier__c`

Parse the object and field name from the argument, then work through every section below in order.
For each section, use `sf` CLI commands, SOQL via `sf data query`, and direct metadata file inspection.
Summarise findings at the end with a risk rating and a recommended action.

---

## 1. Field Metadata

Pull the field definition and record its properties.

```bash
sf sobject describe --sobject <Object> --target-org <default-org> | jq '.fields[] | select(.name == "<FieldApiName>")'
```

Check and record:
- [ ] **Label** and **API Name** match expectations (no typos, follows naming conventions)
- [ ] **Data type** — Text, Number, Picklist, Lookup, Formula, etc.
- [ ] **Length / precision / scale** — appropriate for actual data stored
- [ ] **Required** — is the field truly required in practice or is the constraint bypassed via API/automation?
- [ ] **Default value** — is it set? Does it make sense given current data?
- [ ] **Help text** — present and accurate?
- [ ] **Description** — present and accurate?
- [ ] **Formula** (if applicable) — formula text; note any cross-object references
- [ ] **Rollup summary** (if applicable) — source object, aggregate function, filter criteria
- [ ] **External ID** — flag if true; affects upsert behaviour and indexing
- [ ] **Unique** — flag if true; impacts bulk loads
- [ ] **Indexed** — custom fields are only indexed if marked External ID or system-indexed

---

## 2. Data Profile

Run SOQL to understand what data actually lives in this field.

```bash
# Null vs populated
sf data query --query "SELECT COUNT() FROM <Object> WHERE <FieldApiName> = null" --target-org <default-org>
sf data query --query "SELECT COUNT() FROM <Object> WHERE <FieldApiName> != null" --target-org <default-org>

# For picklist fields — value distribution
sf data query --query "SELECT <FieldApiName>, COUNT(Id) cnt FROM <Object> GROUP BY <FieldApiName> ORDER BY cnt DESC LIMIT 20" --target-org <default-org>

# Most recent write (approximate freshness)
sf data query --query "SELECT <FieldApiName>, LastModifiedDate FROM <Object> WHERE <FieldApiName> != null ORDER BY LastModifiedDate DESC LIMIT 1" --target-org <default-org>
```

Check and record:
- [ ] **Null rate** — high null rate (>80%) on a required or important field is a data quality signal
- [ ] **Value distribution** — for picklists, flag values with zero or near-zero use (stale values)
- [ ] **Data freshness** — when was this field last written? Not updated in >12 months may mean abandoned
- [ ] **Volume** — total record count; relevant for index and query performance

---

## 3. Apex References

Search all Apex classes and triggers for direct and dynamic references.

```bash
# Direct field references
grep -rn "<FieldApiName>" force-app/ --include="*.cls" --include="*.trigger"

# Dynamic SOQL references (string-based)
grep -rn "\"<FieldApiName>\"\|'<FieldApiName>'" force-app/ --include="*.cls" --include="*.trigger"

# Schema describe references
grep -rn "fields\.<FieldApiName>" force-app/ --include="*.cls" --include="*.trigger"
```

For each match, record:
- [ ] **File path and line number**
- [ ] **Context** — SOQL SELECT, SOQL WHERE, DML assignment, Schema describe, dynamic SOQL string
- [ ] **Read or write** — is the field being read, written, or both?
- [ ] **Class purpose** — trigger handler, service, batch, REST resource, test class
- [ ] **FLS enforcement** — does surrounding SOQL use `WITH USER_MODE` / `WITH SECURITY_ENFORCED`, or DML use `Security.stripInaccessible`? Flag gaps.
- [ ] **Test coverage** — are Apex paths that use this field covered by test classes?

---

## 4. LWC & Aura References

Search component files for field references.

```bash
# LWC JS, HTML, and meta files
grep -rn "<FieldApiName>" force-app/ --include="*.js" --include="*.html" --include="*.js-meta.xml"

# Aura components
grep -rn "<FieldApiName>" force-app/ --include="*.cmp" --include="*.app" --include="*.evt"

# Wire adapter usage
grep -rn "getRecord\|getFieldValue\|FIELDS" force-app/ --include="*.js" | grep -i "<FieldApiName>"
```

For each match, record:
- [ ] **Component name and file**
- [ ] **Usage type** — displayed in template, in wire `fields` array, sent in Apex callout, used in record-edit form
- [ ] **User-facing** — visible to end users? Does the label match the field label in Setup?
- [ ] **Edit or read-only** — is the field editable from this component?

---

## 5. Flow References

Search Flow metadata for field references.

```bash
grep -rn "<FieldApiName>" force-app/ --include="*.flow-meta.xml"
```

For each match, record:
- [ ] **Flow name and type** — Record-Triggered, Screen, Scheduled, Autolaunched
- [ ] **Element type** — Get Records filter, Assignment, Update Records, Decision condition, Loop
- [ ] **Read or write** — filter/condition (read) vs Assignment/Update (write)
- [ ] **Active or inactive** — check `<status>Active</status>` in the metadata
- [ ] **Fault path** — if used in a Get/Update/Create element, is there a fault connector?

---

## 6. Validation Rule References

```bash
grep -rn "<FieldApiName>" force-app/main/default/objects/<Object>/validationRules/*.validationRule-meta.xml
```

For each match, record:
- [ ] **Rule name** and **active/inactive** status
- [ ] **Role of field** — field being validated, or a conditional reference?
- [ ] **Error message** — human-readable and accurate?
- [ ] **Impact of field deletion** — removing this field would break this rule; flag as dependency

---

## 7. Workflow Rules & Process Builder (Legacy Automation)

```bash
grep -rn "<FieldApiName>" force-app/ --include="*.workflow-meta.xml"
```

For each match, record:
- [ ] **Rule or action name**
- [ ] **Type** — criteria field, field update action, outbound message payload, email template field
- [ ] **Active or inactive**
- [ ] **Migration status** — flag any active Workflow Rules or Process Builder as candidates for Flow migration

---

## 8. Page Layouts

```bash
grep -rn "<FieldApiName>" force-app/main/default/layouts/*.layout-meta.xml
```

For each match, record:
- [ ] **Layout name(s)**
- [ ] **Section and position**
- [ ] **Required on layout** vs required at field level (mismatch = confusing UX)
- [ ] **Read-only on layout** — important for fields that should only be written by automation
- [ ] **Visible on mobile** (`MobileLayoutSection`)

---

## 9. Reports & Dashboards

```bash
# Search report metadata
grep -rn "<FieldApiName>" force-app/ --include="*.report-meta.xml"

# Tooling API query
sf data query --query "SELECT Id, Name, FolderName FROM Report WHERE Description LIKE '%<FieldApiName>%'" --target-org <default-org> --use-tooling-api
```

For each match, record:
- [ ] **Report name** and **folder**
- [ ] **Usage** — column, filter, grouping, formula
- [ ] **Scheduled** — is this report emailed or subscribed to?
- [ ] **Dashboard dependency** — does any dashboard source from a report using this field?

---

## 10. Permission Sets & Profiles

```bash
grep -rn "<FieldApiName>" force-app/main/default/permissionsets/*.permissionset-meta.xml
grep -rn "<FieldApiName>" force-app/main/default/profiles/*.profile-meta.xml
```

For each match, record:
- [ ] **Permission set or profile name**
- [ ] **Read access granted** — `readable: true`
- [ ] **Edit access granted** — `editable: true`
- [ ] **Gaps** — any persona that writes via automation but lacks FLS edit access?
- [ ] **Over-permissioned** — anyone with edit access who shouldn't have it?

---

## 11. Integration & API Usage

```bash
# External data sources / objects
grep -rn "<FieldApiName>" force-app/ --include="*.externalDataSource-meta.xml" --include="*.externalObject-meta.xml"

# Search for field in JSON/XML payload construction in Apex (see Section 3)
grep -rn "<FieldApiName>" force-app/ --include="*.cls" | grep -i "json\|payload\|request\|body"
```

Check and record:
- [ ] **Used in inbound integrations** — field populated via API from external system?
- [ ] **Used in outbound integrations** — field sent to external system in callout payload?
- [ ] **External ID** — if yes, used for upsert matching? Which integration uses it?
- [ ] **ETL / data load** — is this field in any documented data migration or bulk load spec?

---

## 12. Dependent Picklist Relationships

```bash
# Fields this field controls
sf sobject describe --sobject <Object> --target-org <default-org> | jq '.fields[] | select(.controllerName == "<FieldApiName>") | .name'

# Whether this field is itself dependent
sf sobject describe --sobject <Object> --target-org <default-org> | jq '.fields[] | select(.name == "<FieldApiName>") | {dependentPicklist, controllerName}'
```

Check and record:
- [ ] **Controls dependent picklists** — list all; changing values in this field breaks their filtering
- [ ] **Is itself dependent** — removing the controlling field breaks this field
- [ ] **Record type value sets** — does the picklist have different values per record type?

---

## 13. History & Tracking

```bash
sf sobject describe --sobject <Object> --target-org <default-org> | jq '.fields[] | select(.name == "<FieldApiName>") | {trackHistory, trackFeedHistory, trackTrending}'
```

Check and record:
- [ ] **Field History Tracking enabled** — disabling loses future audit trail
- [ ] **Feed Tracking enabled** — changes appear in Chatter feed
- [ ] **Trend Reporting enabled** — used in Einstein Analytics trending datasets

---

## Summary & Risk Rating

After completing all sections, produce a structured summary:

### Field Identity
| Property | Value |
|----------|-------|
| Object | |
| API Name | |
| Label | |
| Type | |
| Null Rate | |
| Last Written (est.) | |

### Usage Heatmap
| Area | References Found | Read | Write | Risk if Removed |
|------|-----------------|------|-------|----------------|
| Apex | | | | |
| LWC / Aura | | | | |
| Flows | | | | |
| Validation Rules | | | | |
| Workflow / Process Builder | | | | |
| Page Layouts | | | | |
| Reports / Dashboards | | | | |
| Integrations | | | | |
| Permission Sets | | | | |

### Risk Rating
| Rating | Criteria |
|--------|----------|
| 🔴 **Critical** | Used in active automation, integration payload, or external ID upsert; removal causes data loss or broken processes |
| 🟠 **High** | Referenced in Apex, active Flow, or validation rule; removal requires code changes and regression testing |
| 🟡 **Medium** | Appears on page layouts or reports only; removal safe with layout/report updates |
| 🟢 **Low** | No active references found; high null rate; candidate for deprecation |

### Recommended Action
Choose one and provide specific next steps:
- **Keep & Document** — field is critical; add/fix Description and Help Text; ensure FLS is correct across all personas
- **Refactor** — field is used but incorrectly typed, labelled, or over-permissioned; create a migration plan
- **Deprecate** — field is unused or redundant; follow the deprecation checklist below
- **Investigate Further** — ambiguous usage found in dynamic SOQL or external systems; need stakeholder input before deciding

---

## Deprecation Checklist (run only if Recommended Action = Deprecate)

- [ ] Export / archive non-null values to a backup object or external store
- [ ] Set field to **read-only** on all page layouts (prevents new data entry while keeping history visible)
- [ ] Remove from all **active Flows** — deactivate or update each flow version
- [ ] Remove from all **Apex** — deploy updated classes with field references removed
- [ ] Remove from all **LWC / Aura** components
- [ ] Remove from all **Validation Rules** (update or deactivate rules)
- [ ] Remove from all **Reports** (update columns and filters)
- [ ] Communicate change to **integration owners** if field was in any API payload
- [ ] Run full **regression test** in sandbox
- [ ] Deploy to production in a **change window**
- [ ] Delete field in Setup — confirm deletion warning lists zero dependencies
