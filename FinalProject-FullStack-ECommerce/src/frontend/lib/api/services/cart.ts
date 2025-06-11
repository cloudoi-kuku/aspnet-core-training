import { apiClient } from '../client';
import { CartDto, AddToCartRequest, UpdateCartItemRequest } from '../../../types';

export const cartService = {
  async getCart(): Promise<CartDto> {
    const response = await apiClient.get<CartDto>('/api/cart');
    return response.data;
  },

  async addItem(request: AddToCartRequest): Promise<CartDto> {
    const response = await apiClient.post<CartDto>('/api/cart/items', request);
    return response.data;
  },

  async updateItem(itemId: number, request: UpdateCartItemRequest): Promise<CartDto> {
    const response = await apiClient.put<CartDto>(`/api/cart/items/${itemId}`, request);
    return response.data;
  },

  async removeItem(itemId: number): Promise<CartDto> {
    const response = await apiClient.delete<CartDto>(`/api/cart/items/${itemId}`);
    return response.data;
  },

  async clearCart(): Promise<void> {
    await apiClient.delete('/api/cart');
  },

  async checkout(): Promise<{ orderId: number }> {
    const response = await apiClient.post<{ orderId: number }>('/api/cart/checkout');
    return response.data;
  },
};