import pandas as pd
import matplotlib.pyplot as plt
from math import ceil
import psycopg2

try:
    with psycopg2.connect(
        database="churn",
        user="postgres",
        password="alejandro",
        host="localhost",
        port="5432" # Default PostgreSQL port
    ) as conn:


        with conn.cursor() as cursor:

            cursor.execute("""SET
            SEARCH_PATH TO SOCIALNET7,
            PUBLIC;

        SHOW SEARCH_PATH;

        --time series statistics
        WITH
            DATE_RANGE AS (
                SELECT
                    I::TIMESTAMP AS CALC_DATE
                FROM
                    GENERATE_SERIES('2020-02-09', '2020-03-15', '7 day'::INTERVAL) I
            ),
            THE_METRIC AS (
                SELECT
                    *
                FROM
                    METRIC AS M
                    INNER JOIN METRIC_NAME AS N ON M.METRIC_NAME_ID = N.METRIC_NAME_ID
                WHERE
                    N.METRIC_NAME = 'like_per_month'
            )
        SELECT
            CALC_DATE,
            AVG(METRIC_VALUE),
            COUNT(THE_METRIC.*) AS N_CALC,
            MIN(METRIC_VALUE),
            MAX(METRIC_VALUE)
        FROM
            DATE_RANGE
            LEFT OUTER JOIN THE_METRIC ON CALC_DATE = METRIC_TIME
        GROUP BY
            CALC_DATE
        """)
            
            rows = cursor.fetchall()

            print(rows)

            conn.commit()


except psycopg2.DatabaseError as e:
    print(f"Error connecting to the database: {e}")
    exit()