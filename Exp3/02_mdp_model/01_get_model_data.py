#%%
import subprocess
import csv
#%%

with open("data/model_result.csv", "w") as new_file:
    writer = csv.writer(new_file)
    fieldnames = ['Emotion', 'Suddenness', 'Goal_relevance', 'Conduciveness', 
    'Power' ]
    writer.writerow(fieldnames)

#%%
program_list = ['02_mdp_model/anxiety.py', '02_mdp_model/despair.py',
                '02_mdp_model/irritation.py','02_mdp_model/rage.py']

for program in program_list:
    subprocess.call(['python3', program])
    print("Finished:" + program)
