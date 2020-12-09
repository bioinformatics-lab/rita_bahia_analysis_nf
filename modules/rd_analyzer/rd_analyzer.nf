
params.saveMode = 'copy'
params.resultsDir = 'results/rdAnalyzer'


process RD_ANALYZER {
    container 'nextflowhubcontainers/rdanalyzer'
    publishDir params.resultsDir, mode: params.saveMode

    cpus 2

    input:
    tuple val(genomeFileName), file(genomeReads)

    output:
    tuple path("""${genomeName}.result"""), path("""${genomeName}.depth""")


    script:
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    python  /RD-Analyzer/RD-Analyzer.py  -o ./${genomeName} ${genomeReads[0]} ${genomeReads[1]}
    """
}


