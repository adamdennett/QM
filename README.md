---
title: "Cloned CASA0007 module repo"
description: "Lectures and Practical Content for CASA0007"
site: index.html   # path under the Pages root — use this when there's no working index.html
image: https://github.com/adamdennett/QM/blob/main/sessions/L6_images/regression2.PNG     # relative path in the repo, or a full URL
---

# CASA0007 module repo
This repo contains lecture notes and practical notebooks for CASA0007 Quantitative Methods, which is part of **CASA MSc/MRes Urban Spatial Science** programme.

The website is here: https://huanfachen.github.io/QM/.

## Notes for Editors

1. **Cloning and Previewing**  
   To edit this repository, clone it to your local machine.  
   To preview the Quarto project, run:  
   ```bash
   quarto preview
   ```  
   This will render the project and serve it locally at **http://localhost:4200**.

2. **Updating Documents for Week X**  
   - Go to the `sessions` folder.  
   - Make a copy of three qmd files, `weekX.qmd`, `weekX_lecture.qmd`, `weekX_practical.qmd`. Rename them by replacing X with the week numbering, like 1, 2, or 10. In these qmd files, if you need to import images, please use relative path, e.g. ![](img/1.1-Repo_Created.png). The advantage of using relative paths is that when Github action builds the qmd files, it will identify these linked images and then automatically synce these images to the *gh-pages* branch.
   - If you need to add images/data, you can create a folder under `sessions` called LX_images and LX_data, and then add image or data in these folder.
   - **Do not** generate or upload HTML files manually.  
   - After editing, run add/commit/push of the three files to the main branch. [A GitHub Action is already set up and will automatically rebuild and update the website after you push changes.]

## TODO
1. Moodle: clean up
1. Moodle: Ask PGTAs to prepare quiz questions
1. Moodle: Suggested reading
1. Moodle: add link to lecture recording video
1. Quarto: week 1 practical - add standard deviation
1. Quarto: week 5/9/10
