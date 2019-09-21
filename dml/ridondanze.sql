/** RIDODNAZE PASCOLO: AGGIORNAMENTO DI ULTIMO PASCOLO AVVIATO **/
DELIMITER ;;
CREATE EVENT `update_ultimo_pascolo`
ON SCHEDULE EVERY 30 MINUTE DO
BEGIN
    UPDATE Locale L SET L.`Ultimo pascolo avviato` = (
        SELECT P.`ora inizio`
        FROM Pascolo P
        WHERE 
            P.locale = L.id AND
            P.`ora inizio` > CURRENT_TIME AND
            P.`ora inizio` <= CURRENT_TIME + INTERVAL 30 MINUTE
        -- Per i check su Pascolo dovrebbe tornare solo un pascolo...
        LIMIT 1
    );
END;;

/** RIDODNAZE PASCOLO: Inserimento tramite procedura del pascolo **/
CREATE PROCEDURE `insert_posizione_animale` 
(
    IN animale                  BIGINT UNSIGNED,
    
    IN latitudine               CHAR(20),
    IN longitudine              CHAR(20),
    
    IN ultimoPascoloLocale      INT UNSIGNED,
    IN ultimoPascoloOra         TIME,
    
    IN forceDifferentTime       TIMESTAMP
)
MODIFIES SQL DATA
BEGIN
    DECLARE uscito BOOLEAN DEFAULT FALSE;
    DECLARE tempo  TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    DECLARE posGPS POINT;
    
    -- Imposto il sistema di rifermento a coordinate geografiche del GPS
    
    -- Importo il valore inviato dal sensore alla base dati
    SET posGPS = ST_PointFromText(concat('POINT(',latitudine,' ', longitudine, ')'), 4326);
    
    IF animale IS NULL OR latitudine IS NULL OR longitudine IS NULL 
    THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Alcuni paramatri non possono essere null!';
    END IF;
    
    IF forceDifferentTime IS NOT NULL
    THEN
        SET tempo = forceDifferentTime;
    END IF;
    
    -- Se l'ultimo pascolo non è stato passato allora lo calcolo (da Locale)
    
    -- Controllo se sono passsato per un varco
    
    -- Inserisco nella base allora

END;;

DELIMITER ;