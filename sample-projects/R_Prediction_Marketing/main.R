# clear environment variables
rm(list =ls())

# installing and loading dependencies
library(tidyverse)
library(xgboost)
library(FNN)
library(rpart)
library(cluster)
library(randomForest)
library(modelr)
library(caret)

# ---- LOAD THE DATA ------------------------------------------------------------------------------- #
df <- read_csv("C:/Users/Clem/OneDrive/Informatik_Lernen/Statistics/SampleProjects/Prediction_Marketing/marketing.csv")
df


# ---- DATA TRANSFORMATION ------------------------------------------------------------------------- #

# convert the variables to meaningful types

# SalesInThousands should be left as numbers
# MarketID and LocationID are arbitrary numbers and do not make sense as predictors
# MarketSize, the type of Promotion as well as the week make sense as factors, since
# week only takes on 4 discrete values

unique(df$week)

df$MarketSize <- as.factor(df$MarketSize)
df$Promotion <- as.factor(df$Promotion)
df$week <- as.factor(df$week)

# AgeOfStore takes on many different values and therefore makes sense as a number

length(unique(df$AgeOfStore))



# ---- DATA EXPLORATION ---------------------------------------------------------------------------- #

# Since we are interested in the prediction of sales, we want to plot the different variables against
# the sales. To get a quick overview, we can use facets.

# In our first facet, we see that promotions tend to work equally well in different markets,
# but Promotion number 2 seems to perform worse across all markets

ggplot(data = df) +
  geom_boxplot(mapping = aes(x = Promotion, y = SalesInThousands, color = Promotion)) +
  facet_wrap(~ MarketSize, nrow = nlevels(df$MarketSize)) +
  theme(legend.position="none") +
  coord_flip()

# Next, we have a look on the influence of our promotional campaigns

# For this we have to merge group 1 and 3

by_promotion <- group_by(df, Promotion)
Promotion_means <- summarize(by_promotion, pm_means = mean(SalesInThousands, na.rm = TRUE))
Promotion_means

# As we have seen from the medians in the previous graph, promotion 2 seems to perform worse
# than 1 or 3
# We can use a test to identify if the difference in means is significant
# For this, we have to merge promotion 1 and 3 into 1

grouped_promotion <- df$Promotion
grouped_promotion[grouped_promotion == "3"] <- "1"
grouped_promotion

prom_meantest <- as.tibble(cbind(df$SalesInThousands, grouped_promotion))
prom_meantest$grouped_promotion <- as.factor(prom_meantest$grouped_promotion)

t.test(V1 ~ grouped_promotion, data = prom_meantest)

# We may reject the hypothesis that the average sales of the promotional campaign number 2
# equals those of the other campaigns.

# In the another facet, we see that the influence of weeks on Sales might be very small.
# Only the sales in small markets could be affected by the influence of weeks

ggplot(data = df) +
  geom_boxplot(mapping = aes(x = week, y = SalesInThousands, color = week)) +
  facet_wrap(~ MarketSize, nrow = nlevels(df$MarketSize)) +
  theme(legend.position="none") +
  coord_flip()

# In this next plot we can see that the age of the store does not have a clear impact
# on sales

ggplot(data = df, aes(x = AgeOfStore, y = SalesInThousands)) +
  geom_point() +
  geom_smooth()

# The main influence on sales seems to be the market size

ggplot(data = df, aes(x = MarketSize, y = SalesInThousands)) +
  geom_boxplot()

# Accordingly, we calculate the means and medians of Sales, grouped by MarketSize
# and we see that the mean, as well as the median, differ greatly, with large markets
# being the most profitable on average

MSize_median <- group_by(df, MarketSize) %>%
  summarize(median = median(SalesInThousands))

MSize_mean <- group_by(df, MarketSize) %>%
  summarize(mean = mean(SalesInThousands))

MSize_location <- as.tibble(cbind(MSize_median[,1], MSize_median[,2], MSize_mean[,2]))
MSize_location

# As a final step to discover hidden factors, we build a tree model

df_tree <- rpart(SalesInThousands ~ MarketSize + AgeOfStore + Promotion + week,
                 data = df, control = rpart.control(cp=.005))

plot(df_tree, uniform = TRUE, margin = .05)
text(df_tree)

