/** OPERAZIONE 10 : AUTENTICAZIONE DI UN UTENTE**/

SELECT @PWD = C.`parola d'ordine` AS 'Autenticazione corretta'
FROM Credenziali C
WHERE C.`nome utente`=@username 
