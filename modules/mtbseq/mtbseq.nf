nextflow.enable.dsl = 2
// NOTE: To properly setup the gatk inside the docker image
// - Download the gatk-3.8.0 tar file from here https://console.cloud.google.com/storage/browser/gatk-software/package-archive/gatk;tab=objects?prefix=&forceOnObjectsSortingFiltering=false
// - tar -xvf GATK_TAR_FILE
// - gatk-register gatk_folder/gatk_jar


params.resultsDir = "${params.outdir}/mtbseq"
params.saveMode = 'copy'
params.shouldPublish = true

// TODO: Add the tbjoin workflow
process MTBSEQ {
    tag "${genomeFileName}"
    publishDir params.resultsDir, mode: params.saveMode, enabled: params.shouldPublish

    input:
    tuple val(genomeFileName), path("${genomeFileName}_somelib_R?.fastq.gz")
    path(gatk_jar)
    env USER

    output:
    path("${genomeFileName}")

    script:

    """
    #ignore the silly exit 1 status even after successful execution
    set +e

    gatk-register ${gatk_jar}

    mkdir ${genomeFileName}
   
    MTBseq --step TBfull --thread ${task.cpus}
    
    mv  Amend ./${genomeFileName}/
    mv  Bam ./${genomeFileName}/
    mv  Called ./${genomeFileName}/
    mv  Classification ./${genomeFileName}/
    mv  GATK_Bam ./${genomeFileName}/
    mv  Groups ./${genomeFileName}/
    mv  Joint ./${genomeFileName}/
    mv  Mpileup ./${genomeFileName}/
    mv  Position_Tables ./${genomeFileName}/
    mv  Statistics ./${genomeFileName}/
    """

    stub:

    """
    echo "gatk-register ${gatk_jar}"
    echo "MTBseq --step TBfull --thread ${task.cpus}"

    mkdir ${genomeFileName}

    """


}



params.resultsDir_mtbseq_cohort = "${params.outdir}/mtbseq_cohort"
params.saveMode_mtbseq_cohort = 'copy'
params.shouldPublish_mtbseq_cohort = true

process MTBSEQ_COHORT {
    publishDir params.resultsDir_mtbseq_cohort, mode: params.saveMode_mtbseq_cohort, enabled: params.shouldPublish_mtbseq_cohort

    input:
    path(samples_tsv_ch)
    path("Called/*")
    path("Position_Tables/*")
    path(gatk_jar)
    env USER

    output:
    tuple path("Joint"), path("Amend"), path("Groups")

    script:

    """
    set +e

    gatk-register ${gatk_jar}

    export USER=$USER

    mkdir Joint && MTBseq --step TBjoin --samples ${samples_tsv_ch} --project ${params.mtbseq_project_name}
    mkdir Amend && MTBseq --step TBamend --samples ${samples_tsv_ch} --project ${params.mtbseq_project_name}
    mkdir Groups && MTBseq --step TBgroups --samples ${samples_tsv_ch} --project ${params.mtbseq_project_name}
    """

    stub:

    """
    echo gatk-register ${gatk_jar}
    export USER=$USER

    mkdir Joint
    mkdir Amend 
    mkdir Groups
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
