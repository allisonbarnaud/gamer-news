CREATE DATABASE gamernews;

CREATE TABLE preferences (
    id SERIAL PRIMARY KEY,
    filter_term TEXT,
    results_number INTEGER,
    user_id INTEGER
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email TEXT,
    password_digest TEXT,
    username TEXT
);


