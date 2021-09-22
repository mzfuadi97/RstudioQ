library(dplyr)
df_loan <- read.csv('https://dqlab-dataset.s3-ap-southeast-1.amazonaws.com/loan_disbursement.csv', 
                    stringsAsFactors = F)
dplyr::glimpse(df_loan)


# [Memfilter data bulan Mei 2020, dan jumlahkan data per cabang]


df_loan_mei <- df_loan %>% 
  filter(tanggal_cair >=  '2020-05-01', 
         tanggal_cair <= '2020-05-31') %>% 
  group_by(cabang) %>% 
  summarise(total_amount = sum(amount)) 
df_loan_mei
