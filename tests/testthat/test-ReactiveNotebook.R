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

test_that("rearranging three cells works", {
  nb <- ReactiveNotebook$new()
  
  nb$run_cell(list(id = "a", value = "a <- 1", position = 1))
  nb$run_cell(list(id = "b", value = "b <- 2", position = 2))
  nb$run_cell(list(id = "c", value = "d <- 3", position = 3))
  
  expect_equal(nb$data_frame()$id, c("a", "b", "c"))
  
  # Move cell b to first position
  nb$move(2, 0)
  expect_equal(nb$data_frame()$id, c("b", "a", "c"))
  
  # Move cell b back to second position
  nb$move(1, 2.5)
  expect_equal(nb$data_frame()$id, c("a", "b", "c"))
  
  # Move a to second position
  nb$move(1, 2.5)
  expect_equal(nb$data_frame()$id, c("b", "a", "c"))
  
  # Move c to first position
  nb$move(3, 0.5)
  expect_equal(nb$data_frame()$id, c("c", "b", "a"))
  
  # Move a to second position
  nb$move(3, 1.5)
  expect_equal(nb$data_frame()$id, c("c", "a", "b"))
})

test_that("updating view size works", {
  nb <- ReactiveNotebook$new()
  
  nb$run_cell(list(id = "a", value = "plot(1:10)", position = 1))
  
  expect_equal(nb$data_frame()$viewWidth, "")
  
  nb$updateSize(list(id = "a"), list(width = 0.5))
  expect_equal(nb$data_frame()$viewWidth, 0.5)
  
  nb$updateSize(list(id = "a"), list(height = 0.5))
  expect_equal(nb$data_frame()$viewHeight, 0.5)
  
  nb$updateSize(list(id = "a"), list(width = 0.25, height = 0.25))
  expect_equal(nb$data_frame()$viewWidth, 0.25)
  expect_equal(nb$data_frame()$viewHeight, 0.25)
})

test_that("updating cell open status works", {
  nb <- ReactiveNotebook$new()
  
  nb$run_cell(list(id = "a", value = "plot(1:10)", position = 1))
  expect_equal(nb$cells$a$open, FALSE)
  
  nb$updateOpen(list(id = "a"), list(open = TRUE))
  expect_equal(nb$cells$a$open, TRUE)
  
  nb$updateOpen(list(id = "a"), list(open = FALSE))
  expect_equal(nb$cells$a$open, FALSE)
})
