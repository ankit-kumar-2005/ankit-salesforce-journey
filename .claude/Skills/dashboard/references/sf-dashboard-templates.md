# Salesforce Dashboard Metadata XML Templates — Complete Reference

All XML is valid and deployable against the Salesforce Metadata API (API v59.0+).
Every block uses `<?xml version="1.0" encoding="UTF-8"?>` and the standard metadata namespace.

---

## Section 1: Dashboard Folder Templates

Dashboard folders control who can view and edit dashboards.
A sub-folder developer name is formed by concatenating the parent folder developer name, a hyphen, and the child folder developer name.

---

### 1a. Parent Folder — `Sales_Dashboards`

**File path:** `force-app/main/default/dashboards/Sales_Dashboards.dashboardFolder-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<DashboardFolder xmlns="http://soap.sforce.com/2006/04/metadata">
    <!-- accessType options: Hidden | Shared | Public -->
    <accessType>Shared</accessType>
    <name>Sales Dashboards</name>
    <!-- folderShares control role-based and user-based access -->
    <folderShares>
        <!-- Share 1: Sales Team role gets View access -->
        <folderShare>
            <!-- accessLevel options: View | Edit | Manage -->
            <accessLevel>View</accessLevel>
            <!-- sharedTo must match an existing Role developer name -->
            <sharedTo>Sales_Team</sharedTo>
            <!-- sharedToType options: Role | RoleAndSubordinates | Group | User | Organization -->
            <sharedToType>Role</sharedToType>
        </folderShare>
        <!-- Share 2: Sales Managers role gets Edit access -->
        <folderShare>
            <accessLevel>Edit</accessLevel>
            <sharedTo>Sales_Managers</sharedTo>
            <sharedToType>Role</sharedToType>
        </folderShare>
    </folderShares>
</DashboardFolder>
```

---

### 1b. Sub-Folder — `Sales_Executive_Dashboards` under `Sales_Dashboards`

The developer name of a sub-folder is `ParentFolderName-SubFolderName` (hyphen-concatenated).

**File path:** `force-app/main/default/dashboards/Sales_Dashboards-Sales_Executive_Dashboards.dashboardFolder-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<DashboardFolder xmlns="http://soap.sforce.com/2006/04/metadata">
    <accessType>Shared</accessType>
    <name>Sales Executive Dashboards</name>
    <folderShares>
        <!-- VP of Sales and above — full Manage access -->
        <folderShare>
            <accessLevel>Manage</accessLevel>
            <sharedTo>VP_Sales</sharedTo>
            <sharedToType>Role</sharedToType>
        </folderShare>
        <!-- Sales Managers — View only -->
        <folderShare>
            <accessLevel>View</accessLevel>
            <sharedTo>Sales_Managers</sharedTo>
            <sharedToType>RoleAndSubordinates</sharedToType>
        </folderShare>
    </folderShares>
</DashboardFolder>
```

---

## Section 2: Full Sales Pipeline Dashboard (SpecifiedUser)

`dashboardType>SpecifiedUser` means the dashboard always runs as a single named user,
regardless of who is viewing it. The `<runningUser>` tag holds that user's Salesforce username.

