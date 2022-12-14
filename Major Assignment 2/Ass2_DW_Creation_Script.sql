--MAJOR ASSESSMENT 2--
--TEAM  --
/*MEMBERS NAME: 
NGO CONG THANH - 130433609
PHAN TRONG HIEU
*/

-- 1.1
DROP SEQUENCE SEQ_A2ERROREVENT; 
CREATE SEQUENCE SEQ_A2ERROREVENT; 
/
DROP TABLE A2ERROREVENT; 
/
CREATE TABLE A2ERROREVENT (
ERRORID INTEGER,
SOURCE_ROWID ROWID,
SOURCE_TABLE VARCHAR2(30),
ERRORCODE INTEGER,
FILTERID INTEGER,
DATETIME DATE,
ACTION VARCHAR2(6),
CONSTRAINT ERROREVENTACTION
CHECK (ACTION IN ('SKIP','MODIFY'))
);
/
-- 1.2
DROP TABLE DWPROD;
DROP TABLE DWSALE;
DROP TABLE DWCUST;
DROP TABLE GENDERSPELLING; 
/ 
DROP SEQUENCE SEQ_DWPROD;
CREATE SEQUENCE SEQ_DWPROD; 
/
DROP SEQUENCE SEQ_DWSALE;
CREATE SEQUENCE SEQ_DWSALE;
/
CREATE TABLE DWPROD (
DWPRODID INTEGER,
DWSOURCETABLE VARCHAR2(20),
DWSOURCEID INTEGER,
PRODNAME VARCHAR2(120),
PRODCATNAME VARCHAR2(30),
PRODMANUNAME VARCHAR2(30),
PRODSHIPNAME VARCHAR2(30)
);
/
CREATE TABLE DWCUST (
DWCUSTID INTEGER,
DWSOURCEIDBRIS INTEGER,
DWSOURCEIDMELB INTEGER,
FIRSTNAME VARCHAR2(30),
SURNAME VARCHAR2(30),
GENDER VARCHAR2(10),
PHONE VARCHAR2(20),
POSTCODE NUMBER(4,0),
CITY VARCHAR2(50),
STATE VARCHAR2(10),
CUSTCATNAME VARCHAR2(30)
);
/
CREATE TABLE DWSALE (
DWSALEID INTEGER,
DWCUSTID INTEGER,
DWPRODID INTEGER,
DWSOURCEIDBRIS INTEGER,
DWSOURCEIDMELB INTEGER,
QTY NUMBER(2,0),
SALE_DWDATEID INTEGER,
SHIP_DWDATEID INTEGER,
SALEPRICE NUMBER(7,2)
);
/
-- 1.3
CREATE TABLE GENDERSPELLING(InvalidValue VARCHAR2(10), NewValue VARCHAR2(1)); 
/
INSERT INTO GENDERSPELLING VALUES('MAIL', 'M');
INSERT INTO GENDERSPELLING VALUES('WOMAN', 'F');
INSERT INTO GENDERSPELLING VALUES('FEM', 'F');
INSERT INTO GENDERSPELLING VALUES('FEMALE', 'F');
INSERT INTO GENDERSPELLING VALUES('MALE', 'M');
INSERT INTO GENDERSPELLING VALUES('GENTLEMAN', 'M');
INSERT INTO GENDERSPELLING VALUES('MM', 'M');
INSERT INTO GENDERSPELLING VALUES('FF', 'F');
INSERT INTO GENDERSPELLING VALUES('FEMAIL', 'F');
/ 
-- 2.1
 INSERT INTO A2ERROREVENT 
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID,'A2PRODUCT',107,1,TO_DATE(SYSDATE,'yyyy-mm-dd'),'SKIP'
 FROM A2Product P 
 WHERE P.PRODNAME IS NULL;
/
-- 2.2
INSERT INTO A2ERROREVENT
 SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2PRODUCT',135,2, SYSDATE, 'MODIFY'
 FROM A2PRODUCT P
 WHERE P.MANUFACTURERCODE IS NULL;
 COMMIT; 
/
-- 2.3
INSERT INTO A2ERROREVENT
 SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2PRODUCT',141,3, SYSDATE, 'MODIFY'
 FROM A2PRODUCT P
 WHERE P.PRODCATEGORY IS NULL OR P.PRODCATEGORY NOT IN (SELECT PC.PRODUCTCATEGORY
FROM A2PRODCATEGORY PC);
 COMMIT; 
