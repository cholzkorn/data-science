library(onehot)

predictors <- tibble(df$MarketSize, df$AgeOfStore, df$Promotion, df$week)

oh_predictors <- cbind(model.matrix(~MarketSize -1, data = df), model.matrix(~AgeOfStore -1, data = df))
