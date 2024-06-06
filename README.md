### Opis UI do systemu bankowego

To repozytorium zawiera kod UI dla systemu bankowego stworzonego w Lua. Kod został dostosowany do współpracy z interfejsem (UI).

### Elementy interfejsu użytkownika:

1. **Strona logowania**: Użytkownik jest proszony o podanie PIN-u w celu uwierzytelnienia się. Możliwe jest także wylogowanie się z systemu.
   
2. **Strona główna**: Po zalogowaniu użytkownik zostaje przekierowany do strony głównej, na której wyświetlane są informacje o stanie konta oraz historia transakcji.
   
3. **Wpłacanie środków**: Użytkownik ma możliwość wpłacenia środków na swoje konto bankowe poprzez wpisanie odpowiedniej kwoty.

4. **Wypłacanie środków**: Możliwość wypłacenia środków z konta bankowego poprzez podanie odpowiedniej kwoty.

5. **Przelew środków**: Umożliwia przelanie środków na konto innego użytkownika, poprzez podanie identyfikatora odbiorcy oraz kwoty przelewu.

6. **Ustawienia**: W tym module użytkownik może zmienić swój PIN.

### Funkcjonalności:

- Obsługa wprowadzania PIN-u.
- Wpłacanie i wypłacanie środków z konta.
- Przeglądanie historii transakcji.
- Możliwość przeprowadzenia przelewu na konto innego użytkownika.

### Wymagania:

- Kod Lua, który jest częścią systemu bankowego ESX.
- Środowisko uruchomieniowe ESX.

## Licencja
Projekt jest dostępny na licencji MIT. Zobacz plik `LICENSE` po więcej informacji.
