#!/bin/bash
#PBS -l nodes=compute_node_3:ppn=12
#PBS -l walltime=144:00:00
#PBS -j oe
#PBS -N Pindel
##
############################################
tumor_bam=$1
normal_bam=$2
sample=$3
nt=$4
ref=$5

############################################
##module load
#module load bwa
#module load fastqc
module load samtools 
module load pindel
gatk="/opt/softwares/GATK-3.6.0"
#samtools="/opt/softwares/samtools-1.3.1/samtools"
#varscan="/opt/softwares/VarScan2"
#pindel="/opt/softwares/pindel"
#java="/home/chenxingdong/software/jre1.8.0_144/bin/java"
############################################
# Log file 
cd /home/libin/Projects/qtPindel201711 
#====== bianll======
logfile="log/${sample}.$(date +"%Y%m%d%H%M").log"

set -x
exec >$logfile
start_time=$(date +%s)
startdate=$(date -d @$start_time)


##VarScan2
start_time_mod=$(date +%s)
samtools view $tumor_bam | sam2pindel - "Results"/$sample.tumor.pindel 300 tumor 0 Illumina-PairEnd
samtools view $normal_bam | sam2pindel - "Results"/$sample.normal.pindel 300 normal 0 Illumina-PairEnd

pindel -f $ref/hg19_nochr.fa -T $nt -p "Results"/$sample.tumor.pindel -c ALL -o "Results"/$sample.tumor.pindel.txt
pindel -f $ref/hg19_nochr.fa -T $nt -p "Results"/$sample.tumor.pindel -c ALL -o "Results"/$sample.normal.pindel.txt

Foo=("INV" "TD" "SI" "D" "LI" "BP")

for type in ${Foo[@]}

do

pindel2vcf -p "Results"/$sample.normal.pindel.txt_${type} -r $ref/hg19_nochr.fa -R hg19  -d 2009 -v "Results"/$sample.tumor.$type &
pindel2vcf -p "Results"/$sample.normal.pindel.txt_${type} -r $ref/hg19_nochr.fa -R hg19  -d 2009 -v "Results"/$sample.normal.$type &

done



#$samtools mpileup -f $ref/hg19_nochr.fa  -q 30 -B $normal_bam  $tumor_bam | $java -Xmx12g -jar $varscan/VarScan.v2.3.9.jar somatic --min-coverage 8 --min-coverage-normal 8 --min-coverage-tumor 5 --min-var-freq 0.08 --min-avg-qual 20 --mpileup 1 --output-vcf 1 --output-snp "Results"/$sample.VarScan2.snp.txt --output-indel "Results"/$sample.VarScan2.indel.txt --strand-filter 1 --p-value 0.05
end_time_mod=$(date +%s)
echo "Module PIndel Started: "$start_date"; Ended: "$end_date"; Elapsed time: "$(($end_time_mod - $start_time_mod))" sec">>$logfile

echo "Module All Started: "$start_date"; Ended: "$end_date"; Elapsed time: "$(($end_time_mod - $start_time_mod))" sec">>$logfile



