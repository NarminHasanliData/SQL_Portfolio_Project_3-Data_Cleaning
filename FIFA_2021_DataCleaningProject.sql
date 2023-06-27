-- FIFA 2021 Data Cleaning
-- source: https://www.kaggle.com/datasets/yagunnersya/fifa-21-messy-raw-dataset-for-cleaning-exploring

------------------------------------------------------------------------------------
--Delete Name Column. Because we have LongName Column

ALTER TABLE FIFA_2021..FIFA_2021
DROP COLUMN Name

------------------------------------------------------------------------------------
--To see if there is any charachter in LongName column other than letters

SELECT LongName
FROM FIFA_2021..FIFA_2021
WHERE LongName NOT LIKE '%[a-zA-Z]%'

------------------------------------------------------------------------------------
--Delete PhotoURL. Because these links are not opening. And also PlayerURL links have photos of players.

ALTER TABLE FIFA_2021..FIFA_2021
DROP COLUMN photoUrl


------------------------------------------------------------------------------------
-- Checking the correctness of Nationality Column
SELECT Nationality
FROM FIFA_2021..FIFA_2021
WHERE Nationality NOT LIKE '%[a-zA-Z]%'

SELECT Nationality
FROM FIFA_2021..FIFA_2021
WHERE Nationality LIKE '% '


------------------------------------------------------------------------------------
--Just was interesting to know the max, min and average ages of players

SELECT MAX(Age) AS MaxAge, 
		MIN(Age) AS MinAge, 
		AVG(Age) AS AvgAge
FROM FIFA_2021..FIFA_2021

SELECT LongName, Age
FROM FIFA_2021..FIFA_2021
WHERE Age = (SELECT MAX(Age)
			FROM FIFA_2021..FIFA_2021) OR
			Age = (SELECT MIN(Age)
					FROM FIFA_2021..FIFA_2021)
ORDER BY Age DESC


------------------------------------------------------------------------------------
-- Difference between OVA and POT

SELECT LongName, OVA, POT, (POT-OVA) AS Difference
FROM FIFA_2021..FIFA_2021
ORDER BY Difference DESC

------------------------------------------------------------------------------------
-- Club Column cleaning

SELECT Club
FROM FIFA_2021..FIFA_2021
WHERE CHARINDEX(CHAR(13), Club) > 0

SELECT REPLACE(REPLACE(Club, CHAR(13), ''), CHAR(10), '') AS Club_Updated
FROM FIFA_2021..FIFA_2021

SELECT *
FROM FIFA_2021..FIFA_2021

UPDATE FIFA_2021..FIFA_2021
SET Club = REPLACE(REPLACE(Club, CHAR(13), ''), CHAR(10), '')

SELECT Club
FROM FIFA_2021..FIFA_2021
WHERE Club NOT LIKE '%[a-zA-Z]%'



------------------------------------------------------------------------------------
-- Dividing Contract into to columns Contract_Start_Year and Contract_End_Year

SELECT Contract
FROM FIFA_2021..FIFA_2021
WHERE Contract NOT LIKE  '%~%' 
	AND Contract NOT LIKE 'Free'

ALTER TABLE FIFA_2021..FIFA_2021
ADD Loan_Start_Date Date

SELECT *
FROM FIFA_2021..FIFA_2021

UPDATE FIFA_2021..FIFA_2021
SET Loan_Start_Date = LEFT(Contract, 12)
		FROM FIFA_2021..FIFA_2021
		WHERE Contract NOT LIKE  '%~%' 
			AND Contract NOT LIKE 'Free'

SELECT Contract, Loan_Date_End, Loan_Start_date
FROM FIFA_2021..FIFA_2021
WHERE Loan_Date_End IS NOT NULL
	AND Loan_Date_End <> Loan_Start_date

ALTER TABLE FIFA_2021..FIFA_2021
DROP COLUMN Loan_Start_date

UPDATE FIFA_2021..FIFA_2021 
SET Contract = 'On Loan' 
WHERE Contract NOT LIKE  '%~%' 
	AND Contract NOT LIKE 'Free'

SELECT Contract,
		LEFT(Contract, CHARINDEX('~', Contract) - 1) AS Contract_Start_Year,
		RIGHT(Contract, CHARINDEX('~', Contract) - 1) AS Contract_End_Year
FROM FIFA_2021..FIFA_2021 
WHERE Contract LIKE  '%~%'

UPDATE FIFA_2021..FIFA_2021 
SET Contract = 'On Loan' 
WHERE Contract NOT LIKE  '%~%' 
	AND Contract NOT LIKE 'Free'

