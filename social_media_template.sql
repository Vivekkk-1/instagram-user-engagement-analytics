/* =====================================================================
   SOCIAL MEDIA (IG CLONE) — STUDENT ANSWER TEMPLATE
   ===================================================================== */

USE ig_clone;


/* =====================================================================
   OBJECTIVE QUESTIONS
   ===================================================================== */

-- O1
-- Are there any tables with duplicate or missing null values? If so, how
-- would you handle them?
-- check user table is null or not
SELECT *
FROM users
WHERE id IS NULL OR username IS NULL OR created_at IS NULL;

-- check photos table is null or not
SELECT *
FROM photos
WHERE id IS NULL OR image_url IS NULL OR user_id IS NULL OR created_dat IS NULL;

-- There are no NULL values in the tables. The required columns have appropriate constraints, and the foreign key columns correctly reference the primary keys of the related tables.
-- FOR DUPLICATION CHECK
-- USER TABLE
SELECT username, COUNT(*) AS cnt
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

-- FOR PHOTOS TABLE
SELECT image_url, COUNT(*) AS cnt
FROM photos
GROUP BY image_url
HAVING COUNT(*) > 1;

-- FOR COMMENTS TABLE
SELECT user_id, photo_id, comment_text, COUNT(*) AS cnt
FROM comments
GROUP BY user_id, photo_id, comment_text
HAVING COUNT(*) > 1;

-- FOR FOLLOWS TABLE
SELECT
FOLLOWER_ID,FOLLOWEE_ID,COUNT(*) AS CNT
FROM FOLLOWS
GROUP BY FOLLOWER_ID,FOLLOWEE_ID
HAVING COUNT(*)>1;
-- IF TABLE CONTAINS DUPPLICATE VALUES THEN WE SHOULD REMOVE THEM OR IF CONTAINS NULL VALUES THEN WE SHOULD IMPUTE THEM

-- O2
-- What is the distribution of user activity levels (e.g., number of posts,
-- likes, comments) across the user base?

SELECT
    u.id,
    u.username,
    COALESCE(p.no_of_posts, 0) AS no_of_posts,
    COALESCE(l.no_of_likes, 0) AS no_of_likes,
    COALESCE(c.no_of_comments, 0) AS no_of_comments
FROM users u

LEFT JOIN (
    SELECT user_id, COUNT(*) AS no_of_posts
    FROM photos
    GROUP BY user_id
) p
ON u.id = p.user_id

LEFT JOIN (
    SELECT user_id, COUNT(*) AS no_of_likes
    FROM likes
    GROUP BY user_id
) l
ON u.id = l.user_id

LEFT JOIN (
    SELECT user_id, COUNT(*) AS no_of_comments
    FROM comments
    GROUP BY user_id
) c
ON u.id = c.user_id;

-- O3
-- Calculate the average number of tags per post (photo_tags and photos
-- tables).
-- IF THE QUESTION IS TAG PER PHOTO THEN
 
WITH TEMP AS (SELECT
P.ID,COALESCE(A.CNT,0) AS CNT
FROM photos P
LEFT JOIN (SELECT
PHOTO_ID,COUNT(TAG_ID) AS CNT
FROM photo_tags
GROUP BY PHOTO_ID
ORDER BY PHOTO_ID) A ON P.ID=A.PHOTO_ID)

SELECT
AVG(CNT)
FROM TEMP;

-- IF THE QUESTION IS ONLY TAG PHOTO THEN
WITH TEMP AS (SELECT
P.ID,COALESCE(A.CNT,0) AS CNT
FROM photos P
JOIN (SELECT
PHOTO_ID,COUNT(TAG_ID) AS CNT
FROM photo_tags
GROUP BY PHOTO_ID
ORDER BY PHOTO_ID) A ON P.ID=A.PHOTO_ID)

SELECT
AVG(CNT)
FROM TEMP;
-- O4
-- Identify the top users with the highest engagement rates (likes, comments)
-- on their posts and rank them.
WITH engagement AS (
    SELECT
        p.user_id,
        p.id AS photo_id,
        COALESCE(l.likes_count, 0) AS likes_count,
        COALESCE(c.comments_count, 0) AS comments_count
    FROM photos p
    JOIN (
        SELECT
            photo_id,
            COUNT(*) AS likes_count
        FROM likes
        GROUP BY photo_id
    ) l
        ON p.id = l.photo_id
    JOIN (
        SELECT
            photo_id,
            COUNT(*) AS comments_count
        FROM comments
        GROUP BY photo_id
    ) c
        ON p.id = c.photo_id
)

