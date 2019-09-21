/** Somma composizione foraggio non superi il 100% */
DELIMITER ;;
CREATE PROCEDURE `chk_quanità_100` 
(
    IN  `tipoforaggio`          CHAR (70),
    IN  `tipoalimento`          CHAR (70),
    OUT `via libera`            BOOLEAN
)
READS SQL DATA
BEGIN 
    SET `via libera` = (
        SELECT IFNULL(SUM(C.`quantità`),0) <= 100 AS `Condizione`
        FROM `Composizione foraggio` C
        WHERE
            C.`tipo foraggio` = `tipoforaggio`
    );
END;;

CREATE TRIGGER `chk_quanità_100_INSERT`
BEFORE INSERT ON `Composizione foraggio`FOR EACH ROW
BEGIN
    DECLARE ok BOOLEAN DEFAULT TRUE;
    CALL chk_quanità_100(NEW.`tipo foraggio`, NEW.`tipo alimento`, ok);
    
    IF NOT ok THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Eccesso di 100%!';
    END IF;
END;;

CREATE TRIGGER `chk_quanità_100_UPDATE`
BEFORE UPDATE ON `Composizione foraggio`FOR EACH ROW
BEGIN
    DECLARE ok BOOLEAN DEFAULT TRUE;
    CALL chk_quanità_100(NEW.`tipo foraggio`, NEW.`tipo alimento`, ok);
    
    IF NOT ok THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Eccesso di 100%!';
    END IF;
END;;

/** I pascoli di un locale siano distanziati di 31 minuti **/
CREATE PROCEDURE `chk_orario_pascolo` 
(
    IN  `orario`          TIME,
    IN  `locale`          INT UNSIGNED,
    OUT `vialibera`       BOOLEAN
)
READS SQL DATA
BEGIN 
    
END;;

