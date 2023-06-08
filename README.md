# Predicting Kidney Transplant Graft Survival using a Cluster-Then-Predict Framework
Kidney Transplantation is a life-changing procedure that increase a patient’s
lifespan for decades. Acute rejection is the primary risk factor and incurs significant
costs on human life and the healthcare system. Kidney donations are in short
supply, so each one must be allocated carefully. Machines learning models have been
developed to predict graft survival to aid decision making in clinical practice. To
date, they have not outperformed traditional statistical methods and have generally
suffered from insufficient evaluation. We propose a novel strategy using a
cluster-then-predict framework by utilising a large dataset of over 2500 kidney
transplants containing donor and recipient characteristics and transplant factors. 

## Overview

This repository documents Aoife McDaid and Diarmuid Brady's final year project.

Our final report submission can be found here [Final Report](reports/deliverables/Final_Report.pdf).

You can learn more about the project using the [research proposal](reports/deliverables/research_proposal.pdf).

The repository follows the file structure from [nbdev](https://nbdev.fast.ai/)

Branch names follow the conventions outlined in this [DeepSource Article](https://deepsource.io/blog/git-branch-naming-conventions/).

## File Structure
The repository has six main directories; data, docs, environments, kidney_tranplant_prediction, nbs, reports.

### data
The data is not present on github for GDPR and access reasons.

However, the _data_ directory consists of three directories; _raw_, _interim_, and _proc_. _Raw_ contains the data and is never touched. _interim_ is a copy of _raw_ and it contains data that is allowed to be manipulated. When the data from _interim_ has been processed, it is saved in the _proc_ directory. _proc_ must only contain data that is processed.

### docs 
_docs_ contains relevant documentation on how the code works or how to use certain modules created.

### environments
_environments_ contains the environment files used to aid reproducibility of analysis. It also contains a file used for setting up jupyter lab on the high performance cluster.

### kidney_tranplant_prediction
This includes a number of importable python functions and variables exported from the _nbs_ directory. The file names are generated from the comment in the top cell of a notebook.
```
# default exp *name*
```
Then all the code in files can be found in the cells with `#| export` at the top.

### nbs
_nbs_ contains all notebooks used for analysis. This notebooks are then converted to python files available in _kidney\_transplant\_prediction_ as importable files.

### reports
_reports_ contain a variety of supporting documents. Firstly, _deliverables_ contain documents that are specific to the grading of our project such as the [research proposal](reports/deliverables/research_proposal.pdf) and [final report (not yet complete)](). _figures_ includes all visualisations generated during analysis. This will not be an exhaustive list, instead only the key visuals need for supporting documents.
