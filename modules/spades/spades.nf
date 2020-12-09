
params.resultsDir = 'results/spades'
params.saveMode = 'copy'

process SPADES {
    container 'quay.io/biocontainers/spades:3.14.0--h2d02072_0'
    publishDir params.resultsDir, mode: params.saveMode

    input:
    tuple val(genomeName), path(genomeReads)

    output:
    tuple val(genomeName), path("${genomeName}_scaffolds.fasta")


    script:

    """
    spades.py -k 21,33,55,77 --careful --only-assembler --pe1-1 ${genomeReads[0]} --pe1-2 ${genomeReads[1]} -o ${genomeName} -t 2
    cp ${genomeName}/scaffolds.fasta ${genomeName}_scaffolds.fasta 
    """
}


