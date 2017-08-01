
##########################
#初始化设置
##########################

rm(list=ls()) #清理内存
library(rjson) #导入RJSON的代码库
setwd('C:/Users/WenluluSens/Documents/qianji/beimi/data') #设置工作文件夹

tryapply <- function(x,fun,fun2=lapply){
  fun3 <- function(x){
    rlt <- try(fun(x))
    if(class(rlt)=="try-error"){
      return(NULL)
    } else {
      return(rlt)
    }
  }
  rlt <- fun2(x,fun3)
  rlt[!sapply(rlt,is.null)]
}
lcode<- function(x){
  for(i in 1:length(x)){
    if(is.null(x[[i]])){next}
    x[[i]] <- cbind(i,x[[i]])
  }
  return(do.call(rbind,x))
}
#这句先别管

##########################
#读取原始数据
##########################

fs <- dir() #dir函数用于读取当前文件夹下的所有文件文件名，赋值为fs
json2r <- function(x){
  x <- readLines(x,encoding='UTF-8')
  fromJSON(x)
} 
#创造了一个函数，给定文件名x，第一步读取x中的所有内容，第二步json格式的内容改为Rlist格式

rawdata <- tryapply(fs,json2r)
pdata <- lapply(rawdata,function(x){
  basic <- unlist(x$basic)
  calllog <- do.call(rbind,x$callLog$calls)
  record <- do.call(rbind,x$existingCustomer)
  behavior <- do.call(rbind,x$behavior)
  device <- try(unlist(x$device[[length(x$device)]][-1]))
  emergency <- do.call(rbind,x$emergencyContacts)
  contacts <- do.call(rbind,x$contacts)
  credit <- unlist(x$credit)
  score <- 1-table(unlist(record[,5]))[('overdue')]/table(unlist(record[,2]))['paid']
  reject <- 1-table(unlist(record[,2]))[('paid')]/nrow(record)
  list(basic=basic,calllog=calllog,record=record,behavior=behavior,
       device=device,emergency=emergency,contacts=contacts,credit=credit,
       score=score,reject=reject)
})
score <- sapply(pdata,function(x)x$score)
pdata <- pdata[!is.na(score)]
score <- score[!is.na(score)]

test <- sapply(pdata,function(xi){
  # ifelse(is.null(xi$credit),NA,xi$credit)
  # length(unique(xi$calllog[,1]))/length(xi$calllog[,1])
  mean(unlist(xi$behavior[,2])=='apply_loan')
})
y <- score[!is.na(test)]
x <- test[!is.na(test)]
cor(y,x)
y <- y>0
test <- MASS::lda(y~x)
table(predict(test)$class,y)
sum(diag(table(predict(test)$class,y)))/length(y)

#########################
#数据overview
#########################

# credit <- sapply(rawdata,function(x){
#   ifelse(is.null(x$credit$zmxyScore),0,x$credit$zmxyScore)
# })
# basic <- cbind(t(sapply(rawdata,function(x){x$basic})),credit)
# call <- lcode(lapply(rawdata,function(x){do.call(rbind,x[[2]][[3]])}))
# record <- lcode(lapply(rawdata,function(x){do.call(rbind,x$existingCustomer)}))
# beh <- lcode(lapply(rawdata,function(x){do.call(rbind,x$behavior)}))
# contacts <- lcode(lapply(rawdata,function(x){do.call(rbind,x$contacts)}))
# apps <- sapply(rawdata,function(x){paste(unique(paste(unlist(x$apps))),collapse=';')})
# setwd('..')
# setwd('sample')
# 
# write.csv(basic,'basic.csv')
# write.csv(call,'call.csv')
# write.csv(record,'record.csv')
# write.csv(beh,'beh.csv')
# write.csv(contacts,'contacts.csv')
# write.csv(apps,'apps.csv')
