print(Sys.time())
options(scipen=999)

library(data.table)
library(plyr)
library(dplyr)
library(stringr)
library(splitstackshape)
library(tcltk)
library(Rserve)
Rserve()

get_scriptpath <- function() {
  # location of script can depend on how it was invoked:
  # source() and knit() put it in sys.calls()
  path <- NULL
  
  if(!is.null(sys.calls())) {
    path <- as.character(sys.call(1))[2] 
    # make sure we got a file that ends in .R, .Rmd or .Rnw
    if (grepl("..+\\.[R|Rmd|Rnw]", path, perl=TRUE, ignore.case = TRUE) )  {
      cat(path)
      return(path)
    } else { 
      message("Obtained value for path does not end with .R, .Rmd or .Rnw: ", path)
    }
  } else{
    # Rscript and R -f put it in commandArgs
    args <- commandArgs(trailingOnly = FALSE)
  }
  return(path)
}


mypath <- get_scriptpath()

output_name <- paste("Dynamic_Inquiry_Attributes_Post_Acq",".csv", sep = "" )

DIR <- dirname(mypath)
setwd(DIR)

merge_path <- read.table("merge_name.txt")


unlink("merge_name.txt")
setwd("..")
setwd(as.character(merge_path[1,1]))
setwd("temp")

Inq_Attr_Final <- data.frame()
for(file in list.files()) {
  
  df <- read.table(file, sep = "|",header=T,colClasses=c("LOS.APP.ID"="character"),
                   fill=T )
  print(nrow(df))
  
  if(nrow(Inq_Attr_Final) == 0){
    
    Inq_Attr_Final <- df
    
  } else {
    
    Inq_Attr_Final<-merge(Inq_Attr_Final, df, by="CREDT.RPT.ID", all=T)
    print(nrow(Inq_Attr_Final))
    
  }
  
}

# sets the wd to output location we defined and save with the chosen name.
setwd("..")

if (!file.exists("Output")){
  dir.create("Output")
}
setwd(".//Output")


Inq_Attr_Final<-Inq_Attr_Final[Inq_Attr_Final$CREDT.RPT.ID!="CREDT-RPT-ID",]

write.table(Inq_Attr_Final,file = output_name,sep="|",row.names = FALSE)

print(Sys.time())
gc()
rm(list=ls(all=TRUE))
