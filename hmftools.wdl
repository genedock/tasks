version 1.0

# Copyright (c) 2020 Leiden University Medical Center
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

task Amber {
    input {
        String referenceName
        File referenceBam
        File referenceBamIndex
        String tumorName
        File tumorBam
        File tumorBamIndex
        String outputDir = "./amber"
        File loci
        File referenceFasta
        File referenceFastaFai
        File referenceFastaDict

        Int threads = 2
        String memory = "70G"
        String javaXmx = "64G"
        Int timeMinutes = 240
        String dockerImage = "quay.io/biocontainers/hmftools-amber:3.5--0"
    }

    command {
        AMBER -Xmx~{javaXmx} \
        -reference ~{referenceName} \
        -reference_bam ~{referenceBam} \
        -tumor ~{tumorName} \
        -tumor_bam ~{tumorBam} \
        -output_dir ~{outputDir} \
        -threads ~{threads} \
        -ref_genome ~{referenceFasta} \
        -loci ~{loci}
    }

    output {
        File version = "~{outputDir}/amber.version"
        File tumorBafPcf = "~{outputDir}/~{tumorName}.amber.baf.pcf"
        File tumorBafTsv = "~{outputDir}/~{tumorName}.amber.baf.tsv"
        File tumorBafVcf = "~{outputDir}/~{tumorName}.amber.baf.vcf.gz"
        File tumorBafVcfIndex = "~{outputDir}/~{tumorName}.amber.baf.vcf.gz.tbi"
        File tumorContaminationVcf = "~{outputDir}/~{tumorName}.amber.contamination.vcf.gz"
        File tumorContaminationVcfIndex = "~{outputDir}/~{tumorName}.amber.contamination.vcf.gz.tbi"
        File tumorContaminationTsv = "~{outputDir}/~{tumorName}.amber.contamination.tsv"
        File tumorQc = "~{outputDir}/~{tumorName}.amber.qc"
        File normalSnpVcf = "~{outputDir}/~{referenceName}.amber.snp.vcf.gz"
        File normalSnpVcfIndex = "~{outputDir}/~{referenceName}.amber.snp.vcf.gz.tbi"
        Array[File] outputs = [version, tumorBafPcf, tumorBafTsv, tumorBafVcf, tumorBafVcfIndex, 
            tumorContaminationVcf, tumorContaminationVcfIndex, tumorContaminationTsv, tumorQc, 
            normalSnpVcf, normalSnpVcfIndex]
    }

    runtime {
        memory: memory
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
        cpu: threads
    }

    parameter_meta {
        referenceName: {description: "the name of the normal sample.", category: "required"}
        referenceBam: {description: "The normal BAM file.", category: "required"}
        referenceBamIndex: {description: "The index for the normal BAM file.", category: "required"}
        tumorName: {description: "The name of the tumor sample.", category: "required"}
        tumorBam: {description: "The tumor BAM file.", category: "required"}
        tumorBamIndex: {description: "The index for the tumor BAM file.", category: "required"}
        outputDir: {description: "The path to the output directory.", category: "common"}
        loci: {description: "A VCF file containing likely heterozygous sites.", category: "required"}
        referenceFasta: {description: "The reference fasta file.", category: "required"}
        referenceFastaDict: {description: "The sequence dictionary associated with the reference fasta file.",
                             category: "required"}
        referenceFastaFai: {description: "The index for the reference fasta file.", category: "required"}
        threads: {description: "The number of threads the program will use.", category: "advanced"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task Cobalt {
    input {
        String referenceName
        File referenceBam
        File referenceBamIndex
        String tumorName
        File tumorBam
        File tumorBamIndex
        String outputDir = "./cobalt"
        File gcProfile
        
        Int threads = 1
        String memory = "5G"
        String javaXmx = "4G"
        Int timeMinutes = 240
        String dockerImage = "quay.io/biocontainers/hmftools-cobalt:1.11--0"
    }

    command {
        COBALT -Xmx~{javaXmx} \
        -reference ~{referenceName} \
        -reference_bam ~{referenceBam} \
        -tumor ~{tumorName} \
        -tumor_bam ~{tumorBam} \
        -output_dir ~{outputDir} \
        -threads ~{threads} \
        -gc_profile ~{gcProfile}
    }

    output {
        File version = "~{outputDir}/cobalt.version"
        File normalGcMedianTsv = "~{outputDir}/~{referenceName}.cobalt.gc.median.tsv"
        File normalRationMedianTsv = "~{outputDir}/~{referenceName}.cobalt.ratio.median.tsv"
        File normalRationPcf = "~{outputDir}/~{referenceName}.cobalt.ratio.pcf"
        File tumorGcMedianTsv = "~{outputDir}/~{tumorName}.cobalt.gc.median.tsv"
        File tumorRatioPcf = "~{outputDir}/~{tumorName}.cobalt.ratio.pcf"
        File tumorRatioTsv = "~{outputDir}/~{tumorName}.cobalt.ratio.tsv"
        File tumorChrLen = "~{outputDir}/~{tumorName}.chr.len"
        Array[File] outputs = [version, normalGcMedianTsv, normalRationMedianTsv,
            normalRationPcf, tumorGcMedianTsv, tumorRatioPcf, tumorRatioTsv, tumorChrLen]
    }

    runtime {
        memory: memory
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
        cpu: threads
    }

    parameter_meta {
        referenceName: {description: "the name of the normal sample.", category: "required"}
        referenceBam: {description: "The normal BAM file.", category: "required"}
        referenceBamIndex: {description: "The index for the normal BAM file.", category: "required"}
        tumorName: {description: "The name of the tumor sample.", category: "required"}
        tumorBam: {description: "The tumor BAM file.", category: "required"}
        tumorBamIndex: {description: "The index for the tumor BAM file.", category: "required"}
        outputDir: {description: "The path to the output directory.", category: "common"}
        gcProfile: {description: "A file describing the GC profile of the reference genome.", category: "required"}
        threads: {description: "The number of threads the program will use.", category: "advanced"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task Cuppa {
    input {
        Array[File]+ linxOutput
        Array[File]+ purpleOutput
        String sampleName
        Array[String]+ categories = ["DNA"]
        Array[File]+ referenceData 
        File purpleSvVcf
        File purpleSvVcfIndex
        File purpleSomaticVcf
        File purpleSomaticVcfIndex
        String outputDir = "./cuppa"

        String javaXmx = "4G"
        String memory = "5G"
        Int timeMinutes = 10
        String dockerImage = "quay.io/biowdl/cuppa:1.4"
    }

    command {
        set -e
        mkdir -p sampleData ~{outputDir}
        ln -s -t sampleData ~{sep=" " linxOutput} ~{sep=" " purpleOutput}
        cuppa -Xmx~{javaXmx} \
        -output_dir ~{outputDir} \
        -output_id ~{sampleName} \
        -categories '~{sep="," categories}' \
        -ref_data_dir ~{sub(referenceData[0], basename(referenceData[0]), "")} \
        -sample_data_dir sampleData \
        -sample_data ~{sampleName} \
        -sample_sv_file ~{purpleSvVcf} \
        -sample_somatic_vcf ~{purpleSomaticVcf}
    }

    output {
        File cupData = "~{outputDir}/~{sampleName}.cup.data.csv"
    }

    runtime {
        memory: memory
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
    }

    parameter_meta {
        linxOutput: {description: "The files produced by linx.", category: "required"}
        purpleOutput: {description: "The files produced by purple.", category: "required"}
        sampleName: {description: "The name of the sample.", category: "required"}
        categories: {description: "The classifiers to use.", category: "advanced"}
        referenceData : {description: "The reference data.", category: "required"}
        purpleSvVcf: {description: "The VCF file produced by purple which contains structural variants.", category: "required"}
        purpleSvVcfIndex: {description: "The index of the structural variants VCF file produced by purple.", category: "required"}
        purpleSomaticVcf: {description: "The VCF file produced by purple which contains somatic variants.", category: "required"}
        purpleSomaticVcfIndex: {description: "The index of the somatic VCF file produced by purple.", category: "required"}
        outputDir: {description: "The directory the ouput will be placed in.", category: "common"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task CuppaChart {
    input {
        String sampleName
        File cupData
        String outputDir = "./cuppa"

        String memory = "4G"
        Int timeMinutes = 5
        String dockerImage = "quay.io/biowdl/cuppa:1.4"
    }

    command {
        set -e 
        mkdir -p ~{outputDir}
        cuppa-chart \
        -sample ~{sampleName} \
        -sample_data ~{cupData} \
        -output_dir ~{outputDir}
    }

    output {
        File cuppaChart = "~{outputDir}/~{sampleName}.cuppa.chart.png"
        File cuppaConclusion = "~{outputDir}/~{sampleName}.cuppa.conclusion.txt"
    }

    runtime {
        memory: memory
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
    }

    parameter_meta {
        sampleName: {description: "The name of the sample.", category:"common"}
        cupData: {description: "The cuppa output.", category: "required"}
        outputDir: {description: "The directory the output will be written to.", category:"common"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task GripssApplicationKt {
    input {
        File inputVcf
        String outputPath = "gripss.vcf.gz"
        String tumorName
        String referenceName
        File referenceFasta
        File referenceFastaFai
        File referenceFastaDict
        File breakpointHotspot
        File breakendPon
        File breakpointPon

        String memory = "32G"
        String javaXmx = "31G"
        Int timeMinutes = 45
        String dockerImage = "quay.io/biocontainers/hmftools-gripss:1.11--hdfd78af_0"
    }

    command {
        java -Xmx~{javaXmx} -XX:ParallelGCThreads=1 \
        -cp /usr/local/share/hmftools-gripss-1.11-0/gripss.jar \
        com.hartwig.hmftools.gripss.GripssApplicationKt \
        -tumor ~{tumorName} \
        -reference ~{referenceName} \
        -ref_genome ~{referenceFasta} \
        -breakpoint_hotspot ~{breakpointHotspot} \
        -breakend_pon ~{breakendPon} \
        -breakpoint_pon ~{breakpointPon} \
        -input_vcf ~{inputVcf} \
        -output_vcf ~{outputPath} \
        -paired_normal_tumor_ordinals
    }

    output {
        File outputVcf = outputPath
        File outputVcfIndex = outputPath + ".tbi"
    }

    runtime {
        memory: memory
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
    }

    parameter_meta {
        inputVcf: {description: "The input VCF.", category: "required"}
        outputPath: {description: "The path where th eoutput VCF will be written.", category: "common"}
        referenceFasta: {description: "The reference fasta file.", category: "required"}
        referenceFastaDict: {description: "The sequence dictionary associated with the reference fasta file.",
                             category: "required"}
        referenceFastaFai: {description: "The index for the reference fasta file.", category: "required"}
        breakpointHotspot: {description: "Equivalent to the `-breakpoint_hotspot` option.", category: "required"}
        breakendPon: {description: "Equivalent to the `-breakend_pon` option.", category: "required"}
        breakpointPon: {description: "Equivalent to the `breakpoint_pon` option.", category: "required"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task GripssHardFilterApplicationKt {
    input {
        File inputVcf
        String outputPath = "gripss_hard_filter.vcf.gz"

        String memory = "3G"
        String javaXmx = "2G"
        Int timeMinutes = 15
        String dockerImage = "quay.io/biocontainers/hmftools-gripss:1.11--hdfd78af_0"
    }

    command {
        java -Xmx~{javaXmx} -XX:ParallelGCThreads=1 \
        -cp /usr/local/share/hmftools-gripss-1.11-0/gripss.jar \
        com.hartwig.hmftools.gripss.GripssHardFilterApplicationKt \
        -input_vcf ~{inputVcf} \
        -output_vcf ~{outputPath} 
    }

    output {
        File outputVcf = outputPath
        File outputVcfIndex = outputPath + ".tbi"
    }

    runtime {
        memory: memory
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
    }

    parameter_meta {
        inputVcf: {description: "The input VCF.", category: "required"}
        outputPath: {description: "The path where th eoutput VCF will be written.", category: "common"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task HealthChecker {
    input {
        String outputDir = "."
        String referenceName
        File referenceFlagstats
        File referenceMetrics
        String tumorName
        File tumorFlagstats
        File tumorMetrics
        Array[File]+ purpleOutput

        String javaXmx = "2G"
        String memory = "1G"
        Int timeMinutes = 1
        String dockerImage = "quay.io/biowdl/health-checker:3.2"
    }

    command {
        set -e
        mkdir -p ~{outputDir}
        health-checker -Xmx~{javaXmx} -XX:ParallelGCThreads=1 \
        -reference ~{referenceName} \
        -ref_flagstat_file ~{referenceFlagstats} \
        -ref_wgs_metrics_file ~{referenceMetrics} \
        -tumor ~{tumorName} \
        -tum_flagstat_file ~{tumorFlagstats} \
        -tum_wgs_metrics_file ~{tumorMetrics} \
        -purple_dir ~{sub(purpleOutput[0], basename(purpleOutput[0]), "")} \
        -output_dir ~{outputDir}
        test -e '~{outputDir}/~{tumorName}.HealthCheckSucceeded' && echo 'true' > '~{outputDir}/succeeded'
        test -e '~{outputDir}/~{tumorName}.HealthCheckFailed' && echo 'false' > '~{outputDir}/succeeded'
    }

    output {
        Boolean succeeded = read_boolean("result")
        File outputFile = if succeeded 
                          then "~{outputDir}/~{tumorName}.HealthCheckSucceeded"
                          else "~{outputDir}/~{tumorName}.HealthCheckFailed"
    }

    runtime {
        memory: memory
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
    }

    parameter_meta {
        outputDir: {description: "The path the output will be written to.", category:"required"}
        referenceName: {description: "The name of the normal sample.", category: "required"}
        referenceFlagstats: {description: "The flagstats for the normal sample.", category: "required"}
        referenceMetrics: {description: "The picard WGS metrics for the normal sample.", category: "required"}
        tumorName: {description: "The name of the tumor sample.", category: "required"}
        tumorFlagstats: {description: "The flagstats for the tumor sample.", category: "required"}
        tumorMetrics: {description: "The picard WGS metrics for the tumor sample.", category: "required"}
        purpleOutput: {description: "The files from purple's output directory.", category: "required"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task Linx {
    input {
        String sampleName
        File svVcf
        File svVcfIndex
        Array[File]+ purpleOutput
        String refGenomeVersion
        String outputDir = "./linx"
        File fragileSiteCsv
        File lineElementCsv
        File replicationOriginsBed
        File viralHostsCsv
        File knownFusionCsv
        File driverGenePanel
        #The following should be in the same directory.
        File geneDataCsv
        File proteinFeaturesCsv
        File transExonDataCsv
        File transSpliceDataCsv

        String memory = "5G"
        String javaXmx = "4G"
        Int timeMinutes = 10
        String dockerImage = "quay.io/biocontainers/hmftools-linx:1.16--hdfd78af_0"
    }

    command {
        linx -Xmx~{javaXmx} -XX:ParallelGCThreads=1 \
        -sample ~{sampleName} \
        -sv_vcf ~{svVcf} \
        -purple_dir ~{sub(purpleOutput[0], basename(purpleOutput[0]), "")} \
        -ref_genome_version ~{refGenomeVersion} \
        -output_dir ~{outputDir} \
        -fragile_site_file ~{fragileSiteCsv} \
        -line_element_file ~{lineElementCsv} \
        -replication_origins_file ~{replicationOriginsBed} \
        -viral_hosts_file ~{viralHostsCsv} \
        -gene_transcripts_dir ~{sub(geneDataCsv, basename(geneDataCsv), "")} \
        -check_fusions \
        -known_fusion_file ~{knownFusionCsv} \
        -check_drivers \
        -driver_gene_panel ~{driverGenePanel} \
        -chaining_sv_limit 0 \
        -write_vis_data
    }

    output {
        File driverCatalog = "~{outputDir}/~{sampleName}.linx.driver.catalog.tsv"
        File linxBreakend = "~{outputDir}/~{sampleName}.linx.breakend.tsv"
        File linxClusters = "~{outputDir}/~{sampleName}.linx.clusters.tsv"
        File linxDrivers = "~{outputDir}/~{sampleName}.linx.drivers.tsv"
        File linxFusion = "~{outputDir}/~{sampleName}.linx.fusion.tsv"
        File linxLinks = "~{outputDir}/~{sampleName}.linx.links.tsv"
        File linxSvs = "~{outputDir}/~{sampleName}.linx.svs.tsv"
        File linxViralInserts = "~{outputDir}/~{sampleName}.linx.viral_inserts.tsv"
        File linxVisCopyNumber = "~{outputDir}/~{sampleName}.linx.vis_copy_number.tsv"
        File linxVisFusion = "~{outputDir}/~{sampleName}.linx.vis_fusion.tsv"
        File linxVisGeneExon = "~{outputDir}/~{sampleName}.linx.vis_gene_exon.tsv"
        File linxVisProteinDomain = "~{outputDir}/~{sampleName}.linx.vis_protein_domain.tsv"
        File linxVisSegments = "~{outputDir}/~{sampleName}.linx.vis_segments.tsv"
        File linxVisSvData = "~{outputDir}/~{sampleName}.linx.vis_sv_data.tsv"
        File linxVersion = "~{outputDir}/linx.version"
        Array[File] outputs = [driverCatalog, linxBreakend, linxClusters, linxDrivers, linxFusion,
                               linxLinks, linxSvs, linxViralInserts, linxVisCopyNumber,
                               linxVisFusion, linxVisGeneExon, linxVisProteinDomain,
                               linxVisSegments, linxVisSvData, linxVersion]
    }

    runtime {
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
        memory: memory
    }

    parameter_meta {
        sampleName: {description: "The name of the sample.", category: "required"}
        svVcf: {description: "A VCF file containing structural variants, produced using GRIDSS, annotated for viral insertions and postprocessed with GRIPSS.", category: "required"}
        svVcfIndex: {description: "Index for the structural variants VCf file.", category: "required"}
        purpleOutput: {description: "The files produced by PURPLE.", category: "required"}
        refGenomeVersion: {description: "The version of the genome assembly used for alignment. Either \"HG19\" or \"HG38\".", category: "required"}
        outputDir: {description: "The directory the outputs will be written to.", category: "required"}
        fragileSiteCsv: {description: "A list of known fragile sites.", category: "required"}
        lineElementCsv: {description: "A list of known LINE source regions.", category: "required"}
        replicationOriginsBed: {description: "Replication timing input in BED format with replication timing as the 4th column.", category: "required"}
        viralHostsCsv: {description: "A list of the viruses which were used for annotation of the GRIDSS results.", category: "required"}
        knownFusionCsv: {description: "A CSV file describing known fusions.", category: "required"}
        driverGenePanel: {description: "A TSV file describing the driver gene panel.", category: "required"}
        geneDataCsv: {description: "A  CSV file containing gene information, must be in the same directory as `proteinFeaturesCsv`, `transExonDataCsv` and `transSpliceDataCsv`.", category: "required"}
        proteinFeaturesCsv: {description: "A  CSV file containing protein feature information, must be in the same directory as `geneDataCsv`, `transExonDataCsv` and `transSpliceDataCsv`.", category: "required"}
        transExonDataCsv: {description: "A  CSV file containing transcript exon information, must be in the same directory as `geneDataCsv`, `proteinFeaturesCsv` and `transSpliceDataCsv`.", category: "required"}
        transSpliceDataCsv: {description: "A  CSV file containing transcript splicing information, must be in the same directory as `geneDataCsv`, `proteinFeaturesCsv` and `transExonDataCsv`.", category: "required"}

        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task Protect {
    input {
        String refGenomeVersion
        String tumorName
        String referenceName
        Array[String]+ sampleDoids
        String outputDir = "."
        Array[File]+ serveActionability
        File doidJson
        File purplePurity
        File purpleQc
        File purpleDriverCatalogSomatic
        File purpleDriverCatalogGermline
        File purpleSomaticVariants
        File purpleSomaticVariantsIndex
        File purpleGermlineVariants
        File purpleGermlineVariantsIndex
        File purpleGeneCopyNumber
        File linxFusion
        File linxBreakend
        File linxDriversCatalog
        File chordPrediction
        File annotatedVirus

        String memory = "9G"
        String javaXmx = "8G"
        Int timeMinutes = 60
        String dockerImage = "quay.io/biowdl/protect:v1.4"
    }

    command {
        protect -Xmx~{javaXmx} \
        -ref_genome_version ~{refGenomeVersion} \
        -tumor_sample_id ~{tumorName} \
        -reference_sample_id ~{referenceName} \
        -primary_tumor_doids '~{sep=";" sampleDoids}' \
        -output_dir ~{outputDir} \
        -serve_actionability_dir ~{sub(serveActionability[0], basename(serveActionability[0]), "")} \
        -doid_json ~{doidJson} \
        -purple_purity_tsv ~{purplePurity} \
        -purple_qc_file ~{purpleQc} \
        -purple_somatic_driver_catalog_tsv ~{purpleDriverCatalogSomatic} \
        -purple_germline_driver_catalog_tsv ~{purpleDriverCatalogGermline} \
        -purple_somatic_variant_vcf ~{purpleSomaticVariants} \
        -purple_germline_variant_vcf ~{purpleGermlineVariants} \
        -purple_gene_copy_number_tsv ~{purpleGeneCopyNumber} \
        -linx_fusion_tsv ~{linxFusion} \
        -linx_breakend_tsv ~{linxBreakend} \
        -linx_driver_catalog_tsv ~{linxDriversCatalog} \
        -chord_prediction_txt ~{chordPrediction} \
        -annotated_virus_tsv ~{annotatedVirus}
    }

    output {
        File protectTsv = "~{outputDir}/~{tumorName}.protect.tsv"
    }

    runtime {
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
        memory: memory
    }

    parameter_meta {
        refGenomeVersion: {description: "The version of the genome assembly used for alignment. Either \"37\" or \"38\".", category: "required"} 
        tumorName: {description: "The name of the tumor sample.", category: "required"}
        referenceName: {description: "The name of the normal sample.", category: "required"}
        sampleDoids: {description: "The DOIDs (Human Disease Ontology) for the primary tumor.", category: "required"}
        outputDir: {description: "The directory the outputs will be written to.", category: "required"}
        serveActionability: {description: "The actionability files generated by hmftools' serve.", category: "required"}
        doidJson: {description: "A json with the DOID (Human Disease Ontology) tree.", category: "required"}
        purplePurity: {description: "The purity file generated by purple.", category: "required"}
        purpleQc: {description: "The QC file generated by purple.", category: "required"}
        purpleDriverCatalogSomatic: {description: "The somatic driver catalog generated by purple.", category: "required"}
        purpleDriverCatalogGermline: {description: "The germline driver catalog generated by purple.", category: "required"}
        purpleSomaticVariants: {description: "The somatic VCF generated by purple.", category: "required"}
        purpleSomaticVariantsIndex: {description: "The index for the somatic VCF generated by purple.", category: "required"}
        purpleGermlineVariants: {description: "The germline VCF generated by purple.", category: "required"}
        purpleGermlineVariantsIndex: {description: "The index of the germline VCF generated by purple.", category: "required"}
        purpleGeneCopyNumber: {description: "The gene copy number file generated by purple.", category: "required"}
        linxFusion: {description: "The fusion file generated by linx.", category: "required"}
        linxBreakend: {description: "The breakend file generated by linx.", category: "required"}
        linxDriversCatalog: {description: "The driver catalog generated generated by linx.", category: "required"}
        chordPrediction: {description: "The chord prediction file.", category: "required"}
        annotatedVirus: {description: "The virus-interpreter output.", category: "required"}

        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task Purple {
    input {
        String referenceName
        String tumorName
        String outputDir = "./purple"
        Array[File]+ amberOutput
        Array[File]+ cobaltOutput
        File gcProfile
        File somaticVcf
        File germlineVcf
        File filteredSvVcf
        File? fullSvVcf
        File? fullSvVcfIndex
        File referenceFasta
        File referenceFastaFai
        File referenceFastaDict
        File driverGenePanel
        File somaticHotspots
        File germlineHotspots
        
        Int threads = 1
        Int timeMinutes = 30
        String memory = "9G"
        String javaXmx = "8G"
        # clone of quay.io/biocontainers/hmftools-purple:3.1--hdfd78af_0 with 'ln -s /usr/local/lib/libwebp.so.7 /usr/local/lib/libwebp.so.6'
        String dockerImage = "quay.io/biowdl/hmftools-purple:3.1" 
    }

    command {
        PURPLE -Xmx~{javaXmx} \
        -reference ~{referenceName} \
        -tumor ~{tumorName} \
        -output_dir ~{outputDir} \
        -amber ~{sub(amberOutput[0], basename(amberOutput[0]), "")} \
        -cobalt ~{sub(cobaltOutput[0], basename(cobaltOutput[0]), "")} \
        -gc_profile ~{gcProfile} \
        -somatic_vcf ~{somaticVcf} \
        -germline_vcf ~{germlineVcf} \
        -structural_vcf ~{filteredSvVcf} \
        ~{"-sv_recovery_vcf " + fullSvVcf} \
        -circos /usr/local/bin/circos \
        -ref_genome ~{referenceFasta} \
        -driver_catalog \
        -driver_gene_panel ~{driverGenePanel} \
        -somatic_hotspots ~{somaticHotspots} \
        -germline_hotspots ~{germlineHotspots} \
        -threads ~{threads}
    }

    output {
        File driverCatalogSomaticTsv = "~{outputDir}/~{tumorName}.driver.catalog.somatic.tsv"
        File driverCatalogGermlineTsv = "~{outputDir}/~{tumorName}.driver.catalog.germline.tsv"
        File purpleCnvGeneTsv = "~{outputDir}/~{tumorName}.purple.cnv.gene.tsv"
        File purpleCnvGermlineTsv = "~{outputDir}/~{tumorName}.purple.cnv.germline.tsv"
        File purpleCnvSomaticTsv = "~{outputDir}/~{tumorName}.purple.cnv.somatic.tsv"
        File purplePurityRangeTsv = "~{outputDir}/~{tumorName}.purple.purity.range.tsv"
        File purplePurityTsv = "~{outputDir}/~{tumorName}.purple.purity.tsv"
        File purpleQc = "~{outputDir}/~{tumorName}.purple.qc"
        File purpleSegmentTsv = "~{outputDir}/~{tumorName}.purple.segment.tsv"
        File purpleSomaticClonalityTsv = "~{outputDir}/~{tumorName}.purple.somatic.clonality.tsv"
        File purpleSomaticHistTsv = "~{outputDir}/~{tumorName}.purple.somatic.hist.tsv"
        File purpleSomaticVcf = "~{outputDir}/~{tumorName}.purple.somatic.vcf.gz"
        File purpleSomaticVcfIndex = "~{outputDir}/~{tumorName}.purple.somatic.vcf.gz.tbi"
        File purpleGermlineVcf = "~{outputDir}/~{tumorName}.purple.germline.vcf.gz"
        File purpleGermlineVcfIndex = "~{outputDir}/~{tumorName}.purple.germline.vcf.gz.tbi"
        File purpleSvVcf = "~{outputDir}/~{tumorName}.purple.sv.vcf.gz"
        File purpleSvVcfIndex = "~{outputDir}/~{tumorName}.purple.sv.vcf.gz.tbi"
        File circosPlot = "~{outputDir}/plot/~{tumorName}.circos.png"
        File copynumberPlot = "~{outputDir}/plot/~{tumorName}.copynumber.png"
        File inputPlot = "~{outputDir}/plot/~{tumorName}.input.png"
        File mapPlot = "~{outputDir}/plot/~{tumorName}.map.png"
        File purityRangePlot = "~{outputDir}/plot/~{tumorName}.purity.range.png"
        File segmentPlot = "~{outputDir}/plot/~{tumorName}.segment.png"
        File somaticClonalityPlot = "~{outputDir}/plot/~{tumorName}.somatic.clonality.png"
        File somaticPlot = "~{outputDir}/plot/~{tumorName}.somatic.png"
        File purpleVersion = "~{outputDir}/purple.version"
        File circosNormalRatio = "~{outputDir}/circos/~{referenceName}.ratio.circos"
        File circosConf = "~{outputDir}/circos/~{tumorName}.circos.conf"
        File circosIndel = "~{outputDir}/circos/~{tumorName}.indel.circos"
        File circosLink = "~{outputDir}/circos/~{tumorName}.link.circos"
        File circosTumorRatio = "~{outputDir}/circos/~{tumorName}.ratio.circos"
        File circosGaps = "~{outputDir}/circos/gaps.txt"
        File circosBaf = "~{outputDir}/circos/~{tumorName}.baf.circos"
        File circosCnv = "~{outputDir}/circos/~{tumorName}.cnv.circos"
        File circosInputConf = "~{outputDir}/circos/~{tumorName}.input.conf"
        File circosMap = "~{outputDir}/circos/~{tumorName}.map.circos"
        File circosSnp = "~{outputDir}/circos/~{tumorName}.snp.circos"
        Array[File] outputs = [driverCatalogSomaticTsv, purpleCnvGeneTsv, purpleCnvGermlineTsv,
            purpleCnvSomaticTsv, purplePurityRangeTsv, purplePurityTsv, purpleQc, 
            purpleSegmentTsv, purpleSomaticClonalityTsv, purpleSomaticHistTsv, 
            purpleSomaticVcf, purpleSomaticVcfIndex, purpleSvVcf, purpleSvVcfIndex,
            purpleVersion, purpleGermlineVcf, purpleGermlineVcfIndex, driverCatalogGermlineTsv]
        Array[File] plots = [circosPlot, copynumberPlot, inputPlot, mapPlot, purityRangePlot,
            segmentPlot, somaticClonalityPlot, somaticPlot]
        Array[File] circos = [circosNormalRatio, circosConf, circosIndel, circosLink,
            circosTumorRatio, circosGaps, circosBaf, circosCnv, circosInputConf, circosMap,
            circosSnp]
    }

    runtime {
        time_minutes: timeMinutes # !UnknownRuntimeKey
        cpu: threads
        docker: dockerImage
        memory: memory
    }

    parameter_meta {
        referenceName: {description: "the name of the normal sample.", category: "required"}
        tumorName: {description: "The name of the tumor sample.", category: "required"}
        outputDir: {description: "The path to the output directory.", category: "common"}
        amberOutput: {description: "The output files of hmftools amber.", category: "required"}
        cobaltOutput: {description: "The output files of hmftools cobalt", category: "required"}
        gcProfile: {description: "A file describing the GC profile of the reference genome.", category: "required"}
        somaticVcf: {description: "The somatic variant calling results.", category: "required"}
        germlineVcf: {description: "The germline variant calling results.", category: "required"}
        filteredSvVcf: {description: "The filtered structural variant calling results.", category: "required"}
        fullSvVcf: {description: "The unfiltered structural variant calling results.", category: "required"}
        referenceFasta: {description: "The reference fasta file.", category: "required"}
        referenceFastaDict: {description: "The sequence dictionary associated with the reference fasta file.",
                             category: "required"}
        referenceFastaFai: {description: "The index for the reference fasta file.", category: "required"}
        driverGenePanel: {description: "A TSV file describing the driver gene panel.", category: "required"}
        somaticHotspots: {description: "A vcf file with hotspot somatic variant sites.", category: "required"}
        germlineHotspots: {description: "A vcf file with hotspot germline variant sites.", category: "required"}

        threads: {description: "The number of threads the program will use.", category: "advanced"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task Sage {
    input {
        String tumorName
        File tumorBam
        File tumorBamIndex
        File referenceFasta
        File referenceFastaDict
        File referenceFastaFai
        File hotspots
        File panelBed
        File highConfidenceBed
        Boolean hg38 = false
        Boolean panelOnly = false
        String outputPath = "./sage.vcf.gz"

        String? referenceName
        File? referenceBam
        File? referenceBamIndex
        Int? hotspotMinTumorQual
        Int? panelMinTumorQual
        Int? hotspotMaxGermlineVaf
        Int? hotspotMaxGermlineRelRawBaseQual
        Int? panelMaxGermlineVaf
        Int? panelMaxGermlineRelRawBaseQual
        String? mnvFilterEnabled
        File? coverageBed

        Int threads = 4
        String javaXmx = "50G"
        String memory = "51G"
        Int timeMinutes = 1 + ceil(size(select_all([tumorBam, referenceBam]), "G") * 9 / threads)
        String dockerImage = "quay.io/biocontainers/hmftools-sage:2.8--hdfd78af_0"
    }

    command {
        SAGE -Xmx~{javaXmx} -XX:ParallelGCThreads=1 \
        -tumor ~{tumorName} \
        -tumor_bam ~{tumorBam} \
        ~{"-reference " + referenceName} \
        ~{"-reference_bam " + referenceBam} \
        -ref_genome ~{referenceFasta} \
        -hotspots ~{hotspots} \
        -panel_bed ~{panelBed} \
        -high_confidence_bed ~{highConfidenceBed} \
        -assembly ~{true="hg38" false="hg19" hg38} \
        ~{"-hotspot_min_tumor_qual " + hotspotMinTumorQual} \
        ~{"-panel_min_tumor_qual " + panelMinTumorQual} \
        ~{"-hotspot_max_germline_vaf " + hotspotMaxGermlineVaf} \
        ~{"-hotspot_max_germline_rel_raw_base_qual " + hotspotMaxGermlineRelRawBaseQual} \
        ~{"-panel_max_germline_vaf " + panelMaxGermlineVaf} \
        ~{"-panel_max_germline_rel_raw_base_qual " + panelMaxGermlineRelRawBaseQual} \
        ~{"-mnv_filter_enabled " + mnvFilterEnabled} \
        ~{"-coverage_bed " + coverageBed} \
        ~{true="-panel_only" false="" panelOnly} \
        -threads ~{threads} \
        -out ~{outputPath}
    }

    output {
        File outputVcf = outputPath
        File outputVcfIndex = outputPath + ".tbi"
        # There is some plots as well, but in the current container the labels in the plots are just series of `□`s.
        # This seems to be a systemic issue with R generated plots in biocontainers...
    }

    runtime {
        time_minutes: timeMinutes # !UnknownRuntimeKey
        cpu: threads
        docker: dockerImage
        memory: memory
    }

    parameter_meta {
        tumorName: {description: "The name of the tumor sample.", category: "required"}
        tumorBam: {description: "The BAM file for the tumor sample.", category: "required"}
        tumorBamIndex: {description: "The index of the BAM file for the tumor sample.", category: "required"}
        referenceName: {description: "The name of the normal/reference sample.", category: "common"}
        referenceBam: {description: "The BAM file for the normal sample.", category: "common"}
        referenceBamIndex: {description: "The index of the BAM file for the normal sample.", category: "common"}
        referenceFasta: {description: "The reference fasta file.", category: "required"}
        referenceFastaDict: {description: "The sequence dictionary associated with the reference fasta file.",
                             category: "required"}
        referenceFastaFai: {description: "The index for the reference fasta file.", category: "required"}
        hotspots: {description: "A vcf file with hotspot variant sites.", category: "required"}
        panelBed: {description: "A bed file describing coding regions to search for in frame indels.", category: "required"}
        highConfidenceBed: {description: "A bed files describing high confidence mapping regions.", category: "required"}
        hotspotMinTumorQual: {description: "Equivalent to sage's `hotspot_min_tumor_qual` option.", category: "advanced"}
        panelMinTumorQual: {description: "Equivalent to sage's `panel_min_tumor_qual` option.", category: "advanced"}
        hotspotMaxGermlineVaf: {description: "Equivalent to sage's `hotspot_max_germline_vaf` option.", category: "advanced"}
        hotspotMaxGermlineRelRawBaseQual: {description: "Equivalent to sage's `hotspot_max_germline_rel_raw_base_qual` option.", category: "advanced"}
        panelMaxGermlineVaf: {description: "Equivalent to sage's `panel_max_germline_vaf` option.", category: "advanced"}
        panelMaxGermlineRelRawBaseQual: {description: "Equivalent to sage's `panel_max_germline_vaf` option.", category: "advanced"}
        mnvFilterEnabled: {description: "Equivalent to sage's `mnv_filter_enabled` option.", category: "advanced"}

        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}

task VirusInterpreter {
    input {
        String sampleId
        File virusBreakendTsv
        File taxonomyDbTsv
        File virusInterpretationTsv
        File virusBlacklistTsv
        String outputDir = "."

        String memory = "3G"
        String javaXmx = "2G"
        Int timeMinutes = 15
        String dockerImage = "quay.io/biowdl/virus-interpreter:1.0"
    }

    command {
        virus-interpreter -Xmx~{javaXmx} \
        -sample_id ~{sampleId} \
        -virus_breakend_tsv ~{virusBreakendTsv} \
        -taxonomy_db_tsv ~{taxonomyDbTsv} \
        -virus_interpretation_tsv ~{virusInterpretationTsv} \
        -virus_blacklist_tsv ~{virusBlacklistTsv} \
        -output_dir ~{outputDir}
    }

    output {
        File virusAnnotatedTsv = "~{outputDir}/~{sampleId}.virus.annotated.tsv"
    }

    runtime {
        time_minutes: timeMinutes # !UnknownRuntimeKey
        docker: dockerImage
        memory: memory
    }

    parameter_meta {
        sampleId: {description: "The name of the sample.", category: "required"}
        virusBreakendTsv: {description: "The TSV output from virusbreakend.", category: "required"}
        taxonomyDbTsv: {description: "A taxonomy database tsv.", category: "required"}
        virusInterpretationTsv: {description: "A virus interpretation tsv.", category: "required"}
        virusBlacklistTsv: {description: "A virus blacklist tsv.", category: "required"}
        outputDir: {description: "The directory the output will be written to.", category: "required"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        javaXmx: {description: "The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.",
                  category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.",
                      category: "advanced"}
    }
}