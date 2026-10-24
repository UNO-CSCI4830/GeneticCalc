"""
Basic tests for the genetic cross calculation engine.

This file runs a sample cross, prints the offspring genotype
and phenotype frequencies, and can be used to check that the
results match expected Mendelian inheritance patterns.
"""

from genetics import calculate_cross, calculate_phenotype_frequencies

# Define the genotypes of both parents
parent1 = ["AA"]
parent2 = ["Aa"]

# Calculaes offspring genotype probabilities and phenotype probabilities
genotypes = calculate_cross(parent1, parent2)
phenotypes = calculate_phenotype_frequencies(genotypes)

# Display genotype probabilities as percentages
print("Genotype frequencies:")
for genotype, frequency in genotypes.items():
    print(f"{''.join(genotype)}: {frequency:.0%}")

# Display phenotype probabilities as percentages
print("\nPhenotype frequencies:")
for phenotype, frequency in phenotypes.items():
    print(f"{phenotype}: {frequency:.0%}")