SELECT
    user_id,
    SUM(likes_count + comments_count) AS Total,
    RANK() OVER (
        ORDER BY SUM(likes_count + comments_count) DESC
    ) AS rnk
FROM engagement
GROUP BY user_id
ORDER BY rnk;


-- O5
-- Which users have the highest number of followers and followings?
SELECT
U.ID,U.USERNAME,COALESCE(F.FOLLOWER_CNT,0) AS FOLLOWERS,COALESCE(F1.FOLLOWING_CNT,0) AS FOLLOWING
FROM users U
LEFT JOIN (SELECT
followee_id,COUNT(*) AS FOLLOWER_CNT
FROM follows
GROUP BY followee_id)F ON U.ID=F.followee_id
LEFT JOIN (SELECT
follower_id,COUNT(*) AS FOLLOWING_CNT
FROM follows
GROUP BY follower_id) F1 ON F1.follower_id=U.ID
ORDER BY FOLLOWERS DESC,FOLLOWING DESC;


-- O6
-- Calculate the average engagement rate (likes, comments) per post for each
-- user.
WITH TEMP AS (SELECT
USER_ID,IMAGE_URL,COALESCE(L.LIKES,0) AS LIKES,COALESCE(C.COMMENTS,0) AS COMMENTS
FROM photos P
LEFT JOIN (SELECT
PHOTO_ID,COUNT(USER_ID) AS LIKES
FROM LIKES
GROUP BY PHOTO_ID) L ON P.ID=L.PHOTO_ID
LEFT JOIN (SELECT
PHOTO_ID,COUNT(USER_ID) AS COMMENTS
FROM COMMENTS
GROUP BY PHOTO_ID) C ON P.ID=C.PHOTO_ID),

T2 AS (SELECT
USER_ID,SUM(LIKES+COMMENTS)/(SELECT COUNT(IMAGE_URL) FROM TEMP WHERE USER_ID=T.USER_ID)  AS ENGAGEMENT
FROM TEMP T
GROUP BY USER_ID)

SELECT
U.ID,U.USERNAME,ROUND(T2.ENGAGEMENT,2) AS avg_engagement
FROM USERS U
JOIN T2 ON U.ID=T2.USER_ID;

-- O7
-- Get the list of users who have never liked any post (users and likes
-- tables)
SELECT
U.ID,U.USERNAME
FROM USERS U
LEFT JOIN LIKES L ON L.USER_ID=U.ID
WHERE L.USER_ID IS NULL
ORDER BY ID;


-- O8
-- How can you leverage user-generated content (posts, hashtags, photo tags)
-- to create more personalized and engaging ad campaigns?
WITH TEMP AS (
    SELECT
        U.ID,
        U.USERNAME,
        P.ID AS PHOTO_ID,
        T.TAG_NAME
    FROM USERS U
    LEFT JOIN PHOTOS P
        ON P.USER_ID = U.ID
    LEFT JOIN PHOTO_TAGS PT
        ON PT.PHOTO_ID = P.ID
    LEFT JOIN TAGS T
        ON T.ID = PT.TAG_ID
),

LIKE_COUNTS AS (
    SELECT
        PHOTO_ID,
        COUNT(*) AS LIKE_CNT
    FROM LIKES
    GROUP BY PHOTO_ID
),

COMMENT_COUNTS AS (
    SELECT
        PHOTO_ID,
        COUNT(*) AS COMMENT_CNT
    FROM COMMENTS
    GROUP BY PHOTO_ID
)

SELECT
    T.ID AS USER_ID,
    T.USERNAME,
    T.TAG_NAME,
    COUNT(*) AS TAG_USAGE,
    SUM(COALESCE(L.LIKE_CNT, 0)) AS TOTAL_LIKES_RECEIVED,
    SUM(COALESCE(C.COMMENT_CNT, 0)) AS TOTAL_COMMENTS_RECEIVED,
    SUM(COALESCE(L.LIKE_CNT, 0))
      + SUM(COALESCE(C.COMMENT_CNT, 0)) AS TOTAL_ENGAGEMENT
FROM TEMP T
LEFT JOIN LIKE_COUNTS L
    ON T.PHOTO_ID = L.PHOTO_ID
LEFT JOIN COMMENT_COUNTS C
    ON T.PHOTO_ID = C.PHOTO_ID
GROUP BY
    T.ID,
    T.USERNAME,
    T.TAG_NAME;

