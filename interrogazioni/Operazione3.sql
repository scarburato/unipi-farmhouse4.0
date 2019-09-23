
/** OPERAZIONE 3 : SODDISFAZIONE DEI CLIENTI **/
SELECT 
    PC.nome,
    SUM(CO.reso IS TRUE)/COUNT(*) AS `Percentuale resi`,
    SUM(CO.reso IS FALSE)/COUNT(*) AS `Percentuale resi`
FROM `Prodotto caseario` PC
    INNER JOIN  Forma F ON F.id = PC.nome
    INNER JOIN `Composizione ordine` CO ON CO.`forma di formaggio`= PC.nome
    
GROUP BY PC.nome

