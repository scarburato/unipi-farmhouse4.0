/** OPERAZIONE 7: CONTROLLO DELLA SALUTE DELL'ANIMALE GESTANTE**/
SET @madre = 1;
SET @data_tentativo = '2018-01-01';

SELECT 
    FU.farmaco, 
    FU.`numero successi`/(FU.`numero successi`+FU.`numero insuccessi`) AS `Percentuale successi`,
    FU.`numero insuccessi`/(FU.`numero successi`+FU.`numero insuccessi`) AS `Percentuale insuccessi`

FROM `Farmaci usati` FU
WHERE FU.madre = @madre AND FU.`data concepimento`= @data_tentativo