**File path:** `force-app/main/default/dashboards/Sales_Dashboards/Sales_Pipeline_Overview_VP.dashboard-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Dashboard xmlns="http://soap.sforce.com/2006/04/metadata">
    <backgroundEndColor>#FFFFFF</backgroundEndColor>
    <backgroundFadeDirection>Diagonal</backgroundFadeDirection>
    <backgroundStartColor>#FFFFFF</backgroundStartColor>
    <chartTheme>light</chartTheme>
    <colorPalette>default</colorPalette>
    <description>VP-level view of the full open pipeline. Runs as the VP of Sales user so all territory data is visible to every viewer.</description>
    <!-- dashboardType options: SpecifiedUser | LoggedInUser | MyTeamUser -->
    <dashboardType>SpecifiedUser</dashboardType>
    <!-- runningUser: Salesforce username (not the Id) of the user whose data context is used.
         Required when dashboardType = SpecifiedUser. Omit for LoggedInUser / MyTeamUser. -->
    <runningUser>vp.sales@acme.com</runningUser>
    <title>Sales Pipeline Overview — VP View</title>

    <!-- ============================================================
         DASHBOARD FILTERS
         Filters allow viewers to slice dashboard data without
         opening the underlying reports.
         ============================================================ -->
    <dashboardFilters>
        <!-- Filter 1: Date Range on Opportunity Close Date -->
        <dashboardFilter>
            <name>Close Date Range</name>
            <!-- filterOptions define which date ranges are available in the picker -->
            <dashboardFilterOptions>
                <operator>BETWEEN</operator>
                <values>THIS_QUARTER</values>
            </dashboardFilterOptions>
            <dashboardFilterOptions>
                <operator>BETWEEN</operator>
                <values>NEXT_QUARTER</values>
            </dashboardFilterOptions>
            <dashboardFilterOptions>
                <operator>BETWEEN</operator>
                <values>THIS_YEAR</values>
            </dashboardFilterOptions>
        </dashboardFilter>
        <!-- Filter 2: Sales Team (Owner Role) multi-select -->
        <dashboardFilter>
            <name>Sales Team</name>
            <dashboardFilterOptions>
                <operator>EQUALS</operator>
                <values>Inside Sales</values>
            </dashboardFilterOptions>
            <dashboardFilterOptions>
                <operator>EQUALS</operator>
                <values>Enterprise Sales</values>
            </dashboardFilterOptions>
            <dashboardFilterOptions>
                <operator>EQUALS</operator>
                <values>SMB Sales</values>
            </dashboardFilterOptions>
        </dashboardFilter>
    </dashboardFilters>

    <!-- ============================================================
         LAYOUT
         Dashboards use a 3-column grid: leftSection / middleSection / rightSection.
         Each section contains an ordered list of <components>.
         Components in the same row position appear side-by-side.
         ============================================================ -->

    <!-- ---- ROW 1: Three Metric tiles ---- -->
    <leftSection>
        <!-- Metric 1: Total Pipeline Amount -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <!-- componentType options: Metric | Gauge | Chart | Table | SectionHeader -->
            <componentType>Metric</componentType>
            <dashboardFilterColumns>
                <!-- Map this component to Filter 1 (index 0) via the Close Date field -->
                <filter>
                    <criteriaField>CLOSE_DATE</criteriaField>
                    <!-- dashboardFilterId references the position (1-based) of the filter above -->
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
                <filter>
                    <criteriaField>OWNER_ROLE</criteriaField>
                    <dashboardFilterId>2</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <displayUnits>Auto</displayUnits>
            <footer>All open stages</footer>
            <header>Total Pipeline</header>
            <!-- metricLabel overrides the value label shown below the number -->
            <metricLabel>Pipeline Amount</metricLabel>
            <!-- reportName: developer name of the source report (no .report extension) -->
            <reportName>Sales_Reports/Pipeline_Amount_by_Stage_Summary</reportName>
            <!-- reportColumn: API field name of the aggregate being displayed -->
            <reportColumn>AMOUNT</reportColumn>
            <title>Total Pipeline Amount</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Metric 2: Open Opportunities Count -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>CLOSE_DATE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
                <filter>
                    <criteriaField>OWNER_ROLE</criteriaField>
                    <dashboardFilterId>2</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <displayUnits>Integer</displayUnits>
            <footer>Count of open records</footer>
            <header>Open Opportunities</header>
            <metricLabel>Opportunity Count</metricLabel>
            <reportName>Sales_Reports/Open_Opportunities_Count_Summary</reportName>
            <!-- RECORD_COUNT is the built-in aggregate for row count in Summary/Matrix reports -->
            <reportColumn>RECORD_COUNT</reportColumn>
            <title>Open Opportunities Count</title>
        </components>
    </middleSection>

    <rightSection>
        <!-- Metric 3: Average Deal Size -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>CLOSE_DATE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
                <filter>
                    <criteriaField>OWNER_ROLE</criteriaField>
                    <dashboardFilterId>2</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <displayUnits>Auto</displayUnits>
            <footer>Average across all open opps</footer>
            <header>Average Deal Size</header>
            <metricLabel>Avg Amount</metricLabel>
            <reportName>Sales_Reports/Average_Deal_Size_Summary</reportName>
            <!-- AVG_AMOUNT is the custom aggregate alias; the source report must expose it -->
            <reportColumn>AVG_AMOUNT</reportColumn>
            <title>Average Deal Size</title>
        </components>
    </rightSection>

    <!-- ---- ROW 2: Bar Chart (left) + Line Chart (middle) ---- -->
    <leftSection>
        <!-- Bar Chart: Pipeline by Stage -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <!-- componentType = Chart for all chart types; chartType distinguishes them -->
            <componentType>Chart</componentType>
            <chartAxisRange>Auto</chartAxisRange>
            <!-- chartType options: HorizontalBar | VerticalBar | Line | Donut | Pie | Funnel | Scatter -->
            <chartType>HorizontalBar</chartType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>CLOSE_DATE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
                <filter>
                    <criteriaField>OWNER_ROLE</criteriaField>
                    <dashboardFilterId>2</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <description>Shows total pipeline amount grouped by opportunity stage.</description>
            <displayUnits>Auto</displayUnits>
            <footer>Grouped by StageName</footer>
            <groupingColumn>STAGE_NAME</groupingColumn>
            <header>Pipeline by Stage</header>
            <legendPosition>Bottom</legendPosition>
            <reportName>Sales_Reports/Pipeline_Amount_by_Stage_Summary</reportName>
            <!-- reportColumn: the aggregated measure to plot on the value axis -->
            <reportColumn>AMOUNT</reportColumn>
            <showPercentage>false</showPercentage>
            <showTotal>true</showTotal>
            <showValues>true</showValues>
            <title>Pipeline by Stage</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Line Chart: New Opportunities Created by Month -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Chart</componentType>
            <chartAxisRange>Auto</chartAxisRange>
            <chartType>Line</chartType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>CREATED_DATE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
                <filter>
                    <criteriaField>OWNER_ROLE</criteriaField>
                    <dashboardFilterId>2</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <description>Trend of new opportunities created each calendar month.</description>
            <displayUnits>Integer</displayUnits>
            <footer>Created Date grouped by month</footer>
            <!-- groupingColumn for a Line chart is typically the X-axis date bucket -->
            <groupingColumn>CREATED_DATE_MONTH</groupingColumn>
            <header>New Opps Created</header>
            <legendPosition>Bottom</legendPosition>
            <reportName>Sales_Reports/New_Opportunities_Created_by_Month_Summary</reportName>
            <reportColumn>RECORD_COUNT</reportColumn>
            <showPercentage>false</showPercentage>
            <showTotal>false</showTotal>
            <showValues>false</showValues>
            <title>New Opportunities Created by Month</title>
        </components>
    </middleSection>

    <!-- ---- ROW 3: Table spanning left column ---- -->
    <leftSection>
        <!-- Table: Top 10 Open Opportunities by Amount -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Table</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>CLOSE_DATE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
                <filter>
                    <criteriaField>OWNER_ROLE</criteriaField>
                    <dashboardFilterId>2</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <description>The ten largest open opportunities ranked by amount descending.</description>
            <footer>Sorted by Amount descending</footer>
            <header>Top Open Opportunities</header>
            <!-- maxRows: maximum number of data rows to display in the table component -->
            <maxRows>10</maxRows>
            <reportName>Sales_Reports/Top_Open_Opportunities_by_Amount_Tabular</reportName>
            <!-- indicatorHighColor / indicatorLowColor add conditional color indicators -->
            <indicatorHighColor>#54C254</indicatorHighColor>
            <indicatorLowColor>#C25454</indicatorLowColor>
            <indicatorBreakpoint1>50000</indicatorBreakpoint1>
            <indicatorBreakpoint2>200000</indicatorBreakpoint2>
            <!-- showPictographics: show colored dots instead of values for the indicator column -->
            <showPictographics>false</showPictographics>
            <sortBy>AMOUNT</sortBy>
            <!-- sortOrder options: Ascending | Descending -->
            <sortOrder>Descending</sortOrder>
            <title>Top 10 Open Opportunities by Amount</title>
        </components>
    </leftSection>

</Dashboard>
```

