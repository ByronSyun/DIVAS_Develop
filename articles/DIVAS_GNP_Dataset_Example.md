# DIVAS Vignette: GNP Dataset Example

## Example 2: Using the GNP Dataset

In addition to the toy dataset, we can also demonstrate how to use DIVAS
with a different type of data format. The following example uses a
dataset stored in `qs` format.

### About the GNP Dataset

The `gnp_imputed.qs` dataset contains multi-omics data organized in a
list structure. When loaded, it provides:

1.  `gnp$datablock`: A list of three named data matrices:
    - `RNA`: Gene expression data (8432 genes × 18 samples)
    - `PRO`: Protein expression data (3156 proteins × 18 samples)
    - `MIC`: MicroRNA expression data (283 miRNAs × 18 samples)
2.  `gnp$metaData`: A data frame with 18 rows (samples) and 8 columns of
    metadata, including information about sample stage, donor, sex, and
    age.

All three data matrices share the same samples (18 columns with
identical sample IDs), making this a perfect example for multi-modal
data integration with DIVAS. Each data type (RNA, protein, miRNA)
represents a different “view” of the same biological samples.

To run this example, you’ll need the `qs` package:

``` r
# install.packages("qs")
# library(qs)
```

### Loading and Analyzing the GNP Dataset

``` r
# library(qs)
# gnp_data_path <- system.file("extdata", "gnp_imputed.qs", package = "DIVAS") 
# gnp <- qs::qread(gnp_data_path)
# 
# datablock_gnp <- gnp$datablock
# divasRes_gnp <- DIVAS::DIVASmain(datablock_gnp, nsim = 400, colCent = TRUE)
# 
# # Create names for the data blocks
# dataname_gnp <- paste0("DataBlock_", names(datablock_gnp))
# plots_gnp <- DIVAS::DJIVEAngleDiagnosticJP(datablock_gnp, dataname_gnp, divasRes_gnp, 566, "GNP Demo")
# print(plots_gnp)
```

## References

1.  Prothero, J., …, Marron J. S. (2024). Data integration via analysis
    of subspaces (DIVAS).

2.  DIVAS R package. <https://github.com/ByronSyun/DIVAS_Develop>.

3.  Klein, C., Hesse, S., Mao, J., Hadziahmetovic, A., et al. (2025). A
    molecular atlas of human granulopoiesis.
    <https://www.researchsquare.com/article/rs-6184761/v1>

4.  GNP dataset provided by the [Comprehensive Childhood Research
    Center](https://www.ccrc-hauner.de/mission/509ecab365bf4e16)  
    at the [Dr. von Hauner Children’s
    Hospital](https://www.lmu-klinikum.de/hauner/kinder-und-kinderpoliklinik)
    ([Klein
    Lab](https://www.ccrc-hauner.de/research-labs/klein-lab/939888339a9fcb00)).
    <https://granulopoiesis.com/>

For more detailed technical information about the DIVAS method, please
refer to the primary publication (1). For details on the R package
implementation, please visit the GitHub repository (2). The GNP dataset
used in Example 2 is from the human granulopoiesis atlas project (3,4).
