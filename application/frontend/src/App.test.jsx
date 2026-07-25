import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import App from './App.jsx';
import {
  createJournal,
  getJournals,
  getServiceReadiness,
} from './services/journal-api.js';

vi.mock('./services/journal-api.js', () => ({
  getJournals: vi.fn(),
  getServiceReadiness: vi.fn(),
  createJournal: vi.fn(),
  deleteJournal: vi.fn(),
}));

const createdJournal = {
  id: '675917f7-fdb0-4d2c-82ec-fad4491dc93d',
  title: 'Cloud Security Conference',
  location: 'London, United Kingdom',
  travel_date: '2026-07-20',
  description: 'A practical journey through secure software delivery.',
};

describe('App', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    getJournals.mockResolvedValue([]);
    getServiceReadiness.mockResolvedValue({ status: 'ready' });
    window.confirm = vi.fn(() => true);
  });

  it('renders the empty journal state', async () => {
    render(<App />);

    expect(await screen.findByText('No journal entries yet')).toBeInTheDocument();
    expect(screen.getByText('API ready')).toBeInTheDocument();
  });

  it('creates and displays a journal entry', async () => {
    createJournal.mockResolvedValue(createdJournal);
    render(<App />);

    await screen.findByText('No journal entries yet');

    fireEvent.change(screen.getByLabelText('Title'), {
      target: { value: createdJournal.title },
    });
    fireEvent.change(screen.getByLabelText('Location'), {
      target: { value: createdJournal.location },
    });
    fireEvent.change(screen.getByLabelText('Travel date'), {
      target: { value: createdJournal.travel_date },
    });
    fireEvent.change(screen.getByLabelText('Journal notes'), {
      target: { value: createdJournal.description },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Save journal entry' }));

    expect(await screen.findByText(createdJournal.title)).toBeInTheDocument();
    expect(createJournal).toHaveBeenCalledWith({
      title: createdJournal.title,
      location: createdJournal.location,
      travel_date: createdJournal.travel_date,
      description: createdJournal.description,
    });
  });

  it('shows an API error without crashing the interface', async () => {
    getJournals.mockRejectedValue(new Error('The application could not reach the API.'));
    render(<App />);

    await waitFor(() => {
      expect(
        screen.getByText('The application could not reach the API.'),
      ).toBeInTheDocument();
    });
  });
});
