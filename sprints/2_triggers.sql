CREATE OR REPLACE FUNCTION fn_actualizar_run()
RETURNS TRIGGER AS $$
DECLARE
    run_afectada INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        run_afectada := OLD.id_run;
    ELSE
        run_afectada := NEW.id_run;
    END IF;

    UPDATE run
       SET popularidad         = COALESCE((SELECT ROUND(AVG(popularidad), 2) FROM issue WHERE id_run = run_afectada), 0),
           ejemplares_vendidos = COALESCE((SELECT SUM(ejemplares_vendidos)   FROM issue WHERE id_run = run_afectada), 0)
     WHERE id_run = run_afectada;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_issue_actualiza_run ON issue;
CREATE TRIGGER tr_issue_actualiza_run
AFTER INSERT OR UPDATE OR DELETE ON issue
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_run();

CREATE OR REPLACE FUNCTION fn_actualizar_comic()
RETURNS TRIGGER AS $$
DECLARE
    comic_afectado INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        comic_afectado := OLD.id_comic;
    ELSE
        comic_afectado := NEW.id_comic;
    END IF;

    UPDATE comic
       SET popularidad         = COALESCE((SELECT ROUND(AVG(popularidad), 2) FROM run WHERE id_comic = comic_afectado), 0),
           ejemplares_vendidos = COALESCE((SELECT SUM(ejemplares_vendidos)   FROM run WHERE id_comic = comic_afectado), 0)
     WHERE id_comic = comic_afectado;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_run_actualiza_comic ON run;
CREATE TRIGGER tr_run_actualiza_comic
AFTER INSERT OR UPDATE OR DELETE ON run
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_comic();

CREATE OR REPLACE FUNCTION fn_controlar_fecha_run()
RETURNS TRIGGER AS $$
DECLARE
    inicio_comic DATE;
BEGIN
    SELECT fecha_inicio INTO inicio_comic FROM comic WHERE id_comic = NEW.id_comic;

    IF NEW.fecha_inicio < inicio_comic THEN
        RAISE EXCEPTION 'La run no puede empezar antes que el cómic (el cómic empieza el %)', inicio_comic;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_run_fecha ON run;
CREATE TRIGGER tr_run_fecha
BEFORE INSERT OR UPDATE OF fecha_inicio ON run
FOR EACH ROW EXECUTE FUNCTION fn_controlar_fecha_run();

CREATE OR REPLACE FUNCTION fn_controlar_cover_principal()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.es_variant = FALSE AND EXISTS (
        SELECT 1 FROM cover
         WHERE id_issue   = NEW.id_issue
           AND es_variant = FALSE
           AND id_cover  <> NEW.id_cover
    ) THEN
        RAISE EXCEPTION 'El issue % ya tiene una cover principal', NEW.id_issue;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_cover_principal ON cover;
CREATE TRIGGER tr_cover_principal
BEFORE INSERT OR UPDATE ON cover
FOR EACH ROW EXECUTE FUNCTION fn_controlar_cover_principal();