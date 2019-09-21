/*
Scrip DML per l'areaea GIALLA
*/

CREATE TABLE `Stalla`(
`id`          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`agriturismo` INT UNSIGNED NOT NULL
);

CREATE TABLE `Locale`(
`id`                        INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`stalla`                    INT UNSIGNED NOT NULL,

`specie ammessa`            CHAR(70) NOT NULL,
`pavimentazione`            CHAR(70) NOT NULL,

`Ultimo pascolo avviato`    TIME NULL DEFAULT NULL,

-- Chiave esterna a stalla
FOREIGN KEY (stalla) REFERENCES Stalla(id)
);

CREATE TABLE `Posizione locale`(
`locale`          INT UNSIGNED PRIMARY KEY,
`orientamento`    ENUM('Nord', 'Est', 'Sud', 'Ovest') NOT NULL,

-- In centimetri
`lunghezza`       INT UNSIGNED NOT NULL CHECK(`lunghezza` > 0),
`larghezza`       INT UNSIGNED NOT NULL CHECK(`larghezza` > 0),

FOREIGN KEY (locale) REFERENCES Locale(id)
);

CREATE TABLE `Abbeveratorio`(
`id`              INT UNSIGNED PRIMARY KEY,
`locale`          INT UNSIGNED NOT NULL,

FOREIGN KEY (locale) REFERENCES Locale(id)
);

CREATE TABLE `Storico abbeveratorio`(
`timestamp`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
`abbeveratorio`   INT UNSIGNED NOT NULL,

PRIMARY KEY (`timestamp`, `abbeveratorio`),

FOREIGN KEY (`abbeveratorio`) REFERENCES Abbeveratorio(id)
);

CREATE TABLE `Sostanza`(
`nome`            CHAR(100) NOT NULL PRIMARY KEY
);

CREATE TABLE `Sostanza disciolta`(
`timestamp`       TIMESTAMP NOT NULL,
`abbeveratorio`   INT UNSIGNED NOT NULL,
`sostanza`        CHAR(100) NOT NULL,

`quantità`        DOUBLE NOT NULL CHECK(`quantità` > 0),

PRIMARY KEY(`timestamp`, `abbeveratorio`, `sostanza`),

FOREIGN KEY (sostanza) REFERENCES Sostanza(nome),
FOREIGN KEY (`timestamp`, `abbeveratorio`) REFERENCES `Storico abbeveratorio`(`timestamp`, `abbeveratorio`)
);

CREATE TABLE `Mangiatoia` (
`id`              INT UNSIGNED PRIMARY KEY,
`locale`          INT UNSIGNED NOT NULL,

FOREIGN KEY (locale) REFERENCES Locale(id)
);

CREATE TABLE `Tipo foraggio`(
`nome`                CHAR(70) PRIMARY KEY NOT NULL
);

CREATE TABLE `Storico mangiatoia`(
`timestamp`           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
`mangiatoia`          INT UNSIGNED NOT NULL,

`livello`             DECIMAL(3,2) UNSIGNED NOT NULL CHECK(`livello` BETWEEN 0 AND 100),
`tipo conservazione`  ENUM ('Fresco', 'Fieno', 'Insilato') NOT NULL,
`tipo foraggio`       CHAR(70) NOT NULL,

PRIMARY KEY (`timestamp`, `mangiatoia`),

FOREIGN KEY (mangiatoia) REFERENCES Mangiatoia(id),
FOREIGN KEY (`tipo foraggio`) REFERENCES `Tipo foraggio`(nome)
);

