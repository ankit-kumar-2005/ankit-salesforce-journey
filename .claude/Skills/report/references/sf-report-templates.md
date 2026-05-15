# Salesforce Report Metadata XML — Complete Reference Templates

This reference file contains deployable Salesforce report metadata XML templates for all major report types. All XML is valid for the Salesforce Metadata API and can be used directly in a SFDX project under `force-app/main/default/reports/`.

---

## Section 1: Report Folder Template

### Primary Folder: Sales Reports

File path: `force-app/main/default/reportFolders/Sales_Reports.reportFolder-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ReportFolder xmlns="http://soap.sforce.com/2006/04/metadata">
    <accessType>Shared</accessType>
    <!-- "Shared" makes this folder visible to users based on folderShares rules.
         Options: Hidden | Shared | Public -->
    <description>Central repository for all Sales team operational and pipeline reports.</description>
    <folderShares>
        <!-- Share with the SalesTeam role — view only -->
        <accessLevel>View</accessLevel>
        <sharedTo>SalesTeam</sharedTo>
        <sharedToType>Role</sharedToType>
        <!-- sharedToType options: Role | RoleAndSubordinates | Group | Queue | User | AllInternalUsers | Organization -->
    </folderShares>
    <folderShares>
        <!-- Share with Sales Managers group — edit access -->
        <accessLevel>Edit</accessLevel>
        <sharedTo>Sales_Managers</sharedTo>
        <sharedToType>Group</sharedToType>
    </folderShares>
    <name>Sales Reports</name>
    <publicFolderAccess>ReadOnly</publicFolderAccess>
    <!-- publicFolderAccess controls what users NOT explicitly listed in folderShares can do.
         Options: ReadOnly | ReadWrite -->
</ReportFolder>
```

### Sub-folder: Sales Pipeline Reports (nested inside Sales Reports)

File path: `force-app/main/default/reportFolders/Sales_Reports-Sales_Pipeline_Reports.reportFolder-meta.xml`

> **Note:** In Salesforce Metadata API, sub-folder names use a hyphen-delimited path format:
> `<ParentFolderDeveloperName>-<SubFolderDeveloperName>`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ReportFolder xmlns="http://soap.sforce.com/2006/04/metadata">
    <accessType>Shared</accessType>
    <description>Weekly and monthly pipeline analysis reports for the Sales team.</description>
    <folderShares>
        <accessLevel>View</accessLevel>
        <sharedTo>SalesTeam</sharedTo>
        <sharedToType>Role</sharedToType>
    </folderShares>
    <folderShares>
        <accessLevel>Edit</accessLevel>
        <sharedTo>Sales_Managers</sharedTo>
        <sharedToType>Group</sharedToType>
    </folderShares>
    <name>Sales Pipeline Reports</name>
    <publicFolderAccess>ReadOnly</publicFolderAccess>
