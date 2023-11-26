-- Number of commits per repository

SELECT
  repo,
  count() as commits
FROM gitlog;


-- Number of commits per repository for each given month

SELECT
  committed_datetime,
  repo,
  count() as commits
FROM gitlog
SAMPLE BY 1M ALIGN TO CALENDAR;


-- Most recent commit for each repository

SELECT *
FROM gitlog
LATEST ON committed_datetime
    PARTITION BY repo;

-- Most recent contribution for each repository, per author

SELECT *
FROM gitlog
LATEST ON committed_datetime
    PARTITION BY repo, author_name;


-- Busiest day for each of the repositories

WITH totals AS (
    SELECT
      committed_datetime,
      repo,
      count() as commits
    FROM gitlog
    SAMPLE BY 1d ALIGN TO CALENDAR
), ranked AS (
    SELECT *, RANK() OVER(
                            PARTITION BY repo
                            ORDER BY commits DESC
                            ) AS position
    FROM totals
)
SELECT * FROM ranked
WHERE position = 1;
ORDER BY repo
;


-- Understand how vibrant a community is by tracking contributor's activity over time

SELECT
  committed_datetime,
  repo,
  count_distinct(author_name) AS unique_authors
FROM gitlog
SAMPLE BY 1y ALIGN TO CALENDAR;


-- Find periods without any commit activity for each or all of the projects

WITH kube_sampled_and_interpolated AS (
  SELECT
    committed_datetime,
    repo,
    count() as commits
  FROM gitlog
  WHERE repo = 'kubernetes'
  SAMPLE BY 2d FILL(NULL) ALIGN TO CALENDAR
 )
 SELECT * FROM kube_sampled_and_interpolated
 WHERE commits IS NULL;

-- Find the most prolonged period without any activity (hint: SAMPLE BY and FILL can help for this query)

 WITH go_sampled_and_interpolated AS (
  SELECT
    committed_datetime,
    repo,
    count() as commits
  FROM gitlog
  WHERE repo = 'go'
  SAMPLE BY 13y FILL(NULL) ALIGN TO CALENDAR
 )
 SELECT * FROM go_sampled_and_interpolated
 WHERE commits IS NULL;
