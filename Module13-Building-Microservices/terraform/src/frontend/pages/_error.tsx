import { NextPageContext } from 'next';
import Head from 'next/head';
import Link from 'next/link';
import Layout from '../components/Layout';

interface ErrorProps {
  statusCode?: number;
}

function Error({ statusCode }: ErrorProps) {
  return (
    <Layout>
      <Head>
        <title>{statusCode ? `${statusCode} Error` : 'Error'} - E-Commerce Platform</title>
      </Head>
      
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-6xl font-bold text-gray-900 mb-4">
            {statusCode || '404'}
          </h1>
          <p className="text-2xl text-gray-600 mb-8">
            {statusCode === 404
              ? 'Page not found'
              : statusCode === 500
              ? 'Internal server error'
              : 'An error occurred'}
          </p>
          <div className="space-x-4">
            <Link href="/" className="btn btn-primary">
              Go Home
            </Link>
            <button
              onClick={() => window.history.back()}
              className="btn btn-outline"
            >
              Go Back
            </button>
          </div>
        </div>
      </div>
    </Layout>
  );
}

Error.getInitialProps = ({ res, err }: NextPageContext) => {
  const statusCode = res ? res.statusCode : err ? err.statusCode : 404;
  return { statusCode };
};

export default Error;