/** OPERAZIONE 9 : RAPPORTO SULLA PRODUZIONE **/

SELECT IF(F.stato = 'Scaduto',L.`data di scadenza`,OA.timestamp) AS 'Data di uscita'
FROM Forma F
    INNER JOIN Lotto L ON L.codice = F.`codice lotto` AND L.`agriturismo` = F.`agriturismo del lotto`
    LEFT JOIN `Composizione ordine` CO ON CO.`forma di formaggio`= F.id
    LEFT JOIN `Ordine acquisto` OA ON OA.`codice ordine` = CO.`codice ordine acquisto`
WHERE F.`agriturismo del lotto` = @agriturismo AND F.`codice lotto`= @lotto