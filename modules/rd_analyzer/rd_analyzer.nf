
nextflow.enable.dsl= 2

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


workflow test {


// works
//input_ch = Channel.fromFilePairs("$launchDir/results/trimmomatic/*_{R1,R2}.p.fastq.gz")
//RD_ANALYZER(input_ch)


include { TRIMMOMATIC } from "../trimmomatic/trimmomatic.nf"

input_ch = Channel.fromFilePairs("$launchDir/test_data/*_{1,2}.fastq.gz")

TRIMMOMATIC(input_ch)

RD_ANALYZER(TRIMMOMATIC.out)




}
