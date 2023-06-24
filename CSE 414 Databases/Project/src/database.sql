
CREATE TABLE person (
    person_ID INT AUTO_INCREMENT PRIMARY KEY,
    person_name VARCHAR(25) NOT NULL,
    person_surname VARCHAR(25) NOT NULL
);

CREATE TABLE customer (
    customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(25),
    customer_surname VARCHAR(25),
    customer_phone VARCHAR(25) NOT NULL,
    email VARCHAR(60) NOT NULL,
    FOREIGN KEY (customer_ID) REFERENCES person(person_ID) ON DELETE RESTRICT
);

CREATE TABLE customer_address (
    address_ID INT AUTO_INCREMENT PRIMARY KEY,
    customer_ID INT,
    address_text VARCHAR(200) NOT NULL,
    FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID) ON DELETE RESTRICT
);

CREATE TABLE employee (
    employee_ID INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(25),
    employee_surname VARCHAR(25),
    FOREIGN KEY (employee_ID) REFERENCES person(person_ID) ON DELETE RESTRICT
);

CREATE TABLE orders (
    orders_ID INT AUTO_INCREMENT PRIMARY KEY,
    orders_Status VARCHAR(20) NOT NULL,
    request_date DATE NOT NULL
);

CREATE TABLE placed_order (
       orders_ID INT,
       customer_ID INT,
       FOREIGN KEY (orders_ID) REFERENCES orders(orders_ID) ON DELETE RESTRICT,
       FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID) ON DELETE RESTRICT  
);

CREATE TABLE order_prepare (
    orders_ID INT,
    employee_ID INT,
    FOREIGN KEY (orders_ID) REFERENCES orders(orders_ID) ON DELETE RESTRICT,
    FOREIGN KEY (employee_ID) REFERENCES employee(employee_ID) ON DELETE RESTRICT
);

CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(50),
    product_description VARCHAR(1000),
    product_price NUMERIC(10, 2) NOT NULL,
    product_rating NUMERIC(4, 2)
);

CREATE TABLE ordered_product (
    product_id INT,
    orders_ID INT,
    product_quantity INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE RESTRICT,
    FOREIGN KEY (orders_ID) REFERENCES orders(orders_ID) ON DELETE RESTRICT
);

CREATE TABLE payment (
    payment_ID INT AUTO_INCREMENT PRIMARY KEY,
    payment_date DATE NOT NULL,
    credit_card_num VARCHAR(20) NOT NULL,
    name_on_card VARCHAR(25) NOT NULL,
    expiry_month INT NOT NULL,
    expiry_year INT NOT NULL,
    cvv_num INT NOT NULL
);

CREATE TABLE orders_payment (
    payment_ID INT,
    orders_ID INT,
    FOREIGN KEY (payment_ID) REFERENCES payment(payment_ID) ON DELETE RESTRICT,
    FOREIGN KEY (orders_ID) REFERENCES orders(orders_ID) ON DELETE RESTRICT
);

CREATE TABLE reviews (
    review_ID INT AUTO_INCREMENT PRIMARY KEY,
    customer_ID INT,
    product_id INT,
    review_rating NUMERIC(4, 2) NOT NULL,
    review_description VARCHAR(300),
    review_date TIMESTAMP,
    FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID) ON DELETE RESTRICT,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE RESTRICT
);



CREATE TABLE delivery (
    delivery_ID INT AUTO_INCREMENT PRIMARY KEY,
    delivery_startdate TIMESTAMP NOT NULL,
    address_ID INT,
    FOREIGN KEY (address_ID) REFERENCES customer_address(address_ID) ON DELETE RESTRICT
);

CREATE TABLE order_delivery(
       orders_id INT,
       delivery_ID INT,
       FOREIGN KEY (delivery_ID) REFERENCES delivery(delivery_ID) ON DELETE RESTRICT,
       FOREIGN KEY (orders_ID) REFERENCES orders(orders_ID) ON DELETE RESTRICT

);