/
-- 2.4.3
INSERT INTO DWPROD
 SELECT SEQ_DWPROD.NEXTVAL, 'A2PRODUCT', PRODID, PRODNAME, CATEGORYNAME, MANUNAME,
DESCRIPTION
 FROM A2PRODUCT P
 NATURAL JOIN A2MANUFACTURER M, A2SHIPPING S, A2PRODCATEGORY PC
 WHERE P.ROWID NOT IN (SELECT EE.SOURCE_ROWID FROM A2ERROREVENT EE) AND M.MANUCODE
= P.MANUFACTURERCODE AND PC.PRODUCTCATEGORY = P.PRODCATEGORY AND S.SHIPPINGCODE =
P.SHIPPINGCODE;
 COMMIT; 
/
--  2.4.4
INSERT INTO DWPROD
 SELECT SEQ_DWPROD.NEXTVAL, 'A2PRODUCT', PRODID, PRODNAME, CATEGORYNAME, 'UNKNOWN',
DESCRIPTION
 FROM A2PRODUCT P
 NATURAL JOIN A2PRODCATEGORY PC, A2SHIPPING S
 WHERE P.ROWID IN (SELECT EE.SOURCE_ROWID
 FROM A2ERROREVENT EE
 WHERE EE.FILTERID = 2 ) AND PC.PRODUCTCATEGORY = P.PRODCATEGORY AND
S.SHIPPINGCODE = P.SHIPPINGCODE;
 COMMIT; 
/
/
-- 2.4.5
INSERT INTO DWPROD
 SELECT SEQ_DWPROD.NEXTVAL, 'A2PRODUCT', PRODID, PRODNAME, 'UNKNOWN', MANUNAME,
DESCRIPTION
 FROM A2PRODUCT P
 NATURAL JOIN A2MANUFACTURER M, A2SHIPPING S
 WHERE P.ROWID IN (SELECT EE.SOURCE_ROWID
 FROM A2ERROREVENT EE
 WHERE EE.FILTERID = 3 ) AND M.MANUCODE = P.MANUFACTURERCODE AND
S.SHIPPINGCODE = P.SHIPPINGCODE;
 COMMIT;
/ 
--3.1
INSERT INTO A2ERROREVENT 
 SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2CUSTBRIS', 163, 4, SYSDATE, 'MODIFY' 
 FROM A2CUSTBRIS CB 
 WHERE CB.CUSTCATCODE NOT IN(SELECT CC.CUSTCATCODE 
 FROM A2CUSTCATEGORY CC) OR CB.CUSTCATCODE IS NULL; 
 COMMIT;
/
--3.2
INSERT INTO A2ERROREVENT 
 SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2CUSTBRIS', 199, 5, SYSDATE, 'MODIFY' 
 FROM A2CUSTBRIS CB 
 WHERE INSTR(CB.PHONE, '-')>0 OR INSTR(CB.PHONE, ' ')>0; 
 COMMIT;
/
--3.3
INSERT INTO A2ERROREVENT 
 SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2CUSTBRIS', 204, 6, SYSDATE, 'SKIP' 
 FROM A2CUSTBRIS CB 
 WHERE (NOT(PHONE LIKE '%-%' OR PHONE LIKE '% %')) AND LENGTH(CB.PHONE) != 10; 
 COMMIT;
/
--3.4
INSERT INTO A2ERROREVENT 
 SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2CUSTBRIS', 237, 7, SYSDATE, 'MODIFY' 
FROM A2CUSTBRIS CB 
 WHERE UPPER(CB.GENDER) NOT LIKE 'M' AND UPPER(CB.GENDER) NOT LIKE 'F' OR CB.GENDER 
IS NULL; 
COMMIT;
/
--3.5.1
INSERT INTO DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, 
POSTCODE, CITY, STATE, CUSTCATNAME) 
 SELECT SEQ_DWCUST.NEXTVAL, CUSTID, FNAME, SNAME, UPPER(GENDER), PHONE, POSTCODE, CITY, 
CB.STATE, CUSTCATNAME 
 FROM A2CUSTBRIS CB 
 NATURAL JOIN A2CUSTCATEGORY CC 
 WHERE CB.ROWID NOT IN (SELECT EE.SOURCE_ROWID 
 FROM A2ERROREVENT EE); 
 COMMIT;