CREATE TABLE `Tipo alimento`(
`nome`                  CHAR (70) PRIMARY KEY,              

`fattore di energia`    DOUBLE NOT NULL CHECK(`fattore di energia` > 0),
`fibra`                 DECIMAL(3,2) UNSIGNED NOT NULL CHECK(`fibra`     BETWEEN 0 AND 100),
`proteine`              DECIMAL(3,2) UNSIGNED NOT NULL CHECK(`proteine`  BETWEEN 0 AND 100),
`glucidi`               DECIMAL(3,2) UNSIGNED NOT NULL CHECK(`glucidi`   BETWEEN 0 AND 100),

-- Controllo composizione sia 100%
CHECK(fibra + proteine + glucidi = 1)
);

CREATE TABLE `Composizione foraggio` (
`tipo foraggio`         CHAR (70) NOT NULL,
`tipo alimento`         CHAR (70) NOT NULL,

`quantità`              DECIMAL(3,2) UNSIGNED NOT NULL CHECK(`quantità` > 0 AND `quantità` <= 100),

PRIMARY KEY (`tipo foraggio`, `tipo alimento`),

FOREIGN KEY (`tipo foraggio`) REFERENCES `Tipo foraggio`(nome),
FOREIGN KEY (`tipo alimento`) REFERENCES `Tipo alimento`(nome)
);

CREATE TABLE `Pasto pianificato`(
`locale`                INT UNSIGNED NOT NULL,
`orario`                TIME NOT NULL,

PRIMARY KEY (locale, orario),

FOREIGN KEY (locale) REFERENCES Locale(id)
);

CREATE TABLE `Tipo sensore` (
`nome`                  CHAR(70) PRIMARY KEY,
`valore soglia`         DOUBLE NULL
);

CREATE TABLE `Sensore`(
`id`                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
`tipo`                  CHAR(70) NOT NULL,
`locale`                INT UNSIGNED NOT NULL,

FOREIGN KEY (tipo) REFERENCES `Tipo sensore`(nome),
FOREIGN KEY (locale) REFERENCES Locale(id)
);

CREATE TABLE `Storico sensore`(
`sensore`               INT UNSIGNED NOT NULL,
`timestamp`             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
`valore`                DOUBLE NOT NULL,

PRIMARY KEY (`timestamp`, `sensore`),

FOREIGN KEY (sensore) REFERENCES Sensore(id)
);

CREATE TABLE `Richiesta di pulizia` (
`id`                    INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`timestamp`             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
`locale`                INT UNSIGNED NOT NULL,

`stato`                 ENUM('Richiesto', 'Effettuato') DEFAULT 'Richiesto',

FOREIGN KEY (`locale`) REFERENCES Locale(id)
);

CREATE TABLE `Zona pascolo`(
`id`                    INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`confine`               POLYGON SRID 4326 NOT NULL,
`proprietà`             INT UNSIGNED NOT NULL
);

CREATE TABLE `Portale accesso pascolo` (
`posizione`             POINT SRID 4326 NOT NULL, -- PRIMARY KEY,
`zona pascolo`          INT UNSIGNED NOT NULL,

FOREIGN KEY (`zona pascolo`) REFERENCES `Zona pascolo`(id)
);

CREATE TABLE `Pascolo`(
`locale`                INT UNSIGNED NOT NULL,
`ora inizio`            TIME NOT NULL,
`ora fine`              TIME NOT NULL,
`zona pascolo`          INT UNSIGNED NOT NULL,

CHECK ( MINUTE(TIMEDIFF(`ora fine`, `ora inizio`)) > 30 ),

PRIMARY KEY (locale, `ora inizio`),

FOREIGN KEY (locale) REFERENCES Locale(id),
FOREIGN KEY (`zona pascolo`) REFERENCES `Zona pascolo`(id)
);

CREATE TABLE `Storico posizioni`(
`animale`                   BIGINT UNSIGNED NOT NULL,
`timestamp`                 TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

`posizione`                 POINT SRID 4326 NOT NULL,

`pascolo: locale`           INT UNSIGNED NOT NULL,
`pascolo: ora`              TIME NOT NULL,

`rientro`                   BOOLEAN NOT NULL DEFAULT FALSE,

PRIMARY KEY (animale, `timestamp`),

FOREIGN KEY (`pascolo: locale`, `pascolo: ora`)
    REFERENCES Pascolo(`locale`, `ora inizio`)
);

