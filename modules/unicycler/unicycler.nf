nextflow.enable.dsl = 2

params.results_dir = "${params.outdir}/unicycler"
params.save_mode = 'copy'
params.should_publish = true

process UNICYCLER {
    tag "${genomeName}"
    publishDir params.results_dir, mode: params.save_mode, enabled: params.should_publish

    input:
    tuple val(genomeName),  path(genomeReads)

    output:
    path("${genomeName}")

    script:

    """
    unicycler  \
    -t ${task.cpus} \
    --keep 0 \
    --short1 ${genomeReads[0]} \
    --short2 ${genomeReads[1]} \
    --out ${genomeName} 
    """

    stub:

    """
    echo "unicycler  \
    -t ${task.cpus} \
    --keep 0 \
    --short1 ${genomeReads[0]} \
    --short2 ${genomeReads[1]} \
    --out ${genomeName}" 

    mkdir ${genomeName}
    """

}


workflow test {

    input_ch = Channel.fromFilePairs("$launchDir/test_data/*_{1,2}.fastq.gz")

    UNICYCLER(input_ch)

}
