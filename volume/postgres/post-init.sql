drop table stocks;

create table stocks (
    id bigserial primary key,
    ean varchar(13),
    store_id bigserial references stores(store_id),
    stock bigint
);

insert into stocks (ean, store_id, stock)
    select p.ean, i.store_id, count (*) as stock
    from items i 
    inner join products p on p.ean = i.ean 
    where i.state in ('STOCK', 'SALESAREA') 
    group by p.ean, i.store_id;

alter table stocks add foreign key (ean) references products(ean);

-- Trigger d'update des stock si on update le state d'un item
-- Caveat : si un items est inserré dans sur un shop qui ne contient pas encore cette ean, ne crée pas la row

create or replace function update_stock_item_state() returns trigger as $update_stock_item_state$
    declare
        this_updated_item_ean items.ean%TYPE;
        this_updated_item_store_id items.store_id%TYPE;
        this_updated_product_new_stock integer;
    begin
        select into this_updated_item_ean new.ean;
        select into this_updated_item_store_id new.store_id;

        select count(*)
          into this_updated_product_new_stock
          from items
         where items.state in ('STOCK', 'SALESAREA')
         and ean = this_updated_item_ean
         and store_id = this_updated_item_store_id;

        update stocks
           set stock=this_updated_product_new_stock
         where ean=this_updated_item_ean
         and store_id=this_updated_item_store_id;
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

        insert into stocks (ean, stock, store_id)
        select  this_new_ean as ean,
                (select count(*)
                from items
                where items.state in ('STOCK', 'SALESAREA')
                and ean = this_new_ean
                ) as ean;
        return null;
    end;
$insert_stock_new_product$ language plpgsql;

DROP TRIGGER IF EXISTS insert_stock_new_product on products;

create trigger insert_stock_new_product after insert on products
    for each row
    execute procedure insert_stock_new_product();