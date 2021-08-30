----------DATABASE SIZE------

SELECT
    pg_database.datname as database,
    pg_size_pretty(pg_database_size(pg_database.datname)) AS size
    FROM pg_database
    WHERE datistemplate=false 
    AND pg_database_size(pg_database.datname) > 0;


-----DB connections by count by users-------


SELECT 
	datname as database ,usename as user ,client_addr,state, count(*) as total_connections
FROM pg_stat_activity
WHERE pid<>pg_backend_pid()
GROUP BY usename,client_addr,datname,state;


-- Queries running for greater than * ms

SELECT
 (now() - query_start)  as query_time_taken,
 datname as database ,usename as user,
 query 
FROM pg_stat_activity 
WHERE xact_start IS NOT NULL 
AND (now() - query_start) > interval '300 ms';


-- deadlocks----

SELECT pid, 
       usename, 
       pg_blocking_pids(pid) AS blocked_by, 
       query AS blocked_query
FROM pg_stat_activity
WHERE cardinality(pg_blocking_pids(pid)) > 0;


-- View current replication status (on Primary)

SELECT usename as user, application_name, client_addr, client_port, state, sent_lsn, write_lsn, flush_lsn, replay_lsn
FROM pg_stat_replication;




-- View replication lag (on Secondary)

SELECT CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn()
THEN 0
ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp())
END AS log_delay;



---------Number of active connections-------

SELECT COUNT(*) FROM pg_stat_activity WHERE state='active';

-------Percentage of max connections in use-------

SELECT (SELECT SUM(numbackends) FROM pg_stat_database) / (SELECT setting::float FROM pg_settings WHERE name = 'max_connections');


