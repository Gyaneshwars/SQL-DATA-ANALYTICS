
--- PYTHON & SQL ETL DEVELOPER-GNANESHWAR SRAVANE

IF OBJECT_ID('tempdb..#Versiondata') IS NOT NULL DROP TABLE #Versiondata
SELECT CT.collectionEntityId, CT.relatedCompanyId, p.priorityname, CT.enddate, 
usr.employeenumber, usr.firstname+' '+usr.lastname AS EmpName, cs.collectionStageName INTO #Versiondata FROM WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK)
INNER JOIN WorkflowArchive_Estimates.dbo.priority_tbl p (NOLOCK) on CT.priorityid = p.priorityid
LEFT JOIN CTAdminRepTables.dbo.user_tbl usr (NOLOCK)on CT.userId = usr.userid
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionStage_tbl cs (NOLOCK) on CT.collectionStageId = cs.collectionStageId
WHERE CT.collectionEntityId IN (-2095827280,-2094674134
,-2089014536,109130811,1968198728,-2090669190,-2089014536,-2087382722,1931731118,1958292542,-2087082766,-2138078582,-2086379392,-2087752042,-2087356740,-2086298648,-2087769762,-2087051094,-2083477240,-2083705266,-2083705266,-2083522624,-2083163672,-2086283442,-2082019696,-2144582120,-2144582120,-2144582120,-2144582120,-2083524558,-2081654360,-2133005648,-2138049794,-2138049794,-2080494422,-2082234150,-2081145158,-2083499324,-2086846776,-2081630160,-2083666682)
AND CT.collectionProcessId IN (64)
AND CS.collectionStageId IN (1,2,24)
AND CT.collectionStageStatusId IN (4,5)
AND usr.employeenumber IS NOT NULL
AND usr.userid <> 907321171
ORDER BY CT.collectionentityid , CT.enddate

IF OBJECT_ID('tempdb..#Final') IS NOT NULL DROP TABLE #Final
SELECT collectionEntityId,relatedCompanyId,enddate,priorityname,employeenumber,EmpName,collectionStageName,
(ROW_NUMBER() OVER(PARTITION BY collectionEntityId,relatedCompanyId ORDER BY collectionEntityId,relatedCompanyId,enddate)) AS RN 
INTO #Final FROM #Versiondata

SELECT DISTINCT collectionEntityId,relatedCompanyId,enddate,priorityname,employeenumber,EmpName,collectionStageName FROM #Final WHERE RN IN (1)


