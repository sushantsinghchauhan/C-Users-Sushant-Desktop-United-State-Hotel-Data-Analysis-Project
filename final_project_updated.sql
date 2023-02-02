--ALL TABLES
USE SQL_PROJECT


	SELECT * FROM df_austin_availability
	SELECT  * FROM host_austin_df
	SELECT * FROM listing_austin_df
	SELECT * FROM review_austin_df

	select distinct(room_type) from listing_austin_df;
	--You are an Analyst working for a Property Rental company.



--The company wants to explore the trends for different property types(Room Types) and their listed price across a variety of metrics. Thus, you are asked to understand the data and come up with the below analysis:

	--TYPES OF property types(Room Types)
	

--a. Analyze different metrics to draw the distinction between the different types of property along with their price listings(bucketize them within 3-4 categories basis your understanding):
--To achieve this, you can use the following metrics and explore a few yourself as well. 
--	Availability within 50,100-150,150-200,etc. days, Acceptance Rate, Average no of bookings, reviews, etc.     
	
	--Availability within 15,30,45,etc. days OF property types(Room Types)
		
		WITH TABLE1 AS
		(SELECT C.room_type,CASE 
		WHEN DATEDIFF(DAY,GETDATE(),date) < 51 and available ='TRUE' THEN 'Available within 50 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 50 AND 101 and available ='TRUE' THEN 'Available after 50 within 100 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 100 AND 151 and available ='TRUE' THEN 'Available after 100 within 150 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 150 AND 201 and available ='TRUE'  THEN 'Available after 150 within 200 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 200 AND 251 and available ='TRUE' THEN 'Available after 200 within 250 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 250 AND 301  AND available ='TRUE'THEN 'Available after 250 within 300 Days'
		END
		AVAILABLITY

		FROM df_austin_availability A JOIN listing_austin_df C
		ON A.id=C.id)
	

		SELECT room_type,ISNULL(AVAILABLITY,'NA') as Duration ,COUNT(AVAILABLITY) AVAILABLE_PROPERTIES FROM TABLE1
		GROUP BY room_type,AVAILABLITY order by room_type;

	--Acceptance Rate OF property types(Room Types)

		SELECT A.room_type,CAST(AVG(B.host_acceptance_rate) AS DECIMAL(10,2)) AVG_ACC_RATE
		FROM listing_austin_df A JOIN host_austin_df B
		ON A.host_id=B.host_id
		GROUP BY A.room_type

	--Average no of bookings OF property types(Room Types)
		
		SELECT A.room_type,COUNT(B.listing_id) TOTAL_BOOKINGS FROM listing_austin_df A JOIN review_austin_df B
		ON A.id=B.listing_id
		GROUP BY A.room_type;


	--reviews OF property types(Room Types)
		SELECT room_type,COUNT(B.listing_id) TOTAL_BOOKINGS ,AVG(review_scores_rating) AVG_review_scores_rating,AVG(review_scores_accuracy) AVG_review_scores_accuracy,
		AVG(review_scores_cleanliness) AVG_review_scores_cleanliness,
		AVG(review_scores_communication) AVG_review_scores_communication,AVG(review_scores_location) AVG_review_scores_location,
		AVG(review_scores_value) AVG_review_scores_value
		FROM listing_austin_df A JOIN review_austin_df B
		ON A.id=B.listing_id
		GROUP BY room_type

SELECT * FROM listing_austin_df;

--b. Study the trends of the different categories and provide insights on same
WITH T1 AS(
SELECT B.room_type,AVG(C.host_response_rate) AS Acceptance_Rate,

AVG(B.review_scores_rating) as Rating,
Count(b.bedrooms) as Bedrooms,
AVG(A.PRICE) AS Avg_Price,
max(A.price) as Max_Price,
Min(A.price) as Min_Price
FROM
df_austin_availability A
JOIN listing_austin_df B
ON A.listing_id=B.id
JOIN host_austin_df C
ON C.host_id=B.host_id
JOIN review_austin_df D
on D.listing_id=A.listing_id
group by  B.room_type), T2 AS
(SELECT B.room_type,count(case when b.instant_bookable='True' then b.instant_bookable end )
as Instant_Avaliable,
count(case when b.instant_bookable='False' then b.instant_bookable end ) 
as Uninstant_Avaliable
FROM
df_austin_availability A
JOIN listing_austin_df B
ON A.listing_id=B.id
JOIN host_austin_df C
ON C.host_id=B.host_id
JOIN review_austin_df D
on D.listing_id=A.listing_id
group by  B.room_type),
T3 AS (
    SELECT ROOM_TYPE, COUNT(room_type) AS COUNT_OF_LISTINGS 
FROM
df_austin_availability A
JOIN listing_austin_df B
ON A.listing_id=B.id
JOIN host_austin_df C
ON C.host_id=B.host_id
JOIN review_austin_df D
on D.listing_id=A.listing_id
GROUP BY room_type
)
SELECT T1.*,T3.COUNT_OF_LISTINGS,T2.Instant_Avaliable,T2.Uninstant_Avaliable FROM T1,T2,T3 WHERE T1.room_type=T2.room_type 
AND  T3.ROOM_TYPE=T2.ROOM_TYPE;


