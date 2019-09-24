DELIMITER ;;
DROP PROCEDURE IF EXISTS `heat_map_pascolo`;;

CREATE PROCEDURE `heat_map_pascolo`(
`localeP`                INT UNSIGNED,
`orainizioP`             TIME
)
BEGIN
    DECLARE recinto             LINESTRING DEFAULT NULL;
    
    -- Questi sono gli estremi del rettangolo che andrò a circoscrivere alla zona di pascolo
    -- in modo da facilitare poi il partizionamento in quadratini
    DECLARE estremoDestro       DOUBLE DEFAULT -180.0;
    DECLARE estremoSinistro     DOUBLE DEFAULT +180.0;
    
    DECLARE estremoSuperiore    DOUBLE DEFAULT -90.0;
    DECLARE estremoInferiore    DOUBLE DEFAULT +90.0;
    
    -- Variabili per il calcolo del rettangolo
    DECLARE numeroEstremi,i     INT UNSIGNED DEFAULT 0;
    DECLARE punto               POINT DEFAULT NULL;
    
    -- Dimensione delle partizioni
    -- 1°S/N di latidune è circa 111 Km
    -- 1° di longitudine varia a seconda della latidune secondo la legge L(l) = cos(l) * 111
    -- L'area del pascolo è molto ridotta rispetto alla sup. terrrestere e si può quindi evitare di considerare la 
    -- curvatura terrestre e pensarla come un piano.
    DECLARE lenPartVert         DOUBLE DEFAULT 0.05; -- 50 metri per
    DECLARE lenPartOriz         DOUBLE DEFAULT 0.05; -- 50 metri
    
    -- Qua salvero la lunghezza di un grado di longitudine rispetto a dove si trova il pascolo sul pianeta
    DECLARE lenLong             DOUBLE DEFAULT 110.0;
    
    -- Qua salverò il numero di partizioni che ci saranno per latidude e long
    DECLARE partizioniVert      INT UNSIGNED DEFAULT 0;
    DECLARE partizioniOriz      INT UNSIGNED DEFAULT 0;
    
    DECLARE gradPerPartVert     DOUBLE;
    DECLARE gradPerPartOriz     DOUBLE;
    
    -- Ottengo il perimetro del pligono della zona di pascolo come linea spezzata
    SET recinto = (
        SELECT ST_ExteriorRing(Z.confine)
        FROM `Pascolo` P
            INNER JOIN `Zona pascolo` Z ON Z.`id` = P.`zona pascolo`
        WHERE P.`locale` = localeP AND P.`ora inizio` = orainizioP
    );
    
    -- Se il pascolo non esiste errore
    IF recinto IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'È stato inserito un pascolo inesistente ovvero una funzione di OpenGIS non ha funzionato come atteso...';
    END IF; 
    
    -- Il numero di punti che vanno a creare la linea spezzata
    SET numeroEstremi = ST_NumPoints(recinto);
    
    -- Ciclo attraverso tutti i punti della linea
    WHILE i < numeroEstremi DO
        -- Il punto attuale
        SET punto = ST_PointN(recinto, i + 1);
        
        -- Check latidude superiore
        IF ST_Latitude(punto) > estremoSuperiore THEN
            SET estremoSuperiore = ST_Latitude(punto);
        END IF;
        
        -- Check latidude superiore
        IF ST_Latitude(punto) < estremoInferiore THEN
            SET estremoInferiore = ST_Latitude(punto);
        END IF;
        
        -- Check longiutdine destra 
        IF ST_Longitude(punto) > estremoDestro THEN
            SET estremoDestro = ST_Longitude(punto);
        END IF;
        
        -- Check longiutdine destra 
        IF ST_Longitude(punto) < estremoSinistro THEN
            SET estremoSinistro = ST_Longitude(punto);
        END IF;
        
        SET i = i + 1;
    END WHILE;
    
    -- Se l'area è troppo alta errore
    IF estremoSuperiore - estremoInferiore > 1.00 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'L\'area selezionata ha dimensioni massive, la sua lunghezza rispetto ai meridiani supera i 100Km!\
È impossibile computare i dati come se fossero su di un piano anziché su una sfera!';
    END IF;
    
    -- Ora calcolo quante partizioni ci sono; prima quelle verticali che sono costanti
    SET partizioniVert  = FLOOR((estremoSuperiore - estremoInferiore)*111 / lenPartVert);
    SET gradPerPartVert = (estremoSuperiore - estremoInferiore) / partizioniVert;
    
    -- Quanto è lungo 1° di longitudine? 
    SET lenLong = cos( radians( estremoSuperiore ) ) * 111;
    
    SET partizioniOriz  = FLOOR((estremoDestro - estremoSinistro)*lenLong / lenPartOriz );
    SET gradPerPartOriz = (estremoDestro - estremoSinistro) / partizioniOriz;
    
    -- Ora creo la tabella con le tabelle con le partizioni
    DROP TEMPORARY TABLE IF EXISTS `heatmap_Vert`;
    CREATE TEMPORARY TABLE `heatmap_Vert`(
        `latidudine`          DOUBLE NOT NULL
    );
    
    DROP TEMPORARY TABLE IF EXISTS `heatmap_Oriz`;
    CREATE TEMPORARY TABLE `heatmap_Oriz`(
        `longitudine`         DOUBLE NOT NULL
    );
    
    SET i = 0;
    WHILE i < partizioniVert DO
        INSERT INTO `heatmap_Vert` 
        -- TODO Mettere in una var separata
        VALUES (estremoInferiore + gradPerPartVert*(i));
        SET i = i + 1;
    END WHILE;
    
    SET i = 0;
    WHILE i < partizioniOriz DO
        INSERT INTO `heatmap_Oriz` 
        VALUES (estremoSinistro + gradPerPartOriz*(i));
        SET i = i + 1;
    END WHILE;
    
    DROP TEMPORARY TABLE IF EXISTS `CROSS`;
    
    CREATE TEMPORARY TABLE `CROSS` AS(
    SELECT *
    FROM `heatmap_Vert` CROSS JOIN `heatmap_Oriz`); 
    
/************************************************************
 *                  COMPUTO DEL SOGGIORNO
 *                      DEGLI ANIMALI
 *              NELLE PARTIZIONI RETTANGOLARI
 ************************************************************/
    SELECT 
        'pos' AS `name`,
        latidudine,
        longitudine,
        COUNT(SP.posizione) AS `Numero posizioni registrate` -- ,
        -- NULL AS `Animale(i) più frequente`
    FROM `CROSS`
        LEFT JOIN `Storico posizioni` SP ON 
            -- del pascolo interessato
            SP.`pascolo: locale` = localeP AND SP.`pascolo: ora` = orainizioP AND
            
            -- nella partizione interessata
            ST_Latitude(SP.posizione) >= latidudine AND ST_Latitude(SP.posizione) < (latidudine + gradPerPartVert) AND
            ST_Longitude(SP.posizione) >= longitudine AND ST_Longitude(SP.posizione) < (longitudine + gradPerPartOriz)
    GROUP BY latidudine, longitudine
    
    ;
    
    DROP TEMPORARY TABLE `heatmap_Oriz`;
    DROP TEMPORARY TABLE `heatmap_Vert`;
END;;

CALL heat_map_pascolo(1, '08:00:00');;