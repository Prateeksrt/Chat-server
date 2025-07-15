import { Router } from 'express';
import { healthCheck } from '../health';

const router = Router();

router.get('/', healthCheck);

export { router as healthRouter };