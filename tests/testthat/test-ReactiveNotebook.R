test_that("saving values works", {
  nb <- ReactiveNotebook$new()
  nb$run_cell(list(id = "a", value = "a <- 1", position = 1))
  nb$run_cell(list(id = "b", value = "b <- 2", position = 2))
  
  expect_equal(nb$run_in_env("a"), 1)
  expect_equal(nb$run_in_env("b"), 2)
})

test_that("updating works", {
  nb <- ReactiveNotebook$new()
  nb$run_cell(list(id = "a", value = "a <- 1", position = 1))
  nb$run_cell(list(id = "b", value = "b <- a", position = 2))
  
  expect_equal(nb$run_in_env("a"), 1)
  expect_equal(nb$run_in_env("b"), 1)
  
  nb$run_cell(list(id = "a", value = "a <- 2", position = 2))
  expect_equal(nb$run_in_env("a"), 2)
  expect_equal(nb$run_in_env("b"), 2)
})
