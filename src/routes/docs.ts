import { Router, Request, Response } from 'express';

const router = Router();

router.get('/', (req: Request, res: Response) => {
  const apiDocs = {
    openapi: '3.0.0',
    info: {
      title: 'TypeScript REST API',
      version: '1.0.0',
      description: 'A modern REST API built with TypeScript and Express.js',
    },
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 3000}/api/v1`,
        description: 'Development server',
      },
    ],
    paths: {
      '/': {
        get: {
          summary: 'API Information',
          description: 'Get API information and available endpoints',
          responses: {
            '200': {
              description: 'Successful response',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      message: { type: 'string' },
                      version: { type: 'string' },
                      endpoints: { type: 'object' },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/users': {
        get: {
          summary: 'Get all users',
          description: 'Retrieve a list of all users',
          responses: {
            '200': {
              description: 'List of users',
              content: {
                'application/json': {
                  schema: {
                    type: 'array',
                    items: {
                      $ref: '#/components/schemas/User',
                    },
                  },
                },
              },
            },
          },
        },
        post: {
          summary: 'Create a new user',
          description: 'Create a new user with the provided data',
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  $ref: '#/components/schemas/CreateUserRequest',
                },
              },
            },
          },
          responses: {
            '201': {
              description: 'User created successfully',
              content: {
                'application/json': {
                  schema: {
                    $ref: '#/components/schemas/User',
                  },
                },
              },
            },
            '400': {
              description: 'Bad request - validation error',
            },
          },
        },
      },
      '/users/{id}': {
        get: {
          summary: 'Get user by ID',
          description: 'Retrieve a specific user by their ID',
          parameters: [
            {
              name: 'id',
              in: 'path',
              required: true,
              schema: {
                type: 'string',
                format: 'uuid',
              },
              description: 'User ID',
            },
          ],
          responses: {
            '200': {
              description: 'User found',
              content: {
                'application/json': {
                  schema: {
                    $ref: '#/components/schemas/User',
                  },
                },
              },
            },
            '404': {
              description: 'User not found',
            },
          },
        },
        put: {
          summary: 'Update user',
          description: 'Update an existing user',
          parameters: [
            {
              name: 'id',
              in: 'path',
              required: true,
              schema: {
                type: 'string',
                format: 'uuid',
              },
              description: 'User ID',
            },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  $ref: '#/components/schemas/UpdateUserRequest',
                },
              },
            },
          },
          responses: {
            '200': {
              description: 'User updated successfully',
              content: {
                'application/json': {
                  schema: {
                    $ref: '#/components/schemas/User',
                  },
                },
              },
            },
            '404': {
              description: 'User not found',
            },
          },
        },
        delete: {
          summary: 'Delete user',
          description: 'Delete a user by their ID',
          parameters: [
            {
              name: 'id',
              in: 'path',
              required: true,
              schema: {
                type: 'string',
                format: 'uuid',
              },
              description: 'User ID',
            },
          ],
          responses: {
            '204': {
              description: 'User deleted successfully',
            },
            '404': {
              description: 'User not found',
            },
          },
        },
      },
    },
    components: {
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              format: 'uuid',
              description: 'Unique user identifier',
            },
            name: {
              type: 'string',
              description: 'User name',
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address',
            },
            age: {
              type: 'integer',
              minimum: 0,
              maximum: 120,
              description: 'User age',
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'User creation timestamp',
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
              description: 'User last update timestamp',
            },
          },
          required: ['id', 'name', 'email', 'createdAt', 'updatedAt'],
        },
        CreateUserRequest: {
          type: 'object',
          properties: {
            name: {
              type: 'string',
              minLength: 2,
              maxLength: 50,
              description: 'User name',
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address',
            },
            age: {
              type: 'integer',
              minimum: 0,
              maximum: 120,
              description: 'User age',
            },
          },
          required: ['name', 'email'],
        },
        UpdateUserRequest: {
          type: 'object',
          properties: {
            name: {
              type: 'string',
              minLength: 2,
              maxLength: 50,
              description: 'User name',
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address',
            },
            age: {
              type: 'integer',
              minimum: 0,
              maximum: 120,
              description: 'User age',
            },
          },
        },
      },
    },
  };

  res.json(apiDocs);
});

export { router as docsRouter };