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
            P.`ora inizio` >= CURRENT_TIME AND
            P.`ora inizio` < addtime(CURRENT_TIME, 30)
        -- Per i check su Pascolo dovrebbe tornare solo un pascolo...
        LIMIT 1
    );
END;;

/*** RIDONDAZA CISTERNA: RIEMPIMENTO AUTOMATICO ***/
CREATE TRIGGER `update_latte_inserito` 
BEFORE INSERT ON `Prodotto mungitura` FOR EACH ROW
BEGIN  
    -- Il check di cisterna farà abortire l'inserimento se si supera la quantità massima
    UPDATE `Cisterna` C
    SET C.`livello riempimento` = C.`livello riempimento` + NEW.`quantità`
    WHERE C.id = NEW.cisterna;
END;;

/*** RIDODANZA CISTERNA: SVUOTAMENTO AUTOMATICO ***/
CREATE TRIGGER `update_latte_usato`
BEFORE INSERT ON `Latte usato` FOR EACH ROW
BEGIN
    -- Il check di cisterna farà abortire l'inserimento se si scende sotto 0
    UPDATE `Cisterna` C
    SET C.`livello riempimento` = C.`livello riempimento` - NEW.`latte usato`
    WHERE C.id = NEW.cisterna;
END;;

/**** RIDODANZA FARMACI USATI: INSERIMENTO somministrazione ****/
CREATE TRIGGER `update_Farmaci_usati` 
AFTER INSERT ON `Somministrazione` FOR EACH ROW
rowss: BEGIN
    -- La chiave della gestazione, se esite
    DECLARE Gmadre          BIGINT UNSIGNED DEFAULT NULL;
    DECLARE Gdata           DATE DEFAULT NULL;
    
    -- Seleziono, se esite, la gestazione associata
    SELECT PVC.`madre`, PVC.`data concepimento` INTO Gmadre, Gdata
    FROM `Programmazione visita di controllo` PVC
        INNER JOIN Terapia T ON T.`visita di controllo` = PVC.`visita di controllo`
    WHERE T.`id` = NEW.terapia;
    
    -- Se non esiste un occorrenza in Programmazione Visita di controllo, non è una terapia
    -- relativa ad una gestazione esco...
    IF Gmadre IS NULL THEN
        LEAVE rowss;
    END IF;
    
    -- Se non esiste già un occorrenza in Farmaci 
    IF NOT EXISTS (
        SELECT 1 FROM `Farmaci usati` FU
        WHERE FU.farmaco = NEW.farmaco AND FU.madre = Gmadre AND FU.`data concepimento` = Gdata
    ) THEN
        -- allora la inserisco
        INSERT INTO `Farmaci usati`(farmaco, madre, `data concepimento`, `quantità`) VALUES
            (NEW.farmaco, Gmadre, Gdata, 1);
    ELSE
        -- altrimenti aggiorno quantità
        UPDATE `Farmaci usati` FU
        SET FU.`quantità` = FU.`quantità` + 1
        WHERE FU.farmaco = NEW.farmaco AND FU.madre = Gmadre AND FU.`data concepimento` = Gdata;
    END IF;
END;;

/**** RIDODANZA FARMACI USATI: CONTEGGIO FALLIMENTI E SUCCESSI A FINE TERAPIA ****/
CREATE TRIGGER `update_Farmaci_usati_esito`
AFTER INSERT ON `Terapia` FOR EACH ROW
rowss: BEGIN
    -- La chiave della gestazione, se esite
    DECLARE Gmadre          BIGINT UNSIGNED DEFAULT NULL;
    DECLARE Gdata           DATE DEFAULT NULL;

    -- Se l'esito è ancora nullo non ho nulla da fare...
    IF NEW.esito IS NULL THEN
        LEAVE rowss;
    END IF;
    
    -- Seleziono, se esite, la gestazione associata
    SELECT PVC.`madre`, PVC.`data concepimento` INTO Gmadre, Gdata
    FROM `Programmazione visita di controllo` PVC
    WHERE PVC.`visita di controllo` = NEW.`visita di controllo`;
    
    -- Se non esiste un occorrenza in Programmazione Visita di controllo, non è una terapia
    -- relativa ad una gestazione esco...
    IF Gmadre IS NULL THEN
        LEAVE rowss;
    END IF;
    
    -- La visita è un successo ?
    IF NEW.esito = 'Successo' THEN
        -- Aggiorno i successi
        UPDATE `Farmaci usati` FU
        SET FU.`numero successi` = FU.`numero successi` + (
            -- Conto il numero di somministrazioni prescritte
            SELECT COUNT(*)
            FROM Somministrazione S
            WHERE S.terapia = NEW.id
        );
    ELSE
        -- Aggiorno gli insusccessi
        UPDATE `Farmaci usati` FU
        SET FU.`numero insuccessi` = FU.`numero insuccessi` + (
            -- Conto il numero di somministrazioni prescritte
            SELECT COUNT(*)
            FROM Somministrazione S
            WHERE S.terapia = NEW.id
        );
    END IF;
    
END;;