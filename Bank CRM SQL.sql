

#Joining the two table
use crm;
SELECT 
    *
FROM
    bank_churn bc
        LEFT JOIN
    customer_info ci ON ci.CustomerId = bc.CustomerId
        INNER JOIN
    gender gen ON ci.GenderID = gen.GenderID
        INNER JOIN
    exit_customer ec ON ec.ExitID = bc.Exited
        INNER JOIN
    credit_card cc ON cc.CreditID = bc.Has_creditcard
        INNER JOIN
    geography geo ON geo.GeographyID = ci.GeographyID
        INNER JOIN
    active_customer ac ON ac.ActiveID = bc.IsActiveMember
;


-- ==========================================================================================================================================================================================================================================================================
#Obj Q1. 




-- =========================================================================================================================================================================================================================================================================
# Obj Q2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. 

	SELECT 
    Surname, sum(EstimatedSalary )AS qrt_sal
FROM
    customer_info
WHERE
	Bank_DOJ BETWEEN '01-09-2019' AND '31-12-2019'
	GROUP BY Surname
   ORDER BY sum(EstimatedSalary) DESC
LIMIT 5; 
-- =========================================================================================================================================================================================
# Obj Q3.	Calculate the average number of products used by customers who have a credit card. (SQL)
	SELECT 
    AVG(NumOfProducts) AS avg_product_by_credit_card
FROM
    bank_churn bc
        LEFT JOIN
    customer_info ci ON ci.CustomerId = bc.CustomerId
        INNER JOIN
    gender gen ON ci.GenderID = gen.GenderID
        INNER JOIN
    exit_customer ec ON ec.ExitID = bc.Exited
        INNER JOIN
    credit_card cc ON cc.CreditID = bc.Has_creditcard
        INNER JOIN
    geography geo ON geo.GeographyID = ci.GeographyID
        INNER JOIN
    active_customer ac ON ac.ActiveID = bc.IsActiveMember
WHERE
    cc.Category = 'credit card holder';

-- =========================================================================================================================================================================================
# Q4.  Determine the churn rate by gender for the most recent year in the dataset.
-- *******
-- ========================================================================================================================================================================================
# Q5.  Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT 
   ec.ExitCategory, avg(bc.CreditScore) as avg_credit_score
FROM
    bank_churn bc
        INNER JOIN
    exit_customer ec ON bc.Exited = ec.ExitID
   group by ec.ExitCategory
;
-- ==============================================================================================================================================================================================
# Q6.  Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
   WITH ActiveAccounts AS (
    SELECT CustomerId,COUNT(*) AS ActiveAccounts
    FROM Bank_Churn
    WHERE IsActiveMember = 1
    GROUP BY customerId
)
SELECT CASE WHEN c.GenderID = 1 THEN 'Male' ELSE 'Female' END AS Gender,
    COUNT(aa.CustomerId) AS ActiveAccounts, round(AVG(c.EstimatedSalary),2) AS AvgSalary
FROM customer_info c
LEFT JOIN ActiveAccounts aa ON c.CustomerId = aa.CustomerId
GROUP BY Gender
ORDER BY AvgSalary DESC;
    
-- ========================================================================================================================================================================================================
# Q7.  Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
WITH credit_score_segments AS (
  SELECT
    customerid, isactivemember,
   CASE
      WHEN creditscore between 800 and 850 THEN 'Excellent'
      WHEN creditscore between 740 and 799 THEN 'Very Good'
      WHEN creditscore between 670 and 739 THEN 'Good'
      WHEN creditscore between 580 and 669 THEN 'Fair'
      ELSE 'Poor'
    END AS credit_score_segment
  FROM bank_churn
)
SELECT
  credit_score_segment,
  AVG(CASE WHEN isactivemember = 0 THEN 0 ELSE 1 END) AS exit_rate
FROM credit_score_segments
GROUP BY credit_score_segment
ORDER BY exit_rate DESC
LIMIT 1;

-- ===================================================================================================================================================================================================================
# Obj Q8.  Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)

SELECT 
    geo.GeographyLocation,
    COUNT(ac.ActiveCategory) AS active_member_count
FROM
    bank_churn bc
        LEFT JOIN
    customer_info ci ON ci.CustomerId = bc.CustomerId
        INNER JOIN
    gender gen ON ci.GenderID = gen.GenderID
        INNER JOIN
    exit_customer ec ON ec.ExitID = bc.Exited
        INNER JOIN
    credit_card cc ON cc.CreditID = bc.Has_creditcard
        INNER JOIN
    geography geo ON geo.GeographyID = ci.GeographyID
        INNER JOIN
    active_customer ac ON ac.ActiveID = bc.IsActiveMember
