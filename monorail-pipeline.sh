#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --time=03:00:00
#SBATCH --partition=amilan
#SBATCH --output=monorail-%j.out
#SBATCH --mail-type=END
#SBATCH --mail-user=lucas.gillenwater@cuanschutz.edu
#SBATCH --job-name=monorail

# load necessary modules
module load sra-toolkit



{
    # saving the sample metadata
    FILENAME="/scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/sample_metadata.tsv"
    touch $FILENAME
    echo -e 'study_id\tsample_id' >> $FILENAME
    
    read
    while IFS=, read -r SRA
    do
	echo $SRA

	# # add metadata to sample metadata
	echo -e "SRP349148\t$SRA" >> $FILENAME

	# # fetch and process sra files 
	prefetch --max-size 200G -L info -t http -O /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/sra $SRA
	fasterq-dump --split-files ./sra/$SRA -O /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/sra
	rm -r /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/sra/$SRA

	# PUMP 
	/scratch/alpine/lgillenwater@xsede.org/monorail-external/singularity/run_recount_pump.sh \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/recount-rs5_1.0.6.sif\
			    $SRA \
			    local \
			    hg38 \
			    20\
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/sra/${SRA}_1.fastq \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/sra/${SRA}_2.fastq \
			    SRP349148

    done
}  < /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/SraTest.csv

mv /scratch/alpine/lgillenwater@xsede.org/monorail-external/output /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/



/scratch/alpine/lgillenwater@xsede.org/monorail-external/singularity/run_recount_unify.sh \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/recount-unify_1.1.1.sif \
			    hg38 \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/references \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/unifier \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/output/htp \
			    /scratch/alpine/lgillenwater@xsede.org/monorail-external/htp/sample_metadata.tsv \
			    20\
			    htp:110



