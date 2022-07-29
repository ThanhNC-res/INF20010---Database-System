/*
Student Name: Ngo Cong Thanh
Student ID: 103433609
*/
-----------------------

----------
--Part 1--
----------

-----------------------

create or replace procedure ADD_CUST_TO_DB(pcustid number, pcustname varchar2) as

OUT_OF_RANGE EXCEPTION;
BEGIN
IF pcustid < 1 OR pcustid > 499 Then
raise OUT_OF_RANGE;
END IF;

INSERT INTO customer(custid, custname, sales_ytd, status)
VALUES (pcustid, pcustname, 0, 'OK');
EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20017,' Duplicate Customer ID');
WHEN OUT_OF_RANGE THEN
    RAISE_APPLICATION_ERROR(-20029,' Customer ID out of range');
WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;

/

create or replace procedure ADD_CUSTOMER_VIASQLDEV(pcustid number, pcustname varchar2) as

begin
dbms_output.put_line('--------------------------------------------');
dbms_output.put_line('Adding Customer. ID: ' || pcustid || ' Name: ' || pcustname);

ADD_CUST_TO_DB(pcustid, pcustname);

dbms_output.put_line('Customer Added OK');


COMMIT;
EXCEPTION 
WHEN OTHERS THEN
   dbms_output.put_line(sqlerrm);
END;

/
create or replace function DELETE_ALL_CUSTOMERS_FROM_DB return number as

pCount number;
begin
DELETE FROM customer; 
pCount := SQL%ROWCOUNT; 
RETURN pCount;
EXCEPTION
WHEN OTHERS THEN 
    raise_application_error(-20000, sqlerrm);
end;

/

create or replace procedure DELETE_ALL_CUSTOMERS_VIASQLDEV as
vCount number;
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting all Customer rows');

vCount := delete_all_customers_from_db;

DBMS_OUTPUT.PUT_LINE(vCount || ' rows deleted');

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

/

create or replace PROCEDURE ADD_PRODUCT_TO_DB(pprodid number, 
pprodname varchar2, pprice number) as

prodid_out_of_range exception;
price_out_of_range exception;

begin
if pprodid < 1000 or pprodid > 2500 then 
    raise prodid_out_of_range;
end if;
if pprice < 0 or pprice > 999.99 then 
    raise price_out_of_range; 
end if;

insert into product(prodid, prodname, selling_price, sales_ytd)
values (pprodid, pprodname, pprice, 0);

exception
when dup_val_on_index then 
    raise_application_error(-20037, ' Duplicate product ID');
when prodid_out_of_range then 
    raise_application_error(-20049, ' Product ID out of range');
when price_out_of_range then 
    raise_application_error(-20056, ' Price out of range');
When OTHERs then
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);

end;


/

create or replace PROCEDURE ADD_PRODUCT_VIASQLDEV(pprodid number, 
pprodname varchar2, pprice number) as

begin

dbms_output.put_line('--------------------------------------------');
dbms_output.put_line('Adding Product. ID: ' || pprodid || ' Name: ' || pprodname 
                                            || ' Price: ' || pprice);

add_product_to_db(pprodid, pprodname, pprice);
dbms_output.put_line('Product Added OK');
COMMIT;
Exception
when OthERS then 
    dbms_output.put_line(sqlerrm);

end;

/

create or replace function DELETE_ALL_PRODUCTS_FROM_DB return number as
pCount number;
begin
DELETE FROM product; 
pCount := SQL%ROWCOUNT; 
RETURN pCount;
EXCEPTION
WHEN OTHERS THEN 
    raise_application_error(-20000, sqlerrm);
end;

/

create or replace procedure DELETE_ALL_PRODUCTS_VIASQLDEV as
vCount number;
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting all Product rows');

vCount := delete_all_products_from_db;

DBMS_OUTPUT.PUT_LINE(vCount || ' rows deleted');

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE(SQLERRM(-20000));
END;

/

create or replace function GET_CUST_STRING_FROM_DB(pcustid number) 
return varchar2 as

pcustname varchar2(20);
pstatus varchar2(10);
psales number; 
p_str varchar2(100);
begin

