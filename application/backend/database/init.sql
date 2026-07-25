CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY,
    title VARCHAR(120) NOT NULL,
    location VARCHAR(120) NOT NULL,
    travel_date DATE NOT NULL,
    description TEXT NOT NULL CHECK (char_length(description) <= 5000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_journal_entries_travel_date
    ON journal_entries (travel_date DESC);
