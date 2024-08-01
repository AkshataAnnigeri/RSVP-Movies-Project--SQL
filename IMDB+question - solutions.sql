USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

/* Solution method 1: 
	Taking count of all the rows in each table and joining them*/
select * from
(select count(*) count_director_mapping from director_mapping) director_mapping,
(select count(*) count_genre from genre) genre,
(select count(*) count_movie from movie) movie,
(select count(*) count_names from names) names,
(select count(*) count_ratings from ratings) ratings,
(select count(*) count_role_mapping from role_mapping) role_mapping;

/* Solution method 2:
	Using the Information Schema from the Database and listing out the count of rows in each table.*/

SELECT table_name, 
	table_rows 
    from INFORMATION_SCHEMA.tables 
    WHERE TABLE_SCHEMA = 'imdb';

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q2. Which columns in the movie table have null values?
-- Type your code below:


/* Solution: 
	Getting the count of null values in each of the columns and joining them into a single query*/

select * from 
	(select count(*) null_id from movie where id is null) ID,
	(select count(*) null_title from movie where title is null) title,
	(select count(*) null_year from movie where year is null) year,
	(select count(*) null_date_published from movie where date_published is null) d_p,
	(select count(*) null_duration from movie where duration is null) duration,
	(select count(*) null_country from movie where country is null) country,
	(select count(*) null_worlwide_gross_income from movie where worlwide_gross_income is null) worlwide_gross_income,
	(select count(*) null_languages from movie where languages is null)languages,
	(select count(*) null_production_company from movie where production_company is null) production_company;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/*Solution:

-- Total number of movies released each year*/

select year,count(*) number_of_movies
	from movie
    group by year
    order by year;
    
    
/*Solution:

-- Total number of movies released each month*/

select month(date_published) month_num, count(*) number_of_movies
	from movie
    group by month(date_published)
    order by month(date_published);




/*The highest number of movies is produced in the month of March.
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

/*Solution:

-- Get the count of rows in movie table with country as India or USA */

    
select count(distinct id) as number_of_movies, 
	year from movie
	where ( country ='USA' or country ='INDIA') and 
    year = 2019; 

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:


select distinct genre 
	from genre;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

/* Solution :
-- For overall all years 
	Join genre & movie table and get the count of genres*/
    
select g.genre, count(g.genre) number_of_movies
	from movie m
    inner join genre g
    on m.id = g.movie_id
    group by g.genre
    order by number_of_movies desc
    limit 1;


/* For future reference in question 9
-- For overall all years 
	Join genre & movie table and get the count of genres with filter of year as 2019 */
    
select g.genre, count(g.genre) number_of_movies, year
	from movie m
    inner join genre g
    on m.id = g.movie_id
    where year = 2019
    group by g.genre,year
    order by number_of_movies desc
    limit 1;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

/* Solution :
	movies that belong to only one genre by joining movie and genre tables */
    

with movies_belongingto_one_genre 
	as (select movie_id, count(distinct genre)
		from genre
        group by movie_id
        having count(distinct genre)=1)
SELECT Count(*) AS movies_with_one_genre
	FROM movies_belongingto_one_genre;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/* Solution :
	average duration of movies in each genre is got by joining movie and genre tables */

select genre,round(avg(duration),2) avg_duration
	from movie m
		inner join genre g
		on m.id = g.movie_id
	group by genre
    order by round(avg(duration),2) desc;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

/* Solution :
	average duration of movies in each genre is got by using genre tables */


WITH triller_genre AS
	(SELECT genre, 
        count(movie_id) as movie_count,
		RANK() OVER (ORDER BY count(movie_id) DESC) AS genre_rank
		from genre
		GROUP BY genre)
select * from triller_genre
where genre="THRILLER";



/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:


/* Solution :
	min and max values of all columns in the table ratings */

select 
	round(min(avg_rating)) min_avg_rating,
    round(max(avg_rating)) max_avg_rating,
    round(min(total_votes)) min_total_votes,
    round(max(total_votes)) max_total_votes,
    round(min(median_rating)) min_median_rating,
    round(max(median_rating)) min_median_rating
    from ratings;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too


/* Solution :
	top 10 movies based on average rating by joining movie and ratings table */


-- top 10 using rank

select title,
	avg_rating,
    rank() over(order by avg_rating desc) movie_rank
    from movie m
		inner join ratings r
        on r.movie_id = m.id
	limit 10;


-- top 10 moving using dense rank

select title,
	avg_rating,
    dense_rank() over(order by avg_rating desc) movie_rank
    from movie m
		inner join ratings r
        on r.movie_id = m.id
	limit 10;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

/* Solution :
	movie count by median ratings is got by joining movie table with ratings table 
    with gropu by on median_rating */

