# jmvarberg/bacassemblyprep
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A525.04.0-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.5.1-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.5.1)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/jmvarberg/bacassemblyprep)

## Introduction

**jmvarberg/bacassemblyprep** is a bioinformatics pipeline that stages and prepares sequencing data for analysis using nf-core/bacass. The primary feature is to collect and concatenate data from ONT long-read sequencing projects that contain multiple input __fastq.gz__ files per isolate/sequencing run. Once combined, basic statistics are calculated using 'seqkit stats' to calculate a predicted coverage value. These are optionally used to filter the list of isolates for a minimum predicted coverage and to generate a sample sheet ready for submission using nf-core/bacass.

__IN DEVELOPMENT:__ This pipeline also generates an output CSV file that can be uploaded to a Shiny app (in development) that can serve as a dashboard to track large sequencing projects, generate basic plots to monitor number of samples sequenced, fraction passing quality thresholds, and interactively generate nf-core/bacass input sample sheets. 

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/guidelines/graphic_design/workflow_diagrams#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. 

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
RunID,Isolate,Type,Data
1,Ecoli_isolate_001,ONT,path_to_file_or_directory

```

Each row represents an individual sequencing run, and is referenced by a unique RunID integer value. The Isolate column should contain the unique identifier for the sample/isolate sequenced. Type column should contain values of either 'ONT' for long-read, or 'SR' for short-read/Illumina sequencing data. These values will only be used to properly format the samplesheet generated so that it is compatible with nf-core/bacass.

The Data column should contain a full file path specifying where to find the sequencing data for that run. These paths can resolve to individual fastq(.gz) files, or to a directory containing multiple fastq.gz files for that run (for example, the path to 'barcode01' from an ONT run). If Data is a directory and multiple fastq.gz files are found within, they will be concatenated into a single 'combined.fastq.gz' file.

The pipeline is built to handle multiple independent runs of the same Isolate. To disambiguate, the processed fastq.gz files are copied locally to the 'staged_fastqs' subdirectory (default location at "params.outdir/results/staged_fastqs"), and are re-named with unique names formatted as "[RunID]_[Isolate]_[TYPE]_[combined.fastq.gz|fastq.gz]", with 'combined' added to any samples that had multiple input files concatenated.

By default, the pipeline assumes that the fastq files require concatenation/staging. If this is not the case (i.e., all input files are single fastq.gz files), you can set the parameters 'skip_staging true' to tell the pipeline to skip the pre-processing/staging steps. You will also need to provide the path to the directry containing all of the fastq.gz files ready for processing to input 'staged_dir'.

-->

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run jmvarberg/bacassemblyprep \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR> \
   --min_coverage 50 \
   --genome_size 5100000
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

## Credits

jmvarberg/bacassemblyprep was originally written by Joe Varberg, PhD.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use jmvarberg/bacassemblyprep for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->



This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/main/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
