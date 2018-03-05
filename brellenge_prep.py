#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Make a pivot table from ethnicity-full-nested-new and a metadata table. Explore how pandas and seaborn work a little.

Run with ipython -i or load into Jupyter or whatever.

Created on Sat Mar  3 11:14:51 2018

@author: tcake and cozza
"""

import pandas as pd


def change_since(start, end=2015):
    "Normalised change in population since x till y."
    start = 'y{}'.format(start)
    end = 'y{}'.format(end)
    return (pivoted.loc[:, end] - pivoted.loc[:, start]) / pivoted.loc[:, start]

# Read in data
data = pd.read_csv("data/ethnicity-full-nested-new.csv")
yearlabels = ['y{}'.format(x) for x in range(1998, 2018)]

## Globals to play with

# Make the pivot table
pivoted = pd.pivot_table(data[['AreaName', 'ethnic2'] + yearlabels], columns=['ethnic2'], index = ['AreaName'])
idx = pd.IndexSlice

# Data for joining on: Remove all the ethnicity stuff and drop rate_nonUK because it's got NAs in it.
metadata = data.drop(["ethnic2", "ethnicrate", "rate_nonUk"] + yearlabels,1).drop_duplicates().set_index('AreaName')
# Add a "Result" column for Tess.
metadata["Result"] = metadata.apply(lambda row: "Leave" if row.Leave > row.Remain else "Remain", axis=1)
# Proportion White British in 2015: good for regression with change rate.
metadata['y2015_WBR'] = pivoted.loc[:, idx['y2015', 'White British']]

# List of ethnicities for for loops.
ethnicities = [x for x in pivoted.columns.levels[1]]

# Get English IMDs
imd = pd.read_csv("data/File_2_ID_2015_Domains_of_deprivation.csv")
ladimd=imd.groupby('Local Authority District code (2013)').median()
# IMD data has NAs for all of Scotland :(
metadata = metadata.join(ladimd, on='LAD16CD')
metadata=metadata.rename(columns={"Index of Multiple Deprivation (IMD) Decile (where 1 is most deprived 10% of LSOAs)":"IMD"})

### Analysis ###


# How to index pivot table
## First idx is one of the pivot table indexes (pivoted.index.levels), second one is one of the ethnicity columns
pivoted.loc[:, idx['y1998':'y2003', 'Asian':'Other']]


# How to plot:
import matplotlib.pyplot as plt
import seaborn

def stacked_bar_chart():
    pivoted.loc[:,idx[:,:]].dropna().sum().divide(348).unstack('ethnic2').plot.bar(stacked=True, figsize=(10,7), legend =True)

def scatter_plot_change(ethnicity, start, end=2015):
    "Plot change in ethnicity since start against Pct_Remain"
    data = metadata.join(change_since(start, end)[ethnicity]).dropna()
    seaborn.regplot(data[ethnicity], data['Pct_Remain'])

# scatter_plot_change('White Other', 2003)
stacked_bar_chart() # I'm not sure why the bar chart does not remain constant
#plt.show()

# Interactive use:
# df=metadata.join(change_since(2003)).dropna()
# seaborn.regplot(df.Asian, df.Pct_Remain)

# Get an interactive console. Can also use ipython3 -i brellenge_prep.py
# import IPython
# IPython.embed()

### Regressions ###

import statsmodels.formula.api as smf

# Example interactive exploration

# df=change_since(2005).join(metadata)
# # R2 = 0.45
# # The Q is to handle whitespace in column names.
# smf.ols('Pct_Remain ~ Q("White British") + Q("White Other") + Asian + Black + Other + Region', data=df).fit().summary()
# # R2 = 0.45
# smf.ols('Pct_Remain ~ Q("White British") + Q("White Other") + Asian + Black + Other + y2015_WBR', data=df).fit().summary()

# Better exploration:

def explore(metadata, formula):
    "Explore all possible change_sinces"
    results = []
    for since in range(1998, 2018):
        for till in range(1998, 2018):
            try:
                ols = smf.ols(formula, data=change_since(since, till).join(metadata))
                results.append((since, till, ols, ols.fit(), ols.fit().rsquared_adj))
            except:
                # Model failed to converge
                pass

    results.sort(key = lambda row: row[4])

    # Actually pandas is pretty nice
    results = pd.DataFrame.from_records(results)
    results.columns = ['since', 'till', 'ols', 'ols.fit', 'rsq']
    return results

def exploreEngland():
    justEngland = metadata.dropna()
    formula = 'Pct_Remain ~ Q("White British") + Q("White Other") + Asian + Black + Other + y2015_WBR + IMD'
    return explore(justEngland, formula)

def exploreUK():
    return explore(metadata, 'Pct_Remain ~ Q("White British") + Q("White Other") + Asian + Black + Other + y2015_WBR')

def multiHeatmap(namedResults):
    "(formula/name, results) -> figure of lots of heatmaps"

    # This is a lot of boring work. You'd have thought someone else would have
    # done it :(

    # Make grid
    rows = max(1, len(namedResults)//3)
    cols = min(3, len(namedResults))
    fig, axs = plt.subplots(rows, cols)
    # Share colour bar.
    cbar_ax = fig.add_axes([.91, .3, .03, .4])

    # Find limits
    vmin = min((df.rsq.min() for _, df in namedResults))
    vmax = max((df.rsq.max() for _, df in namedResults))

    # Create plots
    for ax, (name, results) in zip(axs, namedResults):
        seaborn.heatmap(
                results.pivot('since', 'till', 'rsq'),
                cmap='YlGnBu',
                vmin=vmin, vmax=vmax,
                square=True,
                ax=ax,
                cbar=ax == axs[0],
                cbar_ax=cbar_ax)
        ax.set_title(name)

    return (fig, axs)

# If you feel like searching again, try:
# bestUK = exploreUK()[-1]

# Going backwards turns out to be best, probably because it's capturing the relative population near referendum better?
bestEng = smf.ols('Pct_Remain ~ Q("White British") + Q("White Other") + Asian + Black + Other + y2015_WBR + IMD', data=change_since(2016, 2001).join(metadata))
bestUK = smf.ols('Pct_Remain ~ Q("White British") + Q("White Other") + Asian + Black + Other + y2015_WBR', data=change_since(2017, 2003).join(metadata))

# Heatmaps
# res = exploreUK()
# seaborn.heatmap(res.pivot('since', 'till', 'rsq'))
# multi = (('UK', exploreUK()), ('England', exploreEngland()))
# multiHeatmap(multi)
