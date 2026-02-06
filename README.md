
<div align="center">

# Walk-Forward Crypto Optimization - A novel approach to trading strategy parameter optimization, using double out-of-sample data and walk-forward techniques 📈
### High-performance backtesting and data pipeline orchestration.


![DVC](https://img.shields.io/badge/DVC-945DDB?style=flat-square&logo=data-version-control&logoColor=white)
![R](https://img.shields.io/badge/R-276DC3?style=flat-square&logo=r&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.9+-blue?style=flat-square&logo=python)
![Conda](https://img.shields.io/badge/Conda-Managed-green?style=flat-square&logo=anaconda)



</div>

authors :
- Tomasz Mroziewicz  ORCID: https://orcid.org/0009-0003-6540-6554, email: tomasz.mroziewicz2@gmail.com
- Robert Ślepaczuk   ORCID: https://orcid.org/0000-0001-5227-2014, corresponding author: rslepaczuk@wne.uw.edu.pl 


## Abstract 
This study introduces a novel approach to walk-forward optimization by parameterizing the
lengths of training and testing windows. We demonstrate that the performance of a trading
strategy using the Exponential Moving Average (EMA) evaluated within a walk-forward procedure
based on the Robust Sharpe Ratio is highly dependent on the chosen window size. We
investigated the strategy on intraday Bitcoin data at six frequencies (1 minute to 60 minutes)
using 81 combinations of walk-forward window lengths (1 day to 28 days) over a 19-month training period. The two best-performing parameter sets from the training data were applied to a 21-month out-of-sample testing period to ensure data independence. The strategy was only
executed once during the testing period. To further validate the framework, strategy parameters
estimated on Bitcoin were applied to Binance Coin and Ethereum. Our results suggest the robustness of our custom approach. In the training period for Bitcoin, all combinations of walk-forward windows outperformed a Buy-and-Hold strategy. During the testing period, the strategy
performed similarly to Buy-and-Hold but with lower drawdown and a higher Information Ratio.
Similar results were observed for Binance Coin and Ethereum. The real strength was demonstrated
when a portfolio combining Buy-and-Hold with our strategies outperformed all individual
strategies and Buy-and-Hold alone, achieving the highest overall performance and a 50%
reduction in drawdown. A conservative fee of 0.1\% per transaction was included in all calculations. A cost sensitivity analysis was performed as a sanity check, revealing that the strategy's break-even point was around 0.4\% per transaction. This research highlights the importance of optimizing walk-forward window lengths and emphasizing the value of single-time out-of-sample testing for reliable strategy evaluation.

<img width="400" alt="image" src="https://github.com/user-attachments/assets/6644af88-b8d4-4517-aba3-3b9ba58875cd" />                  <img width="395"  alt="image" src="https://github.com/user-attachments/assets/8d4dfe3d-70a2-4c42-8b4c-5cebf5a0873f" />



## Overview
This repository contains the reproduction code for the tables and charts presented in our paper. It is designed to ensure computational transparency and replicability of our findings.

🛠 System Architecture
The project relies on a modular setup where data generation and data processing are decoupled:

- Upstream Data: Trading data generation is managed in the external [wf_optim_crypto](https://github.com/tmr-crypto/wf_optim_crypto) project.

- Orchestration: We use Data Version Control (DVC) to manage the data flow, calculation dependencies, and experiment versioning.

- Execution: All statistical computations and visualizations are performed using R.

📊 Main Output
The primary result of this pipeline is a reproduced PDF document. This document contains charts and tables that are numerically and visually identical to those published in the original paper.

🏗️ Pipeline Orchestration
This research is fully reproducible using Data Version Control (DVC) — an open-source tool for versioning data, experiments, and machine learning pipelines.
  
## Repository Structure
- 🐍 conda_env/wf_optim_conda.yaml: Configuration file for creating the Anaconda environment

- 📂 data: Empty in Git; populate via Google Drive or the wf_optim_crypto project

- 📂 output: Stores generated .rds files and the final PDF report

- 📊 reports: R Markdown scripts for generating the final PDF

- 📜 scripts: R scripts executed by the DVC pipeline

- ⚙️ config.r: Defines the local path to the wf_optim_crypto project

- 🏗️ dvc.yaml: Defines all automated data processing stages

- 🛠️ params.yaml: Defines all parameters used by the DVC pipeline

- 📖 README.md: Project documentation and setup guide
  
## Data Acquisition
To run this pipeline, you need the underlying trading data located in the `wf_optim_crypto_analysis\data` directory. You can obtain this data using one of two methods:

**Option 1**: Direct Download (Recommended)

- This is the fastest way to get started using the exact datasets used in the original research.

- Download the pre-calculated trading data from this [wf_optim_crypto_analysis.zip](https://drive.google.com/file/d/1y7J3cGFEYYBufVTACzPYr4GXiUSCOKm7/view?usp=drive_link) (76 MB) stored on  Google Drive .

- Extract/Copy the files into the following directory: wf_optim_crypto_analysis\data

**Option 2**: Full Reproduction

- Choose this option if you wish to audit the data generation process or modify the underlying trading logic.

- Clone and run the `wf_optim_crypto` repository.

- Generate the datasets according to that project's instructions.

- Transfer the resulting output files to: `wf_optim_crypto_analysis\data`

- More information about data generation and exporting can be found in the associated repository [Export Guide](https://github.com/tmr-crypto/wf_optim_crypto#export-guide) 

## Prerequisite 
You can either install R/Python dependencies manually or use Anaconda to install prerequisites at once.

### Option 1 - Manual installation 
Project need following  
- **Python**: version 3.9.10 or higher.
- **R**: version 3.6 or higher.
	- install the R packages by running this in your R console:
	```
	install.packages(c("tidyverse", "PerformanceAnalytics", "tseries", 
	                   "psych", "rmarkdown", "kableExtra", 
	                   "here", "optparse", "ggtext", "latex2exp"))
	```
- **DVC**: version 3.10 or higher. Install via 
	```
	pip install dvc
	```
- **Miktex**:  required for PDF output (`pdflatex`) a standalone installation is required.
	- Download [Miktex](https://miktex.org/download)
 	- During Miktex installation choose  following options 
		- Install for all users 
		- Enable Install missing packages on-the-fly 

### Option 2 - Anaconda Environment Setup
To ensure everyone gets the **exact same versions** of Python, libraries, and dependencies (critical for reproducing research results), 
use **Anaconda** to create an isolated environment from the provided YAML file.

1. **Download and install Miniconda**
	- Download [Anaconda Mini](https://www.anaconda.com/download/success)
	- Follow the installation instruction [Anaconda Installation](https://www.anaconda.com/docs/getting-started/miniconda/install#windows-installation)
1. **Create the project environment*
	- Open **Anaconda Prompt**
	- If you have already cloned this repo, navigate to `wf_optim_crypto_analysis\conda_env` where **Anaconda** yaml file is located defining environmnent and packages  (If you want to change the environment name, edit the file wf_optim_conda.yaml before creating the environment.)
	- Run the following command:
	
	```bash
	conda env create -f wf_optim_conda.yaml
	```
2. After the environment is created, verify that it can be activated.
	If you changed the environment name in the YAML file, replace `wf_optim` with the new name:
	
	```bash
	conda activate wf_optim
	```
3. **Miktex** same procedure as above for manual installation. MiKTeX package distributed via Anaconda is not compatible with this project.


## How to Reproduce Results
Results from the paper can be reproduced as a PDF containing all original tables and charts. Follow this procedure:

- 🐍 Open Anaconda Prompt: (Skip this if you chose manual installation). Activate the environment created in the prerequisites:
  ```
  conda activate wf_optim
  ```

- :inbox_tray: Clone this repository:
  ```
  git clone https://github.com/tmr-crypto/wf_optim_crypto_analysis wf_optim_crypto_analysis
  ```

- :inbox_tray: Clone depended repository:
  ```
  git clone https://github.com/tmr-crypto/wf_optim_crypto wf_optim_crypto
  ```

- 📂 Navigate: Go to your cloned repository folder wf_optim_crypto_analysis.

- ⚙️ Configure Path: If both cloned projects are in the same parent folder, skip this. Otherwise, update the WF_CRYPTO_REPO path inside config.r to point to your wf_optim_crypto location.

- :inbox_tray: Data Acquisition: Populate the data folder by following the instructions in the [Data Acquisition](#data-acquisition) section.

- 🏗️ Execute Pipeline: Run the DVC pipeline to perform all calculations:

```
dvc repro --force
```
📊 Review Results: Once execution finishes:
- Open output\wf_optim_crypto_charts_table.pdf for the final tables and charts.
- The output/ folder also contains intermediate data in *.rds format.
