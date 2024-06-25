# OBJECTIVE QUESTIONS

# 2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

select customerID,
Surname,
max(EstimatedSalary) as EstimateDalary
from customerinfo
	where quarter(Bank_DOJ) = 4
group by 1, 2
limit 5;

# 3. Calculate the average number of products used by customers who have a credit card. (SQL)

select
round(avg(NumOfProducts), 0) as AverageNoOfProducts
from bank_churn
	where HasCrCard = 1;
    
# 5. Compare the average credit score of customers who have exited and those who remain. (SQL)

select ExitCategory,
avg(CreditScore) as AvgCreditScore
from bank_churn b
inner join exitcustomer e
on b.Exited = e.ExitID
group by 1;

# 6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)

select genderCategory,
Round(avg(EstimatedSalary), 0) as AvgEstimatedSalary,
count(IsActiveMember) as ActiveAccounts
from customerinfo c  inner join gender g on c.GenderID = g.GenderID
inner join bank_churn b on c.CustomerId = b.CustomerId
	where IsActiveMember = 1
group by 1;

# 7. Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

select case
when CreditScore >= 800 then 'Excellent'
when CreditScore < 800 and CreditScore >= 740 then 'Very Good'
when CreditScore < 740 and CreditScore >= 670 then 'Good'
when CreditScore < 670 and CreditScore >= 580 then 'Fair'
else 'Poor'
end as CreditScoreSegment, 
Round((sum(Exited)/count(*))*100, 2) as ExitRate
from bank_churn
group by 1
order by 2 desc;

# 8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)

select geographyID, geographyLocation, count(IsActiveMember) as ActiveCustomers
from customerinfo c inner join bank_churn b on c.CustomerId = b.CustomerId
inner join geography g on c.GeographyID = g.GeographyID
	where IsActiveMember = 1 and Tenure > 5
group by 1, 2;

# 9. What is the impact of having a credit card on customer churn, based on the available data?

select HasCrCard,
Round((sum(Exited)/count(*))*100, 2) as ChurnRate
from bank_churn
group by 1
order by 2 desc;

# 10. For customers who have exited, what is the most common number of products they have used?

select NumOfProducts,
count(Exited) as ExitCustomers
from
bank_churn
where Exited = 1
Group by 1
order by 2 desc;

# 11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly).

select year(Bank_DOJ) as 'year',
count(customerID) as CustomerCount,
round(sum(EstimatedSalary), 2) as Salary
from customerinfo
group by 1
order by 2 desc, 3 desc;

# 12. Analyze the relationship between the number of products and the account balance for customers who have exited.

select NumOfProducts, count(Exited) as ExitCustomers,
round(avg(Balance), 2) as AverageBalance
from Bank_churn
	where Exited = 1
group by 1
order by 2 desc;

# 15. Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)

select g.GeographyID,
ge.GenderCategory,
avg(b.Balance) as AverageIncome,
rank() over(partition by g.GeographyID order by avg(b.Balance) desc) as 'Rank'
from customerinfo c
inner join bank_churn b
on b.CustomerId = c.CustomerId
inner join geography g
on c.GeographyID = g.GeographyID
inner join gender ge
on c.GenderID = ge.GenderID
group by 1, 2;

# 16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

select case
when Age between 18 and 30 then 'Young Adults'
when Age between 30 and 50 then 'Adults'
else 'Old'
end as AgeBucket,
round(avg(Tenure), 2) as AvgTenure
from customerinfo c inner join bank_churn b on c.CustomerId = b.CustomerId
where Exited = 1
group by 1;


# 19. Rank each bucket of credit score as per the number of customers who have churned the bank.

select case
when CreditScore >= 800 then 'Excellent'
when CreditScore < 800 and CreditScore >= 740 then 'Very Good'
when CreditScore < 740 and CreditScore >= 670 then 'Good'
when CreditScore < 670 and CreditScore >= 580 then 'Fair'
else 'Poor'
end as CreditScoreSegment,
count(CustomerID) as TotalCustomers,
row_number() over( order by count(CustomerID) desc) as 'RowNumber'
from bank_churn
	where exited = 1
group by 1;

# 20(1). According to the age buckets find the number of customers who have a credit card.

select case
when Age between 18 and 30 then 'Young Adults'
when Age between 30 and 50 then 'Adults'
else 'Old'
end as AgeBucket,
count(c.CustomerID) as CustomerCount
from bank_churn b inner join customerinfo c on b.CustomerId = c.CustomerId
	where HasCrCard = 1
group by 1;

# 20(2). Also retrieve those buckets that have lesser than average number of credit cards per bucket.

select case
when Age between 18 and 30 then 'Young Adults'
when Age between 30 and 50 then 'Adults'
else 'Old'
end as AgeBucket, (sum(HasCrCard)) as TotalCards
from customerinfo c inner join bank_churn b on c.CustomerId = b.CustomerId
group by 1
having (sum(HasCrCard)) < (select (sum(HasCrCard))/3 from bank_churn);

# 21.  Rank the Locations as per the number of people who have churned the bank and average balance of the customers.

select GeographyID, count(c.CustomerID) as CustomerCount,
row_number() over( order by count(CustomerID) desc) as 'CustomerRANK',
round(avg(Balance), 2) as AverageBalance,
row_number() over( order by avg(Balance) desc) as 'BalanceRANK'
from customerinfo c inner join bank_churn b on c.CustomerId = b.CustomerId
	where Exited = 1
group by 1;

# 22. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.

select concat(CustomerID,'_', Surname) as CustomerID_Surname from customerinfo;

# 23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

SELECT *,
    (SELECT ExitCategory FROM exitcustomer ec WHERE ec.ExitID = Bank_Churn.Exited) AS ExitCategory
FROM Bank_Churn;

# 25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

select c.CustomerId,
Surname,
IsActiveMember
from customerinfo c
inner join bank_churn b
on c.CustomerId = b.CustomerId
	where Surname like '%on';
    
    
# SUBJECTIVE QUESTIONS
    
# 9. Utilize SQL queries to segment customers based on demographics and account details.

select Tenure,
NumOfProducts,
case
when CreditScore >= 800 then 'Excellent'
when CreditScore < 800 and CreditScore >= 740 then 'Very Good'
when CreditScore < 740 and CreditScore >= 670 then 'Good'
when CreditScore < 670 and CreditScore >= 580 then 'Fair'
else 'Poor'
end as CreditScoreSegment,
count(customerID) as CustomerCount,
round(avg(Balance), 2) as AverageBalance
from bank_churn
group by 1, 2, 3
order by 1;


select * from bank_churn