select custname, status, sales_ytd into pcustname, pstatus, psales 
from customer
where custid = pcustid;

p_str := 'CustId:' || pcustid || ' Name:' || pcustname || ' Status:' || pstatus
            || ' SalesYTD:' || psales;

return p_str;
exception
when no_data_found then 
raise_application_error(-20067, 'Customer ID not found');
when others then 
raise_application_error(-20000, SQLERRM);

end;

/

create or replace procedure GET_CUST_STRING_VIASQLDEV(pcustid number) as

p_str varchar2(100);
begin

DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Getting Details for Cust Id ' || pcustid);

p_str := get_cust_string_from_db(pcustid);

DBMS_OUTPUT.PUT_LINE(p_str);

Exception
when others then 
dbms_output.put_line(sqlerrm);
end;

/

create or replace procedure UPD_CUST_SALESYTD_IN_DB(pcustid number, pamt number) as

out_of_range exception;

begin

if pamt < -999.99 or pamt > 999.99 then
raise out_of_range;
end if; 

update customer
set sales_ytd = sales_ytd + pamt
where custid = pcustid;

if SQL%NOTFOUND then 
raise no_data_found;
end if;

exception

when no_data_found then 
raise_application_error(-20077, 'Customer ID not found');
when out_of_range then
raise_application_error(-20089, 'Amount out of range');
when others then
raise_application_error(-20000, sqlerrm);
end;

/

create or replace procedure UPD_CUST_SALESYTD_VIASQLDEV(pcustid number, pamt number) as

begin

dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Updating SalesYTD Customer Id:' || pcustid || ' Amount:' || pamt);

upd_cust_salesytd_in_db(pcustid, pamt);

dbms_output.put_line('Update OK'); 
COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

/

create or replace function GET_PROD_STRING_FROM_DB(pprodid number) 
return varchar2 as

pprodname varchar2(20);
pprice number;
psales number;
p_str varchar2(100);
begin
select prodname, selling_price, sales_ytd
into pprodname, pprice, psales
from product
where prodid = pprodid;

p_str := 'Prodid:' || pprodid || ' Name:' || pprodname || ' Price:'
                                || pprice || ' SalesYTD:' || psales;
return p_str;

exception
when no_data_found then
raise_application_error(-20097, 'Product ID not found');
when others then 
raise_application_error(-20000, SQLERRM);

end;

/

create or replace procedure GET_PROD_STRING_VIASQLDEV(pcustid number) as

p_str varchar2(100);
begin

DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Getting Details for Prod Id ' || pcustid);

p_str := get_prod_string_from_db(pcustid);

DBMS_OUTPUT.PUT_LINE(p_str);

Exception
when others then 
dbms_output.put_line(sqlerrm);
end;

/

create or replace procedure UPD_PROD_SALESYTD_IN_DB(pprodid number, pamt number) as

out_of_range exception;

begin

if pamt < -999.99 or pamt > 999.99 then
raise out_of_range;
end if; 

update product
set sales_ytd = sales_ytd + pamt
where prodid = pprodid;

if SQL%NOTFOUND then 
raise no_data_found;
end if;

exception
when no_data_found then 
raise_application_error(-20107, 'Product ID not found');
when out_of_range then
raise_application_error(-20119, 'Amount out of range');
when others then
raise_application_error(-20000, sqlerrm);
end;

/

create or replace procedure UPD_PROD_SALESYTD_VIASQLDEV(pprodid number, pamt number) as

begin

dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Updating SalesYTD Product Id:' || pprodid || ' Amount:' || pamt);

upd_prod_salesytd_in_db(pprodid, pamt);

dbms_output.put_line('Update OK'); 
COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

/

create or replace procedure UPD_CUST_STATUS_IN_DB(pcustid number, pstatus varchar2) as

invalid_status exception;
begin

if LOWER(pstatus) != 'ok' and LOWER(pstatus) != 'suspend' then
raise invalid_status;
end if;

update customer
set status = pstatus
where custid = pcustid;

if SQL%NOTFOUND then 
raise no_data_found;
end if;