select median_rating,
	count(title) movie_count
    from movie m
		inner join ratings r
		on r.movie_id = m.id
	group by median_rating
    order by movie_count desc;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:


/* Solution :
	production house that produced the most number of hit movies got by joining the following tables movie and ratings grouped on produciton company 
    with condition as average rating in greater than 8*/

select production_company,
	count(title) movie_count,
    dense_rank() over( order by count(title) desc)prod_company_rank
    from movie m
		inner join ratings r
		on r.movie_id = m.id
	where production_company is not null
		and avg_rating > 8
	group by production_company
    limit 1;



-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/* Solution :
	movies released in each genre during March 2017 in the USA that had more than 1,000 votes
    is got by joning follwing tables movie, ratings, genre*/


SELECT genre, COUNT(id) as movie_count
	from genre as g 
		inner join ratings as r 
		on g.movie_id=r.movie_id
		inner join movie as m
		on r.movie_id=m.id
	WHERE year=2017
		and month(date_published)=3
		and country='USA'
		and total_votes>1000
	group by genre
	order by count(id) desc;



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

/* Solution :
	movies of each genre that start with the word ‘The’ and which have an average rating > 8
    is got by joning follwing tables movie, ratings, genre with avg rating above 8 */

select title,
	avg_rating,
	genre
    from movie m
		inner join ratings r
        on r.movie_id = m.id
        inner join genre g
        on g.movie_id = r.movie_id
	where title like 'The%'
		and avg_rating>8
        group by genre
    order by title desc;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

/* Solution :
	movies released between 1 April 2018 and 1 April 2019 count of them having ratings 8
    is got by joning follwing tables movie, ratings with median rating  8 */

select count(movie_id) as movie_count 
	from ratings as r
		inner join movie as m
		on r.movie_id=m.id
	where date_published between '2018-4-1' and '2019-4-1'
		and median_rating = 8;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


/* Solution :
	To find if german movies get more votes than italian movies */

with votes_summary as    -- common table expression to get the sum of votes of german and italian movies
	(select 
		case 
        when languages like '%German%' Then 'German'
        else 'Italian'
        end as lang,
		sum(total_votes) sum_of_votes
		from movie m
			inner join ratings r
			on m.id = r.movie_id
		where languages like '%German%'
			or languages like '%Italian%'
		group by lang
        order by sum(total_votes) desc
        limit 1) -- limiting it by one in descending order so that the city having highest votes is queried
select 
	case 
    when lang = 'Italian' then 'No'
    when lang = 'German' then 'Yes'
    end as 'Do German movies get more votes than Italian movies ?'
    from votes_summary;
    
-- with the help of CTE votes summary we are able to get the yes or no answer and here its Yes for given data
-- meaning german movies get higher votes than italian



-- Answer is Yes
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

/*Solution:
	 to find columns in the names table have null values or not*/

select * from 
	(select count(*) name_nulls from names where name is null) name_nulls,
	(select count(*) height_nulls from names where height is null) height_nulls,
	(select count(*) date_of_birth_nulls from names where date_of_birth is null) date_of_birth_nulls,
	(select count(*) known_for_movies_nulls from names where known_for_movies is null) known_for_movies_nulls;


/* There are no Null value in the column 'name'.

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/*Solution:
	To get the top three directors in the top three genres with average rating greater than 8*/

with genere_summary as  -- CTE to get the top 3 genres from ratings joined with genre table 
(select genre,
	count(r.movie_id) movie_count,
    round(avg(avg_rating),1) avg_rating
    from ratings r
		inner join genre g
        on r.movie_id = g.movie_id
    where avg_rating>8
    group by genre
    order by movie_count desc
    limit 3)
select name director_name,
	count(m.id) movie_count
    from names n
		inner join director_mapping d
        on n.id = d.name_id
		inner join movie m
        on d.movie_id = m.id
        inner join genre g 
        on g.movie_id = m.id
        inner join ratings r
        on g.movie_id = r.movie_id
	where r.avg_rating>8 and g.genre in (select genre from genere_summary)
    group by director_name
    order by movie_count desc
    limit 3;
-- The top 3 directors are got by joining the CTE with the follwing tables movie,director mapping, names, genre, ratings




/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/*Solution:
	To get the top 2 actors having movie rating atleast 8*/ 
    
select distinct name as actor_name, 
	count(r.movie_id) as movie_count
    from ratings r
    inner join role_mapping r_m
    on r_m.movie_id = r.movie_id
    inner join names n
    on n.id = r_m.name_id
    where r.median_rating >= 8
		and r_m.category = 'actor'
	group by actor_name
    order by movie_count desc
    limit 2;



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

