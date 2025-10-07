# FYD for SBL fMRI data

LC Oct 2025

<br>

The FYD (Follow Your Data) platform allows you to place json file descriptors for your data on the disk where the data is, so that it can be discovered and added to the platform for data exploration and retrieval.

Importantly, the values contained in the json file *must be already registered in the FYD database* for the json file to be valid. 

To this aim, the FYD web interface (https://nhi-fyd.nin.nl/) currently provides two functionalities: 

- register the project as well as the respective values of the (mandatory) fields for that project in the FYD database. One of these fields is the subject ID, which also needs to be registered in the web interface.
- download the corresponding json file. NB: on your *local* directory, not in the final location where you intend to place it.

There are two important things to understand here:

- every subject ID must be registered separately, and must be _unique_ across projects for the same lab (!)
- the web interface allows you to download the json file, but *does not* automatically place it in the final destination. That is up to you.

**The main issue is therefore with the number of subjects, which can be in the hundreds.** It becomes therefore impractical - and prone to mistakes - to use this interface to register and produce the json one by one (let alone copying them to their final destination).

There are however two good news:

- only 6 fields - besides the `subject` field - are mandatory in the json, namely `project`, `dataset`, `condition`, `stimulus`, `setup`, `investigator`. If the dataset is such that these fields can be considered as constant, they just need to registered once on the web interface. Once this is done, valid json files can be generated programmatically (i.e. using a script), and directly saved to their final locations.

- the registration of the subjects can also be done programmatically by writing directly in the FYD database e.g. using a python script. This can be achieved as easily as by providing a text file with one subject ID per row.

  

Admittedly this is still quite complex, but if the dataset allows to be organized simply, the whole procedure can be carried out efficiently and with a reasonable effort.

In the case of of fMRI data, this can be done if we keep the data organized in the following simple structure:

- all the raw data is contained in one folder.
- in this raw data folder, there is exactly one folder for each subject - which internally can contain multiple sessions and runs.
- there is a clear pattern in the naming of the subject folders, e.g. `sub-001`, `sub-003`, `sub-023`.
- each subject is associated only with one json file, which is placed at the top level of the subject's folder.



The main idea for the procedure is the following:

1. Choose a simple organization for your raw data folder (like the one suggested - see below for an example)
2. Go to [FYD](https://nhi-fyd.nin.nl/), create your new project and register the mandatory fields for that project. Note that some of them could be already present, like there could be already a `fmri_7T` registered value for the `setup` field.
3. Create a text file with a list of all you subject IDs (e.g. [list_subj.txt](https://github.com/leonardocerliani/FYD_SBL/blob/main/list_subj.txt)) and feed it into a first notebook that will generate the json files based on a template (e.g. [01_generate_json.ipynb](https://github.com/leonardocerliani/FYD_SBL/blob/main/01_generate_json.ipynb)). The values of each field in the template must reflect *exactly* the values that you previously registered in the FYD interface (see below an example template). 
4. Copy the files in the appropriate folders. This can be easily integrated in the script that generates the json files, although the present code in the repo does not do it.
6. Use the second python notebook (e.g. [02_register_subj_on_FYD.ipynb](https://github.com/leonardocerliani/FYD_SBL/blob/main/02_register_subj_on_FYD.ipynb)) - to register the subjects on FYD. 



## Access

In order to access FYD (https://nhi-fyd.nin.nl/) you need to be connected via ethernet to the NIN network. The connection with other wifi is also possible (e.g. eduroam) although I am not sure of which of the many wifi networks at the NIN grant access to FYD.

NB: username is your NIN uname (e.g. cerliani) and pw is the one used for Microsoft.



##  Procedure to create the json files and register them in the FYD db



### Disclaimer

***You accept to use the code in this github repository at your own risk. I am not in any way responsible for potential data loss that could derive from any use of this code or part of it. If you use this code, you agree and accept with the content of this disclaimer and you take full responsibility for any consequence that will derive from that*.**

*It is important to understand that you cannot run the notebooks as they are in the current state provided on this github repository. Rather you need to adapt a few variables according to the structure of your dataset and your needs in terms of field values. For instance, there are procedures in the notebooks to retrieve the numerical ID associated with your project and to set this as the value for the `project_id` in the [02_register_subj_on_FYD.ipynb](https://github.com/leonardocerliani/FYD_SBL/blob/main/02_register_subj_on_FYD.ipynb). You should inspect this by yourself and manually set the correct value for `project_id`.*

*The procedure has been tested on a Mac and for sure it works also on Linux. I am not familiar with windoze, but it should work there as well. If there are some substantial differences and you have found how to adapt the code for windoze, feel free to let me know.*



### First step

Read, understand and accept the Disclaimer above.



### Creating a python virtual environment and running the notebooks

You should make sure that you have python in your system, or download and install it (most likely you already have it). I used python 3.12.9, but other relatively recent 3.x.x versions should be fine.

We will need to use python both for creating the json files and to register them in the FYD db. Since we will be using jupyter notebooks, we also need the libraries for that.

```python
python -m venv venv_FYD
source vevn_FYD/bin/activate
pip install -r requirements.txt
# These are basically the libraries that the requirements.txt will install:
# python-dotenv pandas numpy jupyter "notebook<7.0.0" datajoint itables
```

To open the notebooks and run the code inside them, just go to a terminal and launch `jupyter notebook` or `jupyter lab`. This will open a browser interface to load the desired notebook.



### Choose a simple organization of the raw files

```bash
e.g. /data01/7T_Emotion_Insula/Data_collection/raw_data

raw_data
├── sub-02
├── sub-03
...
├── sub-34

```

Of course inside the sub folders you can have as many subfolders you want (e.g. for sessions). The idea is to have _only one json for each subject_, so the level-1 organization is all we will care about for the FYD.

The unicity of the subject ID will be determined by the association of the sub-### and the project name, for instance, we will generate json files named:

```
sub-02_7T_Emotion_Insula_session.json
sub-03_7T_Emotion_Insula_session.json
...
sub-34_7T_Emotion_Insula_session.json
```

Note that the directory names and the names of the files inside the directories are _independent_ from the subject ID we will place in the `_session.json`. The latter is only for FYD, and our only concern is that it is unique across all the projects of our lab (that is the requirement and I cannot do anything about that)



### Create a list_subj.txt file

This is very simple from the terminal (I assume you are on storm or in general in a bash terminal. I am not sure how this can be achieved in the windoze powershell). For instance in the case of the structure of directories above, it is as simple as doing

```bash
# list all the directories (i.e. folders) that start with 'sub' 
# and write the result in a file called list_subj.txt
ls -d sub* > list_subj.txt
```

This is the file that we will feed into the script to generate the json files according to the template.



### Register the new project on FYD and the mandatory fields

At this point you should head to https://nhi-fyd.nin.nl/, create a new project and fill in *only once* all the fields that you will keep stable across subjects. Everything explained below works for the case in which all the mandatory fields (see above) always remain the same, and the only field that changes is the subject field.

**IMPORTANTLY, ONCE REGISTERED, THESE VALUES SHOULD NOT BE CHANGED, SO CHOOSE THEM WISELY.**

Note that I am pretty sure you also need to register one subject. You can give a temporary name and remove it later.

Below you can see an example

![](./assets/fyd_create_fields.png)



### Fill in a json template

Once you have registered all the fields that will not change, you build a template for the json files using exactly the same field names you just registered. Make sure you do not make typos here!

```python
json_template = {
    "project": "7T_emotion_insula",
    "dataset": "MRI_Emotion_observation",
    "condition": "Emotion_Movies",
    "subject": "SUB_ID",
    "stimulus": "emotion_faces_videos",
    "setup": "fMRI_7T",
    "investigator": "LeonardoCerliani",
    "date": "2024-01-01",
    "version": "1.0",
    "logfile": "",
    "comment": ""
}
```



The only field that should not be entered manually is of course the "subject", for which here I just put a placeholder. Note that to make the SUB_ID unique, we will replace it not just with the content of one line of the `list_subjects.txt` , but also with a `project_label` variable inside the notebook, in order to ensure the unicity of the subject name across all the projects in the lab.



### Generate the json files

You should now open and adapt the `generate_jsons.ipynb` notebook according to your needs.

Make sure that 

- you have the correct project label
- the json template reflects the fields you registered online
- the `list_subj.txt` has exclusively the following content: one user ID in each row.



Next, the `generate_jsons.ipynb` will generate spaceless (as required) jsons using 

- the information contained in the json template
- the subj_list.txt



Note that when the json file has been generated, you will still have to place it in the appropriate subject directory for each subject. I strongly recommend you to use a simple bash command for that or just edit the notebook and do it directly in python.



### Registering the subjct-IDs on FYD

This is something that can be done programmatically using `datajoint`. An example is in `02_register_subj_on_FYD.ipynb`. Other information (the classes for other tables) can be found on the [github of the FYD Python client](https://github.com/Herseninstituut/FYD_Python/blob/main/DJ/examplelab.ipynb). 

NB: in the notebook there are also examples showing how to _remove_ subjects. Check the last cells.



### Verify the results

At any moment, you can use the [00_view_project_state.ipynb](https://github.com/leonardocerliani/FYD_SBL/blob/main/00_view_project_state.ipynb) notebook to access your project and verify its state in terms of subjects registered.

