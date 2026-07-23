import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { createApp } from '../src/app.js';

describe('health routes', () => {
  let db;
  let app;

  beforeEach(() => {
    db = { query: vi.fn() };
    app = createApp({ db });
  });

  it('returns liveness without querying the database', async () => {
    const response = await request(app).get('/api/health/live');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      status: 'ok',
      service: 'secure-travel-journal-api',
    });
    expect(db.query).not.toHaveBeenCalled();
  });

  it('returns ready when PostgreSQL is reachable', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ ready: 1 }] });

    const response = await request(app).get('/api/health/ready');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      status: 'ready',
      database: 'connected',
    });
  });

  it('returns 503 when PostgreSQL is unavailable', async () => {
    db.query.mockRejectedValueOnce(new Error('connection refused'));

    const response = await request(app).get('/api/health/ready');

    expect(response.status).toBe(503);
    expect(response.body).toMatchObject({
      status: 'not_ready',
      database: 'unavailable',
    });
  });
});