where
    ac.ActiveCategory = 'Active Member'
        AND bc.Tenure > 5
GROUP BY geo.GeographyLocation
ORDER BY ac.ActiveCategory DESC
limit 1
;
-- ===========================================================================================
#10.	For customers who have exited, what is the most common number of products they have used?
SELECT 
	count(bc.CustomerID) , NumOfProducts
FROM
     bank_churn bc
        LEFT JOIN
    customer_info ci ON ci.CustomerId = bc.CustomerId
        INNER JOIN
    exit_customer ec ON ec.ExitID = bc.Exited
        where bc.Exited = 1
    group by NumOfProducts
    ;
-- ====================================================================================================================================================================================================================================================================================    
# 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.   
    SELECT  
    count(CustomerID),
    extract(month from str_to_date(Bank_DOJ,'%d-%m-%Y')) as "month_Joining" ,
    extract(year from str_to_date(Bank_DOJ,'%d-%m-%Y')) as "Year_Joining" 
FROM
    customer_info
  group by month_Joining, Year_Joining
order by  Year_Joining,month_Joining ; 
-- ======================================================================================================================================================
#12.   Analyse the relationship between the number of products and the account balance for customers who have exited.
SELECT 
	 NumOfProducts, round(sum(Balance),0) as SumOFBalanace
FROM
     bank_churn bc
        
        where bc.Exited = 1
     
    group by NumOfProducts
    order by SumOFBalanace desc
    ;


-- ============================================================================================================================================================================================================================
#15.   Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)
select  
	ci.GeographyID,
    geo.GeographyLocation,
	avg(ci.EstimatedSalary) as average_salary,
	gen.GenderCategory,
	rank() over(partition by ci.GeographyID order by avg(ci.EstimatedSalary) desc ) gender_rank


from bank_churn bc
left join customer_info ci on ci.CustomerId=bc.CustomerId
inner join gender gen on ci. GenderID= gen.GenderID
inner join geography geo on geo.GeographyID=ci.GeographyID
group by gen.GenderCategory, ci.GeographyID,geo.GeographyLocation
;

-- =============================================================================================================================================================================================================================
# 16.  Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
with bracket as (
	select bc.Tenure , 
   case when ci.Age between 18 and 29 then "18-30"
		when ci.Age between 30 and 49 then "30-50" 
        else "50 and above"
        end as age_bracket
        from bank_churn bc 
        left join customer_info ci on bc.CustomerID=ci.CustomerID
    ) 
  select age_bracket, round(avg(Tenure),2) avg_tenure
   
  from bracket
group by age_bracket
order by age_bracket asc
;
-- =========================================================================================================================================================================
#17.	Is there any direct correlation between salary and the balance of the customers? And is it different for people who have exited or not?
SELECT 
round((count(*) * sum(bc.Balance * ci.EstimatedSalary) - sum(bc.Balance) * sum(ci.EstimatedSalary)) / 
(sqrt(count(*) * sum(bc.Balance * bc.Balance) - sum(bc.Balance) * sum(bc.Balance)) * sqrt(count(*) * 
sum(ci.EstimatedSalary * ci.EstimatedSalary) - sum(ci.EstimatedSalary) * sum(ci.EstimatedSalary))),4) 
AS correlation_coefficient_sample
FROM bank_churn as bc
left join customer_info as ci on ci.customerID=bc.CustomerID;
-- ===========================================================================================================================================================================
#18.   Is there any correlation between the salary and the Credit score of customers?
SELECT 
round((count(*) * sum(bc.Has_creditcard * ci.EstimatedSalary) - sum(bc.Has_creditcard) * sum(ci.EstimatedSalary)) / 
(sqrt(count(*) * sum(bc.Has_creditcard * bc.Has_creditcard) - sum(bc.Has_creditcard) * 
sum(bc.Has_creditcard)) * sqrt(count(*) * sum(ci.EstimatedSalary * ci.EstimatedSalary) - sum(ci.EstimatedSalary) * sum(ci.EstimatedSalary))),4) 
AS correlation_coefficient_sample
FROM bank_churn as bc
left join customer_info ci on bc.CustomerID=ci.CustomerID
;
-- ========================================================================================================================================================================================================================
#19.   Rank each bucket of credit score as per the number of customers who have churned the bank.
select 
case when CreditScore >=800 then 'Excelent'
	when CreditScore between 740 and 799 then 'Very Good'
	when CreditScore between 670 and 739 then 'Good'
	when CreditScore between 580 and 699 then 'Fair'
	else 'Poor'
