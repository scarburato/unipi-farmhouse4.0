/*
Scrip DML per l'areaea BLU
*/

CREATE TABLE `Agriturismo` (
`id`			   			   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`Nominativo`				   VARCHAR(100)
);	

CREATE TABLE `Tipologia letto`(
`tipo`        CHAR(70) PRIMARY KEY,
`capacità`		INT UNSIGNED NOT NULL CHECK(`capacità` >= 1)
);

CREATE TABLE `Stanza` (
`numero stanza`          INT UNSIGNED NOT NULL,
`agriturismo`            INT UNSIGNED NOT NULL,
`tipologia stanza`       ENUM('Semplice','Suite'),
`prezzo pernottamento`   DECIMAL(4,2) UNSIGNED NOT NULL,
  
PRIMARY KEY              pk1(`numero stanza`,`agriturismo`),
  
 -- chiave esterna per agriturismo
FOREIGN KEY (agriturismo) REFERENCES Agriturismo(id)
);

CREATE TABLE `Composizione stanze` (
`agriturismo`            INT UNSIGNED NOT NULL,
`numero stanza`          INT UNSIGNED NOT NULL,
`tipo`                   CHAR(70) NOT NULL,
`quantità`               TINYINT NOT NULL CHECK(`quantità` >=1),
  
PRIMARY KEY              pk1(`numero stanza`,`tipo`,`agriturismo`),
  
  -- Chiavi esterne agriturismo e numero stanza riferite a quelle di Stanza
FOREIGN KEY (agriturismo,`numero stanza`) REFERENCES Stanza(agriturismo,`numero stanza`),
  
  -- Chiave esterna tipo riferita a tipo di tipologia letto
FOREIGN KEY (tipo) REFERENCES `Tipologia letto`(tipo)
);

CREATE TABLE `Prenotazione stanze` (
`data arrivo`				DATE NOT NULL,
`utente`					CHAR(16) NOT NULL,
`data partenza` 			DATE NOT NULL,
`timestamp prenotazione` 	TIMESTAMP NOT NULL,

PRIMARY KEY 				pk1(`data arrivo`,`utente`),

);

CREATE TABLE `Prenotazione stanza` (
`numero stanza` 	INT UNSIGNED NOT NULL,
`agriturismo`		INT UNSIGNED NOT NULL,
`data arrivo`		DATE NOT NULL,
`utente`			CHAR(16),

PRIMARY KEY 		pk1(`numero stanza`,`agriturismo`,`data arrivo`,`utente`),


-- Chiave esterna riferita a Stanza
FOREIGN KEY (`numero stanza`,agriturismo) REFERENCES Stanza(`numero stanza`,agriturismo),

-- Chiave esterna riferita a Prenotazione stanze
FOREIGN KEY (`data arrivo`,utente) REFERENCES `Prenotazione stanze`(`data arrivo`,utente)

);

CREATE TABLE `Servizio aggiuntivo` (
`nome` 			CHAR(60) PRIMARY KEY,
`prezzo` 		DECIMAL(4,2) UNSIGNED NOT NULL
);

CREATE TABLE `Prenotazione servizio` (
`data arrivo`			DATE NOT NULL,
`utente`				CHAR(16) NOT NULL,
`giorno` 				DATE NOT NULL,
`servizio aggiuntivo` 	CHAR(60) NOT NULL,

PRIMARY KEY 			pk1(`data arrivo`,`utente`,`giorno`,`servizio aggiuntivo`),

-- Chiave esterna riferita al servizio aggiuntivo
FOREIGN KEY (`servizio aggiuntivo`) REFERENCES `Servizio aggiuntivo`(nome),

-- Chiave esterna riferita al servizio aggiuntivo
FOREIGN KEY (`data arrivo`,utente) REFERENCES `Prenotazione stanze`(`data arrivo`,utente)
);
CREATE TABLE `Utente` (
`codice carta` 			CHAR(16) PRIMARY KEY
);

-- ALTER TABLE PER AGGIUNGERE IL RIFERIMENTO ALLA TABELLA prenotazioni stanze
-- precedentemente creata
ALTER TABLE `Prenotazione stanze`
ADD FOREIGN KEY (utente) REFERENCES `Utente`(`codice carta`);

CREATE TABLE `Utente registrato` (
`utente` 		CHAR(16) PRIMARY KEY,
`nome`			VARCHAR(100) NOT NULL,
`cognome` 		VARCHAR(100) NOT NULL,
`indirizzo`		VARCHAR(100) NOT NULL,
`codice documento` CHAR(20) NOT NULL,

--Chiave esterna utente riferita a Utente
FOREIGN KEY (utente) REFERENCES `Utente`(`codice carta`)
);
 
CREATE TABLE `Prenotazione escursione` (
`codice utente` CHAR(16) NOT NULL,
`codice escursione` INT UNSIGNED,

PRIMARY KEY(`codice utente`,`codice escursione`),

--Chiave esterna utente riferita a Utente
FOREIGN KEY (utente) REFERENCES `Utente`(`codice carta`)
);

CREATE TABLE `Escursione` (
`id`	 				INT UNSIGNED PRIMARY KEY,
`inizio escursione` 	TIMESTAMP
);

