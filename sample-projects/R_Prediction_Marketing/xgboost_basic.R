library(xgboost)

ms_predictors <- data.matrix(s_predictors)
ms_label <- as.numeric(s_sales)

xgb <- xgboost(data = ms_predictors, label = ms_label,
               objective = "reg:linear", nrounds = 100)

