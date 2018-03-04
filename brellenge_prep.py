#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Make a pivot table from ethnicity-full-nested-new and a metadata table. Explore how pandas and seaborn work a little.

Run with ipython -i or load into Jupyter or whatever.

Created on Sat Mar  3 11:14:51 2018

@author: tcake and cozza
"""

import pandas as pd
import unittest
import numpy as np

def change_since(start, end=2015):
    "Normalised change in population since x till y."
    start = f'y{start}'
    end = f'y{end}'
    return (pivoted.loc[:, end] - pivoted.loc[:, start]) / pivoted.loc[:, start]

# Set up some globals
data = pd.read_csv("data/ethnicity-full-nested-new.csv")
yearlabels = [f'y{x}' for x in range(1998, 2018)]

# List of ethnicities for for loops.
ethnicities = [x for x in pivoted.columns.levels[1]]

# Data for joining on: Remove all the ethnicity stuff
metadata = data.drop(["ethnic2", "ethnicrate"] + yearlabels,1).drop_duplicates().set_index('AreaName')
# Add a "Result" column for Tess.
metadata["Result"] = metadata.apply(lambda row: "Leave" if row.Leave > row.Remain else "Remain", axis=1)

# Make the pivot table
pivoted = pd.pivot_table(data[['AreaName', 'ethnic2'] + yearlabels], columns=['ethnic2'], index = ['AreaName'])


### Analysis ###


# How to index pivot table
idx = pd.IndexSlice
## First idx is one of the pivot table indexes (pivoted.index.levels), second one is one of the ethnicity columns
pivoted.loc[:, idx['y1998':'y2003', 'Asian':'Other']]


# How to plot:
import matplotlib.pyplot as plt
import seaborn

def scatter_plot_change(ethnicity, start, end=2015):
    "Plot change in ethnicity since start against Pct_Remain"
    data = metadata.join(change_since(start, end)[ethnicity]).dropna()
    seaborn.regplot(data[ethnicity], data['Pct_Remain'])

scatter_plot_change('White Other', 2003)
#plt.show()

# Interactive use:
# df=metadata.join(change_since(2003)).dropna()
# seaborn.regplot(df.Asian, df.Pct_Remain)

# Get an interactive console. Can also use ipython3 -i brellenge_prep.py
# import IPython
# IPython.embed()


### Old stuff ###

# class FeatureEngineering:

#      def percentage_NaN(dataframe):
#         num = selected_columns.isnull().sum()
#         den = len(selected_columns)
#         percentage_by_column = round(num/den, 2)
#         percentage_loss = percentage_by_column.sum()/len(percentage_by_column)
#         return percentage_loss

    # You can just use metadata.query('Remain < Leave'), if you want the result column I include a oneline below
     # def label_result(dataframe):
     #    dataframe["Result"] = pd.Series(np.NaN)
     #    leave_index = dataframe[dataframe["Leave"] > dataframe["Remain"]].index
     #    remain_index = dataframe[dataframe["Leave"] < dataframe["Remain"]].index
     #    for i in leave_index:
     #        dataframe.loc[i,"Result"] = "Leave"
     #    for i in remain_index:
     #        dataframe.loc[i,"Result"] = "Remain"
     #    return dataframe

# Run the tests with `pytest brellenge_prep.py`
# class Test(unittest.TestCase):

#     def test_result_labelled_correctly(self):
#         data.index = data.AreaName
#         self.assertEqual("Leave", data.loc['Hartlepool','Result'].values[0])

#     def test_no_data_lost(self):
#         self.assertEqual(FeatureEngineering.percentage_NaN(data), FeatureEngineering.percentage_NaN(selected_columns))
