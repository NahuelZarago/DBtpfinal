CREATE OR REPLACE FUNCTION fn_consulta_a(p_anio INTEGER)
RETURNS TABLE (comic VARCHAR, empresa VARCHAR, cantidad_variants BIGINT) AS $$
    SELECT comic, empresa, cantidad_variants
    FROM v_variants_por_anio
    WHERE anio = p_anio
    ORDER BY cantidad_variants DESC, comic;
$$ LANGUAGE sql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION fn_consulta_b(p_empresa VARCHAR DEFAULT 'Marvel',
                                         p_minimo  DECIMAL DEFAULT 4)
RETURNS TABLE (id_run INTEGER, comic VARCHAR, fecha_inicio DATE,
               popularidad DECIMAL, ejemplares_vendidos INTEGER, cantidad_issues BIGINT) AS $$
    SELECT id_run, comic, fecha_inicio, popularidad, ejemplares_vendidos, cantidad_issues
    FROM v_detalle_runs
    WHERE empresa = p_empresa
      AND popularidad > p_minimo
    ORDER BY popularidad DESC;
$$ LANGUAGE sql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION fn_consulta_c(p_id_artista INTEGER)
RETURNS TABLE (comic VARCHAR, cantidad_variants BIGINT) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM artista WHERE id_artista = p_id_artista) THEN
        RAISE EXCEPTION 'No existe el artista %', p_id_artista;
    END IF;

    RETURN QUERY
    SELECT v.comic, COUNT(*)
    FROM v_participacion_artistas v
    WHERE v.id_artista = p_id_artista
    GROUP BY v.comic
    HAVING COUNT(*) = SUM(CASE WHEN v.tipo = 'variant cover' THEN 1 ELSE 0 END);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION fn_consulta_d_agregar(p_id_run      INTEGER,
                                                 p_numero      INTEGER,
                                                 p_titulo      VARCHAR,
                                                 p_popularidad DECIMAL,
                                                 p_ejemplares  INTEGER,
                                                 p_id_artista  INTEGER)
RETURNS TABLE (registro TEXT, puntuacion_antes DECIMAL, puntuacion_despues DECIMAL,
               ventas_antes INTEGER, ventas_despues INTEGER) AS $$
DECLARE
    v_comic       INTEGER;
    v_run_pts     DECIMAL;
    v_run_ventas  INTEGER;
    v_com_pts     DECIMAL;
    v_com_ventas  INTEGER;
    v_nuevo_issue INTEGER;
BEGIN
    SELECT id_comic, popularidad, ejemplares_vendidos
      INTO v_comic, v_run_pts, v_run_ventas
      FROM run WHERE id_run = p_id_run;

    SELECT popularidad, ejemplares_vendidos
      INTO v_com_pts, v_com_ventas
      FROM comic WHERE id_comic = v_comic;

    INSERT INTO issue (numero, titulo, ejemplares_vendidos, popularidad, id_run)
    VALUES (p_numero, p_titulo, p_ejemplares, p_popularidad, p_id_run)
    RETURNING id_issue INTO v_nuevo_issue;

    INSERT INTO issue_artista (id_issue, id_artista) VALUES (v_nuevo_issue, p_id_artista);

    INSERT INTO cover (nombre, es_variant, id_issue, id_artista)
    VALUES ('Cover issue ' || p_numero, FALSE, v_nuevo_issue, p_id_artista);

    RETURN QUERY
    SELECT 'Run ' || id_run, v_run_pts, run.popularidad::DECIMAL,
           v_run_ventas, run.ejemplares_vendidos::INTEGER
    FROM run WHERE id_run = p_id_run;

    RETURN QUERY
    SELECT 'Cómic ' || id_comic, v_com_pts, comic.popularidad::DECIMAL,
           v_com_ventas, comic.ejemplares_vendidos::INTEGER
    FROM comic WHERE id_comic = v_comic;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_consulta_d_borrar(p_id_issue INTEGER)
RETURNS TABLE (registro TEXT, puntuacion_antes DECIMAL, puntuacion_despues DECIMAL,
               ventas_antes INTEGER, ventas_despues INTEGER) AS $$
DECLARE
    v_run        INTEGER;
    v_comic      INTEGER;
    v_run_pts    DECIMAL;
    v_run_ventas INTEGER;
    v_com_pts    DECIMAL;
    v_com_ventas INTEGER;
BEGIN
    SELECT id_run INTO v_run FROM issue WHERE id_issue = p_id_issue;
    IF v_run IS NULL THEN
        RAISE EXCEPTION 'No existe el issue %', p_id_issue;
    END IF;

    SELECT id_comic, popularidad, ejemplares_vendidos
      INTO v_comic, v_run_pts, v_run_ventas
      FROM run WHERE id_run = v_run;

    SELECT popularidad, ejemplares_vendidos
      INTO v_com_pts, v_com_ventas
      FROM comic WHERE id_comic = v_comic;

    DELETE FROM issue WHERE id_issue = p_id_issue;

    RETURN QUERY
    SELECT 'Run ' || id_run, v_run_pts, run.popularidad::DECIMAL,
           v_run_ventas, run.ejemplares_vendidos::INTEGER
    FROM run WHERE id_run = v_run;

    RETURN QUERY
    SELECT 'Cómic ' || id_comic, v_com_pts, comic.popularidad::DECIMAL,
           v_com_ventas, comic.ejemplares_vendidos::INTEGER
    FROM comic WHERE id_comic = v_comic;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_consulta_e()
RETURNS TABLE (persona TEXT, rol TEXT, cantidad_comics BIGINT, puntuacion DECIMAL) AS $$
    SELECT persona, rol, cantidad_comics, puntuacion
    FROM v_puntuacion_personas
    ORDER BY puntuacion DESC, cantidad_comics DESC
    LIMIT 10;
$$ LANGUAGE sql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION fn_consulta_f()
RETURNS TABLE (id_artista INTEGER, artista TEXT, fecha_inicio DATE) AS $$
    SELECT a.id_artista,
           p.nombre || ' ' || p.apellido,
           p.fecha_inicio
    FROM artista a
    JOIN persona p ON p.id_persona = a.id_artista
    WHERE p.fecha_inicio <= CURRENT_DATE - INTERVAL '10 years'
      AND a.id_artista NOT IN (
            SELECT v.id_artista
            FROM v_participacion_artistas v
            WHERE v.tipo  = 'variant cover'
              AND v.fecha > CURRENT_DATE - INTERVAL '6 months')
    ORDER BY p.fecha_inicio;
$$ LANGUAGE sql SECURITY DEFINER;