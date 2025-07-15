# src/utils.R
# =========================
# Utility functions for configuration management, logging, and directory setup

# Ensure required packages are installed
if (!requireNamespace("yaml", quietly=TRUE)) install.packages("yaml")
if (!requireNamespace("logging", quietly=TRUE)) install.packages("logging")

library(yaml)
library(logging)

#' Read YAML configuration file
#'
#' @param config_file Path to YAML file (default: "config/default.yaml")
#' @return List of configuration parameters
readConfig <- function(config_file = "config/default.yaml") {
  cfg <- yaml::read_yaml(config_file)
  return(cfg)
}

#' Initialize logging to file and console
#'
#' @param logfile File path for log output (default: "results/logs/pipeline.log")
#' @param level Logging level as string (DEBUG, INFO, WARN, ERROR)
#' @return NULL
initLogging <- function(logfile = "results/logs/pipeline.log", level = "INFO") {
  basicConfig(level = getLevel(level))
  addHandler(writeToFile, file = logfile, level = getLevel(level))
  addHandler(writeToConsole, level = getLevel(level))
  loginfo("Logging initialized. File: %s", logfile)
}

#' Ensure directories exist (create if missing)
#'
#' @param dirs Character vector of directory paths
#' @return NULL
ensureDirs <- function(dirs) {
  for (d in dirs) {
    if (!dir.exists(d)) {
      dir.create(d, recursive = TRUE)
      loginfo("Created directory: %s", d)
    }
  }
}
