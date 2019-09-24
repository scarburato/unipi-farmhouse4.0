/** POPOLO PARTE DELLA ZONA VERDE PER LA SECONDA ANALYTIC **/

INSERT INTO Agriturismo(id,nominativo) VALUES
(1,'Beppe');

INSERT INTO `Locale stoccaggio`(id,tipo) VALUES
(1,'Cantina');

INSERT INTO Lotto(codice,agriturismo,`data di scadenza`,`laboratorio`,`durata processo produttivo`) VALUES
('AAA111',1,'2019-11-03 12:00:00','LAB 1',3),
('CBA213',1,'2019-10-03 12:00:00','LAB 3',4),
('ACA532',1,'2019-12-03 12:00:00','LAB 2',2);

INSERT INTO `Prodotto caseario`(nome,`grado di deperibilità`,tipologia) VALUES
('Pecorino salato','Alto','Pasta dura'),
('Mozzarella','Medio','Pasta dura'),
('Crescenza','Basso','Pasta molle');

INSERT INTO `Forma`(id,`tipologia prodotto`,stato,peso,`locale stoccaggio`,`codice lotto`,`agriturismo del lotto`) VALUES
(1,'Pecorino salato','Conservato',6,1,'AAA111',1),
(2,'Mozzarella','Scaduto',5,NULL,'CBA213',1),
(3,'Crescenza','Acquistato',4,NULL,'AAA111',1);

INSERT INTO Ricetta(`Prodotto caseario`,stagionatura,`zona geografica`)VALUES
('Pecorino salato',2,'Valtellina'),
('Mozzarella',1,'Liguria'),
('Crescenza',2,'Veneto');

INSERT INTO Parametro(nome,`unità di misura`) VALUES
('acidità del latte','ph'),
('peso della forma','grammi'),
('temperatura del latte','celsius'),
('tempo di riposo','secondi');

INSERT INTO Passo(ricetta,`numero passo`, descrizione, durata) VALUES
('Pecorino salato',0,'Tenere il pecorino in un forno',7),
('Mozzarella',0,'Usare un mattarello per impastare',3),
('Crescenza',0,'Pesare la pasta',1),
('Mozzarella',1,'Misurare l acidità del latte',1);

INSERT INTO Aspettativa(parametro,ricetta,`numero passo`,`valore atteso`) VALUES
('temperatura del latte','Pecorino salato',0,20),
('tempo di riposo','Mozzarella',0,10000),
('acidità del latte','Crescenza',0,4),
('peso della forma','Mozzarella',1,4);


INSERT INTO `Valore reale`(forma,parametro,ricetta,`numero passo`,`valore letto`) VALUES
(1, 'temperatura del latte','Pecorino salato',0,15),
(2, 'tempo di riposo','Mozzarella',0,10000),
(3, 'peso della forma','Crescenza',0,5),
(2, 'acidità del latte','Mozzarella',1,2);



