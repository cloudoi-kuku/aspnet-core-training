import { useState } from 'react';
import { GetServerSideProps } from 'next';
import Head from 'next/head';
import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/router';
import { StarIcon, ShoppingCartIcon, HeartIcon } from '@heroicons/react/24/solid';
import { ChevronLeftIcon } from '@heroicons/react/24/outline';
import Layout from '../../components/Layout';
import ProductCard from '../../components/ProductCard';
import { ProductDto } from '../../types';
import { productService, cartService } from '../../lib/api';
import toast from 'react-hot-toast';

interface ProductDetailProps {
  product: ProductDto;
  relatedProducts: ProductDto[];
  error?: string;
}

export default function ProductDetail({ product, relatedProducts, error }: ProductDetailProps) {
  const router = useRouter();
  const [quantity, setQuantity] = useState(1);
  const [isAddingToCart, setIsAddingToCart] = useState(false);
  const [imageError, setImageError] = useState(false);
  const [selectedTab, setSelectedTab] = useState('description');

  if (error || !product) {
    return (
      <Layout>
        <div className="min-h-screen flex items-center justify-center">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-red-600 mb-4">Product Not Found</h1>
            <p className="text-gray-600 mb-4">{error || 'The product you are looking for does not exist.'}</p>
            <Link href="/products" className="btn btn-primary">
              Back to Products
            </Link>
          </div>
        </div>
      </Layout>
    );
  }

  const handleAddToCart = async () => {
    setIsAddingToCart(true);
    try {
      await cartService.addItem({
        productId: product.id,
        quantity: quantity,
      });
      toast.success(`Added ${quantity} ${quantity === 1 ? 'item' : 'items'} to cart!`);
    } catch (error: any) {
      if (error.response?.status === 401) {
        toast.error('Please login to add items to cart');
        router.push('/login?returnUrl=' + router.asPath);
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

  // Generate random rating for demo
  const rating = 4.5;
  const reviewCount = 128;

  return (
    <Layout>
      <Head>
        <title>{product.name} - E-Commerce Platform</title>
        <meta name="description" content={product.description} />
      </Head>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <nav className="flex items-center space-x-2 text-sm text-gray-600 mb-8">
          <Link href="/" className="hover:text-gray-900">Home</Link>
          <span>/</span>
          <Link href="/products" className="hover:text-gray-900">Products</Link>
          <span>/</span>
          {product.categoryName && (
            <>
              <Link href={`/categories/${product.categoryId}`} className="hover:text-gray-900">
                {product.categoryName}
              </Link>
              <span>/</span>
            </>
          )}
          <span className="text-gray-900">{product.name}</span>
        </nav>

        {/* Product details */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 mb-16">
          {/* Product image */}
          <div className="relative aspect-square bg-gray-100 rounded-lg overflow-hidden">
            {product.imageUrl && !imageError ? (
              <Image
                src={product.imageUrl}
                alt={product.name}
                fill
                className="object-cover"
                onError={() => setImageError(true)}
                priority
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <svg
                  className="w-32 h-32 text-gray-400"
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
          </div>

          {/* Product info */}
          <div>
            <div className="mb-4">
              {product.categoryName && (
                <p className="text-sm text-blue-600 font-medium mb-2">{product.categoryName}</p>
              )}
              <h1 className="text-3xl font-bold text-gray-900">{product.name}</h1>
            </div>

            {/* Rating */}
            <div className="flex items-center mb-6">
              <div className="flex items-center">
                {[...Array(5)].map((_, i) => (
                  <StarIcon
                    key={i}
                    className={`h-5 w-5 ${
                      i < Math.floor(rating)
                        ? 'text-yellow-400'
                        : i < rating
                        ? 'text-yellow-400'
                        : 'text-gray-300'
                    }`}
                  />
                ))}
              </div>
              <span className="ml-2 text-gray-600">
                {rating} ({reviewCount} reviews)
              </span>
            </div>

            {/* Price */}
            <div className="mb-6">
              <p className="text-3xl font-bold text-gray-900">{formatPrice(product.price)}</p>
              {product.stock > 0 ? (
                <p className="text-green-600 mt-2">
                  ✓ In Stock ({product.stock} available)
                </p>
              ) : (
                <p className="text-red-600 mt-2">Out of Stock</p>
              )}
            </div>

            {/* Add to cart */}
            <div className="mb-8">
              <div className="flex items-center space-x-4 mb-4">
                <label className="text-gray-700">Quantity:</label>
                <div className="flex items-center border border-gray-300 rounded-lg">
                  <button
                    onClick={() => setQuantity(Math.max(1, quantity - 1))}
                    className="px-3 py-2 hover:bg-gray-100"
                  >
                    -
                  </button>
                  <input
                    type="number"
                    value={quantity}
                    onChange={(e) => setQuantity(Math.max(1, parseInt(e.target.value) || 1))}
                    className="w-16 text-center border-x border-gray-300 py-2"
                    min="1"
                    max={product.stock}
                  />
                  <button
                    onClick={() => setQuantity(Math.min(product.stock, quantity + 1))}
                    className="px-3 py-2 hover:bg-gray-100"
                  >
                    +
                  </button>
                </div>
              </div>

              <div className="flex space-x-4">
                <button
                  onClick={handleAddToCart}
                  disabled={!product.isActive || product.stock === 0 || isAddingToCart}
                  className="flex-1 btn btn-primary py-3 flex items-center justify-center space-x-2"
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
                <button className="p-3 border border-gray-300 rounded-lg hover:bg-gray-50">
                  <HeartIcon className="h-6 w-6 text-gray-400" />
                </button>
              </div>
            </div>

            {/* Product features */}
            <div className="border-t pt-6">
              <h3 className="font-semibold mb-3">Key Features</h3>
              <ul className="space-y-2 text-gray-600">
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  Free shipping on orders over $100
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  30-day return policy
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  1-year manufacturer warranty
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="mb-16">
          <div className="border-b">
            <nav className="flex space-x-8">
              <button
                onClick={() => setSelectedTab('description')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  selectedTab === 'description'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Description
              </button>
              <button
                onClick={() => setSelectedTab('specifications')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  selectedTab === 'specifications'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Specifications
              </button>
              <button
                onClick={() => setSelectedTab('reviews')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  selectedTab === 'reviews'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Reviews ({reviewCount})
              </button>
            </nav>
          </div>

          <div className="py-8">
            {selectedTab === 'description' && (
              <div className="prose max-w-none">
                <p className="text-gray-600">{product.description}</p>
              </div>
            )}
            {selectedTab === 'specifications' && (
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <h4 className="font-medium text-gray-900">Product ID</h4>
                    <p className="text-gray-600">#{product.id}</p>
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-900">Category</h4>
                    <p className="text-gray-600">{product.categoryName || 'Uncategorized'}</p>
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-900">Stock</h4>
                    <p className="text-gray-600">{product.stock} units</p>
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-900">Status</h4>
                    <p className="text-gray-600">{product.isActive ? 'Active' : 'Inactive'}</p>
                  </div>
                </div>
              </div>
            )}
            {selectedTab === 'reviews' && (
              <div className="text-center py-8">
                <p className="text-gray-600">No reviews yet. Be the first to review this product!</p>
              </div>
            )}
          </div>
        </div>

        {/* Related products */}
        {relatedProducts.length > 0 && (
          <div>
            <h2 className="text-2xl font-bold text-gray-900 mb-8">Related Products</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {relatedProducts.slice(0, 4).map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}

export const getServerSideProps: GetServerSideProps = async ({ params }) => {
  const id = params?.id as string;
  
  try {
    const productId = parseInt(id);
    if (isNaN(productId)) {
      return { props: { error: 'Invalid product ID' } };
    }

    const product = await productService.getById(productId);
    
    // Get related products from the same category
    let relatedProducts: ProductDto[] = [];
    if (product.categoryId) {
      const categoryProducts = await productService.getByCategory(product.categoryId);
      relatedProducts = categoryProducts.filter(p => p.id !== product.id);
    }

    return {
      props: {
        product,
        relatedProducts,
      },
    };
  } catch (error) {
    console.error('Error fetching product:', error);
    
    return {
      props: {
        product: null,
        relatedProducts: [],
        error: 'Failed to load product details',
      },
    };
  }
};