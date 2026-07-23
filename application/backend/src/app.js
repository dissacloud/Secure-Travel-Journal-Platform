import { randomUUID } from 'node:crypto';
import express from 'express';
import helmet from 'helmet';
import {
  errorHandler,
  notFoundHandler,
} from './middleware/error-handler.js';
import { healthRouter } from './routes/health.routes.js';
import { journalRouter } from './routes/journal.routes.js';

export function createApp({ db }) {
  if (!db || typeof db.query !== 'function') {
    throw new TypeError('A database client with a query method is required.');
  }

  const app = express();
  app.disable('x-powered-by');
  app.locals.db = db;

  app.use((req, res, next) => {
    const requestId = req.get('x-request-id') || randomUUID();
    res.locals.requestId = requestId;
    res.setHeader('x-request-id', requestId);
    next();
  });

  app.use(helmet());
  app.use(express.json({ limit: '32kb' }));

  app.use('/api/health', healthRouter);
  app.use('/api/journals', journalRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
