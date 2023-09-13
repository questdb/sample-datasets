-- How many commits do we have per repository?

SELECT
  repo,
  count() as commits
FROM gitlog;


-- How many do we have per repository and month? Trivia: check out the date of Go first commit? :)

SELECT
  committed_datetime,
  repo,
  count() as commits
FROM gitlog
SAMPLE BY 1M ALIGN TO CALENDAR;


-- Which is the latest registered commit for each repository?

SELECT *
FROM gitlog
LATEST ON committed_datetime
    PARTITION BY repo;

-- And the most recent contribution for each repository and author?

SELECT *
FROM gitlog
LATEST ON committed_datetime
    PARTITION BY repo, author_name;


-- What was the busiest day for each of the repos?

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


-- Can you get an idea of the community health by tracking different contributors over the years?

SELECT
  committed_datetime,
  repo,
  count_distinct(author_name) AS unique_authors
FROM gitlog
SAMPLE BY 1y ALIGN TO CALENDAR;


-- Are there any periods where we don't have any activity for each/all of the projects? Can you find the longest period

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


WITH questdb_sampled_and_interpolated AS (
  SELECT
    committed_datetime,
    repo,
    count() as commits
  FROM gitlog
  WHERE repo = 'questdb'
  SAMPLE BY 20d FILL(NULL) ALIGN TO CALENDAR
 )
 SELECT * FROM questdb_sampled_and_interpolated
 WHERE commits IS NULL;


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