---

## Section 3: Dynamic Dashboard (LoggedInUser)

`dashboardType>LoggedInUser` runs each dashboard in the data context of whoever is currently
viewing it. **No `<runningUser>` tag is used** — adding one would be a deployment error because
the running user is resolved at runtime from the session. This is the "My ..." pattern that gives
every rep a personalized view of their own records.

**File path:** `force-app/main/default/dashboards/Sales_Dashboards/My_Pipeline_Dashboard.dashboard-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Dashboard xmlns="http://soap.sforce.com/2006/04/metadata">
    <backgroundEndColor>#FFFFFF</backgroundEndColor>
    <backgroundFadeDirection>Diagonal</backgroundFadeDirection>
    <backgroundStartColor>#FFFFFF</backgroundStartColor>
    <chartTheme>light</chartTheme>
    <colorPalette>default</colorPalette>
    <description>Personal pipeline dashboard. Runs as the logged-in user so each rep sees only their own opportunities.</description>

    <!-- dashboardType = LoggedInUser: no <runningUser> element is included.
         If dashboardType were SpecifiedUser, a <runningUser> would be required here.
         MyTeamUser would show the logged-in user's subordinate hierarchy. -->
    <dashboardType>LoggedInUser</dashboardType>
    <title>My Pipeline Dashboard</title>

    <leftSection>
        <!-- Component 1: My Open Opportunities count (Metric) -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <displayUnits>Integer</displayUnits>
            <footer>Open opportunities owned by me</footer>
            <header>My Open Opportunities</header>
            <metricLabel>Open Opps</metricLabel>
            <!-- Report must be filtered to "My Opportunities" (Owner = Current User) -->
            <reportName>Sales_Reports/My_Open_Opportunities_Count_Summary</reportName>
            <reportColumn>RECORD_COUNT</reportColumn>
            <title>My Open Opportunities</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Component 2: My Pipeline by Stage (Donut chart) -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Chart</componentType>
            <chartAxisRange>Auto</chartAxisRange>
            <chartType>Donut</chartType>
            <description>Distribution of my open pipeline across opportunity stages.</description>
            <displayUnits>Auto</displayUnits>
            <footer>Grouped by Stage Name</footer>
            <groupingColumn>STAGE_NAME</groupingColumn>
            <header>My Pipeline by Stage</header>
            <legendPosition>Right</legendPosition>
            <reportName>Sales_Reports/My_Pipeline_by_Stage_Summary</reportName>
            <reportColumn>AMOUNT</reportColumn>
            <showPercentage>true</showPercentage>
            <showTotal>true</showTotal>
            <showValues>false</showValues>
            <title>My Pipeline by Stage</title>
        </components>
    </middleSection>

    <rightSection>
        <!-- Component 3: My Opportunities Closing This Month (Table) -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Table</componentType>
            <description>All my opportunities with a close date in the current calendar month.</description>
            <footer>Close Date = This Month</footer>
            <header>Closing This Month</header>
            <maxRows>10</maxRows>
            <reportName>Sales_Reports/My_Opportunities_Closing_This_Month_Tabular</reportName>
            <sortBy>CLOSE_DATE</sortBy>
            <sortOrder>Ascending</sortOrder>
            <title>My Opportunities Closing This Month</title>
        </components>
    </rightSection>

</Dashboard>
```

---

## Section 4: Service Operations Dashboard

