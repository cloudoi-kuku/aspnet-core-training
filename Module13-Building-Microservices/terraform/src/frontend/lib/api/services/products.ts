import { apiClient } from '../client';
import { Product, ProductDto, CreateProductRequest, UpdateProductRequest } from '../../../types';

export const productService = {
  async getAll(): Promise<ProductDto[]> {
    const response = await apiClient.get<ProductDto[]>('/api/products');
    return response.data;
  },

  async getById(id: number): Promise<ProductDto> {
    const response = await apiClient.get<ProductDto>(`/api/products/${id}`);
    return response.data;
  },

  async getByCategory(categoryId: number): Promise<ProductDto[]> {
    const response = await apiClient.get<ProductDto[]>(`/api/products/category/${categoryId}`);
    return response.data;
  },

  async create(product: CreateProductRequest): Promise<ProductDto> {
    const response = await apiClient.post<ProductDto>('/api/products', product);
    return response.data;
  },

  async update(id: number, product: UpdateProductRequest): Promise<ProductDto> {
    const response = await apiClient.put<ProductDto>(`/api/products/${id}`, product);
    return response.data;
  },

  async delete(id: number): Promise<void> {
    await apiClient.delete(`/api/products/${id}`);
  },

  async updateStock(id: number, newStock: number): Promise<void> {
    await apiClient.patch(`/api/products/${id}/stock`, { stock: newStock });
  },

  async search(query: string): Promise<ProductDto[]> {
    const response = await apiClient.get<ProductDto[]>('/api/products', {
      params: { search: query }
    });
    return response.data;
  },
};