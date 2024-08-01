/*Question 1:

Level: Simple

Topic: DISTINCT

Task: Create a list of all the different (distinct) replacement costs of the films.

Question: What's the lowest replacement cost?

Answer: 9.99*/
select distinct(replacement_cost) from film order by replacement_cost;

-----------------------------------------------------------------------------------------

/*Question 2:

Level: Moderate

Topic: CASE + GROUP BY

Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges

low: 9.99 - 19.99

medium: 20.00 - 24.99

high: 25.00 - 29.99

Question: How many films have a replacement cost in the "low" group?

Answer: 514*/
select
case 
	when replacement_cost <= 19.99 then 'Low'
	when replacement_cost <= 24.99 then 'Medium'
	when replacement_cost <= 29.99 then 'High'
end as category,
count(*)
from film
group by category
order by count(*) desc;

-----------------------------------------------------------------------------------------

/*Question 3:

Level: Moderate

Topic: JOIN

Task: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.

Question: In which category is the longest film and how long is it?

Answer: Sports and 184*/
select 
title, length, name
from film f
inner join film_category fc
on f.film_id=fc.film_id
inner join category c
on c.category_id=fc.category_id
where name in ('Drama','Sports')
order by length desc;

-----------------------------------------------------------------------------------------

/*Question 4:

Level: Moderate

Topic: JOIN & GROUP BY

Task: Create an overview of how many movies (titles) there are in each category (name).

Question: Which category (name) is the most common among the films?

Answer: Sports with 74 titles*/
select 
name, count(title)
from film f
inner join film_category fc
on f.film_id=fc.film_id
inner join category c
on c.category_id=fc.category_id
group by name
order by count(title) desc;

-----------------------------------------------------------------------------------------

/*Question 5:

Level: Moderate

Topic: JOIN & GROUP BY

Task: Create an overview of the actors' first and last names and in how many movies they appear in.

Question: Which actor is part of most movies??

Answer: Susan Davis with 54 movies*/
select
first_name,last_name,count(*) from Actor a
inner join film_actor fa
on fa.actor_id=a.actor_id
inner join film f
on fa.film_id=f.film_id
group by first_name,last_name
order by count(*) desc;

-----------------------------------------------------------------------------------------

/*Question 6:

Level: Moderate

Topic: LEFT JOIN & FILTERING

Task: Create an overview of the addresses that are not associated to any customer.

Question: How many addresses are that?

Answer: 4*/
select a.address_id,address from address a
left join customer c
on a.address_id=c.address_id
where c.* is null;

-----------------------------------------------------------------------------------------

/*Question 7:

Level: Moderate

Topic: JOIN & GROUP BY

Task: Create the overview of the sales  to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur.

Question: What city is that and how much is the amount?

Answer: Cape Coral with a total amount of 221.55*/
select 
city,count(*),sum(amount)
from city c 
inner join address a 
on a.city_id=c.city_id
inner join customer cu
on a.address_id=cu.address_id
inner join payment p
on cu.customer_id=p.customer_id
group by city
order by sum(amount) desc;

-----------------------------------------------------------------------------------------

/*Question 8:

Level: Moderate to difficult

Topic: JOIN & GROUP BY

Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".

Question: Which country, city has the least sales?

Answer: United States, Tallahassee with a total amount of 50.85.*/
select 
country,city,count(*),sum(amount)
from city c 
inner join country co
on co.country_id=c.country_id
inner join address a 
on a.city_id=c.city_id
inner join customer cu
on a.address_id=cu.address_id
inner join payment p
on cu.customer_id=p.customer_id
group by country,city
order by sum(amount);

-----------------------------------------------------------------------------------------

/*Question 9:

Level: Difficult

Topic: Uncorrelated subquery

Task: Create a list with the average of the sales amount each staff_id has per customer.

Question: Which staff_id makes on average more revenue per customer?

Answer: staff_id 2 with an average revenue of 56.64 per customer.*/
select staff_id, 
round(sum(amount)/count(distinct(customer_id)),2) as avg_per_customer
from payment
group by staff_id
order by avg_per_customer desc;

