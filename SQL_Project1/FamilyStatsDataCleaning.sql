--Make a Copy of Mariage Rate Table for Data Cleaning
/*CREATE TABLE marriage_rate LIKE [dbo].['marriage-rate-per-1000-inhabita$']
INSERT INTO marriage_rate 
	SELECT Distinct Entity, Code, [Year], [Crude marriage rate (per 1,000 inhabitants)] 
	FROM [dbo].['marriage-rate-per-1000-inhabita$']
*/

SELECT DISTINCT Entity, Code, [Year], [Crude marriage rate (per 1,000 inhabitants)] 
	INTO marriage_rate
	FROM [dbo].['marriage-rate-per-1000-inhabita$']

SELECT DISTINCT Entity, Code, [Year], [Crude divorce rate (per 1,000 inhabitants)] 
	INTO divorce_rate
	FROM [dbo].['divorces-per-1000-people$']

DROP TABLE [dbo].['marriage-rate-per-1000-inhabita$']
DROP TABLE [dbo].['divorces-per-1000-people$']