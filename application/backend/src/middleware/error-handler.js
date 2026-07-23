export function notFoundHandler(req, res) {
  return res.status(404).json({
    error: {
      code: 'ROUTE_NOT_FOUND',
      message: 'The requested API route does not exist.',
    },
    requestId: res.locals.requestId,
  });
}

export function errorHandler(error, req, res, next) {
  if (res.headersSent) {
    return next(error);
  }

  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return res.status(400).json({
      error: {
        code: 'INVALID_JSON',
        message: 'The request body contains invalid JSON.',
      },
      requestId: res.locals.requestId,
    });
  }

  const status = Number.isInteger(error.status) ? error.status : 500;
  const isServerError = status >= 500;

  if (isServerError) {
    console.error(`[${res.locals.requestId}] Unhandled request error`, error);
  }

  return res.status(status).json({
    error: {
      code: error.code ?? (isServerError ? 'INTERNAL_SERVER_ERROR' : 'REQUEST_ERROR'),
      message:
        error.publicMessage ??
        (isServerError
          ? 'The service could not complete the request.'
          : error.message),
    },
    requestId: res.locals.requestId,
  });
}
