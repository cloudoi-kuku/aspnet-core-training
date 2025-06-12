import { useState, useEffect } from 'react';
import { GetServerSideProps } from 'next';
import Head from 'next/head';
import { ChevronDownIcon, FunnelIcon } from '@heroicons/react/24/outline';
import Layout from '../../components/Layout';
import ProductCard from '../../components/ProductCard';
import { ProductDto, Category } from '../../types';
import { productService, categoryService } from '../../lib/api';

interface ProductsPageProps {
  initialProducts: ProductDto[];
  categories: Category[];
  error?: string;
}

const sortOptions = [
  { name: 'Newest', value: 'newest' },
  { name: 'Price: Low to High', value: 'price-asc' },
  { name: 'Price: High to Low', value: 'price-desc' },
  { name: 'Name: A-Z', value: 'name-asc' },
  { name: 'Name: Z-A', value: 'name-desc' },
];

export default function Products({ initialProducts, categories, error }: ProductsPageProps) {
  const [products, setProducts] = useState(initialProducts);
  const [filteredProducts, setFilteredProducts] = useState(initialProducts);
  const [selectedCategory, setSelectedCategory] = useState<number | null>(null);
  const [sortBy, setSortBy] = useState('newest');
  const [searchTerm, setSearchTerm] = useState('');
  const [priceRange, setPriceRange] = useState({ min: 0, max: 1000 });
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    filterAndSortProducts();
  }, [products, selectedCategory, sortBy, searchTerm, priceRange]);

  const filterAndSortProducts = () => {
    let filtered = [...products];

    // Category filter
    if (selectedCategory) {
      filtered = filtered.filter(p => p.categoryId === selectedCategory);
    }

    // Search filter
    if (searchTerm) {
      filtered = filtered.filter(p =>
        p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Price filter
    filtered = filtered.filter(p => p.price >= priceRange.min && p.price <= priceRange.max);

    // Sorting
    switch (sortBy) {
      case 'price-asc':
        filtered.sort((a, b) => a.price - b.price);
        break;
      case 'price-desc':
        filtered.sort((a, b) => b.price - a.price);
        break;
      case 'name-asc':
        filtered.sort((a, b) => a.name.localeCompare(b.name));
        break;
      case 'name-desc':
        filtered.sort((a, b) => b.name.localeCompare(a.name));
        break;
      default:
        // Newest (assuming products are already sorted by date)
        break;
    }

    setFilteredProducts(filtered);
  };

  if (error) {
    return (
      <Layout>
        <div className="min-h-screen flex items-center justify-center">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-red-600 mb-4">Error Loading Products</h1>
            <p className="text-gray-600">{error}</p>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <Head>
        <title>Products - E-Commerce Platform</title>
        <meta name="description" content="Browse our wide selection of products" />
      </Head>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">All Products</h1>
          <p className="mt-2 text-gray-600">
            Discover {filteredProducts.length} amazing products
          </p>
        </div>

        {/* Mobile filter button */}
        <div className="lg:hidden mb-4">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center space-x-2 btn btn-outline w-full justify-center"
          >
            <FunnelIcon className="h-5 w-5" />
            <span>Filters</span>
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Filters sidebar */}
          <aside className={`lg:col-span-1 ${showFilters ? 'block' : 'hidden lg:block'}`}>
            <div className="bg-white rounded-lg shadow-md p-6 sticky top-24">
              <h2 className="text-lg font-semibold mb-4">Filters</h2>

              {/* Search */}
              <div className="mb-6">
                <label className="form-label">Search</label>
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search products..."
                  className="form-input"
                />
              </div>

              {/* Categories */}
              <div className="mb-6">
                <h3 className="font-medium mb-3">Categories</h3>
                <div className="space-y-2">
                  <label className="flex items-center">
                    <input
                      type="radio"
                      name="category"
                      checked={selectedCategory === null}
                      onChange={() => setSelectedCategory(null)}
                      className="mr-2"
                    />
                    <span>All Categories</span>
                  </label>
                  {categories.map((category) => (
                    <label key={category.id} className="flex items-center">
                      <input
                        type="radio"
                        name="category"
                        checked={selectedCategory === category.id}
                        onChange={() => setSelectedCategory(category.id)}
                        className="mr-2"
                      />
                      <span>{category.name}</span>
                    </label>
                  ))}
                </div>
              </div>

              {/* Price range */}
              <div className="mb-6">
                <h3 className="font-medium mb-3">Price Range</h3>
                <div className="space-y-3">
                  <div>
                    <label className="text-sm text-gray-600">Min Price</label>
                    <input
                      type="number"
                      value={priceRange.min}
                      onChange={(e) => setPriceRange({ ...priceRange, min: Number(e.target.value) })}
                      className="form-input"
                      min="0"
                    />
                  </div>
                  <div>
                    <label className="text-sm text-gray-600">Max Price</label>
                    <input
                      type="number"
                      value={priceRange.max}
                      onChange={(e) => setPriceRange({ ...priceRange, max: Number(e.target.value) })}
                      className="form-input"
                      min="0"
                    />
                  </div>
                </div>
              </div>

              {/* Clear filters */}
              <button
                onClick={() => {
                  setSelectedCategory(null);
                  setSearchTerm('');
                  setPriceRange({ min: 0, max: 1000 });
                  setSortBy('newest');
                }}
                className="w-full btn btn-secondary"
              >
                Clear Filters
              </button>
            </div>
          </aside>

          {/* Products grid */}
          <div className="lg:col-span-3">
            {/* Sort options */}
            <div className="mb-6 flex items-center justify-between">
              <p className="text-sm text-gray-600">
                Showing {filteredProducts.length} results
              </p>
              <div className="relative">
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value)}
                  className="appearance-none bg-white border border-gray-300 rounded-lg px-4 py-2 pr-8 focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  {sortOptions.map((option) => (
                    <option key={option.value} value={option.value}>
                      {option.name}
                    </option>
                  ))}
                </select>
                <ChevronDownIcon className="absolute right-2 top-3 h-4 w-4 pointer-events-none" />
              </div>
            </div>

            {/* Products */}
            {filteredProducts.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-600 text-lg">
                  No products found matching your criteria.
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredProducts.map((product) => (
                  <ProductCard key={product.id} product={product} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
}

export const getServerSideProps: GetServerSideProps = async () => {
  try {
    const [products, categories] = await Promise.all([
      productService.getAll(),
      categoryService.getAll(),
    ]);

    return {
      props: {
        initialProducts: products || [],
        categories: categories || [],
      },
    };
  } catch (error) {
    console.error('Error fetching data:', error);
    
    return {
      props: {
        initialProducts: [],
        categories: [],
        error: 'Failed to load products. Please try again later.',
      },
    };
  }
};