**File path:** `force-app/main/default/dashboards/Service_Dashboards/Service_SLA_Compliance_Operations.dashboard-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Dashboard xmlns="http://soap.sforce.com/2006/04/metadata">
    <backgroundEndColor>#FFFFFF</backgroundEndColor>
    <backgroundFadeDirection>Diagonal</backgroundFadeDirection>
    <backgroundStartColor>#FFFFFF</backgroundStartColor>
    <chartTheme>light</chartTheme>
    <colorPalette>default</colorPalette>
    <description>Operational view of SLA compliance and case queue health for the Service team.</description>
    <dashboardType>SpecifiedUser</dashboardType>
    <runningUser>service.operations@acme.com</runningUser>
    <title>Service SLA Compliance — Operations</title>

    <!-- Dashboard Filter: Case Type -->
    <dashboardFilters>
        <dashboardFilter>
            <name>Case Type</name>
            <dashboardFilterOptions>
                <operator>EQUALS</operator>
                <values>Mechanical</values>
            </dashboardFilterOptions>
            <dashboardFilterOptions>
                <operator>EQUALS</operator>
                <values>Electrical</values>
            </dashboardFilterOptions>
            <dashboardFilterOptions>
                <operator>EQUALS</operator>
                <values>Software</values>
            </dashboardFilterOptions>
            <dashboardFilterOptions>
                <operator>EQUALS</operator>
                <values>Billing</values>
            </dashboardFilterOptions>
        </dashboardFilter>
    </dashboardFilters>

    <!-- ---- ROW 1: Three Metric tiles ---- -->
    <leftSection>
        <!-- Metric 1: Open Cases -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>TYPE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <displayUnits>Integer</displayUnits>
            <footer>All open cases</footer>
            <header>Open Cases</header>
            <metricLabel>Total Open</metricLabel>
            <reportName>Service_Reports/Open_Cases_Count_Summary</reportName>
            <reportColumn>RECORD_COUNT</reportColumn>
            <title>Open Cases</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Metric 2: Cases Breached SLA -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>TYPE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <displayUnits>Integer</displayUnits>
            <footer>SLA violated</footer>
            <header>Breached SLA</header>
            <metricLabel>SLA Breaches</metricLabel>
            <!-- Source report filtered to IsSlaViolated = TRUE -->
            <reportName>Service_Reports/Cases_Breached_SLA_Count_Summary</reportName>
            <reportColumn>RECORD_COUNT</reportColumn>
            <title>Cases Breached SLA</title>
        </components>
    </middleSection>

    <rightSection>
        <!-- Metric 3: Average Resolution Time (hours) -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>TYPE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <displayUnits>Auto</displayUnits>
            <footer>Closed cases — hours to resolve</footer>
            <header>Avg Resolution Time</header>
            <metricLabel>Hours</metricLabel>
            <reportName>Service_Reports/Average_Case_Resolution_Time_Summary</reportName>
            <!-- AVG_HOURS_TO_CLOSE is a custom formula field aggregate in the source report -->
            <reportColumn>AVG_HOURS_TO_CLOSE</reportColumn>
            <title>Average Resolution Time</title>
        </components>
    </rightSection>

    <!-- ---- ROW 2: Gauge + Bar Chart ---- -->
    <leftSection>
        <!-- Gauge: SLA Compliance % -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Gauge</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>TYPE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <description>Percentage of cases resolved within SLA target. Red below 80%, yellow 80-95%, green above 95%.</description>
            <footer>Target: 95%</footer>
            <header>SLA Compliance</header>
            <!-- gaugeMin / gaugeMax define the full scale of the gauge needle -->
            <gaugeMin>0.0</gaugeMin>
            <gaugeMax>100.0</gaugeMax>
            <!-- breakPointOne: bottom of the medium (yellow) band -->
            <breakPointOne>80.0</breakPointOne>
            <!-- breakPointTwo: bottom of the high (green) band -->
            <breakPointTwo>95.0</breakPointTwo>
            <!-- indicatorLowColor: color for values below breakPointOne -->
            <indicatorLowColor>#C25454</indicatorLowColor>
            <!-- indicatorMidColor: color for values between breakPointOne and breakPointTwo -->
            <indicatorMidColor>#FFD700</indicatorMidColor>
            <!-- indicatorHighColor: color for values above breakPointTwo -->
            <indicatorHighColor>#54C254</indicatorHighColor>
            <reportName>Service_Reports/SLA_Compliance_Percentage_Summary</reportName>
            <!-- SLA_COMPLIANCE_PCT: custom formula field measuring (1 - breaches/total)*100 -->
            <reportColumn>SLA_COMPLIANCE_PCT</reportColumn>
            <showPercentage>true</showPercentage>
            <showTotal>false</showTotal>
            <title>SLA Compliance % — Current Period</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Bar Chart: Cases by Priority -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Chart</componentType>
            <chartAxisRange>Auto</chartAxisRange>
            <chartType>HorizontalBar</chartType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>TYPE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <description>Volume of open cases broken down by priority level.</description>
            <displayUnits>Integer</displayUnits>
            <footer>Open cases grouped by priority</footer>
            <groupingColumn>PRIORITY</groupingColumn>
            <header>Cases by Priority</header>
            <legendPosition>Bottom</legendPosition>
            <reportName>Service_Reports/Open_Cases_by_Priority_Summary</reportName>
            <reportColumn>RECORD_COUNT</reportColumn>
            <showPercentage>false</showPercentage>
            <showTotal>true</showTotal>
            <showValues>true</showValues>
            <title>Cases by Priority</title>
        </components>
    </middleSection>

    <!-- ---- ROW 3: Table (Cases Open > 5 Days) ---- -->
    <leftSection>
        <!-- Table: Cases Open More Than 5 Days -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Table</componentType>
            <dashboardFilterColumns>
                <filter>
                    <criteriaField>TYPE</criteriaField>
                    <dashboardFilterId>1</dashboardFilterId>
                </filter>
            </dashboardFilterColumns>
            <description>Cases that have been open for more than 5 business days and require immediate attention.</description>
            <footer>Sorted by age descending</footer>
            <header>Cases Open &gt; 5 Days</header>
            <maxRows>10</maxRows>
            <reportName>Service_Reports/Cases_Open_More_Than_5_Days_Tabular</reportName>
            <sortBy>CREATED_DATE</sortBy>
            <sortOrder>Ascending</sortOrder>
            <title>Cases Open More Than 5 Days</title>
        </components>
    </leftSection>

</Dashboard>
```

---

## Section 5: Executive KPI Dashboard

Text/header components (SectionHeader) create visual separators between dashboard sections.
They display a label with no underlying report data.

