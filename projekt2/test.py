# Autor: Šimon Kadnár 
# Zadanie: Testy ku kostre grafu
# Login: xkadna00

import subprocess

def check(name_of_input, name_of_output):

    # spustenie flp23-log ako prikaz
    command = f"make && ./flp23-log < {name_of_input}"
    process = subprocess.Popen(command, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    stdout, _ = process.communicate()

    # preskocenie prveho riadku vo vypise (nachadza sa tam spustanie z makefilu)
    res = stdout.strip().split('\n')[1:]

    # nacitanie ocakavaneho vystupu
    with open(name_of_output, "r") as f:
        excepted_res = f.read().splitlines()
    
    process.terminate()

    # odstranenie medzier
    res = [row.replace(" ", "") for row in res]
    excepted_res = [row.replace(" ", "") for row in excepted_res]

    # utriedenie kostier
    res.sort()
    excepted_res.sort()

    assert res == excepted_res
    
def test_basic():
    check("test_data/input1.txt", "test_data/output.txt")

def test_oposite_tops():
    check("test_data/input2.txt", "test_data/output.txt")

def test_duplicates():
    check("test_data/input3.txt", "test_data/output.txt")

def test_double_top():
    check("test_data/input4.txt", "test_data/output.txt")

def test_mix():
    check("test_data/input5.txt", "test_data/output.txt")