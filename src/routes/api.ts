import { Router } from 'express';
import { userRouter } from './users';
import { docsRouter } from './docs';

const router = Router();

// API documentation
router.use('/docs', docsRouter);

// User routes
router.use('/users', userRouter);

// API info endpoint
router.get('/', (req, res) => {
  res.json({
    message: 'Welcome to the TypeScript REST API',
    version: '1.0.0',
    endpoints: {
      docs: '/api/v1/docs',
      users: '/api/v1/users',
      health: '/health',
    },
  });
});

export { router as apiRouter };