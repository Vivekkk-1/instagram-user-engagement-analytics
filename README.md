# Instagram User Engagement & Analytics

## 📊 Project Overview

This project analyzes an Instagram-style social media dataset using MySQL to understand user activity, engagement behavior, content performance, follower relationships, and hashtag trends.

The objective is to transform raw social media data into meaningful insights that can support content personalization, user engagement, retention, and marketing strategies.

---

## 🎯 Business Problem

Social media platforms generate large volumes of user interaction data through posts, likes, comments, follows, and hashtags.

The key business questions addressed in this project are:

- Which users are most active and engaged?
- How does user activity vary across the platform?
- Which users have low or no engagement?
- What is the relationship between posts, likes, and comments?
- Which hashtags are associated with higher engagement?
- What follower and following patterns exist?
- Which users can be considered for re-engagement or personalized content?
- How can user behavior be used to improve content and marketing strategies?

---

## 🗂️ Dataset

The database contains **100 users** and the following tables:

| Table | Description |
|---|---|
| `users` | User information and account creation dates |
| `photos` | Posts/photos uploaded by users |
| `comments` | Comments made on posts |
| `likes` | Likes given to posts |
| `follows` | Follower and following relationships |
| `tags` | Available hashtags |
| `photo_tags` | Relationship between photos and hashtags |

### Database Structure

```text
users
  │
  ├── photos
  │     ├── likes
  │     ├── comments
  │     └── photo_tags ─── tags
  │
  └── follows
