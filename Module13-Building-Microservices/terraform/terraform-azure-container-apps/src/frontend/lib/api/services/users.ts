import { apiClient } from '../client';
import { User, UserDto, UpdateProfileRequest } from '../../../types';

export const userService = {
  async getProfile(): Promise<UserDto> {
    const response = await apiClient.get<UserDto>('/api/users/profile');
    return response.data;
  },

  async updateProfile(data: UpdateProfileRequest): Promise<UserDto> {
    const response = await apiClient.put<UserDto>('/api/users/profile', data);
    return response.data;
  },

  // Admin methods
  async getAllUsers(): Promise<User[]> {
    const response = await apiClient.get<User[]>('/api/users');
    return response.data;
  },

  async getUserById(id: number): Promise<User> {
    const response = await apiClient.get<User>(`/api/users/${id}`);
    return response.data;
  },

  async createUser(userData: any): Promise<User> {
    const response = await apiClient.post<User>('/api/users', userData);
    return response.data;
  },

  async updateUser(id: number, userData: any): Promise<User> {
    const response = await apiClient.put<User>(`/api/users/${id}`, userData);
    return response.data;
  },

  async deleteUser(id: number): Promise<void> {
    await apiClient.delete(`/api/users/${id}`);
  },

  async activateUser(id: number): Promise<void> {
    await apiClient.post(`/api/users/${id}/activate`);
  },

  async deactivateUser(id: number): Promise<void> {
    await apiClient.post(`/api/users/${id}/deactivate`);
  },
};