/
--3.5.2
INSERT INTO DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, 
POSTCODE, CITY, STATE, CUSTCATNAME) 
 SELECT SEQ_DWCUST.NEXTVAL, CUSTID, FNAME, SNAME, UPPER(GENDER), PHONE, POSTCODE, CITY, 
CB.STATE, 'UNKNOWN' 
 FROM A2CUSTBRIS CB 
 WHERE CB.ROWID IN (SELECT EE.SOURCE_ROWID 
 FROM A2ERROREVENT EE 
 WHERE EE.FILTERID = 4); 
 COMMIT;
/
--3.5.3
INSERT INTO DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, 
POSTCODE, CITY, STATE, CUSTCATNAME) 
 SELECT SEQ_DWCUST.NEXTVAL, CUSTID, FNAME, SNAME, UPPER(GENDER), 
REPLACE(REPLACE(PHONE,'-',''),' ',''), POSTCODE, CITY, CB.STATE, CUSTCATNAME 
 FROM A2CUSTBRIS CB 
 NATURAL JOIN A2CUSTCATEGORY CC
 WHERE CB.ROWID IN (SELECT EE.SOURCE_ROWID 
 FROM A2ERROREVENT EE 
 WHERE EE.FILTERID = 5); 
 COMMIT;
/
--3.5.4
INSERT INTO DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, 
POSTCODE, CITY, STATE, CUSTCATNAME) 
 SELECT SEQ_DWCUST.NEXTVAL, CUSTID, FNAME, SNAME, 
 CASE WHEN UPPER(CB.GENDER) IN (SELECT INVALIDVALUE 
 FROM GENDERSPELLING) 
 THEN (SELECT NEWVALUE FROM GENDERSPELLING GS WHERE UPPER(CB.GENDER) = 
GS.INVALIDVALUE) 
 ELSE 'U' 
 END, 
 PHONE, POSTCODE, CITY, CB.STATE, CUSTCATNAME 
 FROM A2CUSTBRIS CB 
 NATURAL JOIN A2CUSTCATEGORY CC 
 WHERE CB.ROWID IN (SELECT EE.SOURCE_ROWID 
 FROM A2ERROREVENT EE 
 WHERE EE.FILTERID = 7); 
 COMMIT;
 /
-- 4.1
MERGE INTO DWCUST DC
USING (SELECT * FROM A2CUSTMELB A2CM INNER JOIN A2CUSTCATEGORY A2CC ON
A2CM.CUSTCATCODE = A2CC.CUSTCATCODE) CM 
ON (DC.FIRSTNAME = CM.FNAME AND DC.SURNAME = CM.SNAME AND DC.POSTCODE =
CM.POSTCODE)
WHEN MATCHED THEN UPDATE SET DC.DWSOURCEIDMELB = CM.CUSTID
WHEN NOT MATCHED THEN INSERT (DWCUSTID, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER,
PHONE, POSTCODE, CITY, STATE, CUSTCATNAME)
VALUES(SEQ_DWCUST.NEXTVAL, CM.CUSTID, CM.FNAME, CM.SNAME, UPPER(CM.GENDER),
CM.PHONE, CM.POSTCODE, CM.CITY, CM.STATE, CM.CUSTCATNAME);
 COMMIT;
/ 
-- 5.1
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEBRIS',248,8, SYSDATE, 'SKIP'
FROM A2SALEBRIS SB
WHERE SB.PRODID NOT IN (SELECT DWSOURCEID FROM DWPROD) OR SB.PRODID IS NULL;
 COMMIT;
/
-- 5.2
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEBRIS',266,9, SYSDATE, 'SKIP'
FROM A2SALEBRIS
WHERE NOT EXISTS
(SELECT NULL FROM DWCUST
WHERE A2SALEBRIS.CUSTID=DWCUST.DWSOURCEIDBRIS);
 COMMIT;
