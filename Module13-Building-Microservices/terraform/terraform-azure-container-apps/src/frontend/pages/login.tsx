import { useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Head from 'next/head';
import { useForm } from 'react-hook-form';
import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline';
import { authService } from '../lib/api';
import { LoginRequest } from '../types';
import toast from 'react-hot-toast';

// Disable static generation for this page
export async function getServerSideProps() {
  return { props: {} };
}

export default function Login() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginRequest>();

  const onSubmit = async (data: LoginRequest) => {
    setIsLoading(true);
    try {
      const result = await authService.login(data);
      if (result.success) {
        toast.success('Login successful!');
        
        // Redirect to the page they were trying to access, or home
        const returnUrl = router.query.returnUrl as string || '/';
        router.push(returnUrl);
      } else {
        toast.error(result.message || 'Login failed');
      }
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'An error occurred during login');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <>
      <Head>
        <title>Login - E-Commerce Platform</title>
        <meta name="description" content="Login to your account" />
      </Head>

      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full">
          {/* Logo and header */}
          <div className="text-center mb-8">
            <Link href="/" className="inline-block">
              <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                E-Commerce
              </h1>
            </Link>
            <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
              Welcome back
            </h2>
            <p className="mt-2 text-sm text-gray-600">
              Don't have an account?{' '}
              <Link href="/register" className="font-medium text-blue-600 hover:text-blue-500">
                Sign up
              </Link>
            </p>
          </div>

          {/* Login form */}
          <div className="bg-white rounded-2xl shadow-xl p-8">
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
              {/* Email field */}
              <div>
                <label htmlFor="email" className="form-label">
                  Email address
                </label>
                <input
                  {...register('email', {
                    required: 'Email is required',
                    pattern: {
                      value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                      message: 'Invalid email address',
                    },
                  })}
                  type="email"
                  autoComplete="email"
                  className={`form-input ${errors.email ? 'border-red-500' : ''}`}
                  placeholder="Enter your email"
                />
                {errors.email && (
                  <p className="form-error">{errors.email.message}</p>
                )}
              </div>

              {/* Password field */}
              <div>
                <label htmlFor="password" className="form-label">
                  Password
                </label>
                <div className="relative">
                  <input
                    {...register('password', {
                      required: 'Password is required',
                      minLength: {
                        value: 6,
                        message: 'Password must be at least 6 characters',
                      },
                    })}
                    type={showPassword ? 'text' : 'password'}
                    autoComplete="current-password"
                    className={`form-input pr-10 ${errors.password ? 'border-red-500' : ''}`}
                    placeholder="Enter your password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  >
                    {showPassword ? (
                      <EyeSlashIcon className="h-5 w-5 text-gray-400" />
                    ) : (
                      <EyeIcon className="h-5 w-5 text-gray-400" />
                    )}
                  </button>
                </div>
                {errors.password && (
                  <p className="form-error">{errors.password.message}</p>
                )}
              </div>

              {/* Remember me and forgot password */}
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    name="remember-me"
                    type="checkbox"
                    className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  />
                  <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-900">
                    Remember me
                  </label>
                </div>

                <div className="text-sm">
                  <Link href="/forgot-password" className="font-medium text-blue-600 hover:text-blue-500">
                    Forgot your password?
                  </Link>
                </div>
              </div>

              {/* Submit button */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full btn btn-primary py-3 text-base"
              >
                {isLoading ? (
                  <div className="flex items-center justify-center">
                    <div className="spinner-sm mr-2" />
                    Signing in...
                  </div>
                ) : (
                  'Sign in'
                )}
              </button>

              {/* Social login */}
              <div className="mt-6">
                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-gray-300" />
                  </div>
                  <div className="relative flex justify-center text-sm">
                    <span className="px-2 bg-white text-gray-500">Or continue with</span>
                  </div>
                </div>

                <div className="mt-6 grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    className="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-lg shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                  >
                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M12.545,10.239v3.821h5.445c-0.712,2.315-2.647,3.972-5.445,3.972c-3.332,0-6.033-2.701-6.033-6.032s2.701-6.032,6.033-6.032c1.498,0,2.866,0.549,3.921,1.453l2.814-2.814C17.503,2.988,15.139,2,12.545,2C7.021,2,2.543,6.477,2.543,12s4.478,10,10.002,10c8.396,0,10.249-7.85,9.426-11.748L12.545,10.239z" />
                    </svg>
                    <span className="ml-2">Google</span>
                  </button>

                  <button
                    type="button"
                    className="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-lg shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                  >
                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M12 2C6.477 2 2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.879V14.89h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.989C18.343 21.129 22 16.99 22 12c0-5.523-4.477-10-10-10z" />
                    </svg>
                    <span className="ml-2">Facebook</span>
                  </button>
                </div>
              </div>
            </form>
          </div>

          {/* Footer links */}
          <div className="mt-8 text-center text-sm text-gray-600">
            <Link href="/terms" className="hover:text-gray-900">
              Terms of Service
            </Link>
            {' · '}
            <Link href="/privacy" className="hover:text-gray-900">
              Privacy Policy
            </Link>
          </div>
        </div>
      </div>
    </>
  );
}