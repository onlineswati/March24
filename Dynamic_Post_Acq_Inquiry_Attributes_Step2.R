setwd('/home/ubuntu/data/Project/scripts')
File <- "Dynamic_Post_Acq_Inquiry_Attributes_Step2.R"
Files <- list.files(recursive=T,include.dirs=T)
Path.file <- names(unlist(sapply(Files,grep,pattern=File))[1])
Dir.wd <- dirname(Path.file)
setwd(Dir.wd)


source('Dynamic_Post_Acq_Inquiry_Attributes_Step2A.R')