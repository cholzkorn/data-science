# Plotting Classification Trees with the plot.rpart and rattle pckages

library(rpart)				        # Popular decision tree algorithm
library(rattle)					# Fancy tree plot
library(rpart.plot)				# Enhanced tree plots
library(RColorBrewer)				# Color selection for fancy tree plot
library(party)					# Alternative decision tree algorithm
library(partykit)				# Convert rpart object to BinaryTree
library(caret)					# Just a data source for this script

seatbelts <- Seatbelts
seatbelts <- as.data.frame(seatbelts)
unique(seatbelts$law)


seatbelts_tree <- rpart(law ~ ., data=seatbelts)
plot(seatbelts_tree, uniform = TRUE, margin = 0.5)
text(seatbelts_tree)

prp(seatbelts_tree)
fancyRpartPlot(seatbelts_tree)