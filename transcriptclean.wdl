version 1.0

# Copyright (c) 2019 Sequencing Analysis Support Core - Leiden University Medical Center
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

task CleanSpliceJunctions {
    input {
        File SAMfile
        File referenceGenome
        String outputPrefix
        File spliceJunctionAnnotation

        File? variantFile

        Int cores = 1
        String memory = "4G"
        String dockerImage = "biocontainers/transcriptclean:v1.0.8_cv1"
    }

    command {
        set -e
        mkdir -p $(dirname ~{outputPrefix})
        clean_splice_jns \
        ~{"--f=" + SAMfile} \
        ~{"--g=" + referenceGenome} \
        ~{"--o=" + outputPrefix} \
        ~{"--s=" + spliceJunctionAnnotation} \
        ~{"--v=" + variantFile}
    }

    output {
        File outputCleanedSAM = outputPrefix + "_clean.sam"
    }

    runtime {
        cpu: cores
        memory: memory
        docker: dockerImage
    }

    parameter_meta {
        SAMfile: "Input SAM file"
        referenceGenome: "Reference genome fasta file."
        outputPrefix: "Output directory path + output file prefix."
        spliceJunctionAnnotation: "Splice junction file"
        variantFile: "VCF formatted file of variants"

        outputCleanedSAM: "Cleaned sam output file."
    }
}

task GetCorrectedSJsFromLog {
    input {
        File TElogFile
        String outputPrefix

        Int cores = 1
        String memory = "5G"
        String dockerImage = "biocontainers/transcriptclean:v1.0.8_cv1"
    }

    command {
        set -e 
        mkdir -p $(dirname ~{outputPrefix})
        get_corrected_SJs_from_log \
        ~{TElogFile} \
        ~{outputPrefix + ".tsv"}
    }

    output {
        File outputCorrectedSJs = outputPrefix + ".tsv"
    }

    runtime {
        cpu: cores
        memory: memory
        docker: dockerImage
    }

    parameter_meta {
        TElogFile: "TE log from TranscriptClean."
        outputPrefix: "Output directory path + output file prefix."

        outputCorrectedSJs: "Formely noncanonical splice junctions in BED format."
    }
}

task GetSJsFromGtf {
    input {
        File GTFfile
        File genomeFile
        String outputPrefix
        Int minIntronSize = 21

        Int cores = 1
        String memory = "8G"
        String dockerImage = "biocontainers/transcriptclean:v1.0.8_cv1"
    }

    command {
        set -e
        mkdir -p $(dirname ~{outputPrefix})
        get_SJs_from_gtf \
        ~{"--f=" + GTFfile} \
        ~{"--g=" + genomeFile} \
        ~{"--o=" + outputPrefix + ".tsv"} \
        ~{"--minIntronSize=" + minIntronSize}
    }

    output {
        File outputSJsFile = outputPrefix + ".tsv"
    }

    runtime {
        cpu: cores
        memory: memory
        docker: dockerImage
    }

    parameter_meta {
        GTFfile: "Input GTF file"
        genomeFile: "Reference genome"
        outputPrefix: "Output directory path + output file prefix."
        minIntronSize: "Minimum size of intron to consider a junction."

        outputSJsFile: "Extracted splice junctions."
    }
}

task GetTranscriptCleanStats {
    input {
        File transcriptCleanSAMfile
        String outputPrefix

        Int cores = 1
        String memory = "4G"
        String dockerImage = "biocontainers/transcriptclean:v1.0.8_cv1"
    }

    command {
        set -e
        mkdir -p $(dirname ~{outputPrefix})
        get_TranscriptClean_stats \
        ~{transcriptCleanSAMfile} \
        ~{outputPrefix}
    }

    output {
        File outputStatsFile = stdout()
    }

    runtime {
        cpu: cores
        memory: memory
        docker: dockerImage
    }

    parameter_meta {
        transcriptCleanSAMfile: "Output SAM file from TranscriptClean"
        outputPrefix: "Output directory path + output file prefix."

        outputStatsFile: "Summary stats from TranscriptClean run."
    }
}

task TranscriptClean {
    input {
        File SAMfile
        File referenceGenome
        String outputPrefix
        Int maxLenIndel = 5
        Int maxSJoffset = 5
        Boolean correctMismatches = true
        Boolean correctIndels = true
        Boolean dryRun = false
        Boolean primaryOnly = false

        File? spliceJunctionAnnotation
        File? variantFile
        Boolean? correctSJs

        Int cores = 1
        String memory = "25G"
        String dockerImage = "biocontainers/transcriptclean:v1.0.8_cv1"
    }

    command {
        set -e
        mkdir -p $(dirname ~{outputPrefix})
        TranscriptClean \
        ~{"-s " + SAMfile} \
        ~{"-g " + referenceGenome} \
        ~{"-o " + outputPrefix} \
        ~{"-j " + spliceJunctionAnnotation} \
        ~{"-v " + variantFile} \
        ~{"--maxLenIndel=" + maxLenIndel} \
        ~{"--maxSJOffset=" + maxSJoffset} \
        ~{true="-m CORRECTMISMATCHES" false="-m false" correctMismatches} \
        ~{true="-i CORRECTINDELS" false="-i false" correctIndels} \
        ~{true="--correctSJs=CORRECTSJS" false="--correctSJs=false" correctSJs} \
        ~{true="--dryRun" false="" dryRun} \
        ~{true="--primaryOnly" false="" primaryOnly}
    }

    output {
        File outputTranscriptCleanFasta = outputPrefix + "_clean.fa"
        File outputTranscriptCleanLog = outputPrefix + "_clean.log"
        File outputTranscriptCleanSAM = outputPrefix + "_clean.sam"
        File outputTranscriptCleanTElog = outputPrefix + "_clean.TE.log"
    }

    runtime {
        cpu: cores
        memory: memory
        docker: dockerImage
    }

    parameter_meta {
        SAMfile: "Input SAM file containing transcripts to correct."
        referenceGenome: "Reference genome fasta file."
        outputPrefix: "Output directory path + output file prefix."
        spliceJunctionAnnotation: "Splice junction file"
        maxLenIndel: "Maximum size indel to correct."
        maxSJoffset: "Maximum distance from annotated splice junction to correct."
        correctMismatches: "Set this to make TranscriptClean correct mismatches."
        correctIndels: "Set this to make TranscriptClean correct indels."
        correctSJs: "Set this to make TranscriptClean correct splice junctions."
        dryRun: "TranscriptClean will read in the data but don't do any correction."
        primaryOnly: "TranscriptClean will only output primary mappings of transcripts."

        outputTranscriptCleanFasta: "Fasta file containing corrected reads."
        outputTranscriptCleanLog: "Log file of TranscriptClean run."
        outputTranscriptCleanSAM: "SAM file containing corrected aligned reads."
        outputTranscriptCleanTElog: "TE log file of TranscriptClean run."
   }
}