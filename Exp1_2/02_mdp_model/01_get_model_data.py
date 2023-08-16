#%%
import subprocess
import csv

#%%

with open("data/model_result.csv", "w") as new_file:
    writer = csv.writer(new_file)
    fieldnames = ['Emotion', 'Suddenness', 'Goal_relevance', 'Conduciveness', 'Power' ]
    writer.writerow(fieldnames)

#%%
program_list = ['02_mdp_model/mdp_boredom.py', '02_mdp_model/mdp_fear.py','02_mdp_model/mdp_happiness.py',
                '02_mdp_model/mdp_joy.py','02_mdp_model/mdp_pride.py',
                '02_mdp_model/mdp_sadness.py','02_mdp_model/mdp_shame.py']

for program in program_list:
    subprocess.call(['python3', program])
    print("Finished:" + program)
