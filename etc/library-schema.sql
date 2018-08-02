-- acquisitions
create table acquisitions (
    id            INTEGER PRIMARY KEY,
    date_created  DATETIME,
    process       TEXT,
    data          TEXT,
    key           TEXT,
    email         TEXT,
    ip            TEXT,
    date_updated  DATETIME,
    status        TEXT,
    note          TEXT
);

