/*
Question #1:
Calculate the number of flights with a departure time during the work week (Monday through Friday) and the number of flights departing during the weekend (Saturday or Sunday).

Expected column names: working_cnt, weekend_cnt
*/

-- q1 solution:

SELECT 
    SUM(CASE WHEN EXTRACT(ISODOW FROM departure_time) IN (1,2,3,4,5) THEN 1 ELSE 0 END) AS working_cnt,
    SUM(CASE WHEN EXTRACT(ISODOW FROM departure_time) IN (6,7) THEN 1 ELSE 0 END) AS weekend_cnt
FROM flights;

/*

Question #2: 
For users that have booked at least 2  trips with a hotel discount, 
it is possible to calculate their average hotel discount, and maximum hotel discount. write a solution to find users whose maximum hotel discount is strictly greater than the max average discount across all users.

Expected column names: user_id

*/

-- q2 solution:

WITH UserHotelDiscounts AS (
    SELECT
        user_id,
        MAX(hotel_discount_amount) AS max_hotel_discount,
        AVG(hotel_discount_amount) AS avg_hotel_discount
    FROM sessions
    WHERE hotel_discount = TRUE
      AND hotel_booked = TRUE
      AND cancellation = FALSE
    GROUP BY user_id
    HAVING COUNT(DISTINCT trip_id) >= 2
),
MaxAvgHotelDiscount AS (
    SELECT MAX(avg_hotel_discount) AS max_avg_hotel_discount
    FROM UserHotelDiscounts
)
SELECT user_id
FROM UserHotelDiscounts
CROSS JOIN MaxAvgHotelDiscount
WHERE max_hotel_discount > max_avg_hotel_discount;

/*
Question #3: 
when a customer passes through an airport we count this as one “service”.

for example:

suppose a group of 3 people book a flight from LAX to SFO with return flights. In this case the number of services for each airport is as follows:

3 services when the travelers depart from LAX

3 services when they arrive at SFO

3 services when they depart from SFO

3 services when they arrive home at LAX

for a total of 6 services each for LAX and SFO.

find the airport with the most services.

Expected column names: airport

*/

-- q3 solution:

WITH AirportServices AS (
    SELECT origin_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY origin_airport
    UNION ALL
    SELECT destination_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY destination_airport
)
SELECT airport
FROM AirportServices
GROUP BY airport
ORDER BY SUM(services) DESC
LIMIT 1;
/*
Question #4: 
using the definition of “services” provided in the previous question, we will now rank airports by total number of services. 

write a solution to report the rank of each airport as a percentage, where the rank as a percentage is computed using the following formula: 

`percent_rank = (airport_rank - 1) * 100 / (the_number_of_airports - 1)`

The percent rank should be rounded to 1 decimal place. airport rank is ascending, such that the airport with the least services is rank 1. If two airports have the same number of services, they also get the same rank.

Return by ascending order of rank

E**xpected column names: airport, percent_rank**

Expected column names: airport, percent_rank
*/

-- q4 solution:

WITH AirportServices AS (
    SELECT origin_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY origin_airport
    UNION ALL
    SELECT destination_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY destination_airport
),
RankedAirports AS (
    SELECT 
        airport,
        SUM(services) AS total_services,
        RANK() OVER (ORDER BY SUM(services) ASC) AS airport_rank
    FROM AirportServices
    GROUP BY airport
)
SELECT 
    airport,
    ROUND((airport_rank - 1) * 100.0 / (MAX(airport_rank) OVER () - 1), 1) AS percent_rank
FROM RankedAirports
ORDER BY airport_rank;









