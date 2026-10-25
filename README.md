# GeneticCalc

This is a genetic cross calculator. You put in the genotypes of two parents (like AA and Aa) and it shows the possible genotypes and phenotypes of the offspring, like a Punnett square.

It is written in Python and the GUI uses PySide6.

This project is still in progress. Right now it only does monohybrid crosses (one gene).

## What you need

- Python 3.9 or newer
- PySide6
- Git

## How to set it up

Clone the repo:

```
git clone https://github.com/UNO-CSCI4830/GeneticCalc.git
cd GeneticCalc
```

Install PySide6:

```
pip install PySide6
```

## How to run it

```
python main.py
```

## How to run the test

```
python test_genetics.py
```

Run it from inside the GeneticCalc folder. It does a sample cross (AA x Aa) and should print:

```
Genotype frequencies:
AA: 50%
Aa: 50%

Phenotype frequencies:
Dominant: 100%
```

## Files

- `main.py` - starts the app
- `genetics.py` - the math for the genetic crosses
- `test_genetics.py` - sample test
- `qml/` - the GUI files

## What works so far

- Checks if a genotype is valid
- Finds the gametes for each parent
- Calculates genotype and phenotype percentages
- GUI layout

Still working on: connecting the GUI buttons to the logic and adding more tests.

## Team

- Ben - GUI
- Liz - monohybrid logic and basic test
- Matt - connecting the logic to the GUI
- Brady - more test cases
- Geovany - README
