#!/bin/bash

# Define paths (updated to external SSD)
VCF_DIR="/Volumes/Extreme_SSD/Regie/vcf_loftee_all"
OUTPUT_DIR="/Volumes/Extreme_SSD/Regie/annovar_keepingallcols_afterloftee_results"
HUMANDB_DIR="/usr/local/bin/humandb"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Export paths for parallel processing
export HUMANDB_DIR
export OUTPUT_DIR

# Process all VCF files in parallel (2 jobs at a time)
ls "$VCF_DIR"/*.vcf | parallel -j 2 '
    VCF_FILE={};
    SAMPLE=$(basename "$VCF_FILE" .freebayes_VEP.ann.vcf);
    OUTPUT_PREFIX="$OUTPUT_DIR/$SAMPLE";

    echo "Processing sample: $SAMPLE";

    # Run ANNOVAR with multi-threading (4 threads)
    perl /usr/local/bin/table_annovar.pl \
        "$VCF_FILE" \
        "$HUMANDB_DIR" \
        --buildver hg38 \
        --outfile "$OUTPUT_PREFIX" \
        --remove \
        --protocol refGene,gnomad41_exome,gme,dbnsfp42c,dbscsnv11,clinvar_20240917 \
        --operation g,f,f,f,f,f \
        --nastring . \
        --polish \
        --vcfinput \
        --thread 4 \
        --argument "-otherinfo",,,,, 

    # Check if annotation was successful
    if [[ $? -eq 0 ]]; then 
        echo "Annotation completed for sample $SAMPLE."; 
    else 
        echo "Error: Annotation failed for sample $SAMPLE."; 
        exit 1; 
    fi
'

echo "All samples processed."

