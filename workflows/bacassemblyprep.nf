/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { PARSE_SAMPLESHEET     } from '../subworkflows/local/parse_samplesheet'
include { STAGE_FASTQS          } from '../modules/local/stage_fastqs'
include { SEQKIT_STATS          } from '../modules/nf-core/seqkit/stats'
include { COMBINE_SEQKIT_STATS  } from '../modules/local/combine_seqkit_stats'
include { GENERATE_SAMPLESHEET  } from '../modules/local/samplesheets'
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
    //ch_samplesheet.view { "BACASSEMBLY INPUT: $it (${it.getClass()})" }

    //Set channel for path to staged FASTQs - use provided if skipping staging, or set to default if not.
    def path_to_staged_dir 

    //------------------
    // Step 1: Parse Input Samplesheet, stage files if needed, generate channel of fastq files ready for analysis
    //------------------

    //parse input sample sheet and generate channel for analysis. 
    //If skip_staging true, use files present in staged_dir directly, otherwise, stage them using STAGE_FASTQS
    if (!params.skip_staging) {
        
        ch_samples = PARSE_SAMPLESHEET(ch_samplesheet)
        STAGE_FASTQS(ch_samples)
        ch_fastqs = STAGE_FASTQS.out.processed_fastq
        
        //If staging files, then use the default staging output directory 
        path_to_staged_dir = "${params.outdir}/staged_fastqs"

    }
    else {
        //if skip_staging = true, check for staged_dir. If not provided, error out.
        if (!params.staged_dir)
            error "skip_staging=true but --staged_dir was not provided."

        //if provided, confirm that the directory exists
        path_to_staged_dir = file(params.staged_dir, checkIfExists: true)

        //Once confirmed, create ch_fastqs from fastq files in staged_dir, error if none found
        ch_fastqs = Channel.fromPath("${path_to_staged_dir}/*.fastq.gz", checkIfExists: true)
            .ifEmpty { error "No .fastq.gz files in staged_dir: ${path_to_staged_dir}" }
            .map { fastq ->
                tuple([id: fastq.simpleName], fastq )
            }
    }

    //Create a single Channel for the staged directory for downstream process use
    Channel.fromPath(path_to_staged_dir.toString(), type: 'dir')
        .set { ch_staged_dir }

    //-------------
    // Step 2: QC with Seqkit stats. Runs seqkit stats and combines into single output.
    //-------------

    //Modify ch_fastqs output meta.id structure to avoid filename collisions downstream.
    ch_fastqs = ch_fastqs
        .map { meta, fastq ->
            def filename = fastq.simpleName
            tuple([id: filename], fastq)
        }

    SEQKIT_STATS(ch_fastqs)

    ch_stats = SEQKIT_STATS.out.stats
       .map { meta, tsv -> tsv}
       .collect()
    
    ch_stats.view {"DEBUG: CHECK GROUPTUPLE: ${it}"}

    COMBINE_SEQKIT_STATS(ch_stats)

    //-------------
    // Step 3: Automatically Generate Sample Sheet that is ready to use to submit/run nf-core/bacass
    //-------------

    GENERATE_SAMPLESHEET(
        ch_staged_dir,
        COMBINE_SEQKIT_STATS.out.combined_seqkit_stats,
        ch_samplesheet,
        params.genome_size.toInteger(),
        params.min_cov.toInteger()
    )

}



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
