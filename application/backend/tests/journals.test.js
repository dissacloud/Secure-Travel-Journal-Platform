import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { createApp } from '../src/app.js';

const JOURNAL_ID = '675917f7-fdb0-4d2c-82ec-fad4491dc93d';
const journal = {
  id: JOURNAL_ID,
  title: 'Security Conference in London',
  location: 'London, United Kingdom',
  travel_date: '2026-07-20',
  description: 'Documented the trip and key cloud-security lessons.',
  created_at: '2026-07-20T09:00:00.000Z',
  updated_at: '2026-07-20T09:00:00.000Z',
};

describe('journal routes', () => {
  let db;
  let app;

  beforeEach(() => {
    db = { query: vi.fn() };
    app = createApp({ db });
  });

  it('lists journal entries', async () => {
    db.query.mockResolvedValueOnce({ rows: [journal], rowCount: 1 });

    const response = await request(app).get('/api/journals');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ data: [journal], count: 1 });
  });

  it('creates a journal using a parameterised query', async () => {
    db.query.mockResolvedValueOnce({ rows: [journal], rowCount: 1 });

    const response = await request(app).post('/api/journals').send({
      title: journal.title,
      location: journal.location,
      travel_date: journal.travel_date,
      description: journal.description,
    });

    expect(response.status).toBe(201);
    expect(response.body.data).toEqual(journal);
    expect(db.query).toHaveBeenCalledTimes(1);

    const [, parameters] = db.query.mock.calls[0];
    expect(parameters).toHaveLength(5);
    expect(parameters.slice(1)).toEqual([
      journal.title,
      journal.location,
      journal.travel_date,
      journal.description,
    ]);
  });

  it('rejects invalid journal data before querying PostgreSQL', async () => {
    const response = await request(app).post('/api/journals').send({
      title: '',
      location: '',
      travel_date: '2026-02-31',
      description: '',
    });

    expect(response.status).toBe(422);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
    expect(response.body.error.details).toHaveLength(4);
    expect(db.query).not.toHaveBeenCalled();
  });

  it('returns 404 when a journal entry does not exist', async () => {
    db.query.mockResolvedValueOnce({ rows: [], rowCount: 0 });

    const response = await request(app).get(`/api/journals/${JOURNAL_ID}`);

    expect(response.status).toBe(404);
    expect(response.body.error.code).toBe('JOURNAL_NOT_FOUND');
  });

  it('deletes an existing journal entry', async () => {
    db.query.mockResolvedValueOnce({ rows: [], rowCount: 1 });

    const response = await request(app).delete(`/api/journals/${JOURNAL_ID}`);

    expect(response.status).toBe(204);
    expect(response.text).toBe('');
  });
});