</ReportFolder>
```

---

## Section 2: Tabular Report Template

File path: `force-app/main/default/reports/Sales_Reports/All_Open_Opportunities_Export.report-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Full export of all open opportunities across the organization. Use for pipeline data exports and CRM hygiene reviews. Excludes Closed Won and Closed Lost records.</description>
    <format>TABULAR</format>
    <name>All Open Opportunities — Export</name>
    <reportType>Opportunity</reportType>
    <!-- reportType must match the API name of the report type. See Section 11 for common values. -->

    <scope>organization</scope>
    <!-- scope controls the record set.
         Options: mine (My records) | organization (All records) | queue | territory | team -->

    <showDetails>true</showDetails>
    <!-- showDetails=true shows individual rows (as opposed to aggregates only) -->

    <!-- ==================== COLUMNS ==================== -->
    <!-- Columns appear in the order listed here. -->
    <!-- Use the Salesforce field API name as the <field> value. -->

    <columns>
        <field>OPPORTUNITY_NAME</field>
    </columns>
    <columns>
        <field>ACCOUNT_NAME</field>
    </columns>
    <columns>
        <field>STAGE_NAME</field>
    </columns>
    <columns>
        <field>AMOUNT</field>
    </columns>
    <columns>
        <field>CLOSE_DATE</field>
    </columns>
    <columns>
        <field>OWNER</field>
        <!-- OWNER renders the Owner's full name -->
    </columns>
    <columns>
        <field>PROBABILITY</field>
    </columns>
    <columns>
        <field>TYPE</field>
    </columns>

    <!-- ==================== FILTERS ==================== -->
    <filter>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <!-- booleanFilter allows AND/OR/NOT combinations across criteria rows.
             Row numbers correspond to the order of <criteriaItems> below. -->

        <criteriaItems>
            <!-- Filter 1: Stage != Closed Won -->
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Won</value>
        </criteriaItems>

        <criteriaItems>
            <!-- Filter 2: Stage != Closed Lost -->
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Lost</value>
        </criteriaItems>

        <criteriaItems>
            <!-- Filter 3: Close Date within current Fiscal Year -->
            <column>CLOSE_DATE</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>equals</operator>
            <value>THIS_FISCAL_YEAR</value>
            <!-- Common date range values: THIS_WEEK | LAST_WEEK | THIS_MONTH | LAST_MONTH |
                 THIS_QUARTER | LAST_QUARTER | THIS_YEAR | LAST_YEAR |
                 THIS_FISCAL_YEAR | LAST_FISCAL_YEAR | LAST_N_DAYS:90 -->
        </criteriaItems>
    </filter>

    <!-- ==================== ROW LIMIT ==================== -->
    <rowLimit>2000</rowLimit>
    <!-- rowLimit only applies to TABULAR reports. Max value Salesforce allows is 2000. -->

    <currency>USD</currency>
    <division>global</division>
    <reportType>Opportunity</reportType>
