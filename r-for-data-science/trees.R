library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)

seatbelts <- Seatbelts
seatbelts <- as.data.frame(seatbelts)
unique(seatbelts$law)


seatbelts_tree <- rpart(law ~ ., data=seatbelts, control = rpart.control(cp=0.05))
plot(seatbelts_tree, uniform = TRUE, margin = 0.5)
text(seatbelts_tree)

prp(seatbelts_tree)
fancyRpartPlot(seatbelts_tree, type=2)

seatbelts_tree # The split is made on the variable with the lowest p-value


# ctree solution - shows p values
library(partykit)

seatbelts_ctree <- ctree(law~ ., data=seatbelts)
seatbelts_ctree

plot(seatbelts_ctree)
