SET
	SEARCH_PATH TO SOCIALNET7,
	PUBLIC;

WITH
	DATE_RANGE AS (
		SELECT
			'2020-02-02'::TIMESTAMP AS START_DATE,
			'2020-05-10'::TIMESTAMP AS END_DATE
	),
	ACCOUNT_COUNT AS (
		--cuenta subscripciones validas en el mes
		SELECT
			COUNT(DISTINCT S.ACCOUNT_ID) AS N_ACCOUNT
		FROM
			--mientras no haya terminado, significa que esta activa 
			--pero hay cuentas que estan dobles
			--cuentas unicas con que este activa una vez, puede no seguir activa despues
			SUBSCRIPTION S
			INNER JOIN DATE_RANGE D ON S.START_DATE <= D.END_DATE
			AND (
				S.END_DATE >= D.START_DATE
				OR S.END_DATE IS NULL
			)
	)
SELECT
	--el avg metric value para ese rango de tiempo
	METRIC_NAME,
	COUNT(DISTINCT M.ACCOUNT_ID) AS COUNT_WITH_METRIC,
	N_ACCOUNT,
	(COUNT(DISTINCT M.ACCOUNT_ID))::FLOAT / N_ACCOUNT::FLOAT AS PCNT_WITH_METRIC,
	--este es de todos no de los distintos  
	--las metricas que estan en el rango de tiempo
	AVG(METRIC_VALUE) AS AVG_VALUE,
	MIN(METRIC_VALUE) AS MIN_VALUE,
	MAX(METRIC_VALUE),
	MIN(METRIC_TIME),
	MAX(METRIC_TIME)
	--select *
FROM
	--esta evento paso en esta subscripcion
	METRIC M
	CROSS JOIN ACCOUNT_COUNT
	INNER JOIN DATE_RANGE ON METRIC_TIME >= START_DATE
	AND METRIC_TIME <= END_DATE
	INNER JOIN METRIC_NAME N ON M.METRIC_NAME_ID = N.METRIC_NAME_ID
	INNER JOIN SUBSCRIPTION S ON S.ACCOUNT_ID = M.ACCOUNT_ID
	AND S.START_DATE <= M.METRIC_TIME
	AND (
		S.END_DATE >= M.METRIC_TIME
		OR S.END_DATE IS NULL
	)
GROUP BY
	METRIC_NAME,
	N_ACCOUNT