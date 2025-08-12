-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT DISTINCT type,COUNT(type)
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
WITH RATING_COUNT AS(
SELECT Distinct type,rating,
COUNT(rating) AS rating_count
FROM netflix
GROUP BY type,rating

)
SELECT type,rating AS most_frequent_rating 
FROM(
SELECT Distinct type,rating,
RANK () OVER (PARTITION BY type ORDER BY rating_count desc ) AS ranked_rating
FROM RATING_COUNT
) AS RANKED
Where ranked_rating=1;


-- 3. List all movies released in a specific years (e.g., 2020,2021,2022)


SELECT DISTINCT *
FROM netflix;
WHERE release_year IN (2020,2021,2022);

-- 4. Find the top 5 countries with the most content on Netflix



SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS COUNTRY,count(*) AS Contet_COUNT
FROM netflix
GROUP BY COUNTRY
ORDER BY Contet_COUNT desc
LIMIT 5;


-- 5. Identify the longest movie


SELECT *
FROM (
  SELECT *,
    CAST((REGEXP_MATCHES(duration, '^\d+'))[1] AS INTEGER) AS duration_int
  FROM netflix
  WHERE type = 'Movie'
) AS int_dur
 ORDER BY duration_int DESC
LIMIT 1;

-- 6. Find content added in the last 5 years


WITH 
t1 AS(
SELECT *,
CAST((REGEXP_MATCHES(date_added ,'\d{4}$'))[1] AS INTEGER) AS year_added
FROM netflix
) 

SELECT *
FROM t1
WHERE year_added BETWEEN EXTRACT (YEAR FROM CURRENT_DATE) -5 AND EXTRACT (YEAR FROM CURRENT_DATE);


-- 7. Find all the movies/TV shows by director 'Christopher Nolan'
WITH 
t1 AS(
SELECT *,
UNNEST (STRING_TO_ARRAY(director,',')) AS DIRECTOR_LIST
FROM netflix
) 


SELECT *
FROM t1
WHERE DIRECTOR_LIST ='Christopher Nolan';



-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM(
SELECT *,
CAST ((REGEXP_MATCHES(duration,'^\d+'))[1] AS INTEGER) AS tv_shows_dur 
FROM netflix 
) AS t1
WHERE type='TV Show' AND tv_shows_dur>5;

-- 9. Count the number of content items in each genre
SELECT 
UNNEST (STRING_TO_ARRAY(listed_in,',')) AS GENRE,
COUNT(show_id) AS CONTENT_ITEMS
FROM netflix
GROUP BY GENRE;

-- 10.Find each year and the average numbers of content release in Pakistan on netflix. 
-- return top 5 year with highest avg content release!


SELECT RELEASE_YEAR,AVG(CONTENT_COUNT) AS AVG_CONTENT
FROM (
SELECT (REGEXP_MATCHES(date_added,'\d{4}$'))[1] AS RELEASE_YEAR,COUNT(show_id) AS CONTENT_COUNT,
UNNEST(STRING_TO_ARRAY(country,',')) AS COUNTRY
FROM netflix
WHERE COUNTRY='Pakistan'
GROUP BY 1,3
)
GROUP BY RELEASE_YEAR
ORDER BY AVG_CONTENT DESC
LIMIT 5;

WITH t1 AS(
SELECT (REGEXP_MATCHES(date_added,'\d{4}$'))[1] AS RELEASE_YEAR,COUNT(show_id) AS CONTENT_COUNT
FROM netflix
WHERE country ILIKE '%Pakistan%'
GROUP BY 1
)

SELECT RELEASE_YEAR,CONTENT_COUNT::float/(SELECT SUM(CONTENT_COUNT) FROM t1 ) AS AVG_CONTENT
FROM t1
ORDER BY AVG_CONTENT DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT show_id,type,title,listed_in
FROM(
SELECT * ,
UNNEST (STRING_TO_ARRAY(listed_in,',')) AS GENRE
FROM netflix) AS t1

WHERE type='Movie' AND GENRE='Documentaries';

-- 12. Find all content without a director


SELECT *
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies/Tv Shows actor 'Cillian Murphy' appeared in last 10 years!

SELECT COUNT(*)AS CONTENT_COUNT  
FROM (
SELECT *,
UNNEST (STRING_TO_ARRAY(casts,',')) AS ACTORS_IN_CAST,
TO_DATE (date_added,'Month DD,YYYY') AS DATEADDED
FROM netflix
) AS t1
WHERE DATEADDED >= DATEADDED - INTERVAL '10 years'
AND  ACTORS_IN_CAST ='Cillian Murphy';
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in Pakistan.
SELECT 
UNNEST (STRING_TO_ARRAY(casts,',')) AS ACTORS_IN_CAST,
COUNT(*) AS MOVIE_COUNT
FROM (
SELECT casts,type,
UNNEST(STRING_TO_ARRAY(country,',')) AS COUNTRY
FROM netflix
)
WHERE type='Movie' AND COUNTRY='Pakistan'
GROUP BY ACTORS_IN_CAST
ORDER BY MOVIE_COUNT DESC
LIMIT 10;

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT CATEGORY,COUNT(*)
FROM
(
SELECT *,
CASE 
WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'BAD' 
ELSE 'GOOD'
END AS CATEGORY
FROM netflix
) AS t1
GROUP BY CATEGORY;