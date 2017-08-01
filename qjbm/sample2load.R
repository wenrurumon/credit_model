rm(list=ls())

library(data.table)
library(dplyr)
setwd('C:/Users/WenluluSens/Documents/qianji/beimi/sample')
load('beijing_shanghai.rda')

##########################

x <- pdata[[10]]
x.loan <- as.Date(filter(x$x.behavior,type=='apply_loan')$timestamp)
d <- x.loan[1]

filter(x$x.call,as.Date(date)<=d)
