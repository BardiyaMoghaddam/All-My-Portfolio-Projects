create TABLE hotel_bookings (
    hotel VARCHAR(100),
    Cancelation_Dummy TINYINT DEFAULT 0,
    lead_time INT,
	Booking_Date Date ,
    arrival_date_week_number INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    Guests_country VARCHAR(50),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    repeated_guest_Dummy TINYINT DEFAULT 0,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    booking_changes INT,
    deposit_type VARCHAR(50),
    agent VARCHAR(50),
    company VARCHAR(50),
    days_in_waiting_list INT,
    customer_type VARCHAR(50),
    Average_Daily_Rate DECIMAL(10, 2),
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(50),
    reservation_status_date DATE,
    Meal_Name VARCHAR(100)
);


SELECT * FROM Hotel_Booking.hotel_bookings;

#Finding the Peak Booking Seasons based on the number of bookings, and arrival_date
select  Arrival_Date, count(arrival_date) as number_of_bookings
FROM hotel_bookings
GROUP BY Arrival_Date
ORDER BY number_of_bookings DESC
LIMIT 3;
#look at the peak dates based on the hotel types seperately
select  hotel, Arrival_Date, count(arrival_date) as number_of_bookings
FROM hotel_bookings
GROUP BY hotel, Arrival_Date
ORDER BY hotel, number_of_bookings DESC;
#Calculate the Average Lead Time for Cancellations to see what is the relationship between the number of days from booking to arrival to cancelation. 
SELECT AVG(lead_time) AS average_lead_time
FROM hotel_bookings
WHERE Cancelation_Dummy = 1;

#which countries the guests came from?
SELECT Guests_country, COUNT(*) AS number_of_guests
FROM hotel_bookings
GROUP BY Guests_country
ORDER BY number_of_guests DESC
limit 3;

# the Distribution of Guests by Country for each hotel seperately
SELECT hotel, Guests_country, COUNT(*) AS number_of_guests
FROM hotel_bookings
GROUP BY hotel, Guests_country
ORDER BY hotel, number_of_guests DESC;

#Market segment

SELECT market_segment, COUNT(market_segment) AS number_of_guests
FROM hotel_bookings
GROUP BY market_segment
ORDER BY number_of_guests DESC
limit 5;

#how the market Segment differs between the two hotels?

SELECT hotel, market_segment, COUNT(market_segment) AS number_of_guests
FROM hotel_bookings
GROUP BY hotel, market_segment
ORDER BY hotel, number_of_guests DESC;

#What is the Average Length of Stay in both hotels?
SELECT hotel, AVG(stays_in_weekend_nights + stays_in_week_nights) AS average_length_of_stay
FROM hotel_bookings
group by hotel
order by average_length_of_stay desc;

#-	What are the Most Common Customer Types for both hotels?
SELECT hotel, customer_type, COUNT(customer_type) AS Count_customer_type 
FROM hotel_bookings 
GROUP BY hotel, customer_type 
ORDER BY Count_customer_type DESC;

select*
from hotel_bookings;

#What is the Total Number of Guests Per Year for each hotel including adults, children, and babies?
SELECT hotel,SUM(Adults + children + babies) AS total_guests
FROM hotel_bookings
group by hotel;

SELECT hotel, YEAR(Arrival_Date) AS year, SUM(Adults + children + babies) AS total_guests
FROM hotel_bookings
GROUP BY hotel, YEAR(Arrival_Date)
ORDER BY YEAR(Arrival_Date),total_guests desc;

CREATE INDEX idx_hotel ON hotel_bookings(hotel);

#what are the most favorite room types in both hotels?

SELECT hotel, reserved_room_type, COUNT(reserved_room_type) AS Count_room_type 
FROM hotel_bookings 
GROUP BY hotel, reserved_room_type 
ORDER BY count_room_type DESC;