--identify top 2 crucial metrics which makes different 
--property types along their listing price stand ahead of other categories 

SELECT B.room_type,count(case when b.instant_bookable='True' then b.instant_bookable end )
as Instant_Avaliable,round(avg(B.price),2) as Price,round(AVG(B.review_scores_cleanliness),2) as Rating_Avg,
count(case when b.instant_bookable='False' then b.instant_bookable end ) 
as Uninstant_Avaliable
FROM
df_austin_availability A
JOIN listing_austin_df B
ON A.listing_id=B.id
JOIN host_austin_df C
ON C.host_id=B.host_id
JOIN review_austin_df D
on D.listing_id=A.listing_id
group by  B.room_type order by Uninstant_Avaliable desc;






-- SELECT TOP 1* FROM df_austin_availability
-- SELECT * FROM review_austin_df
-- SELECT TOP 1* FROM listing_austin_df
-- SELECT TOP 1* FROM host_austin_df



--d. Analyze how does the comments of reviewers vary for listings of distinct categories(Extract words from the comments provided by the reviewers)
SELECT top 1* From listing_austin_df
select * from review_austin_df;

with cte as(
select l.room_type,
count(case when r.comments like '%good%' or r.comments like '%love%' or r.comments like  '%amazing%' or r.comments like  '%cool%' 
or r.comments like  '%fantastic%' or r.comments like '%very good%' or r.comments like  '%nice%' 
or r.comments like '%satisfied%' or r.comments like '%awesome%' then comments end ) as positive_sentimnents
from review_austin_df r
join listing_austin_df l
on r.listing_id = l.id
group by l.room_type
),
ct2 as ( 
    select l.room_type,
count(case when r.comments like '%bad%' or r.comments like '%unpleasent%' or r.comments like  '%unhygenic%' or r.comments like '%unsatisfied%'
or r.comments like '%worst%' or  r.comments like '%messy%' then comments end) as negative_sentiments
from review_austin_df r
join listing_austin_df l
on r.listing_id = l.id
group by l.room_type)
select cte.*,ct2.negative_sentiments
from cte
join ct2
on cte.room_type = ct2.room_type;





--e. Analyze if there is any correlation between property type and their availability across the months
WITH TABLE1 AS
	(SELECT A.room_type,YEAR(B.DATE) YEAR_,DATENAME(MONTH,B.date) MONTH_,COUNT(B.available) TOTAL_ROOMS 
	FROM listing_austin_df A JOIN df_austin_availability B
	ON A.id=B.id
	WHERE B.available IN ('TRUE','FALSE')
	GROUP BY A.room_type,YEAR(B.DATE),DATENAME(MONTH,B.date)),
	
	TABLE2 AS
	(SELECT A.room_type,YEAR(B.DATE) YEAR_,DATENAME(MONTH,B.date) MONTH_,COUNT(B.available) AVAILABLE_ROOMS 
	FROM listing_austin_df A JOIN df_austin_availability B
	ON A.id=B.id
	WHERE B.available LIKE 'TRUE'
	GROUP BY A.room_type,YEAR(B.DATE),DATENAME(MONTH,B.date) ),

	TABLE3 AS
	(SELECT A.room_type,YEAR(B.DATE) YEAR_,DATENAME(MONTH,B.date)  MONTH_,COUNT(B.available) UNAVAILABLE_ROOMS 
	FROM listing_austin_df A JOIN df_austin_availability B
	ON A.id=B.id
	WHERE B.available LIKE 'FALSE'
	GROUP BY A.room_type,YEAR(B.DATE),DATENAME(MONTH,B.date) )

	SELECT TABLE1.ROOM_TYPE,TABLE1.YEAR_,TABLE1.MONTH_,TOTAL_ROOMS,
	AVAILABLE_ROOMS, UNAVAILABLE_ROOMS FROM TABLE1 JOIN TABLE2 ON TABLE1.ROOM_TYPE=TABLE2.ROOM_TYPE AND TABLE1.YEAR_=TABLE2.YEAR_ AND TABLE1.MONTH_=TABLE2.MONTH_
	JOIN TABLE3 ON TABLE1.ROOM_TYPE=TABLE3.ROOM_TYPE AND TABLE1.YEAR_=TABLE3.YEAR_ AND TABLE1.MONTH_=TABLE3.MONTH_









