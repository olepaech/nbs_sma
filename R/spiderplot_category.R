#' Create a Radar Chart of Median Expectations by Category
#'
#' This function generates a spider (radar) plot of median expectations across months
#' for different groups based on a selected category (Profession, Experience, or Nationality).
#'
#' @param data A data frame with participant survey responses.
#' @param category A character string specifying the category to group by.
#'   Must be one of "Profession", "Experience", or "Nationality".
#' @param Min Numeric value for the minimum axis limit of the radar plot. Default is 1.
#' @param Max Numeric value for the maximum axis limit of the radar plot. Default is 4.
#'
#' @return A radar chart visualizing the median inflation expectations by group.
#'
#' @author Ole Paech
#'
#' @examples
#' \dontrun{
#' path <- load_participant_files()
#' data <- readxl::read_excel(path)
#' spiderplot_category(data, category = "Profession")
#' }
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr select mutate across all_of filter group_by summarise bind_rows
#' @importFrom stringr str_replace_all
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom stats median
#' @importFrom tibble column_to_rownames
#' @importFrom fmsb radarchart
#' @importFrom grDevices rainbow
#' @importFrom graphics legend
#'
#' @export
spiderplot_category <- function(data, category, Min = 1, Max = 4){
  suppressWarnings({
    category_map <- list(
      "Profession" = "What is your profession?",
      "Experience" = "How many years of expertise do you have?",
      "Nationality" = "What is your nationality?"
    )

    if (!(category %in% names(category_map))) {
      stop("Invalid Category. Please choose between 'Profession', 'Experience' or 'Nationality'.")
    }

    category_col <- category_map[[category]]

    relevant_cols <- names(data)[c(10,12,14,16)]

    data_clean <- data %>%
      dplyr::select(dplyr::all_of(category_col), dplyr::all_of(relevant_cols)) %>%
      dplyr::mutate(dplyr::across(
        dplyr::all_of(relevant_cols),
        ~ stringr::str_replace_all(., "%", "") %>%
          stringr::str_replace_all(",", ".") %>%
          as.numeric()
      ))

    data_long <- data_clean %>%
      tidyr::pivot_longer(cols = dplyr::all_of(relevant_cols), names_to = "Question", values_to = "Value") %>%
      dplyr::filter(!is.na(Value)) %>%
      dplyr::mutate(Month = extract_label(Question))

    month_levels <- unique(data_long$Month)[
      order(match(unique(data_long$Month), extract_label(relevant_cols)))
    ]

    data_long <- data_long %>%
      dplyr::mutate(Month = factor(Month, levels = month_levels)) %>%
      dplyr::group_by(.data[[category_col]], Month) %>%
      dplyr::summarise(
        Median_Expectation = stats::median(Value),
        .groups = "drop"
      )

    radar_df <- data_long %>%
      tidyr::pivot_wider(
        names_from = .data[[category_col]],
        values_from = Median_Expectation
      )

    radar_df <- radar_df %>%
      dplyr::mutate(dplyr::across(-Month, as.numeric))

    max_row <- radar_df[1, ] %>%
      dplyr::mutate(dplyr::across(-Month, ~ Max), Month = "MAX")
    min_row <- radar_df[1, ] %>%
      dplyr::mutate(dplyr::across(-Month, ~ Min), Month = "MIN")

    radar_df <- dplyr::bind_rows(max_row, min_row, radar_df)
    radar_df <- tibble::column_to_rownames(radar_df, "Month")

    fmsb::radarchart(
      radar_df,
      axistype = 1,
      pcol = grDevices::rainbow(nrow(radar_df) - 2),
      plwd = 2,
      plty = 1,
      cglcol = "grey",
      cglty = 1,
      axislabcol = "grey",
      caxislabels = seq(1, 4, 0.5),
      vlcex = 0.8
    )

    graphics::legend("topright", legend = rownames(radar_df)[-c(1, 2)],
                     col = grDevices::rainbow(nrow(radar_df) - 2), lty = 1, lwd = 2, bty = "n")
  })
}