</Report>
```

---

## Section 3: Summary Report Template

File path: `force-app/main/default/reports/Sales_Reports-Sales_Pipeline_Reports/Open_Opps_By_Stage_Owner_Weekly_Pipeline.report-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Weekly pipeline report grouping open opportunities by Stage and then by Owner. Shows sum of Amount and average probability at each grouping level. Used in Monday pipeline review meetings.</description>
    <format>SUMMARY</format>
    <name>Open Opportunities by Stage and Owner — Weekly Pipeline</name>
    <reportType>Opportunity</reportType>
    <scope>organization</scope>
    <showDetails>true</showDetails>
    <showGrandTotal>true</showGrandTotal>
    <!-- showGrandTotal adds a Grand Total row at the bottom of the report -->
    <showSubTotals>true</showSubTotals>
    <!-- showSubTotals adds subtotal rows at each grouping level break -->

    <!-- ==================== COLUMNS ==================== -->
    <columns>
        <field>OPPORTUNITY_NAME</field>
    </columns>
    <columns>
        <field>AMOUNT</field>
        <!-- For SUMMARY reports, numeric fields in columns can show subtotals automatically -->
    </columns>
    <columns>
        <field>CLOSE_DATE</field>
    </columns>
    <columns>
        <field>PROBABILITY</field>
    </columns>
    <columns>
        <field>AGE</field>
        <!-- AGE is a system-calculated field: number of days since the opportunity was created -->
    </columns>

    <!-- ==================== GROUPINGS (Rows) ==================== -->
    <!-- For SUMMARY reports, <groupingsDown> defines the row grouping hierarchy. -->

    <groupingsDown>
        <!-- First grouping: Stage -->
        <dateGranularity>Day</dateGranularity>
        <!-- dateGranularity is required even for non-date fields; use Day as default -->
        <field>STAGE_NAME</field>
        <sortOrder>Asc</sortOrder>
        <!-- sortOrder: Asc | Desc -->
    </groupingsDown>

    <groupingsDown>
        <!-- Second grouping: Owner Name (nested under Stage) -->
        <dateGranularity>Day</dateGranularity>
        <field>OWNER</field>
        <sortOrder>Asc</sortOrder>
    </groupingsDown>

    <!-- ==================== FILTERS ==================== -->
    <filter>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <!-- Close Date = This Quarter -->
            <column>CLOSE_DATE</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>equals</operator>
            <value>THIS_QUARTER</value>
        </criteriaItems>
    </filter>

    <!-- ==================== SUMMARY FORMULA ==================== -->
    <!-- Summary formulas are custom calculations evaluated at a grouping level. -->

    <aggregates>
        <!-- Built-in aggregate: Sum of Amount shown at Stage grouping -->
        <acrossGroupingContext>GRAND_SUMMARY</acrossGroupingContext>
        <calculatedFormula>AMOUNT:SUM</calculatedFormula>
        <datatype>currency</datatype>
        <developerName>AMOUNT_SUM</developerName>
        <downGroupingContext>STAGE_NAME</downGroupingContext>
        <isActive>true</isActive>
        <isCrossBlock>false</isCrossBlock>
        <masterLabel>Sum of Amount</masterLabel>
        <reportType>Opportunity</reportType>
        <scale>2</scale>
    </aggregates>

    <aggregates>
        <!-- Custom summary formula: Average Probability displayed at Stage level -->
        <acrossGroupingContext>GRAND_SUMMARY</acrossGroupingContext>
        <calculatedFormula>PROBABILITY:AVG</calculatedFormula>
        <!-- Formula syntax: FIELDAPINAME:FUNCTION
             Functions: SUM | AVG | MAX | MIN | COUNT | COUNT_DISTINCT -->
        <datatype>percent</datatype>
        <developerName>AVG_PROBABILITY</developerName>
        <downGroupingContext>STAGE_NAME</downGroupingContext>
        <!-- downGroupingContext: the grouping level where this formula appears.
             Use GRAND_SUMMARY to show at all levels, or a field API name for a specific level. -->
        <isActive>true</isActive>
        <isCrossBlock>false</isCrossBlock>
        <masterLabel>Average Probability</masterLabel>
        <reportType>Opportunity</reportType>
        <scale>1</scale>
    </aggregates>

    <!-- ==================== CHART ==================== -->
    <chart>
        <backgroundColor1>#FFFFFF</backgroundColor1>
        <backgroundColor2>#FFFFFF</backgroundColor2>
        <backgroundFadeDir>Diagonal</backgroundFadeDir>
        <chartType>Bar</chartType>
        <!-- chartType options: Bar | HorizontalBar | Line | Pie | Donut | Funnel | Scatter | etc. -->
        <enableHoverLabels>true</enableHoverLabels>
        <expandOthers>true</expandOthers>

        <groupingColumn>STAGE_NAME</groupingColumn>
        <!-- groupingColumn determines the X-axis (or legend grouping) of the chart -->

        <legendPosition>Bottom</legendPosition>
        <!-- legendPosition: Bottom | OnChart | Right -->

        <showAxisLabels>true</showAxisLabels>
        <showPercentage>false</showPercentage>
        <showTotal>false</showTotal>
        <showValues>true</showValues>
        <size>Medium</size>
        <!-- size: Tiny | Small | Medium | Large | Huge -->

        <summaryAggregate>SUM</summaryAggregate>
        <!-- summaryAggregate: the aggregation function for the Y-axis value -->
        <summaryColumn>AMOUNT</summaryColumn>
        <!-- summaryColumn: the field whose aggregate is plotted on the Y-axis -->

        <textColor>#000000</textColor>
        <textSize>12</textSize>
        <title>Pipeline Amount by Stage — This Quarter</title>
    </chart>

    <currency>USD</currency>
