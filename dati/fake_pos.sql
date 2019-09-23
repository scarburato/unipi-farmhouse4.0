DROP PROCEDURE IF EXISTS `genFakePos`;
DROP FUNCTION IF EXISTS `randmove`;

DELIMITER ;;
CREATE FUNCTION `randmove` (
    attuale         POINT,
    recinto         POLYGON
)
RETURNS POINT DETERMINISTIC
BEGIN
    DECLARE moduloSpostamento       DOUBLE DEFAULT 0;
    DECLARE direzioneSpostamento    DOUBLE DEFAULT 0;
    DECLARE nuovaPos                POINT DEFAULT NULL;

    -- 0.5 di stare fermo
    IF (SELECT ROUND(RAND()) AS `Stai fermo`) THEN
        RETURN attuale;
    END IF;
    
    -- Calcolo spostamento. È DELTAt = 60s, Una mucca muove a v in (0, 10] km/h = (0, 2.8] m/s
    SET moduloSpostamento = (SELECT (RAND() * 1000) % (3.0 * 60));
    
    illegale: LOOP
        -- Dove si muove l'animale ?
        SET direzioneSpostamento = (SELECT radians((RAND() * 5000) % 360));
        
        SET nuovaPos = ST_PointFromText( concat(
            'Point( ',
            ST_Latitude(attuale) + (moduloSpostamento/111000.0)*cos(direzioneSpostamento),
            ' ',
            ST_Longitude(attuale) + (moduloSpostamento/(cos(radians(ST_Latitude(attuale))) * 111000.0))*sin(direzioneSpostamento),
            ' )'
        ), 4326);
        
        -- Se è una mossa legale
        IF st_contains(recinto, nuovaPos) THEN 
            LEAVE illegale;
        END IF;    
    END LOOP;
    
    RETURN nuovaPos;
END;;

CREATE PROCEDURE `genFakePos`(
    IN nAnimali        BIGINT UNSIGNED,
    IN noffset         BIGINT UNSIGNED
)
BEGIN
    DECLARE recinto             POLYGON DEFAULT ST_PolygonFromText(
    'POLYGON((
        42.741840 11.0249000,
        42.756280 11.0249000,
        42.756280 11.0009000,
        42.741840 11.0009000,
        42.741840 11.0249000
    ))', 4326);    
    DECLARE startTime           TIME DEFAULT '08:00:00';
    DECLARE endTime             TIME DEFAULT '11:30:00';
    DECLARE curTime             TIME DEFAULT startTime;
    
    DECLARE localeTarget        INT UNSIGNED DEFAULT 1;
    DECLARE animale             BIGINT;
    
    DECLARE pos                 POINT;
    DECLARE ancora              BOOLEAN DEFAULT TRUE;

    
    DECLARE animaliLoc          CURSOR FOR(
        SELECT A.id
        FROM Animale A
        WHERE A.locale = localeTarget
        LIMIT nAnimali OFFSET noffset
    );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET ancora = FALSE;
    
    OPEN animaliLoc;
    -- Prendo gli animili
    ciclo: LOOP
        FETCH animaliLoc INTO animale;
        
        IF NOT ancora THEN
            LEAVE ciclo;
        END IF;
        
        -- Parto dall'ultimo
        SET pos = ST_PointFromText('POINT(42.749060 11.012900)', 4326);
        SET curTime = startTime;
        
        WHILE curTime < endTime DO
            SET pos = randmove(pos, recinto);
            
            CALL insert_posizione_animale(
                animale,
                pos,
                localeTarget,
                startTime,
                concat(CURRENT_DATE, ' ', curTime)
            );
            
         --   SELECT concat(CURRENT_DATE, ' ', curTime);
            
            SET curTime = curTime + INTERVAL 1 MINUTE;
        END WHILE;
    END LOOP;
    
    CLOSE animaliLoc;
END;;
