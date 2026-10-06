# 📦 Supply Chain Demand Forecasting & Inventory Optimization System

An end-to-end data science and analytics pipeline designed to optimize warehouse inventory levels, predict product demand, and audit fulfillment bottlenecks using enterprise relational data.

---

## 🚀 Business Objective
Retail and manufacturing operations face a constant balancing act: carrying too much inventory incurs high holding costs, while carrying too little results in stockouts and lost revenue. This project builds a predictive analytics system to:
1. Forecast future product demand using historical time-series data.
2. Calculate optimal **Safety Stock** and **Reorder Points** to mitigate supply chain volatility.
3. Audit fulfillment bottlenecks and delivery delays using advanced relational database queries.

---

## 🛠️ Tech Stack & Skills Demonstrated
* **Database & SQL:** PostgreSQL / SQLite (CTEs, Window Functions, Complex Joins, Data Auditing)
* **Data Manipulation & Analysis:** Python, Pandas, NumPy
* **Statistical Modeling & Forecasting:** Prophet / SARIMA (Time-series analysis, variance tracking)
* **Visualization:** Power BI / Matplotlib / Seaborn
* **Domain Focus:** Supply Chain Operations, Inventory Control, Logistics

---

## 📊 Project Architecture & Workflow

### 1. Database Extraction & Auditing (SQL)
* **Objective:** Simulated an enterprise relational database environment.
* **Actions:** Loaded raw transactional data into a SQL database and wrote complex queries to isolate lead-time variances, supplier performance, and product stockout rates.
* *[Link to SQL Script](./sql/data_audit_queries.sql)*

### 2. Exploratory Data Analysis & Feature Engineering (Python)
* Extracted audited data into Pandas to analyze seasonal purchasing trends, geographic shipping constraints, and fulfillment cycle times.

### 3. Statistical Modeling & Demand Forecasting
* Engineered a predictive forecasting pipeline to project quarterly product demand.
* Applied statistical formulas to calculate safety stock thresholds based on historical demand standard deviation and supplier lead-time fluctuations.

### 4. Business Impact & Dashboards
* Translated technical model outputs into actionable operational metrics:
  * **Projected Inventory Carrying Cost Reduction:** X%
  * **Service Level Target Maintained:** 98%
  * **Identified Bottlenecks:** Highlighted top regional shipping delays causing customer friction.

---

## 📂 Repository Structure
```text
├── data/                  # Raw and cleaned datasets (or instructions for access)
├── sql/                   # Database schema setup and complex SQL queries
├── notebooks/             # Jupyter notebooks for EDA and modeling
├── scripts/               # Production-ready Python scripts for pipelines
└── README.md              # Project documentation
