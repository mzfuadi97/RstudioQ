# Dataset Transaksi Penjualan DQLab.id Fashion
library(arules)

transaksi_tabular <- read.transactions(file="transaksi_dqlab_retail.tsv", 
                                        format="single", sep="\t", cols=c(1,2), skip=1)
write(transaksi_tabular, file="test_project_retail_1.txt", sep=",")

# Statistik Top 10
data <- read.transactions(file = "transaksi_dqlab_retail.tsv", 
                            format = "single", sep = "\t", cols = c(1,2), skip = 1)
top_10 <- sort(itemFrequency(data, type="absolute"), decreasing = TRUE)[1:10]
hasil <- data.frame("Nama Produk" = names(top_10), "Jumlah" = top_10, row.names = NULL)

# Statistik Bottom 10
data <- read.transactions(file = "transaksi_dqlab_retail.tsv", 
                            format = "single", sep = "\t", cols = c(1,2), skip = 1)
bottom_10 <- sort(itemFrequency(data, type = "absolute"), decreasing = FALSE)[1:10]
hasil <- data.frame("Nama Produk" = names(bottom_10), "Jumlah" = bottom_10, row.names = NULL)

# Mendapatkan Kombinasi Produk yang menarik
nama_file <- "transaksi_dqlab_retail.tsv"
transaksi_tabular <- read.transactions(file=nama_file, format="single", sep="\t", cols=c(1,2), skip=1)
apriori_rules <- apriori(transaksi_tabular, 
                            parameter=list(supp=10/length(transaksi_tabular), conf=0.5, minlen=2, maxlen=3))
apriori_rules <- head(sort(apriori_rules, by='lift', decreasing = T),n=10)
inspect(apriori_rules)

# Mencari Paket Produk yang bisa dipasangkan dengan Item Slow-Moving

nama_file <- "transaksi_dqlab_retail.tsv"
transaksi_tabular <- read.transactions(file=nama_file, format="single", sep="\t", cols=c(1,2), skip=1)
jumlah_transaksi<-length(transaksi_tabular)
jumlah_kemunculan_minimal <- 10
apriori_rules <- apriori(
    transaksi_tabular,
    parameter= list(supp=jumlah_kemunculan_minimal/jumlah_transaksi,
                    conf=0.1, minlen=2, maxlen=3))

# Filter
apriori_rules1 <- subset(apriori_rules, lift > 1 & rhs %in% "Tas Makeup")
apriori_rules1 <- sort(apriori_rules1, by='lift', decreasing = T)[1:3]
apriori_rules2 <- subset(apriori_rules, lift > 1 & rhs %in% "Baju Renang Pria Anak-anak")
apriori_rules2 <- sort(apriori_rules2, by='lift', decreasing = T)[1:3]
apriori_rules <- c(apriori_rules1, apriori_rules2)
inspect(apriori_rules)
write(apriori_rules,file="kombinasi_retail_slow_moving.txt")