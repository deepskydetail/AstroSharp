# Running on Mac OSX with RStudio

Currently the embedded application is windows only.

The application is written in R and uses the shiny web application framework.

It is possible to run the application from RStudio directly on OSX.

## Requirements

The following are needed.

- [R](https://www.r-project.org/) - the language
- [RStudio](https://posit.co/products/open-source/rstudio/) open source edition - the R development editor/IDE
- [XQuartx](https://www.xquartz.org/) - X Windows for mac - this is the framework that the app expects

At the time of writing the versions in use were:

- R: R-4.3.2-x86_64 (intel) / R-4.3.2-arm64 (apple silicon)
- RStudio: 2023.12.0-369
- XQuartz: 2.8.5

## Installation

You can either install them directly using the links above - or - if you use mac [homebrew](https://brew.sh/) then you can install using that.

```shell
brew install --cask r
brew install --cask rstudio
brew install --cask xquartz
```

## Application code

The app code can be downloaded from the github repository download as zip using a browser (and then unzip it in Finder) - or with git:

```shell
git clone git@github.com:deepskydetail/AstroSharp.git
```

## Setup

Create a working directory somewhere you want to keep the app code:

Example:

```shell
mkdir R_WD
```

Copy the resources/app directory from the app download into this directory - either via Finder or directly:

Example:

```shell
cp -R Downloads/AstroSharp-DualPSF/resources/app R_WD
```

Open RStudio - set the working path to R_WD (under Preferences > General > Basic > R Sessions)

Restart RStudio - at this point - the app folder should appear in the tree in the RStudio window bottom right.

## Dependencies

Open app/appPSFBeta.R from this folder tree.

A warning should appear above the code stating that some packages are required but are not installed - click the `Install` link in the warning.

At the time of writing there were 58 dependencies that were installed.

Once complete - in the console area of RStudio (bottom left) - run the following:

```
install.packages("remotes")
remotes::install_github("bips-hb/neuralnet")
```

## Run the app

Now all you should need to do is hit the Run App button above the code in RStudio - upload a TIFF and get editing :)
