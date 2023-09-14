CREATE TABLE IF NOT EXISTS gitlog (
    committed_datetime TIMESTAMP,
    repo SYMBOL,
    author_name SYMBOL,
    summary STRING,
    size INT,
    insertions INT,
    deletions INT,
    lines INT,
    files INT
    ) timestamp (committed_datetime)
    PARTITION BY MONTH WAL
    DEDUP UPSERT KEYS(committed_datetime, repo, author_name);

