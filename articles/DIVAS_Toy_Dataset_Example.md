# DIVAS Vignette: Toy Dataset Example

## Introduction

This guide demonstrates how to use the `DIVAS` R package to perform data
integration on a provided toy dataset. DIVAS (Data Integration via
Analysis of Subspaces) identifies joint and individual variation
patterns across multiple data blocks (modalities).

First, ensure you have the `DIVAS` package and its dependencies
installed. See the main `README.md` for installation instructions,
especially regarding the required `CVXR` version (0.99-7).

``` r
# install if not have
# install.packages("devtools")

# Install DIVAS package from GitHub
# devtools::install_github("ByronSyun/DIVAS_Develop", ref = "DIVAS-v1")

# Or install from local folder
# devtools::load_all("DIVAS-main") 

# Install the specified version of CVXR
# devtools::install_version("CVXR", version = "0.99-7", repos = "http://cran.us.r-project.org")

# For pkgdown, libraries are generally not needed here if the package is loaded,
# # library(R.matlab)
# # library(DIVAS)
```

## The Toy Dataset (`toyDataThreeWay.mat`)

The toy dataset (`toyDataThreeWay.mat`) is used to test DIVAS by the
original author. It’s stored in MATLAB format.

This dataset contains a variable named `datablock`, which is a MATLAB
cell array with dimensions 1×3. Inside R, after loading with
[`readMat()`](https://rdrr.io/pkg/R.matlab/man/readMat.html), it becomes
a nested list structure with three elements, each containing a data
matrix. It also includes a `dataname` variable that provides labels
(“X1”, “X2”, “X3”) for these data blocks.

The three data matrices have the following dimensions: - Block 1 (X1):
200 × 400 matrix - Block 2 (X2): 400 × 400 matrix - Block 3 (X3): 10000
× 400 matrix

These matrices share a common dimension (400 columns), representing 400
samples measured using three different modalities, where each modality
captures a different number of features (200, 400, and 10000
respectively). This structure is typical in multi-modal data integration
scenarios, where the same samples are profiled using different
measurement techniques.

Let’s load the data:

``` r
# library(R.matlab)
# Assuming 'toyDataThreeWay.mat' is in your working directory or data/ directory of the package
# data_path <- system.file("extdata", "toyDataThreeWay.mat", package = "DIVAS") 
# data <- R.matlab::readMat(data_path) 
# str(data$datablock)
```

The `datablock` object loaded from the `.mat` file needs to be converted
into a simple list of matrices, where each element of the list is one
data block (matrix).

``` r
# datablock_list <- list(
#   Block1 = data$datablock[1,1][[1]][[1]],
#   Block2 = data$datablock[1,2][[1]][[1]],
#   Block3 = data$datablock[1,3][[1]][[1]]
# )
# 
# print(paste("Block 1 dimensions:", dim(datablock_list[[1]])))
# print(paste("Block 2 dimensions:", dim(datablock_list[[2]])))
# print(paste("Block 3 dimensions:", dim(datablock_list[[3]])))
```

Now, `datablock_list` is ready for DIVAS analysis. It contains three
matrices.

## Running DIVAS Analysis

The core function is `DIVASmain`. We pass our prepared list of data
blocks to it.

``` r
# Run the main DIVAS function
# Use default parameters for this example
# divas_results <- DIVAS::DIVASmain(datablock_list)
# 
# # The result is a list containing various outputs
# names(divas_results)
```

## DIVAS Analysis Process and Results Interpretation

The DIVAS analysis performed by
[`DIVASmain()`](https://byronsyun.github.io/DIVAS_Develop/reference/DIVASmain.md)
consists of three main steps:

### Step 1: Signal Extraction

The first step extracts the signal component from each data block by
separating it from noise. When you run
[`DIVASmain()`](https://byronsyun.github.io/DIVAS_Develop/reference/DIVASmain.md),
you’ll see output similar to:

    Signal estimation for X1
    Datablock dimensions: 200 features; 400 samples 
    estimated noise = 19.96 
    Initial signal rank for X1 is 3.
    Progress Through Bootstrapped Matrices:
    ...
    Culled Rank is 3.
    Perturbation Angle for X1 is 11.8.

For each data block, this step:

1.  **Estimates the noise level** using random matrix theory
2.  **Determines an initial signal rank** based on singular values above
    the noise threshold
3.  **Refines the rank through bootstrapping** (sampling with
    replacement)
4.  **Calculates a perturbation angle**, which indicates how stable the
    extracted signal subspace is

In our toy example, all three data blocks have: - **Culled Rank = 3**:
The algorithm detected three significant components in each data block -
**Perturbation Angles** (11.8, 8.6, and 2.8 for X1, X2, and X3): These
values indicate the stability of the extracted signals. Smaller angles
suggest more stable signals, explaining why X3 (with 10,000 features)
has the most stable signal extraction.

The output from this step, the signal matrices, becomes the input for
the joint structure identification step.

### Step 2: Joint Structure Identification

The second step identifies joint and individual structure components
across the data blocks. DIVAS uses convex optimization to find subspaces
that are shared between different combinations of data blocks, as well
as subspaces that are unique to individual blocks.

This step is computationally intensive as it involves solving a
penalized optimization problem. When running, you’ll see output similar
to:

    Joint structure estimation for block: 1, 2, 3
    Solving for structures with key: 1
    Solving for structures with key: 2
    Solving for structures with key: 3
    Solving for structures with key: 4
    ...
    Solving for structures with key: 7
    Joint structure estimate for 1, 2, 3 complete.

During this step, the algorithm performs iterative convex optimization
to identify joint and individual structures. For each structure key,
you’ll see output like:

    Find joint structure shared only among X1, X2, X3.
    Search Direction 1:
    2 0.903132 0.953589 1.004182 2.990696 0.995363 -1000005.482454
    3 0.796711 0.845383 0.894077 2.767596 0.885542 0.162749
    4 0.701401 0.748269 0.795147 2.561086 0.786920 0.154449
    ...
    Iteration 10
    10 0.307495 0.345173 0.382800 1.602823 0.376174 0.111738
    ...
    Iteration 20
    20 0.041978 0.069198 0.096336 0.696604 0.091532 0.060549
    ...

This output represents the optimization progress where: - **Column 1**:
Iteration number - **Columns 2-4**: Slack variables for each data block
(X1, X2, X3), which measure constraint violations for each block -
**Column 5**: Sum of the slack variables, representing total constraint
violation - **Column 6**: Represents the norm constraint slack variable
(ensuring the solution vector has unit norm) - **Column 7**: Objective
function change between successive iterations (decrease in objective
value, first one as negative infinity).

The algorithm is using a penalty method with slack variables to solve a
constrained optimization problem. As the iterations progress, you should
observe: 1. Decreasing slack values (columns 2-5), indicating
constraints are being better satisfied 2. Smaller changes in the
objective function (column 7), indicating convergence.

The optimization stops when both the change in objective value and the
sum of slack variables fall below specified thresholds, indicating that
a stable solution has been found.

Additionally, you’ll notice the algorithm searches for multiple
directions within each structure:

    Search Direction 1:
    ...
    Direction 1 converges.
    There is room for searching next direction. Continue...

    Search Direction 2:
    ...
    Direction 2 does not converge. Stop searching current joint block.

    Find joint structure shared only among X1, X2.
    Search Direction 1:
    ...

This sequence shows how DIVAS finds the basis vectors for each
structure:

1.  For each joint structure (e.g., “structure shared among X1, X2,
    X3”), the algorithm searches for orthogonal directions sequentially.

2.  Each “Search Direction” represents an attempt to find one basis
    vector of the subspace corresponding to a particular structure.

3.  When a direction converges successfully (e.g., “Direction 1
    converges”), the algorithm checks if additional dimensions might
    exist for this structure and proceeds to search for another
    direction.

4.  When a direction fails to converge (e.g., “Direction 2 does not
    converge”), the algorithm concludes that it has found all
    significant dimensions for the current structure and moves on to the
    next structure type.

5.  The process continues until all possible structures have been
    examined (individual structures for each block and all possible
    combinations of joint structures).

At the end of the joint structure identification step, DIVAS summarizes
the results like this:

    Direction 1 converges.
    There is no room for searching next direction. Stop searching current joint block.
    There is no room for the next joint block. Stop searching.
    The rank of joint block among X1, X2, X3: 1
    The rank of joint block among X1, X2: 1
    The rank of joint block among X1, X3: 1
    The rank of joint block among X2, X3: 1
    Starting binary code 1

This summary shows the rank (number of dimensions) found for each joint
structure. In this example, DIVAS identified: - 1 dimension shared among
all three data blocks (X1, X2, X3) - 1 dimension shared between each
pair of data blocks (X1-X2, X1-X3, X2-X3)

### Step 3: Structure Reconstruction

In the final step, DIVAS reconstructs the estimated individual and joint
structures for each data block. This reconstruction provides a
decomposition of the original signal into its joint and individual
components.

The algorithm outputs (More explanations are summarized together in the
next Section):

    $jointBasisMap
    $matLoadings
    $matBlocks
    $keyIdxMap

## Interpreting the Visualization Results

The DIVAS analysis generates two main diagnostic plots that provide
critical insights into the identified structures:

### 1. Joint Structure Loadings Diagnostics

``` r
# These plots are generated by the DJIVEAngleDiagnosticJP function
# plots <- DJIVEAngleDiagnosticJP(datablock_list, dataname, divas_results, 
#                               randseed = 566, titlestr = "Demo")
```

This plot shows:

- **Rows**: Each data block (DataBlock_1, DataBlock_2, DataBlock_3)
- **Columns**: Different structure types (3-Way = shared by all three
  blocks, 2-Way = pairwise joint structures, 1-Way = individual
  structures)
- **Numbers in cells**: The rank (dimensionality) of each structure type
  for each data block
- **Colors**: Blue for 3-Way joint structures, Red for 2-Way joint
  structures, Gray for individual structures
- **Angles**: Values like “78.4”, “8.6” represent perturbation angles,
  with smaller angles indicating more stable structures
- **Bottom row**: Shows the effective contribution of each structure
  type to the overall signal

In the example plot: - Each data block has a 1-dimensional structure
shared with all blocks (the “3-Way” column) - Each data block
participates in 1-dimensional pairwise joint structures (the “2-Way”
columns) - None of the blocks show individual structures (zeros in the
“1-Way” column) - The perturbation angles vary across blocks, with
DataBlock_3 showing the most stable joint structure (smallest angle of
2.8°)

### 2. Joint Structure Score Diagnostics

``` r
# print(plots$score)
```

This plot is similar to the loadings plot but focuses on the sample
space (scores) rather than the feature space (loadings). It shows:

- How the joint and individual structures manifest in the sample
  dimensions
- Principal angles (like “82”, “11.8”) between the identified structures
  and random subspaces
- The bottom row shows the “Effective Number of Cases” that contribute
  to each structure

Smaller angles in both plots indicate that the identified structures are
statistically significant and distinct from random variation.

These visualizations provide a comprehensive view of how information is
shared across data blocks, helping researchers identify which structures
are most important and reliable for interpretation.

Let’s examine the key components of the `divas_results` object in
detail:

### Joint Basis Map

The `jointBasisMap` is a list containing the estimated basis vectors
(scores) for each identified structure:

``` r
# names(divas_results$jointBasisMap)
# dim(divas_results$jointBasisMap[["7"]])
```

### Matrix Loadings

The `matLoadings` component provides the corresponding loadings for each
structure:

``` r
# str(divas_results$matLoadings, max.level = 2)
```

This nested list structure contains loadings for each block and each
structure. The loadings show how the joint and individual patterns are
expressed in the original feature space of each data block.

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
