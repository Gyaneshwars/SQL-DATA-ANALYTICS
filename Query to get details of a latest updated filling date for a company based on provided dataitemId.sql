
--- PYTHON & SQL ETL DEVELOPER-GNANESHWAR SRAVANE
USE Estimates

IF OBJECT_ID('tempdb..#latestdatabycomp') IS NOT NULL DROP TABLE #latestdatabycomp
SELECT DISTINCT ed.companyId, cc.companyName,stt.subTypeId,stt.subTypeValue,ed.effectiveDate,ednd.dataItemId,cm.IndustryID,id.IndustryName,id.SectorId,ss.SectorName 
INTO #latestdatabycomp FROM EstimateDetail_tbl ed 
INNER JOIN ComparisonData.dbo.Company_tbl CC (NOLOCK) ON cc.companyId = ed.companyId
INNER JOIN Comparisondata.dbo.SubType_tbl stt (NOLOCK) ON stt.SubTypeId=cc.PrimarySubTypeId
INNER JOIN CompanyMaster.[dbo].[CompanyInfoMaster] cm (NOLOCK) ON cm.CIQCompanyId=cc.companyId
INNER JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] id (NOLOCK) ON cm.IndustryID=id.IndustryId
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
INNER JOIN CompanyMaster.[dbo].[Sectors] ss (NOLOCK) ON ss.SectorId = id.SectorId
WHERE
ed.versionId IS NOT NULL
AND ednd.dataItemId IN (21642,21649,21634)   
AND ed.companyId IN (135466,108116523)   ----Please provide companyid's here

--SELECT * FROM #latestdatabycomp


IF OBJECT_ID('tempdb..#maxdate') IS NOT NULL DROP TABLE #maxdate 
SELECT DISTINCT companyid,MAX(effectivedate) AS MaxFilingDate INTO #maxdate FROM #latestdatabycomp 
GROUP BY companyid

SELECT DISTINCT a.companyId,a.companyName,a.IndustryID,a.IndustryName,a.SectorId,a.SectorName,a.subTypeId,a.subTypeValue,a.dataItemId,a.effectiveDate FROM #latestdatabycomp a 
INNER JOIN #maxdate b (NOLOCK) ON b.companyId=a.companyId 
WHERE b.MaxFilingDate=a.effectiveDate
