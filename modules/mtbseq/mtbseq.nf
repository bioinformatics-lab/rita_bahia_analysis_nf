
// NOTE: To properly setup the gatk inside the docker image
// - Download the gatk-3.8.0 tar file from here https://console.cloud.google.com/storage/browser/gatk-software/package-archive/gatk;tab=objects?prefix=&forceOnObjectsSortingFiltering=false
// - tar -xvf GATK_TAR_FILE
// - gatk-register gatk_folder/gatk_jar


params.resultsDir = 'results/mtbseq/mtbFull'
params.readsFilePattern = "./*_{R1,R2}.fastq.gz"
params.saveMode = 'copy'

Channel.fromFilePairs(params.readsFilePattern)
        .set { ch_in_mtbFull }

process MTBSEQ {
    publishDir params.resultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/mtbseq:1.0.3--pl526_1'

    cpus 4

    input:
    tuple genomeFileName, file("${genomeFileName}_somelib_R?.fastq.gz") from ch_in_mtbFull
    env USER from Channel.value("root")

    output:
    path("""${genomeFileName}""") into ch_out_multiqc

    script:

    """


    mkdir ${genomeFileName}
   
    MTBseq --step TBfull --thread ${task.cpus}
    
    mv -a Amend ./${genomeFileName}/
    mv -a Bam ./${genomeFileName}/
    mv -a Called ./${genomeFileName}/
    mv -a Classification ./${genomeFileName}/
    mv -a GATK_Bam ./${genomeFileName}/
    mv -a Groups ./${genomeFileName}/
    mv -a Joint ./${genomeFileName}/
    mv -a Mpileup ./${genomeFileName}/
    mv -a Position_Tables ./${genomeFileName}/
    mv -a Statistics ./${genomeFileName}/
    """


}


