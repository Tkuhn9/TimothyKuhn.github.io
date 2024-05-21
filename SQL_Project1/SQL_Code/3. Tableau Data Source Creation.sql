--PURPOSE: To use SQL Queries to generate useful data sources for my Tableau project.

--Average Marriage Rate
Select AVG([Crude marriage rate (per 1,000 inhabitants)]) FROM [dbo].[marriage_rate]
--Average Divorce Rate[dbo].[divorce_rate]
SELECT AVG([Crude divorce rate (per 1,000 inhabitants)]) FROM [dbo].[divorce_rate]

--Find the year with most recent data for each country, then store it in a temp table for future reference
SELECT Entity, MAX([Year]) AS 'MaxYear'
	INTO #temp
	FROM [dbo].[marriage_rate] 
	GROUP BY Entity
	ORDER BY Entity

--Use the temp table to find the most recent marriage rates for each entity, sorted by marriage rate
SELECT * FROM [dbo].[marriage_rate] T1
	JOIN #temp
	ON (T1.Entity = #temp.Entity AND T1.[Year] = #temp.MaxYear)
	ORDER BY [Crude marriage rate (per 1,000 inhabitants)] desc

-- Use Population table to turn Marriage Rate into # of Marriages and ditto for Divorces
	-- USE CTE to make a table with # of Marriages in its own column
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



