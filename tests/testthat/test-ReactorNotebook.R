test_that("saving values works", {
  nb <- ReactorNotebook$new()
  nb$run_cell(list(id = "a", value = "a <- 1", position = 1))
  nb$run_cell(list(id = "b", value = "b <- 2", position = 2))
  
  expect_equal(nb$run_in_env("a"), 1)
  expect_equal(nb$run_in_env("b"), 2)
})

test_that("updating works", {
  nb <- ReactorNotebook$new()
  nb$run_cell(list(id = "a", value = "a <- 1", position = 1))
  nb$run_cell(list(id = "b", value = "b <- a", position = 2))
  
  expect_equal(nb$run_in_env("a"), 1)
  expect_equal(nb$run_in_env("b"), 1)
  
  nb$run_cell(list(id = "a", value = "a <- 2", position = 2))
  expect_equal(nb$run_in_env("a"), 2)
  expect_equal(nb$run_in_env("b"), 2)
})

test_that("rearranging two cells works", {
  nb <- ReactorNotebook$new()
  
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
  nb <- ReactorNotebook$new()
  
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
  nb <- ReactorNotebook$new()
  
  nb$run_cell(list(id = "a", value = "plot(1:10)", position = 1))
  
  expect_equal(nb$data_frame()$viewWidth, "")
  
  nb$update_size(list(id = "a"), list(width = 0.5))
  expect_equal(nb$data_frame()$viewWidth, 0.5)
  
  nb$update_size(list(id = "a"), list(height = 0.5))
  expect_equal(nb$data_frame()$viewHeight, 0.5)
  
  nb$update_size(list(id = "a"), list(width = 0.25, height = 0.25))
  expect_equal(nb$data_frame()$viewWidth, 0.25)
  expect_equal(nb$data_frame()$viewHeight, 0.25)
})

test_that("updating cell open status works", {
  nb <- ReactorNotebook$new()
  
  nb$run_cell(list(id = "a", value = "plot(1:10)", position = 1))
  expect_equal(nb$cells$a$open, FALSE)
  
  nb$update_open(list(id = "a"), list(open = TRUE))
  expect_equal(nb$cells$a$open, TRUE)
  
  nb$update_open(list(id = "a"), list(open = FALSE))
  expect_equal(nb$cells$a$open, FALSE)
})

test_that("update_from_view works", {
  nb <- ReactorNotebook$new()
  
  nb$run_cell(list(id = "a", value = "a <- slider(min = 0, max = 1, value = 0.5)"))
  nb$run_cell(list(id = "b", value = "b <- as.numeric(a)"))
  
  expect_equal(nb$run_in_env("b"), 0.5)
  
  nb$update_from_view(list(id = "a", name = "a"), 1)
  
  expect_equal(nb$run_in_env("b"), 1)
})

test_that("saving and loading works", {
  nb <- ReactorNotebook$new()
  
  nb$run_cell(list(id = "a", value = "a <- 10", position = 1))
  nb$run_cell(list(id = "b", value = "b <- a", position = 2))
  
  tmp <- tempfile()
  
  nb$save(tmp)
  
  nb_load <- ReactorNotebook$load(tmp)
  
  expect_equal(nb$run_in_env("a"), 10)
  expect_equal(nb$run_in_env("b"), 10)
})

test_that("export works", {
  nb <- ReactorNotebook$new()
  
  nb$run_cell(list(id = "a", value = "a <- 10", position = 1))
  nb$run_cell(list(id = "b", value = "b <- a", position = 2))
  
  expect_equal(nb$export(), "a <- 10\n\nb <- a")
})
