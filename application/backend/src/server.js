import 'dotenv/config';
import { createApp } from './app.js';
import {
  closeDatabase,
  pool,
  verifyDatabaseConnection,
} from './config/database.js';

function positiveInteger(value, fallback) {
  const parsed = Number.parseInt(value, 10);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}

const port = positiveInteger(process.env.PORT, 5000);
const startupRetries = positiveInteger(process.env.DB_STARTUP_RETRIES, 10);
const retryDelayMs = positiveInteger(
  process.env.DB_STARTUP_RETRY_DELAY_MS,
  1000,
);

function delay(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function waitForDatabase() {
  for (let attempt = 1; attempt <= startupRetries; attempt += 1) {
    try {
      await verifyDatabaseConnection();
      console.log('Database connection established.');
      return;
    } catch (error) {
      if (attempt === startupRetries) {
        throw error;
      }

      console.warn(
        `Database unavailable; retrying (${attempt}/${startupRetries})...`,
      );
      await delay(retryDelayMs);
    }
  }
}

async function startServer() {
  await waitForDatabase();

  const app = createApp({ db: pool });
  const server = app.listen(port, '0.0.0.0', () => {
    console.log(`Secure Travel Journal API listening on port ${port}.`);
  });

  let shuttingDown = false;

  async function shutdown(signal) {
    if (shuttingDown) {
      return;
    }

    shuttingDown = true;
    console.log(`${signal} received; shutting down gracefully.`);

    const forceExitTimer = setTimeout(() => {
      console.error('Graceful shutdown timed out; forcing exit.');
      process.exit(1);
    }, 10_000);
    forceExitTimer.unref();

    server.close(async (serverError) => {
      try {
        await closeDatabase();
      } catch (databaseError) {
        console.error('Failed to close the database pool.', databaseError);
      }

      clearTimeout(forceExitTimer);
      process.exit(serverError ? 1 : 0);
    });
  }

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

startServer().catch(async (error) => {
  console.error('API startup failed.', error);
  try {
    await closeDatabase();
  } finally {
    process.exit(1);
  }
});
