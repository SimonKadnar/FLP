--Author: Šimon Kadnár
--Login: xkadna00
--Project: Decision tree

import System.Environment
import Data.Ord (comparing)
import Data.List.Split (splitOn)
import Data.List (sortBy, findIndex, groupBy, group, maximumBy)

main :: IO ()
main = do
    args <- getArgs
    case args of

        ["-1", file1, file2] -> do
            f1 <- readFile file1
            f2 <- readFile file2
            decide_all (create_tree (lines f1)) (lines f2)

        ["-2", file1] -> do
            f3 <- readFile file1
            cart (create_rows (lines f3)) 0

        _ -> putStrLn "Invalid input"

------------------------------Úloha1------------------------------

-- Struktura pre storm
data Tree = Leaf String  | Node Int Float Tree Tree deriving (Show)

--funkcia ktora najde poziciu kde by mal zacinat novy uzol podla odsadenia
find_follower :: Int -> [String] -> Int
find_follower count strs = 
    case filter (\str -> length (takeWhile (== ' ') str) == count) strs of
        (x:_) -> case findIndex (== x) strs of
                    Just idx -> idx
                    Nothing -> 0
        [] -> 0

{-Vytvorenie rozhodovacieho stormu, 
prejde sa na koniec zoznamu a spatnourekuziou sa pridavaju predchodcovia k prislusnym uzlom a listom,
pricom vzdy ked sa v zozname stringov narazi na uzol hlada sa knemu uzol/list na rovnakej urovni
nasledne sa rozdeli zoznam na 2 (jedena cast pre pravy druha cast pre lavy podstrom)-}
create_tree :: [String] -> Tree
create_tree [] = error "Empty list"
create_tree (x:xs) = case words x of 
        ["Leaf:", label] -> (Leaf label)

        ["Node:", first, second] -> 
            (Node (read (filter (/= ',') first) :: Int) (read second :: Float) 
                (create_tree (take (find_follower ((length $ takeWhile (== ' ') x) +2) (tail xs) +1 ) xs)) 
                (create_tree (drop (find_follower ((length $ takeWhile (== ' ') x) +2) (tail xs) +1 ) xs)) )

        _ -> error ("Invalid input: " ++ x)

--rozhodovacia funkcia ktora pre dany riadok cisiel rozhodne pod aku triedu patria
decide :: Tree -> [Float] -> IO()
decide (Leaf l_value) _ = print l_value
decide (Node i_value f_value r_tree l_tree) arr
    | f_value <= arr !! i_value = decide l_tree arr
    | f_value > arr !! i_value = decide r_tree arr
decide _ _ = error ("Invalid input for numbers")

--funkcia prechadzajuca (po riadkoch) vstupne cisla ktore maju byt rozhodnute
decide_all :: Tree -> [String] -> IO()
decide_all _ [] = return ()
decide_all tree (x:xs) =  
    decide tree (map read (splitOn "," x)) >>
    decide_all tree xs 

------------------------------Úloha2------------------------------

--pomocna struktura uchovavajuca kompletny riadok vstupu (1.1, 2.5, 0.4, triedaA)
data Row = Row { element :: String, numbers :: [Float]} deriving (Show)

instance Eq Row where
  (Row e1 n1) == (Row e2 n2) = e1 == e2 && n1 == n2

--pomocna struktura pre gini index pre 1 kombinaciu (vazeny priemer, treshold pre vysledny uzol a index s ktorymi stlpacami bolo pracovane)
data FloatPair = FloatPair {avg ::Float, threshold::Float, index::Int} deriving (Show)

instance Eq FloatPair where
    (FloatPair avg1 _ _) == (FloatPair avg2 _ _) = avg1 == avg2

instance Ord FloatPair where
    compare (FloatPair avg1 _ _) (FloatPair avg2 _ _) = compare avg1 avg2

--funkcia na oddelenie cisiel a triedy z jedneho stringu
divider:: [String] -> Row
divider x = Row { element = last x, numbers = map read (init x) }

--funkcia ktora transofrmuje vstup vo forme riadkov do zoznamu Row
create_rows :: [String] -> [Row]
create_rows [] = error("Empty list")
create_rows [x] = [divider (splitOn "," x)]
create_rows (x:xs) = (create_rows xs) ++ [divider (splitOn "," x)]

--utriredenie zoznamu row podla urciteho stlpca
sort_by_column :: Int -> [Row] -> [Row]
sort_by_column colIndex = sortBy (\row1 row2 -> compare (numbers row1 !! colIndex) (numbers row2 !! colIndex))

--utriredenie zoznamu row podla tried
sort_by_element :: [Row] -> [Row]
sort_by_element = sortBy (\row1 row2 -> compare (element row1) (element row2))

--vrati list s vyskytmi jednotlivych tried
numbers_of_elements :: [Row] -> [Int]
numbers_of_elements rows = map length groupedRows
    where
        groupedRows = groupBy (\row1 row2 -> element row1 == element row2) rows

