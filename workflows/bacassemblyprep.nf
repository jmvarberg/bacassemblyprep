/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { PARSE_SAMPLESHEET     } from '../subworkflows/local/parse_samplesheet'
include { STAGE_FASTQS          } from '../modules/local/stage_fastqs'
include { SEQKIT_STATS          } from '../modules/nf-core/seqkit/stats'
include { COMBINE_SEQKIT_STATS  } from '../modules/local/combine_seqkit_stats'
//include { CREATE_SHINY_INPUT_R  } from '../modules/local/create_shiny_input_r'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACASSEMBLYPREP {

    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:

    //Check input channel
    ch_samplesheet.view { "BACASSEMBLY INPUT: $it (${it.getClass()})" }

    //------------------
    // Step 1: Parse Input Samplesheet, stage files if needed, generate channel of fastq files ready for analysis
    //------------------

    //parse input sample sheet and generate channel for analysis. If skip_staging true, use files present in staged_dir directly, otherwise, stage them using STAGE_FASTQS
    if (!params.skip_staging) {
        ch_samples = PARSE_SAMPLESHEET(ch_samplesheet)
        STAGE_FASTQS(ch_samples)
        ch_fastqs = STAGE_FASTQS.out.processed_fastq
    }
    else {
        if (!params.staged_dir)
            error "skip_staging=true but --staged_dir was not provided."

        def staged = file(params.staged_dir, checkIfExists: true)

        ch_fastqs = channel.fromPath("${staged}/*.fastq.gz", checkIfExists: true)
            .ifEmpty { error "No .fastq.gz files in staged_dir: ${staged}" }
            .map { fastq ->
                tuple([id: fastq.simpleName], fastq )
            }
    }

    //View to check the fastq channel
    //ch_fastqs.view {"FASTQS CHANNEL: ${it}"}

    //-------------
    // Step 2: QC with Seqkit stats. Runs seqkit stats and combines into single output.
    //-------------
    SEQKIT_STATS(ch_fastqs)

    ch_stats = SEQKIT_STATS.out.stats
        .map { meta, tsv -> tsv }
        .collect()

    //ch_stats.view { "CHECK CH_STATS: ${it}"}

    COMBINE_SEQKIT_STATS(ch_stats)



}



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