exception
when no_data_found then 
raise_application_error(-20127, 'Customer ID not found');
when invalid_status then
raise_application_error(-20139, 'Invalid Status value');
when others then
raise_application_error(-20000, sqlerrm);
end;

/

create or replace procedure UPD_CUST_STATUS_VIASQLDEV(pcustid number, pstatus varchar2) as

begin

dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Updating Status. ID:' || pcustid || ' New Status:' || pstatus);

upd_cust_status_in_db(pcustid, pstatus);

dbms_output.put_line('Update OK'); 
COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

/

create or replace procedure ADD_SIMPLE_SALE_TO_DB(pcustid number, pprodid number,
pqty number) as

out_of_range exception;
invalid_cust_status exception;
no_match_custid exception;
no_match_prodid exception;

pprice number;
pcustsales number;
pprodsales number;
pstatus varchar2(10); 
begin

if pqty < 1 or pqty > 999 then 
raise out_of_range;
end if;

select sales_ytd, status into pcustsales, pstatus from customer
where custid = pcustid;



if LOWER(pstatus) != 'ok' then
raise invalid_cust_status;
end if;

select selling_price, sales_ytd into pprice, pprodsales from product
where prodid = pprodid;

if SQL%NOTFOUND then
if pcustsales is null then
raise no_match_custid;
end if;

if pprice is null then
raise no_match_prodid;
end if;
end if;

update customer
set sales_ytd = pcustsales + (pqty * pprice)
where custid = pcustid;

update product
set sales_ytd = pprodsales + (pqty * pprice)
where prodid = pprodid;

exception
when out_of_range then
raise_application_error(-20147, 'Sale Quantity outside valid range');
when invalid_cust_status then
raise_application_error(-20159, 'Customer Status is not OK');
when no_match_custid then 
raise_application_error(-20166, 'Customer ID not found');
when no_match_prodid then 
raise_application_error(-20172, 'Product ID not found');
when others then 
raise_application_error(-20000, sqlerrm);

end;

/

create or replace procedure ADD_SIMPLE_SALE_VIASQLDEV(pcustid number, pprodid number,
pqty number) as

begin
dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Adding Simple Sale. Custi Id:' || pcustid || ' Prod Id:' || pprodid || ' Qty:' || pqty);

add_simple_sale_to_db(pcustid, pprodid, pqty);

dbms_output.put_line('Added Simple Sale OK'); 
COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);

end;

/

create or replace function SUM_CUST_SALESYTD return number as

ptotal number;

begin
select sum(sales_ytd) into ptotal
from customer; 
return ptotal;

exception 
when others then 
raise_application_error(-20000, SQLERRM);
end;

/

create or replace PROCEDURE SUM_CUST_SALES_VIASQLDEV as

ptotal number;
begin

dbms_output.put_line('--------------------------------------------');
dbms_output.put_line('Summing Customer SalesYTD');

ptotal := sum_cust_salesytd;
dbms_output.put_line('All Customer Total: ' || ptotal);
COMMIT;
Exception
when no_data_found then
    dbms_output.put_line('All Customer Total: 0');
when OtherS then 
    dbms_output.put_line(SQLERRM);

end;

/

create or replace function SUM_PROD_SALESYTD_FROM_DB return number as

ptotal number;
begin

select sum(sales_ytd) into ptotal
from product;
return ptotal;

exception 
when others then 
raise_application_error(-20000, sqlerrm);
end;

/

create or replace PROCEDURE SUM_PROD_SALES_VIASQLDEV as

ptotal number;
begin

dbms_output.put_line('--------------------------------------------');
dbms_output.put_line('Summing Product SalesYTD');

ptotal := sum_prod_salesytd_from_db;
dbms_output.put_line('All Product Total: ' || ptotal);
COMMIT;
Exception
when no_data_found then
    dbms_output.put_line('All Product Total: 0');
when OtherS then 
    dbms_output.put_line(SQLERRM);

end;

/
----------
--Part 2--
----------

-----------------------


create or replace function GET_ALLCUST return SYS_REFCURSOR as

rv_ref SYS_REFCURSOR;
begin

open rv_ref for select * from customer;
return rv_ref;

