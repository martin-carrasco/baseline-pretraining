
# Setup 

## Virtual environment
First we need to set-up a virtual environment to be able to manage packages. There are plenty of choices out there for environment managers but we will give a brief explanation of the two most popular ones: pyenv and conda

### Installation 

#### Conda (Miniconda)
The complete installation guide can be found [here](https://docs.anaconda.com/miniconda/miniconda-install/). However, we will detail steps for macOS and Linux. We will use a distribution of *Conda* called *Miniconda* which is somewhat smaller.


##### Linux

First create a directory for miniconda
```
mkdir -p ~/miniconda3
```
then get the installation script (for x86_64)
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
```
or for x64 architecture 
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
```
Now, execute the script and pass the path set in the first command as conda's home. Enter your settings and leave as default if not sure.
```
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
```
Depending on your shell you can initialize with the following command
```
~/miniconda3/bin/conda init bash
```
if you use a different shell replace `bash` with it. 

To make sure the install is working close your current terminal and reopen another one with your specified shell and run `conda list`.

finally, delete the install script
```
rm ~/miniconda3/miniconda.sh
```

##### MacOS
First create a directory for miniconda
```
mkdir -p ~/miniconda3
```
then get the installation script (for arm64)
```
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -O ~/miniconda3/miniconda.sh
```
Now, execute the script and pass the path set in the first command as conda's home. Enter your settings and leave as default if not sure.
```
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
```
Depending on your shell you can initialize with the following command
```
~/miniconda3/bin/conda init zsh
```
if you use a different shell replace `zsh` with it. 

To make sure the install is working close your current terminal and reopen another one with your specified shell and run `conda list`.

finally, delete the install script
```
rm ~/miniconda3/miniconda.sh
```

#### pyenv

The oficial repository of pyenv [here](https://github.com/pyenv/pyenv) has some very detail installation instructions, but we will cover a basic usage here.

##### Linux
##### MacOS


### Creating an environment
To use this library we will need to create a particular environment using Python version 12.1 and up.

1. First, we create en environment using either Conda or Pyenv
    1. With conda
        1. Run `conda create --name test_env python=3.12`
    2. With pyenv
        1. First we install Python 3.12 using `pyenv install 3.12`
2. Now we activate our environment
    1. With conda
        1. Run `conda activate test_env` to use the current envionment
    2. With pyenv
        1. This will be done locally on the next step

## Installing poetry
Poetry is a dependancy manager that helps managing dependencies in projects. This project uses poetry to manage dependencies on CPU and GPU pytorch versions. More information can be found here [here](https://python-poetry.org/docs/).

A very simple way to install it is on your global python install (outside any virtual environment) run `pip install poetry`. That should be enough to enable poetry as a command.


## Package management
Each environment we created represents a particular python version an a set of *packages* installed for the interpreter.
Different projects might require different packages as dependancies change, to handle that this repository uses poetry to configure
*a particular python interpreter instance*. For the macOS installation checkout branch `macos`.
1. First, make a directory, in this case we will name it `babylm_test` with `mkdir babylm_test` and `cd babylm_test`
2. Then, clone this repository
3. Clone the supporting repository https://github.com/martin-carrasco/pt_framework
4. Go inside the repo using `cd baseline-pretraining` and activate your environment
    1. Using conda `conda activate test_env`
    2. Using pyenv `pyenv local 3.12`
    3. Using Makefile `make conda` or `make pyenv` or `make env` (last one uses conda by default or else pyenv)
5. Install the dependencies
    1. MacOS (checkout branch `macos`)
        1. With torch cpu based libraries just run `poetry install`
        2. With torch gpu based libraries run `poetry install --with gpu121`
    2.  Linux 
        1. With cpu `poetry install`
        1. With gpu `poetry install --with gpu121`

## Loading up the traning data
First, define the environment variable `BABYLM_ROOT_DIR` to be where your models and data will live.
The downloaded data should be put at `${BABYLM_ROOT_DIR}/datasets/` so that this folder contains the following four subfolders: `babylm_100M`, `babylm_10M`, `babylm_dev`, and `babylm_test`. Note that the T5 training script expects .txt file inputs, so we create a single dev file by running this command in the `${BABYLM_ROOT_DIR}/datasets/babylm_dev/` folder: `cat *.dev > babylm_dev.txt`.
The trained models will be put at `${BABYLM_ROOT_DIR}/models/` and the records will be put at `${BABYLM_ROOT_DIR}/model_recs/`.

# Execution

## Parameters
Learning rate schedule is defined at function `get_learning_rate_params` in script `basic_param_setter.py` under `src/babylm_baseline_train` folder.


## Training

### OPT-125M
Run the following command under the `scripts` folder.
```
python -m torch.distributed.run --nproc_per_node=1 --master_port=29123 baseline_pretraining/scripts/general_train.py --setting "BabyLM/exp_strict.py:opt125m_s1"
```

This command will load a training setting specified by function `opt125m_s1` at `src/babylm_baseline_train/configs/BabyLM/exp_strict.py`.

### RoBERTa-Base
Run the following command under the `scripts` folder.
```
python -m torch.distributed.run --nproc_per_node=1 --master_port=29123 baseline_pretraining/scripts/general_train.py --setting "BabyLM/exp_strict_mask.py:roberta_s1"
```

### T5-Base
Run the following command under the `scripts` folder.
```
./train_t5_babylm.sh
```
Note that this training script uses a different backend than the OPT and RoBERTa models. This script is a slightly modified version of the `flax` T5 pre-training script from huggingface; the original [lives here](https://github.com/huggingface/transformers/tree/main/examples/flax/language-modeling).

Optimizer is in the `scripts/general_train.py` script inside the `get_key_params` funciton.

## Prediction
### How to load the pretrained models

See the functions in `src/babylm_baseline_train/models/ckpt_loader.py`.