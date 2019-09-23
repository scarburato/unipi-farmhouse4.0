/** OPERAZIONE 8: COMPOSIZIONE LETTI STANZE **/

SELECT TL.tipo,capacità,quantità
FROM `Tipologia letto` TL
    INNER JOIN `Composizione stanze` CS ON TL.tipo=CS.tipo
WHERE CS.agriturismo = @agriturismo AND CS.`numero stanza` = @numero_stanza 