exception
when others then 
raise_application_error(-20000, SQLERRM);
end;

/

create or replace procedure GET_ALLCUST_VIASQLDEV as

rv_ref SYS_REFCURSOR;
cust_details customer%rowtype;

begin

dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Listing All Customer Details');

rv_ref := get_allcust;

if rv_ref%notfound then
dbms_output.put_line('No rows found');
end if;

loop fetch rv_ref into cust_details;
exit when rv_ref%notfound;
dbms_output.put_line('CustId:' || cust_details.custid || ' Name:' || cust_details.custname
                        || ' Status:' || cust_details.status || ' SalesYTD:' || cust_details.sales_ytd);

end loop;

close rv_ref;

COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

/

create or replace function GET_ALLPROD_FROM_DB return sys_refcursor as
      rv_ref Sys_Refcursor;
    begin
      OPEN rv_ref FOR SELECT * FROM PRODUCT;
      RETURN rv_ref;
    exception
      WHEN OTHERS THEN
      Raise_Application_Error(-20000, Sqlerrm);
    End;
/

create or replace procedure GET_ALLPROD_VIASQLDEV as

rv_ref SYS_REFCURSOR;
prod_details product%rowtype;

begin

dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Listing All Product Details');

rv_ref := get_allprod_from_db;

if rv_ref%notfound then
dbms_output.put_line('No rows found');
end if;

loop fetch rv_ref into prod_details;
exit when rv_ref%notfound;
dbms_output.put_line('ProdId:' || prod_details.prodid || ' Name:' || prod_details.prodname
                        || ' Price:' || prod_details.selling_price || ' SalesYTD:' || prod_details.sales_ytd);

end loop;

close rv_ref;

COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

/


--------------------

----------
--Part 3--
----------

-----------------------

create or replace PROCEDURE ADD_LOCATION_TO_DB(ploccode varchar2, pminqty number, pmaxqty number) AS
CHECK_LOCID_LENGTH EXCEPTION;
CHECK_MINQTY_RANGE EXCEPTION;
CHECK_MAXQTY_RANGE EXCEPTION;
CHECK_MAXQTY_GREATER_MIXQTY EXCEPTION;
BEGIN
IF Length(PLOCCODE) <> 5 THEN
RAISE CHECK_LOCID_LENGTH;
END IF;
IF PMAXQTY < PMINQTY THEN
RAISE CHECK_MAXQTY_GREATER_MIXQTY;
END IF;
IF PMINQTY <0 OR PMINQTY >999 THEN
RAISE CHECK_MINQTY_RANGE;
END IF; 
IF PMAXQTY <0 OR PMAXQTY >999 THEN
RAISE CHECK_MAXQTY_RANGE;
END IF; 
INSERT INTO LOCATION(LOCID, MINQTY, MAXQTY)
VALUES (PLOCCODE, PMINQTY, PMAXQTY);

EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
raise_application_error(-20187,	' Duplicate location ID');
WHEN CHECK_LOCID_LENGTH THEN
raise_application_error(-20199, ' Location Code length invalid');
WHEN CHECK_MINQTY_RANGE THEN
raise_application_error(-20206, ' Minimum Qty out of range');
WHEN CHECK_MAXQTY_RANGE THEN
raise_application_error(-20212, ' Maximum Qty out of range');
WHEN CHECK_MAXQTY_GREATER_MIXQTY THEN
raise_application_error(-20224, ' Minimum qty larger than maximum qty');
WHEN OTHERS THEN
raise_application_error(-20000, sqlerrm);
END;

/

create or replace PROCEDURE ADD_LOCATION_VIASQLDEV (ploccode varchar2, pminqty number, pmaxqty number) AS

begin
dbms_output.put_line('--------------------------------------------');
dbms_output.put_line('Adding Location LocCode: ' || ploccode || ' MinQty: ' || pminqty || ' MaxQty: ' || pmaxqty);

add_location_to_db(ploccode, pminqty, pmaxqty);

DBMS_OUTPUT.PUT_LINE('Location Added OK');
exception
when others then
dbms_output.put_line(SQLERRM);
END;

/

--------------------

