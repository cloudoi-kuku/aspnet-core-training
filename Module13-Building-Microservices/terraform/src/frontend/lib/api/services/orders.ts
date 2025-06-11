import { apiClient } from '../client';
import { Order, CreateOrderRequest } from '../../../types';

export const orderService = {
  async getMyOrders(): Promise<Order[]> {
    const response = await apiClient.get<Order[]>('/api/orders');
    return response.data;
  },

  async getById(id: number): Promise<Order> {
    const response = await apiClient.get<Order>(`/api/orders/${id}`);
    return response.data;
  },

  async create(request: CreateOrderRequest): Promise<Order> {
    const response = await apiClient.post<Order>('/api/orders', request);
    return response.data;
  },

  async cancel(id: number): Promise<void> {
    await apiClient.post(`/api/orders/${id}/cancel`);
  },

  // Admin methods
  async getAllOrders(): Promise<Order[]> {
    const response = await apiClient.get<Order[]>('/api/orders/admin/all');
    return response.data;
  },

  async updateStatus(id: number, status: string): Promise<void> {
    await apiClient.put(`/api/orders/${id}/status`, { status });
  },
};