/ 
-- 5.3
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEBRIS',293,10, SYSDATE, 'MODIFY'
FROM A2SALEBRIS
WHERE SHIPDATE < SALEDATE;
COMMIT; 
/
-- 5.4
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEBRIS',318,11, SYSDATE, 'MODIFY'
FROM A2SALEBRIS
WHERE UNITPRICE IS NULL;
COMMIT;
/
-- 5.5
INSERT INTO DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDBRIS, QTY, SALE_DWDATEID,
SHIP_DWDATEID, SALEPRICE)
SELECT SEQ_DWSALE.NEXTVAL, (SELECT DWCUSTID FROM DWCUST WHERE DWSOURCEIDBRIS =
SB.CUSTID),
(SELECT DWPRODID FROM DWPROD WHERE DWSOURCEID = SB.PRODID), SB.SALEID, SB.QTY,
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SB.SALEDATE),
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SB.SHIPDATE), SB.UNITPRICE
FROM A2SALEBRIS SB
WHERE ROWID NOT IN (SELECT SOURCE_ROWID FROM A2ERROREVENT);
COMMIT;
/ 
-- 5.6
INSERT INTO DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDBRIS, QTY, SALE_DWDATEID,
SHIP_DWDATEID, SALEPRICE)
SELECT SEQ_DWSALE.NEXTVAL, (SELECT DWCUSTID FROM DWCUST WHERE DWSOURCEIDBRIS =
SB.CUSTID),
(SELECT DWPRODID FROM DWPROD WHERE DWSOURCEID = SB.PRODID), SB.SALEID, SB.QTY,
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SB.SALEDATE),
((SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SB.SALEDATE)+2), SB.UNITPRICE
FROM A2SALEBRIS SB
WHERE ROWID IN (SELECT SOURCE_ROWID FROM A2ERROREVENT WHERE FILTERID = 10);
COMMIT;
/
-- 5.7
INSERT INTO DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDBRIS, QTY, SALE_DWDATEID,
SHIP_DWDATEID, SALEPRICE)
SELECT SEQ_DWSALE.NEXTVAL, (SELECT DWCUSTID FROM DWCUST WHERE SB.CUSTID =
DWSOURCEIDBRIS),
(SELECT DWPRODID FROM DWPROD WHERE DWSOURCEID = SB.PRODID), SB.SALEID, SB.QTY,
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SB.SALEDATE),
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SB.SHIPDATE),
(SELECT MAX(UNITPRICE) FROM A2SALEBRIS WHERE PRODID = DP.DWSOURCEID)
FROM A2SALEBRIS SB
INNER JOIN DWPROD DP ON SB.PRODID = DP.DWSOURCEID
WHERE SB.ROWID IN (SELECT SOURCE_ROWID FROM A2ERROREVENT WHERE FILTERID = 11);
COMMIT;
/ 
--TASK6.1--
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEMELB',322, 12, SYSDATE, 'SKIP'
From A2SALEMELB
Where A2SALEMELB.PRODID NOT IN (SELECT dwprod.dwsourceid FROM DWPROD);
 COMMIT;
