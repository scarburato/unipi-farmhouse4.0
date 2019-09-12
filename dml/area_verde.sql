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
CONSTRAINT `lotto_fk1` FOREIGN KEY (`codice`, `agriturismo`) REFERENCES Lotto(`codice`, `agriturismo`)
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