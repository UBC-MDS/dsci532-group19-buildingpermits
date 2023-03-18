[![App Deploys](https://github.com/UBC-MDS/dsci532-group19-buildingpermits/actions/workflows/deploy-app.yaml/badge.svg)](https://github.com/UBC-MDS/dsci532-group19-buildingpermits/actions/workflows/deploy-app.yaml)
[![App Deploys](https://github.com/UBC-MDS/dsci532-group19-buildingpermits/actions/workflows/testing.yaml/badge.svg)](https://github.com/UBC-MDS/dsci532-group19-buildingpermits/actions/workflows/testing.yaml)

# Vancouver Building Permit Exploration

- Authors: Spencer Gerlach, Alex Taciuk, Revathy Ponnambalam, Waiel Tinwala

- Shiny App link : **https://ataciuk.shinyapps.io/dsci532-group19-buildingpermits/**

<img src="img/app-demo_2023-03-17.gif">

## Dashboard Motivation: Why?

Our dashboard is a shiny app created for people or organizations in Vancouver that depend on development insights from building permit data, but are unable to access them due to various technical or other accessiblity constraints. 

## Dashboard Contents: What?

Upon launch of the shiny app, users are met with a detailed summary of Vancouver building permit data. Users can toggle between two different tabs, showing different levels of summary information. The two tabs are described below.

### Tab 1: Spatial Visualization of Housing Permit

> Users can explore different data filters using the filter pane on the left side. These filters will update the two main visuals on the page. Users can choose between a histogram, faceted line chart, or data table using selection tabs. Users can filter permits based on neighbourhood, building type, approval date range, etc.

The summary visuals on page 1 are comprised of:

1. **Permit Location Map:** Users can find individual permits on a map, and hover over each permit location to see an expanded list of information about the permit. Users can also toggle the basemap to explore the area surrounding each permit location (e.g. street names, adjacent businesses, etc.).

2. **Layered Visuals:** 
    - TAB 1: **Histogram of Projects:** Users can view the distribution of permits based on the cost of project construction (CAD), or by the number of days elapsed before the building permit was approved. Use the dropdown at the bottom of the left-side filter pane to toggle between these two values.
    - TAB 2: **Line Chart:** Users can view the trends in project value or days for approval over time (use dropdown at bottom of left-side filter pane). Users can decide to facet charts by neighbourhood (multiple options) or by the type of building (use dropdown at top left corner of line chart area).
    - TAB 3: **Building Permit Data:** Users can view tabular data corresponding to the filtered data shown in the visuals. If desired, users can download the data in CSV or JSON format using the download buttons at the bottom of the left-side filter pane.

#### Example View:


<img src="img/tab1-example_2023-03-17.png">

### Tab 2: Neighbourhood Analysis

> Users can explore building permit data summarized to Vancouver's neighbourhood boundaries. Users can decide between various summary statistics.

- Using the filter pane on the left side of the page, users can view various building permit summary statistics by spatial neighbourhood boundary. Options include various statistics for project value ($CAD), permit approval timelines, and permit counts.
- Based on the selection, the neighbourhood map will dynamically update to show that statistic. Darker colors represent larger values.
- Users can hover their mouse over each neighbourhood to see the neighbourhood name and the value of the chosen summary statistic.

#### Example View:

<img src="img/tab2-example_2023-03-17.png">

### Tab 3: About

> Users can find more information about our app, including a link to this GitHub repository, and a link to the Vancouver Open Data portal (data source).

#### Example View:

<img src="img/tab3-example_2023-03-17.png">

## Contribution to the Dashboard: How?

Interested in contributing to this dashboard? Instructions and guidelines for contributing to our project can be found in the `CONTRIBUTING.MD` file in this repository.

We are excited about this product, and welcome any suggestions for improvement. Specific suggestions about use-cases can help our team develop a truly useful app that people will use and build value from.

Thank you for considering contributing to our dashboard!

# License
Licensed under the terms of the MIT license.
