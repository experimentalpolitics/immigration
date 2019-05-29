<!--- 
    Created by Nicholas R. Davis (nicholas@democracyobserver.org)
    on 2019-04-23 14:17:55. Intended for GitHub distribution.

    experimentalpolitics/immigration/declaredesign-notes 
 -->

# Notes on DeclareDesign Implementation

Included here are some notes on installing and implementing DeclareDesign in `R`. 

## Installation

Platform details: macOS Mojave 10.14.4 running R version 3.5.3 (2019-03-11).

* tried to install with `install.packages("DeclareDesign", dependencies = TRUE, repos = c("http://R.declaredesign.org", "https://cloud.r-project.org"))` and load; failure to load dependency package `estimatr` 
    - error appears to be caused by a bad version of the `estimatr` package in those repos, although this has not be confirmed 
    - solved by uninstalling and reinstalling that package 
    - installing without indicating those repos should result in avoiding the error 
* loading the library also loads several required packages 

## Usage

I replicated the example on their help wiki to see how the code works. The code with some of my comments is shared in an R file - you can clone or fork to get your own copy and try this. Here is what I learned.

This is a helpful background on the idea of the setup: https://declaredesign.org/idea/. They also have the paper (prepublished) posted here: https://declaredesign.org/paper.pdf.

It looks like we need to specify the various components of the design according to our needs. This pappears to be fairly flexible, although I need a better understanding of how our data structure is to be confident I can do it correctly. 

I got the code to run, and it produces comparable output to the examples provided by them. It is not obvious how to fit our 2x2x2 design in here, but I am sure it is a matter of better understanding how to tweak the code specifying the various components.

## Recommendations for our implementation

... Stopped here; will continue later. 