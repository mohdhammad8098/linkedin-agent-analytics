# LinkedIn Agent Analytics Platform

## Project Overview

This project is an end-to-end analytics platform designed to analyze LinkedIn agent outreach and lead activity.

The solution covers:

 LinkedIn agent integration,
 Lead and outreach data ingestion,
 Data warehouse / star-schema design,
 Data-quality validation,
 Risk intelligence,
 Power BI analytics and visualization,
 Automated testing,
 CI/CD workflow using GitHub Actions.

The objective is to transform LinkedIn outreach data into reliable analytical datasets and business-focused dashboards.

## Project Architecture
LinkedIn Agent
      │
      ▼
Lead / Outreach Data
      │
      ▼
Data Ingestion
      │
      ▼
PostgreSQL Database
      │
      ├── Dimension Tables
      │     ├── dim_date
      │     ├── dim_agent
      │     ├── dim_lead
      │     └── dim_source
      │
      ├── Fact Table
      │     └── fact_lead_activity
      │
      └── Data Quality Results
            └── dq_results
      │
      ▼
Analytical Views
      │
      ▼
Power BI
      │
      ├── Core KPIs
      ├── Account Health
      ├── Risk Intelligence
      ├── Campaign ROI
      └── Data Quality

# Technology Stack
Python	
PostgreSQL	
SQL	
Power BI	
GitHub	
pytest	


## Project structure

linkedin-agent-analytics/
│
├── .github/
│   └── workflows/
│       └── tests.yml
│
├── part_1_evidence/
│   └── project_ss/
│
├── power bi/
│   ├── linkedin_agent_analytics.pbix
│   └── screenshots/
│
├── raw_data/
│
├── src/
│   ├── analytics/
│   │   ├── queries.sql
│   │   └── risk_model.sql
│   │
│   ├── db/
│   │   ├── connection.py
│   │   └── schema.sql
│   │
│   ├── ingestion/
│   │   └── load_leads.py
│   │
│   ├── quality/
│   │   └── data_quality.sql
│   │
│   └── warehouse/
│       └── star.schema.sql
│
├── tests/
│   └── test_leads.py
│
├── .gitignore
│
└── README.md




# Part 1 - LinkedIn Integration
The LinkedIn agent was connected successfully and used as the source for the outreach/lead data used in the analytics workflow.
Integration Evidence
The repository contains screenshots and notes documenting the integration process.
The integration notes cover:
 Account age information,
 LinkedIn connection / MFA,
 Integration challenges,
 Resolution of agent messaging issues.

Evidence is available in: part_1 evidence


# Part 2 - Data Ingestion
The project ingests lead and outreach information and prepares it for analytical processing.
The ingestion process is designed to:
 Retrieve source data,
 Validate the incoming data,
 Transform fields into an analytical structure,
 Load the data into PostgreSQL,
 Make the processed data available for Power BI.
The ingestion layer separates raw source data from analytical data so that the pipeline can be maintained and validated independently.

# Part 3 - Data Warehouse Design
A star-schema architecture was implemented for analytical reporting.
Dimension Tables:
    (dim_date) Stores date-related attributes used for time-based analysis,
    (dim_agent) Stores information about the LinkedIn agent,
    (dim_source) Stores lead-source information,
    (dim_lead) Stores lead-level information such as company, industry, location and other lead attributes.
Fact Table:
    (fact_lead_activity) Stores lead activity and outreach-related events used for analytical reporting.
Data Quality Table:
    (dq_results) Stores data-quality validation results and allows data-quality checks to be tracked.

The schema definition is available in: src/warehouse/star.schema.sql

# Part 4 - Data Quality
Data-quality checks were implemented to identify incomplete or invalid lead information.
The dashboard currently contains 70 leads.
The key data quality findings are:
 Total Leads= 70,
 Missing Company= 34,
 Missing Industry= 46,
 LinkedIn URLs= Complete & unique.

These metrics are presented in the Data Quality Power BI page.
The purpose of these checks is to identify issues in the source data before relying on the data for business analysis.

# Part 5 - Power BI Dashboard
The Power BI dashboard provides five analytical pages.
1. Core KPIs:
This page provides a high-level overview of LinkedIn outreach performance.
It includes:
    Total Leads - 70,
    Replies - 25,
    Reply Rate - 35.71%,
    Connections - 70,
    High-Risk Leads - 40.
The page also provides:
    Replies by agent,
    Lead status distribution,

2. Account Health:
This page evaluates the overall quality and risk profile of the lead database.
It includes:
    Average Risk Score — 55.71,
    Risk Level Distribution,
    Leads by Industry,
    Leads by Location.

3. Risk Intelligence:
This page focuses specifically on lead-risk analysis.
It includes:
    High-Risk Leads - 40,
    Lead Risk Distribution,
    Average Risk Score by Industry.
This page helps identify areas where lead-quality or outreach risk may require attention.

4. Campaign ROI:
The supplied dataset does not contain the required campaign-level financial fields needed to calculate reliable ROI or ROAS.
Specifically, the dataset does not contain:
    Campaign cost,
    Campaign ID,
    Revenue,
    Conversion value.
Therefore, ROI and ROAS are not calculated, because doing so would require unsupported assumptions.
Instead, the page presents source-level performance information such as:
    Total Leads by Source,
    Replies by Source.

5. Data Quality:
The Data Quality page provides a concise summary of the dataset's completeness.
Results:
    70 total leads,
    34 missing company values,
    46 missing industry values,
    LinkedIn URLs are complete and unique.
This page helps users quickly understand the reliability and completeness of the underlying dataset.

# Key Business Insights
Lead Volume- The dataset contains 70 leads,
Outreach Response- There are 25 replies, resulting in a reply rate of: 35.71%,
Risk- There are 40 high-risk leads and average risk score is 55.71,
Data Completeness- A significant portion of the dataset has missing, 34 leads have missing company information and 46 leads have missing industry information.

# Testing
Automated tests were implemented using pytest:-
Tests are located in: tests,
Tests can be executed locally using: pytest.


# Continuous Integration
GitHub Actions is configured to automatically run the test suite.
Workflow: .github/workflows/tests.yml .
The CI workflow helps ensure that changes to the project do not introduce unexpected failures.
The workflow runs the automated tests whenever changes are pushed to the repository.


# Data Limitations
The current dataset has several limitations that should be considered when interpreting the dashboard.
Missing Company Information: 34 of the 70 leads do not contain company information,
Missing Industry Information: 46 of the 70 leads do not contain industry information,
Campaign ROI Limitation: The dataset does not provide - Campaign ID, Campaign cost, Revenue, Conversion value.

# Conclusion
The LinkedIn Agent Analytics Platform provides an end-to-end workflow for transforming LinkedIn outreach data into an analytical reporting solution.
The project combines:
    LinkedIn Integration → Data Ingestion → PostgreSQL → Star Schema → Data Quality → Automated Testing → Power BI

The final Power BI dashboard provides visibility into:
    Lead volume,
    Outreach responses,
    Reply rate,
    Account health,
    Lead risk,
    Industry and location distribution,
    Data quality,
    Source-level performance.

The solution also explicitly documents data limitations rather than making unsupported business calculations.