-- ALTER TABLE PER AGGIUNGERE IL RIFERIMENTO ALLA TABELLA prenotazione escursione
-- precedentemente creata
ALTER TABLE `Prenotazione escursione`
ADD FOREIGN KEY (`codice escursione`) REFERENCES `Escursione`(`id`);

CREATE TABLE `Composizione escursione` (
`zona` 					CHAR(70) NOT NULL,
`agriturismo` 			INT UNSIGNED NOT NULL,
`escursione` 			INT UNSIGNED NOT NULL,
`progressivo passaggio` TINYINT UNSIGNED NOT NULL,
`tempo permanenza`	    SMALLINT UNSIGNED NOT NULL,

PRIMARY KEY pk1(`agriturismo`,`escursione`,`progressivo passaggio`),

FOREIGN KEY (`escursione`) REFERENCES `Escursione`(`id`)
);
CREATE TABLE `Zona` (
`nome` CHAR(70) 			NOT NULL,
`agriturismo`  				INT UNSIGNED NOT NULL,

PRIMARY KEY 				pk1(`nome`,`agriturismo`),

FOREIGN KEY (`agriturismo`) REFERENCES `Agriturismo`(`id`)
);

-- ALTER TABLE PER AGGIUNGERE IL RIFERIMENTO ALLA TABELLA prenotazione escursione
-- precedentemente creata
ALTER TABLE `Composizione escursione`
ADD FOREIGN KEY (`zona`,agriturismo) REFERENCES `Escursione`(`nome`,agriturismo);


CREATE TABLE `Transazione` (
`timestamp transazionale` 		TIMESTAMP,
`data arrivo`					DATE NOT NULL,
`codice carta`					CHAR(16) NOT NULL,
`importo`						DECIMAL(4,2) NOT NULL,
`indirizzo fatturazione`		VARCHAR NOT NULL,

PRIMARY KEY         pk1(`timestamp transazionale`,`data arrivo`,`codice carta`),

FOREIGN KEY (`data arrivo`) REFERENCES `Prenotazione stanze`(`data arrivo`),

FOREIGN KEY (`codice carta`) REFERENCES `Prenotazione stanze`(`utente`)

);
CREATE TABLE `Composizione ordine` (
`forma di formaggio`			INT UNSIGNED PRIMARY KEY,       --TO DO collegare con forma
`reso`							BOOLEAN NOT NULL DEFAULT FALSE,
`gradimento generale`			DECIMAL(5) UNSIGNED,  -- DA 0  A 5
`conservazione`					DECIMAL(5) UNSIGNED,
`qualità percepita`				DECIMAL(5) UNSIGNED,
`gusto`							DECIMAL(5) UNSIGNED,
`codice ordine acquisto`		INT UNSIGNED,
);

CREATE TABLE `Documento` (
`utente store` 			CHAR(16) PRIMARY KEY ,
`tipologia`    			VARCHAR NOT NULL,
`data scadenza` 		DATE NOT NULL,
`ente`  				CHAR(20) NOT NULL,

FOREIGN KEY (`utente store`) REFERENCES `Utente store`(`codice fiscale`)

);

CREATE TABLE `Credenziali` (
`nome utente`   		CHAR(50) PRIMARY KEY ,
`risposta`				TEXT NOT NULL,
`domanda segreta`		TEXT NOT NULL,
`parola d ordine`		CHAR(100) NOT NULL
);

CREATE TABLE `Utente store` (
`codice fiscale` 		CHAR(16) PRIMARY KEY ,
`cognome`      		 	CHAR(50) NOT NULL,
`nome`					CHAR(50) NOT NULL,
`recapito telefonico`	CHAR(35) CHECK (`recapito telefonico` REGEXP '\\+[0-9]{1,3}-[0-9()+\\-]{1,30}'), /* In conformità a ISO 20022 */
`data iscrizione`		DATE() NOT NULL,
`indirizzo`				VARCHAR(150) NOT NULL,
`credenziali`			CHAR(50) NOT NULL,

FOREIGN KEY (`credenziali`) REFERENCES `Credenziali`(`nome utente`)
);
CREATE TABLE `Ordine acquisto` (
`codice ordine` 		INT UNSIGNED PRIMARY KEY ,
`utente store` 			CHAR(16) NOT NULL,
`codice spedizione`		INT UNSIGNED,
-- `stato`  ENUM(), ????

);
CREATE TABLE `HUB` (
`id` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
);

CREATE TABLE `Spedizione` (
`codice`	INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
`stato`		ENUM('Spedito','In transito','In consegna','Consegnato') NOT NULL DEFAULT 'Spedito',
`data consegna stimata`    DATE NOT NULL
);

CREATE TABLE `Passaggio` (
`codice spedizione`		INT UNSIGNED,
`hub`					INT UNSIGNED,
`timestamp`  			TIMESTAMP,
PRIMARY KEY             pk1(`codice spedizione`,`hub`),

FOREIGN KEY (`codice spedizione`) REFERENCES `Spedizione`(`codice`),
FOREIGN KEY (`hub`) REFERENCES `HUB`(`id`)
);






