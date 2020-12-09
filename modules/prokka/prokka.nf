#!/usr/bin/env nextflow


/*
#==============================================
# params
#==============================================
*/

params.spadesResults = 'results/spades/*_scaffolds.fasta'
params.resultsDir = 'results/prokka'
params.saveMode = 'copy'


/*
#==============================================
# read genomes
#==============================================
*/

Channel.fromPath("""${params.spadesResults}""")
        .into { ch_in_prokka }


/*
#==============================================
# prokka
#==============================================
*/


process prokka {
    publishDir params.resultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/prokka:1.14.6--pl526_0'

    input:
    path bestContig from ch_in_prokka

    output:
    path("""${genomeName}""") into ch_out_prokka


    script:
    genomeName = bestContig.getName().split("\\_")[0]

    """
    prokka --outdir ./${genomeName} --prefix $genomeName ${bestContig}
    """

}



/*
#==============================================
# extra
#==============================================
*/
