SELECT * FROM CUSTOMERS;
SELECT * FROM LEARNING_MODULES;
SELECT * FROM MEETINGS;
SELECT * FROM RM_NAMES;


/*ADDING NEW COLUMN */
ALTER TABLE CUSTOMERS
ADD COLUMN APR_21_BAL INT,
ADD COLUMN MAR_22_BAL INT,
ADD COLUMN INCREMENTAL_BAL_FY INT;


/*UPDATING NEW COLUMN BY REMOVING COMMA FROM TEXT AND CHANGING FROM TEXT TO INTEGER*/
UPDATE CUSTOMERS
SET APR_21_BAL=CAST(REPLACE(APR_21_MAB,",","") AS UNSIGNED),
 MAR_22_BAL=CAST(REPLACE(MAR_22_MAB,",","") AS UNSIGNED),
 INCREMENTAL_BAL_FY=CAST(REPLACE(INCREMENTAL_CASA,",","")AS SIGNED);
 
 
 /*DROP OLD COLUMN WHICH HAS INTEGER IN TEXT FORMAT*/
ALTER TABLE CUSTOMERS 
DROP COLUMN APR_21_MAB,
DROP COLUMN MAR_22_MAB,
DROP COLUMN INCREMENTAL_CASA;

/*LIST OF RELATIONSHIP MANAGERS*/
SELECT  NAMES FROM RM_NAMES; 

/*RELATIONSHIP MANAGERS BOOK SIZE IN THE START OF FY 21-22 AND TOTAL NO OF CLIENTS MAPPED*/
SELECT NAMES,COUNT(CUSTOMER_NAME) AS TOTAL_CLIENTS ,SUM(APR_21_BAL) AS BOOK_SIZE
 FROM CUSTOMERS C INNER JOIN RM_NAMES RN ON C.RM_ID=RN.RM_ID
 GROUP BY NAMES ORDER BY BOOK_SIZE DESC ;

/*RELATIONSHIP MANAGERS BOOK SIZE AND TOTAL NO OF CLIENTS AT THE END OF FY-21-22*/
SELECT NAMES,COUNT(CUSTOMER_NAME) AS TOTAL_CLIENTS ,SUM(MAR_22_BAL) AS BOOK_SIZE
 FROM CUSTOMERS C INNER JOIN RM_NAMES RN ON C.RM_ID=RN.RM_ID
 GROUP BY NAMES ORDER BY BOOK_SIZE DESC ;
 
 /*RELATIONSHIP MANAGERS WITH THEIE INCREMENTAL BOOK SIZE IN FY-21-22*/
 SELECT NAMES,SUM(INCREMENTAL_BAL_FY) AS INCREMENTAL_BOOK
 FROM CUSTOMERS C INNER JOIN RM_NAMES RN ON C.RM_ID=RN.RM_ID
 GROUP BY NAMES ORDER BY INCREMENTAL_BOOK DESC ;

 
/*TO CHECK RM WISE TOTAL PRODUCT SOLD IN FY 21-22*/
SELECT NAMES,SUM(TOTAL_PRODUCTS) AS TOTAL_UNITS_SOLD 
FROM CUSTOMERS C INNER JOIN RM_NAMES RN ON C.RM_ID=RN.RM_ID
 GROUP BY NAMES ORDER BY TOTAL_UNITS_SOLD DESC;

/*TO CHECK RM WISE TOTAL REVENUE GENERATED IN FY-21-22*/
SELECT NAMES,SUM(REVENUE) AS TOTAL_REVENUE 
FROM CUSTOMERS C INNER JOIN RM_NAMES RN ON C.RM_ID=RN.RM_ID
INNER JOIN REVENUE R ON R.CUST_ID=C.CUST_ID
 GROUP BY NAMES ORDER BY TOTAL_REVENUE DESC;


