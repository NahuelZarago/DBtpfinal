DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'administrador') THEN
        CREATE USER administrador WITH PASSWORD 'Admin.2026';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'operador') THEN
        CREATE USER operador WITH PASSWORD 'Operador.2026';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'analista') THEN
        CREATE USER analista WITH PASSWORD 'Analista.2026';
    END IF;
END $$;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

GRANT USAGE ON SCHEMA public TO administrador, operador, analista;

GRANT CREATE ON SCHEMA public TO administrador;
GRANT ALL ON ALL TABLES    IN SCHEMA public TO administrador;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO administrador;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO administrador;

GRANT SELECT, INSERT, DELETE ON ALL TABLES    IN SCHEMA public TO operador;
GRANT USAGE                  ON ALL SEQUENCES IN SCHEMA public TO operador;
GRANT EXECUTE                ON ALL FUNCTIONS IN SCHEMA public TO operador;

GRANT UPDATE ON persona, empresa, issue, cover TO operador;
GRANT UPDATE (nombre, descripcion, fecha_inicio, id_empresa, id_escritor) ON comic TO operador;
GRANT UPDATE (fecha_inicio, id_comic) ON run TO operador;

GRANT SELECT ON v_variants_por_anio, v_detalle_runs,
                v_participacion_artistas, v_puntuacion_personas TO analista;

GRANT EXECUTE ON FUNCTION fn_consulta_a(INTEGER),
                          fn_consulta_b(VARCHAR, DECIMAL),
                          fn_consulta_c(INTEGER),
                          fn_consulta_e(),
                          fn_consulta_f() TO analista;