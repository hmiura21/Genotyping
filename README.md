# 🧬 Bordetella parapertussis Genome Assembly and Assessment

---

## 📄 Assignment Overview

This project focuses on the genomic analysis of *Bordetella parapertussis* isolates sequenced as part of national surveillance in Colombia. The key goals are to:

- Download Illumina sequencing reads for three SRA accessions.
- Perform read trimming and de novo assembly.
- Compare assemblies to the species type strain using **FastANI**.
- Genotype using **MLST**.
- Assess genome quality for one sample using **CheckM**, **CheckM2**, or **BUSCO**.

---

## 📥 SRA Accessions Used

| Sample Name | SRA Accession |
|-------------|---------------|
| Sample_1    | SRR27160580   |
| Sample_2    | SRR27160579   |
| Sample_3    | SRR27160578   |

All three datasets were downloaded using `fasterq-dump`.

---

## 🧪 Workflow Summary

The pipeline was built using core skills from class. All commands are documented in `cmds.sh`, including commentary for reproducibility.

### 1. 🔽 Data Retrieval

- Used `fasterq-dump` to download raw FASTQ reads from the SRA database.

### 2. 🧼 Read Preprocessing

- Cleaned reads using `fastp` to remove low-quality bases and adapters.

### 3. 🧬 Genome Assembly

- Assembled reads using `skesa`, a fast assembler optimized for Illumina data.
- Filtered contigs based on:
  - Minimum length threshold (e.g., >500 bp)
  - Minimum coverage (e.g., >5x)


### 4. 🧠 FastANI Species Identification

Compared all three assembled genomes against the *Bordetella parapertussis* type strain genome using `fastANI`

**Output:**
- Results stored in `fastani.tsv`
- Table includes:
  - Sample names (SRA accessions)
  - ANI percentage
  - Total aligned fragments
  - Total matching fragments


### 5. 🧬 MLST Genotyping

Used `mlst` to genotype all three assemblies along with the type strain.

**Purpose:**  
Multi-Locus Sequence Typing (MLST) identifies sequence types based on housekeeping gene alleles, helping distinguish between closely related strains.

**Output:**
- Results stored in `mlst.tsv`
- Includes:
  - Sample names (SRA accessions)
  - Allele calls for each gene
  - Sequence type (ST)


### 6. ✅ Genome Quality Assessment

Estimated genome **completeness** and **contamination** for one of the three assemblies using `CheckM`.

**Tool Used:**  
- `CheckM` 
- Documented in `cmds.sh` under the section `# Step 7 - Genome Quality Assessment`

**Purpose:**  
Evaluate how complete and clean the genome assembly is using lineage-specific marker genes.

**Input:**  
- One selected `.fna` assembly file (e.g., `SRR27160578.fna`)

**Output:**  
- Tab-delimited summary file: `quality.tsv`
  - Includes header row with:
    - Sample name
    - Completeness (%)
    - Contamination (%)
    - Strain heterogeneity
    - Lineage

