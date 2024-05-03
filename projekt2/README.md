Autor: Šimon Kadnár  
Login: xkadna00  
Dátum: 27.4.2024  
Zdanie: Kostra grafu

**Riešenie (generovanie všetkých kombinácií a následné hladanie tých ktoré necyklia):**
1. Program načíta vstup z príkazového riadku.
2. Vstup sa spracuje na pole dvojíc vrcholov, napr. A B\n B C -> [(A,B), (B,C)].
3. Odstránia sa opačné dvojice, napr. [(A,B), (B,A)] -> [(A,B)].
4. Z vytvoreného poľa sa vyberú vrcholy, s ktorými sa bude pracovať, napr. [(A,B), (B,C)] -> [A, B, C].
5. Z unikátnych dvojíc sa vytvoria jedinečné kombinácie (podgrafy) o dĺžke, ktorá odpovedá počtu vrcholom.
6. Prejdú sa všetky podgrafy a pokiaľ v konkrétnom podgrafe nevzniká cyklus, vypíše sa na výstup.
    1. Určenie, že podgraf neobsahuje cyklus:
        - Pre všetky vrcholy sa otestuje, či neexistuje cesta, ktorou by vznikol cyklus.
    2. Rekurzívne sa berie vždy prvá dvojica z podgrafu a zistí sa, či jej vrcholy sa nachádzajú v zozname navštívených vrcholov.
        - Ak nie, pridá sa do zoznamu navštívených vrcholov a rekurzívne sa prezerajú zvyšné dvojice.
        - Ak áno, hľadanie končí a podgraf nie je vypísaný na výstup, pretože obsahuje cyklus.

**Spúštanie:** 
- Najskôr je potrebné urobiť preklad pomocov makefilu `make`
- Príklad sputenia `./flp23-log < vstupny_subor`  
- Spustenie s jedným z pribalených vstupných súborov `./flp23-log < test_data/input1.txt`

**Rozšírenie (testy):**
- Spúštanie: v zložke kde je rozbalený zip `pytest test.py` (verzia Pythonu 3.10)
- Ak pytest nie je prítomný `pip install pytest`
- Dĺžka doby behu testov:
    - real    0m1.512s
    - user    0m1.229s
    - sys     0m0.152s