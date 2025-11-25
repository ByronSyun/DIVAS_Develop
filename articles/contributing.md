# Contributing to DIVAS

Thank you for your interest in contributing to the DIVAS package! This
document provides guidelines for contributing to the project, whether
through code contributions, documentation improvements, or bug reports.

## Ways to Contribute

There are several ways you can contribute to the DIVAS project:

1.  **Report bugs**: If you find a bug, please report it by [creating an
    issue](https://github.com/ByronSyun/DIVAS_Develop/issues) on our
    GitHub repository.

2.  **Suggest features**: Have an idea for a new feature? Share it by
    creating an issue labeled as “feature request.”

3.  **Improve documentation**: Help us improve documentation by fixing
    typos, clarifying explanations, or adding examples.

4.  **Contribute code**: Add new features, fix bugs, or optimize
    existing code.

5.  **Share examples**: Create example scripts that showcase DIVAS in
    real-world applications.

## Code Contribution Guidelines

If you’d like to contribute code to DIVAS, please follow these steps:

1.  **Fork the repository** to your GitHub account.

2.  **Create a branch** for your changes:

    ``` bash
    git checkout -b feature/your-feature-name
    ```

3.  **Make your changes** following our coding style guidelines (see
    below).

4.  **Add tests** for new features or bug fixes.

5.  **Run tests** to ensure your changes don’t break existing
    functionality:

    ``` r
    devtools::test()
    ```

6.  **Document your code** using roxygen2 comments and update vignettes
    if necessary.

7.  **Submit a pull request** with a clear description of the changes.

## Coding Style Guidelines

We follow the [tidyverse style guide](https://style.tidyverse.org/) for
R code. Key points include:

- Use 2 spaces for indentation
- Limit lines to 80 characters
- Use snake_case for variable and function names
- Document all exported functions with roxygen2
- Include examples in function documentation

## Documentation

Good documentation is crucial for the usability of the package. When
contributing:

- Document all exported functions with roxygen2
- Include examples in function documentation
- Update vignettes to reflect changes in functionality
- Keep the README up to date

## Testing

We use the testthat package for testing. Please ensure:

- All new features have corresponding tests
- All bug fixes include tests that would have caught the bug
- All tests pass before submitting your contribution

To run tests locally:

``` r
devtools::test()
```

## Submitting a Pull Request

When you’re ready to submit your changes:

1.  Push your branch to your fork:

    ``` bash
    git push origin feature/your-feature-name
    ```

2.  Go to the [DIVAS
    repository](https://github.com/ByronSyun/DIVAS_Develop) and create a
    pull request.

3.  Include a clear title and description of your changes.

4.  Reference any related issues using the GitHub issue number (e.g.,
    “Fixes \#42”).

## Code of Conduct

Please note that the DIVAS project is released with a [Contributor Code
of
Conduct](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).
By contributing to this project, you agree to abide by its terms.

## Questions?

If you have any questions about contributing, please [open an
issue](https://github.com/ByronSyun/DIVAS_Develop/issues) and we’ll be
happy to help!
