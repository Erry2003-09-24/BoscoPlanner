# BoscoPlanner

BoscoPlanner è un’app frontend progettata per supportare gli operatori nella gestione della filiera bosco-legno. Consente di monitorare e registrare direttamente sul campo le principali attività di piantumazione e taglio degli alberi, fornendo informazioni in tempo reale sulla posizione GPS e sulle condizioni meteo, per facilitare decisioni sia su quando piantare un albero che su quando tagliarlo. Grazie alla registrazione in locale degli interventi mediante shared_prefereces, l’app permette di mantenere uno storico delle operazioni svolte (sia piantumazione che taglio), migliorando la tracciabilità e l’organizzazione delle attività forestali.

## Funzionalità principali dell'app

- **Splash Screen**  
  Visualizza il logo dell'app (un'icona di un albero) con il titolo “BoscoPlanner” e una semplice transizione automatica alla Home dopo una durata stabilita.

- **Home Page**  
  Mostra la posizione attuale (latitudine e longitudine) e il meteo corrente tramite API OpenWeatherMap.  
  Contiene i pulsanti per consentire agli operatori di effettuare le seguenti operazioni:
  🌱 Pianta un albero (salva posizione)  
  🪓 Taglia un albero (mostra meteo e richiede conferma)  
  📜 Storico operazioni (mostra lista cronologica)

- **Schermata “Pianta un albero”**  
  Rileva la posizione GPS attuale, mostra una conferma e salva localmente l’evento con flag “piantato”, una data e una posizione.

- **Schermata “Taglia un albero”**  
  Ottiene posizione e meteo attuale, se il meteo è favorevole indica “Condizioni favorevoli per il taglio” e salva localmente l’intervento, se invece il meteo non è favorevole indica "Condizioni meteo NON favorevoli"

- **Storico operazioni**  
  Visualizza una lista delle operazioni salvate localmente con tipo (piantato/tagliato), data e posizione. I due flag che indicano l'operazione effettuata sull'albero, hanno il colore verde se l'albero è stato piantato, rosso se invece è stato tagliato.


