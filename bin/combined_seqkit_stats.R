#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

suppressPackageStartupMessages({
		library(dplyr)
		library(data.table)
	}
	)

# Read data
stats <- lapply(args, data.table::fread)

print("Number of stats files: ")
print(length(args))

out <- stats |> dplyr::bind_rows() |> dplyr::arrange(file)

write.csv(out, "./combined_seqkit_stats.csv", row.names = F)