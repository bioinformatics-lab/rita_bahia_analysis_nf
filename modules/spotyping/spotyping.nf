
params.resultsDir = 'results/spotyping'
params.saveMode = 'copy'
params.R2 = false


process SPOTYPING {
    tag "${genomeFileName}"
    container 'nextflowhubcontainers/spotyping'
    publishDir params.resultsDir, mode: params.saveMode

    cpus 2

    input:
    tuple val(genomeFileName), path(genomeReads)

    output:
    tuple file('*.txt'), file('SITVIT*.xls')

    script:
    genomeName = genomeFileName.toString().split("\\_")[0]
    genomeReadToBeAnalyzed = params.R2 ? genomeReads[1] : genomeReads[0]

    """
    python /SpoTyping-v2.0/SpoTyping-v2.0-commandLine/SpoTyping.py ./${genomeReadToBeAnalyzed} -o ${genomeName}.txt
    """

}

