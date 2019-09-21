/*
Scrip DML per l'areaea verde
*/

CREATE TABLE `Dipendente area produzione`(
`id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY
);

CREATE TABLE `Lotto`
(
`codice`            CHAR(50) NOT NULL,
`agriturismo`       INT UNSIGNED NOT NULL,

`data di scadenza`  DATE NOT NULL,
`laboratorio`       INT UNSIGNED, -- TODO CONTROLLA STA ROBA!!

`durata processo produttivo` INT UNSIGNED NOT NULL,

PRIMARY KEY pk1(`codice`, `agriturismo`)
);

CREATE TABLE `Lavorazione`
(
`lotto`             CHAR(50) NOT NULL,
`agriturismo`       INT UNSIGNED NOT NULL,
`dipendente`        INT UNSIGNED NOT NULL,

PRIMARY KEY pk1(`lotto`, `agriturismo`, `dipendente`),

CONSTRAINT `dipendente_fk1` FOREIGN KEY (`dipendente`) REFERENCES `Dipendente area produzione`(id),
CONSTRAINT `lotto_fk2` FOREIGN KEY (`lotto`, `agriturismo`) REFERENCES Lotto(`codice`, `agriturismo`)
);

CREATE TABLE `Prodotto caseario`(
`nome`                      CHAR(70) NOT NULL PRIMARY KEY,

`grado di deperibilità`        ENUM('alto', 'medio', 'basso', 'nessuno') NOT NULL,
`tipologia`                 ENUM('pasta molle','pasta dura') NOT NULL
);

CREATE TABLE `Ricetta`(
`prodotto caseario`         CHAR(70) NOT NULL PRIMARY KEY,
`stagionatura`              INT UNSIGNED NOT NULL DEFAULT 0,
`zona geografica`           TEXT NOT NULL,

CONSTRAINT `prodotto_caseario_fk1` FOREIGN KEY (`prodotto caseario`) REFERENCES `Prodotto caseario`(nome)
);

CREATE TABLE `Passo`(
`ricetta`                   CHAR(70) NOT NULL,
`numero passo`              TINYINT UNSIGNED NOT NULL,

`descrizione`               TEXT NOT NULL,
`durata`                    SMALLINT UNSIGNED NOT NULL DEFAULT 0,

PRIMARY KEY pk1(`ricetta`, `numero passo`),

CONSTRAINT `ricetta_fk1` FOREIGN KEY (`ricetta`) REFERENCES Ricetta(`prodotto caseario`)
);

CREATE TABLE `Parametro`(
`nome`                      CHAR(70) PRIMARY KEY NOT NULL,
`unità di misura`          CHAR(50) NOT NULL
);

CREATE TABLE `Aspettativa`(
`parametro`                 CHAR(70) NOT NULL,
`ricetta`                   CHAR(70) NOT NULL,
`numero passo`              TINYINT UNSIGNED NOT NULL,

`valore atteso`             DOUBLE NOT NULL,

PRIMARY KEY pk1(parametro, ricetta, `numero passo`),

CONSTRAINT `passo_ricetta_fk1` FOREIGN KEY (ricetta, `numero passo`) 
    REFERENCES Passo(ricetta, `numero passo`),
    
CONSTRAINT `parametro_fk1` FOREIGN KEY (parametro)
    REFERENCES Parametro(nome)
);

CREATE TABLE `Forma` (
`id`                        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

`tipologia prodotto`        CHAR(70) NOT NULL,
`stato`                     ENUM('Conservato', 'Acquistato', 'Scaduto') NOT NULL DEFAULT 'Conservato',
`peso`                      DECIMAL(4,2) UNSIGNED NOT NULL CHECK(peso <> 0),
`locale stoccaggio`         INT UNSIGNED NULL DEFAULT NULL,

`codice lotto`              CHAR(50) NOT NULL,
`agriturismo del lotto`     INT UNSIGNED NOT NULL,

-- Chiave del lotto
CONSTRAINT `lotto_fk1` FOREIGN KEY (`codice lotto`, `agriturismo del lotto`)
    REFERENCES Lotto(codice, agriturismo),
    
-- Chiave al tipo di prodot
CONSTRAINT `prodotto_caseario_fk2` 
    FOREIGN KEY (`tipologia prodotto`) REFERENCES `Prodotto caseario`(nome),

-- Aggiunere dopo chiave al locale
-- Controllo se e solo tipo è conservato allora la forma è in un locale
CONSTRAINT `chk_stato_conservato` 
    CHECK(NOT (stato <> 'Conservato' XOR`locale stoccaggio` IS NULL))
);

CREATE TABLE `Latte usato`(
`forma`                     BIGINT UNSIGNED NOT NULL,
`cisterna`                  INT UNSIGNED NOT NULL,
`latte usato`               DECIMAL(2,2) CHECK(`latte usato` <> 0),

PRIMARY KEY pk1(`forma`, `cisterna`),

-- Chiave esterna alla forma
CONSTRAINT `forma_fk1` FOREIGN KEY (forma) 
    REFERENCES Forma(id)
    
-- Chiave esterna alla cisterna da aggiungere avanti
);

CREATE TABLE `Valore reale`(
`forma`                     BIGINT UNSIGNED NOT NULL,
`parametro`                 CHAR(70) NOT NULL,
`ricetta`                   CHAR(70) NOT NULL,
`numero passo`              TINYINT UNSIGNED NOT NULL,

`valore letto`              DOUBLE NOT NULL,

PRIMARY KEY pk1(forma, parametro, ricetta, `numero passo`),

-- Chiave esterna a forma
CONSTRAINT `forma_fk2` FOREIGN KEY (`forma`) 
    REFERENCES Forma(id),
    
-- Chiave esterna a paramtero
CONSTRAINT `parametro_fk2` FOREIGN KEY(`parametro`)
    REFERENCES Parametro(nome),
    
-- Chiave esterna a passo
CONSTRAINT `passo_ricetta_fk2` FOREIGN KEY (ricetta, `numero passo`) 
    REFERENCES Passo(ricetta, `numero passo`)
);

CREATE TABLE `Cisterna`(
`id`                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
`capacità`             DECIMAL(2,2) CHECK(`capacità` <> 0),
`livello riempimento`   DECIMAL(2,2) ,



CHECK(`livello riempimento` <= `capacità`)
);

CREATE TABLE `Mungitrice`(
`id`            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`modello`       CHAR (70) NOT NULL,
`marca`         CHAR(70) NOT NULL,
`posizione`     POINT,
`proprietario`  INT UNSIGNED NOT NULL
);

CREATE TABLE `Prodotto mungitura`(
`munto`         BIGINT UNSIGNED,
`timestamp`     TIMESTAMP,
`mungitrice`    INT UNSIGNED NOT NULL,
`quantità`      DECIMAL(2,2),

PRIMARY KEY     pk1(`munto`,`timestamp`),

FOREIGN KEY (`mungitrice`) REFERENCES Mungitrice(`id`)

);
CREATE TABLE `Sostanza latte`(
`nome` VARCHAR(60) PRIMARY KEY
);

CREATE TABLE `Composizione`(
`animale munto`         BIGINT UNSIGNED,
`timestamp`             TIMESTAMP,
`sostanza latte`        VARCHAR(60) NOT NULL,
`quantita`              DECIMAL(2,2),


FOREIGN KEY (`sostanza latte`) REFERENCES `Sostanza latte`(`nome`),

FOREIGN KEY (`animale munto`,`timestamp`) REFERENCES `Prodotto mungitura`(`munto`,`timestamp`)

);

CREATE TABLE `Locale stoccaggio`(
`id`    INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`tipo`  ENUM('Magazzino','Cantina')
);

CREATE TABLE `Scaffalatura`(
`id`            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`locale`        INT UNSIGNED,

/** URGENTE PENSARE A COME IMPLEMENTARE ORA!! */
`posizione`     INT,    -- TO DO da cambiare con x,y,z

FOREIGN KEY (`locale`) REFERENCES `Locale stoccaggio`(`id`)
);

CREATE TABLE `Sensore cantina`(
`tipologia`             ENUM('Ventilazione','Temperatura','Umidità'),
`locale stoccaggio`     INT UNSIGNED NOT NULL,

PRIMARY KEY  pk1(`tipologia`,`locale stoccaggio`),

FOREIGN KEY (`locale stoccaggio`) REFERENCES `Locale stoccaggio`(`id`)
);

CREATE TABLE `Storico sensore cantina`(
`timestamp`             TIMESTAMP,
`tipologia`             ENUM('Ventilazione','Temperatura','Umidità'),
`locale stoccaggio`     INT UNSIGNED NOT NULL,
`valore`                DOUBLE,

PRIMARY KEY  pk1(`timestamp`,`tipologia`,`locale stoccaggio`),

FOREIGN KEY (`tipologia`,`locale stoccaggio`) REFERENCES `Sensore cantina`(`tipologia`,`locale stoccaggio`)

);

