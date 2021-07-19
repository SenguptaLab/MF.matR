library(tidyverse)
library(ggiraph)
library(patchwork)
trackdata <- read_csv(file.choose()) %>%
  mutate(state_name = fct_relevel(state_name, c('Forward','Curve', 'Pause', 'Reverse','Omega-F','Omega-R')))

(histplot <- trackdata %>%
  filter(!is.na(state_name)) %>% #get rid of untracked rows - no y position or state ID
  ggplot(aes(x = y)) + geom_histogram() + facet_grid(.~state_name))

pointplot <- trackdata %>%
  filter(!is.na(state_name), state_name != "no_state_call") %>%
  ggplot(aes(x = -x, y = -y)) +
  geom_point_interactive(aes(data_id = state_name, colour = state_name), alpha = 0.2) +
  scale_colour_brewer(palette = "Set2") +
  guides(colour = guide_legend(override.aes = list(alpha = 1)))

girafe(ggobj = pointplot)

# get behavioral probability:
trackdata %>%
  filter(!is.na(state_name)) %>%
  group_by(state_name) %>% #use a column to group (can be any column)
  summarize(n = n()) %>% #can also use tally() which does the same thing
  mutate(prop = n / sum(n))

# get probability by y posittion:
# the key is to generate a new column in which to group_by
trackdata %>%
  filter(!is.na(state_name)) %>%
  select(worm, state_name, y) %>%
  mutate(ybin = ntile(y, 20)) %>% #use ntile to make 30 bins in the y position
  group_by(state_name, ybin) %>%
  tally() %>%
  group_by(ybin) %>% #explicitly group by ybin now to do the prop calculation
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = ybin, y = prop)) +
  geom_bar(stat = "identity", aes(fill = state_name)) +
  facet_grid(.~state_name)

# now et animals moving up vs. down:
behprob <- trackdata %>%
  filter(!is.na(state_name)) %>%
  select(worm, state_name, y, direction) %>%
  mutate(ybin = ntile(y, 20)) %>% #use ntile to make 30 bins in the y position
  group_by(state_name, ybin, direction) %>%
  tally() %>%
  group_by(ybin, direction) %>% #explicitly group by ybin now to do the prop calculation
  mutate(prop = n / sum(n),
         log_odds = boot::logit(prop)) %>%
  filter(direction %in% c("up", "down", "left", "right")) %>%
  ggplot(aes(x = ybin, y = prop, data_id = ybin)) +
  geom_bar_interactive(stat = "identity") +
  scale_fill_brewer_interactive(palette = "Set2") +
  facet_grid(direction~state_name) #+
  #coord_cartesian(ylim = c(-5, 2.5))
#x <- girafe(ggobj = behprob + pointplot, width_svg = 10, height_svg = 4) %>%
x <-girafe(ggobj = behprob) %>%
  girafe_options(opts_hover(css = "fill:cyan;"))
if( interactive() ) print(x)




