/*
Scrip DML per l'areaea verde
*/

CREATE TABLE `Dipendente area produzione`(
`id`			INT UNSIGNED AUTO_INCREMENT PRIMARY KEY
);

CREATE TABLE `Lotto`
(
`codice`			CHAR(50) NOT NULL,
`agriturismo`		INT UNSIGNED NOT NULL,

`data di scadenza`	DATE NOT NULL,
`laboratorio`		INT UNSIGNED, -- TODO CONTROLLA STA ROBA!!

`durata processo produttivo` INT UNSIGNED NOT NULL,

PRIMARY KEY pk1(`codice`, `agriturismo`)
);

CREATE TABLE `Lavorazione`
(
`lotto`				CHAR(50) NOT NULL,
`agriturismo`		INT UNSIGNED NOT NULL,
`dipendente`		INT UNSIGNED NOT NULL,

PRIMARY KEY pk1(`lotto`, `agriturismo`, `dipendente`),

CONSTRAINT `dipendente_fk1` FOREIGN KEY (`dipendente`) REFERENCES `Dipendente area produzione`(id),
CONSTRAINT `lotto_fk2` FOREIGN KEY (`lotto`, `agriturismo`) REFERENCES Lotto(`codice`, `agriturismo`)
);

CREATE TABLE `Prodotto caseario`(
`nome`						CHAR(70) NOT NULL PRIMARY KEY,

`grado di deperibilità`		ENUM('alto', 'medio', 'basso', 'nessuno') NOT NULL,
`tipologia`					ENUM('pasta molle','pasta dura') NOT NULL
);

CREATE TABLE `Ricetta`(
`prodotto caseario`			CHAR(70) NOT NULL PRIMARY KEY,
`stagionatura`				BOOLEAN NOT NULL,
`zona geografica`			TEXT NOT NULL,

CONSTRAINT `prodotto_caseario_fk1` FOREIGN KEY (`prodotto caseario`) REFERENCES `Prodotto caseario`(nome)
);

CREATE TABLE `Passo`(
`ricetta`					CHAR(70) NOT NULL,
`numero passo`				TINYINT UNSIGNED NOT NULL,

`descrizione`				TEXT NOT NULL,
`durata`					SMALLINT UNSIGNED NOT NULL DEFAULT 0,

PRIMARY KEY pk1(`ricetta`, `numero passo`),

CONSTRAINT `ricetta_fk1` FOREIGN KEY (`ricetta`) REFERENCES Ricetta(`prodotto caseario`)
);

CREATE TABLE `Parametro`(
`nome`						CHAR(70) PRIMARY KEY NOT NULL
);

CREATE TABLE `Aspettativa`(
`parametro`					CHAR(70) NOT NULL,
`ricetta`					CHAR(70) NOT NULL,
`numero passo`				TINYINT UNSIGNED NOT NULL,

`valore atteso`				DOUBLE NOT NULL,
`unità di misura`			CHAR(50) NOT NULL,

PRIMARY KEY pk1(parametro, ricetta, `numero passo`),

CONSTRAINT `passo_ricetta_fk1` FOREIGN KEY (ricetta, `numero passo`) 
	REFERENCES Passo(ricetta, `numero passo`),
    
CONSTRAINT `parametro_fk1` FOREIGN KEY (parametro)
	REFERENCES Parametro(nome)
);

CREATE TABLE `Forma` (
`id`						BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

`stato`						ENUM('Conservato', 'Acquistato', 'Scaduto') NOT NULL DEFAULT 'Conservato',
`peso`						DECIMAL(4,2) UNSIGNED NOT NULL CHECK(peso <> 0),
`locale stoccaggio`			INT UNSIGNED NULL DEFAULT NULL,

`codice lotto`				CHAR(50) NOT NULL,
`agriturismo del lotto`		INT UNSIGNED NOT NULL,

-- Chiave del lotto
CONSTRAINT `lotto_fk1` FOREIGN KEY (`codice lotto`, `agriturismo del lotto`)
	REFERENCES Lotto(codice, agriturismo),

-- Aggiunere dopo chiave al locale
-- Controllo se e solo tipo è conservato allora la forma è in un locale
CONSTRAINT `chk_stato_conservato` 
	CHECK(NOT (stato <> 'Conservato' XOR`locale stoccaggio` IS NULL))
);

CREATE TABLE `Latte usato`(
`forma`						BIGINT UNSIGNED NOT NULL,
`cisterna`					INT UNSIGNED NOT NULL,
`latte usato`				DECIMAL(2,2) CHECK(`latte usato` <> 0),

PRIMARY KEY pk1(`forma`, `cisterna`),

-- Chiave esterna alla forma
CONSTRAINT `forma_fk1` FOREIGN KEY (forma) 
	REFERENCES Forma(id)
    
-- Chiave esterna alla cisterna da aggiungere avanti
);

CREATE TABLE `Valore reale`(
`forma`						BIGINT UNSIGNED NOT NULL,
`parametro`					CHAR(70) NOT NULL,
`ricetta`					CHAR(70) NOT NULL,
`numero passo`				TINYINT UNSIGNED NOT NULL,

`valore letto`				DOUBLE NOT NULL,

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