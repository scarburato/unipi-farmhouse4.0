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
            C.`tipo foraggio` = `tipoforaggio` AND
            C.`tipo alimento` = `tipoalimento`
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