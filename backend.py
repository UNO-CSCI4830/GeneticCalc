"""
This file contains the mappings and logic for GUI buttons, features, and output. 
"""

import csv

from PySide6.QtCore import QObject, QUrl, Signal, Slot

import genetics

"""
Display input to user for easy reference and confirmation.
Input: Parent input strings from GeneInputGroupv2 (ex. "" -> none, a -> one allele, aa -> two allele)
Output: genotype_rows, phenotype_rows
"""
def build_results(parent1_inputs, parent2_inputs, gene_names):
    p1, p2 = [], []

    for name, g1, g2 in zip(gene_names, parent1_inputs, parent2_inputs):
        if not g1 and not g2:
            continue #empty gene slots
        if len(g1) != 2 or len(g2) != 2:
            raise ValueError(f"Gene {name}: Select both alleles for both parents.")
        p1.append(g1)
        p2.append(g2)

    if not p1:
        raise ValueError("Select alleles for at least one gene.")

    #Genetics logic mapping
    genotype_freqs = genetics.calculate_cross(p1, p2)

    #Punnett square box count
    total_boxes = len(genetics.generate_gametes(p1)) * len(genetics.generate_gametes(p2))

    #Build result list with genotype, percent, and count via squares
    genotype_rows = [
        {
            "genotype": "".join(genotype),
            "percent": f"{freq * 100:.2f}",
            "count": f"{round(freq * total_boxes)} of {total_boxes}",
        }
        for genotype, freq in genotype_freqs.items()
    ]

    """
    Iterating through genotype frequencies to determine and format phenotype frequencies, used for 
    determine phenotype row mapping output
    """
    phenotype_freqs = {}
    for genotype, freq in genotype_freqs.items():
        label = ", ".join(
            f"{g[0].upper()} {genetics.determine_phenotype(g).lower()}"
            for g in genotype
        )
        phenotype_freqs[label] = phenotype_freqs.get(label, 0) + freq

    phenotype_rows = [
        {
            "phenotype": label,
            "percent": f"{freq * 100:.2f}",
        }
        for label, freq in sorted(phenotype_freqs.items(), key=lambda kv: -kv[1])
    ]

    return genotype_rows, phenotype_rows


"""
Write the most recent results to a .csv file: a genotype section followed by a
phenotype section, separated by a blank line.
"""
def write_results_csv(path, genotype_rows, phenotype_rows):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Genotype", "Frequency (%)", "Count (Expected)"])
        for row in genotype_rows:
            writer.writerow([row["genotype"], row["percent"], row["count"]])
        writer.writerow([])
        writer.writerow(["Phenotype", "Frequency (%)"])
        for row in phenotype_rows:
            writer.writerow([row["phenotype"], row["percent"]])


#GUI output formatting and potential errors
class CrossBackend(QObject):
    resultsReady = Signal(list, list, arguments=["genotypeRows", "phenotypeRows"])
    errorOccurred = Signal(str, arguments=["message"])
    exportFinished = Signal(str, arguments=["path"])

    def __init__(self, parent=None):
        super().__init__(parent)
        # Last successful calculation, so Export to CSV has something to write
        self._genotype_rows = []
        self._phenotype_rows = []

    @Slot(list, list, list)
    def calculate(self, parent1_inputs, parent2_inputs, gene_names):
        try:
            genotype_rows, phenotype_rows = build_results(
                [str(g) for g in parent1_inputs],
                [str(g) for g in parent2_inputs],
                [str(n) for n in gene_names],
            )
        except ValueError as e:
            self.errorOccurred.emit(str(e))
            return
        self._genotype_rows = genotype_rows
        self._phenotype_rows = phenotype_rows
        self.resultsReady.emit(genotype_rows, phenotype_rows)

    # Called by the Clear button so a stale result can't be exported afterwards
    @Slot()
    def clear(self):
        self._genotype_rows = []
        self._phenotype_rows = []

    # Called by Export to CSV button path is whatever the file dialog returned
    @Slot(str)
    def exportCsv(self, path):
        if not self._genotype_rows:
            self.errorOccurred.emit("Nothing to export yet. Run Calculate Cross first.")
            return
        if path.startswith("file:"):
            path = QUrl(path).toLocalFile()   # "file:///C:/x.csv" -> "C:/x.csv"
        if not path.lower().endswith(".csv"):
            path += ".csv"
        try:
            write_results_csv(path, self._genotype_rows, self._phenotype_rows)
        except OSError as e:
            self.errorOccurred.emit(f"Could not save file: {e}")
            return
        self.exportFinished.emit(path)