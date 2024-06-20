Q1: who is the senior most employee based on job title?

select * from employee
ORDER BY levels desc
LIMIT 1 

Q2: which countries have the most Invoices?

select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc

Q3: what are top 3 values of total invoices?

select total from invoice
order by total desc
limit 3

Q4: which city has the best customers? we would like to throw a promotional music festival in the city we made the most money. write a query that returns one city that has the highest sum of invoices totals. return both the city name and sum of all invoices totals

select sum(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc

Q5: who is the best customer? the customer who has spent the most money will be declared the best customer. write a query that returns the person who has spent the most money.

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc 
limit 1


set 2

Q1: write query to return the email, first name, last name and genre of all rockmusic listeners. return your list ordered alphabetically by emails starting with A

select distinct email, first_name, last_name
from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
    select track_id from track
	JOIN genre ON track.genre_id = genre.genre_id
	where genre.name LIKE 'Rock'
)
order by email;

Q2: lets invite the artists who have written the most rock music in our dataset. write a query that returns the artist name and totaltrack count of the 10 rock bands

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
group by artist.artist_id
order by number_of_songs DESC
limit 10;

Q3: return all the track names that have a song length longer than the average song length. return the name and milliseconds for each track. order by the song length with the longest songs listed first.

SELECT name, milliseconds
FROM track 
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_lenght
	FROM track)
ORDER BY milliseconds DESC;	 

set 3

Q1: find how much amount spent by each customer on artists? write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
   SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
   SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
   FROM invoice_line
   JOIN track ON track.track_id = invoice_line.track_id
   JOIN album ON album.album_id = track.album_id
   JOIN artist ON artist.artist_id = album.artist_id
   GROUP BY 1
   ORDER BY 3 DESC 
   LIMIT 1  
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) AS amount_spent
from invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2, 3,4
ORDER BY 5 DESC;
  

Q2: we want to find out the most popular music genre for each country. we determine the most popular genre as the genre with the highest amount of purchases. write a query that returns each country along with the top genre. for countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS 
(  
	SELECT COUNT (invoice_line.quantity) AS purchase, customer.country, genre.name, genre.genre_id,
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT (invoice_line.quantity)DESC) AS RowNo
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

Q3: write a query that determines the customer that has spent the most on music for each country. write a query that returns the country along with the top customer and how much they spent. for countries where the top amount spent is shared , provide all customers who spent this amount

WITH RECURSIVE 
    customer_with_country AS (
	   SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
	   FROM invoice
	   JOIN customer ON customer.customer_id = invoice.customer_id
	   GROUP BY 1,2,3,4 
	   ORDER BY 2,3 DESC),
	
	country_max_spending AS(
	   SELECT billing_country,MAX(total_spending) AS max_spending
	   FROM customer_with_country
	   group by billing_country)
	   
SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;
	   
	
	