-----------------------------------------------------------------------------------------

/*Question 10:

Level: Difficult to very difficult

Topic: EXTRACT + Uncorrelated subquery

Task: Create a query that shows average daily revenue of all Sundays.

Question: What is the daily average revenue of all Sundays?

Answer: 1410.65*/
select 
round(sum(amount)/count(distinct(to_char(payment_date,'dd-mm-yyyy'))),2) as avg_amount
from (select * from payment where extract(dow from payment_date)=0);

-----------------------------------------------------------------------------------------

/*Question 11:

Level: Difficult to very difficult

Topic: Correlated subquery

Task: Create a list of movies - with their length and their replacement cost - that are longer than the average length in each replacement cost group.

Question: Which two movies are the shortest on that list and how long are they?

Answer: CELEBRITY HORN and SEATTLE EXPECTATIONS with 110 minutes.*/
select
title, length, replacement_cost
from film f1
where length > (select avg(length) from film f2
					where f1.replacement_cost=f2.replacement_cost)
order by length;

-----------------------------------------------------------------------------------------

/*Question 12:

Level: Very difficult

Topic: Uncorrelated subquery

Task: Create a list that shows the "average customer lifetime value" grouped by the different districts.

Example:
If there are two customers in "District 1" where one customer has a total (lifetime) spent of $1000 and the second customer has a total spent of $2000 then the "average customer lifetime spent" in this district is $1500.

So, first, you need to calculate the total per customer and then the average of these totals per district.

Question: Which district has the highest average customer lifetime value?

Answer: Saint-Denis with an average customer lifetime value of 216.54.*/
select district,
round(sum(amount)/count(distinct(c.customer_id)),2) as avg_lftm_spent
from customer c
inner join payment p
on c.customer_id = p.customer_id
inner join address a 
on a.address_id = c.address_id
group by district
order by avg_lftm_spent desc;

-----------------------------------------------------------------------------------------

/*Question 13:

Level: Very difficult

Topic: Correlated query

Task: Create a list that shows all payments including the payment_id, amount, and the film category (name) plus the total amount that was made in this category. Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.

Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?

Answer: Total revenue in the category 'Action' is 4375.85 and the lowest payment_id in that category is 16055.*/
select payment_id,amount,name,
	(select category_total from 
		(select name,sum(amount) as category_total
		from payment p
		inner join rental r on p.rental_id=r.rental_id
		inner join inventory i on i.inventory_id=r.inventory_id
		inner join film_category f on f.film_id=i.film_id
		inner join category ca on ca.category_id=f.category_id
		group by name) t1
	where ca.name=t1.name)
from payment p
inner join rental r on p.rental_id=r.rental_id
inner join inventory i on i.inventory_id=r.inventory_id
inner join film_category f on f.film_id=i.film_id
inner join category ca on ca.category_id=f.category_id
order by name,payment_id;

-----------------------------------------------------------------------------------------

/*Bonus question 14:

Level: Extremely difficult

Topic: Correlated and uncorrelated subqueries (nested)

Task: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name).

Question: Which is the top-performing film in the animation category?

Answer: DOGMA FAMILY with 178.70.*/
select * from (
select name,title,sum(amount) as revenue
from film f
inner join film_category fc
on fc.film_id=f.film_id
inner join category c
on c.category_id=fc.category_id
inner join inventory i
on i.film_id=f.film_id
inner join rental r 
on r.inventory_id=i.inventory_id
inner join payment p
on p.rental_id=r.rental_id
group by name,title
) t1
where revenue = (select max(revenue) from (select name,title,sum(amount) as revenue
											from film f
											inner join film_category fc
											on fc.film_id=f.film_id
											inner join category c
											on c.category_id=fc.category_id
											inner join inventory i
											on i.film_id=f.film_id
											inner join rental r 
											on r.inventory_id=i.inventory_id
											inner join payment p
											on p.rental_id=r.rental_id
											group by name,title
											) t2
					where t1.name=t2.name)
order by name;

-----------------------------------------------------------------------------------------
