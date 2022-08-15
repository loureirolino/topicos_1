#install.packages("sparklyr")
library(sparklyr)

# You have to install locally (on the driver where RStudio is running) the same Spark version
spark_v = "2.4.5"
#cat("Installing Spark in the directory:", spark_install_dir())
# spark_install(version = spark_v)

# config 
conf = spark_config()
#conf$`spark_connect_gateway` = 4040


if (c('sc') %in% ls() == TRUE && is.null(conn) == FALSE){
  invisible()
} else {
  sc = spark_connect(spark_home = spark_install_find(version=spark_v)$sparkVersionDir, 
                     master = 'local',
                     version = spark_v,
                     config = conf)
}

# if (c('sc') %in% ls() == TRUE && is.null(conn) == FALSE){
#   invisible()
# } else {
#   sc = spark_connect(spark_home = spark_install_find(version=spark_v)$sparkVersionDir, 
#                      master = "spark://10.68.14.110:7077/",
#                      version = spark_v,
#                      config = conf)
# }


