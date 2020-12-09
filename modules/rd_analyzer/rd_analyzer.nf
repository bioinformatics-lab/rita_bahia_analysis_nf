#!/usr/bin/env nextflow

/*
#==============================================
code documentation
#==============================================
*/


/*
#==============================================
params
#==============================================
*/

params.saveMode = 'copy'
params.resultsDir = 'results/rdAnalyzer'
params.filePattern = "./*_{R1,R2}.fastq.gz"

Channel.fromFilePairs(params.filePattern)
        .into { ch_in_rdanalyzer }



/*
#==============================================
RD-analyzer
#==============================================
*/

process rdAnalyzer {
    container 'abhi18av/rdanalyzer'
    publishDir params.resultsDir, mode: params.saveMode

    input:
    set genomeFileName, file(genomeReads) from ch_in_rdanalyzer

    output:
    tuple path("""${genomeName}.result"""), path("""${genomeName}.depth""") into ch_out_rdanalyzer


    script:
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    python  /RD-Analyzer/RD-Analyzer.py  -o ./${genomeName} ${genomeReads[0]} ${genomeReads[1]}
    """
}



/*
#==============================================
# extra
#==============================================
*/
