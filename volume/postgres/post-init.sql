create table stocks as
    select p.ean, count (*) 
    from items i 
    inner join products p on p.ean = i.ean 
    where i.state in ('STOCK', 'SALES AREA') 
    group by p.ean;

alter table stocks add foreign key (ean) references products(ean);