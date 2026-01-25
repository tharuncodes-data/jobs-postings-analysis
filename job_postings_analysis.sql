/*		RUN QUERIES DIRECTLY FROM HERE

select * from bi_data_job_location;


select * from bi_job_skill_demand;


select * from  bi_skill_demand_percentages


select * from bi_top_tech_paying_skills


select * from bi_skill_demand_vs_salary


select * from bi_job_role_demand_by_schedule


select * from bi_avg_salary_by_role

select * from bi_job_postings_over_time


select * from  bi_top_hiring_companies


select * from  bi_skill_combinations


select * from bi_skill_diversity_by_role

select * from bi_kpi_summary

select * from bi_most_valuable_skills

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


create view bi_data_job_location as 
select
	job_country,
	job_title_short,
	job_schedule_type,
	count(*) as job_count

from job_postings_fact
where job_title_short like '%Data%' or
	job_title_short like '%Machine%' or
	job_title_short like '%Business%' 

group by 
	job_country,
	job_title_short,
	job_schedule_type

order by
	job_count desc;


/*	TOP SKILLS FOR DATA JOBS	*/

CREATE VIEW bi_job_skill_demand AS

SELECT
	s.skills,
	j.job_title_short,
	j.job_schedule_type,
	count(*) as demand_count

from job_postings_fact as j

join skills_job_dim as js
	on j.job_id = js.job_id
join skills_dim s
	on js.skill_id = s.skill_id

where job_title_short like '%Data%' or
	j.job_title_short like '%Machine%' or
	j.job_title_short like '%Business%' 
group by
	s.skills,
	j.job_title_short,
	job_schedule_type

order by
	demand_count desc;


/*	SKILL DEMAND %	*/

CREATE OR REPLACE VIEW bi_skill_demand_percentages AS
WITH skill_demand AS (
    SELECT
        j.job_title_short,
        s.skills,
        COUNT(*) AS demand_count
    FROM job_postings_fact j
    JOIN skills_job_dim sj
        ON j.job_id = sj.job_id
    JOIN skills_dim s
        ON sj.skill_id = s.skill_id
    GROUP BY
        j.job_title_short,
        s.skills
),
total_demand AS (
    SELECT
        job_title_short,
        SUM(demand_count) AS total_demand
    FROM skill_demand
    GROUP BY job_title_short
)
SELECT
    sd.job_title_short,
    sd.skills,
    sd.demand_count,
    ROUND(
        (sd.demand_count * 100.0) / td.total_demand,
        2
    ) AS demand_percentage
FROM skill_demand sd
JOIN total_demand td
    ON sd.job_title_short = td.job_title_short
ORDER BY
	demand_percentage DESC
	

/*	TOP TECH PAYING SKILLS	*/
CREATE or replace VIEW bi_top_tech_paying_skills as
WITH base_data AS (
    SELECT
        j.job_title_short,
        s.skills,
        AVG(j.salary_year_avg::numeric) AS avg_salary,
        COUNT(*) AS demand_count
    FROM job_postings_fact j
    JOIN skills_job_dim sj
        ON j.job_id = sj.job_id
    JOIN skills_dim s
        ON sj.skill_id = s.skill_id
    WHERE j.salary_year_avg IS NOT NULL
    GROUP BY
        j.job_title_short,
        s.skills
)
SELECT
    job_title_short,
    skills,
    ROUND(avg_salary, 0) AS yearly_compensation,
    demand_count
FROM base_data;


/*	SKILL DEMAND VS SALARY	*/
CREATE OR REPLACE VIEW bi_skill_demand_vs_salary AS
SELECT
    j.job_title_short,
    s.skills,
    COUNT(*) AS demand_count,
    ROUND(AVG(j.salary_year_avg::numeric),0) AS avg_salary
FROM job_postings_fact j
JOIN skills_job_dim sj
    ON j.job_id = sj.job_id
JOIN skills_dim s
    ON sj.skill_id = s.skill_id
WHERE j.salary_year_avg IS NOT NULL
GROUP BY
    j.job_title_short,
    s.skills;


/*	DEMAND JOBS BY JOB TYPE	*/
CREATE OR REPLACE VIEW bi_job_role_demand_by_schedule AS
SELECT
    job_title_short,
    job_schedule_type,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY
    job_title_short,
    job_schedule_type;



/*	AVERAGE SALARY BY ROLE	*/
CREATE OR REPLACE VIEW bi_avg_salary_by_role AS
SELECT
    job_title_short,
    ROUND(AVG(salary_year_avg::numeric), 0) AS avg_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY
    job_title_short;


/*	JOB POSTINGS OVER TIME	*/
CREATE OR REPLACE VIEW bi_job_postings_over_time AS
SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    job_title_short,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY
    job_posted_month,
    job_title_short
ORDER BY
    job_posted_month;


/*	TOP HIRING COMPANIES	*/
CREATE OR REPLACE VIEW bi_top_hiring_companies AS

SELECT
    c.name AS company_name,
    j.job_title_short,
    COUNT(*) AS job_count
FROM job_postings_fact j
JOIN company_dim c
    ON j.company_id = c.company_id
GROUP BY
    c.name,
    j.job_title_short;



/*	NORMAL SKILL PAIRS	*/

CREATE OR REPLACE VIEW bi_skill_combinations AS
WITH skill_pairs AS (
    SELECT
        j.job_title_short,
        s1.skills AS skill_1,
        s2.skills AS skill_2
    FROM job_postings_fact j
    JOIN skills_job_dim sj1
        ON j.job_id = sj1.job_id
    JOIN skills_job_dim sj2
        ON j.job_id = sj2.job_id
        AND sj1.skill_id < sj2.skill_id
    JOIN skills_dim s1
        ON sj1.skill_id = s1.skill_id
    JOIN skills_dim s2
        ON sj2.skill_id = s2.skill_id
)
SELECT
    job_title_short,
    skill_1,
    skill_2,
    COUNT(*) AS co_occurrence_count
FROM skill_pairs
GROUP BY
    job_title_short,
    skill_1,
    skill_2;


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
    ROUND(ss.avg_salary, 0) AS avg_salary
FROM skill_stats ss
JOIN role_totals rt
    ON ss.job_title_short = rt.job_title_short
ORDER BY
	demand_percentage DESC;
