# Proposal

#### Authors
- Spencer Gerlach
- Alex Taciuk
- Revathy Ponnambalam
- Waiel Tinwala

#### Date
- First Draft: 2023-Feb-16

## Motivation and Purpose

Our dashboard provides an accessible way for people to explore building permits granted in the City of Vancouver. Building permits are a source of valuable information about development in Vancouver. They are granted to approve new development, from single family houses to condo buildings, offices, retail and any other changes to private property. Building permits can be used to derive insights about development value (dollar amount), development type (low-, medium-, and high-density), permit fulfillment timelines, and how these vary across neighbourhoods. 

Our tool is focused on providing an accessible means to explore insights about housing development that may otherwise be inaccessible. City staff make building permit data available via their open data portal, but the data is not accessible for people who lack technical skills or are unfamiliar with the building permit system. The data is also mostly project-by-project, with few options to aggregate by neighborhood or development type. Given the housing crisis in Vancouver, our team hopes to make data available to all.

This tool could benefit citizens of Vancouver who wish to be informed of recent and current trends in development, organizations who wish to develop property in the city, or those advocating for social change. 

We assume the role of a City of Vancouver department, making a purpose-built tool to deliver these insights to our interested citizens and organizations.

## Data Description

The [dataset](https://opendata.vancouver.ca/explore/dataset/issued-building-permits/information/) contains a row for each building permit approved by the City of Vancouver from 2017-2023. It is published in the City’s Open Data Portal and is updated daily. Each row contains temporal, geographical, numeric, and descriptive data on the project, and the data is mostly complete. Approximately 7,800 of the 35,000 permits are primarily focused on residential development permits for new buildings, which may contain one or more dwelling units.  

Ten of the 20 variables in the dataset are of interest:
- `PermitElaspedDays` (Number of days from permit submission to approval)
- `ProjectValue` (Estimated construction cost at the time of the permit issuance in dollars)
- `ProjectDescription` (detailed description of the project, including number of dwelling units)
- `PermitCategory` (type of permit granted – many NAs) 
- `PropertyUse` (general land use type, e.g. Dwelling, Retail, Office)
- `SpecificUseCategory` (specific land use type, e.g. Multiple Dwelling, Laneway House)
- `IssueYear` (the year the permit was issued)
- `GeoLocalArea` (the Vancouver neighbourhood of the development)
- `YearMonth` (the year and month the permit was issued)
- `Geo_point_2d` (lat/lon coordinates)

## Target Personas and Usage Scenarios

Our target audience is citizens and organizations that would like to be informed on recent development approvals across the city, and how development varies by neighborhood. 

Arman is a Vancouverite passionate about the history of development approvals across the city. Arman wants to explore the trends in development value, type, and activity (number of planned developments). Ideally, he would be able to explore these trends at both an aggregated citywide level, but also to explore differences in these trends at the neighbourhood level. Our dashboard will give Arman a simple interface where he can toggle between those citywide and neighbourhood aggregation levels. Since Arman likes simple graphics and maps, he will be able to navigate to our interactive map of Vancouver neighbourhoods. Here, he will be able to see a chloropleth map outlining number of permits issued per neighbourhood; this might give him a quick idea of which neighbourhood are most active. Arman doesn’t stop there, since the map is interactive, he can click a neighbourhood to filter the dashboard statistics to present information specific to that selected neighbourhood. Say Arman lives in West Point Grey, he can then get an idea of the average time it takes to get a building permit approved, the average value of the development in the neighbourhood, and the specific breakdown of the development types (e.g. low density, high density, etc). With this information, Arman can make informed decisions about city leadership, and can become more involved in community discussions about current and planned development. 

Varada volunteers in an organization advocating to build more affordable rental housing throughout the City. Permit data would be useful to help her volunteer organization argue their case. She is concerned that red tape in City Hall delays new rental housing, and wants to know how the details of building permits compare neighbourhood-to-neighbourhood. Wading through the City’s excel spreadsheets does not meet her needs, as she has few hours to meaningfully contribute to the volunteer project outside of her day job. Varada is specifically interested in the average time it takes to get a building permit approved based on the type of development. Her specific question is whether it takes medium or high density developments longer to get building permit approval than lower density. Using the citywide aggregation view of our dashboard, Varada is able to quickly filter the summary charts to show building permits for only low and high-density developments. She may find that it takes longer for high density buildings to get approval than low-density buildings; she can take these findings to her next meeting with a City Councillor to give her argument some credibility.