</Report>
```

---

## Section 4: Matrix Report Template

File path: `force-app/main/default/reports/Sales_Reports-Sales_Pipeline_Reports/Revenue_By_Stage_Close_Month_MTD.report-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Matrix showing total opportunity revenue broken down by Stage (rows) and Close Month (columns) for the current calendar year. Used in monthly revenue reviews and board reporting.</description>
    <format>MATRIX</format>
    <name>Revenue by Stage and Close Month — MTD</name>
    <reportType>Opportunity</reportType>
    <scope>organization</scope>
    <showDetails>false</showDetails>
    <!-- MATRIX reports typically hide row-level details and show only aggregates -->
    <showGrandTotal>true</showGrandTotal>
    <showSubTotals>true</showSubTotals>

    <!-- ==================== GROUPINGS DOWN (Rows) ==================== -->
    <groupingsDown>
        <dateGranularity>Day</dateGranularity>
        <field>STAGE_NAME</field>
        <sortOrder>Asc</sortOrder>
    </groupingsDown>

    <!-- ==================== GROUPINGS ACROSS (Columns) ==================== -->
    <!-- In a MATRIX report, <groupingsAcross> defines the column headers. -->
    <groupingsAcross>
        <dateGranularity>Month</dateGranularity>
        <!-- dateGranularity for date fields controls column bucketing.
             Options: Day | Week | Month | Quarter | Year | FiscalQuarter | FiscalYear -->
        <field>CLOSE_DATE</field>
        <sortOrder>Asc</sortOrder>
    </groupingsAcross>

    <!-- ==================== AGGREGATE COLUMNS ==================== -->
    <!-- In a MATRIX report, <aggregates> defines the values inside each cell. -->
    <aggregates>
        <acrossGroupingContext>CLOSE_DATE</acrossGroupingContext>
        <calculatedFormula>AMOUNT:SUM</calculatedFormula>
        <datatype>currency</datatype>
        <developerName>AMOUNT_SUM</developerName>
        <downGroupingContext>STAGE_NAME</downGroupingContext>
        <isActive>true</isActive>
        <isCrossBlock>false</isCrossBlock>
        <masterLabel>Sum of Amount</masterLabel>
        <reportType>Opportunity</reportType>
        <scale>2</scale>
    </aggregates>

    <!-- ==================== FILTER ==================== -->
    <filter>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <column>CLOSE_DATE</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>equals</operator>
            <value>THIS_YEAR</value>
        </criteriaItems>
    </filter>

    <currency>USD</currency>
</Report>
```

---

## Section 5: Joined Report Template

File path: `force-app/main/default/reports/Sales_Reports/Accounts_With_Without_Open_Opportunities.report-meta.xml`

> **Important:** Joined Reports have significant XML complexity. Each block is a self-contained sub-report with its own columns, filters, and report type. The `<id>` on each `<block>` must be unique within the report.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Joined report combining all Accounts with their open Opportunities. Block 1 shows all accounts; Block 2 shows open opportunities linked to those accounts. Useful for identifying accounts with no active pipeline.</description>
    <format>JOINED</format>
    <name>Accounts With and Without Open Opportunities</name>
    <reportType>AccountList</reportType>
    <!-- For JOINED reports, the top-level <reportType> is the primary block's report type -->
    <scope>organization</scope>
    <showDetails>true</showDetails>

    <!-- ==================== BLOCK 1: ALL ACCOUNTS ==================== -->
    <blocks>
        <blockInfo>
            <aggregateReferences>
                <!-- aggregateReferences defines which aggregates from this block appear
                     in the joined report summary row -->
                <aggregate>RowCount</aggregate>
            </aggregateReferences>
            <blockId>B1</blockId>
            <!-- blockId must be unique. Referenced in <blockInfo> of other blocks
                 and in <columns> via <reverseColumnLookupMap> if cross-block formulas are used -->
            <joinTable>a</joinTable>
            <!-- joinTable is an internal alias used in formula references.
                 Convention: a, b, c... matching block order -->
        </blockInfo>

        <columns>
            <field>ACCOUNT_NAME</field>
        </columns>
        <columns>
            <field>INDUSTRY</field>
        </columns>
        <columns>
            <field>ANNUAL_REVENUE</field>
        </columns>
        <columns>
            <field>OWNER</field>
        </columns>

        <!-- No filter on Block 1 — we want all accounts -->
        <format>TABULAR</format>
        <name>All Accounts</name>
        <reportType>AccountList</reportType>
        <scope>organization</scope>
        <showDetails>true</showDetails>
    </blocks>

    <!-- ==================== BLOCK 2: OPEN OPPORTUNITIES ==================== -->
    <blocks>
        <blockInfo>
            <aggregateReferences>
                <aggregate>RowCount</aggregate>
            </aggregateReferences>
            <blockId>B2</blockId>
            <joinTable>b</joinTable>
        </blockInfo>

        <columns>
            <field>OPPORTUNITY_NAME</field>
        </columns>
        <columns>
            <field>STAGE_NAME</field>
        </columns>
        <columns>
            <field>AMOUNT</field>
        </columns>
        <columns>
            <field>CLOSE_DATE</field>
        </columns>

        <filter>
            <booleanFilter>1 AND 2</booleanFilter>
            <criteriaItems>
                <column>STAGE_NAME</column>
                <columnToColumn>false</columnToColumn>
                <isNull>false</isNull>
                <operator>notEqual</operator>
                <value>Closed Won</value>
            </criteriaItems>
            <criteriaItems>
                <column>STAGE_NAME</column>
                <columnToColumn>false</columnToColumn>
                <isNull>false</isNull>
                <operator>notEqual</operator>
                <value>Closed Lost</value>
            </criteriaItems>
        </filter>

        <format>TABULAR</format>
        <name>Open Opportunities</name>
        <reportType>Opportunity</reportType>
        <!-- Each block can have its own reportType -->
        <scope>organization</scope>
        <showDetails>true</showDetails>
    </blocks>

    <!-- ==================== JOINED REPORT GROUPINGS ==================== -->
    <!-- Optional: add a top-level grouping that applies across all blocks -->
    <groupingsDown>
        <dateGranularity>Day</dateGranularity>
        <field>ACCOUNT_NAME</field>
        <sortOrder>Asc</sortOrder>
    </groupingsDown>

    <currency>USD</currency>
</Report>
```

