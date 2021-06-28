nextflow.enable.dsl= 2


params.save_mode = 'copy'
params.results_dir = "${params.outdir}/trimmomatic"
params.should_publish = true


process TRIMMOMATIC {
    tag "${genomeName}"
    publishDir params.results_dir, mode: params.save_mode, enabled: params.should_publish

    input:
    tuple val(genomeName), path(genomeReads)

    output:
    tuple val(genomeName), path("*_{R1,R2}.p.fastq.gz")

    script:

    fq_1_paired = genomeName + '_R1.p.fastq.gz'
    fq_1_unpaired = genomeName + '_R1.s.fastq.gz'
    fq_2_paired = genomeName + '_R2.p.fastq.gz'
    fq_2_unpaired = genomeName + '_R2.s.fastq.gz'

    """
    trimmomatic \
    PE \
    -threads ${task.cpus} \
    -phred33 \
    ${genomeReads[0]} \
    ${genomeReads[1]} \
    $fq_1_paired \
    $fq_1_unpaired \
    $fq_2_paired \
    $fq_2_unpaired \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36
    """

    stub:
    fq_1_paired = genomeName + '_R1.p.fastq.gz'
    fq_1_unpaired = genomeName + '_R1.s.fastq.gz'
    fq_2_paired = genomeName + '_R2.p.fastq.gz'
    fq_2_unpaired = genomeName + '_R2.s.fastq.gz'
    
    """
    echo "trimmomatic \
    PE \
    -threads ${task.cpus} \
    -phred33 \
    ${genomeReads[0]} \
    ${genomeReads[1]} \
    $fq_1_paired \
    $fq_1_unpaired \
    $fq_2_paired \
    $fq_2_unpaired \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36"
    
    touch ${genomeName}_R1.p.fastq.gz
    touch ${genomeName}_R2.p.fastq.gz
    """


}

workflow test {


input_ch = Channel.fromFilePairs("$launchDir/test_data/*_{1,2}.fastq.gz")


TRIMMOMATIC(input_ch)

}
