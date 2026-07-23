import { JournalCard } from './JournalCard.jsx';

export function JournalList({ journals, onDelete, deletingId }) {
  if (journals.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-state__icon" aria-hidden="true">
          ✦
        </div>
        <h3>No journal entries yet</h3>
        <p>Your first recorded journey will appear here.</p>
      </div>
    );
  }

  return (
    <div className="journal-grid">
      {journals.map((journal) => (
        <JournalCard
          key={journal.id}
          journal={journal}
          onDelete={onDelete}
          isDeleting={deletingId === journal.id}
        />
      ))}
    </div>
  );
}
