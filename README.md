# A novel approach to trading strategy parameter optimization, using double out-of-sample data and walk-forward techniques on cryptocurrency market 


## Overview
This repository contains code to reproduce research results (tables,charts) contained  in the paper "A novel approach to trading strategy parameter optimization,
using double out-of-sample data and walk-forward techniques on cryptocurrency market" 






authors :
- Tomasz Mroziewicz  ORCID: https://orcid.org/0009-0003-6540-6554, email: t.mroziewic2@student.uw.edu.pl
- Robert Ślepaczuk   ORCID: https://orcid.org/0000-0001-5227-2014, corresponding author: rslepaczuk@wne.uw.edu.pl 

##DVC
This research is fully reproducible using **[Data Version Control (DVC)](https://dvc.org/)** — an open-source tool for versioning data, models, experiments, and machine learning pipelines.

### Key files
- `dvc.yaml` — defines the complete pipeline (stages, dependencies, outputs, commands)
- `params.yaml` — contains all configurable hyperparameters and settings
- `dvc.lock` — locks exact versions of data, models, metrics, and code outputs



## Repository Structure
- **data**: Contains result of walk forward optimization, data could be regenerated using DVC project stored in the wf_optim_crypto
- **reports** script for generating actual pdf 
- **experiments/**: Each experiment is stored in its own self-contained branch to keep the history clean.
- dvc.yaml all procesing steps are defined 
- params.yaml all params used by dvc.yaml are defined
- config.r file containing location of wf_optim_crypto
- wf_optim_conda.yaml - file containing configuration file to create Anaconda environment 



#Prerequistits 
You can choose or install dependencies manually in R/Python, or use Anaconda package manager to ensure all prerequisites are installed

## Manual installation 

**Python**: version 3.9.10 or higher.
**DVC**: version 3.10 or higher. Install via 
```bash
pip install dvc
**R**: version 3.6 or higher.
**R packages** 
**Miktex**  as PDF is the result, Pdflatex is needed,

## Package manager - Conda Environment Setup (Prerequisites)
To ensure everyone gets the **exact same versions** of Python, libraries, and dependencies (critical for reproducing research results), 
use **Conda** to create an isolated environment from the provided YAML file.

1. **Download and install Miniconda**:
2. **Create the project environment inside Anaconda Prompt***
- Open **Anaconda Prompt**
- Navigate to `wf_optim_crypto_analysis\conda_env` (If you want to change the environment name, edit the file wf_optim_conda.yaml before creating the environment.)
- Run the following command:

```bash
conda env create -f wf_optim_conda.yaml

After the environment is created, verify that it can be activated.
If you changed the environment name in the YAML file, replace `wf_optim` with the new name:

```bash
conda activate wf_optim
```
3. **Miktex**  as PDF is the result, Pdflatex is needed, standalone installation is required as Miktex delivered as Anaconda package was not compatible with this project
	- During Miktex installation choose  following options 
			- Install for all users 
			- Enable Install missing packages on-the-fly 


## How to reproduce results presented in the paper
Results of research presented in the paper could be reproduced in form PDF containing tables and charts. Follow procdure:
- Clone this repository git clone https://github.com/tmroziewicz/wf_optim_crypto_analysis wf_optim_crypto_analysis
- Clone depended repository git clone https://github.com/tmroziewicz/wf_optim_crypto wf_optim_crypto
- Navigate to repository cd wf_optim_crypto_analysis
- Configure WF_CRYPTO_REPO path inside config.r where  wf_optim_crypto is located
- Download data from https://drive.google.com/drive/folders/1HAYX3iUfO5ewWXlWK0MbOAu9HQ4l6Zzr
	Note: Alternatively  you can generate all data by yourself using wf_optim_crypto, this will perform walk forward analysis.
- Unzip downloaded file into data folder, make sure that data folder has structure as zip 
- Execute dvc pipeline where all execution will be performed:  dvc repro --force 
- When command finished 
	- open file in the outupf\wf_optim_crypto_charts_table.pdf , file contains all charts and tables from research
	- output folder contains also intermediate data in form or *.rds files used for generating the content 
