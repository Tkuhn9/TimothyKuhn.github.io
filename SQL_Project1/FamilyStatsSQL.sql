--Initial Data Exploration
	--Select entire marriage rate table
Select * FROM [dbo].[marriage_rate]
	--Number of Countries/Entities in Marriage table
Select COUNT(Entity) FROM [dbo].[marriage_rate]
	--Average Marriage Rate
Select AVG([Crude marriage rate (per 1,000 inhabitants)]) FROM [dbo].[marriage_rate]
	--Select entrie Divorce rate table
SELECT * FROM [dbo].[divorce_rate]
	--Number of Countries/Entities in Divorce table
SELECT COUNT(Entity) FROM [dbo].[divorce_rate]
	--Average Divorce Rate[dbo].[divorce_rate]
SELECT AVG([Crude divorce rate (per 1,000 inhabitants)]) FROM [dbo].[divorce_rate]
	--Entire Population Table
SELECT * FROM [dbo].[population$]

	--Search for US stats
SELECT * FROM [dbo].[marriage_rate]
WHERE Entity like '%state%'
SELECT AVG([Crude marriage rate (per 1,000 inhabitants)]) FROM [dbo].[marriage_rate]
WHERE Entity like '%state%'
	--Search for UK stats
SELECT * FROM [dbo].[marriage_rate]
WHERE Entity like '%united kingdom%'

