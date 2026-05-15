CREATE TABLE _migration_test (
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO _migration_test (message) VALUES ('migrate test from v0.2.0');