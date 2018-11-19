# How To Build
git pull
git checkout [michi-ccc|michi-ccc-fiff-mzm|flo-ccc|flo-tum]
git rebase origin/master
make

# Files and Directories
images: here are all the images for the presentation located
paranoia.tex: main file, all packages are loaded here, options are set.
              you don't want to aff content here!
metadata.tex: metadata that is written in the pdf (date, title, ...)
              this information is also added to some of the slides
content.tex:  the slides come here!
BRAINDUMP:    you might use this to collect ideas...

Makefile:     rules for making the pdf
.gitignore:   Filetypes that are ignored by git
hyperref.cfg: might in the future contain options for package hyperref