**File path:** `force-app/main/default/dashboards/Executive_Dashboards/Executive_Monthly_KPIs.dashboard-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Dashboard xmlns="http://soap.sforce.com/2006/04/metadata">
    <backgroundEndColor>#FFFFFF</backgroundEndColor>
    <backgroundFadeDirection>Diagonal</backgroundFadeDirection>
    <backgroundStartColor>#FFFFFF</backgroundStartColor>
    <chartTheme>light</chartTheme>
    <colorPalette>default</colorPalette>
    <description>Monthly KPI summary for the executive team covering Revenue, Pipeline, and Service metrics.</description>
    <dashboardType>SpecifiedUser</dashboardType>
    <runningUser>ceo@acme.com</runningUser>
    <title>Executive Monthly KPIs</title>

    <!-- ============================================================
         SECTION: Revenue
         SectionHeader components span all 3 columns and act as
         visual dividers. componentType = SectionHeader has no
         reportName — it is purely a label component.
         ============================================================ -->

    <leftSection>
        <!-- Section Header: Revenue -->
        <components>
            <!-- componentType = SectionHeader renders a text banner row.
                 No reportName, reportColumn, or data fields are used. -->
            <componentType>SectionHeader</componentType>
            <!-- header text is the visible label shown on the dashboard -->
            <header>Revenue</header>
            <title>Revenue Section Header</title>
        </components>
    </leftSection>

    <!-- Revenue Row: MTD Revenue (left), QTD Revenue (middle), Revenue Trend Line (right) -->
    <leftSection>
        <!-- Metric: MTD Revenue -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <displayUnits>Auto</displayUnits>
            <footer>Closed Won — month to date</footer>
            <header>MTD Revenue</header>
            <metricLabel>Revenue</metricLabel>
            <reportName>Finance_Reports/MTD_Closed_Won_Revenue_Summary</reportName>
            <reportColumn>AMOUNT</reportColumn>
            <title>MTD Revenue</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Metric: QTD Revenue -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <displayUnits>Auto</displayUnits>
            <footer>Closed Won — quarter to date</footer>
            <header>QTD Revenue</header>
            <metricLabel>Revenue</metricLabel>
            <reportName>Finance_Reports/QTD_Closed_Won_Revenue_Summary</reportName>
            <reportColumn>AMOUNT</reportColumn>
            <title>QTD Revenue</title>
        </components>
    </middleSection>

    <rightSection>
        <!-- Line Chart: Revenue Trend by Month -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Chart</componentType>
            <chartAxisRange>Auto</chartAxisRange>
            <chartType>Line</chartType>
            <description>Monthly closed-won revenue for the past 12 months.</description>
            <displayUnits>Auto</displayUnits>
            <footer>Last 12 months</footer>
            <groupingColumn>CLOSE_DATE_MONTH</groupingColumn>
            <header>Revenue Trend</header>
            <legendPosition>Bottom</legendPosition>
            <reportName>Finance_Reports/Monthly_Closed_Won_Revenue_Trend_Summary</reportName>
            <reportColumn>AMOUNT</reportColumn>
            <showPercentage>false</showPercentage>
            <showTotal>false</showTotal>
            <showValues>false</showValues>
            <title>Revenue Trend by Month</title>
        </components>
    </rightSection>

    <!-- ============================================================
         SECTION: Pipeline
         ============================================================ -->
    <leftSection>
        <components>
            <componentType>SectionHeader</componentType>
            <header>Pipeline</header>
            <title>Pipeline Section Header</title>
        </components>
    </leftSection>

    <!-- Pipeline Row: Total Pipeline (left), Funnel Chart by Stage (middle) -->
    <leftSection>
        <!-- Metric: Total Pipeline -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <displayUnits>Auto</displayUnits>
            <footer>All open stages</footer>
            <header>Total Pipeline</header>
            <metricLabel>Pipeline</metricLabel>
            <reportName>Sales_Reports/Pipeline_Amount_by_Stage_Summary</reportName>
            <reportColumn>AMOUNT</reportColumn>
            <title>Total Pipeline</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Funnel Chart: Pipeline by Stage -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Chart</componentType>
            <chartAxisRange>Auto</chartAxisRange>
            <!-- Funnel charts are ideal for visualising pipeline stage drop-off -->
            <chartType>Funnel</chartType>
            <description>Pipeline amount at each stage, visualised as a conversion funnel.</description>
            <displayUnits>Auto</displayUnits>
            <footer>Open pipeline by stage</footer>
            <groupingColumn>STAGE_NAME</groupingColumn>
            <header>Pipeline by Stage</header>
            <legendPosition>Bottom</legendPosition>
            <reportName>Sales_Reports/Pipeline_Amount_by_Stage_Summary</reportName>
            <reportColumn>AMOUNT</reportColumn>
            <showPercentage>true</showPercentage>
            <showTotal>true</showTotal>
            <showValues>true</showValues>
            <title>Pipeline by Stage (Funnel)</title>
        </components>
    </middleSection>

    <!-- ============================================================
         SECTION: Service
         ============================================================ -->
    <leftSection>
        <components>
            <componentType>SectionHeader</componentType>
            <header>Service</header>
            <title>Service Section Header</title>
        </components>
    </leftSection>

    <!-- Service Row: Open Cases (left), CSAT Score (middle) -->
    <leftSection>
        <!-- Metric: Open Cases -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <displayUnits>Integer</displayUnits>
            <footer>All open cases</footer>
            <header>Open Cases</header>
            <metricLabel>Cases</metricLabel>
            <reportName>Service_Reports/Open_Cases_Count_Summary</reportName>
            <reportColumn>RECORD_COUNT</reportColumn>
            <title>Open Cases</title>
        </components>
    </leftSection>

    <middleSection>
        <!-- Metric: CSAT Score -->
        <components>
            <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
            <componentType>Metric</componentType>
            <displayUnits>Auto</displayUnits>
            <footer>Average CSAT — current month</footer>
            <header>CSAT Score</header>
            <metricLabel>CSAT</metricLabel>
            <reportName>Service_Reports/Average_CSAT_Score_Summary</reportName>
            <!-- AVG_CSAT_SCORE: average of the CSAT_Score__c custom field -->
            <reportColumn>AVG_CSAT_SCORE</reportColumn>
            <title>CSAT Score</title>
        </components>
    </middleSection>

</Dashboard>
```

---

## Section 6: Dashboard with Gauge Component — Standalone Snippet

**Context:** The gauge below would be placed inside a `<leftSection>`, `<middleSection>`, or `<rightSection>` block.

**File path context:** `force-app/main/default/dashboards/Sales_Dashboards/Quota_Attainment_Dashboard.dashboard-meta.xml`

