function formatDate(value) {
  const date = new Date(`${value}T00:00:00Z`);
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
        <time dateTime={journal.travel_date}>{formatDate(journal.travel_date)}</time>
      </div>

      <h3>{journal.title}</h3>
      <p>{journal.description}</p>

      <div className="journal-card__footer">
        <span className="digest-label">ID {journal.id.slice(0, 8)}</span>
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
