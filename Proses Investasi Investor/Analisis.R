# Import Data
library(dplyr)
df_event <- read.csv('https://storage.googleapis.com/dqlab-dataset/event.csv', stringsAsFactors = F)
dplyr::glimpse(df_event)


library(lubridate)
# Mengubah kolom created_at menjadi tipe Timestamp
df_event$created_at <- ymd_hms(df_event$created_at)
dplyr::glimpse(df_event)

# Summary Event
df_event %>%
  group_by(nama_event) %>%
  summarise(jumlah_event = n(), 
            loan = n_distinct(loan_id), 
            investor = n_distinct(investor_id))

