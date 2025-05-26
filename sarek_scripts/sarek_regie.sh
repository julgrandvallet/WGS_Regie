#!/bin/bash

# Set project-specific variables
INVESTIGATOR=Regie
PROJECT=hearing_loss

# Generate a timestamp for the log files
RAN_ON=$(date +%Y_%m_%d_%H_%M)

# Define base directories
WGS=/beevol/home/contrerj/projects/
DATA=$WGS/${INVESTIGATOR}/$PROJECT
FASTQ=$WGS/${INVESTIGATOR}/$PROJECT/fastq_files/fqfiles/  # Update to point to the correct FASTQ directory
SCRIPTS=$DATA/scripts

# Define log and output directories
LOGFILE=$SCRIPTS/nf_sarek_log
OUTPUT=$DATA/nfcore_sarek_vep_bamincluded_results


# Create the necessary directories
mkdir -p $LOGFILE
mkdir -p $OUTPUT

# Define the job script file
FILE="Regie_script"

# Create the job script
cat << EOF > ${FILE}_script.sh

#BSUB -J Sarek
#BSUB -o $LOGFILE/${RAN_ON}_Sarek.out
#BSUB -e $LOGFILE/${RAN_ON}_Sarek.err
#BSUB -R "select[mem>190] rusage[mem=190]"
#BSUB -R "span[hosts=1]"
#BSUB -q jones
#BSUB -n 22


module load modules modules-init modules-python
module load java/18

export NXF_OPTS='-Xms1g -Xmx4g'

cd $FASTQ
     
nextflow run nf-core/sarek \
    -profile docker \
    --input /beevol/home/contrerj/projects/Regie/hearing_loss/fastq_files/samplesheet.csv \
    --genome GATK.GRCh38 \
    --outdir /beevol/home/contrerj/projects/Regie/hearing_loss/nfcore_sarek_vep_results \
    --tools freebayes,strelka,manta,cnvkit,vep,snpeff \
    -c /beevol/home/contrerj/projects/Regie/hearing_loss/custom.config \
    --skip_tools baserecalibrator \
    --trim_fastq true \
    --save_trimmed true \
    --save_mapped true \
    --multiqc_title test_for_loftee \
    --max_retries 3 \
    --vep_loftee \
    -resume

EOF

# Submit the job script to the cluster
bsub < ${FILE}_script.sh

# Clean up by removing the job script
rm -f ${FILE}_script.sh