# With this information, we can move on to our predictive model





# ---- PREDICTORS, SCALING AND ENCODING AS ONE HOT ENCODER ------------------------------- #

# Following variables may be useful as predictors in the modeling process:
  # MarketSize
  # AgeOfStore
  # Promotion
  # Week

# BASIC MODEL

scale0_1 <- function(x){(x-min(x))/(max(x)-min(x))}
unscale <- function(a, x){a * (max(x) - min(x)) + min(x)} # where x is the original and a the scaled data

# First, we build the model with factor variables for the linear regression
# the only variables that need to be changed are AgeOfStore and SalesInThousands (scaling)

predictors <- tibble(MarketSize = df$MarketSize,
                     Promotion = df$Promotion,
                     AgeOfStore = scale0_1(df$AgeOfStore),
                     week = df$week)
independent <- scale0_1(df$SalesInThousands)
mdf <- as.tibble(cbind(SalesInThousands = independent, predictors))
mdf



# SCALED MODEL WITH ONE HOT ENCODING

# The factor variables have to be encoded using the "One Hot Encoder"-method,
# while AgeOfStore has to be scaled to fit the interval [0,1]

s_predictors <- as.tibble(cbind(model.matrix(~ MarketSize -1, data = df),
                                 model.matrix(~ week -1, data = df),
                                 model.matrix(~ Promotion -1, data = df),
                                 AgeOfStore = scale0_1(df$AgeOfStore)))

s_predictors

# We also scale the independent variable and combine everything to a dataframe that will
# be the basis of our modeling process

s_sales <- scale0_1(df$SalesInThousands)

s_mdf <- as.tibble(cbind(SalesInThousands = s_sales, s_predictors))

s_mdf









# ---- SPLITTING ------------------------------------------------------------------------- #

# Splitting the data into training and test sets

# For the basic model

n = nrow(mdf)
trainIndex = sample(1:n, size = round(0.7*n), replace=FALSE)
train = mdf[trainIndex ,]
test = mdf[-trainIndex ,]

# For the scaled and encoded model

s_n = nrow(s_mdf)
s_trainIndex = sample(1:n, size = round(0.7*n), replace=FALSE)
s_train = s_mdf[trainIndex ,]
s_test = s_mdf[-trainIndex ,]


# ---- MODELS ----------------------------------------------------------------------------- #






# ---- LINEAR MODEL ----------------------------------------------------------------------- #

############ Since MarketSize seems to be the most influential variable, we should try a linear model

lmodel <- lm(mdf, data = train)
summary(lmodel)

# Now we look at how good our predictions were:

lm_pred <- predict(lmodel, test)

lm_test_pred <- tibble(values = test$SalesInThousands, predictions = lm_pred,
                       diff = test$SalesInThousands - lm_pred)

lm_test_pred

lm_diffplot <- tibble(values = lm_test_pred$values, error = lm_test_pred$diff,
                      cl = as.factor(test$MarketSize))

ggplot(lm_diffplot, aes(y = error, x = values, color = cl)) +
  geom_point() +
  geom_hline(yintercept = 0)

# These predictions look far-off, so we compute the RMSE to check

modelr::rmse(lmodel, data = df)








# ---- RANDOM FOREST ----------------------------------------------------------------------- #

############## As a next model, we try a random Forest

rf <- randomForest(s_train$SalesInThousands ~ ., data = s_train, importance = TRUE)

# First we have a look at how good our predictions were:
rf_pred <- predict(rf, s_test)
rf_test_pred <- tibble(values = s_test$SalesInThousands, predictions = rf_pred,
                                 diff = s_test$SalesInThousands - rf_pred)
rf_test_pred

rf_diffplot <- tibble(values = rf_test_pred$values, error = rf_test_pred$diff)

# The errors are also more evenly scattered around 0, even though the model
# still does a mediocre job of predictions for large values.

ggplot(rf_diffplot, aes(y = error, x = values)) +
  geom_point() +
  geom_hline(yintercept = 0)

# We notice large errors for the groups "Large" and "Medium", while the estimation of
# the group "Small" tends to work better

