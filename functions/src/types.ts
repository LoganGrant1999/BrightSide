import { Timestamp } from "firebase-admin/firestore";

export interface Article {
  title: string;
  summary: string;
  source_name: string;
  source_url: string;
  image_url?: string;
  metro_id: string;
  status: "published" | "archived";
  publish_time: Timestamp;
  is_featured: boolean;
  featured_start: Timestamp | null;
  featured_end: Timestamp | null;
  like_count_total: number;
  like_count_24h: number;
  hot_score: number;
  created_at: Timestamp;
  updated_at: Timestamp;
}

export interface Submission {
  user_id: string;
  metro_id: string;
  title: string;
  summary: string;
  source_name?: string;
  source_url?: string;
  image_url?: string;
  status: "pending" | "approved" | "rejected";
  moderator_id?: string;
  moderator_note?: string;
  approved_article_id?: string;
  created_at: Timestamp;
  updated_at: Timestamp;
}

export interface ArticleLike {
  user_id: string;
  article_id: string;
  metro_id: string;
  created_at: Timestamp;
}

export interface Metro {
  name: string;
  tz: string;
  lat: number;
  lng: number;
  active: boolean;
}

export interface SystemConfig {
  today_max_articles: number;
  daily_refresh_hour_local: number;
  submission_enabled: boolean;
  reporting_enabled: boolean;
  popular_lookback_hours: number;
}