/
--TASK6.2--
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEMELB',350, 13, SYSDATE, 'SKIP'
From A2SALEMELB
Where A2SALEMELB.CUSTID NOT IN (SELECT DWCUST.DWSOURCEIDMELB FROM DWCUST where DWCUST.DWSOURCEIDMELB IS NOT NULL) OR A2SALEMELB.CUSTID IS NULL;
COMMIT;
/
--TASK6.3--
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEMELB',365, 14, SYSDATE, 'MODIFY'
From A2SALEMELB
Where A2SALEMELB.SHIPDATE < A2SALEMELB.saledate;
COMMIT;
/
--TASK6.4--
INSERT INTO A2ERROREVENT
SELECT SEQ_A2ERROREVENT.NEXTVAL, ROWID, 'A2SALEMELB',396, 15, SYSDATE, 'MODIFY'
From A2SALEMELB
Where A2SALEMELB.UNITPRICE IS NULL;
COMMIT;
/
--TASK6.5--
INSERT INTO DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDMELB, QTY, SALE_DWDATEID,
SHIP_DWDATEID, SALEPRICE)
SELECT SEQ_DWSALE.NEXTVAL, (SELECT DWCUSTID FROM DWCUST WHERE DWSOURCEIDMELB =
SM.CUSTID),
(SELECT DWPRODID FROM DWPROD WHERE DWSOURCEID = SM.PRODID), SM.SALEID, SM.QTY,
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SM.SALEDATE),
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SM.SHIPDATE), SM.UNITPRICE
FROM A2SALEMELB SM
WHERE ROWID NOT IN (SELECT SOURCE_ROWID FROM A2ERROREVENT);
COMMIT;
/
--TASK6.6--
INSERT INTO DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDMELB, QTY, SALE_DWDATEID,
SHIP_DWDATEID, SALEPRICE)
SELECT SEQ_DWSALE.NEXTVAL, (SELECT DWCUSTID FROM DWCUST WHERE DWSOURCEIDMELB =
SM.CUSTID),
(SELECT DWPRODID FROM DWPROD WHERE DWSOURCEID = SM.PRODID), SM.SALEID, SM.QTY,
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SM.SALEDATE),
((SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SM.SALEDATE)+2), SM.UNITPRICE
FROM A2SALEMELB SM
WHERE ROWID IN (SELECT SOURCE_ROWID FROM A2ERROREVENT WHERE FILTERID = 14);
COMMIT;
/
--TASK6.7--
INSERT INTO DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDMELB, QTY, SALE_DWDATEID,
SHIP_DWDATEID, SALEPRICE)
SELECT SEQ_DWSALE.NEXTVAL, (SELECT DWCUSTID FROM DWCUST WHERE DWSOURCEIDMELB =
SM.CUSTID),
(SELECT DWPRODID FROM DWPROD WHERE DWSOURCEID = SM.PRODID), SM.SALEID, SM.QTY,
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SM.SALEDATE),
(SELECT DATEKEY FROM DWDATE WHERE DATEVALUE = SM.SHIPDATE),
(SELECT MAX(UNITPRICE) FROM A2SALEMELB WHERE PRODID = DP.DWSOURCEID)
FROM A2SALEMELB SM
INNER JOIN DWPROD DP ON SM.PRODID = DP.DWSOURCEID
WHERE SM.ROWID IN (SELECT SOURCE_ROWID FROM A2ERROREVENT WHERE FILTERID = 15);
COMMIT; 
/
--TASK7.1--
DELETE FROM DWSALE DS
WHERE DS.DWSOURCEIDMELB IN (SELECT SALEID As DWSOURCEIDMELB FROM A2SALEMELB SM
WHERE SM.ROWID IN (SELECT SOURCE_ROWID FROM A2ERROREVENT WHERE SOURCE_TABLE = 'A2SALEMELB' 
GROUP BY SOURCE_ROWID HAVING COUNT(SOURCE_ROWID)>1));


--Part 8

--A
select to_char(dd.datevalue, 'DAY') as "Weekday", 
sum(ds.qty * ds.saleprice) as "Total Sale"
from dwsale ds
inner join dwdate dd on ds.sale_dwdateid=dd.datekey
group by to_char(dd.datevalue, 'DAY')
order by sum(ds.qty) * sum(ds.saleprice) desc;

--B
select dwcust.custcatname AS "Customer Category"
, sum(qty * saleprice) AS "Total Sale"
from dwsale 
inner join dwcust 
on dwsale.dwcustid = dwcust.dwcustid
group by custcatname 
order by sum(qty * saleprice) desc;

--C
select dp.PRODMANUNAME as "PRODMANUNAME", sum(ds.qty) as "TOTAL QTY SOLD"
from dwprod dp
inner join dwsale ds on  dp.dwprodid = ds.dwprodid
group by dp.PRODMANUNAME
order by sum(ds.qty) desc;

--D
select dc.DWCUSTID, FIRSTNAME, SURNAME, sum(ds.qty * ds.saleprice) as "Total Sale"
from dwcust dc
inner join dwsale ds on dc.dwcustid = ds.dwcustid
group by dc.DWCUSTID,dc.FIRSTNAME, dc.SURNAME
order by sum(ds.qty * ds.saleprice) desc
fetch first 10 rows only;

--E
select dp.DWPRODID, PRODNAME, sum(ds.qty * ds.saleprice) as "Total Sale"
from dwprod dp
inner join dwsale ds on dp.dwprodid = ds.dwprodid
group by dp.DWPRODID, dp.PRODNAME
order by sum(ds.qty * ds.saleprice) asc
fetch first 10 rows only;

--F
select CITY, STATE, sum(ds.qty * ds.saleprice) as "Total Sale"
from dwcust dc
inner join dwsale ds on dc.dwcustid = ds.dwcustid
group by dc.DWCUSTID, dc.CITY, dc.STATE
order by sum(ds.qty * ds.saleprice) asc;