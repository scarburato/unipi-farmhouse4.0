/** ANALYTIC SUL CONTROLLO DELLA QUALITÀ DEL PROCESSO **/
SET @lotto = 'AAA111';  -- Inserimento del lotto
SET @agriturismo = '1'; -- Inserimento dell'agriturismo 
SELECT 
    Par.nome,              -- Per ogni parametro si può osservare il valore atteso,
    A.`valore atteso`,     -- lo scostamento medio e l'unità di misura
    AVG(ABS(A.`valore atteso`-VR.`valore letto`)) AS `Scostamento medio`,
    Par.`unità di misura`
    FROM Forma F
    INNER JOIN `Valore reale` VR ON VR.forma = F.id
    INNER JOIN  Aspettativa A ON A.parametro = VR.parametro     -- Si joina con ciò che è necessario
    INNER JOIN  Parametro Par ON Par.nome = VR.parametro        -- per ottenere i dati su cui lavorare
WHERE F.`codice lotto` = @lotto AND F.`agriturismo del lotto` = @agriturismo
GROUP BY Par.nome, A.`valore atteso`