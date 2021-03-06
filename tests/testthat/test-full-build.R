drake_context("full build")

test_with_dir("scratch build with custom filesystem cache.", {
  config <- dbug()
  unlink(default_cache_path(), recursive = TRUE)
  path <- "my_cache"
  config$cache <- cache <- new_cache(
    path = path,
    hash_algorithm = "murmur32"
  )
  expect_error(drake_get_session_info(cache = cache))
  expect_true(length(progress(cache = cache)) == 0)
  expect_equal(config$cache$list(), character(0))

  testrun(config)

  expect_true(is.numeric(readd(final, cache = cache)))
  expect_true(length(config$cache$list()) > 2)
  expect_false(any(c("f", "final") %in% ls()))
  cache <- this_cache(path = path)
  expect_equal(cache$driver$hash_algorithm, "murmur32")

  # changed nothing
  testrun(config)
  nobuild(config)

  cache <- this_cache(path = path)

  # take this opportunity to test clean() and prune()
  all <- sort(c(encode_path("input.rds"),
    encode_path("intermediatefile.rds"), "drake_target_1", "a",
    "b", "c", "combined", "f", "final", "g", "h", "i", "j",
    "myinput", "nextone", "yourinput"))
  expect_equal(config$cache$list(), all)
  expect_true(file.exists("intermediatefile.rds"))
  expect_true(file.exists("input.rds"))
  expect_false(file.exists(default_cache_path()))
  expect_true(file.exists(path))

  # clean specific targets
  clean(b, c, list = c("drake_target_1", "nextone"),
    cache = cache)
  expect_false(file.exists("intermediatefile.rds"))
  expect_true(file.exists("input.rds"))
  expect_equal(
    sort(config$cache$list()),
    sort(setdiff(
      all,
      c("b", "c", "drake_target_1",
        encode_path("intermediatefile.rds"), "nextone")
    ))
  )

  # clean does not remove imported files
  expect_true(file.exists("input.rds"))
  expect_true(encode_path("input.rds") %in%
    config$cache$list())
  clean(list = encode_path("input.rds"), cache = cache)
  expect_true(file.exists("input.rds"))
  expect_false(encode_path("input.rds") %in%
    config$cache$list())

  # clean removes imported functions and cleans up 'functions'
  # namespace
  expect_true(cached(f, cache = cache))
  expect_true("f" %in% config$cache$list())
  clean(f, cache = cache)
  expect_false("f" %in% config$cache$list())

  clean(destroy = FALSE, cache = cache)
  expect_equal(config$cache$list(), character(0))
  expect_false(file.exists("intermediatefile.rds"))
  expect_true(file.exists("input.rds"))
  expect_false(file.exists(default_cache_path()))
  expect_true(file.exists(path))

  clean(destroy = TRUE, cache = cache)
  expect_false(file.exists(path))
})

test_with_dir("clean in full build.", {
  skip_on_cran() # CRAN gets whitelist tests only (check time limits).
  config <- dbug()
  make(config$plan, envir = config$envir, verbose = FALSE)
  expect_true("final" %in% config$cache$list())
  clean(final, search = TRUE)
  expect_false("final" %in% config$cache$list())
  clean(search = TRUE)
  expect_equal(config$cache$list(), character(0))
  expect_true(file.exists(default_cache_path()))
  clean(search = TRUE, destroy = TRUE)
  expect_false(file.exists(default_cache_path()))
})
