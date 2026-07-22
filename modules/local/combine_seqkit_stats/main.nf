process COMBINE_SEQKIT_STATS {
    tag "combine"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/52/52ccce28d2ab928ab862e25aae26314d69c8e38bd41ca9431c67ef05221348aa/data'
        : 'community.wave.seqera.io/library/coreutils_grep_gzip_lbzip2_pruned:838ba80435a629f8'}"

    input:
    path(stats_files)

    output:
    path("combined_seqkit_stats.tsv"), emit: combined_seqkit_stats

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    set -euo pipefail
    first_file=\$(ls ${stats_files} | head -n 1)

    {
        head -n 1 "\$first_file"
        awk 'FNR > 1' ${stats_files}
    } > combined_seqkit_stats.tsv

    """

    stub:
    """
    touch combined_seqkit_stats.tsv
    """
}