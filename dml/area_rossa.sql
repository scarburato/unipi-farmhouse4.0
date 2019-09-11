/*
Scrip DML per l'areaea ross
*/

-- Creazione delle tabelle
CREATE TABLE `Veterinario`
(
`id`					INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT
);

CREATE TABLE `Specie`(
`nome`					CHAR(70) PRIMARY KEY,
`fattore di capacità`	DOUBLE NOT NULL CHECK(`fattore di capacità` > 0),
`famiglia`				ENUM('Bovini', 'Ovini', 'Caprini') NOT NULL
);

CREATE TABLE `Razza`(
`nome`					CHAR(70),
`specie`				CHAR(70),

PRIMARY KEY pk1(`nome`, specie)
);

CREATE TABLE `Animale`(
`id`						BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,

`razza`						CHAR(70) NOT NULL,
`specie`					CHAR(70) NOT NULL,

`locale`					INT UNSIGNED NOT NULL,
	
`sesso`						ENUM('Maschio', 'Femmina') NOT NULL,
`altezza`					SMALLINT UNSIGNED  NOT NULL,

-- Controllare se inizio IS NULL OR fine > inizio
`ultima quarantena`			DATE NULL,
`fine ultima quarantena`	DATE NULL,

-- CHIAVE ESTERNA SU SPECIE
CONSTRAINT specie FOREIGN KEY (`razza`, `specie`) REFERENCES `Razza`(`nome`, `specie`)

-- CHIAVE ESTERNA SU Locale da fare dopo
);

CREATE TABLE `Parto`(
`animale`				BIGINT UNSIGNED NOT NULL,
`madre`					BIGINT UNSIGNED NOT NULL,
`data concepimento`		DATE NOT NULL,

PRIMARY KEY pk1(`animale`),

-- Chiave esterna del nascituro
CONSTRAINT nascituro FOREIGN KEY (`animale`) REFERENCES Animale(`id`)

-- Dopo Chiave esterna su Gestazione aggiunta dopo
);

CREATE TABLE `Fornitore`(
`partita IVA`			CHAR(11) NOT NULL PRIMARY KEY,
`nominativo`			VARCHAR(100) NOT NULL,
`indirizzo`				VARCHAR(100) NOT NULL,
`ragione sociale`		VARCHAR(100) NOT NULL
);

CREATE TABLE `Acquistato`(
`animale`				BIGINT UNSIGNED NOT NULL,
`fornitore`				CHAR(11) NOT NULL,

`data acquisto`			DATE NOT NULL,
`data arrivo`			DATE NOT NULL,

PRIMARY KEY pk1(`animale`),

-- Chiave esterna dell'animae
CONSTRAINT acquisto FOREIGN KEY (`animale`) REFERENCES Animale(`id`),

-- cHIAVE esterna del fornitrore
CONSTRAINT venditore FOREIGN KEY (`fornitore`) REFERENCES Fornitore(`Partita IVA`)
);

CREATE TABLE `Tentativo di riproduzione`(
`madre`					BIGINT UNSIGNED NOT NULL,
`data`					DATE NOT NULL,

`padre`					BIGINT UNSIGNED NOT NULL,
`stato`					ENUM('Successo', 'Insuccesso') NOT NULL,

`veterinario`			INT UNSIGNED NOT NULL,

-- Primary key
PRIMARY KEY pk1(`madre`, `data`),

-- Chiave esterna di madre
CONSTRAINT madre FOREIGN KEY (madre) REFERENCES Animale(id),

-- Chaive esterna del padre
CONSTRAINT padre FOREIGN KEY (padre) REFERENCES Animale(id),

-- cHiave esterna veterinario
CONSTRAINT veterinario_fk FOREIGN KEY (veterinario) REFERENCES Veterinario(id)
);

CREATE TABLE `Gestazione`
(
`madre`					BIGINT UNSIGNED NOT NULL,
`data concepimento`		DATE NOT NULL,

`stato`					ENUM('In corso', 'Conclusa', 'Interrotta') NOT NULL,

`veterinario`			INT UNSIGNED NOT NULL,
`visita dopo aborto`	BIGINT UNSIGNED NULL DEFAULT NULL,

-- Chiave esterna a Conceptimentrre
CONSTRAINT concepimento FOREIGN KEY (madre, `data concepimento`) REFERENCES `Tentativo di riproduzione`(madre, `data`),

-- Chiave esterna al veterinario
CONSTRAINT veterinario FOREIGN KEY (veterinario) REFERENCES Veterinario(id)

-- Dopo chiave alla visita
);

-- Chiave esterna parto
ALTER TABLE `Parto` ADD 
CONSTRAINT parto FOREIGN KEY (`madre`, `data concepimento`) REFERENCES Gestazione(madre, `data concepimento`);

CREATE TABLE `Programmazione visita di controllo`(
`data visita programmata`		DATE NOT NULL,
`madre`							BIGINT UNSIGNED NOT NULL,
`data concepimento`				DATE NOT NULL,

`visita di controllo`			BIGINT UNSIGNED NULL DEFAULT NULL
);