DELIMITER ;;
/** RIDODNAZE PASCOLO: Inserimento tramite procedura del pascolo **/
CREATE PROCEDURE `insert_posizione_animale` 
(
    IN animale                  BIGINT UNSIGNED,
    
    IN posizione                POINT,
    
    IN ultimoRegistro           TIMESTAMP,
    INOUT tempo                 TIME,
    
    OUT uscito                  BOOLEAN
)
MODIFIES SQL DATA
BEGIN
    DECLARE ultimoPascoloLocale     INT UNSIGNED DEFAULT NULL;
    DECLARE ultimoPascoloOra        TIME DEFAULT NULL;
    DECLARE forceJoin               BOOLEAN;
    
    -- Check parametri fondamenti
    IF animale IS NULL OR posizione IS NULL
    THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Alcuni paramatri non possono essere null!';
    END IF;
    
    -- Inzializzazione altri parametri
    SET uscito = FALSE;
    SET forceJoin = tempo IS NOT NULL;
    IF tempo IS NULL THEN
        SET tempo = CURRENT_TIME();
    END IF;
    
    -- Se l'ultimo pascolo non è stato passato ovvero non è più valido allora lo calcolo (da Locale)    
    IF 
        ultimoRegistro IS NULL 
        OR (
            SELECT SP.`rientro` IS TRUE
            FROM `Storico posizioni` SP
            WHERE SP.animale = animale AND SP.`timestamp` = ultimoRegistro
        )
    THEN
        -- Se sono in una simulazione devo trovarlo a mano imponendo il tempo simulato
        IF forceJoin THEN
            SELECT P.locale , P.`ora inizio` INTO ultimoPascoloLocale, ultimoPascoloOra
            FROM Pascolo P
            WHERE 
                P.locale = (SELECT A.locale FROM Animale A WHERE A.id = animale) AND
                P.`ora inizio` >= tempo AND
                P.`ora inizio` < addtime(tempo , 30)
            -- Per i check su Pascolo dovrebbe tornare solo un pascolo...
            LIMIT 1;
        ELSE
            SELECT L.id, L.`Ultimo pascolo avviato` INTO ultimoPascoloLocale, ultimoPascoloOra
            FROM Animale A
                INNER JOIN Locale L ON L.id = A.locale
            WHERE A.id = animale;
        END IF;
    -- Altrimenti lo prendo dall'altra posizione
     ELSE
        SELECT `pascolo: locale`,`pascolo: ora` INTO ultimoPascoloLocale, ultimoPascoloOra
        FROM `Storico posizioni` SP
        WHERE SP.animale = animale AND SP.`timestamp` = ultimoRegistro;
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