----------
--Part 4--
----------

-----------------------

create or replace procedure ADD_COMPLEX_SALE_TO_DB(pcustid number, pprodid number, 
pqty number, pdate varchar2) as

invalid_quantity_range exception;
invalid_cust_status exception;
invalid_sale_date exception;
no_match_custid exception;
no_match_prodid exception;
pprice number;
pstatus varchar2(10);
l_date date;
v_error number := 0;
begin

select status into pstatus
from customer
where custid = pcustid;

v_error := 1;

select selling_price into pprice
from product
where prodid = pprodid;


if LOWER(pstatus) != 'ok' then 
raise invalid_cust_status;
end if;

if pqty < 1 or pqty >999 then
raise invalid_quantity_range;
end if;

if length(pdate) <> 8 then
raise invalid_sale_date;
end if;

l_date := to_date(pdate, 'YYYYMMDD');

insert into sale(saleid, custid, prodid, qty, price, saledate)
values (SALE_SEQ.nextval, pcustid, pprodid, pqty, pprice, l_date);


upd_cust_salesytd_in_db(pcustid, pqty*pprice);
upd_prod_salesytd_in_db(pprodid, pqty*pprice);

exception
when invalid_quantity_range then
raise_application_error(-20237, 'Sale Quantity outside valid range');
when invalid_cust_status then
raise_application_error(-20249, 'Customer status is not OK');
when invalid_sale_date then
raise_application_error(-20256, 'Date not valid');
when no_data_found then 
if v_error = 0 then
raise_application_error(-20262, 'Customer ID not found');
else 
raise_application_error(-20274, 'Product ID not found');
end if;
when others then
raise_application_error(-20000, SQLERRM);
end;

/

create or replace procedure ADD_COMPLEX_SALE_VIASQLDEV(pcustid number, pprodid number, 
pqty number, pdate varchar2) as

begin
dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Adding Complex Sale. Cust Id:' || pcustid || ' Prod Id:' || pprodid || ' Date:' || pdate
                        || ' Amt:' || pqty);

add_complex_sale_to_db(pcustid, pprodid, pqty, pdate);

dbms_output.put_line('Added Complex Sale OK'); 
COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);

end;

/

create or replace function GET_ALLSALES_FROM_DB return SYS_REFCURSOR as

rv_ref SYS_REFCURSOR;
begin

open rv_ref for select * from sale;
return rv_ref;

exception
when others then 
raise_application_error(-20000, sqlerrm);

end;

/

create or replace procedure GET_ALLSALES_VIASQLDEV as

rv_ref SYS_REFCURSOR;
sale_details sale%rowtype;
begin

dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Listing All Sales Details');

rv_ref := get_allsales_from_db;

if rv_ref%notfound then
dbms_output.put_line('No rows found');
end if;

loop fetch rv_ref into sale_details;
exit when rv_ref%notfound;
dbms_output.put_line('SaleId:'  ||sale_details.saleid || ' CustId:' || sale_details.custid || ' ProdId:' || sale_details.prodid
                        || ' Date:' || sale_details.saledate || ' Amount:' || sale_details.qty);

end loop;

close rv_ref;

COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

/

create or replace function COUNT_PRODUCT_SALES_FROM_DB (pdays number) return number as

pCount number;
begin

select count(*) into pCount
from sale
where sysdate - saledate < pdays;
return pCount;

exception
when others then 
raise_application_error(-20000, sqlerrm);

end;

/

create or replace procedure COUNT_PRODUCT_SALES_VIASQLDEV (pdays number) as

pCount number;
begin

dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Counting sales within ' || pdays || ' days');

pCount := count_product_sales_from_db(pdays);

dbms_output.put_line('Total number of sales: ' || pCount);

exception
when others then 
dbms_output.put_line(sqlerrm);
end;

/

--------------------

----------
--Part 5--
----------

--------------------

create or replace function DELETE_SALE_FROM_DB return number as

pid number;
pqty number;
pprodid number;
pcustid number;
pprice number;
cust_sales number;
prod_sales number;
begin

select min(saleid) into pid from sale;

if pid is null then
raise no_data_found;
end if;

