drop table stocks;

create table stocks as
    select p.ean, count (*) as stock
    from items i 
    inner join products p on p.ean = i.ean 
    where i.state in ('STOCK', 'SALES AREA') 
    group by p.ean;

alter table stocks add foreign key (ean) references products(ean);

--Trigger d'update des stock si on update le state d'un item

create or replace function update_stock_item_state() returns trigger as $update_stock_item_state$
    declare
        this_updated_item_ean items.ean%TYPE;
        this_updated_product_new_stock integer;
    begin
        select into this_updated_item_ean new.ean;

        select count(*)
          into this_updated_product_new_stock
          from items
         where items.state in ('STOCK', 'SALES AREA')
         and ean = this_updated_item_ean;

        update stocks
           set stock=this_updated_product_new_stock
         where ean=this_updated_item_ean;
        return null;
    end;
$update_stock_item_state$ language plpgsql;

DROP TRIGGER IF EXISTS update_stock_item_state on items;

create trigger update_stock_item_state after update or insert on items
    for each row
    execute procedure update_stock_item_state();

--Trigger d'update des stocks si on crée un item

create or replace function insert_stock_new_product() returns trigger as $insert_stock_new_product$
    declare
        this_new_ean products.ean%TYPE;
    begin
        select into this_new_ean new.ean;

        insert into stocks (ean, stock)
        select  this_new_ean as ean,
                (select count(*)
                from items
                where items.state in ('STOCK', 'SALES AREA')
                and ean = this_new_ean
                ) as ean;
        return null;
    end;
$insert_stock_new_product$ language plpgsql;

DROP TRIGGER IF EXISTS insert_stock_new_product on products;

create trigger insert_stock_new_product after insert on products
    for each row
    execute procedure insert_stock_new_product();