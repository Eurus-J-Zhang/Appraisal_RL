#%%
from sklearn import svm
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import math
#%%
# we have 70 rows of testing data. 7 emotion, 10 model result for each emotion. 
def read_data (data_file):
    data = pd.read_csv(data_file)
    x1=data['Suddenness']
    x2=data['Goal_relevance']
    x3=data['Conduciveness']
    x4=data['Power']
    x=np.array(list(zip(x1,x2,x3,x4)))
    y=data['Emotion']
    return x,y

x_training, y_training = read_data('source_data/classifier_train.csv')
x_testing, y_testing = read_data('source_data/classifier_test.csv')

target_names = list(dict.fromkeys(y_training))
#%%
# This is for plotting the classifier with a range of c, so that we can compare the y-axie
# and figure out the suitable c value range for fitting human data.
# From the human data (humandata_for_c.py), we get the result that 
# for precision, mean = 0.4019302024931973, var = 0.027696655833540938


# Here is to find c according to precision plot
# x is a range of c value, y is the precision

# for every c, we have 70 precision added from 70 rows, and then get the average precision


def svm_prediction(c,x_train, y_train, x_test):
    svc = svm.SVC(kernel='linear', C=c, probability=True).fit(x_train,y_train)
    prediction_full = []
    for i in range(len(x_test)):
        prediction = svc.predict_proba(x_test[i].reshape(1, -1))
        prediction = prediction.tolist()[0]
        prediction_full.append(prediction)
    return(prediction_full)
# %%

def plot_c_precision(minv, maxv, x_train, y_train, x_test):
    x=[]
    y=[]
    for c in np.linspace(minv,maxv,100):
        prediction_res = svm_prediction(c,x_train, y_train, x_test)
        precision_list = []
        for i in range(len(prediction_res)):
            index = target_names.index(y_testing[i])
            precision_list.append(prediction_res[i][index])
        x.append(c)
        y.append(np.average(precision_list))
    plt.plot(x,y)
    plt.xlabel('C value')
    plt.ylabel('Correct prediction rate')
    plt.show()
    
plot_c_precision(0.0015,0.005,x_training,y_training,x_testing)

# 0.38-0.4-0.42, index 41-47
# c = 0.0032, variance 0.0002 
#%%

# Define a function to calculate entropy
# def entropy(data):
#     n_data = len(data)
#     entropy_list = []
#     for i in range (n_data):
#         # probability list for which without 0, only valid numbers
#         prob_list = [i for i in data[i] if i != 0]
#         entropy = 0
#         # Calculate entropy for this list
#         for prob in prob_list:
#             entropy -= prob * math.log(prob, 2)
#         entropy_list.append(entropy)

#     return entropy_list

# Here is to find c according to entropy plot:


# def plot_c_entropy(minv, maxv, x_train, y_train, x_test):
#     x=[]
#     y=[]
#     for c in np.linspace(minv,maxv,100):
#         prediction_res = svm_prediction(c,x_train,y_train,x_test)
#         entropy_list = entropy(prediction_res)
#         x.append(c)
#         y.append(np.average(entropy_list))
    
#     plt.plot(x,y)
#     plt.xlabel('C value')
#     plt.ylabel('Entropy')
#     plt.show()
#     return(x,y)

# x,y=plot_c_entropy(0.002,0.005,x_training,y_training,x_testing)

# 1.72990941879756 0.2929363168935586
# 47-69
# 0.0034 - 0.004, mean = 0.0037, var = 0.0003

#%%
# https://scikit-learn.org/stable/modules/svm.html
# https://people.revoledu.com/kardi/tutorial/Python/SVM+in+Python.html
