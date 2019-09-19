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
`data di nascita`			DATE NOT NULL,
`data di morte`				DATE NULL DEFAULT NULL,	

`ultima quarantena`			DATE NULL,
`fine ultima quarantena`	DATE NULL,

`tipo`						ENUM('Acquistato', 'Nato in casa') NOT NULL,

-- Controllo sulle date
CONSTRAINT `chk_quarantena`
	CHECK (
		(`ultima quarantena` IS NULL AND `fine ultima quarantena` IS NULL) OR
        (`ultima quarantena` IS NOT NULL AND `fine ultima quarantena` IS NULL) OR
        (`fine ultima quarantena` >= `ultima quarantena`)
	),

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
`stato`					ENUM('Pendente', 'Successo', 'Insuccesso') NOT NULL,

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

-- CONSTRAINT `chk_stato_aborto` CHECK ('')

-- Chiave primari
PRIMARY KEY pk1(`madre`, `data concepimento`),

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

`visita di controllo`			BIGINT UNSIGNED NULL DEFAULT NULL,
`esito`							ENUM('Pendente', 'Negativo', 'Positivo') NOT NULL DEFAULT 'Pendente',

-- È pendente se e solo se visita è null
CONSTRAINT `chk_esito_prgm_vist_contr` 
	CHECK (`visita di controllo` IS NULL XOR `esito` <> 'Pendente'),

-- Chiave primaria
PRIMARY KEY pk1(`data visita programmata`, madre, `data concepimento`),

-- Chiave esterna su Gestazione
CONSTRAINT gestazione_fk FOREIGN KEY (madre, `data concepimento`) REFERENCES Gestazione(madre, `data concepimento`)

-- Dopo aggiungere chiave esterna visita controllo -> visita
);

CREATE TABLE `Esame diagnostico` (
`id`							BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,

`data`							DATE NOT NULL,
`nome`							VARCHAR(100) NOT NULL,
`descrizione`					TEXT NOT NULL,
`macchinario`					VARCHAR(100) NULL,

`data visita programmata`		DATE NOT NULL,
`madre`							BIGINT UNSIGNED NOT NULL,
`data concepimento`				DATE NOT NULL,

-- Chiave esterna
CONSTRAINT visitaprogrammata 
	FOREIGN KEY(`data visita programmata`, madre, `data concepimento`) 
    REFERENCES `Programmazione visita di controllo`(`data visita programmata`, madre, `data concepimento`)
);

CREATE TABLE `Visita di controllo`(
`id`							BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,

`timestamp`						TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
`animale`						BIGINT UNSIGNED NOT NULL,
`veterinario`					INT UNSIGNED NOT NULL,

-- Chiave esterna ad animale
CONSTRAINT visitato FOREIGN KEY (`animale`) REFERENCES Animale(id),

-- Chiave esterna veterinario
CONSTRAINT assegnato FOREIGN KEY (`veterinario`) REFERENCES Veterinario(id)
);

-- Chiave esterna di ABORTO
ALTER TABLE `Gestazione` ADD CONSTRAINT `visita aborto`
	FOREIGN KEY (`visita dopo aborto`) REFERENCES `Visita di controllo`(id);

-- Chiave esterna DI PROGRAMMA VISITA DI CONTROLLO
ALTER TABLE `Programmazione visita di controllo` ADD CONSTRAINT `effettuazione visita`
	FOREIGN KEY (`visita di controllo`) REFERENCES `Visita di controllo`(id);

CREATE TABLE `Indicatore`(
`nome`							CHAR(100) PRIMARY KEY,
`unità di misura`				CHAR(50) NOT NULL,
`tipo`							ENUM('Oggettivo', 'Soggettivo', 'Lesione') NOT NULL,
`parte del corpo`				VARCHAR(200) NULL,

CONSTRAINT `chk_ind_partcorp` 
	CHECK (
		tipo != 'Oggettivo' XOR 
        (tipo = 'Ogettivo' AND `parte del corpo` IS NOT NULL)
	)
);

CREATE TABLE `Rilevazione`(
`visita di controllo`			BIGINT UNSIGNED NOT NULL,
`indicatore`					CHAR(100) NOT NULL,

`valore`						TEXT NOT NULL
);

CREATE TABLE `Terapia`
(
`id`							BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,

`data inizio`					DATE NOT NULL,
`data fine`						DATE NOT NULL,

`esito`							ENUM('Successo', 'Insuccesso') NULL,

`veterinario`					INT UNSIGNED NOT NULL,
`visita di controllo`			BIGINT UNSIGNED NOT NULL,

-- Controllo esito; non si può avere un esito prima che finisca la terapia!
-- CONSTRAINT `chk_esito_data` 
-- CHECK (`data fine` >= CURRENT_DATE XOR (`data fine` < CURRENT_DATE AND `esito` IS NULL)),
    
-- Chiave esterna vet
CONSTRAINT prescrittore_fk FOREIGN KEY (`veterinario`) REFERENCES Veterinario(id),

-- Chiave esterna visita
CONSTRAINT prescrizione_fk FOREIGN KEY (`visita di controllo`) REFERENCES `Visita di controllo`(id)
);

CREATE TABLE `Farmaco`
(
`nome`							CHAR(100) PRIMARY KEY
);

CREATE TABLE `Somministrazione`
(
`terapia`									BIGINT UNSIGNED NOT NULL,
`farmaco`									CHAR(100) NOT NULL,

`posologia`									INT UNSIGNED,

`lista orari somministrazione`				JSON NOT NULL ,
`lista giornate senza somministrazione`		JSON NOT NULL ,

-- terapia
CONSTRAINT somministrando_fk FOREIGN KEY (`terapia`) REFERENCES Terapia(id),

-- farmaco
CONSTRAINT somministrato_fk FOREIGN KEY (farmaco) REFERENCES Farmaco(nome)
);