# The random Forest also computed the variable importance. This mainly confirms what
# we have seen in the Exploratory Analysis. The most important variables are
# MarketSize and Promotion (Promotional campaign #2 in particular).
# The age of the store is only of importance in regards to the Gini Decrease,
# but not regarding Accuracy.

varImpPlot(rf, type = 1, main = "Accuracy Decrease")
varImpPlot(rf, type = 2, main = "Gini Decrease")

# Finally we compute the RMSE
mean(sqrt(rf$mse))

# As expected, the Random Forest outperforms the simple linear model.





# ---- BOOSTING ----------------------------------------------------------------------------- #

############## Finally, we try to get even better predictions with boosting. For that, we try
############## a few different models with different settings for the shrinkage factor (eta)
############## and the maximum depth of the tree (max_depth)

# First we set up the folds and the parameter list:

ms_predictors <- data.matrix(s_predictors)
ms_sales <- as.numeric(s_sales)

N <- nrow(ms_predictors)
fold_number <- sample(1:5, N, replace = TRUE)
params <- data.frame(eta = rep(c(.1, .5, .9), 3),
                     max_depth = rep(c(3, 6, 12), rep(3,3)))

# Now we apply the preceding algorithm to compute the error for each model and each fold
# using five folds

error <- matrix(0, nrow = 9, ncol =5)
for(i in 1:nrow(params)){
  for (k in 1:5){
    fold_idx <- (1:N)[fold_number == k]
    xgb <- xgboost(data = ms_predictors, label = ms_sales,
                   params = list(eta = params[i, "eta"],
                                 max_depth = params[i, "max_depth"]),
                   objective = "reg:linear", nrounds = 100, verbose = 0)
    pred <- predict(xgb, ms_predictors)
    error[i, k] <- mean(ms_sales - pred)
  }
}

# The errors are stored as a matrix with the models along the rows and folds along
# the columns.

avg_error <- 100 * rowMeans(error)
xgb_mdls_errors <- as.tibble(cbind(params, avg_error))
xgb_mdls_errors_abs <- as.tibble(cbind(params, avg_error_abs = abs(avg_error)))

# We get the smallest error for eta = 0.9 and max_depth = 6

xgb_winner <- arrange(xgb_mdls_errors_abs, avg_error_abs)[1,]
xgb_winner

# Therefore we now build this model and compute the rmse. Cross-Validation already took place,
# since the model was fitted on 5 different folds

xgb_finalmodel <- xgboost(data = ms_predictors, label = ms_sales,
                          objective = "reg:linear", nrounds = 100,
                          eta = xgb_winner$eta, xgb_winner$max_depth)

# Transform test to data.matrix, so that we can compare the three models. In comparison to
# the other two models, the errors are smaller and spread out more evenly. Finally, we see
# that we were able to achieve an even lower RMSE than with the Random Forest.

ms_test <- data.matrix(s_test[,-1])

xgb_pred <- predict(xgb_finalmodel, ms_test)

xgb_test_pred <- tibble(values = s_test$SalesInThousands, predictions = xgb_pred,
                       diff = s_test$SalesInThousands - xgb_pred)
xgb_test_pred

xgb_diffplot <- tibble(values = xgb_test_pred$values, error = xgb_test_pred$diff)

ggplot(rf_diffplot, aes(y = error, x = values)) +
  geom_point() +
  geom_hline(yintercept = 0)

# Finally, we compute the RMSE of the boosted model. This final model is recommended
# when trying to predict sales for new data.

min(xgb_finalmodel$evaluation_log$train_rmse)

# A final step we could take is weighting the data to achieve more evenly scattered errors
# and an even smaller RMSE. The values between 0.25 and 0.6 are evenly scattered and well-predicted.
# As we have seen throughout the analysis, the errors left and right of this interval are
# mainly driven by the MarketSize (Medium and Large).

# Weighting, however, will not solve this issue, since the observations Medium and Large markets
# already more numerous than those of Small ones. The "over-representation" of Medium Markets
# does not lead to a "predictive shift" in their favor.

nrow(df[df$MarketSize == "Large",])
nrow(df[df$MarketSize == "Small",])
nrow(df[df$MarketSize == "Medium",])

# A purposeful deviation from the proposed prediction model might be to formulate three models,
# grouped by the Market Size, which, of course depends on the subject of business matter.