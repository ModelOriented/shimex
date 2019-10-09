context("Check modelDown() function")


model_rm <- randomForest::randomForest(life_length ~., data = DALEX::dragons[1:100,], ntree = 200)
explainer <- DALEX::explain(model_rm)

test_that("Default arguments", {
  paste(DALEX::dragons[1, ])
  expect_true({
    create_shimex(explainer, 
                  DALEX::dragons[1, ],
                  run = FALSE)
    
    TRUE
  })
})