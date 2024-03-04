create database if not exists music_database;
use music_database;

Q1). -- Easy --
/* Who is the senior most employee based on job title? */

select * from employee order by levels desc limit 1;

Q2). /* Which countries have the most Invoices? */

select count(*),billing_country from invoice group by billing_country limit 1;

Q3). /* What are top 3 values of total invoice? */

select total from invoice order by total desc limit 3;

Q4)./* Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city
that has the highest sum of invoice totals. Return both the city name & sum of all
invoice totals.*/

SELECT 
    SUM(total) AS total_invoice, billing_city
FROM
    invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;

Q5)./* Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent
the most money.*/

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(i.total) AS total
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total DESC
LIMIT 1;

Q1).-- Moderate --
	
  /*  Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A. */

SELECT 
    c.first_name, c.last_name, c.email
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
        JOIN
    invoice_line AS il ON i.invoice_id = il.invoice_id
        JOIN
    track AS t ON il.track_id = t.track_id
        JOIN
    genre AS g ON g.genre_id = t.genre_id 
    where 
    g.name like 'Rock'
    order by c.email ;
    
    use music_database;
SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

Q2). /*Let's invite the artists who have written the most rock music in our dataset. Write
a query that returns the Artist name and total track count of the top 10 rock
bands. */

use music_database;
SELECT a.artist_id, a.name, COUNT(a.artist_id) AS total_songs
FROM artist AS a
JOIN album2 AS al ON a.artist_id = al.artist_id
JOIN track AS t ON al.album_id = t.album_id
JOIN genre AS g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY total_songs DESC
LIMIT 8;

Q3). /* . Return all the track names that have a song length longer than the average song
length.Return the Name and Milliseconds for each track. Order by the song length
with the longest songs listed first.*/

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;

Q1). -- Advance --
   /* . Find how much amount spent by each customer on artists? Write a query to
return customer name, artist name and total spent.
*/

WITH best_selling_artist AS (
    SELECT
        a.artist_id AS artist_id,
        MAX(a.name) AS artist_name,  -- Use an aggregate function for non-aggregated column
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM
        invoice_line AS il
        JOIN track AS t ON t.track_id = il.track_id
        JOIN album2 AS al ON al.album_id = t.album_id
        JOIN artist AS a ON a.artist_id = al.artist_id
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM
    invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN invoice_line il ON il.invoice_id = i.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN album2 al ON al.album_id = t.album_id
    JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

Q2)./* We want to find out the most popular music Genre for each country. We determine
themost popular genre as the genre with the highest number of purchases. Write a
query that returns each country along with the top Genre. For countries where the
maximumnumber of purchases is shared return all Genres.*/

WITH popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo 
    FROM invoice_line as il
	JOIN invoice as i ON i.invoice_id = il.invoice_id
	JOIN customer as c ON c.customer_id = i.customer_id
	JOIN track as t ON t.track_id = il.track_id
	JOIN genre as g ON g.genre_id = t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

Q3). /* Write a query that determines the customer that has spent the most on music for
each country. Write a query that returns the country along with the top customer
and how much they spent. For countries where the top amount spent is shared,
provide all customers who spent this amount.*/

WITH Customter_with_country AS (
		SELECT c.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice as i
		JOIN customer as c ON c.customer_id = i.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;