workflow PARSE_SAMPLESHEET {
    take:
    ch_samplesheet   // channel: path to the CSV file

    main:
    ch_samples = ch_samplesheet
        .splitCsv(header: true)
        .view { row -> "ROW KEYS: " + row.keySet() }
        .map { row ->
            def run_id  = row['RunID']
            def isolate = row['Isolate']
            def type    = row['Type']
            def data    = file(row['Data'], checkIfExists: true)

            // Resolve FASTQ files from a directory or a single file
            def fastq_files
            if (data.isDirectory()) {
                fastq_files = data.listFiles().findAll { f -> f.name.endsWith('.fastq.gz') }
                if (fastq_files.isEmpty()) {
                    error "No .fastq.gz files found in directory: ${data}"
                }
            }
            else if (data.name.endsWith('.fastq.gz')) {
                fastq_files = [data]
            }
            else {
                error "Data must be a .fastq.gz file or a directory containing them: ${data}"
            }

            def meta = [
                id:     isolate,
                run_id: run_id,
                type:   type
            ]

            tuple(meta, fastq_files)
        }

    emit:
    samples = ch_samples   // tuple(meta, [fastq_files])
}