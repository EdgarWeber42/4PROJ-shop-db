-- 4PROJ Shop database DDL (Postgres)

create table stores (
    store_id bigserial primary key,
    name varchar(60),
    address varchar(60),
    phone_number varchar(10)
);

create type device_type as enum ('PDA', 'register', 'fence', 'beacon');
create table devices (
    id bigserial primary key,
    name varchar(20),
    type device_type,
    store_id bigserial
);

create table customers (
    id bigserial primary key,
    firstName varchar(30),
    lastName varchar(30),
    address varchar(50),
    phone_number varchar(10)
);

create type event_type as enum ('sale', 'refund', 'alarm', 'reception');
create table events (
    id bigserial primary key,
    device_id bigserial references devices(id),
    customer_id bigserial references customers(id),
    type event_type not null,
    date date,
    amount numeric
);

create table products (
    id bigserial primary key,
    ean varchar(13) not null unique,
    name varchar(130),
    price numeric,
    department varchar(20),
    family varchar(30),
    subfamily varchar(30),
    image_prefix varchar(25)
);

create table items (
    id bigserial primary key,
    ean varchar(13) references products(ean),
    epc varchar(24) not null unique,
    state varchar(10)
);

create table event_items (
    id bigserial primary key,
    event_id bigserial references events(id),
    item_epc varchar(24) references items(epc)
);

create table shelf (
    shelf_id bigserial primary key,
    store_id bigserial,
    capacity integer,
    type varchar(15)
);

create table shelf_items (
    id bigserial primary key,
    shelf_id bigserial references shelf(shelf_id),
    item_epc varchar(24) references items(epc)
);

alter table stores add foreign key (store_id) references stores(store_id);
alter table shelf add foreign key (store_id) references stores(store_id);
-- alter table event_items add foreign key (event_id) references events(id);
-- alter table items add foreign key (ean) references products(ean)