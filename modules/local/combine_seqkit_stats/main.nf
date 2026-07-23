process COMBINE_SEQKIT_STATS {
    tag "combine"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !(task.ext.singularity_pull_docker_container ?: false) 
			? 'oras://community.wave.seqera.io/library/r-base_r-data.table_r-dplyr_r-stringr:9418abefbed22a4d'
			: 'community.wave.seqera.io/library/r-base_r-data.table_r-dplyr_r-stringr:5897cbde71ea29a5'}"

    input:
    path(stats_files)

    output:
    path("combined_seqkit_stats.csv"), emit: combined_seqkit_stats

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    combined_seqkit_stats.R ${stats_files.join(' ')}
    """

    stub:
    """
    touch combined_seqkit_stats.csv
    """
}