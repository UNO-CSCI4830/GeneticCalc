from collections import Counter
from itertools import product

def validate_genotype(genotype):
    """
    Check whether a genotype is valid.

    A genotype must contain exactly two alphabetic characters
    representing the same gene, such as "AA", "Aa", or "aa".
    """
    if not isinstance(genotype, str) or len(genotype) != 2:
        return False

    first, second = genotype

    # Both alleles must be the same letter, ignoring case
    if not first.isalpha() or not second.isalpha():
        return False

    return first.upper() == second.upper()

def normalize_genotype(genotype):
    """
    Standardize genotype formatting by putting the uppercase
    allele before the lowercase allele (for example, "aA" -> "Aa").
    Raise a ValueError if the genotype is invalid.
    """
    if not validate_genotype(genotype):
        raise ValueError(f"Invalid genotype: {genotype}")
    
    return "".join(sorted(genotype, key=str.islower))
        
def generate_gametes(parent_genotypes):
    """
    Generate all possible gametes for one parent.

    Args:
        parent_genotypes: A list containing one genotype per gene,
        such as ["Aa", "Bb"].

    Returns:
        A list of possible gametes, such as ["AB", "Ab", "aB", "ab"].

    Each gamete receives one allele from each gene. Duplicate
    choices are removed for homozygous genes because they produce
    only one distinct allele choice.
    """
    normalized = [
        normalize_genotype(genotype)

        for genotype in parent_genotypes
    ]
    
    allele_choices = [
        list(dict.fromkeys(genotype))
        
        for genotype in normalized
    ]

    return [
        "".join(alleles)

        for alleles in product(*allele_choices)
    ]

def combine_gametes(gamete1, gamete2):
    """
    Combine two gametes to produce an offspring genotype.

    Each pair of corresponding alleles forms one gene's genotype.
    The resulting genotypes are normalized and returned as a tuple,
    with one genotype per gene.
    """
    if len(gamete1) != len(gamete2):
        raise ValueError("Gametes must contain the same number of genes.")
    
    offspring = []

    for allele1, allele2 in zip(gamete1, gamete2):
        offspring.append(
            normalize_genotype(allele1 + allele2)
        )

    return tuple(offspring)

def calculate_cross(parent1, parent2):
    """
    Calculate the possible offspring genotypes and their frequencies.

    Args:
        parent1: A list of genotypes for the first parent.
        parent2: A list of genotypes for the second parent.
        Both lists must contain the same genes in the same order.

    Returns:
        A dictionary mapping each offspring genotype tuple to its
        probability, expressed as a decimal between 0 and 1.

    The function generates possible gametes for each parent, combines
    every gamete pairing, counts the resulting genotypes, and converts
    those counts into probabilities.

    Assumes independent assortment and equal probability for each
    distinct gamete produced by a parent.
    """
    if not parent1 or not parent2:
        raise ValueError("Both parents must have at least one gene.")
    
    if len(parent1) != len(parent2):
        raise ValueError("Both parents must have the same number of genes.")
    
    for genotype1, genotype2 in zip(parent1, parent2):
        if not validate_genotype(genotype1):
            raise ValueError(f"Invalid genotype: {genotype1}")
        
        if not validate_genotype(genotype2):
            raise ValueError(f"Invalid genotype: {genotype2}")
        
        if genotype1.upper() != genotype2.upper():
            raise ValueError(
                "Both parents must use the same gene letter at each locus."
            )

    # Generate the possible gametes for each parent
    gametes1 = generate_gametes(parent1)
    gametes2 = generate_gametes(parent2)

    outcomes = Counter()

    # Count the offspring genotype produced by each gamete pairing
    for gamete1 in gametes1:
        for gamete2 in gametes2:
            offspring = combine_gametes(gamete1, gamete2)
            outcomes[offspring] += 1

    # Convert the counts into probabilities
    total = sum(outcomes.values())

    return {
        genotype: count / total
        for genotype, count in sorted(outcomes.items())
    }

def determine_phenotype(genotype):
    """
    Determine the basic dominant/recessive phenotype for one gene.

    Assumes complete dominance: a genotype with at least one
    uppercase allele is classified as dominant. A genotype with
    two lowercase alleles is classified as recessive.

    This function does not yet support incomplete dominance
    or codominance.
    """
    genotype = normalize_genotype(genotype)

    if genotype.isupper():
        return "Dominant"
    
    if genotype.islower():
        return "Recessive"
    
    return "Dominant"

def calculate_phenotype_frequencies(genotype_frequencies):
    """
    Calculate phenotype probabilities from offspring genotype probabilities.

    Args:
        genotype_frequencies: The dictionary returned by calculate_cross().

    Returns:
        A dictionary mapping phenotype labels to their probabilities.

    Genotype probabilities are added together when the genotypes
    produce the same phenotype.
    """
    phenotypes = Counter()
    
    for genotypes, frequency in genotype_frequencies.items():
        for genotype in genotypes:
            phenotype = determine_phenotype(genotype)
            phenotypes[phenotype] += frequency

    return dict(phenotypes)