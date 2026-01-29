# A novel approach to trading strategy parameter optimization, using double out-of-sample data and walk-forward techniques on cryptocurrency market 
authors :
- Tomasz Mroziewicz  ORCID: https://orcid.org/0009-0003-6540-6554, email: t.mroziewic2@student.uw.edu.pl
- Robert Ślepaczuk   ORCID: https://orcid.org/0000-0001-5227-2014, corresponding author: rslepaczuk@wne.uw.edu.pl 


## Overview
This repository contains the reproduction code for the tables and charts presented in our paper. It is designed to ensure computational transparency and replicability of our findings.

🛠 System Architecture
The project relies on a modular setup where data generation and data processing are decoupled:

- Upstream Data: Trading data generation is managed in the external wf_optim_crypto project.

- Orchestration: We use Data Version Control (DVC) to manage the data flow, calculation dependencies, and experiment versioning.

- Execution: All statistical computations and visualizations are performed using R.

📊 Main Output
The primary result of this pipeline is a reproduced PDF document. This document contains charts and tables that are numerically and visually identical to those published in the original paper.

## Clone 
- Clone this repository
  ```
  git clone https://github.com/tmroziewicz/wf_optim_crypto_analysis wf_optim_crypto_analysis
  ```
- Clone depended repositor
  ```
  git clone https://github.com/tmroziewicz/wf_optim_crypto wf_optim_crypto
  ```

  
## Repository Structure
- 🐍 conda_env/wf_optim_conda.yaml: Configuration file for creating the Anaconda environment

- 📥 data/: Empty in Git; populate via Google Drive or the wf_optim_crypto project

- 📤 output/: Stores generated .rds files and the final PDF report

- 📊 reports/: R Markdown scripts for generating the final PDF

- 📜 scripts/: R scripts executed by the DVC pipeline

- ⚙️ config.r: Defines the local path to the wf_optim_crypto project

- 🏗️ dvc.yaml: Defines all automated data processing stages

- 🛠️ params.yaml: Defines all parameters used by the DVC pipeline

- 📖 README.md: Project documentation and setup guide
  
## Data Acquisition
To run this pipeline, you need the underlying trading data located in the wf_optim_crypto_analysis\data directory. You can obtain this data using one of two methods:

**Option 1**: Direct Download (Recommended)
- This is the fastest way to get started using the exact datasets used in the original research.

- Download the pre-calculated trading data from this Google Drive Folder.

- Extract/Copy the files into the following directory: wf_optim_crypto_analysis\data

**Option 2**: Full Reproduction
- Choose this option if you wish to audit the data generation process or modify the underlying trading logic.

- Clone and run the wf_optim_crypto repository.

- Generate the datasets according to that project's instructions.

- Transfer the resulting output files to: wf_optim_crypto_analysis\data


## Prerequisite 
You can either install R/Python dependencies manually or use Anaconda to install all prerequisites at once.

### Option 1 - Manual installation 
Project need following  
- **Python**: version 3.9.10 or higher.
- **R**: version 3.6 or higher.
- **DVC**: version 3.10 or higher. Install via 
```bash
pip install dvc
```
- **Miktex**:  required for PDF output (`pdflatex`); a standalone installation is required, as the MiKTeX package distributed via Anaconda is not compatible with this project.
	- Download https://miktex.org/download
 	- During Miktex installation choose  following options 
		- Install for all users 
		- Enable Install missing packages on-the-fly 

### Option 2 - Package manager installation - Conda Environment Setup
To ensure everyone gets the **exact same versions** of Python, libraries, and dependencies (critical for reproducing research results), 
use **Conda** to create an isolated environment from the provided YAML file.

1. **Download and install Miniconda**
	- Download https://www.anaconda.com/download/success
	- Follow the installation instruction https://www.anaconda.com/docs/getting-started/miniconda/install#windows-installation
1. **Create the project environment inside Anaconda Prompt***
	- Open **Anaconda Prompt**
	- Navigate to `wf_optim_crypto_analysis\conda_env` where **Anaconda** yaml file defining environmnent and packages  (If you want to change the environment name, edit the file wf_optim_conda.yaml before creating the environment.)
	- Run the following command:
	
	```bash
	conda env create -f wf_optim_conda.yaml
	```
1. After the environment is created, verify that it can be activated.
	If you changed the environment name in the YAML file, replace `wf_optim` with the new name:
	
	```bash
	conda activate wf_optim
	```
1. **Miktex** same procedure as above for manual installation 

## DVC
This research is fully reproducible using **[Data Version Control (DVC)](https://dvc.org/)** — an open-source tool for versioning data, models, experiments, and machine learning pipelines.

### Key DVC files
- `dvc.yaml` — defines the complete pipeline (stages, dependencies, outputs, commands)
- `params.yaml` — contains all configurable hyperparameters and settings
- `dvc.lock` — locks exact versions of data, models, metrics, and code outputs

## How to reproduce results presented in the paper
Results of research presented in the paper could be reproduced in form PDF containing tables and charts. Follow procdure:
- Open **Anaconda Prompt**
- Activate environment `wf_optim` (or your name if you changed it) created in prerequistits
  ```
  conda activate wf_optim
  ```
- Navigate to folder where repository was cloned `wf_optim_crypto_analysis`
- If both cloned projects folders are located in the same folder, you can skip that step. If folders has different location change `WF_CRYPTO_REPO` path inside `config.r` pointing to location of  `wf_optim_crypto`. 
- In order to populate **data** folder follow the instruction from [Read more in Data Acquisition](#data-acquisition)
	- **Note**: Alternatively  you can generate all data by yourself using wf_optim_crypto, this will perform walk forward analysis.
- Unzip downloaded file into data folder, make sure that data folder has structure as zip 
- Execute dvc pipeline where all execution will be performed:
  ```
  dvc repro --force
  ```
- When command finished 
	- open file in the `output\wf_optim_crypto_charts_table.pdf` , file contains all charts and tables from research
	- output folder contains also intermediate data in form or `*.rds` files used for generating the content 