/* Solution:
	Top 3 produciton houses is found by getting rank over sum of total votes in descending order
    and by joining movie, ratings tables*/
select production_company,
	sum(total_votes) vote_count,
    dense_rank() over(order by sum(total_votes) desc) prod_comp_rank
    from movie m
		inner join ratings r
		on r.movie_id = m.id
    group by production_company
    limit 3;



/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


/*Solution:
	To get the indian actor having good rating with atleast 5 movie acted 
    we can get it by joining the movie, ratings, names,role_mapping tables 
    with country as India and categoty as Actor
    
    Also weighted average based on votes is calculated by multiplying 
    average rating with total votes and dividing by the sum of total votes per actor
    Using this eighted average we could issue ranking in descending order 
    being the higest average at top*/
    
select name actor_name,
	total_votes,
    count(m.id) movie_count,
    round(sum(avg_rating * total_votes)/sum(total_votes),2) actor_avg_rating,
    rank() over(order by round(sum(avg_rating * total_votes)/sum(total_votes),2) desc) actor_rank
    from movie m
		inner join ratings r
        on r.movie_id = m.id
        inner join role_mapping r_m
        on r_m.movie_id = m.id
		inner join names n
        on n.id = r_m.name_id
	where country = 'India'
		and category = 'actor'
	group by name
    having movie_count>=5
	limit 3;






-- Top actor is Vijay Sethupathi
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

/*Solution:
	To get the indian actoress having good rating with atleast 3 Indian movie acted 
    we can get it by joining the movie, ratings, names,role_mapping tables 
    with country as India and categoty as Actoress with language Hindi
    
    Also weighted average based on votes is calculated by multiplying 
    average rating with total votes and dividing by the sum of total votes per actoress
    Using this eighted average we could issue ranking in descending order 
    being the higest average at top*/


select name actress_name,
	total_votes,
    count(m.id) movie_count,
    round(sum(avg_rating * total_votes)/sum(total_votes),2) actress_avg_rating,
    rank() over(order by round(sum(avg_rating * total_votes)/sum(total_votes),2) desc) actress_rank
    from movie m
		inner join ratings r
        on r.movie_id = m.id
        inner join role_mapping r_m
        on r_m.movie_id = m.id
		inner join names n
        on n.id = r_m.name_id
	where country = 'India'
		and category = 'actress'
        and languages like '%Hindi%'
	group by name
    having count(m.country='India')>=3
	limit 3;



/* Taapsee Pannu tops with average rating 7.74. 
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

/*Solution:
	Case element is used here to build a new categorization with the ratings column
    The required result is got by joining movie,genre and ratings tables
    with genre as thriller */
    
select title,
	avg_rating,
    case
    when avg_rating > 8 then 'Superhit movies'
    when avg_rating between 7 and 8 then 'Hit movies'
    when avg_rating between 5 and 7 then 'One-time-watch movies'
    when avg_rating < 5 then 'Flop movies'
    end as Rating_category
    from movie m
		inner join ratings r
        on r.movie_id = m.id
        inner join genre g
        on g.movie_id = m.id
	where genre = 'Thriller'
    order by avg_rating desc;



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


/*Solution:
	Genre wise running total and moving average requires joins on move, genre tables
    running total duration is found by summing the average duration with the column genre option as unbounded preceeding
    also the moving average can be found by taking average of duration over genre with 10 as preceeding rows as an assumed*/

select genre,
	round(avg(duration)) avg_duration,
    sum(round(avg(duration),2)) over( order by genre rows unbounded preceding) running_total_duration,
    round(avg(round(avg(duration),2)) over(order by genre rows 10 preceding),2) moving_avg_duration
    from movie m
		inner join genre g
        on g.movie_id = m.id
	group by genre
    order by genre;




-- Round is good to have and not a must have; Same thing applies to sorting
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
/*Solution:
	to get Top 3 genres based on most number of movies 
    We first find the movie count genre wise in CTE by joining genre and movie tables
    We then find the rank of world gross income partioned yar wise and joining movie and genre tables,
    also by filtering out the genres from the CTE list.*/
with top_3 as
(select genre,
	count(g.movie_id) movie_count
    from genre g
		inner join movie m
        on m.id = g.movie_id
    group by genre
    order by movie_count desc
    limit 3
)
select * 
	from
		(select genre,
			year,
			title movie_name,
			m.worlwide_gross_income,
			dense_rank() over(partition by year order by worlwide_gross_income desc) movie_rank
			from movie m
				inner join genre g
				on g.movie_id = m.id
			where genre in ( select genre from top_3)) grossing_movies
	where movie_rank <= 5;