--vypocet gini indexu
gini :: [Int] -> Int -> Float
gini [] _ = 0
gini (x:xs) len = ((fromIntegral x / fromIntegral len) ^ (2 :: Int)) + (gini xs len)

--funkcia pocitajuca vazeny priemer
average :: [Row] -> [Row] -> Int -> Int -> FloatPair
average group1 group2 len col =
    let len1 = fromIntegral (length group1)
        len2 = fromIntegral (length group2)
        totalLen = fromIntegral len
        gini_left = 1 - gini (numbers_of_elements (sort_by_element group1)) (length group1)
        gini_right = 1 - gini (numbers_of_elements (sort_by_element group2)) (length group2)
          
    in  FloatPair { avg = ((len1 / totalLen) * gini_left + (len2 / totalLen) * gini_right),         
                        threshold = (((numbers (last group1)) !! col) + ((numbers (head group2)) !! col)) / 2,
                        index = col } 

-- vypocet kombinacii giniindexu pre vsetky prvky podla daneho stlpca + vyber prvku s najmensim giniindexom 
evaluate_col :: [Row] -> Int -> Int -> FloatPair
evaluate_col rows col_index col
    | col_index + 1 == length rows = average (take col_index rows) (drop col_index rows) (length rows) col  

    | otherwise = min (average (take col_index rows) (drop col_index rows) (length rows) col) (evaluate_col rows (col_index + 1) col)

-- vypocet kombinacii giniindexu pre vsetky stlpce + vyber prvku s najmensim giniindexom 
choose_col::[Row]-> Int -> FloatPair
choose_col rows col                       
    | col + 1 /= length(numbers (head rows)) = min (evaluate_col (sort_by_column (col) rows) 1 (col)) (choose_col rows (col+1) )            
    | otherwise = (evaluate_col (sort_by_column (col) rows) 1 (col)) 
    --vypocet zcaina vzdy so skupinou kde je 1 prvok, col znaci pre ktory sltpec bezi vypocet

-- vrati zoznam rows ktore su mensie ako vybrany treashold
low_elements :: [Row] -> FloatPair -> [Row]
low_elements [] _ = []
low_elements (x:xs) float_pair
    | numbers x !! (index float_pair) > threshold float_pair = low_elements xs float_pair
    | otherwise = [x] ++ (low_elements xs float_pair)

-- vrati zoznam rows ktore su vacsie rovne ako vybrany treashold
high_elements :: [Row] -> FloatPair -> [Row]
high_elements [] _ = []
high_elements (x:xs) float_pair
    | numbers x !! (index float_pair) <= threshold float_pair = high_elements xs float_pair
    | otherwise = [x] ++ (high_elements xs float_pair)

--funkcia na vlkadane medzier
spaces :: Int -> String
spaces n = replicate n ' '

--ak maju vsetky riadky v zozname [Row] rovnaku triedu vrati true inak flase
all_elements_equal :: [Row] -> Bool
all_elements_equal [] = True
all_elements_equal [_] = True
all_elements_equal (x:y:xs) = element x == element y && all_elements_equal (y:xs)   

-- Funkcia na spočítanie počtu výskytov každej triedy v zozname
incidence :: [Row] -> [(String, Int)]
incidence rows = map (\xs -> (element (head xs), length xs)) (group (sort_by_element rows))

-- Funkcia na nájdenie elementu s najväčším počtom výskytov
most_com_element :: [Row] -> String
most_com_element rows = fst $ maximumBy (comparing snd) (incidence rows)

--riadiaca funkcia pre cart algoritmus
cart ::[Row] -> Int -> IO ()
cart rows padding

    --pripad kedy zoznam obsahuje iba jednu triedu 
    | all_elements_equal rows = putStrLn $ spaces padding ++ "Leaf: " ++ element (head rows) 

    | otherwise  = 
        let float_pair = choose_col rows 0      -- vzdy sa pocina gini index od nulteho stlpca po nty
            low_elem = low_elements rows float_pair

        --pokial kedy v low_elem je iba jedna trieda je potreba napisat node, triedu a dalej prechadzat zvysok zoznamu (high_elem)
        in if all_elements_equal low_elem
            then putStrLn (spaces padding ++ "Node: " ++ show (index float_pair) ++ ", " ++ show (threshold float_pair)) >>
                putStrLn (spaces (padding+2) ++ "Leaf: " ++ element (head low_elem)) >>
                cart (high_elements rows float_pair) (padding+2) 

            --pripad nekoneceho cyklenia je potreba vypisat najcastejsiu triedu
            else if high_elements rows float_pair == [] 
            then  putStrLn (spaces (padding) ++ "Leaf: " ++ (most_com_element low_elem))

            --pripad kedy v low_elem je vela roznych tired, dochadza k deleniu na dva podstromy
            else putStrLn (spaces padding ++ "Node: " ++ show (index float_pair) ++ ", " ++ show (threshold float_pair)) >>
                cart (low_elem) (padding+2) >>
                cart (high_elements rows float_pair) (padding+2) 