-- O9
-- Are there any correlations between user activity levels and specific
-- content types (e.g., photos, videos, reels)? How can this information
-- guide content creation and curation strategies?
SELECT
    U.ID AS USER_ID,
    COUNT(P.ID) AS TOTAL_POSTS,
    SUM(COALESCE(L.LIKE_CNT, 0)) AS TOTAL_LIKES,
    SUM(COALESCE(C.CMT_CNT, 0)) AS TOTAL_COMMENTS,
    SUM(COALESCE(L.LIKE_CNT, 0))
        + SUM(COALESCE(C.CMT_CNT, 0)) AS TOTAL_ENGAGEMENT
FROM USERS U
JOIN PHOTOS P
    ON P.USER_ID = U.ID
LEFT JOIN (
    SELECT
        PHOTO_ID,
        COUNT(*) AS LIKE_CNT
    FROM LIKES
    GROUP BY PHOTO_ID
) L
    ON P.ID = L.PHOTO_ID
LEFT JOIN (
    SELECT
        PHOTO_ID,
        COUNT(*) AS CMT_CNT
    FROM COMMENTS
    GROUP BY PHOTO_ID
) C
    ON P.ID = C.PHOTO_ID
GROUP BY
    U.ID;


-- O10
-- Calculate the total number of likes, comments, and photo tags for each
-- user.
WITH TOTAL_POST_DATA AS (
    SELECT
        U.ID,
        U.USERNAME,
        COUNT(P.ID) AS TOTAL_POST,
        COALESCE(SUM(L.LIKES), 0) AS TOTAL_LIKES,
        COALESCE(SUM(C.CMT), 0) AS TOTAL_COMMENTS,
        COALESCE(SUM(PT.TAG), 0) AS TOTAL_TAGS
    FROM USERS U
    LEFT JOIN PHOTOS P
        ON P.USER_ID = U.ID
    LEFT JOIN (
        SELECT
            PHOTO_ID,
            COUNT(USER_ID) AS LIKES
        FROM LIKES
        GROUP BY PHOTO_ID
    ) L
        ON L.PHOTO_ID = P.ID
    LEFT JOIN (
        SELECT
            PHOTO_ID,
            COUNT(USER_ID) AS CMT
        FROM COMMENTS
        GROUP BY PHOTO_ID
    ) C
        ON C.PHOTO_ID = P.ID
    LEFT JOIN (
        SELECT
            PHOTO_ID,
            COUNT(TAG_ID) AS TAG
        FROM PHOTO_TAGS
        GROUP BY PHOTO_ID
    ) PT
        ON PT.PHOTO_ID = P.ID
    GROUP BY
        U.ID,
        U.USERNAME
)

SELECT
    ID AS USER_ID,
    USERNAME,
    TOTAL_LIKES,
    TOTAL_COMMENTS,
    TOTAL_TAGS
FROM TOTAL_POST_DATA;

-- O11
-- Rank users based on their total engagement (likes, comments, shares) over a
-- month.

with temp as (select
t.id,t.tag_name,count(pt.photo_id) as total_photo,sum(l.tt) as total_like
from tags t
left join photo_tags pt on t.id=pt.tag_id
join (select photo_id,count(user_id) as tt from likes group by photo_id)l on l.photo_id=pt.photo_id
group by t.id,t.tag_name)

select
id as tag_id,tag_name,round((total_like/total_photo),2) as avg_likes,total_like,total_photo
from temp
order by avg_likes desc
limit 10;


-- O12
-- Retrieve the hashtags that have been used in posts with the highest average
-- number of likes. Use a CTE to calculate the average likes for each
-- hashtag first.

with temp as (select
t.id,t.tag_name,count(pt.photo_id) as total_photo,sum(l.tt) as total_like
from tags t
left join photo_tags pt on t.id=pt.tag_id
join (select photo_id,count(user_id) as tt from likes group by photo_id)l on l.photo_id=pt.photo_id
group by t.id,t.tag_name)

select
id as tag_id,tag_name,round((total_like/total_photo),2) as avg_likes,total_like,total_photo
from temp
order by avg_likes desc
limit 10;


-- O13
-- Retrieve the users who have started following someone after being followed
-- by that person.

SELECT DISTINCT
    u.id,
    u.username
FROM users u
JOIN follows f1
    ON u.id = f1.follower_id
JOIN follows f2
    ON f1.followee_id = f2.follower_id
   AND f2.followee_id = f1.follower_id;




