import { apiClient } from '../client';
import { Category, ProductDto } from '../../../types';

export const categoryService = {
  async getAll(): Promise<Category[]> {
    const response = await apiClient.get<Category[]>('/api/categories');
    return response.data;
  },

  async getById(id: number): Promise<Category> {
    const response = await apiClient.get<Category>(`/api/categories/${id}`);
    return response.data;
  },

  async getProductsByCategory(id: number): Promise<ProductDto[]> {
    const response = await apiClient.get<ProductDto[]>(`/api/categories/${id}/products`);
    return response.data;
  },

  async create(category: Omit<Category, 'id'>): Promise<Category> {
    const response = await apiClient.post<Category>('/api/categories', category);
    return response.data;
  },

  async update(id: number, category: Omit<Category, 'id'>): Promise<Category> {
    const response = await apiClient.put<Category>(`/api/categories/${id}`, category);
    return response.data;
  },

  async delete(id: number): Promise<void> {
    await apiClient.delete(`/api/categories/${id}`);
  },
};