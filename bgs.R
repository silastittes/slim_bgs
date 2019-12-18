library(tidyverse)
library(ggridges)
library(cowplot)
theme_set(theme_cowplot())
library(magrittr)
library(patchwork)

neutral <- read.table("~/Documents/projects_ed/slim/bgs/raisd_bgs0sweep0.txt", sep = "\t") %>%
  as_tibble() %>% 
  set_colnames(c("start", "end", "loc", "var", "sfs", "ld", "u", "iter")) %>% 
  mutate(type = "neutral")
bgs <- read.table("~/Documents/projects_ed/slim/bgs/raisd_bgs0.2sweep0.txt", sep = "\t") %>%
  as_tibble() %>% 
  set_colnames(c("start", "end", "loc", "var", "sfs", "ld", "u", "iter")) %>%  
  mutate(type = "bgs")
sweep <- read.table("~/Documents/projects_ed/slim/bgs/raisd_bgs0sweep1.txt", sep = "\t") %>%
  as_tibble() %>% 
  set_colnames(c("start", "end", "loc", "var", "sfs", "ld", "u", "iter")) %>% 
  mutate(type = "sweep")
sweep_bgs <- read.table("~/Documents/projects_ed/slim/bgs/raisd_bgs0.2sweep1.txt", sep = "\t") %>%
  as_tibble() %>% 
  set_colnames(c("start", "end", "loc", "var", "sfs", "ld", "u", "iter")) %>% 
  mutate(type = "sweep_bgs")

sim_df <- bind_rows(bgs, neutral, sweep, sweep_bgs)

scan <- 
  sim_df %>% 
  ggplot(aes(loc, u, colour = factor(iter))) +
  geom_line(alpha = 0.5) +
  facet_wrap(~type, ncol = 1) +
  theme(legend.position = "n")

sim_df %>% 
  filter(iter == 1) %>% 
  ggplot(aes(loc, u, colour = factor(iter))) +
  geom_line(alpha = 0.5) +
  facet_wrap(~type, ncol = 1) +
  theme(legend.position = "n")


dens <- 
  sim_df %>% 
  ggplot(aes(u, type)) +
  geom_density_ridges(alpha = 0.5) +
  theme(legend.position = "n")

scan + dens + plot_layout(ncol = 2) + ggsave("~/Desktop/slim_raise.png")  
  
sim_df %>% 
  group_by(type) %>% 
  summarise(mean(u))

