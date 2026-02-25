# Stories/Reels API Documentation

## Overview

The Stories module provides TikTok-style vertical video content for sellers to showcase products.

## Endpoints

### Create Story

```http
POST /api/stories
Authorization: Bearer <token>
Content-Type: application/json

{
  "videoUrl": "https://storage.example.com/videos/story.mp4",
  "thumbnailUrl": "https://storage.example.com/thumbnails/story.jpg",
  "description": "Check out this amazing product!",
  "productId": "uuid",
  "duration": 15
}

Response:
{
  "id": "uuid",
  "sellerId": "uuid",
  "videoUrl": "...",
  "thumbnailUrl": "...",
  "description": "...",
  "productId": "uuid",
  "duration": 15,
  "viewsCount": 0,
  "likesCount": 0,
  "sharesCount": 0,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### Get Feed

```http
GET /api/stories/feed?limit=20&offset=0
Authorization: Bearer <token>

Response:
[
  {
    "id": "uuid",
    "seller": {
      "id": "uuid",
      "phone": "+998901234567",
      "sellerProfile": { ... }
    },
    "product": {
      "id": "uuid",
      "name": "Product Name",
      "price": 50000
    },
    "videoUrl": "...",
    "thumbnailUrl": "...",
    "description": "...",
    "viewsCount": 1234,
    "likesCount": 567,
    "isLiked": false,
    "createdAt": "2024-01-01T00:00:00Z"
  }
]
```

### Get Seller Stories

```http
GET /api/stories/seller/:sellerId
Authorization: Bearer <token>
```

### Get My Stories

```http
GET /api/stories/my-stories
Authorization: Bearer <token>
```

### Get Single Story

```http
GET /api/stories/:id
Authorization: Bearer <token>

Response:
{
  "id": "uuid",
  "seller": { ... },
  "product": { ... },
  "videoUrl": "...",
  "isLiked": true,
  ...
}
```

### Record View

```http
POST /api/stories/:id/view
Authorization: Bearer <token>
Content-Type: application/json

{
  "watchDuration": 10
}

Response:
{
  "success": true
}
```

### Toggle Like

```http
POST /api/stories/:id/like
Authorization: Bearer <token>

Response:
{
  "liked": true
}
```

### Delete Story

```http
DELETE /api/stories/:id
Authorization: Bearer <token>

Response:
{
  "success": true
}
```

### Get Statistics

```http
GET /api/stories/stats
Authorization: Bearer <token>

Response:
{
  "totalStories": 10,
  "totalViews": 5000,
  "totalLikes": 1200,
  "avgViewsPerStory": 500,
  "avgLikesPerStory": 120
}
```

## Feed Algorithm

The feed is ordered by:
1. **Recency** - Stories from last 7 days
2. **Engagement** - Sorted by likes and views
3. **Active** - Only active stories

Future improvements:
- Personalized recommendations based on user interests
- Following sellers get priority
- Product category preferences
- Watch time optimization

## Analytics Tracking

### Views
- Counted once per user
- Tracks watch duration
- Used for engagement metrics

### Likes
- Toggle on/off
- Real-time counter updates
- Stored per user

### Engagement Score
```
score = (likesCount * 2) + viewsCount + (avgWatchDuration / duration)
```

## Best Practices

1. **Video Format**
   - Vertical (9:16 aspect ratio)
   - MP4 format
   - Max 60 seconds
   - Recommended: 15-30 seconds

2. **Thumbnails**
   - Auto-generated or custom
   - 1080x1920 resolution
   - JPEG format

3. **Product Linking**
   - Optional but recommended
   - Click to product page
   - Increases conversion

4. **Performance**
   - Videos stored in CDN
   - Lazy loading
   - Preload next 3 stories
