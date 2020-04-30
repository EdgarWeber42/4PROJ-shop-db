-- 4PROJ Shop database DDL (Postgres)

create table events (
    id bigserial primary key,
    type varchar(14) not null,
    date date,
    sender varchar(15),
    customer varchar(30)
);

create table event_items (
    id bigserial primary key,
    event_id bigserial not null
);

create table items (
    id bigserial primary key,
    ean varchar(13) not null,
    epc varchar(24) not null unique
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

alter table event_items add foreign key (event_id) references events(id);
alter table items add foreign key (ean) references products(ean)