/* =====================================================================
   SUBJECTIVE QUESTIONS
   ===================================================================== */

-- S1
-- Based on user engagement and activity levels, which users would you
-- consider the most loyal or valuable? How would you reward or incentivize
-- these users?

-- to calculate the most loyal users
select
u.id,coalesce(l.liked_post,0) as liked_post,coalesce(g.commented_on_post,0) as commented_on_post,(coalesce(l.liked_post,0)+coalesce(g.commented_on_post,0)) as total_engagement,
dense_rank() over(order by (l.liked_post+g.commented_on_post) desc) as ranked
from users u
left join (select user_id,count(photo_id) as liked_post from likes group by user_id)l
on l.user_id=u.id
left join (select user_id,count(id) as commented_on_post from comments group by user_id)g
on g.user_id=u.id;

-- for most valuable user
with valuable_users as (select
p.user_id,count(p.id) as total_post_posted,sum(l.liked) as liked_received,sum(c.comm) as comments_received
from photos p
left join (select photo_id,count(user_id) as liked from likes group by photo_id)l
on p.id=l.photo_id
left join (select photo_id,count(user_id) as comm from comments group by photo_id)c
on p.id=c.photo_id
group by p.user_id)

select
user_id,total_post_posted,liked_received,comments_received,(liked_received+comments_received) as total_engagement,
dense_rank() over(order by (liked_received+comments_received) desc) as Value_of_position
from valuable_users
order by Value_of_position asc
limit 1;


-- S2
-- For inactive users, what strategies would you recommend to re-engage them
-- and encourage them to start posting or engaging again?
-- For users who are inactive in posting
select
u.id,
u.username,
coalesce(cc,0) as post_count
from users u
left join (select user_id,count(id) as cc from photos group by user_id)p on u.id=p.user_id
where cc is null
order by id;

-- The content preference of users who are inactive for posting
WITH temp AS (
    SELECT
        u.id,
        u.username,
        COALESCE(cc, 0) AS post_count
    FROM users u
    LEFT JOIN (
        SELECT
            user_id,
            COUNT(id) AS cc
        FROM photos
        GROUP BY user_id
    ) p
        ON u.id = p.user_id
    WHERE cc IS NULL
),

liked_content_preference AS (
    SELECT
        u.id,
        u.username,
        t.tag_name,
        COUNT(*) AS tag_count,
        DENSE_RANK() OVER (
            PARTITION BY u.id
            ORDER BY COUNT(*) DESC
        ) AS rr
    FROM users u
    JOIN likes l
        ON l.user_id = u.id
    JOIN photo_tags pt
        ON l.photo_id = pt.photo_id
    JOIN tags t
        ON t.id = pt.tag_id
    WHERE u.id IN (SELECT id FROM temp)
    GROUP BY
        u.id,
        u.username,
        t.tag_name
)

SELECT
    id,
    username,
    tag_name,
    tag_count
FROM liked_content_preference
WHERE rr = 1;

-- for user who's content cannot been classified by likes and post so for them we use their comment activity
WITH inactive_users AS (
    SELECT
        u.id AS user_id,
        u.username
    FROM users AS u
    LEFT JOIN photos AS p
        ON u.id = p.user_id
    GROUP BY
        u.id,
        u.username
    HAVING COUNT(p.id) = 0
),

users_without_likes AS (
    SELECT
        iu.user_id,
        iu.username
    FROM inactive_users AS iu
    LEFT JOIN likes AS l
        ON iu.user_id = l.user_id
    GROUP BY
        iu.user_id,
        iu.username
    HAVING COUNT(l.user_id) = 0
)

SELECT
    uwl.user_id,
    uwl.username,
    COUNT(c.id) AS comment_count
FROM users_without_likes AS uwl
LEFT JOIN comments AS c
    ON uwl.user_id = c.user_id
GROUP BY
    uwl.user_id,
    uwl.username
ORDER BY
    uwl.user_id;
-- S3
-- Which hashtags or content topics have the highest engagement rates? How can
-- this information guide content strategy and ad campaigns?

WITH like_count AS (
    SELECT
        photo_id,
        COUNT(*) AS likes
    FROM likes
    GROUP BY photo_id
),

comment_count AS (
    SELECT
        photo_id,
        COUNT(*) AS comments
    FROM comments
    GROUP BY photo_id
),

