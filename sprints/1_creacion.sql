DROP TABLE IF EXISTS cover, issue_artista, issue, escritor_run, run, comic,
                     empresa, artista, escritor, persona CASCADE;
DROP DOMAIN IF EXISTS t_popularidad, t_ejemplares, t_numero_issue, t_tipo_cover CASCADE;

CREATE DOMAIN t_popularidad  AS DECIMAL(3,2) CHECK (VALUE >= 0 AND VALUE <= 5);
CREATE DOMAIN t_ejemplares   AS INTEGER      CHECK (VALUE >= 0);
CREATE DOMAIN t_numero_issue AS INTEGER      CHECK (VALUE > 0);
CREATE DOMAIN t_tipo_cover   AS BOOLEAN;

CREATE TABLE persona (
    id_persona       SERIAL PRIMARY KEY,
    nombre           VARCHAR(30) NOT NULL,
    apellido         VARCHAR(30) NOT NULL,
    alias            VARCHAR(30),
    fecha_nacimiento DATE NOT NULL,
    fecha_inicio     DATE,
    CHECK (fecha_nacimiento <= CURRENT_DATE),
    CHECK (fecha_inicio > fecha_nacimiento)
);

CREATE TABLE escritor (
    id_escritor INTEGER PRIMARY KEY REFERENCES persona (id_persona)
);

CREATE TABLE artista (
    id_artista INTEGER PRIMARY KEY REFERENCES persona (id_persona)
);

CREATE TABLE empresa (
    id_empresa SERIAL PRIMARY KEY,
    nombre     VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE comic (
    id_comic            SERIAL PRIMARY KEY,
    nombre              VARCHAR(30)   NOT NULL,
    descripcion         VARCHAR(300)  NOT NULL,
    fecha_inicio        DATE          NOT NULL CHECK (fecha_inicio <= CURRENT_DATE),
    popularidad         t_popularidad NOT NULL DEFAULT 0,
    ejemplares_vendidos t_ejemplares  NOT NULL DEFAULT 0,
    id_empresa          INTEGER       NOT NULL REFERENCES empresa (id_empresa),
    id_escritor         INTEGER       NOT NULL REFERENCES escritor (id_escritor)
);

CREATE TABLE run (
    id_run              SERIAL PRIMARY KEY,
    fecha_inicio        DATE          NOT NULL,
    popularidad         t_popularidad NOT NULL DEFAULT 0,
    ejemplares_vendidos t_ejemplares  NOT NULL DEFAULT 0,
    id_comic            INTEGER       NOT NULL REFERENCES comic (id_comic) ON DELETE CASCADE
);

CREATE TABLE escritor_run (
    id_run      INTEGER REFERENCES run (id_run) ON DELETE CASCADE,
    id_escritor INTEGER REFERENCES escritor (id_escritor),
    PRIMARY KEY (id_run, id_escritor)
);

CREATE TABLE issue (
    id_issue            SERIAL PRIMARY KEY,
    numero              t_numero_issue NOT NULL,
    titulo              VARCHAR(30),
    ejemplares_vendidos t_ejemplares   NOT NULL DEFAULT 0,
    popularidad         t_popularidad  NOT NULL DEFAULT 0,
    id_run              INTEGER        NOT NULL REFERENCES run (id_run) ON DELETE CASCADE,
    UNIQUE (id_run, numero)
);

CREATE TABLE issue_artista (
    id_issue   INTEGER REFERENCES issue (id_issue) ON DELETE CASCADE,
    id_artista INTEGER REFERENCES artista (id_artista),
    PRIMARY KEY (id_issue, id_artista)
);

CREATE TABLE cover (
    id_cover       SERIAL PRIMARY KEY,
    nombre         VARCHAR(30)  NOT NULL,
    fecha_creacion DATE         NOT NULL DEFAULT CURRENT_DATE CHECK (fecha_creacion <= CURRENT_DATE),
    es_variant     t_tipo_cover NOT NULL DEFAULT TRUE,
    id_issue       INTEGER      NOT NULL REFERENCES issue (id_issue) ON DELETE CASCADE,
    id_artista     INTEGER      NOT NULL REFERENCES artista (id_artista)
);