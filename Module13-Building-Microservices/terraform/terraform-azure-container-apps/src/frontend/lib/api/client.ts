import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { AuthResult } from '../../types';

// Determine the API URL based on whether we're on the server or client
const getApiUrl = () => {
  // Server-side: use internal URL if available
  if (typeof window === 'undefined') {
    return process.env.API_BASE_URL || process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5050';
  }
  // Client-side: use public URL
  return process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5050';
};

// Create axios instance with base configuration
const apiClient: AxiosInstance = axios.create({
  baseURL: getApiUrl(),
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Token management
export const tokenManager = {
  getAccessToken: (): string | null => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('access_token');
    }
    return null;
  },
  
  getRefreshToken: (): string | null => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('refresh_token');
    }
    return null;
  },
  
  setTokens: (accessToken: string, refreshToken?: string) => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('access_token', accessToken);
      if (refreshToken) {
        localStorage.setItem('refresh_token', refreshToken);
      }
    }
  },
  
  clearTokens: () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
    }
  },
};

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    if (typeof window !== 'undefined') {
      const token = tokenManager.getAccessToken();
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle token refresh
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = tokenManager.getRefreshToken();
        if (refreshToken) {
          const response = await axios.post<AuthResult>(`${apiClient.defaults.baseURL}/api/auth/refresh`, {
            refreshToken,
          });
          
          if (response.data.success && response.data.token) {
            tokenManager.setTokens(response.data.token, response.data.refreshToken);
            originalRequest.headers.Authorization = `Bearer ${response.data.token}`;
            return apiClient(originalRequest);
          }
        }
      } catch (refreshError) {
        tokenManager.clearTokens();
        if (typeof window !== 'undefined') {
          window.location.href = '/login';
        }
      }
    }
    
    return Promise.reject(error);
  }
);

export { apiClient };