ALTER TABLE FIFA_2021..FIFA_2021
ADD Contract_End_Year Date

UPDATE FIFA_2021..FIFA_2021
SET Contract_End_Year = RIGHT(Contract, CHARINDEX('~', Contract) - 1)
WHERE Contract LIKE  '%~%'

UPDATE FIFA_2021..FIFA_2021
SET Contract = (CASE 
					WHEN Contract LIKE  '%~%' THEN LEFT(Contract, CHARINDEX('~', Contract) - 1)
					ELSE (Contract)
				END)

ALTER TABLE FIFA_2021..FIFA_2021
ADD Contract_End_Year INT

UPDATE FIFA_2021..FIFA_2021
SET Contract_End_Year = YEAR(Contract_End_Year)

SELECT *
FROM FIFA_2021..FIFA_2021

ALTER TABLE FIFA_2021..FIFA_2021
DROP Column Contract_Year


------------------------------------------------------------------------------------
-- Checking the positions

SELECT DISTINCT(Positions)
FROM FIFA_2021..FIFA_2021


------------------------------------------------------------------------------------
--Convert the height column to numerical forms

SELECT Height
FROM FIFA_2021..FIFA_2021
WHERE Height LIKE '%"%'

SELECT LEFT(Height, len(height)-1)
FROM FIFA_2021..FIFA_2021
WHERE Height LIKE '%"%'

UPDATE FIFA_2021..FIFA_2021
SET Height = LEFT(Height, len(height)-1)
WHERE Height LIKE '%"%'

SELECT Height,
		LEFT(Height, 1) AS Feet,
		SUBSTRING(Height, 3, 2)  AS Inch
FROM FIFA_2021..FIFA_2021
WHERE Height NOT LIKE '%cm%'

ALTER TABLE FIFA_2021..FIFA_2021
ADD Feet int

UPDATE FIFA_2021..FIFA_2021
SET Feet = LEFT(Height, 1)
WHERE Height NOT LIKE '%cm%'

ALTER TABLE FIFA_2021..FIFA_2021
ADD Inch int

UPDATE FIFA_2021..FIFA_2021
SET Inch = SUBSTRING(Height, 3, 2)
WHERE Height NOT LIKE '%cm%'

SELECT *
FROM FIFA_2021..FIFA_2021

ALTER TABLE FIFA_2021..FIFA_2021
ADD Height_CM int

UPDATE FIFA_2021..FIFA_2021
SET Height_CM = ROUND(((Feet * 30.48) + (Inch * 2.54)), 0)
WHERE Height NOT LIKE '%cm%'

UPDATE FIFA_2021..FIFA_2021
SET Height_CM = LEFT(Height, 3)
WHERE Height LIKE '%cm%'

ALTER TABLE FIFA_2021..FIFA_2021
	DROP COLUMN Height
ALTER TABLE FIFA_2021..FIFA_2021
	DROP COLUMN Feet
ALTER TABLE FIFA_2021..FIFA_2021
	DROP COLUMN Inch

------------------------------------------------------------------------------------
--Convert the weight column to numerical forms

SELECT DISTINCT(Weight)
FROM FIFA_2021..FIFA_2021

ALTER TABLE FIFA_2021..FIFA_2021
ADD Weight_KG int

UPDATE FIFA_2021..FIFA_2021
SET Weight_KG = REPLACE(Weight, 'kg', '')
WHERE Weight LIKE '%kg%'

SELECT CAST(REPLACE(Weight, 'lbs', '') AS int) * 0.45
FROM FIFA_2021..FIFA_2021
WHERE Weight LIKE '%lbs%'

UPDATE FIFA_2021..FIFA_2021
SET Weight_KG = ROUND((CAST(REPLACE(Weight, 'lbs', '') AS int) * 0.45),0)
WHERE Weight LIKE '%lbs%'

ALTER TABLE FIFA_2021..FIFA_2021
	DROP COLUMN Weight

SELECT *
FROM FIFA_2021..FIFA_2021

------------------------------------------------------------------------------------
--Based on the 'Joined' column, check which players have been playing at a club for more than 10 years!
--Here I have mentioned the year as 2021, because in these 2 years any of football players can quit or retire.

SELECT LongName,
		Joined,
		2021 - YEAR(Joined) AS Num_of_Years
FROM FIFA_2021..FIFA_2021
WHERE 2021 - YEAR(Joined) > = 10
ORDER BY Num_of_Years DESC

------------------------------------------------------------------------------------
--'Value', 'Wage' and "Release Clause' are string columns. Convert them to numbers. For eg, "M" in value 
--column is Million, so multiply the row values by 1,000,000, etc.

SELECT Value,
		Wage,
		Release_Clause