--f. Analyze what are the peak and off-peak time for the different categories of property type and their listings.
-- Do we see some commonalities in the trend or is it dependent on the category


WITH CTE AS (
SELECT B.room_type AS Room_Type , DATENAME(MONTH,D.DATE) AS Month,COUNT(D.listing_id) AS COUNT_OF_BOOKINGS
FROM
df_austin_availability A
JOIN listing_austin_df B
ON A.listing_id=B.id
JOIN host_austin_df C
ON C.host_id=B.host_id
JOIN review_austin_df D
on D.listing_id=A.listing_id
GROUP BY DATENAME(MONTH,D.DATE),B.room_type)

SELECT * FROM (SELECT Room_Type , COUNT_OF_BOOKINGS,Month from CTE ) AS A
PIVOT (SUM (COUNT_OF_BOOKINGS) FOR MONTH IN ([January],[February],[March],[April],[May],
[June],[JULY],[AUGUST],[SEPTEMBER],[OCTOBER],[NOVEMBER],[DECEMBER])) as P









--g. Using the above analysis, suggest what is the best performing category for the company

--BASED ON REVENUE 

SELECT b.room_type,sum(b.price) as Total_Revenue
FROM
df_austin_availability A
JOIN listing_austin_df B
ON A.listing_id=B.id
JOIN host_austin_df C
ON C.host_id=B.host_id
JOIN review_austin_df D
on D.listing_id=A.listing_id
group by room_type




--Now we are going to do the same analysis on Dallas and then i will compare them both !

select * from df_dallas_availabilitys
select * from host_dallas_df
select  * from listing_dallas_dfs
select * from review_dallas_dfs



--The company wants to explore the trends for different property types(Room Types) and their listed price across a variety of metrics. Thus, you are asked to understand the data and come up with the below analysis:

	--TYPES OF property types(Room Types)
	

--a. Analyze different metrics to draw the distinction between the different types of property along with their price listings(bucketize them within 3-4 categories basis your understanding):
--To achieve this, you can use the following metrics and explore a few yourself as well. 
--	Availability within 50,100-150,150-200,etc. days, Acceptance Rate, Average no of bookings, reviews, etc.     
	
	--Availability within 15,30,45,etc. days OF property types(Room Types)
		
		WITH TABLE1 AS
		(SELECT C.room_type,CASE 
		WHEN DATEDIFF(DAY,GETDATE(),date) < 51 and available ='TRUE' THEN 'Available within 50 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 50 AND 101 and available ='TRUE' THEN 'Available after 50 within 100 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 100 AND 151 and available ='TRUE' THEN 'Available after 100 within 150 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 150 AND 201 and available ='TRUE'  THEN 'Available after 150 within 200 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 200 AND 251 and available ='TRUE' THEN 'Available after 200 within 250 Days'
		WHEN DATEDIFF(DAY,GETDATE(),date) BETWEEN 250 AND 301  AND available ='TRUE'THEN 'Available after 250 within 300 Days'
		END
		AVAILABLITY

		FROM df_dallas_availabilitys A JOIN listing_dallas_dfs C
		ON A.id=C.id)
	

		SELECT room_type,ISNULL(AVAILABLITY,'NA') as Duration ,COUNT(AVAILABLITY) AVAILABLE_PROPERTIES FROM TABLE1
		GROUP BY room_type,AVAILABLITY order by room_type;

	--Acceptance Rate OF property types(Room Types)

		SELECT A.room_type,CAST(AVG(B.host_acceptance_rate) AS DECIMAL(10,2)) AVG_ACC_RATE
		FROM listing_dallas_dfs A JOIN host_dallas_df B
		ON A.host_id=B.host_id
		GROUP BY A.room_type

	--Average no of bookings OF property types(Room Types)
		
		SELECT A.room_type,COUNT(B.listing_id) TOTAL_BOOKINGS FROM listing_dallas_dfs A JOIN review_dallas_dfs B
		ON A.id=B.listing_id
		GROUP BY A.room_type;


	--reviews OF property types(Room Types)
		SELECT room_type,COUNT(B.listing_id) TOTAL_BOOKINGS ,AVG(review_scores_rating) AVG_review_scores_rating,AVG(review_scores_accuracy) AVG_review_scores_accuracy,
		AVG(review_scores_cleanliness) AVG_review_scores_cleanliness,
		AVG(review_scores_communication) AVG_review_scores_communication,AVG(review_scores_location) AVG_review_scores_location,
		AVG(review_scores_value) AVG_review_scores_value
		FROM listing_dallas_dfs A JOIN review_dallas_dfs B
		ON A.id=B.listing_id
		GROUP BY room_type

