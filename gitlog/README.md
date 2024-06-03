# Gitlog dataset (logs/activity)

Activity logs from three open source repositories on GitHub: [QuestDB](https://github.com/questdb/questdb), [Go](https://github.com/golang/go), and [Kubernetes](https://github.com/kubernetes/kubernetes).

This dataset has been generating parsing the `git log` output for each repository. The dataset contains all the commits (~174K rows) since the beginning of each project until `2023-09-05T07:05:52.000000Z`.

---

## Table structure

```sql
CREATE TABLE IF NOT EXISTS gitlog (
    committed_datetime TIMESTAMP,
    repo SYMBOL,
    author_name SYMBOL,
    summary VARCHAR,
    size INT,
    insertions INT,
    deletions INT,
    lines INT,
    files INT
    ) timestamp (committed_datetime)
    PARTITION BY MONTH WAL
    DEDUP UPSERT KEYS(committed_datetime, repo, author_name);
```

---

## Importing the dataset using the command line

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@gitlog_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@gitlog.csv "http://localhost:9000/imp?name=gitlog"
```

---

## Some questions you can ask this dataset

* How many commits do we have per repository?
* How many do we have per repository and month? Trivia: check out the date of Go first commit? :)
* Which is the latest registered commit for each repository?
* And the most recent contribution for each repository and author?
* What was the busiest day for each of the repos?
* Can you get an idea of the community health by tracking different contributors over the years?
* Are there any periods where we don't have any activity for each/all of the projects? Can you find the longest period
 without any activity? (hint: maybe using SAMPLE BY and FILL can help here)

Find [here](./gitlog_sample_queries.sql) some SQL answers to these questions.

