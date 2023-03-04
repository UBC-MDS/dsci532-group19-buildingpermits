# Milestone 2 Reflection - Group 19

## What’s been implemented:
We implemented the majority of features planned in the first milestone, notably:
- The two tab structure
- In one tab we have the choropleth map of Vancouver neighbourhoods, where the user can select the variable that’s visualized
- In the other tab we have the reactive selection pane, a map showing individual projects (that zooms in and out as areas depending on what’s selected), and two charts (a line chart and a histogram

## What was not implemented:
- The dashboard does not include originally-planned functionality to use neighbourhood boundaries as zoom boundaries. The project team has decided that a more effective point map will utilize dynamic, built-in leaflet point clustering.
- The dashboard does not include much extra context for the visuals (i.e. titles, descriptions, etc). 
- Minor issues with formatting and aesthetics remain.
- Fixes needed when no option is selected in the filters.

## Dashboard Strengths:
- The existing visualizations achieve the high-level goal of improving accessibility to the building permit data.
- Users can easily filter the data to visualize different aspects permitting, and the reactive plots keep up with user demands.
- The plot synthesized the complexity of the dataset into a product that shows a lot of data.

## Dashboard Limitations:
- The dashboard currently offers base functionality for a general user. More fine-tuning would be  required, for example, to allow more direct comparisons of different neighbourhoods.

## Future Improvements and Additions:

Future improvements/additions may include:
- Various formatting and aesthetic updates will be done to ensure text is readable and the design is professional and easy to navigate and understand.

#### Detailed Tab
- Point map:
   - Fix labels to fit within the viewable window. A portion of labels are unviewable when a point is close to any edge of the map window.
   - Add more project details (such as the description of the project)
- Charts on detailed tab:
   - Add an average/median to the histogram
   - Add the ability to change the bin size on the histogram
   - Add averages to the line charts

#### Neighbourhood tab:
- Expand map to full screen, and reposition filter tab to overlay the map. Remove ability to pan map. Set fixed zoom level. 
- [stretch goal alternative] Addition of a new summary chart, like a boxplot, that updates reactively based on neighbourhood click selection from choropleth map.
- [stretch goal alternative] Addition of a second choropleth map to the neighbourhood analysis tab. This second map could use different boundaries, such as a hexgrid or postal code areas.
