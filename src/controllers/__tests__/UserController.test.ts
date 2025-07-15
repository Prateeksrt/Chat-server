import request from 'supertest';
import app from '../../index';
import { UserController } from '../UserController';

describe('UserController', () => {
  let userController: UserController;

  beforeEach(() => {
    userController = new UserController();
  });

  describe('getAllUsers', () => {
    it('should return empty array when no users exist', () => {
      const req = {} as any;
      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      } as any;

      userController.getAllUsers(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: [],
        message: 'Users retrieved successfully',
      });
    });
  });

  describe('createUser', () => {
    it('should create a new user successfully', () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
      };

      const req = {
        body: userData,
      } as any;

      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      } as any;

      userController.createUser(req, res);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: expect.objectContaining({
          name: userData.name,
          email: userData.email,
          age: userData.age,
        }),
        message: 'User created successfully',
      });
    });
  });
});

describe('User API Endpoints', () => {
  describe('GET /api/v1/users', () => {
    it('should return empty users array', async () => {
      const response = await request(app).get('/api/v1/users');
      
      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        success: true,
        data: [],
        message: 'Users retrieved successfully',
      });
    });
  });

  describe('POST /api/v1/users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'Jane Doe',
        email: 'jane@example.com',
        age: 25,
      };

      const response = await request(app)
        .post('/api/v1/users')
        .send(userData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        name: userData.name,
        email: userData.email,
        age: userData.age,
      });
      expect(response.body.data.id).toBeDefined();
    });

    it('should return validation error for invalid email', async () => {
      const userData = {
        name: 'Invalid User',
        email: 'invalid-email',
      };

      const response = await request(app)
        .post('/api/v1/users')
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Validation failed');
    });
  });

  describe('GET /api/v1/users/:id', () => {
    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/v1/users/non-existent-id')
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('User not found');
    });
  });
});