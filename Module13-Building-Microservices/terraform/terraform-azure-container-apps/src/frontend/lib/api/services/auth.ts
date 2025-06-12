import { apiClient, tokenManager } from '../client';
import { LoginRequest, RegisterRequest, AuthResult } from '../../../types';

export const authService = {
  async login(credentials: LoginRequest): Promise<AuthResult> {
    const response = await apiClient.post<AuthResult>('/api/auth/login', credentials);
    if (response.data.success && response.data.token) {
      tokenManager.setTokens(response.data.token, response.data.refreshToken);
    }
    return response.data;
  },

  async register(data: RegisterRequest): Promise<AuthResult> {
    const response = await apiClient.post<AuthResult>('/api/auth/register', data);
    if (response.data.success && response.data.token) {
      tokenManager.setTokens(response.data.token, response.data.refreshToken);
    }
    return response.data;
  },

  async logout(): Promise<void> {
    try {
      await apiClient.post('/api/auth/logout');
    } finally {
      tokenManager.clearTokens();
    }
  },

  async validateToken(): Promise<boolean> {
    try {
      await apiClient.post('/api/auth/validate');
      return true;
    } catch {
      return false;
    }
  },

  async refreshToken(refreshToken: string): Promise<AuthResult> {
    const response = await apiClient.post<AuthResult>('/api/auth/refresh', { refreshToken });
    if (response.data.success && response.data.token) {
      tokenManager.setTokens(response.data.token, response.data.refreshToken);
    }
    return response.data;
  },

  isAuthenticated(): boolean {
    if (typeof window === 'undefined') {
      return false;
    }
    return !!tokenManager.getAccessToken();
  },
};