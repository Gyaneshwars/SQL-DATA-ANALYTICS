--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates

IF OBJECT_ID('tempdb..#ed') IS NOT NULL DROP TABLE #ed
SELECT DISTINCT ed.versionid,ed.feedFileId,ed.companyid,edn.dataItemId,peo=dbo.formatPeriodId_fn(ed.estimateperiodid),ed.tradingItemId,
dataitemname=dbo.DataItemName_fn(edn.dataitemid),edn.dataitemvalue,dm.flagEAG,dm.dataCollectionTypeID 
INTO #ed FROM Estimates.[dbo].EstimateDetail_tbl ed (NOLOCK)
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN Estimates.[dbo].DATAITEMMASTER_VW dm (NOLOCK) ON edn.dataItemId=dm.dataItemId
WHERE ed.companyId IN (531302,131325,410666)
AND ed.tradingItemId IN (20217083,20243624,20174307)
AND dm.flavorTypeId IN (2) AND dm.dataCollectionTypeID IN (54,56,62)

SELECT CompanyId,TradingItemId,COUNT(DISTINCT(ISNULL(versionid,feedFileId))) AS CountOfVersions,
COUNT(dataItemId) AS CountOfPer_share_Dataitems FROM #ed
GROUP BY companyId,tradingItemId

SELECT * FROM #ed
