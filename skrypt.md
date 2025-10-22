Sprawdź ile pamięci (szczytowo, tj. maximum resident set size) wykorzystuje program ps -eo user,pid,comm napisany w języku C, a ile Twój skrypt uruchamiany w interpreterze Pythona (można użyć GNU Time). Jak to wygląda procentowo? Zapisz swoje notatki w oddzielnym pliku tekstowym.

# Porównanie zużycia pamięci: `ps -eo user,pid,comm` vs `ps_like.py`


Porównanie szczytowego zużycia pamięci RAM (Maximum resident set size) pomiędzy: 
programem systemowym `ps -eo user,pid,comm` napisanym w C, a skryptem w Pythonie (`ps_like.py`), który realizuje to samo zadanie korzystając z `/proc`

## Sposób pomiaru
Do pomiaru wykorzystano narzędzie GNU Time:

```bash
/usr/bin/time -v ps -eo user,pid,comm
/usr/bin/time -v python3 skrypt.py
```
**Program C**  
  `Maximum resident set size (kbytes): 4712`

**Skrypt Python**  
  `Maximum resident set size (kbytes): 9788`

#### Różnica procentowa:
`(9788-4712)/4712*100%=107.7%`

`Skrypt Python zużywa 107.7% więcej pamięci niż program w C.`
