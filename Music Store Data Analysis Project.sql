-- Set 1)
-- Q1)
select * from employee
order by levels desc
limit 1

-- Q2)
select * from invoice
select billing_country, count(invoice_id)
from invoice
group by billing_country
order by count desc

-- Q3)
select total from invoice
order by total desc
limit 3

-- Q4) 
select * from invoice
select billing_city, sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc

-- Q5) 
select * from customer
select * from invoice
	
select customer.customer_id, customer.first_name,customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id 
order by total desc 
limit 1

-- Set 2)
-- Q1)
select * from customer
select * from invoice
select * from invoice_line
select * from genre
select * from track

select distinct email, first_name, last_name
from customer 
join invoice on customer.customer_id = invoice.invoice_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email asc

-- Q2)
select * from artist
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id 
join artist on artist.artist_id = album.artist_id 
join genre on  genre.genre_id = track.genre_id                    
where genre.name like 'Rock'
group by artist.artist_id 
order by number_of_songs desc
limit 10

-- Q3) 
select * from track
select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) 
	from track)
order by milliseconds desc

-- Set 3)
-- Q1)	
WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, 
           artist.name AS artist_name, 
           SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
    LIMIT 1
)  
SELECT customer.first_name, 
       customer.last_name, 
       bsa.artist_id,
       SUM(invoice_line.unit_price * invoice_line.quantity) AS amount_spent
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = album.artist_id
GROUP BY customer.first_name, customer.last_name, bsa.artist_id
ORDER BY amount_spent DESC;

-- Q2) 
WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purches, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <=1

-- Q3) 
WITH customer_with_country AS (
	SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	from invoice 
	join customer on customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC )
SELECT * FROm customer_with_country WHERE RowNo<=1