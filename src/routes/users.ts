import { Router } from 'express';
import { body, param, validationResult } from 'express-validator';
import { UserController } from '../controllers/UserController';
import { validateRequest } from '../middleware/validateRequest';

const router = Router();
const userController = new UserController();

// Validation rules
const createUserValidation = [
  body('name').isString().trim().isLength({ min: 2, max: 50 }).withMessage('Name must be between 2 and 50 characters'),
  body('email').isEmail().normalizeEmail().withMessage('Must be a valid email'),
  body('age').optional().isInt({ min: 0, max: 120 }).withMessage('Age must be between 0 and 120'),
];

const updateUserValidation = [
  param('id').isUUID().withMessage('Invalid user ID'),
  body('name').optional().isString().trim().isLength({ min: 2, max: 50 }).withMessage('Name must be between 2 and 50 characters'),
  body('email').optional().isEmail().normalizeEmail().withMessage('Must be a valid email'),
  body('age').optional().isInt({ min: 0, max: 120 }).withMessage('Age must be between 0 and 120'),
];

const getUserValidation = [
  param('id').isUUID().withMessage('Invalid user ID'),
];

// Routes
router.get('/', userController.getAllUsers);
router.get('/:id', getUserValidation, validateRequest, userController.getUserById);
router.post('/', createUserValidation, validateRequest, userController.createUser);
router.put('/:id', updateUserValidation, validateRequest, userController.updateUser);
router.delete('/:id', getUserValidation, validateRequest, userController.deleteUser);

export { router as userRouter };