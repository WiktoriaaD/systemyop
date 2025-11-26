**1. Wypisz nagłówek (pierwszą linię) z iris.csv.**

`head -n 1 iris.csv`

**2. Wypisz wszystkie linie oprócz pierwszej z iris.csv (podpowiedź: skorzystaj z man tail).**

`tail -n +2 iris.csv`

**3 Zamień gatunki na liczby (wyświetl poprawione linie, nie zmieniaj treści pliku):**

        “Setosa” na 1,
        “Versicolor” na 2,
        “Virginica” na 3.

`sed -e 's/"Setosa"/1/g' -e 's/"Versicolor"/2/g' -e 's/"Virginica"/3/g' iris.csv`

**4  Wypisz dostępne rodzaje irysów bez powtórzeń i bez cudzysłowów.**

`tail -n +2 iris.csv | cut -d, -f5 | tr -d '"' | uniq`

**5 Oblicz sumę wartości dla każdego wiersza.**

`awk -F, 'NR>1 {print $1 + $2 + $3 + $4}' iris.csv`

**6 Oblicz średnią wartość drugiej kolumny (sepal.width).**

`awk -F, 'NR>1 {total+= $2; lines++} END {print lines/total}' iris.csv`

**7 Wypisz całą linię, która ma maksymalną wartość czwartej kolumny (petal.width).**

`awk -F, 'NR>1 {if($4>max){max=$4;line=$0}} END {print line}' iris.csv` 

**8 Wypisz nazwę gatunku Irysa, którego pierwsza kolumna (sepal.length) jest większa niż 7.**

`awk -F, 'NR>1 {if($1>7){print $5}}' iris.csv`

**9 Przeformatuj plik CSV korzystając z printf w awk na pola oddzielone tabulatorami obcinając liczby do całkowitych.**

5       4       1       0       "Setosa"

`awk -F, 'NR>1 {printf "%.0f\t%.0f\t%.0f\t%.0f\t%s\n", $1, $2, $3, $4, $5}' iris.csv`

**10 Zmień losowo kolejność wierszy z danymi o irysach i zapisz je w nowym pliku CSV z nagłówkiem.**

 `{ head -n 1 iris.csv; tail -n +2 iris.csv | shuf; } > irisrandom.csv`
