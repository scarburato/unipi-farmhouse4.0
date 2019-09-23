/** Area rossa <-> gialla **/

-- Relazione ammette
ALTER TABLE `Locale` ADD
    FOREIGN KEY (`specie ammessa`) REFERENCES Specie(nome);
    
-- Relazione allogiato
ALTER TABLE `Animale` ADD
    FOREIGN KEY (locale) REFERENCES Locale(id);
    
-- Relazione Allestimento ideale
ALTER TABLE `Allestimento ideale` ADD
    FOREIGN KEY (specie) REFERENCES Specie(nome);

-- Relazione LocazioneA
ALTER TABLE `Storico posizioni` ADD
    FOREIGN KEY (animale) REFERENCES Animale(id);

/** Area rossa <-> verde **/
ALTER TABLE `Prodotto mungitura` ADD
    FOREIGN KEY (munto) REFERENCES Animale(id);

/** Area blu <-> gialla **/

-- Relazione stalle possedute
ALTER TABLE `Stalla` ADD
    FOREIGN KEY (`agriturismo`) REFERENCES Agriturismo(id);
    
/** Area blu <-> verde **/
-- Relazione mungitrice di proprietàALTER
ALTER TABLE `Mungitrice` ADD
    FOREIGN KEY (`proprietario`) REFERENCES Agriturismo(id);
    
-- Relazioone proprietà del lotto
ALTER TABLE `Lotto` ADD
    FOREIGN KEY (`agriturismo`) REFERENCES Agriturismo(id);
    
ALTER TABLE `Composizione ordine` ADD
    FOREIGN KEY (`forma di formaggio`) REFERENCES Forma(id);
    
ALTER TABLE `Carrello` ADD
    FOREIGN KEY (`prodotto caseare`) REFERENCES `Prodotto caseario`(nome);