tag_engagement AS (
    SELECT
        t.tag_name,
        COUNT(DISTINCT pt.photo_id) AS total_posts,
        SUM(COALESCE(l.likes, 0)) AS total_likes,
        SUM(COALESCE(c.comments, 0)) AS total_comments,
        SUM(COALESCE(l.likes, 0))
            + SUM(COALESCE(c.comments, 0)) AS total_engagement
    FROM photo_tags pt
    JOIN tags t
        ON t.id = pt.tag_id
    LEFT JOIN like_count l
        ON l.photo_id = pt.photo_id
    LEFT JOIN comment_count c
        ON c.photo_id = pt.photo_id
    GROUP BY
        t.tag_name
),

ranked_tags AS (
    SELECT
        tag_name,
        total_posts,
        total_likes,
        total_comments,
        total_engagement,
        ROUND(
            total_engagement / NULLIF(total_posts, 0),
            2
        ) AS engagement_rate,
        DENSE_RANK() OVER (
            ORDER BY
                total_engagement / NULLIF(total_posts, 0) DESC
        ) AS engagement_rank
    FROM tag_engagement
)

SELECT
    tag_name,
    total_posts,
    total_likes,
    total_comments,
    total_engagement,
    engagement_rate,
    engagement_rank
FROM ranked_tags
ORDER BY
    engagement_rank,
    tag_name;


-- S4
-- Are there any patterns or trends in user engagement based on demographics
-- (age, location, gender) or posting times? How can these insights inform
-- targeted marketing campaigns?
select
DATE_FORMAT(created_dat, '%H:%i') AS Time,
count(id) as posted_content
from photos
group by DATE_FORMAT(created_dat, '%H:%i');


-- S5
-- Based on follower counts and engagement rates, which users would be ideal
-- candidates for influencer marketing campaigns? How would you approach
-- and collaborate with these influencers?
WITH follow_base AS (
    SELECT
        u.id,
        u.username,
        COALESCE(f.follower_cnt, 0) AS followers,
        COALESCE(f1.following_cnt, 0) AS following
    FROM users u

    LEFT JOIN (
        SELECT
            followee_id,
            COUNT(*) AS follower_cnt
        FROM follows
        GROUP BY followee_id
    ) f
        ON u.id = f.followee_id

    LEFT JOIN (
        SELECT
            follower_id,
            COUNT(*) AS following_cnt
        FROM follows
        GROUP BY follower_id
    ) f1
        ON u.id = f1.follower_id
),

engage AS (
    SELECT
        p.user_id,
        COUNT(p.id) AS total_posts,
        SUM(COALESCE(l.likes_rec, 0)) AS likes_received,
        SUM(COALESCE(c.com_rec, 0)) AS comments_received
    FROM photos p

    LEFT JOIN (
        SELECT
            photo_id,
            COUNT(user_id) AS likes_rec
        FROM likes
        GROUP BY photo_id
    ) l
        ON l.photo_id = p.id

    LEFT JOIN (
        SELECT
            photo_id,
            COUNT(user_id) AS com_rec
        FROM comments
        GROUP BY photo_id
    ) c
        ON c.photo_id = p.id

    GROUP BY p.user_id
),

final AS (
    SELECT
        f.id,
        f.username,
        f.followers,
        f.following,
        COALESCE(e.total_posts, 0) AS total_posts,
        COALESCE(e.likes_received, 0) AS likes_received,
        COALESCE(e.comments_received, 0) AS comments_received,

        COALESCE(
            ROUND(
                (e.likes_received + e.comments_received)
                / NULLIF(e.total_posts, 0),
                2
            ),
            0
        ) AS engagement_rate

    FROM follow_base f
    LEFT JOIN engage e
        ON f.id = e.user_id
)

SELECT
    id,
    username,
    followers,
    following,
    total_posts,
    likes_received,
    comments_received,
    engagement_rate,

    DENSE_RANK() OVER (
        ORDER BY followers DESC, engagement_rate DESC
    ) AS influencer_rank

FROM final
ORDER BY
    influencer_rank;

-- S6
-- Based on user behavior and engagement data, how would you segment the user
-- base for targeted marketing campaigns or personalized recommendations?

WITH user_tag_likes AS (
    SELECT
        l.user_id,
        t.tag_name,
        COUNT(*) AS like_count
    FROM likes l
    JOIN photo_tags pt
        ON l.photo_id = pt.photo_id
    JOIN tags t
        ON pt.tag_id = t.id
    GROUP BY
        l.user_id,
        t.tag_name
),

