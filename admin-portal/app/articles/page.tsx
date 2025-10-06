'use client';

import { useEffect, useState } from 'react';
import { collection, query, where, orderBy, getDocs, Timestamp } from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';
import { db, functions } from '@/lib/firebase';
import { ProtectedRoute } from '@/components/protected-route';
import { Nav } from '@/components/nav';

interface Article {
  id: string;
  title: string;
  summary: string;
  source_name: string;
  source_url: string;
  image_url?: string;
  metro_id: string;
  status: string;
  publish_time: Timestamp;
  is_featured: boolean;
  featured_start?: Timestamp | null;
  featured_end?: Timestamp | null;
  like_count_total: number;
}

export default function ArticlesPage() {
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState<string | null>(null);
  const [selectedMetro, setSelectedMetro] = useState<string>('slc');
  const [showFeaturedOnly, setShowFeaturedOnly] = useState(false);

  useEffect(() => {
    loadArticles();
  }, [selectedMetro, showFeaturedOnly]);

  const loadArticles = async () => {
    setLoading(true);
    try {
      let q = query(
        collection(db, 'articles'),
        where('metro_id', '==', selectedMetro),
        where('status', '==', 'published')
      );

      if (showFeaturedOnly) {
        q = query(
          collection(db, 'articles'),
          where('metro_id', '==', selectedMetro),
          where('status', '==', 'published'),
          where('is_featured', '==', true)
        );
      }

      q = query(q, orderBy('publish_time', 'desc'));

      const snapshot = await getDocs(q);
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as Article[];

      setArticles(data);
    } catch (error) {
      console.error('Error loading articles:', error);
      alert('Failed to load articles');
    } finally {
      setLoading(false);
    }
  };

  const handleFeature = async (articleId: string, feature: boolean) => {
    const action = feature ? 'feature' : 'unfeature';
    if (!confirm(`${action} this article?`)) return;

    setProcessing(articleId);
    try {
      const featureArticleFn = httpsCallable(functions, 'featureArticle');
      await featureArticleFn({
        articleId,
        feature,
        endAt: null, // Manual pin (no end date)
      });

      alert(`Article ${action}d successfully!`);
      await loadArticles();
    } catch (error) {
      console.error(`${action} error:`, error);
      alert(`Failed to ${action}: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing(null);
    }
  };

  const getFeatureStatus = (article: Article) => {
    if (!article.is_featured) return null;

    const isManualPin = article.featured_end === null;
    if (isManualPin) {
      return {
        label: '📌 Manual Pin',
        color: 'bg-purple-100 text-purple-800',
      };
    }

    const now = new Date();
    const endDate = article.featured_end?.toDate();
    if (endDate && endDate > now) {
      return {
        label: '⭐ Auto-Featured',
        color: 'bg-blue-100 text-blue-800',
      };
    }

    return {
      label: '⏰ Expiring Soon',
      color: 'bg-yellow-100 text-yellow-800',
    };
  };

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50">
        <Nav />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="mb-6">
            <h1 className="text-3xl font-bold text-gray-900">Articles</h1>
            <p className="text-gray-600 mt-2">
              Manage featured articles and view published content
            </p>
          </div>

          {/* Filters */}
          <div className="bg-white rounded-lg shadow p-4 mb-6">
            <div className="flex flex-wrap gap-4 items-center">
              <div>
                <label htmlFor="metro" className="block text-sm font-medium text-gray-700 mb-1">
                  Metro
                </label>
                <select
                  id="metro"
                  value={selectedMetro}
                  onChange={(e) => setSelectedMetro(e.target.value)}
                  className="border border-gray-300 rounded-lg px-3 py-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="slc">Salt Lake City</option>
                  <option value="nyc">New York City</option>
                  <option value="gsp">Greenville-Spartanburg</option>
                </select>
              </div>

              <div className="flex items-center mt-6">
                <input
                  type="checkbox"
                  id="featured-only"
                  checked={showFeaturedOnly}
                  onChange={(e) => setShowFeaturedOnly(e.target.checked)}
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                />
                <label htmlFor="featured-only" className="ml-2 text-sm text-gray-700">
                  Show featured only
                </label>
              </div>

              <div className="ml-auto mt-6">
                <button
                  onClick={() => loadArticles()}
                  className="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-300 transition-colors"
                >
                  🔄 Refresh
                </button>
              </div>
            </div>
          </div>

          {loading ? (
            <div className="flex justify-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
          ) : articles.length === 0 ? (
            <div className="text-center py-12 bg-white rounded-lg shadow">
              <p className="text-gray-500">No articles found</p>
            </div>
          ) : (
            <div className="space-y-4">
              {articles.map((article) => {
                const featureStatus = getFeatureStatus(article);

                return (
                  <div key={article.id} className="bg-white rounded-lg shadow p-6">
                    <div className="flex justify-between items-start mb-4">
                      <div className="flex-1">
                        <div className="flex items-start gap-3 mb-2">
                          <h3 className="text-xl font-semibold text-gray-900 flex-1">
                            {article.title}
                          </h3>
                          {featureStatus && (
                            <span
                              className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${featureStatus.color}`}
                            >
                              {featureStatus.label}
                            </span>
                          )}
                        </div>
                        <p className="text-gray-600 mb-3">{article.summary}</p>
                        <div className="flex flex-wrap gap-4 text-sm text-gray-500">
                          <span>📰 {article.source_name}</span>
                          <span>📍 {article.metro_id.toUpperCase()}</span>
                          <span>
                            🕐 {article.publish_time?.toDate().toLocaleDateString()}
                          </span>
                          <span>❤️ {article.like_count_total} likes</span>
                        </div>
                        {article.source_url && (
                          <a
                            href={article.source_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-blue-600 hover:underline text-sm mt-2 inline-block"
                          >
                            View source →
                          </a>
                        )}
                      </div>
                      {article.image_url && (
                        <img
                          src={article.image_url}
                          alt="Article"
                          className="w-32 h-32 object-cover rounded-lg ml-4"
                        />
                      )}
                    </div>

                    {/* Feature controls */}
                    <div className="flex gap-3 mt-4 pt-4 border-t">
                      {article.is_featured ? (
                        <button
                          onClick={() => handleFeature(article.id, false)}
                          disabled={processing === article.id}
                          className="flex-1 bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                        >
                          {processing === article.id ? 'Processing...' : '✕ Unfeature'}
                        </button>
                      ) : (
                        <button
                          onClick={() => handleFeature(article.id, true)}
                          disabled={processing === article.id}
                          className="flex-1 bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                        >
                          {processing === article.id ? 'Processing...' : '📌 Pin as Featured'}
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}