```xml
<!-- Gauge: Quota Attainment — Current Quarter -->
<!-- Place inside <leftSection>, <middleSection>, or <rightSection> as needed -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <componentType>Gauge</componentType>
    <description>Displays the percentage of quota attained in the current quarter. Red = below 70%, Yellow = 70-90%, Green = 90%+.</description>
    <footer>Current quarter target: 100%</footer>
    <header>Quota Attainment</header>

    <!-- gaugeMin: the lowest value on the gauge scale (0 = 0%) -->
    <gaugeMin>0.0</gaugeMin>
    <!-- gaugeMax: the highest value on the gauge scale (150 = 150%) -->
    <gaugeMax>150.0</gaugeMax>

    <!-- breakPointOne: the boundary between the Low (red) and Medium (yellow) bands.
         Values below this are shown in indicatorLowColor. -->
    <breakPointOne>70.0</breakPointOne>

    <!-- breakPointTwo: the boundary between the Medium (yellow) and High (green) bands.
         Values between breakPointOne and this are shown in indicatorMidColor.
         Values above this are shown in indicatorHighColor. -->
    <breakPointTwo>90.0</breakPointTwo>

    <!-- indicatorLowColor: hex color for the low band (0-70%) -->
    <indicatorLowColor>#C25454</indicatorLowColor>
    <!-- indicatorMidColor: hex color for the medium band (70-90%) -->
    <indicatorMidColor>#FFD700</indicatorMidColor>
    <!-- indicatorHighColor: hex color for the high band (90%+) -->
    <indicatorHighColor>#54C254</indicatorHighColor>

    <reportName>Sales_Reports/Quota_Attainment_Current_Quarter_Summary</reportName>
    <!-- QUOTA_ATTAINMENT_PCT: formula field = (SUM(Amount) / QuotaAmount__c) * 100 -->
    <reportColumn>QUOTA_ATTAINMENT_PCT</reportColumn>

    <showPercentage>true</showPercentage>
    <showTotal>false</showTotal>
    <title>Quota Attainment — Current Quarter</title>
</components>
```

---

## Section 7: Component XML Snippets Reference

Copy-paste ready XML blocks for each component type.
All snippets assume placement inside a `<leftSection>`, `<middleSection>`, or `<rightSection>` block.

---

### 7a. Metric Component

```xml
<!-- Metric component: displays a single aggregate value (sum, count, average, etc.) -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <!-- componentType = Metric for a single large number tile -->
    <componentType>Metric</componentType>
    <!-- displayUnits options: Auto | Integer | Hundreds | Thousands | Millions | Billions -->
    <displayUnits>Auto</displayUnits>
    <footer>Optional sub-label below the value</footer>
    <header>Component Title Label</header>
    <!-- metricLabel: the label shown directly below the large number -->
    <metricLabel>Amount</metricLabel>
    <!-- reportName: folder/ReportDeveloperName (no .report extension) -->
    <reportName>Sales_Reports/Total_Revenue_Closed_Won_Summary</reportName>
    <!-- reportColumn: aggregate field API name exposed by the source report.
         Common values: AMOUNT, RECORD_COUNT, AVG_AMOUNT, SUM_AMOUNT, MAX_AMOUNT -->
    <reportColumn>AMOUNT</reportColumn>
    <title>Total Revenue — Closed Won</title>
</components>
```

---

### 7b. Gauge Component

```xml
<!-- Gauge component: needle/arc dial showing a value against a min/max scale with colour bands -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <componentType>Gauge</componentType>
    <description>Gauge showing a KPI against target thresholds.</description>
    <footer>Target threshold annotations</footer>
    <header>KPI Gauge</header>
    <gaugeMin>0.0</gaugeMin>
    <gaugeMax>100.0</gaugeMax>
    <!-- breakPointOne: lower threshold (start of medium band) -->
    <breakPointOne>50.0</breakPointOne>
    <!-- breakPointTwo: upper threshold (start of high band) -->
    <breakPointTwo>75.0</breakPointTwo>
    <indicatorLowColor>#C25454</indicatorLowColor>
    <indicatorMidColor>#FFD700</indicatorMidColor>
    <indicatorHighColor>#54C254</indicatorHighColor>
    <reportName>Sales_Reports/Win_Rate_Current_Quarter_Summary</reportName>
    <reportColumn>WIN_RATE_PCT</reportColumn>
    <showPercentage>true</showPercentage>
    <showTotal>false</showTotal>
    <title>Win Rate Gauge — Current Quarter</title>
</components>
```

---

### 7c. Bar Chart Component (Horizontal Bar)

```xml
<!-- Bar chart: HorizontalBar groups data by a row-level field and plots an aggregate measure -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <!-- componentType = Chart for all chart variants -->
    <componentType>Chart</componentType>
    <chartAxisRange>Auto</chartAxisRange>
    <!-- chartType = HorizontalBar renders bars extending left-to-right.
         Use VerticalBar (Column chart) for top-to-bottom bars. -->
    <chartType>HorizontalBar</chartType>
    <description>Bar chart grouped by a categorical field.</description>
    <displayUnits>Auto</displayUnits>
    <footer>Grouped by field label</footer>
    <!-- groupingColumn: the row grouping field from the source Summary/Matrix report
         that defines the category axis (Y-axis for HorizontalBar) -->
    <groupingColumn>ACCOUNT_INDUSTRY</groupingColumn>
    <header>Chart Title Label</header>
    <legendPosition>Bottom</legendPosition>
    <reportName>Sales_Reports/Revenue_by_Industry_Summary</reportName>
    <reportColumn>AMOUNT</reportColumn>
    <showPercentage>false</showPercentage>
    <showTotal>true</showTotal>
    <showValues>true</showValues>
    <title>Revenue by Industry</title>
</components>
```

---

### 7d. Line Chart Component

```xml
<!-- Line chart: best used with a date-bucket grouping on the X-axis to show trends over time -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <componentType>Chart</componentType>
    <chartAxisRange>Auto</chartAxisRange>
    <!-- chartType = Line renders connected data points over a continuous axis -->
    <chartType>Line</chartType>
    <description>Line chart showing a metric trended over time.</description>
    <displayUnits>Auto</displayUnits>
    <footer>Date grouped by month</footer>
    <!-- groupingColumn for a Line chart is typically a date bucket field:
         CLOSE_DATE_MONTH | CLOSE_DATE_QUARTER | CREATED_DATE_MONTH etc. -->
    <groupingColumn>CLOSE_DATE_MONTH</groupingColumn>
    <header>Monthly Trend</header>
    <legendPosition>Bottom</legendPosition>
    <reportName>Sales_Reports/Monthly_Revenue_Trend_Summary</reportName>
    <reportColumn>AMOUNT</reportColumn>
    <showPercentage>false</showPercentage>
    <showTotal>false</showTotal>
    <showValues>false</showValues>
    <title>Monthly Revenue Trend</title>
</components>
```

