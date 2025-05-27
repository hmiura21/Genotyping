#!/bin/bash

source ~/miniforge3/etc/profile.d/conda.sh



#go to home directory
cd /Users/honokamiura/Downloads/BIOL7210/Exercises/ex5/hw/

#FETCHING DATA ------------------------------------------------------------------

#activate environment for cleaning
conda activate ex3

#create and go to raw_data directory
mkdir raw_data
cd raw_data

#fetch fastq data
prefetch SRR27160580
fasterq-dump SRR27160580 --outdir . --split-files --skip-technical

prefetch SRR27160579
fasterq-dump SRR27160579 --outdir . --split-files --skip-technical

prefetch SRR27160578
fasterq-dump SRR27160578 --outdir . --split-files --skip-technical

#make into gz file
pigz ./*.fastq

#go back to main directory
cd ..

#VIEW QUALITY ASSESSMENT ------------------------------------------------------------------
#make and go to raw_qa directory
mkdir raw_qa
cd raw_qa

#check if fastq works
fastqc --version

#view assessment using fastqc
fastqc \
    --threads 2 \
    --outdir .\
    ../raw_data/SRR27160580_1.fastq.gz \
    ../raw_data/SRR27160580_2.fastq.gz

fastqc \
    --threads 2 \
    --outdir .\
    ../raw_data/SRR27160579_1.fastq.gz \
    ../raw_data/SRR27160579_2.fastq.gz

fastqc \
    --threads 2 \
    --outdir .\
    ../raw_data/SRR27160578_1.fastq.gz \
    ../raw_data/SRR27160578_2.fastq.gz

#go back to main directory
cd ..

#TRIM USING FASTP ----------------------------------------

#make and go to trim directory
mkdir trim
cd trim

#trim using fastp
fastp -i ../raw_data/SRR27160580_1.fastq.gz \
    -I ../raw_data/SRR27160580_1.fastq.gz \
    -o ./SRR27160580_out.R1.fq.gz \
    -O ./SRR27160580_out.R2.fq.gz \
    --unpaired1 ./SRR27160580_unpaired_out.R1.fq.gz \
    --unpaired2 ./SRR27160580_unpaired_out.R2.fq.gz \
    -A \
    -e 30 \
    -h ./SRR27160580_fastp_report.html 

#combine unpaired files into singleton file
cat ./SRR27160580_unpaired_out.R1.fq.gz \
    ./SRR27160580_unpaired_out.R2.fq.gz \
    > ./SRR27160580_singletons.fq.gz

#trim using fastp
fastp -i ../raw_data/SRR27160579_1.fastq.gz \
    -I ../raw_data/SRR27160579_2.fastq.gz \
    -o ./SRR27160579_out.R1.fq.gz \
    -O ./SRR27160579_out.R2.fq.gz \
    --unpaired1 ./SRR27160579_unpaired_out.R1.fq.gz \
    --unpaired2 ./SRR27160579_unpaired_out.R2.fq.gz \
    -A \
    -e 30 \
    -h ./SRR27160579_fastp_report.html 

#combine unpaired files into singleton file
cat ./SRR27160579_unpaired_out.R1.fq.gz \
    ./SRR27160579_unpaired_out.R2.fq.gz \
    > ./SRR27160579_singletons.fq.gz


#trim using fastp
fastp -i ../raw_data/SRR27160578_1.fastq.gz \
    -I ../raw_data/SRR27160578_2.fastq.gz \
    -o ./SRR27160578_out.R1.fq.gz \
    -O ./SRR27160578_out.R2.fq.gz \
    --unpaired1 ./SRR27160578_unpaired_out.R1.fq.gz \
    --unpaired2 ./SRR27160578_unpaired_out.R2.fq.gz \
    -A \
    -e 30 \
    -h ./SRR27160578_fastp_report.html 

#combine unpaired files into singleton file
cat ./SRR27160578_unpaired_out.R1.fq.gz \
    ./SRR27160578_unpaired_out.R2.fq.gz \
    > ./SRR27160578_singletons.fq.gz


#remove unpaired file pairs
rm ./*unpaired*


#go back to main directory
cd ..


#ASSEMBLE USING SKESA ------------------------------------------------

#make and go to asm directory
mkdir asm
cd asm

#assembly using skesa
skesa \
    --reads ../trim/SRR27160580_out.R1.fq.gz ../trim/SRR27160580_out.R2.fq.gz \
    --contigs_out ./SRR27160580_assembly.fna 

skesa \
    --reads ../trim/SRR27160579_out.R1.fq.gz ../trim/SRR27160579_out.R2.fq.gz \
    --contigs_out ./SRR27160579_assembly.fna 

skesa \
    --reads ../trim/SRR27160578_out.R1.fq.gz ../trim/SRR27160578_out.R2.fq.gz \
    --contigs_out ./SRR27160578_assembly.fna 

#go back to main directory
cd ..

#FILTER OUT CONTIGS ------------------------------------------------

#make and go to contig_fil directory
mkdir contig_fil
cd contig_fil

#copy filter.contigs.py file to new directory
#cp ex3/contig_fil/filter.contigs.py ex5/hw/contig_fil

#check if filter.contigs.py works
chmod u+x filter.contigs.py 
./filter.contigs.py --help

#run filter.contigs.py
./filter.contigs.py \
    --infile ../asm/SRR27160580_assembly.fna \
    --outfile SRR27160580_filtered_assembly.fna \
    --discarded SRR27160580_removed-contigs.fa \
    --cov 10 


./filter.contigs.py \
    --infile ../asm/SRR27160579_assembly.fna \
    --outfile SRR27160579_filtered_assembly.fna \
    --discarded SRR27160579_removed-contigs.fa \
    --cov 10 


./filter.contigs.py \
    --infile ../asm/SRR27160578_assembly.fna \
    --outfile SRR27160578_filtered_assembly.fna \
    --discarded SRR27160578_removed-contigs.fa \
    --cov 10 


#view file sizes
ls -alh *.fna     #all show file size of 4.5M

#go back to main directory
cd ..

#deactivate env
conda deactivate


#FASTANI ---------------------------------------------------------------------------

#activate env for fastani
conda activate fastani 

#check if fastani works
fastani --version

#rename ref file
mv -v \
 GCF_020735925.1_ASM2073592v1_genomic.fna \
 reference.fna

#perform fastani
fastANI \
  --query ../contig_fil/SRR27160580_filtered_assembly.fna   \
  --ref reference.fna \
  --output SRR27160580_FastANI_Output.tsv

fastANI \
  --query ../contig_fil/SRR27160579_filtered_assembly.fna   \
  --ref reference.fna \
  --output SRR27160579_FastANI_Output.tsv

fastANI \
  --query ../contig_fil/SRR27160578_filtered_assembly.fna   \
  --ref reference.fna \
  --output SRR27160578_FastANI_Output.tsv


#add columns for alignment % and alignment length 
awk \
  '{alignment_percent = $4/$5*100} \
  {alignment_length = $4*3000} \
  {print $0 "\t" alignment_percent "\t" alignment_length}' \
  SRR27160580_FastANI_Output.tsv \
  > SRR27160580_FastANI_Output_With_Alignment.tsv

awk \
  '{alignment_percent = $4/$5*100} \
  {alignment_length = $4*3000} \
  {print $0 "\t" alignment_percent "\t" alignment_length}' \
  SRR27160579_FastANI_Output.tsv \
  > SRR27160579_FastANI_Output_With_Alignment.tsv

awk \
  '{alignment_percent = $4/$5*100} \
  {alignment_length = $4*3000} \
  {print $0 "\t" alignment_percent "\t" alignment_length}' \
  SRR27160578_FastANI_Output.tsv \
  > SRR27160578_FastANI_Output_With_Alignment.tsv

#add headers
awk 'BEGIN \
  {print "Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%Query_Aligned\tBasepairs_Query_Aligned"} \
  {print}' \
  SRR27160580_FastANI_Output_With_Alignment.tsv \
  > SRR27160580_FastANI_Output_With_Alignment_With_Header.tsv

awk 'BEGIN \
  {print "Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%Query_Aligned\tBasepairs_Query_Aligned"} \
  {print}' \
  SRR27160579_FastANI_Output_With_Alignment.tsv \
  > SRR27160579_FastANI_Output_With_Alignment_With_Header.tsv

awk 'BEGIN \
  {print "Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%Query_Aligned\tBasepairs_Query_Aligned"} \
  {print}' \
  SRR27160578_FastANI_Output_With_Alignment.tsv \
  > SRR27160578_FastANI_Output_With_Alignment_With_Header.tsv


#combine all files into single tsv file
cat SRR27160580_FastANI_Output_With_Alignment_With_Header.tsv \
    SRR27160579_FastANI_Output_With_Alignment_With_Header.tsv \
    SRR27160578_FastANI_Output_With_Alignment_With_Header.tsv \
    > fastani.tsv

#go back to home directory
cd ..

#deactivate env
conda deactivate


#MLST ---------------------------------------------------------------------------

#activate env for MLST
conda activate mlst_x86

#make and go to mlst directory
mkdir mlst
cd mlst

#perform mlst
mlst ../contig_fil/*.fna > mlst.tsv

#go back to main directory
cd ..



#CHECKM ---------------------------------------------------------------------------

#activate env for checkm
conda activate checkm

#check if checkm works
checkm --version

#make and go to checkm directory
mkdir checkm/{asm,db}
cd checkm

#go to asm directory
cd asm

#move SRR27160578_filtered_assembly fna files from contig_fil to asm 
ln -sv ../../contig_fil/SRR27160578_filtered_assembly.fna .

#go to db directory
cd ..
cd db

#download database
curl -O https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
tar zxvf checkm_data_2015_01_16.tar.gz

#set root directory for ref database
checkm data setRoot .

#see taxon list for Bordetella
checkm taxon_list | grep Bordetella

#create markers for Bordetella (no species found so working with genus level)
checkm taxon_set genus "Bordetella" Bt.markers

#perform checkm
checkm \
      analyze \
      Bt.markers \
      ../asm \
      analyze_output
checkm \
      qa \
      -f quality.tsv \
      -o 1 \
      Bt.markers \
      analyze_output