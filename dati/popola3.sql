TRUNCATE TABLE Rilevazione;

INSERT INTO Veterinario VAlUES(1);

INSERT INTO Indicatore(nome,`unità di misura`,tipo,`parte del corpo`) VALUES 
('Lesione alla spalla','gravità','Lesione','spalla'),
('Temperatura corporea','celsious','Oggettivo',NULL),
('Spessore dello zoccolo','Millimetri','Oggettivo',NULL),
('Risposta oculare','gravità','Oggettivo',NULL),
('Emocromo','millisecondo','Oggettivo',NULL),
('Battito','pulsazioni al minuto','Oggettivo',NULL);

INSERT INTO `Visita di controllo`(id,`timestamp`,animale,veterinario) VALUES
(1,'2019-01-01 12:00:00',23,1);

INSERT INTO `Rilevazione`(`visita di controllo`,`indicatore`,`valore`) VALUES
(1,'Lesione alla spalla',6),
(1,'Temperatura corporea',40);

INSERT INTO `Visita di controllo`(id,`timestamp`,animale,veterinario) VALUES
(2,'2019-07-01 12:00:00',23,1);
INSERT INTO `Rilevazione`(`visita di controllo`,`indicatore`,`valore`) VALUES
(2,'Lesione alla spalla',3),
(2,'Temperatura corporea',38);