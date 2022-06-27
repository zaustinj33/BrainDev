#!/bin/bash

mkdir -p $2/Code/$1/
mkdir -p $2/working_data/$1
mkdir -p $2/result/$1

pushd $2/Code/$1/

echo -e "#!/bin/bash
#SBATCH -p normal_q
#SBATCH -A davidxie_lab
#SBATCH --nodes=1 --cpus-per-task=40
#SBATCH --mem=100G
#SBATCH --time=48:00:00
#SBATCH --mail-user zaustinj@vt.edu
#SBATCH --mail-type=END

module reset
module load fastp

cd $2/working_data/$1

# Too short or no mate, remove adapters, remove polyx tails, Remove low quality bases, window trim
fastp -w 16 -q 25 -f 6 -t 6 -l 50 --trim_poly_x --poly_x_min_len 10 -i $2/raw_data/$1/$1_1.fq.gz -I $2/raw_data/$1/$1_2.fq.gz --out1 $1_1_trim.fq.gz --out2 $1_2_trim.fq.gz --failed_out $1_failed_length.fq.gz -j $1_failed_length.json -h $1_failed_length.html --detect_adapter_for_pe --overlap_diff_percent_limit 25
module reset
module load HISAT2

mkdir -p \$TMPDIR/ZJ_tmp

cp $1_1_trim.fq.gz \$TMPDIR/ZJ_tmp
cp $1_2_trim.fq.gz \$TMPDIR/ZJ_tmp
cd \$TMPDIR/ZJ_tmp

gunzip $1_1_trim.fq.gz
gunzip $1_2_trim.fq.gz

echo 'Start meRanGh'
meRanGh align -o \$TMPDIR/ZJ_tmp/ -un -ud $2/raw_data/$1/meRanGhUnaligned -f $1_2_trim.fq -r $1_1_trim.fq -t 40 -fmo -ds -S $1_meRanGh_genomeMap.sam -ds -MM -id /projects/epigenomicslab/Annotation/mm10_meRanGh/BSgenomeIDX -GTF /projects/epigenomicslab/Annotation/mm10.ensGene.for.RNABS.gtf
echo 'Finished meRanGh'

cp $1_meRanGh_genomeMap_sorted.bam $2/result/$1/
cp $1_meRanGh_genomeMap_sorted.bam.bai $2/result/$1/

rm $1_1_trim.fq
rm $1_2_trim.fq

" > $1_sequenceTrimMap.sbatch

sbatch $1_sequenceTrimMap.sbatch
