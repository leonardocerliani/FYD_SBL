# Simplified procedure for SBL FYD

LC Nov 2025

## 1. Cloning the repo with the code
Clone [this repo](https://github.com/leonardocerliani/FYD_SBL/tree/main)

## 2. Create a text file with subject ID
Create a `list_subj.txt` with one sub ID per line, e.g.

```
sub-02
sub-03
sub-05
sub-07
sub-09
sub-10
```


## 3. Register the project on the FYD platform
3. register the project [here](https://nhi-fyd.nin.nl/) (note that you need to be on the NIN network to access), as well as the following parameters, and note down **exactly** how you wrote them.

Example:

```
project         7T_emotion_insula
dataset         MRI_Emotion_observation
condition       Emotion_Movies
stimulus        emotion_faces_videos
setup           fmri_7T
investigator    LeonardoCerliani
```

## 4. Create a python virtual environment
Create a python venv, activate it and install the `requirements.txt`

```bash
python3 -m venv venv_FYD
source venv_FYD/bin/activate 
pip install -r requirements.txt
```

## 5. Generate the json files
Launch `jupyter lab` (make sure you are inside the `vnv_FYD` environment) and open the `01_generate_json.ipynb`

Fill in the template with the parameters of your study that you got from the web interface. For instance:

```json
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

The json files will be generated in the directory `generated_jsons`.

Now copy the generated files on storm and in the appropriate dirs. For instance if this the structure of your data:

```
raw_data
├── generated_jsons
├── list_subj.txt
├── sub-02
├── sub-03
├── sub-05
├── sub-07
├── sub-09
├── sub-10
```

and `list_subj.txt` has one subject id per row - as shown above - then you can use something like the following:

```bash
for sub in $(cat list_subj.txt); do
  cp generated_jsons/${sub}*.json ${sub}/
done
```


## 6. Update the FYD database
Open the `02_register)subj_on_FYD.ipynb`. This will allow you to register the subjects for which you created the json - together with all the info contained in them - in the db (database) of FYD.

**NB**: You might need to do some modifications. Notably, you need to have the appropriate uname and pw to access the database. These two should be stored in an `.env` file. 

```
DB_USER=[username placeholder]
DB_PASSWORD=[password placeholder]
```

Follow the instructions in the cells for adding/removing one subject with a given ID or a list of subjects with ids stored in a text file.

