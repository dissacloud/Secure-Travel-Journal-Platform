import { randomUUID } from 'node:crypto';

const JOURNAL_COLUMNS = `
  id,
  title,
  location,
  travel_date,
  description,
  created_at,
  updated_at
`;

export async function listJournals(req, res, next) {
  try {
    const result = await req.app.locals.db.query(`
      SELECT ${JOURNAL_COLUMNS}
      FROM journal_entries
      ORDER BY travel_date DESC, created_at DESC
    `);

    return res.status(200).json({
      data: result.rows,
      count: result.rowCount,
    });
  } catch (error) {
    return next(error);
  }
}

export async function getJournal(req, res, next) {
  try {
    const result = await req.app.locals.db.query(
      `
        SELECT ${JOURNAL_COLUMNS}
        FROM journal_entries
        WHERE id = $1
      `,
      [req.params.id],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: {
          code: 'JOURNAL_NOT_FOUND',
          message: 'The requested journal entry was not found.',
        },
        requestId: res.locals.requestId,
      });
    }

    return res.status(200).json({ data: result.rows[0] });
  } catch (error) {
    return next(error);
  }
}

export async function createJournal(req, res, next) {
  try {
    const id = randomUUID();
    const { title, location, travel_date: travelDate, description } =
      req.validatedBody;

    const result = await req.app.locals.db.query(
      `
        INSERT INTO journal_entries (
          id,
          title,
          location,
          travel_date,
          description
        )
        VALUES ($1, $2, $3, $4, $5)
        RETURNING ${JOURNAL_COLUMNS}
      `,
      [id, title, location, travelDate, description],
    );

    return res.status(201).json({ data: result.rows[0] });
  } catch (error) {
    return next(error);
  }
}

export async function deleteJournal(req, res, next) {
  try {
    const result = await req.app.locals.db.query(
      'DELETE FROM journal_entries WHERE id = $1',
      [req.params.id],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: {
          code: 'JOURNAL_NOT_FOUND',
          message: 'The requested journal entry was not found.',
        },
        requestId: res.locals.requestId,
      });
    }

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}
