USE Estimates

IF OBJECT_ID('TEMPDB..#guid') IS NOT NULL DROP TABLE #guid
select ED.versionId,ED.companyId,ED.parentFlag,ED.accountingStandardId,ed.effectiveDate,ed.researchContributorId,
dbo.formatPeriodId_fn(ed.estimatePeriodId) as apeo,
ednd.dataitemvalue as EBIT,ednd1.dataitemvalue as NIGAAP,ednd11.dataitemvalue as NINormalised,ednd2.dataitemvalue as ETR,
EDND.currencyId,EDND.unitsId,EDND.dataItemId into #guid from EstimateDetail_tbl ED
Inner Join estimatePeriod_tbl FI (Nolock) on FI.estimatePeriodId = ED.estimatePeriodId
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid AND ednd.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd1 (NOLOCK) ON ednd1.estimatedetailid=ed.estimatedetailid AND ednd1.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd11 (NOLOCK) ON ednd11.estimatedetailid=ed.estimatedetailid AND ednd11.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd2 (NOLOCK) ON ednd2.estimatedetailid=ed.estimatedetailid AND ednd2.dataitemvalue<>0
WHERE EDND1.dataItemId =21650 AND EDND11.dataItemId=21649 AND ednd2.dataItemId = 114164 AND ed.effectiveDate>GETDATE()-180 AND ED.versionId > 111
AND EDND.dataItemId IN (21645,21646,21647)

IF OBJECT_ID('TEMPDB..#EBT') IS NOT NULL DROP TABLE #EBT SELECT DISTINCT T.* INTO #EBT FROM #guid T WHERE T.dataItemId IN (21646,21647)

IF OBJECT_ID('TEMPDB..#FINAL') IS NOT NULL DROP TABLE #FINAL SELECT DISTINCT * INTO #FINAL FROM #guid T1 WHERE NOT EXISTS (SELECT * FROM #EBT E WHERE T1.versionid = E.versionid AND
T1.companyid = E.companyid)

SELECT DISTINCT * FROm #FINAL WHERE versionId > 111