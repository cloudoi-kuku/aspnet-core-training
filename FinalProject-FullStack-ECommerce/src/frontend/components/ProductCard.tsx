import Link from 'next/link';
import Image from 'next/image';
import { useState } from 'react';
import { ShoppingCartIcon } from '@heroicons/react/24/outline';
import { StarIcon } from '@heroicons/react/24/solid';
import { ProductDto } from '../types';
import { cartService } from '../lib/api';
import toast from 'react-hot-toast';
import { useRouter } from 'next/router';

interface ProductCardProps {
  product: ProductDto;
}

const ProductCard = ({ product }: ProductCardProps) => {
  const router = useRouter();
  const [isAddingToCart, setIsAddingToCart] = useState(false);
  const [imageError, setImageError] = useState(false);

  const handleAddToCart = async (e: React.MouseEvent) => {
    e.preventDefault(); // Prevent navigation when clicking the button
    setIsAddingToCart(true);

    try {
      await cartService.addItem({
        productId: product.id,
        quantity: 1,
      });
      toast.success('Added to cart!');
    } catch (error: any) {
      if (error.response?.status === 401) {
        toast.error('Please login to add items to cart');
        router.push('/login');
      } else {
        toast.error('Failed to add to cart');
      }
    } finally {
      setIsAddingToCart(false);
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(price);
  };

  // Generate random rating for demo (in real app, this would come from the backend)
  const rating = Math.floor(Math.random() * 2) + 3.5;
  const reviewCount = Math.floor(Math.random() * 100) + 20;

  return (
    <Link href={`/products/${product.id}`}>
      <div className="group bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 cursor-pointer overflow-hidden">
        {/* Image container */}
        <div className="relative h-64 bg-gray-100 overflow-hidden">
          {product.imageUrl && !imageError ? (
            <Image
              src={product.imageUrl}
              alt={product.name}
              fill
              className="object-cover group-hover:scale-110 transition-transform duration-300"
              onError={() => setImageError(true)}
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-gray-100 to-gray-200">
              <svg
                className="w-20 h-20 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </svg>
            </div>
          )}
          
          {/* Stock badge */}
          {product.stock > 0 ? (
            product.stock < 10 && (
              <div className="absolute top-2 left-2 bg-orange-500 text-white px-2 py-1 rounded-md text-xs font-semibold">
                Only {product.stock} left
              </div>
            )
          ) : (
            <div className="absolute top-2 left-2 bg-red-500 text-white px-2 py-1 rounded-md text-xs font-semibold">
              Out of Stock
            </div>
          )}

          {/* Category badge */}
          {product.categoryName && (
            <div className="absolute top-2 right-2 bg-blue-600 text-white px-2 py-1 rounded-md text-xs font-semibold">
              {product.categoryName}
            </div>
          )}
        </div>

        {/* Content */}
        <div className="p-4">
          {/* Product name */}
          <h3 className="text-lg font-semibold text-gray-900 group-hover:text-blue-600 transition-colors line-clamp-1">
            {product.name}
          </h3>

          {/* Rating */}
          <div className="flex items-center mt-2">
            <div className="flex items-center">
              {[...Array(5)].map((_, i) => (
                <StarIcon
                  key={i}
                  className={`h-4 w-4 ${
                    i < Math.floor(rating)
                      ? 'text-yellow-400'
                      : i < rating
                      ? 'text-yellow-400'
                      : 'text-gray-300'
                  }`}
                />
              ))}
            </div>
            <span className="ml-2 text-sm text-gray-600">
              {rating.toFixed(1)} ({reviewCount})
            </span>
          </div>

          {/* Description */}
          <p className="mt-2 text-sm text-gray-600 line-clamp-2">
            {product.description}
          </p>

          {/* Price and action */}
          <div className="mt-4 flex items-center justify-between">
            <div>
              <span className="text-2xl font-bold text-gray-900">
                {formatPrice(product.price)}
              </span>
            </div>

            <button
              onClick={handleAddToCart}
              disabled={!product.isActive || product.stock === 0 || isAddingToCart}
              className={`
                flex items-center space-x-2 px-4 py-2 rounded-lg font-medium transition-all
                ${
                  product.isActive && product.stock > 0
                    ? 'bg-blue-600 text-white hover:bg-blue-700 active:scale-95'
                    : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                }
              `}
            >
              <ShoppingCartIcon className="h-5 w-5" />
              <span>
                {isAddingToCart
                  ? 'Adding...'
                  : product.stock === 0
                  ? 'Out of Stock'
                  : 'Add to Cart'}
              </span>
            </button>
          </div>
        </div>
      </div>
    </Link>
  );
};

export default ProductCard;