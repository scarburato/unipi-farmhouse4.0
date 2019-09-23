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
    
    IN posizione                POINT,
    
    IN ultimoRegistro           TIMESTAMP
    INOUT tempo                 TIMESTAMP,
    
    OUT uscito                  BOOLEAN
)
MODIFIES SQL DATA
BEGIN
    DECLARE ultimoPascoloLocale      INT UNSIGNED DEFAULT NULL;
    DECLARE ultimoPascoloOra         TIME DEFAULT NULL;    
    
    IF animale IS NULL OR posizione IS NULL OR (ultimoPascoloLocale IS NULL XOR ultimoPascoloOra IS NULL)
    THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Alcuni paramatri non possono essere null!';
    END IF;
    
    SET uscito = FALSE;
    IF forceDifferentTime IS NOT NULL
    THEN
        SET tempo = forceDifferentTime;
    END IF;
    
    -- Se l'ultimo pascolo non è stato passato allora lo calcolo (da Locale)
    IF ultimoPascoloLocale IS NULL THEN
        SELECT L.id, L.`Ultimo pascolo avviato` INTO ultimoPascoloLocale, ultimoPascoloOra
        FROM Animale A
            INNER JOIN Locale L ON L.id = A.locale
        WHERE A.id = animale;
    END IF;
    
    -- Controllo se sono passsato per un varco
    SET uscito = 0 <>ANY(
        -- La distanza da un portale è meno di metri 5
        SELECT ST_Distance_Sphere(PAP.posizione, posizione) < 5
        FROM `Portale accesso pascolo` PAP
            INNER JOIN Pascolo P ON P.`zona pascolo` = PAP.`zona pascolo`
        WHERE P.locale = ultimoPascoloLocale AND P.`ora inizio` = ultimoPascoloOra
    );
    
    -- Inserisco nella base allora
    INSERT INTO `Storico posizioni`(`animale`,`timestamp`,`posizione`,`pascolo: locale`,`pascolo: ora`, rientro) VALUES
        (animale, tempo, posizione, ultimoPascoloLocale, ultimoPascoloOra, uscito);

END;;

DELIMITER ;