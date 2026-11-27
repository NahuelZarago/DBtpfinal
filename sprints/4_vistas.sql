CREATE OR REPLACE VIEW v_variants_por_anio AS
SELECT c.id_comic,
       c.nombre                              AS comic,
       e.nombre                              AS empresa,
       EXTRACT(YEAR FROM cv.fecha_creacion)  AS anio,
       COUNT(*)                              AS cantidad_variants
FROM cover cv
JOIN issue   i ON i.id_issue   = cv.id_issue
JOIN run     r ON r.id_run     = i.id_run
JOIN comic   c ON c.id_comic   = r.id_comic
JOIN empresa e ON e.id_empresa = c.id_empresa
WHERE cv.es_variant = TRUE
GROUP BY c.id_comic, c.nombre, e.nombre, EXTRACT(YEAR FROM cv.fecha_creacion);

CREATE OR REPLACE VIEW v_detalle_runs AS
SELECT r.id_run,
       c.nombre            AS comic,
       e.nombre            AS empresa,
       r.fecha_inicio,
       r.popularidad,
       r.ejemplares_vendidos,
       COUNT(i.id_issue)   AS cantidad_issues
FROM run r
JOIN comic   c ON c.id_comic   = r.id_comic
JOIN empresa e ON e.id_empresa = c.id_empresa
LEFT JOIN issue i ON i.id_run  = r.id_run
GROUP BY r.id_run, c.nombre, e.nombre, r.fecha_inicio, r.popularidad, r.ejemplares_vendidos;

CREATE OR REPLACE VIEW v_participacion_artistas AS
SELECT ia.id_artista,
       c.id_comic,
       c.nombre       AS comic,
       'paginas'      AS tipo,
       r.fecha_inicio AS fecha
FROM issue_artista ia
JOIN issue i ON i.id_issue = ia.id_issue
JOIN run   r ON r.id_run   = i.id_run
JOIN comic c ON c.id_comic = r.id_comic

UNION ALL

SELECT cv.id_artista,
       c.id_comic,
       c.nombre,
       CASE WHEN cv.es_variant THEN 'variant cover' ELSE 'cover principal' END,
       cv.fecha_creacion
FROM cover cv
JOIN issue i ON i.id_issue = cv.id_issue
JOIN run   r ON r.id_run   = i.id_run
JOIN comic c ON c.id_comic = r.id_comic;

CREATE OR REPLACE VIEW v_puntuacion_personas AS
SELECT p.id_persona,
       p.nombre || ' ' || p.apellido  AS persona,
       'Escritor'                     AS rol,
       COUNT(*)                       AS cantidad_comics,
       ROUND(AVG(c.popularidad), 2)   AS puntuacion
FROM (SELECT DISTINCT er.id_escritor AS id_persona, r.id_comic
        FROM escritor_run er
        JOIN run r ON r.id_run = er.id_run) trabajos
JOIN persona p ON p.id_persona = trabajos.id_persona
JOIN comic   c ON c.id_comic   = trabajos.id_comic
GROUP BY p.id_persona, p.nombre, p.apellido

UNION ALL

SELECT p.id_persona,
       p.nombre || ' ' || p.apellido,
       'Artista',
       COUNT(*),
       ROUND(AVG(c.popularidad), 2)
FROM (SELECT DISTINCT ia.id_artista AS id_persona, r.id_comic
        FROM issue_artista ia
        JOIN issue i ON i.id_issue = ia.id_issue
        JOIN run   r ON r.id_run   = i.id_run) trabajos
JOIN persona p ON p.id_persona = trabajos.id_persona
JOIN comic   c ON c.id_comic   = trabajos.id_comic
GROUP BY p.id_persona, p.nombre, p.apellido;