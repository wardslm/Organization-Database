show tables;
Create table if not exists Regions(
region_id int auto_increment not null,
region_name varchar(255) unique,
primary key (region_id)
);
Create table if not exists Countries(
country_id int auto_increment not null,
region_id int,
country_name varchar(255) unique,
primary key (country_id),
foreign key (region_id) references Regions(region_id)
);
create table if not exists ProStaTers(
pst_id int auto_increment not null,
country_id int,
pst_name varchar(255) unique,
population int,
primary key (pst_id),
foreign key (country_id) references Countries(country_id)
);
create table if not exists ProStaTers(
pst_id int auto_increment not null,
country_id int,
pst_name varchar(255) unique,
population int,
primary key (pst_id),
foreign key (country_id) references Countries(country_id)
);
create table if not exists Organizations (
org_id int auto_increment not null,
org_name varchar(255) not null,
is_active bool default 1,
primary key (org_id)
);
create table if not exists Companies(
org_id int,
foreign key (org_id) references Organizations(org_id)
);
create table if not exists ResearchCenters(
org_id int,
foreign key (org_id) references Organizations(org_id)
);
create table if not exists GovAgencies(
country_id int,
org_id int,
foreign key (country_id) references Countries(country_id),
foreign key (org_id) references Organizations(org_id),
primary key (org_id)
);
create table if not exists Vaccines(
vaccine_id int,
vaccine_name varchar(255),
primary key (vaccine_id)
);
create table CovidRecords
(
record_id int auto_increment primary Key,
unvaxed_infected int,
unvaxed_death int,
org_id int,
pst_id int,
record_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE
CURRENT_TIMESTAMP
);
create table VaccineInfos
(
vaccine_id int,
record_id int auto_increment primary key,
vax_infected int,
vax_death int,
total_vax int
);
create table if not exists Users (
user_id int auto_increment not null,
country_id int not null,
first_name varchar(255) not null,
last_name varchar(255) not null,
is_active bool default 1,
email varchar(255) not null,
phone varchar(255),
org_name varchar(255) default "N/A", # do not leave it null !!!!
date_of_birth date default "2000-07-16",
primary key (user_id),
foreign key (country_id) references Countries (country_id)
) ;
create table if not exists RegUsers (
user_id int,
foreign key (user_id) references Users (user_id),
primary key (user_id)
);
create table if not exists Admins (
user_id int,
privilege_name varchar(255) default "administrator",
user_name varchar(255) unique,
user_password varchar(255) default "c19pswd",
foreign key (user_id) references Users (user_id),
primary key (user_id)
);
create table if not exists Researchers (
user_id int,
privilege_name varchar(255) default "researcher",
user_name varchar(255) unique,
user_password varchar(255) default "c19pswd",
foreign key (user_id) references Users (user_id),
primary key (user_id)
);
create table if not exists Articles (
article_id int auto_increment not null,
major_topic varchar(255),
minor_topic varchar(255),
summary varchar(100),
publication_date date,
article varchar(255),
author_name varchar(255),
primary key (article_id)
);
create table if not exists OrgDelegates (
user_id int,
org_id int,
user_name varchar(255) unique,
user_password varchar(255) default "c19pswd",
privilege_name varchar(255) default "organization's delegate",
foreign key (org_id) references Organizations(org_id),
primary key (user_id)
);
create table SubToOrg(
user_name varchar(255) not null,
author_name varchar(255) not null,
primary key (user_name, author_name)
);
create table SubToReseacher(
user_name varchar(255) not null,
author_name varchar(255) not null,
primary key (user_name, author_name)
);
create table AdminLogs(
log_id int auto_increment primary key,
admin_id int,
user_id int,
action_type enum ( "add", "edit", "delete"),
log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE
CURRENT_TIMESTAMP,
foreign key (admin_id) references Admins(user_id),
foreign key (user_id) references Users(user_id)
);
create table EmailSent
(
id int auto_increment not null primary key,
date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE
CURRENT_TIMESTAMP,
email_address varchar(255),
emial_subject varchar(255),
email_body varchar(255)
);
