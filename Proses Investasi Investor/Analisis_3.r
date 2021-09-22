library(dplyr)
library(lubridate)
library(ggplot2)
# Trend Investor Register

df_investor_register <- df_event %>% 
    filter(nama_event == 'investor_register') %>%
    mutate(tanggal = floor_date(created_at, 'week')) %>% 
    group_by(tanggal) %>%
    summarise(investor = n_distinct(investor_id)) 

ggplot(df_investor_register) +
    geom_line(aes(x = tanggal, y = investor)) +
    theme_bw() + 
    labs(title = "Investor register sempat naik di awal 2020 namun sudah turun lagi",
        x = "Tanggal",
        y = "Investor Register")

# Trend Investor Investasi Pertama
df_investor_pertama_invest <- df_event %>% 
    filter(nama_event == 'investor_pay_loan') %>%
    group_by(investor_id) %>% 
    summarise(pertama_invest = min(created_at)) %>% 
    mutate(tanggal = floor_date(pertama_invest, 'week')) %>% 
    group_by(tanggal) %>% 
    summarise(investor = n_distinct(investor_id)) 

ggplot(df_investor_pertama_invest) +
    geom_line(aes(x = tanggal, y = investor)) +
    theme_bw() + 
    labs(title = "Ada tren kenaikan jumlah investor invest, namun turun drastis mulai Maret 2020",
        x = "Tanggal",
        y = "Investor Pertama Invest")

# Cohort Pertama Invest berdasarkan Bulan Register
df_register_per_investor <- df_event %>%
    filter(nama_event == 'investor_register') %>% 
    rename(tanggal_register = created_at) %>%  
    mutate(bulan_register = floor_date(tanggal_register, 'month'))  %>%  
    select(investor_id, tanggal_register, bulan_register) 

df_pertama_invest_per_investor <- df_event %>%
    filter(nama_event == 'investor_pay_loan') %>% 
    group_by(investor_id) %>% 
    summarise(pertama_invest = min(created_at)) 

df_register_per_investor %>% 
    left_join(df_pertama_invest_per_investor, by = 'investor_id') %>% 
    mutate(lama_invest = as.numeric(difftime(pertama_invest, tanggal_register, units = "day")) %/% 30) %>%  
    group_by(bulan_register, lama_invest) %>% 
    summarise(investor_per_bulan = n_distinct(investor_id)) %>% 
    group_by(bulan_register) %>% 
    mutate(register = sum(investor_per_bulan)) %>% 
    filter(!is.na(lama_invest)) %>% 
    mutate(invest = sum(investor_per_bulan)) %>% 
    mutate(persen_invest = scales::percent(invest/register)) %>% 
    mutate(breakdown_persen_invest = scales::percent(investor_per_bulan/invest)) %>%  
    select(-investor_per_bulan) %>%  
    spread(lama_invest, breakdown_persen_invest)

# Cohort Retention Invest
df_investasi_per_investor <- df_event %>%
    filter(nama_event == 'investor_pay_loan') %>%
    rename(tanggal_invest = created_at) %>%
    select(investor_id, tanggal_invest)

df_pertama_invest_per_investor %>%
    mutate(bulan_pertama_invest = floor_date(pertama_invest, 'month')) %>%
    inner_join(df_investasi_per_investor, by = 'investor_id') %>%
    mutate(jarak_invest = as.numeric(difftime(tanggal_invest, pertama_invest, units = "day")) %/% 30) %>%
    group_by(bulan_pertama_invest, jarak_invest) %>%
    summarise(investor_per_bulan = n_distinct(investor_id)) %>%
    group_by(bulan_pertama_invest) %>%
    mutate(investor = max(investor_per_bulan)) %>%
    mutate(breakdown_persen_invest = scales::percent(investor_per_bulan/investor)) %>%
    select(-investor_per_bulan) %>%
    spread(jarak_invest, breakdown_persen_invest) %>%
    select(-`0`)