CREATE TABLE `Macchina`(
`nome`                      CHAR(70) PRIMARY KEY,
`descrizione`               TEXT NOT NULL
);

CREATE TABLE `Allestimento ideale`(
`macchina`                  CHAR(70) NOT NULL,
`specie`                    CHAR(70) NOT NULL,

`note installazione`        TEXT NOT NULL,

PRIMARY KEY (macchina, specie),

FOREIGN KEY (macchina) REFERENCES Macchina(nome)
);

/********************************************************************
 *                      
 *                          FUNZIONI
 *
 ********************************************************************/
DELIMITER ;;
CREATE FUNCTION `capacitàMassima` (`locale` INT UNSIGNED)
RETURNS SMALLINT UNSIGNED 
COMMENT 'Computa la capacità massima'
DETERMINISTIC READS SQL DATA
BEGIN
    RETURN (
        SELECT FLOOR(PL.larghezza * PL.lunghezza * S.`fattore di capacità`)
        FROM `Locale` L
            INNER JOIN `Posizione locale` PL ON PL.locale = L.id
            INNER JOIN `Specie` S ON S.nome = L.`specie ammessa`
        WHERE 
            L.id = locale
    );
END;;

CREATE FUNCTION `energia` (`foraggio` CHAR (70), `peso` DOUBLE)
RETURNS DOUBLE 
COMMENT 'Computa i joule per grammo cioè il chilo-joule per chilo-grammo'
DETERMINISTIC READS SQL DATA
BEGIN
    RETURN peso * (
        SELECT IFNULL(SUM(TA.`fattore di energia` * (C.`quantità`/100.0)), 0)
        FROM `Composizione foraggio` C
            INNER JOIN `Tipo alimento` TA ON TA.nome = C.`tipo alimento`
        WHERE C.`tipo foraggio` = foraggio
    );
END;;
 
DELIMITER ;

/********************************************************************
 *                      
 *                         AUTOMATISMI
 *
 ********************************************************************/
DELIMITER ;;
CREATE TRIGGER `sensore_locale_valore_soglia`
AFTER INSERT ON `Storico sensore` FOR EACH ROW
rowss: BEGIN 
    DECLARE soglia DOUBLE DEFAULT NULL;
    DECLARE ultimo TIMESTAMP DEFAULT NULL;
    DECLARE localeS INT UNSIGNED;
    
    -- Il valore soglia del sensore
    SET soglia = (
        SELECT T.`valore soglia`
        FROM `Tipo sensore` T
            INNER JOIN `Sensore` S ON S.tipo = T.nome
        WHERE
            S.id = NEW.sensore
    );
    
    -- Se non è un sensore di igene esco
    IF soglia IS NULL
    THEN
        LEAVE rowss;
    END IF;
    
    -- Locale del sensore
    SET localeS = (
        SELECT S.locale
        FROM Sensore S
        WHERE S.id = NEW.sensore
    );
    
    -- Ulitma richiesta pendente
    SET ultimo =  (
        SELECT RP.`timestamp`
        FROM `Richiesta di pulizia` RP
        WHERE 
            RP.locale = localeS AND
            RP.stato = 'Richiesto'
    );

    -- Se l'ultima non esiste allora inserisco
    IF (ultimo IS NULL)
    THEN
        INSERT INTO `Richiesta di pulizia`(`timestamp`, `locale`)
            VALUES (NEW.`timestamp`, localeS);
    -- altrimenti ne creo una
    ELSE
        UPDATE `Richiesta di pulizia` RP 
        SET RP.`timestamp` = NEW.`timestamp`
        WHERE 
            RP.`stato` = 'Richiesto' AND
            RP.locale = localeS;
    END IF;
END;;

DELIMITER ;