select qty, prodid, custid, price into pqty, pprodid, pcustid, pprice
from sale
where saleid = pid;

if SQL%NOTFOUND then 
raise no_data_found;
end if;

select sales_ytd into prod_sales from product 
where prodid = pprodid;

select  sales_ytd into cust_sales
from customer
where custid = pcustid;


delete from sale
where saleid = pid;

upd_cust_salesytd_in_db(pcustid,  - pqty*pprice);
upd_prod_salesytd_in_db(pprodid,  - pqty*pprice);

return pid;
exception
when no_data_found then
raise_application_error(-20287, 'No Sale Rows Found');
when others then 
raise_application_error(-20000, sqlerrm);
end;

/

create or replace procedure DELETE_SALE_VIASQLDEV as

pid number;
begin
dbms_output.put_line('--------------------------------------------');
dbms_output.put_line('Deleting Sale with smallest SaleId value');

pid := delete_sale_from_db;

dbms_output.put_line('Deleted Sale OK. SaleID:' || pid);

exception
when others then 
dbms_output.put_line(sqlerrm);

end;

/

create or replace PROCEDURE DELETE_ALL_SALES_FROM_DB as

rv_ref SYS_REFCURSOR;
cust_emp customer%rowtype;
prod_emp product%rowtype;

begin

delete from sale;

open rv_ref for select * from customer;

LOOP fetch rv_ref into cust_emp;
exit when rv_ref%notfound;
upd_cust_salesytd_in_db(cust_emp.custid, -cust_emp.sales_ytd);
end loop;

close rv_ref;

open rv_ref for select * from product;

LOOP fetch rv_ref into prod_emp;
exit when rv_ref%notfound;
upd_prod_salesytd_in_db(prod_emp.prodid, -prod_emp.sales_ytd);
end loop;

close rv_ref;

exception
when others then 
raise_application_error(-20000, sqlerrm);

end;

/

create or replace PROCEDURE DELETE_ALL_SALES_VIASQLDEV as

begin

DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting all Sales data in Sale, Customer, and Product tables');

delete_all_sales_from_db;

DBMS_OUTPUT.PUT_LINE('Deletion OK');

COMMIT;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

/

--------------------

----------
--Part 6--
----------

--------------------

create or replace procedure DELETE_CUSTOMER(pcustid number) as

pcount number;
no_data_found exception;
child_record_found exception;
begin

select count(*) into pcount 
from sale
where custid = pcustid;

if pcount = 0 then
delete from customer 
where custid = pcustid;
if SQL%NOTFOUND then
raise no_data_found;
end if;
else
raise child_record_found;
end if;

exception
when no_data_found then
raise_application_error(-20297, 'Customer ID not found');
when child_record_found then
raise_application_error(-20309, 'Customer cannot be deleted as sales exist');
when others then 
raise_application_error(-20000, sqlerrm);

end;

/ 

create or replace procedure DELETE_CUSTOMER_VIASQLDEV(pcustid number) as

begin
dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Deleting Customer. Cust Id:' || pcustid);

delete_customer(pcustid);

dbms_output.put_line('Delete Customer OK'); 
COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);

end;

/

create or replace procedure DELETE_PROD_FROM_DB(pprodid number) as

pcount number;
child_record_found exception;
begin

select count(*) into pcount 
from sale
where prodid = pprodid;


if pcount = 0 then
delete from product 
where prodid = pprodid;
if SQL%NOTFOUND then
raise no_data_found;
end if;
else
raise child_record_found;
end if;

exception
when no_data_found then
raise_application_error(-20317, 'Product ID not found');
when child_record_found then
raise_application_error(-20329, 'Product cannot be deleted as sales exist');
when others then 
raise_application_error(-20000, sqlerrm);

end;

/

create or replace procedure DELETE_PROD_VIASQLDEV(pprodid number) as

begin
dbms_output.put_line('-------------------------------------------');
dbms_output.put_line('Deleting Product. Product Id:' || pprodid);

delete_prod_from_db(pprodid);

dbms_output.put_line('Delete Product OK'); 
COMMIT;

exception
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);

end;

/

