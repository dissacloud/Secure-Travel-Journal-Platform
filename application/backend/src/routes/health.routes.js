import { Router } from 'express';

export const healthRouter = Router();

healthRouter.get('/live', (req, res) => {
  return res.status(200).json({
    status: 'ok',
    service: 'secure-travel-journal-api',
    timestamp: new Date().toISOString(),
  });
});

healthRouter.get('/ready', async (req, res) => {
  try {
    await req.app.locals.db.query('SELECT 1 AS ready');

    return res.status(200).json({
      status: 'ready',
      database: 'connected',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error(
      `[${res.locals.requestId}] Database readiness check failed`,
      error.message,
    );

    return res.status(503).json({
      status: 'not_ready',
      database: 'unavailable',
      requestId: res.locals.requestId,
    });
  }
});
