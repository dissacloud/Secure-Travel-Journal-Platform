function formatDate(value) {
  if (!value) {
    return 'Date unavailable';
  }

  const normalizedValue =
    typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value)
      ? `${value}T00:00:00Z`
      : value;

  const date = new Date(normalizedValue);

  if (Number.isNaN(date.getTime())) {
    console.error('Invalid journal travel_date:', value);
    return 'Date unavailable';
  }

  return new Intl.DateTimeFormat('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  }).format(date);
}

export function JournalCard({ journal, onDelete, isDeleting }) {
  return (
    <article className="journal-card">
      <div className="journal-card__meta">
        <span>{journal.location}</span>
        <time dateTime={journal.travel_date || undefined}>
          {formatDate(journal.travel_date)}
        </time>
      </div>

      <h3>{journal.title}</h3>
      <p>{journal.description}</p>

      <div className="journal-card__footer">
        <span className="digest-label">
          ID {journal.id?.slice(0, 8) || 'Unavailable'}
        </span>

        <button
          className="text-button danger"
          type="button"
          onClick={() => onDelete(journal.id)}
          disabled={isDeleting}
          aria-label={`Delete ${journal.title}`}
        >
          {isDeleting ? 'Deleting…' : 'Delete'}
        </button>
      </div>
    </article>
  );
}
