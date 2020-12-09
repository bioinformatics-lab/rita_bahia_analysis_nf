
nextflow.enable.dsl= 2

params.saveMode = 'copy'
params.resultsDir = 'results/rdAnalyzer'
params.shouldPublish = true


process RD_ANALYZER {
    tag "${genomeFileName}"
    container 'nextflowhubcontainers/rdanalyzer'
    publishDir params.resultsDir, mode: params.saveMode, enabled: params.shouldPublish

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


workflow test {

include { TRIMMOMATIC } from "../trimmomatic/trimmomatic.nf"

input_ch = Channel.fromFilePairs("$launchDir/test_data/*_{1,2}.fastq.gz")

TRIMMOMATIC(input_ch)

RD_ANALYZER(TRIMMOMATIC.out)



}
