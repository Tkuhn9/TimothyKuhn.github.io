--Make a Copy of the Marriage Rate Table with no duplicates
SELECT DISTINCT Entity, Code, [Year], [Crude marriage rate (per 1,000 inhabitants)] 
	INTO marriage_rate
	FROM [dbo].['marriage-rate-per-1000-inhabita$']
	
--Make a Copy of the Divorce Rate Table with no duplicates
SELECT DISTINCT Entity, Code, [Year], [Crude divorce rate (per 1,000 inhabitants)] 
	INTO divorce_rate
	FROM [dbo].['divorces-per-1000-people$']

--Remove the old tables with duplicates
DROP TABLE [dbo].['marriage-rate-per-1000-inhabita$']
DROP TABLE [dbo].['divorces-per-1000-people$']
