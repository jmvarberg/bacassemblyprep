process GENERATE_SAMPLESHEET {

	label "process_single"
	publishDir "${params.outdir}/shiny", mode: 'copy'

	conda "${moduleDir}/environment.yml"
	container "${workflow.containerEngine == 'singularity' && !(task.ext.singularity_pull_docker_container ?: false) 
			? 'oras://community.wave.seqera.io/library/r-base_r-data.table_r-dplyr_r-stringr:9418abefbed22a4d'
			: 'community.wave.seqera.io/library/r-base_r-data.table_r-dplyr_r-stringr:5897cbde71ea29a5'}"

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