SELECT * FROM listing_dallas_dfs;

--b. Study the trends of the different categories and provide insights on same
WITH T1 AS(
SELECT B.room_type,AVG(C.host_response_rate) AS Acceptance_Rate,

AVG(B.review_scores_rating) as Rating,
Count(b.bedrooms) as Bedrooms,
AVG(A.PRICE) AS Avg_Price,
max(A.price) as Max_Price,
Min(A.price) as Min_Price
FROM
df_dallas_availabilitys A
JOIN listing_dallas_dfs B
ON A.listing_id=B.id
JOIN host_dallas_df C
ON C.host_id=B.host_id
JOIN review_dallas_dfs D
on D.listing_id=A.listing_id
group by  B.room_type), T2 AS
(SELECT B.room_type,count(case when b.instant_bookable='True' then b.instant_bookable end )
as Instant_Avaliable,
count(case when b.instant_bookable='False' then b.instant_bookable end ) 
as Uninstant_Avaliable
FROM
df_dallas_availabilitys A
JOIN listing_dallas_dfs B
ON A.listing_id=B.id
JOIN host_dallas_df C
ON C.host_id=B.host_id
JOIN review_dallas_dfs D
on D.listing_id=A.listing_id
group by  B.room_type),
T3 AS (
    SELECT ROOM_TYPE, COUNT(room_type) AS COUNT_OF_LISTINGS 
FROM
df_dallas_availabilitys A
JOIN listing_dallas_dfs B
ON A.listing_id=B.id
JOIN host_dallas_df C
ON C.host_id=B.host_id
JOIN review_dallas_dfs D
on D.listing_id=A.listing_id
GROUP BY room_type
)
SELECT T1.*,T3.COUNT_OF_LISTINGS,T2.Instant_Avaliable,T2.Uninstant_Avaliable FROM T1,T2,T3 WHERE T1.room_type=T2.room_type 
AND  T3.ROOM_TYPE=T2.ROOM_TYPE;


--identify top 2 crucial metrics which makes different 
--property types along their listing price stand ahead of other categories 

SELECT B.room_type,count(case when b.instant_bookable='True' then b.instant_bookable end )
as Instant_Avaliable,round(avg(B.price),2) as Price,round(AVG(B.review_scores_cleanliness),2) as Rating_Avg,
count(case when b.instant_bookable='False' then b.instant_bookable end ) 
as Uninstant_Avaliable
FROM
df_dallas_availabilitys A
JOIN listing_dallas_dfs B
ON A.listing_id=B.id
JOIN host_dallas_df C
ON C.host_id=B.host_id
JOIN review_dallas_dfs D
on D.listing_id=A.listing_id
group by  B.room_type order by Uninstant_Avaliable desc;






-- SELECT TOP 1* FROM df_dallas_availabilitys
-- SELECT * FROM review_dallas_dfs
-- SELECT TOP 1* FROM listing_dallas_dfs
-- SELECT TOP 1* FROM host_dallas_df



--d. Analyze how does the comments of reviewers vary for listings of distinct categories(Extract words from the comments provided by the reviewers)
SELECT top 1* From listing_dallas_dfs
select * from review_dallas_dfs;

