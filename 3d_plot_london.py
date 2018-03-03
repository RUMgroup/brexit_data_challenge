# -*- coding: utf-8 -*-
import csv
import sys
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np

# Brexit result is remain-leave/electorate
# We will hold the data in the form district name, brexit result, unemployment numbers, % white
london_brexit_results = [
    ["City_of_London", 0.371638550192083, [], []],
    ["Barking_and_Dagenham", -0.158705488205022, [], []],
    ["Barnet", 0.176254212031307, [], []],
    ["Bexley", -0.194889301377804, [], []],
    ["Brent", 0.126567912073793, [], []],
    ["Bromley", 0.010212854198978, [], []],
    ["Camden", 0.326333161423414, [], []],
    ["Croydon", 0.059882045575894, [], []],
    ["Ealing", 0.145578921175073, [], []],
    ["Enfield", 0.080368169285286, [], []],
    ["Greenwich", 0.077713399657921, [], []],
    ["Hackney", 0.370703804414395, [], []],
    ["Hammersmith_and_Fulham", 0.279759365504993, [], []],
    ["Haringey", 0.360671028261536, [], []],
    ["Harrow", 0.066866998774608, [], []],
    ["Havering", -0.298685834762565, [], []],
    ["Hillingdon", -0.087767376562557, [], []],
    ["Hounslow", 0.014747046349591, [], []],
    ["Islington", 0.354567723542356, [], []],
    ["Kensington_and_Chelsea", 0.246417475494328, [], []],
    ["Kingston_upon_Thames", 0.181885003399548, [], []],
    ["Lambeth", 0.385407969639469, [], []],
    ["Lewisham", 0.250296181536499, [], []],
    ["Merton", 0.189993546115935, [], []],
    ["Newham", 0.033658219623132, [], []],
    ["Redbridge", 0.05369173474924, [], []],
    ["Richmond_upon_Thames", 0.316560106158393, [], []],
    ["Southwark", 0.301641352903638, [], []],
    ["Sutton", -0.056469548357664, [], []],
    ["Tower_Hamlets", 0.225163866046955, [], []],
    ["Waltham_Forest", 0.121245774099139, [], []],
    ["Wandsworth", 0.36006577958373, [], []],
    ["Westminster", 0.246092064651024, [], []]
]

# First we will build the unemployment lists.
f = sys.argv[1]

rows = []
with open(f) as inputfile:
    for line in inputfile:
        rows.append(line.strip().split(','))
for entry in rows:
    if entry == rows[0]:
        pass
    else:
        for district in london_brexit_results:
            print str(district[0])

            print str(district[0]), str(entry[2])
            if str(district[0]) in str(entry[2]):
                district[2].append(float(entry[14]))
                district[3].append(float(entry[5]))
print london_brexit_results


def use_colours(float):
    if float < 0:
        return "red"
    elif float >= 0:
        return "blue"
    else:
        return "green"


# Generate X Y Z values
x = []
for district in london_brexit_results:
    x.append(np.mean(district[2]))

y = []
for district in london_brexit_results:
    y.append(np.mean(district[3]))

z = []
for district in london_brexit_results:
    z.append(district[1])

# pyplot
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(x, y, z, c=[use_colours(i) for i in z], marker='o')
ax.set_xlabel('Unemployment Rate')
ax.set_ylabel('Percentage of Ethnic White')
ax.set_zlabel('Referendum Score')
for itemnumber, item in enumerate(x):
    plt.plot([x[itemnumber], x[itemnumber]], [y[itemnumber], y[itemnumber]], [min(z), z[itemnumber]], c=use_colours(z[itemnumber]))
fig.savefig('london_results.png')
