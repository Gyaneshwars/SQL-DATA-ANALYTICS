--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates

IF OBJECT_ID('TEMPDB..#VersionDtls') IS NOT NULL DROP TABLE #VersionDtls
SELECT DISTINCT ED.versionId,ED.companyId,DataItemName=Estimates.[dbo].DataItemName_fn(EDN.dataitemid),PEO=Estimates.dbo.formatPeriodId_fn(ED.estimatePeriodId),
EDN.dataItemValue,Contributor=Estimates.[dbo].researchcontributorname_fn(ED.researchcontributorid),FORMAT(CAST(ED.effectiveDate AS DATETIME), 'yyyy-MM-dd hh:mm:ss tt') AS FilingDate,
EDN.currencyId,CR.currencyName,EDN.unitsId,U.unitsType,ED.tradingItemId,ED.researchContributorId,EDN.dataitemid INTO #VersionDtls 
FROM		Estimates.[dbo].EstimateDetail_tbl ED (NOLOCK)
INNER JOIN	Estimates.[dbo].[EstFull_vw] EDN (NOLOCK) ON ED.estimateDetailId=EDN.estimateDetailId
LEFT JOIN	Estimates.[dbo].EstimatePeriod_tbl EP (NOLOCK) ON ED.estimatePeriodId=EP.estimatePeriodId
LEFT JOIN	Estimates.[dbo].[Units_tbl] U (NOLOCK) ON U.unitsId=EDN.unitsId
LEFT JOIN	ComparisonData.[dbo].[Currency_tbl] CR (NOLOCK) ON CR.currencyId=EDN.currencyId
WHERE
ED.researchContributorId IN (3)
AND EDN.dataitemid IN (21634,21635,21649,21650,21646,21647,21642,21643,21645,21661,21640,21659)
AND ED.versionId IN (-1931695832,-1946302140)
;



DECLARE @columns NVARCHAR(MAX) = '', @sql NVARCHAR(MAX) = '';

SELECT @columns += QUOTENAME(DataItemName + ' ' + PEO) + ','
FROM (SELECT DISTINCT DataItemName, PEO FROM #VersionDtls) AS Items
ORDER BY DataItemName, PEO;


SET @columns = LEFT(@columns, LEN(@columns) - 1);

SET @sql = 'SELECT versionId, companyId,Contributor,FilingDate, ' + @columns + '
            FROM
            (
                SELECT versionId,companyId,Contributor,FilingDate, DataItemName + '' '' + PEO AS ItemPEO, dataItemValue
                FROM #VersionDtls
            ) AS SourceTable
            PIVOT
            (
                MAX(dataItemValue)
                FOR ItemPEO IN (' + @columns + ')
            ) AS PivotTable;';

EXEC sp_executesql @sql;


---SELECT * FROM #VersionDtls ORDER BY versionId,companyId,dataitemid;