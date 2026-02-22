/*		RUN QUERIES DIRECTLY FROM HERE


*/

CREATE TABLE company_dim (
    company_id INT PRIMARY KEY,
    company_name TEXT
);


CREATE TABLE job_postings_fact (
    job_id INT PRIMARY KEY,
    job_title TEXT,
    job_title_short TEXT,
    job_location TEXT,
    job_schedule_type TEXT,
    salary_year_avg NUMERIC,
    salary_hour_avg NUMERIC,
    job_posted_date DATE,
    job_work_from_home BOOLEAN,
    company_id INT
);

CREATE TABLE skills_dim (
    skill_id INT PRIMARY KEY,
    skills TEXT
);


CREATE TABLE skills_job_dim (
    job_id INT,
    skill_id INT
);


/*	Data Jobs Locations	*/


CREATE OR REPLACE VIEW data_job_location AS
SELECT
	job_country,
	job_title_short,
	job_schedule_type,
	COUNT(*) job_count

FROM job_postings_fact
WHERE job_title_short LIKE '%Data%' OR
	job_title_short LIKE '%Machine%' OR
	job_title_short LIKE '%Business%' 

GROUP BY 
	job_country,
	job_title_short,
	job_schedule_type

ORDER BY
	job_count DESC;


/*	TOP SKILLS FOR DATA JOBS	*/

CREATE OR REPLACE VIEW top_data_jobs_skills AS

SELECT
	s.skills,
	COUNT(job_title_short) demand_count

FROM job_postings_fact j
JOIN skills_job_dim js
	ON j.job_id = js.job_id
JOIN skills_dim s
	ON js.skill_id = s.skill_id

WHERE job_title_short LIKE '%Data%' OR
	j.job_title_short LIKE '%Machine%' OR
	j.job_title_short LIKE '%Business%' 
GROUP BY
	s.skills
ORDER BY
	demand_count DESC ;


/*	SKILL DEMAND %	*/
CREATE OR REPLACE VIEW skill_demand_percentage AS
WITH demand as (
SELECT
	j.job_title_short,
	s.skills,
	COUNT(*) AS demand_count
FROM job_postings_fact j
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
GROUP BY
	j.job_title_short,
	s.skills
	),
for_pct as(
	SELECT
		job_title_short,
		SUM(demand_count) as total_demand
	FROM demand
	GROUP BY
		job_title_short
)

SELECT
	d.job_title_short,
	d.skills,
	d.demand_count,
	ROUND((d.demand_count/pct.total_demand)*100,2)  AS demand_percentage
FROM demand d
JOIN for_pct pct ON d.job_title_short = pct.job_title_short
ORDER BY demand_percentage DESC
	

/*	TOP TECH PAYING SKILLS	*/
CREATE OR REPLACE VIEW top_tech_paying_skills AS

WITH ds AS (SELECT
	s.skills,
	COUNT(*) AS demand_count,
	j.salary_year_avg
FROM job_postings_fact j
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE j.salary_year_avg IS NOT NULL
GROUP BY
	s.skills,
	j.salary_year_avg
)
SELECT
	skills,
	SUM(demand_count) AS total_demand,
	CAST(AVG(salary_year_avg) AS INT) AS average_salary
FROM ds
GROUP BY
	skills
ORDER BY
		total_demand DESC 


/*	AVERAGE SALARY BY ROLE	*/
CREATE OR REPLACE VIEW avg_salary_by_job AS
SELECT
    job_title_short,
    ROUND(AVG(salary_year_avg::numeric), 0) AS avg_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY
    job_title_short;


/*	JOB POSTINGS OVER TIME	*/
CREATE OR REPLACE VIEW job_postings_over_month AS
SELECT
    TO_CHAR(job_posted_date,'YYYY-MM') AS job_posted_month,
    job_title_short,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY
    job_posted_month,
    job_title_short
ORDER BY
    job_posted_month;

/*	TOP HIRING COMPANIES	*/
CREATE OR REPLACE VIEW top_hiring_companies as

SELECT
    c.name AS company_name,
    j.job_title_short,
    COUNT(*) AS job_count
FROM job_postings_fact j
JOIN company_dim c
    ON j.company_id = c.company_id
GROUP BY
    c.name,
    j.job_title_short
ORDER BY
	job_count DESC

/*	UNIQUE SKILLS FOR EACH JOBS	*/
CREATE OR REPLACE VIEW bi_skill_diversity_by_role AS
SELECT
    j.job_title_short,
    COUNT(DISTINCT sj.skill_id) AS unique_skill_count
FROM job_postings_fact j
JOIN skills_job_dim sj
    ON j.job_id = sj.job_id
GROUP BY
    j.job_title_short;

/*	KPI SUMMARY	*/

CREATE OR REPLACE VIEW bi_kpi_summary AS
SELECT
    COUNT(DISTINCT j.job_id) AS total_jobs,
    COUNT(DISTINCT j.company_id) AS total_companies,
    COUNT(DISTINCT sj.skill_id) AS total_skills
FROM job_postings_fact j
LEFT JOIN skills_job_dim sj
    ON j.job_id = sj.job_id;

/*	MOST VALUABLE SKILLS	*/
CREATE OR REPLACE VIEW bi_most_valuable_skills AS
WITH skill_stats AS (
    SELECT
        j.job_title_short,
        s.skills,
        COUNT(*) AS demand_count,
        AVG(j.salary_year_avg::numeric) AS avg_salary
    FROM job_postings_fact j
    JOIN skills_job_dim sj
        ON j.job_id = sj.job_id
    JOIN skills_dim s
        ON sj.skill_id = s.skill_id
    WHERE j.salary_year_avg IS NOT NULL
    GROUP BY
        j.job_title_short,
        s.skills
),
role_totals AS (
    SELECT
        job_title_short,
        SUM(demand_count) AS total_demand
    FROM skill_stats
    GROUP BY job_title_short
)
SELECT
    ss.skills,
    ss.job_title_short,
    ss.demand_count,
    ROUND((ss.demand_count::numeric / rt.total_demand) * 100, 2) AS demand_percentage,
    ROUND(ss.avg_salary, 0) as avg_salary
FROM skill_stats ss
JOIN role_totals rt
    ON ss.job_title_short = rt.job_title_short
ORDER BY
	demand_percentage DESC;

