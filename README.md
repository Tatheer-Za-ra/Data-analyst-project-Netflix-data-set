Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT DISTINCT type,COUNT(type)
FROM netflix
GROUP BY type;

```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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

```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3.List all movies released in a specific years (e.g., 2020,2021,2022)

```sql
SELECT DISTINCT *
FROM netflix;
WHERE release_year IN (2020,2021,2022);
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS COUNTRY,count(*) AS Contet_COUNT
FROM netflix
GROUP BY COUNTRY
ORDER BY Contet_COUNT desc
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT *
FROM (
  SELECT *,
    CAST((REGEXP_MATCHES(duration, '^\d+'))[1] AS INTEGER) AS duration_int
  FROM netflix
  WHERE type = 'Movie'
) AS int_dur
 ORDER BY duration_int DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
WITH 
t1 AS(
SELECT *,
CAST((REGEXP_MATCHES(date_added ,'\d{4}$'))[1] AS INTEGER) AS year_added
FROM netflix
) 

SELECT *
FROM t1
WHERE year_added BETWEEN EXTRACT (YEAR FROM CURRENT_DATE) -5 AND EXTRACT (YEAR FROM CURRENT_DATE);

```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7.  Find all the movies/TV shows by director 'Christopher Nolan'

```sql

WITH 
t1 AS(
SELECT *,
UNNEST (STRING_TO_ARRAY(director,',')) AS DIRECTOR_LIST
FROM netflix
) 


SELECT *
FROM t1
WHERE DIRECTOR_LIST ='Christopher Nolan';

```

**Objective:** List all content directed by 'Christopher Nolan'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM(
SELECT *,
CAST ((REGEXP_MATCHES(duration,'^\d+'))[1] AS INTEGER) AS tv_shows_dur 
FROM netflix 
) AS t1
WHERE type='TV Show' AND tv_shows_dur>5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
UNNEST (STRING_TO_ARRAY(listed_in,',')) AS GENRE,
COUNT(show_id) AS CONTENT_ITEMS
FROM netflix
GROUP BY GENRE;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in Pakistan on netflix. 
return top 5 year with highest avg content release!

```sql

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
```

**Objective:** Calculate and rank years by the average number of content releases by Pakistan.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find how many movies/Tv Shows actor 'Cillian Murphy' appeared in last 10 years

```sql

SELECT COUNT(*)AS CONTENT_COUNT  
FROM (
SELECT *,
UNNEST (STRING_TO_ARRAY(casts,',')) AS ACTORS_IN_CAST,
TO_DATE (date_added,'Month DD,YYYY') AS DATEADDED
FROM netflix
) AS t1
WHERE DATEADDED >= DATEADDED - INTERVAL '10 years'
AND  ACTORS_IN_CAST ='Cillian Murphy';
```

**Objective:** Count the number of movies featuring 'Cillian Murphy' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in 'Pakistan'

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Pakistan-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by Pakistan highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Tatheer Zahra

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

