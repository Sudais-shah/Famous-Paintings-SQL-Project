/*
    Famous Painting Database Queries
    Author: [Sudais Shah]
    Date: [12-9-2024]

    Description:
    SQL queries based on the Famous Painting Database, covering data retrieval, 
    aggregation, filtering, and joins. A total of 22 questions are solved.

    Instructions:
    - Import the database into your SQL environment before running these queries.
    - Each query is prefixed with its purpose.
    Columns : 
      -1 artist 2 canva_size 3 image_link 4 museum 5 museum_hours 6 product size 7 subject 8 work 
*/
USE famous_painting;

 -- Fetch all the paintings which are not displayed on any museums?
SELECT name FROM work WHERE museum_id  like '';
SELECT * FROM work;
 -- Are there museums without any paintings? --
SELECT m.museum_id, m.name
FROM museum m
left JOIN work w ON m.museum_id = w.museum_id
WHERE w.museum_id IS NULL;

 -- How many paintings have an asking price of more than their regular price?--
 
 SELECT   w.work_id,  w.name, ps.sale_price, ps.regular_price
 FROM work w
 JOIN product_size ps ON w.work_id = ps.work_id 
 WHERE ps.sale_price > ps.regular_price;
 
 -- Identify the paintings whose asking price is less than 50% of its regular price--
  SELECT     w.name, ps.sale_price, ps.regular_price
 FROM work w
 JOIN product_size ps ON w.work_id = ps.work_id 
 WHERE ps.sale_price < (ps.regular_price * 0.5);
 
  
-- Which canva size costs the most?
   SELECT   cs.size_id , cs.width, cs.height,sum(ps.regular_price) AS cost
 FROM canva_size cs
 JOIN product_size ps ON cs.size_id = ps.size_id
 GROUP BY 1,2,3 
 ORDER BY cost desc 
 limit 1;
 
 
 
 -- Delete duplicate records from work, product_size, subject and image_link tables --
 
 with cte_work as (
  SELECT work.work_id ,  row_number() over (partition by work.work_id) as row_no
  from work
 )
  DELETE  FROM work where work_id in(select work_id from cte_work where row_no > 1);
with  cte_product_size as (
 SELECT work_id , row_number() over (partition by  product_size.work_id) as row_no
 from product_size
 )
  DELETE  FROM product_size where work_id in(select work_id from cte_product_size where row_no > 1);
  
with cte_subject as (
SELECT work_id ,  row_number() over (partition by subject.work_id)  as row_no
from subject )

 DELETE  FROM subject where work_id in(select work_id from cte_subject where row_no > 1);
 
with cte_image_link as (
  SELECT work_id, row_number() over (partition by  image_link.work_id) as row_no
  from image_link) 
 DELETE  FROM image_link where work_id in(select work_id from cte_image_link where row_no > 1);
 
 
 -- Identify the museums with invalid city information in the given dataset --
SELECT name as museum_name , city FROM museum WHERE city IS NULL OR city REGEXP '[0-9]';



