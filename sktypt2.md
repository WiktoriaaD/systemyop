Napisz skrypt w Pythonie, który:

  - tworzy na nowo plik o nazwie podanej jako argument,
  - co sekundę dodaje do niego nową linię, która zawiera jej numer (można liczyć od zera).

Uruchom skrypt w jednym terminalu i go nie wyłączaj. Sprawdź, czy linie są faktycznie dopisywane.
Z drugiego terminala usuń ten nowy plik. Jak bezinwazyjnie odzyskać jego zawartość? Zapisz swoje notatki w oddzielnym pliku tekstowym.

---
Skrypt skrypt2.py tworzy i otwiera plik w trybie dopisywania, następnie w nieskończonej pętli co sekundę dodaje nową linię z kolejnym numerem.
Gdy plik zostanie usunięty komendą `rm` system operacyjny przechowuje dane fizycznie na dysku tak długo, jak proces pozostaje aktywny.
Zapisane dane są nadal dostępne przez system plików `/proc`.


## Jak mozemy bezinwazyjnie odzyskac zawartosc krok po kroku

Uruchamiamy skrypt

`skrypt2.py plik.txt`


Terminal 2 - usuń plik

`rm moj_plik.txt`


Znajdź PID procesu

`ps aux | grep skrypt2.py`


Sprawdź liczbe przy pliku (deleted)

`ls -la /proc/PID/fd/`


Odczytaj zawartość przez liczbe

`cat /proc/PID/fd/x`
