BEGIN;
SELECT id_run, popularidad, ejemplares_vendidos FROM run WHERE id_run = 2;
INSERT INTO issue (numero, titulo, ejemplares_vendidos, popularidad, id_run)
VALUES (4, 'Issue de prueba', 10000, 5.00, 2);
SELECT id_run, popularidad, ejemplares_vendidos FROM run WHERE id_run = 2;
ROLLBACK;

BEGIN;
SELECT 'antes' AS momento, r.popularidad AS run_1, c.popularidad AS comic_1
FROM run r JOIN comic c ON c.id_comic = r.id_comic WHERE r.id_run = 1;
UPDATE issue SET popularidad = 1.00 WHERE id_issue = 1;
SELECT 'despues' AS momento, r.popularidad AS run_1, c.popularidad AS comic_1
FROM run r JOIN comic c ON c.id_comic = r.id_comic WHERE r.id_run = 1;
ROLLBACK;

BEGIN;
DELETE FROM issue WHERE id_run = 30;
SELECT id_run, popularidad, ejemplares_vendidos FROM run WHERE id_run = 30;
ROLLBACK;

SELECT COUNT(*) AS comics_con_diferencias
FROM comic c
WHERE c.popularidad <> (SELECT ROUND(AVG(r.popularidad), 2) FROM run r WHERE r.id_comic = c.id_comic);

BEGIN;
INSERT INTO run (fecha_inicio, id_comic) VALUES ('2020-01-01', 1);
ROLLBACK;

BEGIN;
INSERT INTO run (fecha_inicio, id_comic) VALUES ('1990-01-01', 1);
ROLLBACK;

BEGIN;
INSERT INTO cover (nombre, es_variant, id_issue, id_artista) VALUES ('Variant de prueba', TRUE, 1, 11);
ROLLBACK;

BEGIN;
INSERT INTO cover (nombre, es_variant, id_issue, id_artista) VALUES ('Principal de prueba', FALSE, 1, 11);
ROLLBACK;

BEGIN;
INSERT INTO issue (numero, ejemplares_vendidos, popularidad, id_run) VALUES (9, 100, 6, 1);
ROLLBACK;

BEGIN;
INSERT INTO issue (numero, ejemplares_vendidos, popularidad, id_run) VALUES (1, 100, 3, 1);
ROLLBACK;

BEGIN;
INSERT INTO cover (nombre, fecha_creacion, es_variant, id_issue, id_artista)
VALUES ('Variant futura', CURRENT_DATE + 1, TRUE, 1, 11);
ROLLBACK;

BEGIN;
DELETE FROM empresa WHERE nombre = 'Marvel';
ROLLBACK;

SELECT * FROM fn_consulta_a(2025);

SELECT * FROM fn_consulta_a(2019);

SELECT * FROM fn_consulta_b();

SELECT * FROM fn_consulta_c(20);

SELECT * FROM fn_consulta_c(999);

BEGIN;
SELECT * FROM fn_consulta_d_agregar(9, 4, 'Issue de prueba', 2.00, 30000, 12);
SELECT * FROM fn_consulta_d_borrar((SELECT MAX(id_issue) FROM issue));
ROLLBACK;

SELECT * FROM fn_consulta_e();

SELECT * FROM fn_consulta_f();

SELECT COUNT(*) AS runs_con_diferencias
FROM v_detalle_runs v
WHERE v.cantidad_issues <> (SELECT COUNT(*) FROM issue i WHERE i.id_run = v.id_run);

SELECT (SELECT SUM(cantidad_variants) FROM v_variants_por_anio) AS total_en_vista,
       (SELECT COUNT(*) FROM cover WHERE es_variant = TRUE)     AS total_en_tabla;

SELECT
    (SELECT COUNT(*) FROM run r
      WHERE NOT EXISTS (SELECT 1 FROM escritor_run er WHERE er.id_run = r.id_run))   AS runs_sin_escritor,
    (SELECT COUNT(*) FROM issue i
      WHERE NOT EXISTS (SELECT 1 FROM issue_artista ia WHERE ia.id_issue = i.id_issue)) AS issues_sin_artista,
    (SELECT COUNT(*) FROM issue i
      WHERE NOT EXISTS (SELECT 1 FROM cover c WHERE c.id_issue = i.id_issue AND c.es_variant = FALSE)) AS issues_sin_principal;

BEGIN;
SET ROLE analista;
SELECT * FROM v_detalle_runs LIMIT 3;
ROLLBACK;

BEGIN;
SET ROLE analista;
INSERT INTO issue (numero, ejemplares_vendidos, popularidad, id_run) VALUES (8, 1, 1, 1);
ROLLBACK;

BEGIN;
SET ROLE operador;
INSERT INTO issue (numero, ejemplares_vendidos, popularidad, id_run) VALUES (5, 1000, 3, 3);
ROLLBACK;

BEGIN;
SET ROLE operador;
UPDATE run SET popularidad = 5 WHERE id_run = 3;
ROLLBACK;