nextflow.enable.dsl = 2
// NOTE: To properly setup the gatk inside the docker image
// - Download the gatk-3.8.0 tar file from here https://console.cloud.google.com/storage/browser/gatk-software/package-archive/gatk;tab=objects?prefix=&forceOnObjectsSortingFiltering=false
// - tar -xvf GATK_TAR_FILE
// - gatk-register gatk_folder/gatk_jar

params.results_dir = "${params.outdir}/mtbseq/cohort"
params.save_mode = 'copy'
params.should_publish = true

process MTBSEQ_COHORT {
    publishDir params.results_dir, mode: params.save_mode, enabled: params.should_publish
    // TODO port to errorStrategy and maxRetries
    // validExitStatus 0, 1, 2

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

    sleep 10

    mkdir Joint
    MTBseq --step TBjoin --samples ${samples_tsv_ch} --project ${params.mtbseq_project_name}

    mkdir Amend
    MTBseq --step TBamend --samples ${samples_tsv_ch} --project ${params.mtbseq_project_name}

    mkdir Groups
    MTBseq --step TBgroups --samples ${samples_tsv_ch} --project ${params.mtbseq_project_name}

    """



    stub:

    """
    mkdir Joint Amend Groups
    """

}
