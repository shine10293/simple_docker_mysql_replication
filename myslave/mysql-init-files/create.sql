CREATE DATABASE mydb;

CREATE TABLE mydb.user(
  id VARCHAR(100) PRIMARY KEY,
  name VARCHAR (100),
  age INT
);

create user slaveuser@'%' identified by 'slavepassword';
grant all privileges on mydb.* to slaveuser@'%' identified by 'slavepassword';