---

### 7e. Donut Chart Component

```xml
<!-- Donut chart: shows proportional distribution; showPercentage = true adds % labels on slices -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <componentType>Chart</componentType>
    <chartAxisRange>Auto</chartAxisRange>
    <!-- chartType = Donut renders a ring/donut shape; Pie renders a filled circle -->
    <chartType>Donut</chartType>
    <description>Donut chart showing proportional breakdown by category.</description>
    <displayUnits>Auto</displayUnits>
    <footer>Grouped by category field</footer>
    <groupingColumn>LEAD_SOURCE</groupingColumn>
    <header>Opportunities by Lead Source</header>
    <!-- legendPosition options: Bottom | Right | OnChart -->
    <legendPosition>Right</legendPosition>
    <reportName>Sales_Reports/Opportunities_by_Lead_Source_Summary</reportName>
    <reportColumn>RECORD_COUNT</reportColumn>
    <showPercentage>true</showPercentage>
    <showTotal>true</showTotal>
    <showValues>false</showValues>
    <title>Opportunities by Lead Source</title>
</components>
```

---

### 7f. Funnel Chart Component

```xml
<!-- Funnel chart: visualises stage-based drop-off; ordered by the row grouping in the source report -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <componentType>Chart</componentType>
    <chartAxisRange>Auto</chartAxisRange>
    <!-- chartType = Funnel renders trapezoidal segments sized by value, top = largest -->
    <chartType>Funnel</chartType>
    <description>Pipeline conversion funnel showing volume at each sales stage.</description>
    <displayUnits>Auto</displayUnits>
    <footer>Ordered by stage sequence</footer>
    <groupingColumn>STAGE_NAME</groupingColumn>
    <header>Pipeline Funnel</header>
    <legendPosition>Bottom</legendPosition>
    <reportName>Sales_Reports/Pipeline_Amount_by_Stage_Summary</reportName>
    <reportColumn>AMOUNT</reportColumn>
    <showPercentage>true</showPercentage>
    <showTotal>true</showTotal>
    <showValues>true</showValues>
    <title>Pipeline by Stage — Funnel View</title>
</components>
```

---

### 7g. Table Component

```xml
<!-- Table component: renders a row-by-row list from a Tabular or Summary report -->
<components>
    <autoselectColumnsFromReport>false</autoselectColumnsFromReport>
    <!-- componentType = Table renders a data grid -->
    <componentType>Table</componentType>
    <description>Top records sorted by Amount descending.</description>
    <footer>Sorted by Amount descending</footer>
    <header>Top Records by Amount</header>
    <!-- maxRows: cap the displayed rows (1-99); use 10 for most dashboards -->
    <maxRows>10</maxRows>
    <reportName>Sales_Reports/Top_Opportunities_by_Amount_Tabular</reportName>
    <!-- indicatorBreakpoint1 / indicatorBreakpoint2: conditional colour thresholds -->
    <indicatorHighColor>#54C254</indicatorHighColor>
    <indicatorLowColor>#C25454</indicatorLowColor>
    <indicatorBreakpoint1>50000</indicatorBreakpoint1>
    <indicatorBreakpoint2>200000</indicatorBreakpoint2>
    <showPictographics>false</showPictographics>
    <!-- sortBy: API field name to sort the rows by -->
    <sortBy>AMOUNT</sortBy>
    <!-- sortOrder options: Ascending | Descending -->
    <sortOrder>Descending</sortOrder>
    <title>Top 10 Opportunities by Amount</title>
</components>
```

---

### 7h. Text / Section Header Component

```xml
<!-- SectionHeader component: a full-width text banner with no underlying data.
     Use to visually divide a dashboard into labelled sections.
     No reportName, reportColumn, or data-related tags are used. -->
<components>
    <!-- componentType = SectionHeader renders a styled label row
         that spans all 3 columns of the dashboard grid -->
    <componentType>SectionHeader</componentType>
    <!-- header: the visible text displayed in the banner -->
    <header>Section Label Text</header>
    <!-- title: internal metadata name for the component -->
    <title>Section Label — Section Header</title>
</components>
```

---

## Section 8: Dashboard Filter XML — Complete Block

The `<dashboardFilters>` element sits at the top level of the `<Dashboard>` element,
before the column section elements. Filters are referenced by 1-based index in components.

