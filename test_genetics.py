"""
Basic tests for the genetic cross calculation engine.

This file uses pytest for testing, .
"""


import pytest
from genetics import (
    validate_genotype,
    normalize_genotype,
    generate_gametes,
    combine_gametes,
    calculate_cross,
    determine_phenotype,
    calculate_phenotype_frequencies,
)

# test genetics.py functions
 
def test_validate_genotype():
    assert validate_genotype("AA") 
    assert validate_genotype("Aa") 
    assert validate_genotype("aa") 
    assert not validate_genotype("A") 
    assert not validate_genotype("AB") 
    assert not validate_genotype("A1")
    assert not validate_genotype(12)

def test_normalize_genotype():
    assert normalize_genotype("Aa") == "Aa"
    assert normalize_genotype("aA") == "Aa"
    assert normalize_genotype("AA") == "AA"
    assert normalize_genotype("aa") == "aa"
    with pytest.raises(ValueError):
        normalize_genotype("AB")

def test_generate_gametes():
    assert sorted(generate_gametes(["Aa", "Bb"])) == ["AB", "Ab", "aB", "ab"]
    assert generate_gametes(["AA"]) == ["A"]      
    assert sorted(generate_gametes(["AA", "Bb"])) == ["AB", "Ab"]


def test_combine_gametes():
    assert combine_gametes("AB", "ab") == ("Aa", "Bb")
    assert combine_gametes("aB", "Ab") == ("Aa", "Bb")   
    with pytest.raises(ValueError):
        combine_gametes("A", "AB")

def test_determine_phenotype():
    assert determine_phenotype("AA") == "Dominant"
    assert determine_phenotype("Aa") == "Dominant"
    assert determine_phenotype("aa") == "Recessive"



# test cross calculation functions

def test_Aa_x_Aa():
    result = calculate_cross(["Aa"], ["Aa"])
    assert result == {("AA",): 0.25, ("Aa",): 0.5, ("aa",): 0.25}


# FR 5

def test_invalid_input_raises_error():
    with pytest.raises(ValueError):
        calculate_cross(["A"], ["Aa"])
    with pytest.raises(ValueError):
        calculate_cross(["Aa"], ["Aa", "Bb"])

