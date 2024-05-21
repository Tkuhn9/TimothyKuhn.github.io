--PURPOSE: To remove the duplicate data found in both the Marriage Rate and Divorce Rate tables

--Step 1: Make a Copy of the Marriage Rate Table with no duplicates
SELECT DISTINCT Entity, Code, [Year], [Crude marriage rate (per 1,000 inhabitants)] 
	INTO marriage_rate
	FROM [dbo].['marriage-rate-per-1000-inhabita$']
	
--Step 2: Make a Copy of the Divorce Rate Table with no duplicates
SELECT DISTINCT Entity, Code, [Year], [Crude divorce rate (per 1,000 inhabitants)] 
	INTO divorce_rate
	FROM [dbo].['divorces-per-1000-people$']

--Step 3: Remove the old tables with duplicates
DROP TABLE [dbo].['marriage-rate-per-1000-inhabita$']
DROP TABLE [dbo].['divorces-per-1000-people$']
