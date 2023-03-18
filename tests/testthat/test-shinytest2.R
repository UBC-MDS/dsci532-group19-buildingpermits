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




test_that("{shinytest2} recording: valid_output3", {
  app <- AppDriver$new(name = "valid_output3", height = 789, width = 1139)
  app$set_inputs(locations_groups = c("Satellite View", "Basemap", "building locations"), 
      allow_no_input_binding_ = TRUE)
  app$expect_values()
  app$set_inputs(selected_variable = "PermitElapsedDays")
  app$set_inputs(dateRange = c("2017-01-17", "2023-03-02"))
  app$set_inputs(dateRange = c("2017-01-17", "2022-08-16"))
  app$set_inputs(type_of_work = "Addition / Alteration")
  app$set_inputs(selected_variable = "ProjectValue")
  app$expect_values()
})
