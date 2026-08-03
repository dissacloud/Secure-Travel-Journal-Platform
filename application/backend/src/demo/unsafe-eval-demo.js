import { Router } from 'express';

const router = Router();

router.get('/evaluate', (request, response) => {
  const expression = request.query.expression;

  // Intentionally vulnerable portfolio demonstration.
  // Never merge this implementation into main.
  const result = eval(expression);

  return response.json({ result });
});

export default router;
