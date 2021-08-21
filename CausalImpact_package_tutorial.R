# followed the tutorial from here:
# https://cran.r-project.org/web/packages/CausalImpact/vignettes/CausalImpact.html


# install.packages("CausalImpact")
library(CausalImpact)

# create an example dataset
# response variable y, predictor x1
set.seed(1)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y <- 1.2 * x1 + rnorm(100)
# create an intervention effect by lifting the response variable by 10 units after timepoint 71
y[71:100] <- y[71:100] + 10
data <- cbind(y, x1)

# simple matrix with 100 rows and two columns
dim(data)
head(data)

# visualise the generated data using matplotlib
matplot(data, type = "l")

# specify which period in the data should be used for training the model (pre-intervention period)
pre.period <- c(1, 70)

# specify which period should be used for computing a counterfactual prediction (post-intervention period)
post.period <- c(71, 100)

# to perform inference, we run the analysis
# instructs the package to assemble a structural time-series model, 
# perform posterior inference, and compute estimate of the causal effect
# return value is the CausalImpact object
impact <- CausalImpact(data, pre.period, post.period)

# visualise the results
plot(impact)

# panel 1: data and a counterfactual prediction for the post-treatment period
# panel 2: difference between observed data and counterfactural predictions > pointwise causal effect as estimated by the model
# panel 3: adds up the pointwise contributions from panel 2, resilting in a plot of the cumulative effect of the intervention
# inferences depend on the assumption that the covariates were not themselves afffected by the intervention
# model also assumes that the relationship between covariates and treated time series, as established during the pre-period, 
# remains stable throughout the post-period

# feed a time-series object into CausalImpact() rather than a data frame
time.points <- seq.Date(as.Date("2021-01-01"), by = 1, length.out = 100)
data <- zoo(cbind(y, x1), time.points)
head(data)

# specify the pre-period and the post-period in terms of time points rather than indices
pre.period <- as.Date(c("2021-01-01", "2021-03-10"))
post.period <- as.Date(c("2021-03-11", "2021-04-10"))

# as a result, the x-axis of the plot shows time points instead of indices
impact <- CausalImpact(data, pre.period, post.period)
plot(impact)

# obtain a numerical summary of the analysis
summary(impact)  
# impact$summary # for full precision and not rounded precision
# summary(impact, "report")  # for a detailed report

# average: average (across time) during the post-intervention period
# cumulative: sums up individual time points, which are useful perspective if the response variable represents a flow quantity (e.g. queries, clicks, visits) rather than a stock quantity (e.g. #users, stock price)



