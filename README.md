# Grafik

## Todo

- [DONE] Projekt -> Zamówienia
- [DONE] Wywalamy "do odbioru"
- [DONE] kolory
  - [DONE] odebrane - niebieski
  - [DONE] wysłane - szary
- [DONE] klient
  - [DONE] adres do faktury (nazwa ulica kod miasto nip)
  - [DONE] adres do wysyłki (nazwa ulica kod miasto, telefon dla kuriera, nazwisko osoby kontaktowej, email)
  - dodać nazwę skróconą i nazwę długą
- [DONE] projekty
  - [DONE] deadline -> termin
  - [DONE] numer faktury/oferty
  - [DONE] kwota za zamówienie
  - [DONE] ile zapłacono
  - [DONE] data rozpoczęcia zlecenia
  - [DONE] sztywny termin
  - [DONE] sztywny termin na czerwono
- [DONE] breadcrumbs
- [DONE] data wysłania zadania (produktu)
- [DONE] automatycznie ustawiana data zmiany statusu zadania na wysłane
- [DONE] wydruk dla pracownika
 - [DONE] nazwa zlecenia i klienta i termin
   - [DONE] lista zadań do wykonania
- [DONE] wywalić "description" z produktów
- [DONE] na liście zadań pracownika:
  - [DONE] guzik "print", który by otwierał w nowym oknie wykaz zadań bez menu itp... no i odpalał window.print()
  - [DONE] upewnić się, że nie ma zadań z zarchiwizowanych projektów
  - [DONE] sortowanie po dacie oddanie
- [DONE] dashboard
  - [DONE] dużo rekordów na raz w dashboard. wszystko ścieśnić
  - [DONE] przejście do widoku projektu
  - [DONE] przejście do widoku klienta
  - [DONE] szukanie po tekście / filtrowanie po tekście. po wpisaniu niech się pokaże cały projekt, który ma zadanie z wybranym tekstem. Projekty bez zdań z danym tekstem mają się nie wyświetlać
  - [DONE] wyłączyć cache przy pobieraniu projektów bo jest błąd: dodaj zadanie, przejdź na zlecenie i nacisnij wstecz. nowo dodane zadanie się nie wyświetli 
  - [DONE] focus w modal i submit w modal prompt
- [DONE] breadcrumbs ma błędy. np: 
  - [DONE] w edycji pracownika jest nazwa zadania zamiast "edytuj", 
  - [DONE] lub w widoku pracownika jest link do zlecen a nie do listy pracowników
  - [DONE] przejrzeć resztę breadcrumbs
- [DONE] wywalić duplikaty z modelu w dashboard - single source of trueth for clients and for workers assigned to tasks
- [DONE] przejść na korzystanie z erlang release
- [DONE] na czerwono projekty ze sztywnym terminem również w dashboard
- [DONE] upewnić się, ze w dashboard projekty są posortowane po terminach
- [DONE] Dodaj zadanie -> Dodaj produkt
- [DONE] dodawanie zlecenia z jednego formularza to znaczy wszystko: klienta i produkty
- [DONE] pole uwagi do zlecenia
- wywalić zakładkę "zlecenia" i cały kod z tym związany
- backupy
- na przyszłość: sumowanie: wartość zamówień XXX, zapłacono: YYY (ale nie sumować zarchiwizanych)
- daty nie powinny mieć godzin
- wyświetlać gdzieś date wysłania

- w wydruku termin w tej samej lini co klient ale dać do prawego marginesu przytulone
- w edycji zamówienia zrobić aby "Termin (DD-MM-YYYY)" zawsze się wyświetlał a gdy jest błąd aby był na czerwono

    Możliwość tworzenia przyciskiem kopii zapasowej - w razie czego (robimy codzienne backupy (pgdump) na inny serwer)
    raz dziennie wysyłać ewie maila ze zrzutem nie archiwalnych zleceń i wszystkimi zadaniami
    Możliwość wprowadzania całości zamówienia pracując w jednym formularzu
    MOżliwość skopiowania wprowadzonych danych do faktury w pola ADRES DOSTAWY jeżeli oba będą takie same
    Jeżeli wybierzemy status "wysłane" to przyda się pole gdzie można by było wpisać np. kurier DHL dnia 10 lipca
    W zakładce zamówienia niech się wyświetla jedynie nazwa zadania bez nazwy klienta
    Czy na wydruku dla pracowników sztywne daty zaznaczone na czerwono będą drukowały się też na czerwono?
    Jeżeli całe zlecenie będzie miało wszystkie zadania o statusie WYSŁANO to nie powinno być już widoczne na liście bo z czasem będzie za dużo przewijania w poszukiwaniu zleceń będących w trakcie. Powinno takie zlecenie trafić do jakiegoś ARCHIWUM 
    W terminach wyrzucić godziny i minuty bo zamydlają obraz
    Szukanie działa wpisując wyrób ale często szukamy nazw zamówień lub klienta
    W GRAFIKU dobrze by było aby był widoczny: TERMIN, NR FAKTURY, CENA, ILE ZAPŁACONO
    W GRAFIKU przyda się opcja rozwijania całości (wszystkich zamówień jednocześnie aby były widoczne produkty)
    Grubszą czcionką nazwy klientów i zamówień a cieńszą nazwy pól czyli np. Klient. Jest teraz odwrotnie.
    po wpisaniu numeru oferty lub faktury wypełniają się całe zamówienie i zadania
- dodaj "start_at" w dashboard do projektów