-- Check for world or continent values (Don't want to be double-counting things later on)
SELECT * FROM [dbo].[marriage_rate]
WHERE Entity Like '%World%' OR Entity Like '%Europe%' OR Entity Like '%Asia%' OR Entity Like '%Africa%'
	-- Some redundant values discovered, but their "Code" was always NULL. 
	--Verifying ability to filter out redundant values by "NULL code" by first finding all entities whose code is NULL
SELECT Entity, MAX([Crude marriage rate (per 1,000 inhabitants)]) as 'Max Marriage Rate' 
	FROM [dbo].[marriage_rate]
	WHERE Code is NULL
	GROUP BY Entity
	--Double check the divorce table null codes
SELECT Entity, MAX([Crude divorce rate (per 1,000 inhabitants)]) as 'Max Divorce Rate' 
	FROM [dbo].[divorce_rate]
	WHERE Code is NULL
	GROUP BY Entity

--Find the year with most recent data for each country, then store it in a temp table for future reference
SELECT Entity, MAX([Year]) AS 'MaxYear'
	INTO #temp
	FROM [dbo].[marriage_rate] 
	GROUP BY Entity
	ORDER BY Entity

SELECT * FROM #temp
	ORDER BY Entity
--Use the temp table to find the most recent marriage rates for each entity, sorted by marriage rate
SELECT * FROM [dbo].[marriage_rate] T1
	JOIN #temp
	ON (T1.Entity = #temp.Entity AND T1.[Year] = #temp.MaxYear)
	ORDER BY [Crude marriage rate (per 1,000 inhabitants)] desc

--While finding the most recent marriage rates by country, I found duplicates in my results. 
--I used these 2 queries to verify that the data had been doubled in the original table, which I further verified in the Excel file.
--I then used them to verify that the problem had been fixed after I made a disctinct copy of the table, removing the duplicates.
SELECT * FROM [dbo].[marriage_rate]
	WHERE Entity = 'Antigua and Barbuda' AND [Year] = 1995

SELECT * FROM [dbo].[marriage_rate]
	ORDER BY Entity, [YEAR]
	--Repeat the 2nd test on the cleaned up Divorce Table, and on the original Population table 
SELECT * FROM [dbo].[divorce_rate]
	ORDER BY Entity, [YEAR]

SELECT * FROM [dbo].[population$]
	ORDER BY Entity, [YEAR]

-- Use Population table to turn Marriage Rate into # of Marriages and ditto for Divorces
	-- Make Table with # of Marriages in its own column
WITH MarriagePop_CTE as
(SELECT M.Entity, M.Code, M.[Year], M.[Crude marriage rate (per 1,000 inhabitants)] AS 'Marriage Rate', 
	[Population (historical estimates)] AS 'Population' 
	FROM [dbo].[marriage_rate] as M
	JOIN [dbo].[population$] as P
	ON (M.Entity = P.Entity AND M.[Year] = P.[Year])
)

SELECT *, ROUND(([Marriage Rate]*Population/1000), 0) as 'Marriages'
	FROM MarriagePop_CTE
	ORDER BY  Entity, [YEAR]

	--Repeat with the # of Divorces
WITH DivorcePop_CTE as
(SELECT D.Entity, D.Code, D.[Year], D.[Crude Divorce rate (per 1,000 inhabitants)] AS 'Divorce Rate', 
	[Population (historical estimates)] AS 'Population' 
	FROM [dbo].[Divorce_rate] as D
	JOIN [dbo].[population$] as P
	ON (D.Entity = P.Entity AND D.[Year] = P.[Year])
)
SELECT *, ROUND(([Divorce Rate]*Population/1000),0) as 'Divorces'
	FROM DivorcePop_CTE
	ORDER BY  Entity, [YEAR]

	--Put both marriages/divorces in same table	
SELECT M.Entity, M.Code, M.[Year],
	[Population (historical estimates)] AS 'Population', 
	ROUND(([Crude marriage rate (per 1,000 inhabitants)]*[Population (historical estimates)]/1000), 0) AS 'Marriages',
	ROUND(([Crude divorce rate (per 1,000 inhabitants)]*[Population (historical estimates)]/1000), 0) AS 'Divorces'
	INTO #temp_marriages_divorces
	FROM [dbo].[marriage_rate] as M
	JOIN [dbo].[population$] as P
	ON (M.Entity = P.Entity AND M.[Year] = P.[Year])
	JOIN [dbo].[Divorce_rate] as D
	ON (D.Entity = P.Entity AND D.[Year] = P.[Year])
SELECT * From #temp_marriages_divorces

	--Total # of Marriages, Divorces, and the Ratio of Marriages to Divorces in the Dataset using the temp table made previously 
SELECT SUM(Marriages) AS 'Total Marriages', SUM(Divorces) AS 'Total Divorces', (SUM(Marriages)/SUM(Divorces)) AS 'Marriages Per Divorce'
	FROM #temp_marriages_divorces
	WHERE Code IS NOT NULL
	
	--Total # of Marriages and Divorces listed By Location, Ratio of Marriages to Divorces
SELECT Entity, SUM(Marriages) AS 'Total Marriages', SUM(Divorces) AS 'Total Divorces', 
	CASE WHEN SUM(Divorces) = 0 THEN 9999
		ELSE (SUM(Marriages)/SUM(Divorces))
		END AS 'Marriages Per Divorce'
	FROM #temp_marriages_divorces
	WHERE Code IS NOT NULL
	GROUP BY Entity
	ORDER BY 'Marriages Per Divorce' desc

--Running summation
	--Running tally of the total number of marriages recorded in the data (for each country)
SELECT Entity, [Year], Marriages, 
	SUM(Marriages) OVER (PARTITION BY Entity ORDER BY Entity, [Year]) AS 'Total Marriages' 
	FROM #temp_marriages_divorces

	--Running tally of the total number of divorces recorded in the data (for each country)
SELECT Entity, [Year], Divorces,
	SUM(Divorces) OVER (PARTITION BY Entity ORDER BY Entity, [Year]) AS 'Total Divorces'	
	FROM #temp_marriages_divorces

	--Running tallies of both marriages and divorces in a single table.
SELECT Entity, [Year],
	Marriages, 
	SUM(Marriages) OVER w AS 'Total Marriages',
	Divorces,
	SUM(Divorces) OVER w AS 'Total Divorces'
	FROM #temp_marriages_divorces
	WINDOW w AS (PARTITION BY Entity ORDER BY Entity, [Year])