/** Gli animali di un locale devono essere della specie abilitata**/
CREATE TRIGGER `chk_animale_locale_INSERT`
BEFORE INSERT ON `Animale` FOR EACH ROW
BEGIN
    IF(
        SELECT NEW.specie = L.`specie ammessa`
        FROM Locale L
        WHERE L.id = NEW.locale
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La specie non è ammessa';
    END IF;

    -- Controllo se ha superato la capacità
    IF (
        SELECT IFNULL(COUNT(*), 0) > `capacitàMassima`(NEW.locale)
        FROM Animale A
        WHERE A.locale = NEW.locale
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacità superata';
    END IF;
END;;

CREATE TRIGGER `chk_animale_locale_UPDATE`
BEFORE UPDATE ON `Animale` FOR EACH ROW
rowss: BEGIN
    -- Nulla da fare...
    IF (NEW.locale = OLD.locale)
    THEN
        LEAVE rowss;
    END IF;

    IF NOT(
        SELECT NEW.specie = L.`specie ammessa`
        FROM Locale L
        WHERE L.id = NEW.locale
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La specie non è ammessa';
    END IF;
    
    -- Controllo se ha superato la capacità
    IF (
        SELECT IFNULL(COUNT(*), 0) > `capacitàMassima`(NEW.locale)
        FROM Animale A
        WHERE A.locale = NEW.locale
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacità superata';
    END IF;
END;; 

/** Sesso opportuno per gli animali di gestazione
    e nessuna riproduzione pendente
 **/
CREATE TRIGGER `chk_TentativoRip_INSER`
BEFORE INSERT ON `Tentativo di riproduzione` FOR EACH ROW
BEGIN
    -- Controllo padre
    IF NOT(
        SELECT A.sesso = 'Maschio'
        FROM Animale A
        WHERE A.id = NEW.padre
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il padre deve essere maschio!';
    END IF;
    
    -- Controllo madre
    IF NOT(
        SELECT A.sesso = 'Femmina'
        FROM Animale A
        WHERE A.id = NEW.madre
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La madre deve essere femmina!';
    END IF;
    
    -- Controllo gestazione pendente
    IF NEW.stato = 'Pendente' AND EXISTS (
        SELECT 1
        FROM `Tentativo di riproduzione` T
        WHERE 
            T.madre = NEW.madre AND
            T.stato = 'Pendente'
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un tentativo di riproduzione è ancora pendente!';
    END IF;
    
    -- Controllo se non ci sono gestazioni in corso
    IF NEW.stato = 'Pendente' AND EXISTS (
        SELECT 1
        FROM `Gestazione` 
        WHERE 
            T.madre = NEW.madre AND
            T.stato = 'In corso'
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Una gestazione risulta tutt\'ora in corso!';
    END IF;
END;;

CREATE TRIGGER `chk_TentativoRip_UPDATE`
BEFORE UPDATE ON `Tentativo di riproduzione` FOR EACH ROW
BEGIN
    IF(NEW.madre <> OLD.madre OR NEW.padre <> OLD.padre)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'È vietato cambiare i genitori!';
    END IF;
END;;

/** Su Gestazione **/
CREATE TRIGGER `auto_Gestazione_INSERT`
AFTER INSERT ON `Gestazione` FOR EACH ROW
BEGIN
    -- Metto a successo il tentativo associato
    UPDATE `Tentativo di riproduzione` TR
    SET TR.stato = 'Successo'
    WHERE 
        TR.madre = NEW.madre AND
        TR.`data` = NEW.`data concepimento`;
END ;;

CREATE TRIGGER `chk_Gestazione_UPDATE`
BEFORE UPDATE ON `Gestazione` FOR EACH ROW
BEGIN
    -- Controllo parto
    IF NOT(NEW.stato = 'Conclusa' XOR EXISTS(
        SELECT 1
        FROM Parto P
        WHERE 
            P.madre = NEW.madre AND 
            P.`data concepimento` = NEW.`data concepimento`
    ))
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Se è solo se è conlusa allora ha partorito!';
    END IF;
END;;

/** Se metto Parto ALLORA SUCCESSO! 
    Lo metto BEFORE INSERT cosicché l'update su Gestazione fallisce, perché ad esempio è registrato un
    abort, allora l'inserimento esce
**/
CREATE TRIGGER `auto_Parto_INSERT` 
BEFORE INSERT ON Parto FOR EACH ROW
BEGIN 
    UPDATE Gestazione G
    SET G.stato = 'Conclusa'
    WHERE 
        G.`data concepimento` = NEW.`data concepimento` AND
        G.madre = NEW.madre;
END;;

/** Inseirmento di  **/
CREATE TRIGGER `chk_esame_diagnostico_INSERT`
BEFORE INSERT ON `Esame diagnostico` FOR EACH ROW
BEGIN
    -- Deve avere esito negivativo
    IF NOT(
        SELECT PVC.esito = 'Negativo'
        FROM `Programmazione visita di controllo` PVC
        WHERE
            PVC.`data concepimento` = NEW.`data visita programmata` AND
            PVC.madre = NEW.madre AND
            PVC.`data visita programmata` = NEW.`data concepimento` 
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Esami diagnostici possono essere inseriti se e solo se l\'esito è negativo';
    END IF;
END;;

/** VINCOLO SU VISITA DI CONTROLLO 
La madre deve essere l'animale visitato nella visita associata
**/
CREATE TRIGGER `chk_progVisitaControllo_INSERT` 
BEFORE INSERT ON `Programmazione visita di controllo` FOR EACH ROW
BEGIN
    IF NEW.`visita di controllo` IS NOT NULL AND(
        SELECT VC.animale <> NEW.madre
        FROM `Visita di controllo` VC
        WHERE VC.id = NEW.`visita di controllo`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La visita associata non è dello stesso animale!!';
    END IF;
END;;

CREATE TRIGGER `chk_progVisitaControllo_UPDATE` 
BEFORE UPDATE ON `Programmazione visita di controllo` FOR EACH ROW
BEGIN
    IF NEW.`visita di controllo` IS NOT NULL AND NEW.`visita di controllo` <> OLD.`visita di controllo` AND(
        SELECT VC.animale <> NEW.madre
        FROM `Visita di controllo` VC
        WHERE VC.id = NEW.`visita di controllo`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La visita associata non è dello stesso animale!!';
    END IF;
END;;

/** VINCOLI SU SOVRAPOSIZIONE DELLE AREE DI ZONA PASCOLO
Le aree di pascolo non si sovrappongono
REF: https://dev.mysql.com/doc/refman/8.0/en/spatial-relation-functions-object-shapes.html

 Two geometries spatially touch if their interiors do not intersect, but the boundary of one of 
 the geometries intersects either the boundary or the interior of the other. 
 **/
CREATE TRIGGER `chk_zona_INSERT` 
BEFORE INSERT ON `Zona pascolo` FOR EACH ROW
BEGIN
    -- Controllo se sovrappongono tra loro. È ammesso che abbiano i margini condivisi
    IF EXISTS(
        SELECT 1
        FROM `Zona pascolo` ZP
        WHERE st_intersects(ZP.confine, NEW.confine) AND NOT st_touches(ZP.confine, NEW.confine)
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Attenzione dei recinti si interesecano!';
    END IF;
END;;

CREATE TRIGGER `chk_zona_UPDATE` 
BEFORE UPDATE ON `Zona pascolo` FOR EACH ROW
BEGIN
    -- Controllo se sovrappongono tra loro
    IF EXISTS(
        SELECT 1
        FROM `Zona pascolo` ZP
        WHERE
            ZP.id <> NEW.id AND
            st_intersects(ZP.confine, NEW.confine) AND NOT st_touches(ZP.confine, NEW.confine)
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Attenzione dei recinti si toccano!';
    END IF;
END;;

/** Vincolo sui pascoli
1. I pascoli sulla medesima zona sono distanziati di 30 minuti **/

CREATE TRIGGER `chk_Pascolo_INSERT`
BEFORE INSERT ON `Pascolo` FOR EACH ROW
BEGIN
    IF NOT (
        SELECT S.agriturismo
        FROM Locale L
            INNER JOIN Stalla S ON S.id = L.stalla
        WHERE L.id = NEW.locale
    ) = (
        SELECT 1
        FROM `Zona pascolo` ZP
        WHERE ZP.id = NEW.`zona pascolo`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La zona non è nel medesimo agriturismo';
    END IF;
    
    IF ((
        WITH `PP` AS
        (
            WITH `PascoloOrdinato` AS
            (
                SELECT P.`ora inizio` AS `start`, P.`ora fine` AS `end`
                FROM Pascolo P
                WHERE P.zona = NEW.`zona pascolo`
                ORDER BY P.`ora inizio` DESC
            )
            SELECT `end` - LAG(`start`, 1) over () AS `differenza`
            FROM PascoloOrdinato PO
        )
        SELECT IFNULL(MIN(`differenza`), 500) AS `distanza minima`
        FROM PP
    ) <= 30)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'I pascoli devono almere 31 minuti di stacco sulla stessa zona';
    END IF;
    
    IF ((
        WITH `PP` AS
        (
            WITH `PascoloOrdinato` AS
            (
                SELECT P.`ora inizio` AS `start`, P.`ora fine` AS `end`
                FROM Pascolo P
                WHERE P.locale = NEW.locale
                ORDER BY P.`ora inizio` DESC
            )
            SELECT `end` - LAG(`start`, 1) over () AS `differenza`
            FROM PascoloOrdinato PO
        )
        SELECT IFNULL(MIN(`differenza`), 500) AS `distanza minima`
        FROM PP
    ) <= 30)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'I pascoli devono almere 31 minuti di stacco sullo stesso locale';
    END IF;
END;;

CREATE TRIGGER `chk_Pascolo_UPDATE`
BEFORE UPDATE ON `Pascolo` FOR EACH ROW
BEGIN
    IF NOT (
        SELECT S.agriturismo
        FROM Locale L
            INNER JOIN Stalla S ON S.id = L.stalla
        WHERE L.id = NEW.locale
    ) = (
        SELECT 1
        FROM `Zona pascolo` ZP
        WHERE ZP.id = NEW.`zona pascolo`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La zona non è nel medesimo agriturismo';
    END IF;

    IF ((
        WITH `PP` AS
        (
            WITH `PascoloOrdinato` AS
            (
                SELECT P.`ora inizio` AS `start`, P.`ora fine` AS `end`
                FROM Pascolo P
                WHERE 
                    P.`zona pascolo` = NEW.`zona pascolo` AND
                    P.`ora inizio` <> NEW.`ora inizio` AND
                    P.locale <> NEW.locale
                ORDER BY P.`ora inizio` DESC
            )
            SELECT DIFF(`end`, LAG(`start`, 1) over ()) AS `differenza`
            FROM PascoloOrdinato PO
        )
        SELECT IFNULL(MIN(`differenza`), 500) AS `distanza minima`
        FROM PP
    ) <= 30)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'I pascoli devono almere 31 minuti di stacco sulla stessa zona';
    END IF;
    
    IF ((
        WITH `PP` AS
        (
            WITH `PascoloOrdinato` AS
            (
                SELECT P.`ora inizio` AS `start`, P.`ora fine` AS `end`
                FROM Pascolo P
                WHERE P.locale = NEW.locale AND P.`ora inizio` <> NEW.`ora inizio`
                ORDER BY P.`ora inizio` DESC
            )
            SELECT TIMEDIFF(`end`, LAG(`start`, 1) over ()) AS `differenza`
            FROM PascoloOrdinato PO
        )
        SELECT IFNULL(MIN(`differenza`), 500) AS `distanza minima`
        FROM PP
    ) <= 30)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'I pascoli devono almere 31 minuti di stacco sullo stesso locale';
    END IF;
END;;

/** Vincolo prenotazione. Si SOLO possono prenotare stanze del medesimo agriturismo**/
CREATE TRIGGER `chk_prenotazione_INSERT` 
BEFORE INSERT ON `Prenotazione stanza` FOR EACH ROW
BEGIN
    
END;;

/** Vincolo su Prenotazione servizio & CO.
tuple ammesse se si sono prenotate suites **/
CREATE TRIGGER `chk_servizi0` 
BEFORE INSERT ON `Prenotazione servizio` FOR EACH ROW
BEGIN
    -- No suite => No prenoti
    IF NOT EXISTS (
        SELECT 1
        FROM `Prenotazione stanza` PSA
            INNER JOIN `Stanza` S ON S.`numero stanza` = PSA.`numero stanza` AND S.agriturismo = PSA.agriturismo
        WHERE
            PSA.utente = NEW.`utente` AND PSA.`data arrivo` = NEW.`data arrivo` AND
            -- È una suite
            S.`tipologia stanza` = 'Suite'
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'È vietato prenotare servizi se prima non si prenotato SUITE';
    END IF;
END;;

CREATE TRIGGER `chk_servizi1`
BEFORE DELETE ON `Prenotazione stanza` FOR EACH ROW
BEGIN
    -- Controllo se ci sono altre Suite in questa prenotazione
    DECLARE hasSuitesLeft BOOLEAN DEFAULT EXISTS (
        SELECT 1
        FROM `Prenotazione stanza` PSA
            INNER JOIN `Stanza` S ON S.`numero stanza` = PSA.`numero stanza` AND S.agriturismo = PSA.agriturismo
        WHERE
            PSA.utente = OLD.`utente` AND PSA.`data arrivo` = OLD.`data arrivo` AND
            -- È una suite
            S.`tipologia stanza` = 'Suite' AND
            -- Non è la suite da eliminare. Una prenotazione dovrebbe avere 1 agriturismo!
            PSA.`numero stanza` <> OLD.`numero stanza`
    );
    
    -- Se ha servizi AND NOT ha suite allora elevo un errore
    IF NOT hasSuitesLeft AND EXISTS (
        SELECT 1
        FROM `Prenotazione servizio` PS
        WHERE PS.utente = OLD.utente AND PS.`data arrivo` = OLD.`data arrivo`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossibile elimare. Dei servizi prenotati pendono!\nEliminare dapprima i servizi!';
    END IF;
END;;


/**** VINCOLO SULLA SPEDIZIONE TERMINATA *****/
CREATE TRIGGER `chk_passaggio_sped_INSERT`
BEFORE INSERT ON `Passaggio` FOR EACH ROW
BEGIN
    IF (
        SELECT S.stato IN ('In consegna', 'Consegnato')
        FROM Spedizione S 
        WHERE S.codice = NEW.`codice spedizione`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Questa spedizione è già terminata!';
    END IF;
END;;

/**** VINCOLO SULLE FORME NON STAGIONABILI ***/
CREATE TRIGGER `chk_forma_stipata_cantina_INSERT`
BEFORE INSERT ON Forma FOR EACH ROW
rowss: BEGIN
    DECLARE hasStagionatura BOOLEAN DEFAULT FALSE;
    DECLARE isCantina       BOOLEAN DEFAULT FALSE;
    
    -- Se non è stipato allora esco...
    IF NEW.`stato` <> 'Conservato' 
    THEN
        LEAVE rowss;
    END IF;
    
    SET hasStagionatura = (
        SELECT R.stagionatura > 0
        FROM Ricetta R
        WHERE R.`prodotto caseario` = NEW.`tipologia prodotto`    
    );
    
    SET isCantina = (
        SELECT L.tipo = 'Cantina'
        FROM `Locale stoccaggio` L
        WHERE L.id = NEW.`locale stoccaggio`  
    );
    
    IF(NOT(isCantina XOR hasStagionatura))
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'stagionatura ⇔ Locale.tipo = \'Cantina\'';
    END IF;
END;;

/****** Numero passi ricetta ****/
CREATE TRIGGER `chk_passo_ricetta_INSERT` 
BEFORE INSERT ON Passo FOR EACH ROW
rowss: BEGIN
    DECLARE max_passo TINYINT UNSIGNED DEFAULT 0;

    IF NEW.`numero passo` = 0 THEN
        LEAVE rowss;
    END IF;
    
    SET max_passo = (
        SELECT MAX(P.`numero passo`)
        FROM Passo P
        WHERE P.ricetta = NEW.ricetta
    );
    
    -- Se supero la distanza errore
    IF NEW.`numero passo` - max_passo > 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'NEW.passo ≠ 0 ⇔ ∃P ∈ {ricetta} : P.passo - NEW.passo = 1';
    END IF;
END;;

/******* CONTROLLO SESSO ANIMALE MUNTO *******/
CREATE TRIGGER `chk_mungitura_female_INSERT`
BEFORE INSERT ON `Prodotto mungitura` FOR EACH ROW
BEGIN
    IF (
        SELECT A.sesso <> 'Femmina'
        FROM Animale A
        WHERE A.id = NEW.animale
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'È vietato mungere animale di sesso maschile!!';
    END IF;
END;;

/***********************************************************
 *
 *                  DOPO RISTRUTTURAZIONE
 *
 *
 ***********************************************************/
 
/********* Tipo animale ***/
CREATE TRIGGER `chk_animale_tipo` 
BEFORE INSERT ON `Acquistato` FOR EACH ROW
BEGIN
    -- È nato in casa?
    IF(
        SELECT A.tipo = 'Nato in casa'
        FROM Animale 
        WHERE A.id = NEW.animale
    )
    -- Se sì non è stato acquistato!
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L\'animale è nato in casa, ma si sta cercando di aggiungere su esso informazione sull\'acquisto ';
    END IF;
END;;

CREATE TRIGGER `chk_parto`
BEFORE INSERT ON Parto FOR EACH ROW
BEGIN
    -- È stato acquistato ?
    IF(
        SELECT A.tipo = 'Acquistato'
        FROM Animale 
        WHERE A.id = NEW.animale
    )
    -- Se sì non è stato partorito da un animale di FarmHouse 
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L\'animale è stato acquistato, ma si sta cercando di aggiungere su esso informazioni sul parto!';
    END IF;
END;;

/**** I portali d'accesso facciano parte del perimetro del polygon ***/
CREATE TRIGGER `chk_portali_INSERT`
BEFORE INSERT ON `Portale accesso pascolo` FOR EACH ROW
BEGIN
    IF NOT (
        SELECT st_touches(ZP.confine, NEW.posizione)
        FROM `Zona pascolo` ZP
        WHERE ZP.id = NEW.`zona pascolo`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il punto inserito non appartiene alla frontiera della zona pascolo';
    END IF;
END;;

CREATE TRIGGER `chk_portali_UPDATE`
BEFORE UPDATE ON `Portale accesso pascolo` FOR EACH ROW
BEGIN
    IF NOT (
        SELECT st_touches(ZP.confine, NEW.posizione)
        FROM `Zona pascolo` ZP
        WHERE ZP.id = NEW.`zona pascolo`
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il punto inserito non appartiene alla frontiera della zona pascolo';
    END IF;
END;;

/******* Stanze semplici hanno un solo letto singolo! ****/
CREATE TRIGGER `chk_letti_stanza_semplice_INSERT`
BEFORE INSERT ON `Composizione stanze` FOR EACH ROW
rowss: BEGIN
    -- Se è una suite allora via libera (/)
    IF (
        SELECT S.`tipologia stanza` <> 'Semplice'
        FROM Stanza S
        WHERE S.`numero stanza` = NEW.`numero stanza` AND S.agriturismo = NEW.agriturismo
    ) THEN
        LEAVE rowss;
    END IF;
    
    -- Se è in quantità diversa da uno, errore
    IF NEW.`quantità` <> 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'In una stanza semplice v\'è solamente UN letto singolo';
    END IF;
    
    -- Se ci sono altri letti installati, errore
    IF EXISTS(
        SELECT 1
        FROM `Composizione stanze` CS
        WHERE CS.agriturismo = NEW.agriturismo AND CS.`numero stanza` = NEW.`numero stanza`
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Altri letti sono già installati in questa stanza tipo semplice';
    END IF;
    
    -- Se non è un letto singolo allora errore
    IF (
        SELECT TL.`capacità` > 1
        FROM `Tipologia letto` TL
        WHERE TL.tipo = NEW.tipo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il letto di una stanza semplice alloggia à capacità uno';
    END IF;
END;;

CREATE TRIGGER `chk_letti_stanza_semplice_UPDATE`
BEFORE INSERT ON `Composizione stanze` FOR EACH ROW
BEGIN
    IF(
        -- Il valore quantità è stato modificato
        NEW.`quantità` <> OLD.`quantità` AND
        
        -- Il valore è diverso da uno
        NEW.`quanità` <> 1 AND
        
        -- È una semplice
        (
            SELECT S.`tipologia stanza` <> 'Semplice'
            FROM Stanza S
            WHERE S.`numero stanza` = NEW.`numero stanza` AND S.agriturismo = NEW.agriturismo
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'In una stanza semplice v\'è solamente UN letto singolo';
    END IF;
END;;

/** I sensori cantina sono installati solo in locali tali che la tipologia sia Cantina **/
CREATE TRIGGER `chk_sensori_cantina_INSERT`
BEFORE INSERT ON `Sensore cantina` FOR EACH ROW
BEGIN
    IF NOT (
        SELECT L.tipo = 'Cantina'
        FROM `Locale stoccaggio` L
        WHERE L.id = NEW.`locale stoccaggio`
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installare questo sensore in una cantina!';
    END IF;
END;;

CREATE TRIGGER `chk_sensori_cantina_UPDATE`
BEFORE INSERT ON `Sensore cantina` FOR EACH ROW
BEGIN
    IF NEW.`locale stoccaggio` <> OLD.`locale stoccaggio` AND NOT (
        SELECT L.tipo = 'Cantina'
        FROM `Locale stoccaggio` L
        WHERE L.id = NEW.`locale stoccaggio`
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installare questo sensore in una cantina!';
    END IF;
END;;

/*** Forma.stato = acquisto <=> fa parte di un ordine ****/
CREATE TRIGGER `chk_forma_acquisto_UPDATE`
BEFORE UPDATE ON `Forma` FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM `Composizione ordine` CO
        WHERE CO.`forma di formaggio` = NEW.id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inserire la forma prima nella composizione di un ordine e poi cambiare il flag!';
    END IF;
END;;