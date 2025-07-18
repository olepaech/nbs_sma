% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/group_bar_month.R
\name{group_bar_month}
\alias{group_bar_month}
\title{Grouped Bar Plot by Month with Summary Statistics}
\usage{
group_bar_month(data, category)
}
\arguments{
\item{data}{A data frame containing the survey data.}

\item{category}{A character string specifying the category to group by.
Must be one of \code{"Profession"}, \code{"Experience"}, or \code{"Nationality"}.}
}
\value{
A Plotly bar plot object.
}
\description{
This function takes NBS survey data and creates a grouped bar plot
showing Median, Mean and Mode of survey values by a month, colored by
a respondent category (profession, experience, or nationality).
}
\examples{
\dontrun{
  path <- load_participant_files()
  data <- readxl::read_excel(path)
  group_bar_month(data, category = "Profession")
}

}
\author{
Ole Paech
}