/*RM WISE MEETING DONE IN FY 21-22*/
WITH TEMPTABLE AS (SELECT NAMES,C.CUST_ID,MEETINGS_DONE
 FROM CUSTOMERS C INNER JOIN MEETINGS MEET
 ON C.CUST_ID=MEET.CUST_ID INNER JOIN RM_NAMES RN ON RN.RM_ID=C.RM_ID) 
 SELECT NAMES,SUM(MEETINGS_DONE) AS TOTAL_MEETINGS
 FROM TEMPTABLE GROUP BY NAMES 
 ORDER BY TOTAL_MEETINGS DESC ;
 
 /*RM WISE NUMBER OF MODULES COMPLETED*/
 SELECT NAMES,MODULES_COMPLETED 
 FROM LEARNING_MODULES LM INNER JOIN RM_NAMES RN ON RN.NAMES=LM.NAME  ORDER BY MODULES_COMPLETED DESC;
 
 
 /*KPI CALCULATION*/
SET  @REVENUE:=1200000;
SET @CASA:=3000000;
SET @MEETINGS:=1460;
SET @MODULES:=20;

 
WITH TEMPTABLE2 AS (WITH TEMPTABLE1 AS (WITH TEMPTABLE AS ( SELECT NAMES,CUSTOMER_NAME,INCREMENTAL_BAL_FY,MEETINGS_DONE,TOTAL_PRODUCTS,REVENUE,MODULES_COMPLETED
 FROM CUSTOMERS C
 INNER JOIN RM_NAMES RN ON RN.RM_ID=C.RM_ID
 INNER JOIN REVENUE R ON R.CUST_ID=C.CUST_ID
 INNER JOIN MEETINGS MEET ON MEET.CUST_ID=C.CUST_ID
 INNER JOIN LEARNING_MODULES LM ON RN.NAMES=LM.NAME
 )SELECT NAMES,SUM(REVENUE) AS TOTAL_REVENUE,
 SUM(INCREMENTAL_BAL_FY) AS BOOK_GROWTH ,SUM(MEETINGS_DONE) AS TOTAL_MEETINGS ,MODULES_COMPLETED 
 FROM TEMPTABLE GROUP BY NAMES,MODULES_COMPLETED)SELECT NAMES,CASE
 WHEN TOTAL_REVENUE<0.5*@REVENUE THEN 1*0.5
 WHEN 0.5*@REVENUE<=TOTAL_REVENUE<0.7*@REVENUE THEN 2*0.5
 WHEN 0.7*@REVENUE<=TOTAL_REVENUE<0.9*@REVENUE THEN 3*0.5
 ELSE 0.5*4 END AS REVENUE_RATING ,CASE 
 WHEN BOOK_GROWTH <0.5*@CASA THEN 0.2*1
 WHEN 0.5*@CASA<=BOOK_GROWTH<0.7*@CASA THEN 0.2*2
 WHEN 0.7*@CASA<=BOOK_GROWTH<0.9*@CASA THEN 0.2*3
 ELSE 0.2*4 END AS CASA_RATING ,CASE
 WHEN TOTAL_MEETINGS<0.7*@MEETINGS THEN 0.2*1
 WHEN 0.7*@MEETINGS<=TOTAL_MEETINGS<0.8*@MEETINGS THEN 0.2*2
 WHEN 0.8*@MEETINGS<=TOTAL_MEETINGS<0.9*@MEETINGS THEN 0.2*3
 ELSE 0.2*4 END AS MEETINGS_RATING,CASE
 WHEN MODULES_COMPLETED<0.5*@MODULES THEN 0.1*1
 WHEN 0.5*@MODULES<=MODULES_COMPLETED<0.7*@MODULES  THEN 0.1*2
 WHEN 0.7*@MODULES<=MODULES_COMPLETED<0.9*@MODULES THEN 0.1*3
 ELSE 0.1*4 END AS MODULES_RATING FROM TEMPTABLE1) SELECT NAMES ,REVENUE_RATING+CASA_RATING+MEETINGS_RATING+MODULES_RATING AS RATING 
 FROM TEMPTABLE2;
 
 



