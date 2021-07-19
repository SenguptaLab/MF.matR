#' plotResidency_stripes
#'
#' Plots residency data by inside, outside stripe. Generates a heatmap by experiment
#' @param FileFilter string to search/subset filenames
#'
#' @importFrom magrittr "%>%"
#' @importFrom magrittr "%<>%"
#' @importFrom magrittr "%$%"
#' @export
#' @examples data <- plotResidency_stripes(N2, genotype = N2, cue = octanol)
#'
plotResidency_stripes <- function(FileFilter,
                                  folderPath,
                                  arena_size = 16.1,
                            ...) {

  #### making an interactive option for the base folder:
   if(missing(folderPath)) {
    folderPath <- dirname(file.choose())
  }
  message(paste("using files at or below the folder:", basename(folderPath)))

#### select csv files that match the pattern, with an optional FileFilter
  files <- list.files(file.path(folderPath), pattern = "*.csv", recursive = TRUE)
  files <- files[stringr::str_detect(files, pattern = paste0(FileFilter))]
  filenames <- files
  files <- file.path(folderPath, files)
  files

#### correct and determine cue boundaries by luminance:
luminance <- files %>%
  stringr::str_subset(., pattern = "luminance.csv", negate = FALSE)  %>%
  # fix this later to read in only first and last column (much faster)
  read_csv(col_names = FALSE) %>% select(1,length(.))

luminance %<>%
  mutate(ypos = row_number()) %>%
  rename(frame1 = X1, frameLast = X2400) %>%
  pivot_longer(cols = starts_with("frame"),
               names_to = "frame",
               values_to = "luminance")

ybinwidth <- arena_size / max(luminance$ypos)

# linear regression should be a good way to compensate for luminace gradient across devices
luminance <- luminance %>%
  group_by(frame) %>%
  nest() %>%
  # map a linreg to each frame values, then get just the slope and intercept values
  mutate(lmobj = map(data, function(.x) {
    lm(luminance ~ ypos, data = .x) %>% broom::tidy()
  })) %>%
  unnest(lmobj) %>%
  select(-(5:7)) %>%
  pivot_wider(names_from = term, values_from = estimate) %>%
  rename(Intercept = `(Intercept)`, slope = ypos) %>%
  #now correct the slope and binarize:
  unnest(cols = c(data)) %>%
  mutate(norm_lum = luminance - (ypos*slope + Intercept)) %>%
  # the data are still wobbly, so I will use a Loess fit to smooth these
  # out and use these to binarize the luminance data
  nest() %>%
  mutate(smoothed = map(data, function(.x) {
    loess(norm_lum ~ ypos, data = .x, span = 0.1) %>% broom::augment()
  })) %>%
  unnest(smoothed) %>%
  mutate(lum_bin = case_when(
    .fitted >= 0 ~ "buffer",
    TRUE ~ "dye"
  ))

#check if boundaries are greater than one worm length:
first_bound <- luminance %>%
  filter(lum_bin == "dye") %>%
  slice(1) %$% (ypos[1] - ypos[2]) * ybinwidth > 0.5

try(if(first_bound) stop("boundaries unstable"))

second_bound <- luminance %>%
  filter(ypos > max(ypos)/2, lum_bin == "buffer") %>%
  slice(1) %$% (ypos[1] - ypos[2]) * ybinwidth > 0.5

try(if(second_bound) stop("boundaries unstable"))


#### use y position data to generate relative residence
ymat <- files %>%
  stringr::str_subset(., pattern = "ymat.csv", negate = FALSE)  %>%
  # fix this later to read in only first and last column (much faster)
  read_csv(col_names = FALSE) %>% mutate(worm = row_number())

ymat %>%
  pivot_longer(cols = -worm, names_to = "time", values_to = "y") %>%
  mutate(ybin=cut(y,breaks=seq(from = 0, to = 1000, by = 20))) %>%
  group_by(ybin, .drop = FALSE) %>%
  tally() %>%
  filter(!is.na(ybin)) %>%
  ggplot(aes(x = ybin)) +
  geom_tile(aes(y = factor(1), fill=n)) +
  theme(axis.text.x = element_blank())

return(ymat)

#return(select(luminance, ypos, lum_bin) %>% filter(frame == "frame1"))



### put a line to save the luminance plots
#
# luminance %<>% luminance %>%
#   select(ypos, lum_bin)
#
# files %>%
#   stringr::str_subset(., pattern = "ymat.csv", negate = FALSE)

  #need to read in with purr::map

# check that luminance looks same at start and finish:

}
