import { Router } from 'express';
import {
  createJournal,
  deleteJournal,
  getJournal,
  listJournals,
} from '../controllers/journal.controller.js';
import {
  validateJournalBody,
  validateJournalId,
} from '../middleware/validate-journal.js';

export const journalRouter = Router();

journalRouter.get('/', listJournals);
journalRouter.get('/:id', validateJournalId, getJournal);
journalRouter.post('/', validateJournalBody, createJournal);
journalRouter.delete('/:id', validateJournalId, deleteJournal);