/* Fixing the currency difference
   We find that there are couple of values in INR and the rest in $ currency format.
   In order to fix this we could take a step either to multiply $ value by 80 and convert it to INR
   or divide INR value and convert it to $.
   On an assumption that one dollar is equal to 80 INR approx
   
   Here considering to convert INR to $ */
with top_3 as
(select genre,
	count(g.movie_id) movie_count
    from genre g
		inner join movie m
        on m.id = g.movie_id
    group by genre
    order by movie_count desc
    limit 3
)
select * 
	from
		(select *, dense_rank() over(partition by year order by worlwide_gross_income desc) movie_rank
			from
				(select genre,
					year,
					title movie_name,
					case 
					when worlwide_gross_income like 'INR%' then 
						(select concat('$ ',(SELECT SUBSTRING_INDEX(worlwide_gross_income,' ',-1)/80)))
					else worlwide_gross_income
					end as worlwide_gross_income
					from movie m
					inner join genre g
					on g.movie_id = m.id
					where genre in ( select genre from top_3)) grossing_movies)grossing_movies_altered
	where movie_rank <= 5;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

/*Solution:
	Top two production houses with highest hits can be found by joining movie, ratings
    To get only multilingual films we can search for the position of comma in the languages column
		If the position is 0 then its single language movie
        if position is greater than 0 its multilingual
	Eliminated null in production company names to filter only not null values*/
    
select production_company,
	count(id) movie_count,
    dense_rank() over(order by count(id) desc) prod_comp_rank
    from movie m
		inner join ratings r
		on r.movie_id = m.id
    where position(',' in languages) > 0
		and production_company is not null
        and median_rating >= 8
    group by production_company
    limit 2;



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

/*Solution :
	To get the top 3 actress based on hit movies 
    rank on average rating per actress and count of movies acted
    filtered by average ratig greater than 8 */

select name,
	sum(total_votes) total_votes,
    count(r.movie_id) movie_count,
    round(avg(avg_rating),2) actress_avg_rating,
    dense_rank() over( order by round(avg(avg_rating),2) desc) actress_rank
    from names n
		inner Join role_mapping r_m
        on r_m.name_id = n.id
        inner join ratings r
        on r.movie_id = r_m.movie_id
        inner join genre g
        on g.movie_id = r.movie_id
	where category = 'actress'
		and avg_rating > 8
        and genre = 'drama'
        group by name
	limit 3;



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

/*Solution :
	Steps to find the requested details for top  directors
    Explanation for sub-Queries and common table expression
		date_diff       			=   lead by 1 over partioned name id of director for the date_published column 
										so as to make it ease for finding date difference
        final_date_diff 			=   to get the difference of date published and found using the date_diff result
        avg_inter_movie_days_query	=	to get average date difference per director from the result of final_date_diff ( Common table Expression -CTE)
        Final						=	To get the required results by joining the director mapping, names, movie, ratings and the CTE 
										Director id - Direct usage
										Name - Direct usage
										Number of movies - count of movieid
										Average inter movie duration in days - got from CTE
										Average movie ratings - average of avg movie rating
										Total votes - sum of total votes
										Min rating - min fuction on ratings
										Max rating - max funciton on ratings
										total movie durations - sum of duration 
	Order by using row number on count of movies in descending */
    
                                        
with avg_inter_movie_days_query as
	(select name_id,
		avg(date_difference) avg_inter_movie_days
		from
			(select *,
				datediff(next_movie_date,date_published) date_difference 
				from
					(select d.name_id,
						name,
						d.movie_id,
						date_published,
						lead(date_published,1) over(partition by d.name_id order by date_published, d.movie_id) next_movie_date
						from director_mapping d
							inner join names n
							on n.id = d.name_id
							inner join movie m
							on m.id = d.movie_id)date_diff
							)final_date_diff
                            group by name_id)
select director_id, director_name, number_of_movies, avg_inter_movie_days, avg_rating,
	total_votes, min_rating, max_rating, total_duration
    from(
		select d.name_id director_id,
			name director_name,
			count(d.movie_id) number_of_movies,
			round(avg_inter_movie_days) avg_inter_movie_days,
			round(avg(avg_rating),2) avg_rating,
			sum(total_votes) total_votes,
			min(avg_rating) min_rating,
			max(avg_rating) max_rating,
			sum(duration) total_duration,
			row_number() over(order by count(d.movie_id) desc) director_rank
			from names n
				inner join director_mapping d
				on d.name_id = n.id
				inner join movie m
				on m.id = d.movie_id
				inner join avg_inter_movie_days_query a
				on a.name_id = d.name_id
				inner join ratings r
				on r.movie_id = d.movie_id
				group by director_id
				limit 9)Final ;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


