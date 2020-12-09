
params.resultsDir = 'results/prokka'
params.saveMode = 'copy'

process PROKKA {
    tag "${genomeName}"
    publishDir params.resultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/prokka:1.14.6--pl526_0'
    cpus 8

    input:
    tuple val(genomeName),  path(bestContig)

    output:
    path("${genomeName}")

    script:

    """
    prokka --outdir ${genomeName} --prefix $genomeName ${bestContig} --cpus ${task.cpus}
    """

}


