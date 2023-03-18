library(shinytest2)


test_that("{shinytest2} recording: test_validoutput", {
  app <- AppDriver$new(name = "test_validoutput", height = 975, width = 1619)
  app$set_inputs(neighbourhood = character(0))
  app$set_inputs(neighbourhood = "Downtown")
  app$set_inputs(neighbourhood = c("Downtown", "Grandview-Woodland"))
  app$set_inputs(neighbourhood = c("Downtown", "Grandview-Woodland", "Marpole"))
  app$set_inputs(specificUse = c("Multiple Dwelling", "Duplex w/Secondary Suite"))
  app$set_inputs(specificUse = c("Multiple Dwelling", "Duplex w/Secondary Suite", 
      "Freehold Rowhouse"))
  app$set_inputs(specificUse = c("Multiple Dwelling", "Duplex w/Secondary Suite", 
      "Freehold Rowhouse", "Infill Multiple Dwelling"))
  app$set_inputs(elapsedDays = c(730, 1597))
  app$set_inputs(elapsedDays = c(730, 1490))
  app$set_inputs(projectValue = c(0, 190065000))
  app$expect_values()
})


test_that("{shinytest2} recording: test_validoutput2", {
  app <- AppDriver$new(name = "test_validoutput2", height = 975, width = 1619)
  app$set_inputs(type_of_work = "Addition / Alteration")
  app$set_inputs(projectValue = c(130870000, 2.5e+08))
  app$set_inputs(projectValue = c(67635000, 2.5e+08))
  app$set_inputs(projectValue = c(0, 2.5e+08))
  app$set_inputs(projectValue = c(0, 131780000))
  app$expect_values()
})


test_that("{shinytest2} recording: test_validoutput4", {
  app <- AppDriver$new(name = "test_validoutput4", height = 789, width = 1139)
  app$set_inputs(locations_groups = c("Satellite View", "Basemap", "building locations"), 
      allow_no_input_binding_ = TRUE)
  app$set_inputs(tabs1 = "Neighbourhood Map")
  app$set_inputs(chloropleth_shape_mouseover = c(0.470564594425355, 49.2768365399702, 
      -123.209266662598), allow_no_input_binding_ = TRUE)
  app$set_inputs(chloropleth_shape_mouseout = c(0.40846775166215, 49.2799722362952, 
      -123.198623657227), allow_no_input_binding_ = TRUE)
  app$set_inputs(statistic = "elapsed_days_25q")
  app$set_inputs(statistic = "elapsed_days_avg")
  app$set_inputs(statistic = "elapsed_days_50q")
  app$set_inputs(statistic = "project_value_75q")
  app$set_inputs(chloropleth_shape_mouseover = c(0.240217656270722, 49.2234991967928, 
      -123.027305603027), allow_no_input_binding_ = TRUE)
  app$set_inputs(chloropleth_shape_mouseout = c(0.522350830299995, 49.2199114257575, 
      -123.053398132324), allow_no_input_binding_ = TRUE)
  app$set_inputs(chloropleth_shape_mouseover = c(0.567076821777854, 49.2199114257575, 
      -123.053398132324), allow_no_input_binding_ = TRUE)
  app$set_inputs(chloropleth_shape_mouseout = c(0.233494303810352, 49.2187901938917, 
      -123.079147338867), allow_no_input_binding_ = TRUE)
  app$set_inputs(chloropleth_shape_mouseover = c(0.762165238121594, 49.2187901938917, 
      -123.079147338867), allow_no_input_binding_ = TRUE)
  app$set_inputs(chloropleth_shape_mouseout = c(0.00977706646478627, 49.2766125540326, 
      -123.011856079102), allow_no_input_binding_ = TRUE)
  app$expect_values()
})






# test_that("{shinytest2} recording: valid_output3", {
#   app <- AppDriver$new(name = "valid_output3", height = 789, width = 1139)
#   app$set_inputs(locations_groups = c("Satellite View", "Basemap", "building locations"), 
#       allow_no_input_binding_ = TRUE)
#   app$expect_values()
#   app$set_inputs(selected_variable = "PermitElapsedDays")
#   app$set_inputs(dateRange = c("2017-01-17", "2023-03-02"))
#   app$set_inputs(dateRange = c("2017-01-17", "2022-08-16"))
#   app$set_inputs(type_of_work = "Addition / Alteration")
#   app$set_inputs(selected_variable = "ProjectValue")
#   app$expect_values()
# })
