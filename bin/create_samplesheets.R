#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
staged_fastq_dir <- args[1]
seqkit_stats <- args[2]
input_samplesheet <- args[3]
genome_size <- args[4]
min_coverage <- args[5]

suppressPackageStartupMessages({
		library(dplyr)
		library(data.table)
		library(stringr)
	}
	)

# Read data
stats <- data.table::fread(seqkit_stats)
input_log <- data.table::fread(input_samplesheet)
fastq_path <- staged_fastq_dir

#Add seqkit stats output to the input log file

#Step 1: prepare seqkit stats for merging
stats_mod <- stats |>
	dplyr::mutate(
		RunID = as.integer(stringr::str_match(file, "RunID_([0-9]+)")[,2]),
		path = file.path(fastq_path, file)
		)


write.csv(stats_mod, "modified_seqkit_stats.csv", row.names = F)

str(stats_mod)

str(input_log)

#merge seqkit stats with input log using RunID
input_with_stats <- input_log |>
	dplyr::left_join(stats_mod, by = "RunID") |>
	dplyr::mutate(
		genome_size   = as.integer(genome_size),
		predicted_cov = round(sum_len / genome_size, digits = 2))

str(input_with_stats)

write.csv(input_with_stats, "bacprep_log_shiny_input.csv", row.names = FALSE)

#Create bacass input sheet based on input params.
# Revisit in future - Need to handle if it is ONT or SR and generate the require columns for bacass: ID,R1,R2,LongFastQ,FAST5,GenomeSize
# bacass_ss <- input_with_stats |>
# 	dplyr::filter(predicted_cov >= as.integer(min_coverage)) |>
# 	dplyr::group_by(Isolate) |>
# 	dplyr::arrange(desc(predicted_cov)) |>
# 	dplyr::slice_head(n=1) |>
# 	dplyr::mutate(R1 = NA,)
# 	dplyr::select(Isolate)
# write.csv(bacass_ss, "bacass_samplesheet.csv", row.names = FALSE)

