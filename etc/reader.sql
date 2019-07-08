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
    keyword TEXT
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
    sentence  INT,
    flesch    INT,
    summary   TEXT,
    title     TEXT,
    author    TEXT,
    date      TEXT,
    pages     INT,
    extension TEXT,
    mime      TEXT,
    genre     TEXT
);

