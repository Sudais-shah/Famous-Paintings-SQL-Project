create database Famous_Painting;

use Famous_Painting;

CREATE TABLE artist(
 artist_id INT,    -- Removed PRIMARY KEY
 full_name VARCHAR(400),  
 first_name VARCHAR(50),    
 middle_name VARCHAR(50),
 last_name VARCHAR(50),    
 nationality VARCHAR(50),     
 style VARCHAR(50),    
 birth INT,
 death INT
);
select * from artist;
CREATE TABLE canva_size(
 size_id BIGINT,  -- Removed PRIMARY KEY
 width INT, 
 height BIGINT,  -- Updated this to BIGINT based on your previous query
 label VARCHAR(400)
);
select * from canva_size;
CREATE TABLE image_link(
 work_id BIGINT,  -- Removed REFERENCES work(work_id)
 url VARCHAR(400),
 thumbnail_small_url VARCHAR(400), 
 thumbnail_large_url VARCHAR(400)
);
select * from image_link;
CREATE TABLE museum(
 museum_id INT,   -- Removed PRIMARY KEY
 name VARCHAR(50), 
 address VARCHAR(50),
 city VARCHAR(50),
 state VARCHAR(50),
 postal VARCHAR(150),	
 country VARCHAR(50),	
 phone VARCHAR(400),	 
 url VARCHAR(400)
);
select * from museum;

CREATE TABLE museum_hours(
 museum_id bigint,  
 day VARCHAR(100),	
 open VARCHAR(100),	
 close VARCHAR(100)
);
drop table museum_hours;
select * from museum_hours;

CREATE TABLE product_size(
 work_id BIGINT,  
 size_id BIGINT,   
 sale_price BIGINT,  
 regular_price BIGINT
);
select * from product_size;

CREATE TABLE subject(
 work_id BIGINT,  -- Removed REFERENCES work(work_id)
 subject VARCHAR(100)
);
select * from subject;

CREATE TABLE work(
 work_id BIGINT, 
 name VARCHAR(400),
 artist_id INT,   
 style VARCHAR(200),
 museum_id char(50)    
);

drop table work;
select * from work;



