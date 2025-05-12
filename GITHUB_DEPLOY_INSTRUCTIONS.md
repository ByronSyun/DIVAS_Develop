# GitHub Deployment Instructions

Follow these steps to deploy the DIVAS package to GitHub and enable GitHub Pages for the documentation website:

## 1. Project Structure Overview

The project has been organized with the following structure:

```
DIVAS-main/                    # Main project directory
├── R/                         # R function code
├── man/                       # Function documentation
├── vignettes/                 # User guides and tutorials
│   └── figures/               # Images and diagrams
├── docs/                      # Generated website files (GitHub Pages)
├── figs/                      # Figures for the package documentation
└── [other configuration files]
```

## 2. Commit all changes to Git

```bash
# Return to the main directory
cd /Users/byronsun/Desktop/DIVAS-code

# Add all files
git add .

# Commit changes
git commit -m "Reorganize project structure for GitHub Pages"
```

## 3. Create a GitHub repository

1. Visit [GitHub](https://github.com/) and log in
2. Click "New repository" to create a new repository
3. Repository name: `DIVAS_Develop`
4. Choose Public or Private according to your needs
5. Do not initialize the repository (don't add README, .gitignore, or license)
6. Click "Create repository"

## 4. Push the local repository to GitHub

```bash
# Add remote repository
git remote add origin https://github.com/ByronSyun/DIVAS_Develop.git

# Push to GitHub
git push -u origin main  # If your main branch is named 'main'
# Or 
git push -u origin master  # If your main branch is named 'master'
```

## 5. Enable GitHub Pages

1. Open your GitHub repository page in the browser
2. Click the "Settings" tab
3. Click "Pages" in the left navigation bar
4. Select your main branch (main or master) in the "Source" dropdown menu
5. Click on the "/docs" folder option and save

GitHub Pages will deploy within a few minutes, and the URL will be displayed on the page (typically https://username.github.io/DIVAS_Develop/).

## 6. Verify the documentation website

Visit https://byronsyun.github.io/DIVAS_Develop/ to confirm that the website has been correctly deployed.

## 7. Maintain the website

Whenever you update the package and wish to update the documentation:

```bash
# Update the pkgdown website
cd /Users/byronsun/Desktop/DIVAS-code/DIVAS-main
R -e "pkgdown::build_site()"

# Commit changes
git add .
git commit -m "Update documentation"
git push
```

The website will automatically update after the push. 