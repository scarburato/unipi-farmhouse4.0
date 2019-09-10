/*
Scrip DML per l'areaea BLU
*/

CREATE TABLE `Agriturismo` (
`id`			INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`Nominativo`		VARCHAR(100)
);

CREATE TABLE `Tipologia letto`(
`tipo`			CHAR(70) PRIMARY KEY,
`capacità`		INT UNSIGNED NOT NULL CHECK(`capacità` >= 1)
);
