# Event loan di-upload ke marketplace
df_marketplace <- df_event %>% 
    filter(nama_event == 'loan_to_marketplace') %>% 						
    select(loan_id, marketplace = created_at) 
df_marketplace

# Event investor melihat detail loan
df_view_loan <- df_event %>% 
  filter(nama_event == 'investor_view_loan') %>% 
  group_by(loan_id, investor_id) %>% 
  summarise(jumlah_view = n(), 
            pertama_view = min(created_at), 
            terakhir_view = max(created_at))
df_view_loan

# Event investor pesan dan bayar loan
library(tidyr)

df_order_pay <- df_event %>%
    filter(nama_event %in% c('investor_order_loan', 'investor_pay_loan')) %>%
    spread(nama_event, created_at) %>%
    select(loan_id, 
            investor_id, 
            order = investor_order_loan, 
            pay = investor_pay_loan)
df_order_pay

# Gabungan Data Loan Investasi
df_loan_invest <- df_marketplace %>% 
    left_join(df_view_loan, by = 'loan_id') %>% 
    left_join(df_order_pay, by = c('loan_id','investor_id'))
df_loan_invest

# Melihat hubungan jumlah view dengan order
df_loan_invest %>%
    mutate(status_order = ifelse(is.na(order),'not_order','order')) %>%
    count(jumlah_view, status_order) %>%
    spread(status_order, n, fill = 0) %>%
    mutate(persen_order = scales::percent(order/(order+not_order)))

# Berapa lama waktu yang dibutuhkan investor untuk pesan sejak pertama melihat detail loan

df_loan_invest %>%
    filter(!is.na(order)) %>%
    mutate(lama_order_view = as.numeric(difftime(order, pertama_view, units = "mins"))) %>% 
    group_by(jumlah_view) %>% 
    summarise_at(vars(lama_order_view), funs(total = n(), min, median, mean, max)) %>% 
    mutate_if(is.numeric, funs(round(.,2)))

# Rata- rata waktu pemesanan sejak loan di-upload setiap minggu nya
library(ggplot2)

df_lama_order_per_minggu <- df_loan_invest %>% 
    filter(!is.na(order)) %>%
    mutate(tanggal = floor_date(marketplace, 'week'),
            lama_order = as.numeric(difftime(order, marketplace, units = "hour"))) %>% 
    group_by(tanggal) %>%
    summarise(lama_order = median(lama_order)) 

ggplot(df_lama_order_per_minggu) +
    geom_line(aes(x = tanggal, y = lama_order)) +
    theme_bw() + 
    labs(title = "Rata-rata lama order pada tahun 2020 lebih lama daripada 2019",
        x = "Tanggal",
        y = "waktu di marketplce sampai di-pesan (jam)")

# Apakah Investor membayar pesanan yang dia buat
df_bayar_per_minggu <- df_loan_invest %>% 
    filter(!is.na(order)) %>%
    mutate(tanggal = floor_date(marketplace, 'week')) %>% 
    group_by(tanggal) %>%
    summarise(persen_bayar = mean(!is.na(pay))) 

ggplot(df_bayar_per_minggu) +
    geom_line(aes(x = tanggal, y = persen_bayar)) +
    scale_y_continuous(labels = scales::percent) +
    theme_bw() + 
    labs(title = "Sekitar 95% membayar pesanannya. Di akhir mei ada outlier karena lebaran",
        x = "Tanggal",
        y = "Pesanan yang dibayar")

# Waktu yang dibutuhkan investor untuk membayar pesanan
df_lama_bayar_per_minggu <- df_loan_invest %>% 
    filter(!is.na(pay)) %>%
    mutate(tanggal = floor_date(order, 'week'),
            lama_bayar = as.numeric(difftime(pay, order, units = "hour"))) %>% 
    group_by(tanggal) %>%
    summarise(lama_bayar = median(lama_bayar)) 

ggplot(df_lama_bayar_per_minggu) +
    geom_line(aes(x = tanggal, y = lama_bayar)) +
    theme_bw() + 
    labs(title = "Waktu pembayaran trennya cenderung memburuk, 2x lebih lama dari sebelumnya",
        x = "Tanggal",
        y = "waktu di pesanan dibayar (jam)")
