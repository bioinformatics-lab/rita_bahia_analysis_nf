
// NOTE: To properly setup the gatk inside the docker image
// - Download the gatk-3.8.0 tar file from here https://console.cloud.google.com/storage/browser/gatk-software/package-archive/gatk;tab=objects?prefix=&forceOnObjectsSortingFiltering=false
// - tar -xvf GATK_TAR_FILE
// - gatk-register gatk_folder/gatk_jar


params.resultsDir = 'results/mtbseq/mtbFull'
params.saveMode = 'copy'

Channel.fromFilePairs(params.readsFilePattern)
        .set { ch_in_mtbFull }

process MTBSEQ {
    publishDir params.resultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/mtbseq:1.0.3--pl526_1'

    cpus 4

    input:
    tuple val(genomeFileName), path("${genomeFileName}_somelib_R?.fastq.gz")
    path(gatk_jar)
    env USER 

    output:
    path("${genomeFileName}")

    script:

    """


    gatk-register ${gatk_jar}

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




workflow test {

include { TRIMMOMATIC } from "../trimmomatic/trimmomatic.nf"

input_ch = Channel.fromFilePairs("$launchDir/test_data/*_{1,2}.fastq.gz")

TRIMMOMATIC(input_ch)

gatk_jar_ch = Channel.fromPath("$launchDir/test_data/*bz2")
usr_env_ch = Channel.value("root")

MTBSEQ(TRIMMOMATIC.out,
	gatk_jar_ch,
	usr_env_ch)



}
