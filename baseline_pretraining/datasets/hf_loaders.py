from datasets import load_dataset
from ..env_vars import ROOT_DIR, DATASET_ROOT_DIR
import os
import baseline_pretraining

repo_path = baseline_pretraining.__path__[0]


def get_babyLM(name, split):
    dataset = load_dataset(
            path=os.path.join(
                repo_path, 'datasets', "babyLM_for_hf.py"),
            name=name,
            split=split, trust_remote_code=True)
    return dataset