---

## Section 6: Report with Cross-Filter

File path: `force-app/main/default/reports/Sales_Reports/Accounts_Without_Cases_Last_90_Days.report-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Identifies accounts that have had NO support cases opened in the last 90 days. Used by the Customer Success team to proactively reach out to potentially neglected accounts before churn risk increases.</description>
    <format>SUMMARY</format>
    <name>Accounts Without Cases in Last 90 Days — Neglected Accounts</name>
    <reportType>AccountList</reportType>
    <scope>organization</scope>
    <showDetails>true</showDetails>
    <showGrandTotal>true</showGrandTotal>
    <showSubTotals>true</showSubTotals>

    <!-- ==================== COLUMNS ==================== -->
    <columns>
        <field>ACCOUNT_NAME</field>
    </columns>
    <columns>
        <field>TYPE</field>
    </columns>
    <columns>
        <field>LAST_ACTIVITY</field>
        <!-- LAST_ACTIVITY is the Last Activity Date field on Account -->
    </columns>
    <columns>
        <field>ANNUAL_REVENUE</field>
    </columns>

    <!-- ==================== GROUPING ==================== -->
    <groupingsDown>
        <dateGranularity>Day</dateGranularity>
        <field>OWNER</field>
        <sortOrder>Asc</sortOrder>
    </groupingsDown>

    <!-- ==================== CROSS-FILTER ==================== -->
    <!-- Cross-filters let you filter a report based on the presence or absence
         of related records. This replaces needing a complex subquery. -->

    <crossFilters>
        <criteriaItems>
            <!-- Sub-filter: only apply the cross-filter to Cases created in last 90 days -->
            <column>CREATED_DATE</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>equals</operator>
            <value>LAST_N_DAYS:90</value>
        </criteriaItems>
        <operation>without</operation>
        <!-- operation: "with" = accounts THAT HAVE cases matching sub-filter
                        "without" = accounts that DO NOT HAVE cases matching sub-filter -->
        <primaryTableColumn>ACCOUNT_ID</primaryTableColumn>
        <!-- primaryTableColumn: the relationship field on the child object that links to Account -->
        <relatedTable>Case</relatedTable>
        <!-- relatedTable: API name of the related object being cross-filtered -->
        <relatedTableJoinColumn>ACCOUNT_ID</relatedTableJoinColumn>
        <!-- relatedTableJoinColumn: the foreign key on the related object -->
    </crossFilters>

    <!-- ==================== STANDARD FILTER ==================== -->
    <filter>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <!-- Only include active/customer accounts -->
            <column>TYPE</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>equals</operator>
            <value>Customer</value>
        </criteriaItems>
    </filter>

    <currency>USD</currency>
</Report>
```

---

## Section 7: Report with Bucket Field

