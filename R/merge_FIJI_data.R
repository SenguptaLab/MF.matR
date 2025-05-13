#' merge_FIJI_data
#'
#' This helper function takes a group of measurements output from registerquantGCaMP.ijm imageJ macro
#' and generates a merged .csv file with mean neuron pixel values, mean background pixel values, and the
#' background-subtracted pixel values - ie the 'signal'. No bleaching correction is applied. Files are written
#' in place to the enclosing folder.
#'
#' @param filename
#'
merge_FIJI_data <- function(neuronfile, backsub = TRUE,
                            show.plots = TRUE, frame.rate = 4) {
  neuron <- read.csv(neuronfile) %>% dplyr::select(animal = Label, MeanGCaMP = Mean, Slice)
  neuron_prefix <- strsplit(neuronfile,
                            split = "neuron_results.csv")
  background <- read.csv(paste0(neuron_prefix,
                                "background_results.csv")) %>%
    dplyr::select(animal = Label, MeanBackground = Mean, Slice)

  if(backsub == TRUE) {
    data <- dplyr::full_join(neuron, background) %>%
      separate(animal, c("animal", "section"), sep = ":") %>%
      dplyr::select(animal, Slice, MeanGCaMP, MeanBackground) %>%
      mutate(Fluor = MeanGCaMP - mean(MeanBackground[1:20], na.rm = TRUE),
             Fnaut = mean(Fluor[1:20]),
             signal = (Fluor - Fnaut) / Fnaut,
             time = Slice/frame.rate)
  } else {
    data <- dplyr::full_join(neuron, background) %>%
      separate(animal, c("animal", "section"), sep = ":") %>%
      dplyr::select(animal, Slice, MeanGCaMP, MeanBackground) %>%
      mutate(Fluor = MeanGCaMP,
             Fnaut = mean(Fluor[1:20]),
             signal = (Fluor - Fnaut) / Fnaut,
             time = Slice/frame.rate)
  }


  if(show.plots) {
    library(patchwork)
    library(ggrepel)
    p1 <- data %>% ggplot(aes(x = time, y = signal)) +
      geom_line() +
      labs(y = "deltaF/F") +
      labs(title = neuron_prefix)
    p2 <- ggplot(data, aes(x = time)) +
      geom_line(aes(y = MeanBackground), colour = "red") +
      # geom_text(data = subset(data, time == max(data$time)),
      #           aes(x = max(data$time), y = MeanBackground), hjust = -.1,
      #           label = "background", colour = "red") +
      geom_label_repel(data = subset(data, time == max(data$time)),
                       label = "background",
                       aes(x = max(data$time),
                           y = MeanBackground),
                       colour = "red",
                       nudge_y = 100,
                       na.rm = TRUE) +
      geom_line(aes(y = MeanGCaMP), colour = "green") +
      geom_label_repel(data = subset(data, time == max(data$time)),
                       label = "GCaMP",
                       aes(x = max(data$time),
                           y = MeanGCaMP),
                       colour = "green",
                       nudge_y = 100,
                       na.rm = TRUE) +
      labs(y = "mean pixel intensity")

    print(p1 + p2 + patchwork::plot_layout(nrow = 2))
  }

  readr::write_csv(data, path = paste0(neuron_prefix,"ImageJ_data.csv"))
}
