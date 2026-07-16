process STAGE_FASTQS {
    tag "${meta.id}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/52/52ccce28d2ab928ab862e25aae26314d69c8e38bd41ca9431c67ef05221348aa/data'
        : 'community.wave.seqera.io/library/coreutils_grep_gzip_lbzip2_pruned:838ba80435a629f8'}"

    input:
    tuple val(meta), path(fastq_files)

    output:
    tuple val(meta), path("${prefix}.fastq.gz"), emit: processed_fastq

    when:
    task.ext.when == null || task.ext.when

    script:
    def files = fastq_files.sort { f -> f.name }
    def stem  = files.size() == 1
        ? files[0].baseName.replaceFirst(/\.fastq$/, '')
        : 'combined'
    prefix = "RunID_${meta.run_id}_${meta.id}_${meta.type}_${stem}"

    """
    set -euo pipefail
    cat ${files.join(' ')} > "${prefix}.fastq.gz"
    """

    stub:
    prefix = "RunID_${meta.run_id}_${meta.id}_${meta.type}_combined"
    """
    touch "${prefix}.fastq.gz"
    """
}