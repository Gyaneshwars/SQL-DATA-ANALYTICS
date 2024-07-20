--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates
IF OBJECT_ID('tempdb..#Est') IS NOT NULL DROP TABLE #Est
SELECT DISTINCT CONTRIBUTORNAME=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.companyid,ed.versionid,ed.feedfileid,ednd.dataitemid,
dataitemname=dbo.dataitemname_fn(ednd.dataitemid),peo=dbo.formatperiodid_fn(ed.estimateperiodid),ednd.dataitemvalue,
ednd.currencyid,ednd.unitsid,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectivedate INTO #Est from estimatedetail_tbl ed (NOLOCK)
INNER JOIN Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
WHERE ednd.dataItemId in (603231,603244) ----Please enter the dataitem id's here
AND ed.effectivedate>='2022-01-01'

--SELECT * FROM #Est


IF OBJECT_ID('TEMPDB..#FINAL') IS NOT NULL DROP TABLE #FINAL
SELECT DISTINCT TE.VERSIONID,TE.COMPANYID,TE.contributorname,TE.PARENTFLAG,TE.PEO,TE.dataitemname AS dataitemname1,TN.dataitemname AS dataitemname2,TE.DATAITEMVALUE AS DATAITEMVALUE1,TN.DATAITEMVALUE AS DATAITEMVALUE2,(ROW_NUMBER() OVER(PARTITION BY TE.versionid,TE.companyId,TE.PEO,TE.DATAITEMVALUE ORDER BY TE.versionid,TE.companyId,TE.PEO,TE.DATAITEMVALUE)) AS Rownumber INTO #FINAL FROM #Est TE (NOLOCK)
INNER JOIN #Est TN (NOLOCK) ON TN.contributorname = TE.contributorname AND TN.VERSIONID = TE.VERSIONID AND TN.COMPANYID = TE.COMPANYID AND TN.PARENTFLAG = TE.PARENTFLAG AND TN.ACCOUNTINGSTANDARDID = TE.ACCOUNTINGSTANDARDID
WHERE TE.dataitemid!=TN.dataItemId
AND TE.DATAITEMVALUE = TN.DATAITEMVALUE
AND TN.PEO = TE.PEO 
AND TN.CURRENCYID = TE.CURRENCYID 
AND TN.UNITSID = TE.UNITSID


IF OBJECT_ID('TEMPDB..#FINAL1') IS NOT NULL DROP TABLE #FINAL1
SELECT VERSIONID,COMPANYID,CONTRIBUTORNAME,PARENTFLAG,PEO,DATAITEMNAME1,DATAITEMNAME2,DATAITEMVALUE1,DATAITEMVALUE2 INTO #FINAL1 FROM #FINAL WHERE Rownumber=1

IF OBJECT_ID('tempdb..#Finale') IS NOT NULL DROP TABLE #Finale
SELECT DISTINCT F.*,c.companyName,c.PrimarySubTypeId AS SubTypeId,s.subTypeValue AS SubtypeName,s.subparentId,cm.Country,id.IndustryName 
INTO #Finale FROM ComparisonData.[dbo].[Company_tbl] c
INNER JOIN #FINAL1 F (NOLOCK) ON F.COMPANYID=c.companyId
INNER JOIN ComparisonData.[dbo].[SubType_tbl] s (NOLOCK) ON s.subTypeId=c.PrimarySubTypeId
INNER JOIN CompanyMaster.[dbo].[CompanyInfoMaster] cm (NOLOCK) ON cm.CIQCompanyId=c.companyId
INNER JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] id (NOLOCK) ON cm.IndustryID=id.IndustryId


SELECT * FROM #Finale

--SELECT * FROM #FINAL1