boston = read.csv('boston.csv')
str(boston)

plot(boston$LON,boston$LAT)
points(boston$LON[boston$CHAS==1],boston$LAT[boston$CHAS==1], col="blue", pch=19)
points(boston$LON[boston$TRACT==3531], boston$LAT[boston$TRACT==3531], col="red" , pch = 19)
##polution
summary(boston$NOX)

points(boston$LON[boston$NOX>0.55], boston$LAT[boston$NOX>0.55], col="green",pch=19)

summary(boston$MEDV)
##reset the plot
plot(boston$LON,boston$LAT)
points(boston$LON[boston$MEDV>=21.2], boston$LAT[boston$MEDV>=21.2], col="red" , pch = 19)



##build a linear model

lonlatlm = lm(MEDV~LAT + LON, data= boston)
summary(lonlatlm)
points(boston$LON[lonlatlm$fitted.values>=21.2],boston$LAT[lonlatlm$fitted.values>=21.2], col="green", pch ="$")

## build a regression tree use rpart
library(rpart)
library(rpart.plot)
latlontree = rpart(MEDV~ LAT +LON,data = boston)
prp(latlontree)
plot(boston$LON,boston$LAT)
points(boston$LON[boston$MEDV>=21.2], boston$LAT[boston$MEDV>=21.2], col="red" , pch = 19)

fittedvalues= predict(latlontree)
points(boston$LON[fittedvalues>=21.2], boston$LAT[fittedvalues>=21.2] , col="blue", pch="$")

#make sure this won't overfitting
latlontree_min = rpart(MEDV~ LAT +LON,data = boston, minbucket = 50)
plot(latlontree_min)
text(latlontree_min)
plot(boston$LON,boston$LAT)
#Add Straight Lines to a Plot
abline(v=-71.07)
abline(h=42.28)
abline(h=42.17)
points(boston$LON[boston$MEDV>=21.2], boston$LAT[boston$MEDV>=21.2], col="red" , pch = 19)

library(caTools)

set.seed(123)

split = sample.split(boston$MEDV, SplitRatio = 0.7)
train = subset(boston, split==TRUE)
test = subset(boston, split==FALSE)
linreg = lm(MEDV~ LAT + LON + CRIM +ZN + INDUS + CHAS + NOX + RM + AGE + DIS + RAD +TAX + PTRATIO, data = train)

summary(linreg)

linreg.pred = predict(linreg, newdata = test)

linreg.sse = sum((linreg.pred- test$MEDV)^2)

#build the tree to compare with the linear regression

tree = rpart(MEDV~ LAT + LON + CRIM +ZN + INDUS + CHAS + NOX + RM + AGE + DIS + RAD +TAX + PTRATIO, data = train)


prp(tree)
tree.pred = predict(tree, newdata = test)
tree.sse = sum((tree.pred-test$MEDV)^2)


library(caret)
library(e1071)
tr.control = trainControl(method = "cv", number = 10)
cp.grid = expand.grid(.cp = (0:10)*0.001)
tr= train(MEDV~ LAT + LON + CRIM +ZN + INDUS + CHAS + NOX + RM + AGE + DIS + RAD +TAX + PTRATIO, data = train, method = "rpart", trControl = tr.control, tuneGrid = cp.grid )
## the result is different with the video, maybe the version issue? 
best.tree = tr$finalModel
prp(best.tree)
best.tree.pred= predict(best.tree, newdata = test)
best.tree.sse = sum((best.tree.pred-test$MEDV)^2)