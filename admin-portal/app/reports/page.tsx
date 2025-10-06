'use client';

import { useEffect, useState } from 'react';
import { collection, query, where, orderBy, getDocs, doc, updateDoc, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { ProtectedRoute } from '@/components/protected-route';
import { Nav } from '@/components/nav';

interface Report {
  id: string;
  article_id: string;
  reason: string;
  reported_by_uid: string;
  triage_status: string;
  created_at: Timestamp;
  article_title?: string;
}

export default function ReportsPage() {
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState<string | null>(null);

  useEffect(() => {
    loadReports();
  }, []);

  const loadReports = async () => {
    try {
      const q = query(
        collection(db, 'reports'),
        where('triage_status', 'in', ['new', 'reviewing']),
        orderBy('created_at', 'desc')
      );

      const snapshot = await getDocs(q);
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as Report[];

      setReports(data);
    } catch (error) {
      console.error('Error loading reports:', error);
      alert('Failed to load reports');
    } finally {
      setLoading(false);
    }
  };

  const handleSetStatus = async (reportId: string, newStatus: string) => {
    setProcessing(reportId);
    try {
      const reportRef = doc(db, 'reports', reportId);
      await updateDoc(reportRef, {
        triage_status: newStatus,
      });

      alert(`Report marked as ${newStatus}`);
      await loadReports();
    } catch (error) {
      console.error('Update error:', error);
      alert(`Failed to update: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing(null);
    }
  };

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50">
        <Nav />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="mb-6">
            <h1 className="text-3xl font-bold text-gray-900">Open Reports</h1>
            <p className="text-gray-600 mt-2">
              Review user-reported content for potential policy violations
            </p>
          </div>

          {loading ? (
            <div className="flex justify-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
          ) : reports.length === 0 ? (
            <div className="text-center py-12 bg-white rounded-lg shadow">
              <p className="text-gray-500">No open reports</p>
            </div>
          ) : (
            <div className="space-y-4">
              {reports.map((report) => (
                <div key={report.id} className="bg-white rounded-lg shadow p-6">
                  <div className="mb-4">
                    <div className="flex justify-between items-start mb-2">
                      <span
                        className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
                          report.triage_status === 'new'
                            ? 'bg-yellow-100 text-yellow-800'
                            : 'bg-blue-100 text-blue-800'
                        }`}
                      >
                        {report.triage_status === 'new' ? '🆕 New' : '👁️ Reviewing'}
                      </span>
                      <span className="text-sm text-gray-500">
                        {report.created_at?.toDate().toLocaleString()}
                      </span>
                    </div>

                    <h3 className="text-lg font-semibold text-gray-900 mb-2">
                      Reason: {report.reason}
                    </h3>

                    <div className="text-sm text-gray-600 space-y-1">
                      <p>
                        <span className="font-medium">Article ID:</span>{' '}
                        <a
                          href={`/articles/${report.article_id}`}
                          className="text-blue-600 hover:underline"
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {report.article_id}
                        </a>
                      </p>
                      {report.article_title && (
                        <p>
                          <span className="font-medium">Article:</span> {report.article_title}
                        </p>
                      )}
                      <p>
                        <span className="font-medium">Reported by:</span> {report.reported_by_uid}
                      </p>
                    </div>
                  </div>

                  <div className="flex gap-3 mt-4">
                    {report.triage_status === 'new' && (
                      <button
                        onClick={() => handleSetStatus(report.id, 'reviewing')}
                        disabled={processing === report.id}
                        className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                      >
                        {processing === report.id ? 'Processing...' : '👁️ Start Reviewing'}
                      </button>
                    )}
                    <button
                      onClick={() => handleSetStatus(report.id, 'closed')}
                      disabled={processing === report.id}
                      className="flex-1 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                    >
                      {processing === report.id ? 'Processing...' : '✓ Close Report'}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}
