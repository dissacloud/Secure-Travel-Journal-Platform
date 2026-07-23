const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? '/api';
const REQUEST_TIMEOUT_MS = 10_000;

export class ApiError extends Error {
  constructor(message, { status = 0, code = 'API_ERROR', details = [] } = {}) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

async function request(path, options = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(`${API_BASE_URL}${path}`, {
      ...options,
      signal: controller.signal,
      headers: {
        Accept: 'application/json',
        ...(options.body ? { 'Content-Type': 'application/json' } : {}),
        ...options.headers,
      },
    });

    if (response.status === 204) {
      return null;
    }

    const payload = await response.json().catch(() => ({}));

    if (!response.ok) {
      throw new ApiError(
        payload.error?.message ?? `API request failed with status ${response.status}.`,
        {
          status: response.status,
          code: payload.error?.code,
          details: payload.error?.details,
        },
      );
    }

    return payload;
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new ApiError('The API request timed out.', {
        code: 'REQUEST_TIMEOUT',
      });
    }

    if (error instanceof ApiError) {
      throw error;
    }

    throw new ApiError('The application could not reach the API.', {
      code: 'NETWORK_ERROR',
    });
  } finally {
    clearTimeout(timeout);
  }
}

export async function getJournals() {
  const response = await request('/journals');
  return response.data;
}

export async function createJournal(journal) {
  const response = await request('/journals', {
    method: 'POST',
    body: JSON.stringify(journal),
  });
  return response.data;
}

export async function deleteJournal(id) {
  await request(`/journals/${id}`, { method: 'DELETE' });
}

export async function getServiceReadiness() {
  return request('/health/ready');
}
