import { useCallback, useEffect, useState } from 'react';
import { JournalForm } from './components/JournalForm.jsx';
import { JournalList } from './components/JournalList.jsx';
import {
  createJournal,
  deleteJournal,
  getJournals,
  getServiceReadiness,
} from './services/journal-api.js';

export default function App() {
  const [journals, setJournals] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [deletingId, setDeletingId] = useState(null);
  const [serviceStatus, setServiceStatus] = useState('checking');
  const [message, setMessage] = useState(null);

  const loadApplication = useCallback(async () => {
    setIsLoading(true);
    setMessage(null);

    const [journalsResult, readinessResult] = await Promise.allSettled([
      getJournals(),
      getServiceReadiness(),
    ]);

    if (journalsResult.status === 'fulfilled') {
      setJournals(journalsResult.value);
    } else {
      setMessage({ type: 'error', text: journalsResult.reason.message });
    }

    setServiceStatus(
      readinessResult.status === 'fulfilled' ? 'ready' : 'unavailable',
    );
    setIsLoading(false);
  }, []);

  useEffect(() => {
    loadApplication();
  }, [loadApplication]);

  async function handleCreate(form) {
    setIsSubmitting(true);
    setMessage(null);

    try {
      const created = await createJournal(form);
      setJournals((current) => [created, ...current]);
      setMessage({ type: 'success', text: 'Journal entry saved successfully.' });
      return true;
    } catch (error) {
      setMessage({ type: 'error', text: error.message });
      return false;
    } finally {
      setIsSubmitting(false);
    }
  }

  async function handleDelete(id) {
    const journal = journals.find((entry) => entry.id === id);
    const confirmed = window.confirm(
      `Delete “${journal?.title ?? 'this journal entry'}”?`,
    );

    if (!confirmed) {
      return;
    }

    setDeletingId(id);
    setMessage(null);

    try {
      await deleteJournal(id);
      setJournals((current) => current.filter((entry) => entry.id !== id));
      setMessage({ type: 'success', text: 'Journal entry deleted.' });
    } catch (error) {
      setMessage({ type: 'error', text: error.message });
    } finally {
      setDeletingId(null);
    }
  }

  return (
    <div className="app-shell">
      <header className="hero">
        <nav className="topbar" aria-label="Project identity">
          <a className="brand" href="#top" aria-label="Secure Travel Journal home">
            <span className="brand-mark">STJ</span>
            <span>Secure Travel Journal</span>
          </a>
          <span className={`service-status service-status--${serviceStatus}`}>
            <span className="status-dot" aria-hidden="true" />
            API {serviceStatus}
          </span>
        </nav>

        <div className="hero-content" id="top">
          <p className="eyebrow">Cloud security portfolio workload</p>
          <h1>Record the journey. Secure the delivery.</h1>
          <p className="hero-copy">
            A deliberately compact three-tier application built to demonstrate
            secure CI/CD, software-supply-chain controls and AWS cloud security.
          </p>
          <div className="hero-tags" aria-label="Technology stack">
            <span>React</span>
            <span>Express</span>
            <span>PostgreSQL</span>
            <span>Containers</span>
          </div>
        </div>
      </header>

      <main>
        {message && (
          <div className={`notification notification--${message.type}`} role="status">
            {message.text}
          </div>
        )}

        <div className="content-grid">
          <JournalForm onCreate={handleCreate} isSubmitting={isSubmitting} />

          <section className="panel entries-panel" aria-labelledby="entries-heading">
            <div className="section-heading section-heading--inline">
              <div>
                <p className="eyebrow">Journal archive</p>
                <h2 id="entries-heading">Recorded journeys</h2>
              </div>
              <button className="text-button" type="button" onClick={loadApplication}>
                Refresh
              </button>
            </div>

            {isLoading ? (
              <div className="loading-state" role="status">
                Loading journal entries…
              </div>
            ) : (
              <JournalList
                journals={journals}
                onDelete={handleDelete}
                deletingId={deletingId}
              />
            )}
          </section>
        </div>
      </main>

      <footer>
        <p>
          Portfolio project by dissacloud · Application baseline v0.1.0
        </p>
      </footer>
    </div>
  );
}
