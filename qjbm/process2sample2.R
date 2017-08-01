
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
bind <- function(x){
  x <- do.call(rbind,x)
  x <- as.matrix(apply(x,2,paste))
  if(ncol(x)==1){x <- t(x)}
  as.data.frame(x,stringsAsFactors=F)
}
is.error <- function(x){
  class(x)=='try-error'
}

##########################
#读取原始数据
##########################

fs <- dir() #dir函数用于读取当前文件夹下的所有文件文件名，赋值为fs
json2r <- function(x){
  x <- readLines(x,encoding='UTF-8')
  fromJSON(x)
} 
raw_bk <- tryapply(fs,json2r)
raw <- raw_bk[1:20]

##########################
#处理每个文件的数据
##########################

print(i <- 0)
pdata <- lapply(raw_bk,function(x){
  print(i<<-i+1)
  x.basic <- unlist(x$basic)
  x.call <- bind(x$callLog[[3]])
  x.contact <- try(bind(x$contacts))
    x.contact <- ifelse(is.error(x.contact),NA,x.contact)
  x.behavior <- try(bind(x$behavior))
    x.behavior <- ifelse(is.error(x.behavior),NA,x.behavior)
  x.record <- bind(x$existingCustomer)
  x.dev <- try(bind(lapply(x$device,function(x)x[-1])))
    x.dev <- ifelse(is.error(x.dev),NA,x.dev)
  x.app <- lapply(x$device,function(x) x[[1]])
  x.credit <- ifelse(is.null(x$credit[[1]]),NA,x$credit[[1]])
  x.em <- bind(x$emergencyContacts)
  list(x.basic=x.basic,x.call=x.call,x.contact=x.contact,
       x.behavior=x.behavior,x.record=x.record,x.dev=x.dev,
       x.app=x.app,x.credit=x.credit,x.em=x.em)
})
setwd('../sample')
save(raw_bk,pdata,file='beijing_shanghai.rda')

