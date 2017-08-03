
# rm(list=ls()) 
library(dplyr);
setwd('C:/Users/WenluluSens/Documents/qianji/beimi/sample')
# load('beijing_shanghai.rda')

x.record <- t(sapply(pdata,function(x){
    out <- select(x$x.record,loan_decision,loan_status,max_overdue_day)
    a1 <- sum(as.numeric(out$max_overdue_day))
    a2 <- sum(out$loan_decision=='paid')
    a3 <- a1/a2
    c(overdue=a1,paid=a2,rate=a3)
  }))
x.bad <- (x.record[,1]>7)

x.score <- sapply(pdata,function(x){
  x$x.credit
})
