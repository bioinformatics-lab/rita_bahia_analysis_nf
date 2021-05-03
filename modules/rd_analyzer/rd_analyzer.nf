
nextflow.enable.dsl= 2

params.saveMode = 'copy'
params.resultsDir = "${params.outdir}/rd_analyzer"
params.shouldPublish = true


process RD_ANALYZER {
    tag "${genomeFileName}"
    publishDir params.resultsDir, mode: params.saveMode, enabled: params.shouldPublish

    input:
    tuple val(genomeFileName), path(genomeReads)

    output:
    tuple path("*result"), path("*depth")


    script:
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    python  /RD-Analyzer/RD-Analyzer.py  -o ${genomeName} ${genomeReads[0]} ${genomeReads[1]}
    """

    stub: 
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    echo "python  /RD-Analyzer/RD-Analyzer.py  -o ${genomeName} ${genomeReads[0]} ${genomeReads[1]}"

    mkdir ${genomeName}_result
    mkdir ${genomeName}_depth

    """


}


workflow test {

include { TRIMMOMATIC } from "../trimmomatic/trimmomatic.nf"

input_ch = Channel.fromFilePairs("$launchDir/test_data/*_{1,2}.fastq.gz")

TRIMMOMATIC(input_ch)

RD_ANALYZER(TRIMMOMATIC.out)



}
