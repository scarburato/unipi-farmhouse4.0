/** OPERAZIONE 6 : VALORE DEI SENSORI LOCALE**/

SELECT 
    S.tipo,
    (
        SELECT SS.valore
        FROM `Storico sensore` SS
        WHERE SS.sensore = S.id AND SS.`timestamp` <= RP.`timestamp`
        ORDER BY SS.`timestamp` ASC LIMIT 1
    ) as `ultimo valore`
FROM Sensore S 
    INNER JOIN `Richiesta di pulizia` RP ON RP.locale = S.locale
WHERE RP.id = @richiesta
