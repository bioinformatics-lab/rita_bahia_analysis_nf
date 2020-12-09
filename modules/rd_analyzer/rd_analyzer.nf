
params.saveMode = 'copy'
params.resultsDir = 'results/rdAnalyzer'


process RD_ANALYZER {
    tag "${genomeFileName}"
    container 'nextflowhubcontainers/rdanalyzer'
    publishDir params.resultsDir, mode: params.saveMode

    cpus 2

    input:
    tuple val(genomeFileName), path(genomeReads)

    output:
    tuple path("*result"), path("*depth")


    script:
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    python  /RD-Analyzer/RD-Analyzer.py  -o ${genomeName} ${genomeReads[0]} ${genomeReads[1]}
    """
}