File path: `force-app/main/default/reports/Sales_Reports-Sales_Pipeline_Reports/Opps_By_Revenue_Tier_Pipeline_Analysis.report-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Groups open pipeline opportunities into revenue tiers (Small Deal, Mid-Market, Enterprise) based on opportunity Amount. Helps sales leadership understand deal size distribution and focus coaching efforts.</description>
    <format>SUMMARY</format>
    <name>Opportunities by Revenue Tier — Pipeline Analysis</name>
    <reportType>Opportunity</reportType>
    <scope>organization</scope>
    <showDetails>true</showDetails>
    <showGrandTotal>true</showGrandTotal>
    <showSubTotals>true</showSubTotals>

    <!-- ==================== BUCKET FIELD ==================== -->
    <!-- Bucket fields are virtual groupings defined at report-design time.
         They do not exist as actual Salesforce fields; they are computed by the report engine. -->

    <buckets>
        <bucketType>number</bucketType>
        <!-- bucketType: number | text | picklist -->

        <developerName>RevenueTier</developerName>
        <!-- developerName is used to reference this bucket in <groupingsDown> and <columns> -->

        <masterLabel>Revenue Tier</masterLabel>
        <!-- masterLabel is the display name shown in the report -->

        <nullTreatment>z</nullTreatment>
        <!-- nullTreatment for number buckets:
             "z" = treat null as zero (includes in lowest bucket)
             "n" = treat null as its own bucket labeled "Other" -->

        <sourceColumnName>AMOUNT</sourceColumnName>
        <!-- sourceColumnName: the field API name this bucket is based on -->

        <values>
            <!-- Bucket 1: Small Deal — Amount from 0 to 9,999 -->
            <sourceValues>
                <operator>lessThan</operator>
                <value>10000</value>
            </sourceValues>
            <value>Small Deal</value>
            <!-- The <value> tag here is the bucket label displayed in the report -->
        </values>

        <values>
            <!-- Bucket 2: Mid-Market — Amount from 10,000 to 99,999 -->
            <sourceValues>
                <from>10000</from>
                <to>99999</to>
            </sourceValues>
            <value>Mid-Market</value>
        </values>

        <values>
            <!-- Bucket 3: Enterprise — Amount 100,000 and above -->
            <sourceValues>
                <operator>greaterOrEqual</operator>
                <value>100000</value>
            </sourceValues>
            <value>Enterprise</value>
        </values>
    </buckets>

    <!-- ==================== COLUMNS ==================== -->
    <columns>
        <field>OPPORTUNITY_NAME</field>
    </columns>
    <columns>
        <field>AMOUNT</field>
    </columns>
    <columns>
        <field>STAGE_NAME</field>
    </columns>
    <columns>
        <field>CLOSE_DATE</field>
    </columns>
    <columns>
        <field>OWNER</field>
    </columns>

    <!-- ==================== GROUPING BY BUCKET FIELD ==================== -->
    <groupingsDown>
        <dateGranularity>Day</dateGranularity>
        <field>BucketField_RevenueTier</field>
        <!-- Bucket fields are referenced with a "BucketField_" prefix + developerName -->
        <sortOrder>Asc</sortOrder>
    </groupingsDown>

    <!-- ==================== FILTER ==================== -->
    <filter>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Lost</value>
        </criteriaItems>
    </filter>

    <currency>USD</currency>
</Report>
```

---

## Section 8: Report with Row-Level Formula

