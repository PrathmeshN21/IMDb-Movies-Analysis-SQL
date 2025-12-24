
-- IMDb Movies Analysis using SQL
-- Author: Prathmesh Ramesh

/* ===============================
   Segment 1: Database Exploration
   =============================== */

SHOW TABLES;

SELECT 'movie' AS table_name, COUNT(*) AS total_rows FROM movie
UNION ALL
SELECT 'genre', COUNT(*) FROM genre
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'names', COUNT(*) FROM names
UNION ALL
SELECT 'director_mapping', COUNT(*) FROM director_mapping
UNION ALL
SELECT 'role_mapping', COUNT(*) FROM role_mapping;

SELECT 
SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_nulls,
SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls
FROM movie;

/* ===============================
   Segment 2: Movie Release Trends
   =============================== */

SELECT year, COUNT(*) AS total_movies
FROM movie
GROUP BY year
ORDER BY year;

SELECT MONTH(date_published) AS month, COUNT(*) AS total_movies
FROM movie
GROUP BY month
ORDER BY month;

SELECT COUNT(*) AS movies_2019
FROM movie
WHERE year = 2019 AND country IN ('USA', 'India');

/* ===============================
   Segment 3: Genre Analysis
   =============================== */

SELECT DISTINCT genre FROM genre;

SELECT genre, COUNT(*) AS movie_count
FROM genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 1;

SELECT COUNT(movie_id) AS single_genre_movies
FROM (
    SELECT movie_id
    FROM genre
    GROUP BY movie_id
    HAVING COUNT(genre) = 1
) t;

SELECT g.genre, ROUND(AVG(m.duration),2) AS avg_duration
FROM movie m
JOIN genre g ON m.movie_id = g.movie_id
GROUP BY g.genre;

SELECT genre, 
RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
FROM genre
GROUP BY genre
HAVING genre = 'Thriller';

/* ===============================
   Segment 4: Ratings Analysis
   =============================== */

SELECT 
MIN(avg_rating) AS min_rating,
MAX(avg_rating) AS max_rating,
MIN(total_votes) AS min_votes,
MAX(total_votes) AS max_votes
FROM ratings;

SELECT m.title, r.avg_rating
FROM movie m
JOIN ratings r ON m.movie_id = r.movie_id
ORDER BY r.avg_rating DESC
LIMIT 10;

SELECT median_rating, COUNT(*) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;

SELECT production_company, COUNT(*) AS hit_movies
FROM movie m
JOIN ratings r ON m.movie_id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY production_company
ORDER BY hit_movies DESC
LIMIT 1;

/* ===============================
   Segment 5: Crew Analysis
   =============================== */

SELECT 
SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls
FROM names;

SELECT n.name, COUNT(*) AS movie_count
FROM director_mapping d
JOIN ratings r ON d.movie_id = r.movie_id
JOIN names n ON d.name_id = n.name_id
WHERE r.avg_rating > 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 3;

/* ===============================
   Segment 6: Advanced Analysis
   =============================== */

SELECT 
m.title,
CASE 
    WHEN r.avg_rating >= 8 THEN 'Super Hit'
    WHEN r.avg_rating >= 6 THEN 'Hit'
    ELSE 'Average'
END AS category
FROM movie m
JOIN ratings r ON m.movie_id = r.movie_id
JOIN genre g ON m.movie_id = g.movie_id
WHERE g.genre = 'Thriller';

SELECT 
genre,
SUM(AVG(duration)) OVER (ORDER BY genre) AS running_total_duration,
AVG(AVG(duration)) OVER (ORDER BY genre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM movie m
JOIN genre g ON m.movie_id = g.movie_id
GROUP BY genre;

/* ===============================
   Segment 7: End
   =============================== */