-- 8. Museum_Hours table has 1 invalid entry. Identify it and remove it. --
SELECT museum_id , day , open , close FROM museum_hours
WHERE museum_id is null OR museum_id regexp '[a-bA-B]'
OR day IS NULL OR day REGEXP '[0-9]' OR day = monthname(day) or STR_TO_DATE(close, '%h:%i %p') < STR_TO_DATE(open, '%h:%i %p') or
open IS NULL or day  not in('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
 ;
update museum_hours set day = 'thursday' where day = 'thusday';


-- 9. Fetch the top 10 most famous painting subject --
SELECT subject, count(work.museum_id) as famous from subject 
JOIN work ON subject.work_id = work.work_id  
group by subject order by famous desc limit 10 ;

-- 10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
SELECT   museum.name as name , museum.city as city FROM museum 
JOIN museum_hours mh1 ON museum.museum_id = mh1.museum_id 
JOIN museum_hours mh2 ON museum.museum_id = mh2.museum_id 
WHERE mh1.day = 'sunday' AND mh2.day = 'monday';
               --    2  --
    SELECT mh.museum_id
    FROM museum_hours mh
    WHERE mh.day IN ('Sunday', 'Monday')
    GROUP BY mh.museum_id
    HAVING COUNT(DISTINCT mh.day) = 2;


-- 11. How many museums are open every single day? 
  SELECT COUNT(*) AS TOTAL FROM (
   SELECT  museum_id   FROM museum_hours as m
   group by 1
   having count(DISTINCT m.day) = 7 
   
   ) AS A ;
   
-- 12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
 SELECT m.name ,m.museum_id , COUNT(w.name ) as total FROM museum m 
 INNER JOIN work w ON m.museum_id = w.museum_id 
 GROUP BY 1,2 ORDER BY total DESC limit 5
 ;
 
 -- 13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
  SELECT  a.full_name as name, COUNT(w.name) AS total
  FROM artist a
  JOIN work w ON a.artist_id = w.artist_id 
  GROUP BY 1 ORDER BY total DESC 
  LIMIT 5
  ;
  
  -- 14. Display the 3 least popular canva sizes
SELECT label as Popular_Canva_Size , count(ps.size_id) as total FROM canva_size cs 
JOIN product_size ps ON cs.size_id = ps.size_id
GROUP BY label ORDER BY total desc limit 3;


-- 15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
SELECT m.name as name, m.state as state,
 STR_TO_DATE(mh.close, '%h:%i:%p') - STR_TO_DATE(mh.open, '%h:%i:%p')as longest,
  mh.day as day
FROM museum m
JOIN museum_hours mh ON m.museum_id = mh.museum_id 
order by longest desc limit 1
; 
-- 16. Which museum has the most no of most popular painting style?
 Select m.name , w.style , count(w.style) as total_styles from museum m
 JOIN work w on m.museum_id = w.museum_id 
 WHERE style IS NOT NULL 
  AND style != ''
 group by 1,2 
 order by total_styles DESC 
 Limit 1
 ;
 
 -- 17. Identify the artists whose paintings are displayed in multiple countries
   SELECT a.artist_id , a.full_name , count(DISTINCT m.country) as no_of_countries FROM artist a
   JOIN work w ON a.artist_id = w.artist_id 
   JOIN museum m ON w.museum_id = m.museum_id 
   GROUP BY 1,2 HAVING no_of_countries > 1  ORDER BY no_of_countries DESC ;
   
   -- 18. Display the country and the city with most no of museums. Output 2 seperate
-- columns to mention the city and country. If there are multiple value, seperate them
-- with comma.

with cte1 as (
SELECT distinct country , city , count(museum_id) as no_of_museums FROM museum 
GROUP BY 1,2 ORDER BY no_of_museums DESC ),
cte2 as (
SELECT MAX(no_of_museums) as max_museums FROM cte1 
)
select group_concat(country order by country) , group_concat(city order by city) FROM cte1,cte2 
WHERE 
no_of_museums = max_museums;
WITH CityCountryCount AS (
    SELECT country, city, COUNT(museum_id) AS no_of_museums
    FROM museum
    GROUP BY country, city
),
MaxCount AS (
    SELECT MAX(no_of_museums) AS max_museums
    FROM CityCountryCount
)
SELECT GROUP_CONCAT(city ORDER BY city) AS cities, 
       GROUP_CONCAT(country ORDER BY country) AS countries  -- string_aggregate
FROM CityCountryCount, MaxCount
WHERE no_of_museums = max_museums;


-- 19. Identify the artist and the museum where the most expensive and least expensive
-- painting is placed. Display the artist name, sale_price, painting name, museum
-- name, museum city and canvas label

with most_exp as (
SELECT work.name as painting_name , artist.full_name  as full_name , museum.name as museum_name 
 , max(product_size.sale_price) as price 
 , museum.city as city ,
  canva_size.label  as label
FROM work 
JOIN museum  on work.museum_id = museum.museum_id 
JOIN artist  on work.artist_id = artist.artist_id
JOIN product_size on work.work_id = product_size.work_id 
 JOIN canva_size on work.size_id = canva_size.size_id 
group by 1,2,3,5,6
order by price desc
limit 1
),
least_exp as (
SELECT work.name as painting_name , artist.full_name  as full_name , museum.name as museum_name , 
    min(product_size.sale_price) as price2
  , museum.city as city ,
  canva_size.label  as label
FROM work 
JOIN museum  on work.museum_id = museum.museum_id 
JOIN artist  on work.artist_id = artist.artist_id
JOIN product_size on work.work_id = product_size.work_id 
 JOIN canva_size on work.size_id = canva_size.size_id 
group by 1,2,3,5,6
order by  price2 asc
limit 1
 )
SELECT painting_name , full_name , museum_name  ,  price
  , city , label 
 from most_exp 
 union all
 SELECT painting_name , full_name , museum_name  ,price2
 , city , label
 from least_exp
 ;
   --  20. Which country has the 5th highest no of paintings?
with fifth_museum as (
  SELECT m.country , count(w.name) highest_Paintings ,
  row_number() over( order by  count(w.name) desc) as row_no
  from museum m
  JOIN work w on m.museum_id = w.museum_id 
  GROUP BY 1 ORDER BY highest_paintings desc
  limit 5  )
  SELECT * FROM fifth_museum where row_no = 5;
  
  
  -- 21. Which are the 3 most popular and 3 least popular painting styles?
 with popular as (
 SELECT style as style , count(style) as count 
 from work
 group by style order by count desc limit 3),
   least as (
 SELECT style as style  , count(style) as count 
 from work
 group by style order by count asc limit 3
)
 SELECT style , count FROM popular 
 UNION All 
 SELECT style , count FROM least ;


   -- 2ne method 
   
WITH ranked_styles AS (
    SELECT 
        style, 
        COUNT(*) AS style_count,
	
        DENSE_RANK() OVER (ORDER BY COUNT(*) ASC) AS rank_asc,
         DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_desc
    FROM work
    GROUP BY style
)
SELECT style, style_count 
FROM ranked_styles
WHERE rank_desc <= 3 
union all 
SELECT style, style_count 
FROM ranked_styles
WHERE rank_asc <= 3;

-- 22. Which artist has the most no of Portraits paintings outside USA?. Display artist
-- name, no of paintings and the artist nationality.
   
   SELECT a.full_name as name ,m.country ,count(w.work_id     -- or a.subject -- 
   ) as paintings ,  a.nationality  as nationality
   FROM work w
   JOIN museum m on w.museum_id = m.museum_id 
   JOIN artist a on w.artist_id = a.artist_id 
   where a.style = 'portraitist' and m.country not in('usa')
   GROUP BY 1,2,4 Order by count(a.style) desc 
   LIMIT 1;