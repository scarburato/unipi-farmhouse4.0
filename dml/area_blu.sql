/*
Scrip DML per l'areaea BLU
*/

CREATE TABLE `Agriturismo` (
`id`			      INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`Nominativo`		VARCHAR(100)
);

CREATE TABLE `Tipologia letto`(
`tipo`        CHAR(70) PRIMARY KEY,
`capacità`		INT UNSIGNED NOT NULL CHECK(`capacità` >= 1)
);

CREATE TABLE `Stanza` (
`numero stanza`          INT UNSIGNED NOT NULL,
`agriturismo`            INT UNSIGNED NOT NULL,
`tipologia stanza`       ENUM('Semplice','Suite'),
`prezzo pernottamento`   INT UNSIGNED NOT NULL,
  
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

CREATE TABLE `Prenotazione stanza` (



);
CREATE TABLE `Prenotazione stanze` (


);
CREATE TABLE `Prenotazione servizio` (


);
CREATE TABLE `Utente` (


);
CREATE TABLE `Utente registrato` (


);
CREATE TABLE `Prenotazione escursione` (


);
CREATE TABLE `Escursione` (


);
CREATE TABLE `Composizione escursione` (


);
CREATE TABLE `Zona` (


);
CREATE TABLE `Transazione` (


);
CREATE TABLE `Composizione ordine` (


);
CREATE TABLE `Ordine acquisto` (


);
CREATE TABLE `Spedizione` (


);
CREATE TABLE `Passaggio` (


);
CREATE TABLE `HUB` (


);
CREATE TABLE `Utente store` (


);
CREATE TABLE `Credenziali` (


);
CREATE TABLE `Documento` (


);

