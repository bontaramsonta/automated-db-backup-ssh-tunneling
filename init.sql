-- Create a database
CREATE DATABASE mydemo;

-- Connect to the database
\c mydemo;

-- Create a table
CREATE TABLE mytable (
    id serial primary key,
    name text
);

-- Insert demo data
INSERT INTO mytable (name) VALUES ('Data 1');
INSERT INTO mytable (name) VALUES ('Data 2');
INSERT INTO mytable (name) VALUES ('Data 3');
INSERT INTO mytable (name) VALUES ('Data 4');
INSERT INTO mytable (name) VALUES ('Data 5');
INSERT INTO mytable (name) VALUES ('Data 6');
INSERT INTO mytable (name) VALUES ('Data 7');
INSERT INTO mytable (name) VALUES ('Data 8');
INSERT INTO mytable (name) VALUES ('Data 9');
INSERT INTO mytable (name) VALUES ('Data 10');
-- Add more data as needed