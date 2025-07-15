import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { User, CreateUserRequest, UpdateUserRequest, UserResponse } from '../types/user';

export class UserController {
  private users: User[] = [];

  public getAllUsers = (req: Request, res: Response): void => {
    try {
      const response: UserResponse = {
        success: true,
        data: this.users,
        message: 'Users retrieved successfully',
      };
      res.status(200).json(response);
    } catch (error) {
      const response: UserResponse = {
        success: false,
        error: 'Failed to retrieve users',
      };
      res.status(500).json(response);
    }
  };

  public getUserById = (req: Request, res: Response): void => {
    try {
      const { id } = req.params;
      const user = this.users.find((u) => u.id === id);

      if (!user) {
        const response: UserResponse = {
          success: false,
          error: 'User not found',
        };
        res.status(404).json(response);
        return;
      }

      const response: UserResponse = {
        success: true,
        data: user,
        message: 'User retrieved successfully',
      };
      res.status(200).json(response);
    } catch (error) {
      const response: UserResponse = {
        success: false,
        error: 'Failed to retrieve user',
      };
      res.status(500).json(response);
    }
  };

  public createUser = (req: Request, res: Response): void => {
    try {
      const userData: CreateUserRequest = req.body;
      const now = new Date();

      const newUser: User = {
        id: uuidv4(),
        name: userData.name,
        email: userData.email,
        age: userData.age,
        createdAt: now,
        updatedAt: now,
      };

      this.users.push(newUser);

      const response: UserResponse = {
        success: true,
        data: newUser,
        message: 'User created successfully',
      };
      res.status(201).json(response);
    } catch (error) {
      const response: UserResponse = {
        success: false,
        error: 'Failed to create user',
      };
      res.status(500).json(response);
    }
  };

  public updateUser = (req: Request, res: Response): void => {
    try {
      const { id } = req.params;
      const updateData: UpdateUserRequest = req.body;

      const userIndex = this.users.findIndex((u) => u.id === id);

      if (userIndex === -1) {
        const response: UserResponse = {
          success: false,
          error: 'User not found',
        };
        res.status(404).json(response);
        return;
      }

      const updatedUser: User = {
        ...this.users[userIndex],
        ...updateData,
        updatedAt: new Date(),
      };

      this.users[userIndex] = updatedUser;

      const response: UserResponse = {
        success: true,
        data: updatedUser,
        message: 'User updated successfully',
      };
      res.status(200).json(response);
    } catch (error) {
      const response: UserResponse = {
        success: false,
        error: 'Failed to update user',
      };
      res.status(500).json(response);
    }
  };

  public deleteUser = (req: Request, res: Response): void => {
    try {
      const { id } = req.params;
      const userIndex = this.users.findIndex((u) => u.id === id);

      if (userIndex === -1) {
        const response: UserResponse = {
          success: false,
          error: 'User not found',
        };
        res.status(404).json(response);
        return;
      }

      this.users.splice(userIndex, 1);

      const response: UserResponse = {
        success: true,
        message: 'User deleted successfully',
      };
      res.status(204).json(response);
    } catch (error) {
      const response: UserResponse = {
        success: false,
        error: 'Failed to delete user',
      };
      res.status(500).json(response);
    }
  };
}