drop table stocks;

create table stocks as
    select p.ean, count (*) as stock
    from items i 
    inner join products p on p.ean = i.ean 
    where i.state in ('STOCK', 'SALES AREA') 
    group by p.ean;

alter table stocks add foreign key (ean) references products(ean);


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

create trigger update_stock_item_state after update on items
    for each row
    execute procedure update_stock_item_state();