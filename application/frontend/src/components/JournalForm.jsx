import { useState } from 'react';

const INITIAL_FORM = {
  title: '',
  location: '',
  travel_date: '',
  description: '',
};

export function JournalForm({ onCreate, isSubmitting }) {
  const [form, setForm] = useState(INITIAL_FORM);

  function updateField(event) {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const wasCreated = await onCreate(form);
    if (wasCreated) {
      setForm(INITIAL_FORM);
    }
  }

  return (
    <section className="panel" aria-labelledby="new-entry-heading">
      <div className="section-heading">
        <p className="eyebrow">New entry</p>
        <h2 id="new-entry-heading">Record a journey</h2>
        <p>Capture the location, date and highlights from your trip.</p>
      </div>

      <form className="journal-form" onSubmit={handleSubmit}>
        <label>
          Title
          <input
            name="title"
            value={form.title}
            onChange={updateField}
            maxLength="120"
            placeholder="Cloud Security Conference"
            required
          />
        </label>

        <div className="form-row">
          <label>
            Location
            <input
              name="location"
              value={form.location}
              onChange={updateField}
              maxLength="120"
              placeholder="London, United Kingdom"
              required
            />
          </label>

          <label>
            Travel date
            <input
              type="date"
              name="travel_date"
              value={form.travel_date}
              onChange={updateField}
              required
            />
          </label>
        </div>

        <label>
          Journal notes
          <textarea
            name="description"
            value={form.description}
            onChange={updateField}
            rows="6"
            maxLength="5000"
            placeholder="What happened, what did you learn, and what made the trip memorable?"
            required
          />
        </label>

        <div className="form-actions">
          <span>{form.description.length}/5,000 characters</span>
          <button className="primary-button" type="submit" disabled={isSubmitting}>
            {isSubmitting ? 'Saving…' : 'Save journal entry'}
          </button>
        </div>
      </form>
    </section>
  );
}
