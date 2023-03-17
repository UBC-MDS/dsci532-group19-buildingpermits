library(shinytest2)

test_that("{shinytest2} recording: test_defaultinput", {
  app <- AppDriver$new(variant = platform_variant(), name = "test_defaultinput", 
      height = 975, width = 1619)
  app$expect_values()
  app$expect_screenshot()
})


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
