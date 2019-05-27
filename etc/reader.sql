-- part-of-speech
create table pos (
    id    TEXT,
    sid   INT,
    tid   INT,
    token TEXT,
    lemma TEXT,
    pos   TEXT
);

-- name entitites
create table ent (
    id     TEXT,
    sid    INT,
    eid    INT,
    entity TEXT,
    type   TEXT
);

-- keywords
create table wrd (
    id      TEXT,
    keyword TEXT,
    lemma   TEXT
);

-- email addresses
create table adr (
    id      TEXT,
    address TEXT
);

-- questions
create table questions (
    id       TEXT,
    question TEXT
);

-- urls
create table url (
    id     TEXT,
    domain TEXT,
    url    TEXT
);

-- bibliographics, such as they are
create table bib (
    id        TEXT,
    words     INT,
    sentences INT,
    flesch    FLOAT,
    summary   TEXT,
    title     TEXT,
    creator   TEXT,
    date      TEXT,
    genre     TEXT
);

