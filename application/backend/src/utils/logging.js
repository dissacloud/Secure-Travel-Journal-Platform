export function sanitizeLogValue(value) {
  return String(value ?? '').replace(/[\r\n]/g, '');
}