FROM FIFA_2021..FIFA_2021

SELECT DISTINCT(LEFT(Value, 1))
FROM FIFA_2021..FIFA_2021

SELECT DISTINCT(LEFT(Wage, 1))
FROM FIFA_2021..FIFA_2021

SELECT DISTINCT(LEFT(Release_Clause, 1))
FROM FIFA_2021..FIFA_2021

UPDATE FIFA_2021..FIFA_2021
SET Value = REPLACE(Value, '€', ''), 
		Wage = REPLACE(Wage, '€', ''), 
		Release_Clause = REPLACE(Release_Clause, '€', '')

-- Value Column
SELECT DISTINCT(Value)
FROM FIFA_2021..FIFA_2021
WHERE (Value NOT LIKE '%M%' AND
		Value NOT LIKE '%K%')

UPDATE FIFA_2021..FIFA_2021
SET Value = REPLACE(Value, 'M', '')

UPDATE FIFA_2021..FIFA_2021
SET Value = CAST(Value AS decimal) * 1000
	WHERE Value NOT LIKE '%K%'

UPDATE FIFA_2021..FIFA_2021
SET Value = REPLACE(Value, 'K', '')

UPDATE FIFA_2021..FIFA_2021
SET Value = CAST(Value AS decimal) * 1000



-- Wage Column

SELECT DISTINCT(Wage)
FROM FIFA_2021..FIFA_2021
WHERE (Wage LIKE '%M%')-- AND
		Wage NOT LIKE '%K%')

SELECT Wage
FROM FIFA_2021..FIFA_2021
WHERE Wage  LIKE '123'

UPDATE FIFA_2021..FIFA_2021
SET Wage = REPLACE(Wage, 'K', '000')



-- Release Clause Column

SELECT DISTINCT(Release_Clause)
FROM FIFA_2021..FIFA_2021
WHERE (Release_Clause NOT LIKE '%M%' AND
		Release_Clause NOT LIKE '%K%')

SELECT DISTINCT(Release_Clause)
FROM FIFA_2021..FIFA_2021
WHERE Release_Clause LIKE '%K%'

UPDATE FIFA_2021..FIFA_2021
SET Release_Clause = REPLACE(Release_Clause, 'K', '000')

SELECT DISTINCT(Release_Clause)
FROM FIFA_2021..FIFA_2021
WHERE Release_Clause LIKE '%.%'

UPDATE FIFA_2021..FIFA_2021
SET Release_Clause = CASE 
						WHEN Release_Clause LIKE '%.%' AND Release_Clause LIKE '%M%' THEN REPLACE(Release_Clause, 'M', '00000')
						WHEN Release_Clause NOT LIKE '%.%' AND Release_Clause LIKE '%M%' THEN REPLACE(Release_Clause, 'M', '000000')
						ELSE Release_Clause
					END

UPDATE FIFA_2021..FIFA_2021
SET Release_Clause = REPLACE(Release_Clause, '.', '')	

------------------------------------------------------------------------------------
--Which players are highly valuable but still underpaid (on low wages)? 
--(hint: scatter plot between wage and value)


SELECT LongName, 
		Wage_in_Euro, 
		Value_in_Euro,
		Value_in_Euro - Wage_in_Euro  AS Underpayment
FROM FIFA_2021..FIFA_2021 
ORDER BY Underpayment DESC

------------------------------------------------------------------------------------
--Some columns have 'star' characters. Strip those columns of these stars and make the columns numerical


SELECT DISTINCT(W_F)
FROM FIFA_2021..FIFA_2021 

SELECT DISTINCT(SM)
FROM FIFA_2021..FIFA_2021 

SELECT DISTINCT(IR)
FROM FIFA_2021..FIFA_2021 


UPDATE FIFA_2021..FIFA_2021
SET W_F = CAST(SUBSTRING(W_F, 1, 1) AS tinyint)

UPDATE FIFA_2021..FIFA_2021
SET SM = CAST(SUBSTRING(SM, 1, 1) AS tinyint)

UPDATE FIFA_2021..FIFA_2021
SET IR = CAST(SUBSTRING(IR, 1, 1) AS tinyint)

------------------------------------------------------------------------------------
--Checking the columns

SELECT DISTINCT(Hits)
FROM FIFA_2021..FIFA_2021
WHERE Hits NOT LIKE '%.00%'

UPDATE FIFA_2021..FIFA_2021
SET Hits = CAST(Hits AS decimal)

SELECT DISTINCT(A_W)
FROM FIFA_2021..FIFA_2021

SELECT DISTINCT(D_W)
FROM FIFA_2021..FIFA_2021