end as CreditSegment,
sum(Exited) as CreditScoreBucket ,
rank() over(order by sum(Exited) desc) as churned_rank
from bank_churn
where Exited = 1
group by CreditSegment;



-- ===========================================================================================================================================================================================================================================
#20.   According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per bucket.

WITH info AS (
SELECT 
    CASE
        WHEN ci.Age BETWEEN 18 AND 30 THEN 'Adult'
        WHEN ci.Age BETWEEN 31 AND 50 THEN 'Middle-Aged'
        ELSE 'Old-Aged'
    END AS age_brackets,
    count(ci.CustomerId) AS HasCreditCard
FROM customer_info ci JOIN bank_churn b ON ci.CustomerId=b.CustomerId
WHERE ci.CustomerId = 1
GROUP BY age_brackets)
SELECT *
FROM info
WHERE  HasCreditCard < (SELECT AVG(HasCreditCard) FROM info);
-- ============================================================================================================================================================================================================================================
#21.   Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
select  
geo.GeographyLocation, 
count(bc.Exited) as churned,
round(avg(bc.Balance),2) average_balance,
rank() over(order by count(bc.Exited) desc) as ranking
from bank_churn bc
left join customer_info ci on ci.CustomerId=bc.CustomerId
inner join geography geo on geo.GeographyID=ci.GeographyID
where bc.Exited=1
group by geo.GeographyLocation 
;
-- ===================================================================================================================================================================================================================
#22.   As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.

select concat(CustomerID, '  ' ,Surname) as CustomerID_Surname from customer_info;



-- =====================================================================================================================================================================================================================
#23.   Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
--     yes we do his by using 'Select' clause to select columns and 'Where' clause to match column column in two tables
--     Below is the code for this.

select * from bank_churn,exit_customer where exit_customer.ExitID=bank_churn.Exited;
-- ========================================================================================================================================================================================================
#24.   Were there any missing values in the data, using which tool did you replace them and what are the ways to handle them?


# No.

-- ======================================================================================================================================================================================================================
#25.   Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
SELECT 
    bc.CustomerID, ci.Surname AS Last_Name, ac.ActiveCategory
FROM
    bank_churn bc
        LEFT JOIN
    customer_info ci ON ci.CustomerId = bc.CustomerId
        INNER JOIN
    gender gen ON ci.GenderID = gen.GenderID
        INNER JOIN
    exit_customer ec ON ec.ExitID = bc.Exited
        INNER JOIN
    credit_card cc ON cc.CreditID = bc.Has_creditcard
        INNER JOIN
    geography geo ON geo.GeographyID = ci.GeographyID
        INNER JOIN
    active_customer ac ON ac.ActiveID = bc.IsActiveMember
WHERE
    ci.Surname LIKE '%on'
;

-- ==================================================================================================================================================================================================================================

/*Subjective Question:*/

#Sub Q9.	Utilize SQL queries to segment customers based on demographics and account details.
SELECT 
    CASE
        WHEN ci.age < 18 THEN 'Under 18'
        WHEN ci.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN ci.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN ci.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN ci.age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    CASE
        WHEN bc.Balance < 1000 THEN 'Under 1000'
        WHEN bc.Balance BETWEEN 1000 AND 5000 THEN '1000-5000'
        WHEN bc.Balance BETWEEN 5000 AND 10000 THEN '5000-10000'
        ELSE '10000+'
    END AS balance_group,
    COUNT(ci.CustomerID) AS customer_count,
    COUNT(gen.GenderCategory),
    geo.GeographyLocation
FROM
    bank_churn bc
        LEFT JOIN
    customer_info ci ON ci.CustomerId = bc.CustomerId
        INNER JOIN
    gender gen ON ci.GenderID = gen.GenderID
        INNER JOIN
    exit_customer ec ON ec.ExitID = bc.Exited
        INNER JOIN
    credit_card cc ON cc.CreditID = bc.Has_creditcard
        INNER JOIN
    geography geo ON geo.GeographyID = ci.GeographyID
        INNER JOIN
    active_customer ac ON ac.ActiveID = bc.IsActiveMember
GROUP BY ci.age , geo.GeographyLocation , balance_group;
-- ===================================================================================================================================================================================================================================================================
#Sub Q14. In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?
 Alter table bank_churn
 rename column HasCrCard to Has_creditcard;
SELECT 
    *
FROM
    bank_churn;