ranked_preferences AS (
    SELECT
        user_id,
        tag_name,
        like_count,
        DENSE_RANK() OVER (
            PARTITION BY user_id
            ORDER BY like_count DESC
        ) AS tag_rank
    FROM user_tag_likes
),

user_preferences AS (
    SELECT
        u.id AS user_id,
        u.username,
        rp.tag_name AS preferred_tag,
        rp.like_count AS preference_count
    FROM users u
    LEFT JOIN ranked_preferences rp
        ON u.id = rp.user_id
        AND rp.tag_rank = 1
)

SELECT
    user_id,
    username,
    preferred_tag,
    preference_count,

    CASE
        WHEN preferred_tag IS NULL
            THEN 'No Identifiable Preference'
        ELSE CONCAT(preferred_tag, ' Interested User')
    END AS user_segment

FROM user_preferences
ORDER BY
    preferred_tag,
    preference_count DESC;

-- S7
-- If data on ad campaigns (impressions, clicks, conversions) is available,
-- how would you measure their effectiveness and optimize future campaigns?

-- NO QUERY

-- S8
-- How can you use user activity data to identify potential brand ambassadors
-- or advocates who could help promote Instagram's initiatives or events?
WITH follow_base AS (
    SELECT
        u.id,
        u.username,
        COALESCE(f.follower_cnt, 0) AS followers,
        COALESCE(f1.following_cnt, 0) AS following
    FROM users u

    LEFT JOIN (
        SELECT
            followee_id,
            COUNT(*) AS follower_cnt
        FROM follows
        GROUP BY followee_id
    ) f
        ON u.id = f.followee_id

    LEFT JOIN (
        SELECT
            follower_id,
            COUNT(*) AS following_cnt
        FROM follows
        GROUP BY follower_id
    ) f1
        ON u.id = f1.follower_id
),

engage AS (
    SELECT
        p.user_id,
        COUNT(p.id) AS total_posts,
        SUM(COALESCE(l.likes_rec, 0)) AS likes_received,
        SUM(COALESCE(c.com_rec, 0)) AS comments_received
    FROM photos p

    LEFT JOIN (
        SELECT
            photo_id,
            COUNT(user_id) AS likes_rec
        FROM likes
        GROUP BY photo_id
    ) l
        ON l.photo_id = p.id

    LEFT JOIN (
        SELECT
            photo_id,
            COUNT(user_id) AS com_rec
        FROM comments
        GROUP BY photo_id
    ) c
        ON c.photo_id = p.id

    GROUP BY p.user_id
),

final AS (
    SELECT
        f.id,
        f.username,
        f.followers,
        f.following,
        COALESCE(e.total_posts, 0) AS total_posts,
        COALESCE(e.likes_received, 0) AS likes_received,
        COALESCE(e.comments_received, 0) AS comments_received,

        COALESCE(
            ROUND(
                (
                    COALESCE(e.likes_received, 0)
                    + COALESCE(e.comments_received, 0)
                ) / NULLIF(e.total_posts, 0),
                2
            ),
            0
        ) AS engagement_per_post

    FROM follow_base f
    LEFT JOIN engage e
        ON f.id = e.user_id
)

SELECT
    id,
    username,
    followers,
    following,
    total_posts,
    likes_received,
    comments_received,
    engagement_per_post,

    DENSE_RANK() OVER (
        ORDER BY
            followers DESC,
            engagement_per_post DESC
    ) AS advocate_rank

FROM final

ORDER BY
    advocate_rank;

-- S9
-- How would you approach this problem, if the objective and subjective
-- questions weren't given?

-- If the objective and subjective questions were not given, 
-- I would first understand the dataset and identify what type of information is available in each table. 
-- Then I would explore important metrics related to users, posts, likes, comments, follows, and tags to understand user activity and engagement.
-- After that, I would look for patterns such as inactive users, popular content, highly engaged topics, user preferences, follower growth, 
-- and highly active users. Based on these findings, I would identify the important business problems and convert them into analytical questions. 
-- Finally, I would use SQL to analyse those questions and provide insights and recommendations that can help improve user engagement, content strategy, 
-- and marketing campaigns. 


-- S10
-- Assuming there's a "User_Interactions" table tracking user engagements, how
-- can you update the "Engagement_Type" column to change all instances of
-- "Like" to "Heart" to align with Instagram's terminology?
UPDATE User_Interactions
SET Engagement_Type = 'Heart'
WHERE Engagement_Type = 'Like';


/* ===================================== END OF FILE ===================================== */