with cte as(
select l.room_type,
count(case when r.comments like '%good%' or r.comments like '%love%' or r.comments like  '%amazing%' or r.comments like  '%cool%' 
or r.comments like  '%fantastic%' or r.comments like '%very good%' or r.comments like  '%nice%' 
or r.comments like '%satisfied%' or r.comments like '%awesome%' then comments end ) as positive_sentimnents
from review_dallas_dfs r
join listing_dallas_dfs l
on r.listing_id = l.id
group by l.room_type
),
ct2 as ( 
    select l.room_type,
count(case when r.comments like '%bad%' or r.comments like '%unpleasent%' or r.comments like  '%unhygenic%' or r.comments like '%unsatisfied%'
or r.comments like '%worst%' or  r.comments like '%messy%' then comments end) as negative_sentiments
from review_dallas_dfs r
join listing_dallas_dfs l
on r.listing_id = l.id
group by l.room_type)
select cte.*,ct2.negative_sentiments
from cte
join ct2
on cte.room_type = ct2.room_type;





--e. Analyze if there is any correlation between property type and their availability across the months
WITH TABLE1 AS
	(SELECT A.room_type,YEAR(B.DATE) YEAR_,DATENAME(MONTH,B.date) MONTH_,COUNT(B.available) TOTAL_ROOMS 
	FROM listing_dallas_dfs A JOIN df_dallas_availabilitys B
	ON A.id=B.id
	WHERE B.available IN ('TRUE','FALSE')
	GROUP BY A.room_type,YEAR(B.DATE),DATENAME(MONTH,B.date)),
	
	TABLE2 AS
	(SELECT A.room_type,YEAR(B.DATE) YEAR_,DATENAME(MONTH,B.date) MONTH_,COUNT(B.available) AVAILABLE_ROOMS 
	FROM listing_dallas_dfs A JOIN df_dallas_availabilitys B
	ON A.id=B.id
	WHERE B.available LIKE 'TRUE'
	GROUP BY A.room_type,YEAR(B.DATE),DATENAME(MONTH,B.date) ),

	TABLE3 AS
	(SELECT A.room_type,YEAR(B.DATE) YEAR_,DATENAME(MONTH,B.date)  MONTH_,COUNT(B.available) UNAVAILABLE_ROOMS 
	FROM listing_dallas_dfs A JOIN df_dallas_availabilitys B
	ON A.id=B.id
	WHERE B.available LIKE 'FALSE'
	GROUP BY A.room_type,YEAR(B.DATE),DATENAME(MONTH,B.date) )

	SELECT TABLE1.ROOM_TYPE,TABLE1.YEAR_,TABLE1.MONTH_,TOTAL_ROOMS,
	AVAILABLE_ROOMS, UNAVAILABLE_ROOMS FROM TABLE1 JOIN TABLE2 ON TABLE1.ROOM_TYPE=TABLE2.ROOM_TYPE AND TABLE1.YEAR_=TABLE2.YEAR_ AND TABLE1.MONTH_=TABLE2.MONTH_
	JOIN TABLE3 ON TABLE1.ROOM_TYPE=TABLE3.ROOM_TYPE AND TABLE1.YEAR_=TABLE3.YEAR_ AND TABLE1.MONTH_=TABLE3.MONTH_









--f. Analyze what are the peak and off-peak time for the different categories of property type and their listings.
-- Do we see some commonalities in the trend or is it dependent on the category


WITH CTE AS (
SELECT B.room_type AS Room_Type , DATENAME(MONTH,D.DATE) AS Month,COUNT(D.listing_id) AS COUNT_OF_BOOKINGS
FROM
df_dallas_availabilitys A
JOIN listing_dallas_dfs B
ON A.listing_id=B.id
JOIN host_dallas_df C
ON C.host_id=B.host_id
JOIN review_dallas_dfs D
on D.listing_id=A.listing_id
GROUP BY DATENAME(MONTH,D.DATE),B.room_type)

SELECT * FROM (SELECT Room_Type , COUNT_OF_BOOKINGS,Month from CTE ) AS A
PIVOT (SUM (COUNT_OF_BOOKINGS) FOR MONTH IN ([January],[February],[March],[April],[May],
[June],[JULY],[AUGUST],[SEPTEMBER],[OCTOBER],[NOVEMBER],[DECEMBER])) as P









--g. Using the above analysis, suggest what is the best performing category for the company

--BASED ON REVENUE 

SELECT b.room_type,sum(b.price) as Total_Revenue
FROM
df_dallas_availabilitys A
JOIN listing_dallas_dfs B
ON A.listing_id=B.id
JOIN host_dallas_df C
ON C.host_id=B.host_id
JOIN review_dallas_dfs D
on D.listing_id=A.listing_id
group by room_type
