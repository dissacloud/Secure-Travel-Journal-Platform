import { Pool } from 'pg';

function parsePositiveInteger(value, fallback) {
  const parsed = Number.parseInt(value, 10);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}

function buildPoolConfig() {
  const sslEnabled = process.env.DB_SSL === 'true';
  const common = {
    max: parsePositiveInteger(process.env.DB_POOL_MAX, 10),
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 5_000,
    ssl: sslEnabled
      ? {
          rejectUnauthorized:
            process.env.DB_SSL_REJECT_UNAUTHORIZED !== 'false',
        }
      : false,
  };

  if (process.env.DATABASE_URL) {
    return {
      ...common,
      connectionString: process.env.DATABASE_URL,
    };
  }

  return {
    ...common,
    host: process.env.DB_HOST ?? 'localhost',
    port: parsePositiveInteger(process.env.DB_PORT, 5432),
    database: process.env.DB_NAME ?? 'travel_journal',
    user: process.env.DB_USER ?? 'travel_journal_app',
    password: process.env.DB_PASSWORD,
  };
}

export const pool = new Pool(buildPoolConfig());

pool.on('error', (error) => {
  console.error('Unexpected idle PostgreSQL client error', error);
});

export async function verifyDatabaseConnection() {
  await pool.query('SELECT 1 AS healthy');
}

export async function closeDatabase() {
  await pool.end();
}
