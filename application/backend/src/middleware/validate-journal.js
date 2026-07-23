const UUID_V4_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function isValidCalendarDate(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }

  const [year, month, day] = value.split('-').map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));

  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

function validationResponse(res, details) {
  return res.status(422).json({
    error: {
      code: 'VALIDATION_ERROR',
      message: 'The request contains invalid journal data.',
      details,
    },
    requestId: res.locals.requestId,
  });
}

export function validateJournalId(req, res, next) {
  if (!UUID_V4_PATTERN.test(req.params.id)) {
    return validationResponse(res, [
      { field: 'id', message: 'Journal ID must be a valid UUID v4.' },
    ]);
  }

  return next();
}

export function validateJournalBody(req, res, next) {
  const title = typeof req.body.title === 'string' ? req.body.title.trim() : '';
  const location =
    typeof req.body.location === 'string' ? req.body.location.trim() : '';
  const travelDate =
    typeof req.body.travel_date === 'string'
      ? req.body.travel_date.trim()
      : '';
  const description =
    typeof req.body.description === 'string'
      ? req.body.description.trim()
      : '';

  const details = [];

  if (!title) {
    details.push({ field: 'title', message: 'Title is required.' });
  } else if (title.length > 120) {
    details.push({
      field: 'title',
      message: 'Title must not exceed 120 characters.',
    });
  }

  if (!location) {
    details.push({ field: 'location', message: 'Location is required.' });
  } else if (location.length > 120) {
    details.push({
      field: 'location',
      message: 'Location must not exceed 120 characters.',
    });
  }

  if (!travelDate) {
    details.push({ field: 'travel_date', message: 'Travel date is required.' });
  } else if (!isValidCalendarDate(travelDate)) {
    details.push({
      field: 'travel_date',
      message: 'Travel date must be a valid date in YYYY-MM-DD format.',
    });
  }

  if (!description) {
    details.push({
      field: 'description',
      message: 'Description is required.',
    });
  } else if (description.length > 5000) {
    details.push({
      field: 'description',
      message: 'Description must not exceed 5,000 characters.',
    });
  }

  if (details.length > 0) {
    return validationResponse(res, details);
  }

  req.validatedBody = {
    title,
    location,
    travel_date: travelDate,
    description,
  };

  return next();
}
