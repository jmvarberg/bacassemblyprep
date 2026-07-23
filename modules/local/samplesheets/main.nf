process GENERATE_SAMPLESHEET {

	label "process_single"
	publishDir "${params.outdir}/shiny", mode: 'copy'

	conda "${moduleDir}/environment.yml"
	container "${workflow.containerEngine == 'singularity' && !(task.ext.singularity_pull_docker_container ?: false) 
			? 'oras://community.wave.seqera.io/library/r-base_r-bit64_r-data.table_r-dplyr_r-stringr:c0d029696a9beea8'
			: 'community.wave.seqera.io/library/r-base_r-bit64_r-data.table_r-dplyr_r-stringr:4c966b2cd1cec0b2'}"

	input:
	val(staged_dir)
	path(seqkit_stats_report)
	path(input_log)
	val(genome_size)
	val(min_coverage)

	output:
	path("modified_seqkit_stats.csv")
	path("bacprep_log_shiny_input.csv")
	//path("bacass_samplesheet.csv") - add back once finished being built

	script:
	"""
	create_samplesheets.R ${staged_dir} ${seqkit_stats_report} ${input_log} ${genome_size} ${min_coverage}
	"""
	}