CREATE TABLE delivery_status (
    delivery_status_ID INT AUTO_INCREMENT PRIMARY KEY,
    delivery_ID INT,
    delivery_personel_ID INT,
    delivery_station_name VARCHAR(50) NOT NULL,
    station_arrival_time TIMESTAMP NOT NULL,
    FOREIGN KEY (delivery_ID) REFERENCES delivery(delivery_ID) ON DELETE RESTRICT
);

COMMIT;


CREATE VIEW order_details AS
SELECT po.orders_ID, po.customer_ID, op.product_id, op.product_quantity
FROM placed_order po
JOIN ordered_product op ON po.orders_ID = op.orders_ID;

CREATE VIEW product_order_view AS
SELECT op.orders_ID, p.product_name, op.product_quantity, p.product_price
FROM product p
JOIN ordered_product op ON p.product_id = op.product_id;

CREATE VIEW product_delivery_status AS
SELECT o.orders_ID, ds.delivery_status_ID, ds.delivery_station_name, ds.station_arrival_time
FROM orders o
JOIN order_delivery od ON o.orders_ID = od.orders_ID
JOIN delivery d ON od.delivery_ID = d.delivery_ID
JOIN delivery_status ds ON d.delivery_ID = ds.delivery_ID;


DELIMITER //

CREATE TRIGGER update_product_rating
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    DECLARE avg_rating NUMERIC(4,2);
    
    SELECT AVG(review_rating) INTO avg_rating
    FROM reviews
    WHERE product_id = NEW.product_id;
    
    UPDATE product
    SET product_rating = avg_rating
    WHERE product_id = NEW.product_id;
END //


CREATE TRIGGER employee_insert_trigger
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    INSERT INTO person (person_ID, person_name, person_surname)
    VALUES (NEW.employee_ID, NEW.employee_name, NEW.employee_surname);
END//

CREATE TRIGGER customer_insert_trigger
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    INSERT INTO person (person_ID, person_name, person_surname)
    VALUES (NEW.customer_ID, NEW.customer_name, NEW.customer_surname);
END//

CREATE TRIGGER restrict_review_placement
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    DECLARE order_exists INT;
    
    SELECT COUNT(*) INTO order_exists
    FROM order_details
    WHERE customer_ID = NEW.customer_ID AND product_id = NEW.product_id;
    
    IF order_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can only place a review for products you have ordered.';
    END IF;
END//


DELIMITER ;


DELIMITER //

CREATE TRIGGER delete_review_update_product_rating
AFTER DELETE ON reviews
FOR EACH ROW
BEGIN
    DECLARE avg_rating NUMERIC(4, 2);

    SELECT AVG(review_rating) INTO avg_rating
    FROM reviews
    WHERE product_id = OLD.product_id;

    IF avg_rating IS NULL THEN
        SET avg_rating = NULL;  
    END IF;

    UPDATE product
    SET product_rating = avg_rating
    WHERE product_id = OLD.product_id;
END //

DELIMITER ;




DELIMITER //

