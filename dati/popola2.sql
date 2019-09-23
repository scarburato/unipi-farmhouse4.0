INSERT INTO Agriturismo(id, nominativo) VALUES
(1, 'Azienda agricola Pisana'),
(2, 'Cooperativa agraria di Vicopisano'),
(3, 'Consorzio degli allevatori della Maremma');

INSERT INTO Stalla(id, agriturismo)VALUES
(1, 3);

INSERT INTO Specie(`nome`, `fattore di capacità`, `famiglia`)VALUES
('Bos taurus', 0.5, 'Bovini');

INSERT INTO Razza(specie, nome) VALUES
('Bos taurus', 'Simmental'),
('Bos taurus', 'Bavarese');

INSERT INTO Locale(`id`, stalla, `specie ammessa`, `pavimentazione`)VALUES
(1, 1, 'Bos taurus', 'Terra');

INSERT INTO `Posizione locale`(locale, orientamento, lunghezza, larghezza) VALUES
(1, 'Nord', 100, 8);

INSERT INTO Animale(`id`, `specie`, `razza`, `locale`, `sesso`, `altezza`, `data di nascita`, `tipo`) VALUES
(1,  'Bos taurus', 'Bavarese', 1, 'Femmina', 100, '2018-01-01', 'Acquistato'),
(2,  'Bos taurus', 'Bavarese', 1, 'Femmina', 85, '2018-01-01', 'Acquistato'),
(3,  'Bos taurus', 'Bavarese', 1, 'Femmina', 90, '2018-11-01', 'Acquistato'),
(4,  'Bos taurus', 'Bavarese', 1, 'Femmina', 93, '2019-05-01', 'Nato in casa');

DELIMITER ;;
CREATE PROCEDURE `popolaAnimali`(
	nAnimali        INT UNSIGNED
)
MODIFIES SQL DATA
BEGIN
    DECLARE i               INT UNSIGNED DEFAULT 0;
    
    WHILE i < nAnimali DO
        INSERT INTO 
            Animale(`specie`, `razza`, `locale`, `sesso`, `altezza`, `data di nascita`, `tipo`) VALUES
                ('Bos taurus', 'Bavarese', 1, 'Femmina', 
                80 + (RAND()*1000)%40,
                '2017-01-01' + INTERVAL ((RAND() * 10e10) % 65072000) SECOND,
                'Nato in casa'
                );
        SET i = i + 1;
    END WHILE;
END;;

DELIMITER ;

INSERT INTO `Zona pascolo` (`proprietà`, `confine`) VALUES
(3, ST_PolygonFromText(
    'POLYGON((
        42.741840 11.0249000,
        42.756280 11.0249000,
        42.756280 11.0009000,
        42.741840 11.0009000,
        42.741840 11.0249000
    ))', 4326)),
(1, ST_PolygonFromText(
    'POLYGON((
        43.72215011963672 10.49585136537539,
        43.71982944060231 10.49222765110821,
        43.71800901265256 10.49345775102514,
        43.71651948519402 10.49608436102092,
        43.71879384262536 10.50136387927456,
        43.72215011963672 10.49585136537539
    ))', 4326) ),
(1, ST_PolygonFromText(
    'POLYGON((
        43.72170801611923 10.49095183607004,
        43.72172377738207 10.49026979993789,
        43.72146453414842 10.49006756547189,
        43.72185969607589 10.48900405944595,
        43.72163320106306 10.48869358759922,
        43.72191778863821 10.48795733835161,
        43.72172784447186 10.48670662503096,
        43.71704058069942 10.49036654597271,
        43.72170801611923 10.49095183607004
    ))', 4326) );
    
INSERT INTO `Pascolo`(locale, `ora inizio`, `ora fine`, `zona pascolo`) VALUES
(1, '08:00:00', '11:30:00', 1);
    
-- Test area illegale 
/*
INSERT INTO `Zona pascolo` (`proprietà`, `confine`) VALUES
(1, ST_PolygonFromText(
    'POLYGON((
        10.49096613169824 43.71914344144687,
        10.49496189227396 43.71933312628863,
        10.49347259427189 43.72176465098687,
        10.49192573532714 43.72158436390860,
        10.49096613169824 43.71914344144687 
    ))', 4326) );*/
