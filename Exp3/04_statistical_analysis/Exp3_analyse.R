## Analyse the experiments of the RL emotion study
library(tidyverse)
library(lme4)
library(lmerTest)
source("theme-publication.R")



######################
# free rating #
######################

data <- read.table("../data/human_free_limit.csv", header = T, sep = ";") %>%
  pivot_longer(cols = starts_with("Emo."),
               names_to = "Emotion",
               names_prefix = "Emo.",
               values_to = "Val")

## test the hypothesis
model <- lmer(Val ~ Story*Emotion + (1|ID), data = data)
anova(model)

## Get 95% CI (approximate, not estimated)
data.h <- data %>% group_by(Story, Emotion) %>%
  summarise(sd = sd(Val),Val = mean(Val)) %>%
  mutate(SE = sd / sqrt(length(unique(data$ID))),
         CI_lower = Val - 1.96*SE,
         CI_upper = Val + 1.96*SE) %>%
  dplyr::select(Story, Emotion, Val, CI_lower, CI_upper)

data.m <- read.table("../data/svm_free_0.0013_var.csv", header = T, sep = ",") %>%
  group_by(Story, Emotion) %>%
  summarise(Val = mean(Val)) %>%
  mutate(CI_lower = Val, CI_upper = Val)

## Visualise the effect

# ggplot(data %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)),
#        aes(Emotion, Val)) +
#   geom_bar(stat = "identity") +
#   facet_grid(Story ~ .) +
#   ylim(0,1)


## Visualise both data1 and data.m
# data.b <- data %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)) %>%
#   mutate(Val = Val/sum(Val)) %>%
#   mutate(Source = "Human") %>%
#   rbind(data.m %>% mutate(Source = "Model"))

data.b <- data.h %>%
  mutate(Source = "Human") %>%
  rbind(data.m %>% mutate(Source = "Model"))


ggplot(data.b, aes(Emotion, Val, fill = Source)) +
  geom_bar(stat = "identity",width = 0.8, position = position_dodge(0.85)) +
  geom_errorbar(aes(ymin = ifelse(Source == "Human", CI_lower, NA), 
                    ymax = ifelse(Source == "Human", CI_upper, NA)), 
                width = 0.2, position = position_dodge(0.85)) +  
  facet_grid(Story ~ .) +
  ylab("Intensity") + xlab('Emotion')+
  scale_y_continuous(limits = c(0,0.6),breaks = c(0,0.3,0.6))+
  theme_Publication() + scale_fill_Publication() + 
  theme(legend.position = c(0.92, 0.96),
        legend.margin = margin(1, 1, 1,1, "mm"),
        legend.title=element_blank(),
        legend.background = element_rect(fill='transparent'),
        panel.grid.major.x = element_blank() ,
        legend.key.size = unit(0.9, "lines"),
        legend.box.background = element_rect(colour = "black",fill="transparent"),
        legend.spacing.y = unit(0, "mm"))

ggsave(file = "../plots/exp3_free.jpg", width=8, height=8)

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


summary(lm(Val.x ~ Val.y, data = data.bl))

sqrt(data.bl%>%ungroup() %>%summarise(d=mean(d)))

#####################
# limit rating #
#####################



data2 <- read.table("../data/human_free_limit.csv", header = T, sep = ";") %>%
  pivot_longer(cols = starts_with("mc"),
               names_to = "Emotion",
               names_prefix = "mc.",
               values_to = "Val")

## test the hypothesis
model <- lmer(Val ~ Story*Emotion + (1|ID), data = data2)
anova(model)

## Get 95% CI (approximate, not estimated)
data.h2 <- data2 %>% group_by(Story, Emotion) %>%
  summarise(sd = sd(Val),Val = mean(Val)) %>%
  mutate(SE = sd / sqrt(length(unique(data$ID))),
         CI_lower = pmax(Val - 1.96*SE, 0),
         CI_upper = pmin(Val + 1.96*SE, 1)) %>%
  dplyr::select(Story, Emotion, Val, CI_lower, CI_upper)

data.m2 <- read.table("../data/svm_limit_0.0034_var.csv", 
                      header = T, sep = ",") %>%
  group_by(Story, Emotion) %>%
  summarise(Val = mean(Val))

# ggplot(data.m2 %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val))%>%
#          mutate(Val = Val/sum(Val)),
#        aes(Emotion, Val)) +
#   geom_bar(stat = "identity") +
#   facet_grid(Story ~ .) +
#   ylim(0,1)

## Visualise both data2 and data.m
# data.b2 <- data2 %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)) %>%
#   mutate(Val = Val/sum(Val)) %>%
#   mutate(Source = "Human") %>%
#   rbind(data.m2 %>% mutate(Source = "Model"))

data.b2 <- data.h2 %>%
  mutate(Source = "Human") %>%
  rbind(data.m2 %>% mutate(Source = "Model"))

ggplot(data.b2, aes(Emotion, Val, fill = Source)) +
  geom_bar(stat = "identity",width = 0.8, position = position_dodge(0.85)) +
  geom_errorbar(aes(ymin = ifelse(Source == "Human", CI_lower, NA), 
                    ymax = ifelse(Source == "Human", CI_upper, NA)), 
                width = 0.2, position = position_dodge(0.85)) + 
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

ggsave(file = "../plots/exp3_limit.jpg", width=8, height=8)

## Both data, long form
data.bl2 <- data2 %>% group_by(Story, Emotion) %>% summarise(Val = mean(Val)) %>%
  mutate(Val = Val/sum(Val)) %>%
  left_join(data.m2, by = c("Story","Emotion")) %>%
  mutate(d = (Val.x - Val.y)^2)

## Investigate fit
ggplot(data.bl2 %>% group_by(C) %>% summarise(d = mean(d)) %>%
         mutate(d = sqrt(d)),
       aes(C, d)) +
  geom_point() +
  geom_smooth()


summary(lm(Val.x ~ Val.y, data = data.bl2))
sqrt(data.bl2%>%ungroup() %>%summarise(d=mean(d)))