CREATE FUNCTION calculate_total_price(order_id INT) RETURNS NUMERIC(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_price NUMERIC(10, 2);

    SELECT SUM(op.product_quantity * p.product_price)
    INTO total_price
    FROM ordered_product op
    INNER JOIN product p ON op.product_id = p.product_id
    WHERE op.orders_ID = order_id;

    RETURN total_price;
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION calculate_total_revenue() RETURNS NUMERIC(10, 2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total_revenue NUMERIC(10, 2);

    SELECT SUM(op.product_quantity * p.product_price)
    INTO total_revenue
    FROM ordered_product op
    INNER JOIN product p ON op.product_id = p.product_id;

    RETURN total_revenue;
END//
READS SQL DATA
DETERMINISTIC

DELIMITER ;




        INSERT INTO customer (customer_ID, customer_name, customer_surname, customer_phone, email)
        VALUES (20001, 'Jim', 'Brundle', '1234567890', 'Jim.Brundle@example.com'),
        (20002, 'Jane', 'Smith', '9876543210', 'jane.smith@example.com'),
        (20003, 'Michael', 'Jimson', '5555555555', 'michael.Jimson@example.com'),
        (20004, 'Emily', 'Davis', '9999999999', 'emily.davis@example.com'),
        (20005, 'Daniel', 'Watson', '1111111111', 'daniel.Watson@example.com'),
        (20006, 'Sarah', 'Brown', '2222222222', 'sarah.brown@example.com'),
        (20007, 'Matthew', 'Taylor', '3333333333', 'matthew.taylor@example.com'),
        (20008, 'Olivia', 'Anderson', '4444444444', 'olivia.anderson@example.com'),
        (20009, 'Andrew', 'Clark', '5555555555', 'andrew.clark@example.com'),
        (20010, 'Sophia', 'Lewis', '6666666666', 'sophia.lewis@example.com');

        INSERT INTO customer_address (address_ID, customer_ID, address_text)
        VALUES (30001, 20001, '123 Main Street, Texas'),
        (30002, 20002, '456 Elm Street, New York'),
        (30003, 20003, '789 Oak Street, Washington'),
        (30004, 20004, '321 Pine Street, Washington'),
        (30005, 20005, '567 Maple Street, Ottawa'),
        (30006, 20006, '890 Cedar Street, Montreal'),
        (30007, 20007, '123 Oak Avenue, California'),
        (30008, 20008, '456 Elm Avenue, Dallas'),
        (30009, 20009, '789 Pine Avenue, Seattle'),
        (30010, 20010, '321 Maple Avenue, Oklahoma');

        INSERT INTO employee (employee_ID, employee_name, employee_surname)
        VALUES (40001, 'Jim', 'Smith'),
        (40002, 'Alice', 'Jimson'),
        (40003, 'David', 'Brown'),
        (40004, 'Emma', 'Watson'),
        (40005, 'James', 'Thompson'),
        (40006, 'Sophie', 'Lee'),
        (40007, 'Jacob', 'Harris'),
        (40008, 'Ava', 'Martin'),
        (40009, 'Benjamin', 'Walker'),
        (40010, 'Lily', 'Turner');

        INSERT INTO orders (orders_ID, orders_Status, request_date)
        VALUES (50001, 'Pending', '2023-06-20'),
        (50002, 'In Progress', '2023-06-21'),
        (50003, 'Completed', '2023-06-22'),
        (50004, 'Pending', '2023-06-23'),
        (50005, 'In Progress', '2023-06-24');
        
        INSERT INTO placed_order (orders_ID, customer_ID)
        VALUES (50001, 20001),
        (50002, 20002),
        (50003, 20003),
        (50004, 20004),
        (50005, 20005);


        INSERT INTO order_prepare (orders_ID, employee_ID)
        VALUES (50001, 40001),
        (50002, 40002),
        (50003, 40003),
        (50004, 40004),
        (50005, 40005);

        INSERT INTO product (product_id, product_name, product_description, product_price, product_rating)
        VALUES (60001, 'T-Shirt', 'Comfortable cotton t-shirt with a classic fit.', 10.99, null),
                (60002, 'Jeans', 'High-quality denim jeans with a straight leg cut.', 15.99, null),
                (60003, 'Sweatshirt', 'Cozy sweatshirt made of soft fleece material.', 8.99, null),
                (60004, 'Dress', 'Elegant knee-length dress with a floral pattern.', 12.99, null),
                (60005, 'Sneakers', 'Stylish sneakers with a cushioned sole for extra comfort.', 9.99, null),
                (60006, 'Jacket', 'Lightweight jacket suitable for cool weather.', 11.99, null),
                (60007, 'Skirt', 'Versatile skirt that can be dressed up or down.', 14.99, null),
                (60008, 'Shorts', 'Casual shorts made of breathable fabric.', 7.99, null),
                (60009, 'Blouse', 'Fashionable blouse with a flattering silhouette.', 10.99, null),
                (60010, 'Polo Shirt', 'Classic polo shirt for a polished casual look.', 13.99, null);

        INSERT INTO ordered_product (product_id, orders_ID, product_quantity)
        VALUES (60001, 50001, 2),
        (60002, 50001, 1),
        (60003, 50002, 3),
        (60004, 50002, 1),
        (60005, 50003, 2),
        (60006, 50003, 1),
        (60007, 50004, 4),
        (60008, 50004, 2),
        (60009, 50005, 3),
        (60010, 50005, 1);

        INSERT INTO payment (payment_ID, payment_date, credit_card_num, name_on_card, expiry_month, expiry_year, cvv_num)
        VALUES (70001, '2023-06-20', '1234567890123456', 'Jim Brundle', 12, 2025, 123),
        (70002, '2023-06-21', '9876543210987654', 'Jane Smith', 11, 2024, 456),
        (70003, '2023-06-22', '5555666677778888', 'Michael Jimson', 10, 2023, 789),
        (70004, '2023-06-23', '9999888877776666', 'Emily Davis', 9, 2022, 321),
        (70005, '2023-06-24', '1111222233334444', 'Daniel Watson', 8, 2023, 654),
        (70006, '2023-06-25', '2222333344445555', 'Sarah Brown', 7, 2024, 987),
        (70007, '2023-06-26', '6666555544443333', 'Matthew Taylor', 6, 2025, 210),
        (70008, '2023-06-27', '7777888899990000', 'Olivia Anderson', 5, 2026, 543),
        (70009, '2023-06-28', '4444333322221111', 'Andrew Clark', 4, 2023, 876),
        (70010, '2023-06-29', '8888999911112222', 'Sophia Lewis', 3, 2024, 109);

        INSERT INTO orders_payment (payment_ID, orders_ID)
        VALUES (70001, 50001),
        (70002, 50002),
        (70003, 50003),
        (70004, 50004),
        (70005, 50005);

        INSERT INTO reviews (review_ID, customer_ID, product_id, review_rating, review_description, review_date)
        VALUES (80001, 20001, 60001, 4.5, 'This is a great product!', '2023-06-20 10:30:00'),
        (80002, 20001, 60002, 3.8, 'The product quality could be better.', '2023-06-21 12:45:00'),
        (80003, 20002, 60003, 4.2, 'Im satisfied with my purchase.', '2023-06-22 15:20:00'),
        (80004, 20002, 60004, 4.7, 'Highly recommended!', '2023-06-23 14:10:00'),
        (80005, 20003, 60005, 3.5, 'Not as expected.', '2023-06-24 16:35:00'),
        (80006, 20003, 60006, 4.1, 'Good value for the price.', '2023-06-25 11:50:00'),
        (80007, 20004, 60007, 4.9, 'Excellent service!', '2023-06-26 09:15:00'),
        (80008, 20004, 60008, 3.2, 'Average product.', '2023-06-27 13:05:00'),
        (80009, 20005, 60010, 4.6, 'Very happy with my purchase.', '2023-06-28 17:40:00'),
        (80010, 20005, 60010, 4.3, 'Good customer support.', '2023-06-29 10:00:00');

        INSERT INTO delivery (delivery_ID, delivery_startdate, address_ID)
        VALUES (90001, '2023-06-20 10:00:00', 30001),
        (90002, '2023-06-21 11:30:00', 30002),
        (90003, '2023-06-22 12:45:00', 30003),
        (90004, '2023-06-23 09:15:00', 30004),
        (90005, '2023-06-24 13:30:00', 30005);

        INSERT INTO order_delivery(orders_id, delivery_ID)
        VALUES (50001, 90001),
        (50002, 90002),
        (50003, 90003),
        (50004, 90004),
        (50005, 90005);
                

        INSERT INTO delivery_status (delivery_status_ID, delivery_ID, delivery_personel_ID, delivery_station_name, station_arrival_time)
        VALUES (100001, 90001, 40001, 'Store', '2023-06-20 10:30:00'),
        (100002, 90002, 40002, 'Washington Station', '2023-06-21 12:45:00'),
        (100003, 90003, 40003, 'Finished', '2023-06-22 15:20:00'),
        (100004, 90004, 40004, 'Store', '2023-06-23 14:10:00'),
        (100005, 90005, 40005, 'Texas Station', '2023-06-24 16:35:00');
