
params.resultsDir = 'results/spades'
params.saveMode = 'copy'

process SPADES {
    tag "${genomeName}"
    publishDir params.resultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/spades:3.14.0--h2d02072_0'
    cpus 8

    input:
    tuple val(genomeName), path(genomeReads)

    output:
    tuple val(genomeName), path("${genomeName}_scaffolds.fasta")


    script:

    """
    spades.py -k 21,33,55,77 --careful --only-assembler --pe1-1 ${genomeReads[0]} --pe1-2 ${genomeReads[1]} -o ${genomeName} -t ${task.cpus}
    cp ${genomeName}/scaffolds.fasta ${genomeName}_scaffolds.fasta 
    """
}


