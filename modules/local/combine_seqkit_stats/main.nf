process COMBINE_SEQKIT_STATS {
    tag "combine"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !(task.ext.singularity_pull_docker_container ?: false) 
			? 'oras://community.wave.seqera.io/library/r-base_r-bit64_r-data.table_r-dplyr_r-scales:54d43f99629f6388'
			: 'community.wave.seqera.io/library/r-base_r-bit64_r-data.table_r-dplyr_r-scales:f2a2307db2a5e69f'}"
            
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