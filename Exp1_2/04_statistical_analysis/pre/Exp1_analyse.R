## Analyse the experiments of the RL emotion study
library(tidyverse)
library(lme4)
library(lmerTest)


source("theme-publication.R")
# Exp1_human_limited.csv for limited human result
data <- read.table("Exp1_human_limited.csv", header = T, sep = ";") %>%
  pivot_longer(cols = starts_with("Em."),
               names_to = "Emotion",
               names_prefix = "Em.",
               values_to = "Val")

# data$Emotion <- factor(data.l$Emotion, levels = c("Happiness","Joy","Pride",
#                                                 "Boredom","Shame","Sadness","Fear"))


# # Exp1_human.csv for free rating human result
# data <- read.table("Exp1_human.csv", header = T, sep = ";") %>%
#   pivot_longer(cols = starts_with("Em."),
#                names_to = "Emotion",
#                names_prefix = "Em.",
#                values_to = "Val")



## Visualise the effect
# ggplot(data %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)),
#        aes(Emotion, Val)) +
#   geom_bar(stat = "identity") +
#   facet_grid(Story ~ .) +
#   ylim(0,10)

## Standardise emotion within stories
data %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)) %>%
  mutate(Val = Val/sum(Val))

# data$Story <- factor(data$Story, levels = c("Happiness","Joy","Pride",
#                                                 "Boredom","Shame","Sadness","Fear"))
# data$Story <- factor(data$Emotion, levels = c("Happiness","Joy","Pride",
#                                             "Boredom","Shame","Sadness","Fear"))

# ggplot(data %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)) %>%
#          mutate(Val = Val/sum(Val)), aes(Emotion, Val)) +
#   geom_bar(stat = "identity") +
#   facet_grid(Story ~ .) +
#   ylim(0,1)


## Model SVM predictions for experiment 1.

data.m <- read.table("Exp1_svm_model_0.11.csv", header = T, sep = ",") %>%
  group_by(C, Story, Emotion) %>%
  summarise(Val = mean(Val))

## Visualise both data - combine model and human data
data.b <- data %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)) %>%
  mutate(Val = Val/sum(Val)) %>%
  mutate(Source = "Human") %>%
  rbind(data.m %>% mutate(Source = "Model"))


## Change the order of the x-axis and facet 
data.b$Story <- factor(data.b$Story, levels = c("Happiness","Joy","Pride",
                                        "Boredom","Fear","Sadness","Shame"))
data.b$Emotion <- factor(data.b$Emotion, levels = c("Happiness","Joy","Pride",
                                        "Boredom","Fear","Sadness","Shame"))

## Visualize both data - ggplot 
ggplot(data.b, aes(Emotion, Val, fill = Source,)) +
    geom_bar(stat = "identity",width = 0.8, position = position_dodge(0.85)) +
    facet_grid(Story ~ .) +
    ylab("Intensity") + xlab('Emotion')+
    scale_y_continuous(limits = c(0,1),breaks = c(0,0.5,1))+
    theme_Publication() + scale_fill_Publication() + 
    theme(legend.position = c(0.92, 0.96),
          legend.margin = margin(1, 1, 1,1, "mm"),
          legend.title=element_blank(),
          legend.background = element_rect(fill='transparent'),
          panel.grid.major.x = element_blank() ,
          legend.key.size = unit(0.9, "lines"),
          legend.box.background = element_rect(colour = "black",fill="transparent"),
          legend.spacing.y = unit(0, "mm"))


ggsave(file = "exp1_limit.jpg", width=8, height=8)

ggplot(data.b, aes(Emotion, Val, fill = Source)) +
  geom_point()

## Both data, long form
data.bl <- data %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)) %>%
    mutate(Val = Val/sum(Val)) %>%
    left_join(data.m, by = c("Story","Emotion")) %>%
    mutate(d = (Val.x - Val.y)^2)

## Investigate fit
ggplot(data.bl %>% group_by(C) %>% summarise(d = mean(d)) %>%
       mutate(d = sqrt(d)),
       aes(C, d)) +
    geom_point() +
    geom_smooth()

## Scatter plot for fit
ggplot(data.bl, aes(Val.y, Val.x)) +
    geom_point() +
    geom_smooth(method = "lm") +
    ylim(0,0.5) +
    xlim(0,0.5)


summary(lm(Val.x ~ Val.y, data = data.bl))

rmse 