File path: `force-app/main/default/reports/Sales_Reports/Opportunities_Days_To_Close_vs_Age.report-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Shows open opportunities with a custom row-level formula calculating the number of days remaining until Close Date. Helps reps identify deals at risk of slipping past their stated close date.</description>
    <format>SUMMARY</format>
    <name>Opportunities — Days to Close vs Age</name>
    <reportType>Opportunity</reportType>
    <scope>organization</scope>
    <showDetails>true</showDetails>
    <showGrandTotal>true</showGrandTotal>
    <showSubTotals>true</showSubTotals>

    <!-- ==================== COLUMNS ==================== -->
    <columns>
        <field>OPPORTUNITY_NAME</field>
    </columns>
    <columns>
        <field>STAGE_NAME</field>
    </columns>
    <columns>
        <field>CLOSE_DATE</field>
    </columns>
    <columns>
        <field>AGE</field>
    </columns>
    <columns>
        <field>AMOUNT</field>
    </columns>
    <columns>
        <field>OWNER</field>
    </columns>

    <!-- ==================== ROW-LEVEL FORMULA ==================== -->
    <!-- Row-level formulas appear as a computed column on every row.
         They are evaluated per record (not per grouping like summary formulas).
         formulaType must be "ROWS" to indicate this is a row-level formula. -->

    <formulaFields>
        <dataType>Number</dataType>
        <!-- dataType: Number | Currency | Percent | Text | Date | DateTime -->

        <formula>CLOSE_DATE - TODAY()</formula>
        <!-- Formula uses Salesforce report formula syntax.
             CLOSE_DATE and TODAY() are standard functions/fields.
             Result is the number of days from today until the Close Date.
             Negative values mean the close date has already passed. -->

        <formulaType>ROWS</formulaType>
        <!-- formulaType:
             ROWS     = row-level formula (one value per record row)
             SUMMARY  = summary formula (one value per grouping level) -->

        <label>Days Remaining to Close</label>
        <!-- label is the column header shown in the report -->

        <scale>0</scale>
        <!-- scale: decimal places shown in the output. 0 = whole numbers -->
    </formulaFields>

    <!-- ==================== GROUPING ==================== -->
    <groupingsDown>
        <dateGranularity>Day</dateGranularity>
        <field>OWNER</field>
        <sortOrder>Asc</sortOrder>
    </groupingsDown>

    <!-- ==================== FILTER ==================== -->
    <filter>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <column>STAGE_NAME</column>
            <columnToColumn>false</columnToColumn>
            <isNull>false</isNull>
            <operator>notEqual</operator>
            <value>Closed Lost</value>
        </criteriaItems>
    </filter>

    <currency>USD</currency>
</Report>
```

---

## Section 9: Naming Convention Cheat Sheet

| Team | Example Report Names | Folder Path |
|---|---|---|
| Sales | `Open Opportunities by Stage — Weekly Pipeline`, `Closed Won Revenue by Rep — MTD`, `Accounts Without Activity in 30 Days` | `Sales_Reports/Sales_Pipeline_Reports` |
| Service / Support | `Open Cases by Priority and Queue`, `Average Case Resolution Time — This Month`, `Cases Escalated Without Resolution in 72h` | `Service_Reports/Case_Queue_Reports` |
| Finance | `Monthly Recurring Revenue by Account`, `Invoiced vs Collected — This Quarter`, `Overdue Renewals — Next 60 Days` | `Finance_Reports/Revenue_Reports` |
| HR / People Ops | `Headcount by Department and Location`, `Open Requisitions by Hiring Manager`, `Employee Onboarding Status — Active` | `HR_Reports/Headcount_Reports` |
| Operations | `Contract Renewals Due in Next 90 Days`, `Vendor Activity Log — Last Quarter`, `SLA Compliance by Region — MTD` | `Operations_Reports/Contract_Reports` |
| Marketing | `Campaign ROI by Channel — YTD`, `Leads by Source and Stage — This Month`, `MQL to SQL Conversion Rate by Campaign` | `Marketing_Reports/Campaign_Reports` |

**Naming conventions to follow:**
- Use plain English with em-dashes (`—`) to separate the topic from the time scope
- Avoid abbreviations like `Opps` or `Accts` in folder/report names (use full words)
- Time scope goes at the end: `— MTD`, `— This Quarter`, `— Last 90 Days`, `— YTD`
- Developer names (API names) should use underscores and no special characters

---

## Section 10: Folder Hierarchy Example

Recommended folder structure for a mid-sized Salesforce org. Each team gets a top-level folder with 2–3 sub-folders. An `_Archive` folder at root holds deprecated reports.

