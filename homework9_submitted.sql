# Homework Assignment

## Installation Instructions

* Refer to the [installation guide](Installation.md) to install the necessary files.

## Instructions

-------------
-- run db
-------------

USE sakila;

-----------------------------------------------------------------------------
* 1a. Display the first and last names of all actors from the table `actor`.
-----------------------------------------------------------------------------

select
first_name,
last_name
from actor;

-----------------------------------------------------------------------------------------------------------------------------
* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
-----------------------------------------------------------------------------------------------------------------------------

select 
concat(first_name, " ", last_name) as 'Actor Name'
FROM actor;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
first_name,
last_name
from actor
where first_name = "Joe";

----------------------------------------------------------------
* 2b. Find all actors whose last name contain the letters `GEN`:
----------------------------------------------------------------

select 
last_name
from actor
where last_name like ("%GEN%");

--------------------------------------------------------------------------------------------------------------------------------------
* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
--------------------------------------------------------------------------------------------------------------------------------------

select 
last_name,
first_name
from actor
where last_name like ("%LI%")
order by last_name, first_name;

--------------------------------------------------------------------------------------------------------------------------------
* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
--------------------------------------------------------------------------------------------------------------------------------

select 
country_id,
country
from country
where country in ("Afghanistan", "Bangladesh", "China");

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE actor
ADD COLUMN description blob;

-----------------------------------------------------------------------------------------------------------------------------
* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
-----------------------------------------------------------------------------------------------------------------------------

alter table actor drop column description;

-------------------------------------------------------------------------------------
* 4a. List the last names of actors, as well as how many actors have that last name.
-------------------------------------------------------------------------------------

select
last_name,
count(last_name) as count
from actor
GROUP BY last_name;

-------------------------------------------------------------------------------------------------------------------------------------------
* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
-------------------------------------------------------------------------------------------------------------------------------------------

select
last_name,
count(last_name) as count
from actor
GROUP BY last_name
having count >=2;

--------------------------------------------------------------------------------------------------------------------------------------
* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
--------------------------------------------------------------------------------------------------------------------------------------

update actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO"
AND last_name = "WILLIAMS";

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

update actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO"
AND last_name = "WILLIAMS";

------------------------------------------------------------------------------------------------------------------------------------------
* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

  * Hint: [https:--dev.mysql.com-doc-refman-5.7-en-show-create-table.html](https:--dev.mysql.com-doc-refman-5.7-en-show-create-table.html)
-------------------------------------------------------------------------------------------------------------------------------------------

show create table address;

address	CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

----------------------------------------------------------------------------------------------------------------------------------------
* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
-----------------------------------------------------------------------------------------------------------------------------------------

select first_name, last_name, address, address2, district, city_id, postal_code
from address as a
inner join staff as s
	on a.address_id = s.address_id;
        
------------------------------------------------------------------------------------------------------------------------------
* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
------------------------------------------------------------------------------------------------------------------------------

select staff_id, sum(amount) 
from payment
where payment_date between '2005-08-01' and '2005-08-31'
group by staff_id;

-------------------------------------------------------------------------------------------------------------------------------
* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
-------------------------------------------------------------------------------------------------------------------------------

select 
title,
count(actor_id) as 'number of actors'
from film_actor
inner join film
	on film.film_id = film_actor.film_id   
group by title;

----------------------------------------------------------------------------------------
* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
----------------------------------------------------------------------------------------

select 
title, count(title)
from inventory
inner join film
	on inventory.film_id = film.film_id
where title = 'Hunchback Impossible';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

  ![Total amount paid](Images-total_payment.png)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

  select 
  c.last_name as customer,
  sum(p.amount) as amount
  from customer as c
  join payment as p on p.customer_id = c.customer_id
  group by c.customer_id
  order by customer;  
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
title
from film
	where title like "K%" 
	or title like "Q%"
    and language_id = (select language_id from language where name = 'English');    

-------------------------------------------------------------------------------
* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
-------------------------------------------------------------------------------

select
actor_id,
first_name,
last_name
from actor 
where actor_id in (select actor_id from film_actor 
where film_id  in (select film_id from film
where title = "Alone Trip")
);

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select address
first_name,
last_name,
email 
from customer
join address on customer.address_id = address.address_id
join city on city.city_id = address.city_id 
join country on country.country_id = city.country_id
where country = 'Canada';

--------------------------------------------------------------------------------------------------------------------------------------------------------------
* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
--------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
name as 'category',
title
from film
join film_category on film.film_id = film_category.film_id 
join category on film_category.category_id = category.category_id
where category.name = "Family";

---------------------------------------------------------------------
* 7e. Display the most frequently rented movies in descending order.
---------------------------------------------------------------------

select
title, count(title) as 'rental count'
from film
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by title
order by count(title) desc;

-----------------------------------------------------------------------------------
* 7f. Write a query to display how much business, in dollars, each store brought in.
-----------------------------------------------------------------------------------

select 
store_id,
sum(amount) as dollars
FROM payment
join staff on payment.staff_id = staff.staff_id
group by store_id;

-----------------------------------------------------------------------------
* 7g. Write a query to display for each store its store ID, city, and country.
-----------------------------------------------------------------------------

select 
store_id,
city.city,
country.country
from store
join address on store.address_id = address.address_id 
join city on address.city_id = city.city_id 
join country on city.country_id = country.country_id;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
category.name,
sum(amount) as "gross revenue"
FROM payment
join rental on payment.rental_id = rental.rental_id
join inventory on rental.inventory_id = inventory.inventory_id
join film_category on inventory.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
group by name
order by sum(amount) desc
limit 5;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW top_five_genres_by_gross_revenue AS
select 
category.name,
sum(amount) as "gross revenue"
FROM payment
join rental on payment.rental_id = rental.rental_id
join inventory on rental.inventory_id = inventory.inventory_id
join film_category on inventory.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
group by name
order by sum(amount) desc
limit 5;

------------------------------------------------------------
* 8b. How would you display the view that you created in 8a?
------------------------------------------------------------

select * from top_five_genres_by_gross_revenue;

---------------------------------------------------------------------------------------------
* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
---------------------------------------------------------------------------------------------

DROP VIEW top_five_genres_by_gross_revenue;



## Appendix: List of Tables in the Sakila DB

* A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

```sql
'actor'
'actor_info'
'address'
'category'
'city'
'country'
'customer'
'customer_list'
'film'
'film_actor'
'film_category'
'film_list'
'film_text'
'inventory'
'language'
'nicer_but_slower_film_list'
'payment'
'rental'
'sales_by_film_category'
'sales_by_store'
'staff'
'staff_list'
'store'
```

## Uploading Homework

* To submit this homework using BootCampSpot:

  * Create a GitHub repository.
  * Upload your .sql file with the completed queries.
  * Submit a link to your GitHub repo through BootCampSpot.
  
  