```xml
<!-- Complete <dashboardFilters> block — paste inside <Dashboard> before column sections -->
<dashboardFilters>

    <!-- Filter 1: Date Range on Opportunity Close Date -->
    <!-- Components reference this filter with <dashboardFilterId>1</dashboardFilterId> -->
    <!-- and criteriaField CLOSE_DATE -->
    <dashboardFilter>
        <!-- name: the label shown in the dashboard filter bar to viewers -->
        <name>Close Date Range</name>

        <!-- Each <dashboardFilterOptions> block is one item in the filter picklist -->
        <dashboardFilterOptions>
            <!-- operator: BETWEEN works with date range values;
                 other options: EQUALS | NOT_EQUAL | LESS_THAN | GREATER_THAN | CONTAINS -->
            <operator>BETWEEN</operator>
            <!-- values: Salesforce date literal or explicit value.
                 Date literals: THIS_WEEK | LAST_WEEK | THIS_MONTH | LAST_MONTH |
                 THIS_QUARTER | LAST_QUARTER | THIS_YEAR | LAST_YEAR | LAST_N_DAYS:n -->
            <values>THIS_MONTH</values>
        </dashboardFilterOptions>
        <dashboardFilterOptions>
            <operator>BETWEEN</operator>
            <values>THIS_QUARTER</values>
        </dashboardFilterOptions>
        <dashboardFilterOptions>
            <operator>BETWEEN</operator>
            <values>LAST_QUARTER</values>
        </dashboardFilterOptions>
        <dashboardFilterOptions>
            <operator>BETWEEN</operator>
            <values>THIS_YEAR</values>
        </dashboardFilterOptions>

    </dashboardFilter>

    <!-- Filter 2: Owner/Team multi-select (EQUALS, one option per value) -->
    <!-- Components reference this filter with <dashboardFilterId>2</dashboardFilterId> -->
    <!-- and criteriaField OWNER_ROLE -->
    <dashboardFilter>
        <name>Sales Team</name>

        <!-- EQUALS with discrete values works as a multi-select picklist in the UI.
             Each dashboardFilterOptions block adds one selectable value. -->
        <dashboardFilterOptions>
            <operator>EQUALS</operator>
            <values>Inside Sales</values>
        </dashboardFilterOptions>
        <dashboardFilterOptions>
            <operator>EQUALS</operator>
            <values>Enterprise Sales</values>
        </dashboardFilterOptions>
        <dashboardFilterOptions>
            <operator>EQUALS</operator>
            <values>SMB Sales</values>
        </dashboardFilterOptions>
        <dashboardFilterOptions>
            <operator>EQUALS</operator>
            <values>Partner Sales</values>
        </dashboardFilterOptions>

    </dashboardFilter>

</dashboardFilters>
```

---

## Section 9: Naming Convention Cheat Sheet

| Team | Dashboard Developer Name | Audience | Folder Path | Dashboard Type |
|---|---|---|---|---|
| Sales | `Sales_Pipeline_Overview_VP` | VP of Sales | `Sales_Dashboards/Sales_Executive_Dashboards` | SpecifiedUser |
| Sales | `My_Pipeline_Dashboard` | Individual Reps | `Sales_Dashboards` | LoggedInUser |
| Sales | `Sales_Manager_Team_Pipeline` | Sales Managers | `Sales_Dashboards` | MyTeamUser |
| Marketing | `Marketing_Campaign_ROI_Overview` | Marketing Leadership | `Marketing_Dashboards` | SpecifiedUser |
| Service | `Service_SLA_Compliance_Operations` | Service Ops Team | `Service_Dashboards` | SpecifiedUser |
| Service | `My_Cases_Dashboard` | Individual Agents | `Service_Dashboards` | LoggedInUser |
| Finance | `Executive_Monthly_KPIs` | C-Suite / Board | `Executive_Dashboards` | SpecifiedUser |
| Finance | `Finance_Revenue_Forecast_Monthly` | Finance Team | `Finance_Dashboards` | SpecifiedUser |

**Naming rules:**
- Use PascalCase with underscores as word separators: `Sales_Pipeline_Overview_VP`
- Suffix audience or scope at the end: `_VP`, `_Manager`, `_Team`, `_Ops`
- Source report names referenced in dashboard XML follow the same convention:
  `FolderName/Descriptive_Report_Name_ReportType` (e.g., `Sales_Reports/Pipeline_Amount_by_Stage_Summary`)
- Sub-folder developer names use hyphen concatenation: `ParentFolder-SubFolder`

---

## Section 10: Component-to-Report-Type Matrix

| Component | Tabular | Summary | Matrix | Notes |
|---|---|---|---|---|
| Metric | Yes | Yes | Yes | Requires an aggregate (SUM, COUNT, AVG) in the report. Tabular reports must expose a grand total row. Matrix reports can use any aggregate. |
| Gauge | No | Yes | Yes | Must have at least one aggregate field. The report must be Summary or Matrix — Tabular has no grouping to aggregate against. |
| Bar / Column Chart | No | Yes | Yes | Requires at least one row-level grouping in the source report for the category axis. Matrix reports support grouped bar charts. |
| Line Chart | No | Yes | Yes | Works best when the row grouping is a date bucket (month, quarter). Supports secondary groupings for multi-series lines. |
| Donut / Pie | No | Yes | No | Works only with Summary reports. Each slice corresponds to one row-group value. Not supported on Matrix reports. |
| Funnel | No | Yes | No | Works only with Summary reports. Segment size reflects the aggregate value per row group. Order follows the report sort order. |
| Table | Yes | Yes | No | Most flexible component — Tabular reports are ideal for row-by-row lists. Summary reports work but display grouped rows. Matrix not supported. |
| SectionHeader | N/A | N/A | N/A | No source report required. Pure UI label component. Place in any column section to create a visual divider row. |

**Additional notes:**

- **Metric on Tabular:** The report must have a grand total enabled (Report Properties > Show Grand Total). The `reportColumn` should reference a column with a summary (e.g., `AMOUNT` with SUM).
- **Bar/Line on Matrix:** Set `groupingColumn` to the outer row grouping; the inner row grouping becomes a data series. Use a `<groupingColumn2>` attribute when a second series dimension is needed.
- **Table maxRows:** Maximum value is 99. Setting `<maxRows>10</maxRows>` with `<sortOrder>Descending</sortOrder>` is the standard "Top N" table pattern.
- **Gauge source report:** The source Summary/Matrix report must have exactly one aggregate value that maps to the gauge needle. The `gaugeMin`/`gaugeMax` scale should match the realistic range of that aggregate (e.g., 0-100 for a percentage, 0-5000000 for a revenue target).
- **Donut/Pie slice limit:** Salesforce renders a maximum of 20 slices. Values beyond 20 are collapsed into an "Other" slice. Keep your row grouping cardinality low.
- **Funnel ordering:** The Funnel chart respects the sort order defined in the source Summary report. Sort the `STAGE_NAME` grouping by a custom numeric sequence field (e.g., `Stage_Order__c`) to enforce correct funnel progression from Prospecting at the top to Closed Won at the bottom.