```
reports/
├── Sales_Reports/
│   ├── Sales_Pipeline_Reports/
│   │   ├── Open_Opps_By_Stage_Owner_Weekly_Pipeline.report-meta.xml
│   │   └── Revenue_By_Stage_Close_Month_MTD.report-meta.xml
│   ├── Sales_Activity_Reports/
│   │   ├── Activity_Log_By_Rep_Last_30_Days.report-meta.xml
│   │   └── Calls_Meetings_By_Account_This_Week.report-meta.xml
│   └── Sales_Account_Reports/
│       ├── Accounts_Without_Activity_30_Days.report-meta.xml
│       └── Accounts_With_Without_Open_Opportunities.report-meta.xml
│
├── Service_Reports/
│   ├── Case_Queue_Reports/
│   │   ├── Open_Cases_By_Priority_And_Queue.report-meta.xml
│   │   └── Overdue_Cases_Unresolved_72h.report-meta.xml
│   ├── SLA_Reports/
│   │   ├── SLA_Compliance_By_Region_MTD.report-meta.xml
│   │   └── Avg_Resolution_Time_By_Case_Type.report-meta.xml
│   └── CSAT_Reports/
│       └── CSAT_Score_By_Agent_This_Quarter.report-meta.xml
│
├── Finance_Reports/
│   ├── Revenue_Reports/
│   │   ├── MRR_By_Account_This_Month.report-meta.xml
│   │   └── Invoiced_Vs_Collected_This_Quarter.report-meta.xml
│   ├── Renewal_Reports/
│   │   └── Contract_Renewals_Due_Next_90_Days.report-meta.xml
│   └── Forecast_Reports/
│       └── Opportunity_Forecast_By_Owner_This_Quarter.report-meta.xml
│
├── Marketing_Reports/
│   ├── Campaign_Reports/
│   │   ├── Campaign_ROI_By_Channel_YTD.report-meta.xml
│   │   └── MQL_To_SQL_Conversion_By_Campaign.report-meta.xml
│   └── Lead_Reports/
│       ├── Leads_By_Source_And_Stage_This_Month.report-meta.xml
│       └── Uncontacted_Leads_Over_7_Days_Old.report-meta.xml
│
└── _Archive/
    ├── (Deprecated reports moved here before deletion)
    └── (Suffix archived report names with _DEPRECATED_YYYY-MM)
```

**Corresponding `reportFolders/` developer name convention:**

| Display Name | Developer Name (folder-meta.xml filename) |
|---|---|
| Sales Reports | `Sales_Reports` |
| Sales Pipeline Reports | `Sales_Reports-Sales_Pipeline_Reports` |
| Service Reports | `Service_Reports` |
| Case Queue Reports | `Service_Reports-Case_Queue_Reports` |
| Finance Reports | `Finance_Reports` |
| Revenue Reports | `Finance_Reports-Revenue_Reports` |

---

## Section 11: Common Report Type API Names

These API names are used in the `<reportType>` element of every `.report-meta.xml` file.

| Object / Report Name | `<reportType>` API Name | Notes |
|---|---|---|
| Opportunities | `Opportunity` | Standard opportunity report |
| Opportunities with Products | `OpportunityLineItem` | Includes line-item level columns |
| Cases | `Case` | Standard case report |
| Contacts & Accounts | `AccountContact` | Contacts joined with their parent account |
| Activities (Tasks & Events) | `Activity` | Combined tasks and calendar events |
| Leads | `Lead` | Standard lead report |
| Campaigns | `Campaign` | Campaign header-level data |
| Campaigns with Members | `CampaignMember` | Campaign + each member's response status |
| Users | `User` | Internal users — often used for adoption reports |
| Knowledge Articles | `KnowledgeArticleVersion` | Requires Knowledge to be enabled |
| Accounts | `AccountList` | Standard account report |
| Contracts | `Contract` | Standard contract report |
| Products | `Product2` | Product catalog report |
| Assets | `Asset` | Installed assets per account |
| Forecasts | `ForecastingItem` | Requires Collaborative Forecasting |

> **Custom Report Types:** If your org has custom report types created in Setup > Report Types, use their **API Name** exactly as it appears in the `Report Type Name` field in Setup. Custom report type API names are case-sensitive and typically look like `My_Custom_Report_Type` or `AccountsWithCustomObject__c`.

> **Finding an unknown report type API name:** In Setup, go to **Reports & Dashboards > Report Types**, find the report type, and copy the value in the **Report Type Name** column. Alternatively, query it via SOQL: `SELECT DeveloperName FROM ReportType WHERE IsActive = true`.

---

*Last updated: 2026-05-15 | Compatible with Salesforce API version 59.0+*