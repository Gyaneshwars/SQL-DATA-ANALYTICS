--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNYANESHWAR SRAVANE

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2024-01-01 00:00:00.000'
SET @todate='2024-02-29 23:59:59.999'

IF OBJECT_ID('TEMPDB..#IRVersions') IS NOT NULL DROP TABLE #IRVersions
SELECT DISTINCT rd.versionId,rd.lastUpdatedDateUTC,rd.languageId,rd.researchContributorId,rc.contributorShortName,rd.pageCount,rd.primaryCompanyId,l.languageName 
INTO #IRVersions FROM ComparisonData.[dbo].[ResearchDocument_tbl] rd
INNER JOIN ComparisonData.[dbo].[ResearchContributor_tbl] rc (NOLOCK) ON rc.researchContributorId=rd.researchContributorId
INNER JOIN ComparisonData.[dbo].[Language_tbl] l (NOLOCK) ON l.languageId=rd.languageId
WHERE rd.lastUpdatedDateUTC>=@frdate AND rd.lastUpdatedDateUTC<=@todate
AND rc.researchContributorStatusTypeId IN (2)
ORDER BY rd.lastUpdatedDateUTC