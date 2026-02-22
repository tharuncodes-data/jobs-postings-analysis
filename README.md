# 📊 Labor Market Intelligence Analysis (SQL Project)

## 📌 Project Overview

This project explores a job postings dataset using SQL to uncover insights into:

- Global hiring demand  
- Skill requirements & workforce trends  
- Salary distribution & compensation patterns  
- Skill valuation & market economics  
- Company-level hiring behavior  

The objective is to simulate a **real-world Business Intelligence / Talent Analytics workflow** by transforming raw job data into analytical views.

---

## 🎯 Business Problem

Modern job markets are dynamic and competitive.

Understanding:

✔ Which roles are in demand  
✔ Which skills drive hiring decisions  
✔ Which competencies command higher salaries  
✔ Which companies are expanding their workforce  

…is critical for:

- Job seekers  
- Recruiters  
- Workforce planners  
- Business analysts  

This analysis models the hiring ecosystem using structured SQL queries.

---

## 🎯 Key Business Questions Answered

### 🌍 Hiring Demand & Market Trends

- Which countries exhibit the highest hiring demand?  
- How does job demand vary across roles?  
- How has hiring activity evolved over time?  
- Are there observable hiring trends or patterns?  

---

### 🧠 Skill Demand & Workforce Insights

- Which skills are most frequently requested?  
- Which skills dominate hiring requirements within roles?  
- Which roles require the most diverse skillsets?  
- How does skill composition vary across job categories?  

---

### 💰 Salary & Compensation Analytics

- Which job roles command higher compensation premiums?  
- Which skills are associated with higher salaries?  
- Which skills offer the best demand-to-salary value?  

---

### 🏆 Skill Valuation & Market Economics

- Which skills account for the largest share of hiring demand within roles?  
- Which competencies provide the strongest market value?  

---

### 🏢 Company Hiring Insights

- Which companies demonstrate the highest hiring activity?  
- How is hiring demand distributed across job categories within companies?  

---

## 📈 Analytical Approach

The analysis was conducted entirely using SQL with:

✔ Multi-table joins  
✔ Aggregations & grouping  
✔ Common Table Expressions (CTEs)  
✔ Percentage-based metrics  
✔ Time-series analysis  
✔ Compensation modeling  
✔ KPI summarization  

Each query was designed to answer a **specific business question**, rather than simply perform technical operations.

---

## 🧱 Data Model

The dataset follows a relational structure:

- **job_postings_fact** → Job-level information  
- **skills_job_dim** → Job-to-skill mapping  
- **skills_dim** → Skill definitions  
- **company_dim** → Company information  

This design enables realistic Business Intelligence analysis.

---

## 📊 Analytical Views Created

The project transforms raw data into reusable analytical layers:

| View | Business Insight |
|------|------------------|
| `data_job_location` | Hiring demand by country & work arrangement |
| `top_data_jobs_skills` | Most in-demand skills |
| `skill_demand_percentage` | Skill importance within roles |
| `top_tech_paying_skills` | Demand vs salary for skills |
| `avg_salary_by_job` | Compensation benchmarking by role |
| `job_postings_over_month` | Hiring trends over time |
| `top_hiring_companies` | Company-level hiring activity |
| `bi_skill_diversity_by_role` | Role complexity analysis |
| `bi_kpi_summary` | Executive-level KPIs |
| `bi_most_valuable_skills` | Skill valuation across roles |

---

## 💡 Example Insights Derived

This analysis enables discovery of:

✔ High-demand job roles  
✔ Dominant technical competencies  
✔ Salary premiums across roles & skills  
✔ Skill concentration patterns  
✔ Workforce demand trends  
✔ Company hiring intensity  

---

## 🛠 Tools & Technologies

- **SQL (PostgreSQL)**  
- Relational Data Modeling  
- Analytical Query Design  

---

## 🚀 Skills Demonstrated

This project showcases practical analytics capabilities:

✅ Business Intelligence Thinking  
✅ Data Aggregation & Transformation  
✅ Workforce / Market Analysis  
✅ Compensation Analytics  
✅ Skill Valuation Modeling  
✅ Trend & Demand Analysis  

---

## ▶️ How to Run

1. Load the dataset into PostgreSQL  
2. Execute queries from the SQL file  
3. Query analytical views:

```sql
SELECT * FROM most_valuable_skills;
