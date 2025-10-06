'use client';

import { useEffect, useState } from 'react';
import { collection, query, where, orderBy, getDocs, Timestamp } from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';
import { db, functions } from '@/lib/firebase';
import { ProtectedRoute } from '@/components/protected-route';
import { Nav } from '@/components/nav';

interface Submission {
  id: string;
  title: string;
  desc: string;
  city: string;
  state: string;
  photoUrl?: string;
  submittedByUid: string;
  status: string;
  createdAt: Timestamp;
}

export default function SubmissionsPage() {
  const [submissions, setSubmissions] = useState<Submission[]>([]);
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState<string | null>(null);

  useEffect(() => {
    loadSubmissions();
  }, []);

  const loadSubmissions = async () => {
    try {
      const q = query(
        collection(db, 'submissions'),
        where('status', '==', 'pending'),
        orderBy('createdAt', 'desc')
      );

      const snapshot = await getDocs(q);
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as Submission[];

      setSubmissions(data);
    } catch (error) {
      console.error('Error loading submissions:', error);
      alert('Failed to load submissions');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (submissionId: string) => {
    if (!confirm('Approve this submission and publish as an article?')) return;

    setProcessing(submissionId);
    try {
      const approveSubmission = httpsCallable(functions, 'approveSubmission');
      await approveSubmission({
        submissionId,
        publishNow: true,
      });

      alert('Submission approved!');
      await loadSubmissions();
    } catch (error) {
      console.error('Approval error:', error);
      alert(`Failed to approve: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing(null);
    }
  };

  const handleReject = async (submissionId: string) => {
    const reason = prompt('Enter rejection reason (optional):');
    if (reason === null) return;

    setProcessing(submissionId);
    try {
      const rejectSubmission = httpsCallable(functions, 'rejectSubmission');
      await rejectSubmission({
        submissionId,
        reason: reason || 'No reason provided',
      });

      alert('Submission rejected');
      await loadSubmissions();
    } catch (error) {
      console.error('Rejection error:', error);
      alert(`Failed to reject: ${error instanceof Error ? error.message : 'Unknown error'}`);
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
            <h1 className="text-3xl font-bold text-gray-900">Pending Submissions</h1>
            <p className="text-gray-600 mt-2">
              Review and moderate user-submitted positive news stories
            </p>
          </div>

          {loading ? (
            <div className="flex justify-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
          ) : submissions.length === 0 ? (
            <div className="text-center py-12 bg-white rounded-lg shadow">
              <p className="text-gray-500">No pending submissions</p>
            </div>
          ) : (
            <div className="space-y-4">
              {submissions.map((submission) => (
                <div key={submission.id} className="bg-white rounded-lg shadow p-6">
                  <div className="flex justify-between items-start mb-4">
                    <div className="flex-1">
                      <h3 className="text-xl font-semibold text-gray-900 mb-2">
                        {submission.title}
                      </h3>
                      <p className="text-gray-600 mb-3">{submission.desc}</p>
                      <div className="flex gap-4 text-sm text-gray-500">
                        <span>📍 {submission.city}, {submission.state}</span>
                        <span>
                          🕐{' '}
                          {submission.createdAt?.toDate().toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                    {submission.photoUrl && (
                      <img
                        src={submission.photoUrl}
                        alt="Submission"
                        className="w-32 h-32 object-cover rounded-lg ml-4"
                      />
                    )}
                  </div>

                  <div className="flex gap-3 mt-4">
                    <button
                      onClick={() => handleApprove(submission.id)}
                      disabled={processing === submission.id}
                      className="flex-1 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                    >
                      {processing === submission.id ? 'Processing...' : '✓ Approve'}
                    </button>
                    <button
                      onClick={() => handleReject(submission.id)}
                      disabled={processing === submission.id}
                      className="flex-1 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                    >
                      {processing === submission.id ? 'Processing...' : '✗ Reject'}
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
