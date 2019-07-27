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

test_that("rearranging two cells works", {
  nb <- ReactiveNotebook$new()
  
  nb$run_cell(list(id = "a", value = "a <- 1", position = 1))
  nb$run_cell(list(id = "b", value = "b <- 2", position = 2))
  
  expect_equal(nb$data_frame()$id, c("a", "b"))
  
  # Move cell b to first position
  nb$move(2, 0)
  expect_equal(nb$data_frame()$id, c("b", "a"))
  
  # Move cell b back to second position
  nb$move(1, 2.5)
  expect_equal(nb$data_frame()$id, c("a", "b"))
  
  # Move a to second position
  nb$move(1, 2.5)
  expect_equal(nb$data_frame()$id, c("b", "a"))
})
