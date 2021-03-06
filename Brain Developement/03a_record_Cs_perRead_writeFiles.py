import glob, os, json, csv
import pysam

## Note: pysam does not work in Windows!

#%%

def countCs_from_BAM(bam_input):
    #print(bam_input)
    C_count_dict = {'1':0, '2':0, '3':0, '4-5':0, '6-10':0, '11-20': 0, '>20': 0}
    C_count_list = []
    bamfile = pysam.AlignmentFile(bam_input,"rb", check_sq=False)
    sample_name = os.path.basename(bam_input).split("*meRanGh_genomeMap_sorted.bam")[0]

    # check each read for C content, write to new file if passed filter
    # Write reads with 20+Cs to new file
    #writer_20 = pysam.AlignmentFile(sample_name+"_20Cs.sam", "wb", template=bamfile)
    # Write reads with <20+Cs to new file
    #writer_other = pysam.AlignmentFile(sample_name+"_otherCs.sam", "wb", template=bamfile)
            
    # check each read for C content, write to new file if passed filter
    for read in bamfile.fetch():
        sequence = read.query_sequence.upper()
        try:
            if read.get_tag('YR') == 'G2A':  # read pair copy
                C_count = 'null'
                pass
            elif read.get_tag('YG') == 'C2T':  # Aligned to positive strand
                C_count = float(sequence.count('C'))
            elif read.get_tag('YG') == 'G2A':  # Aligned to negative strand
                C_count = float(sequence.count('G'))
            else:
                print("tag not found")
                C_count = 'null'
                pass
            # bin C_count per read
            if C_count == 0 or C_count == 'null':
                pass
            elif C_count <= 1:
                C_count_dict['1'] += 1
                #writer_other.write(read)
            elif C_count <= 2:
                C_count_dict['2'] += 1
                #writer_other.write(read)
            elif C_count <= 3:
                C_count_dict['3'] += 1
            elif C_count <= 5:
                C_count_dict['4-5'] += 1
                #writer_other.write(read)
            elif C_count <= 10:
                C_count_dict['6-10'] += 1
            elif C_count <= 20:
                C_count_dict['11-20'] += 1
                #writer_other.write(read)
            elif C_count > 20:
                C_count_dict['>20'] += 1
                #writer_20.write(read)
            else:
                print("missed-count")
                    #C_count_list = [i for i in C_count_list if i != 0]
        except KeyError:
            print("problem with tag ID")
    return C_count_dict

#%%
C_count_dict = {}
df_list = []
name_list = []

# Important files to count:
important_ext =  ["*_meRanGh_genomeMap_sorted.bam"]

important_files = []

for ext in important_ext:
    for file in glob.glob("**/"+ext, recursive=True):
        important_files.append(file)

print(important_files)
for file in important_files:
    print(file)
    name = os.path.basename(file).split("*_meRanGh_genomeMap_sorted.bam")[0]
    name_list.append(name)
    hist_list = countCs_from_BAM(file)
    df_list.append(hist_list)

for i in range(len(name_list)):
    C_count_dict[name_list[i]] = df_list[i]

with open(os.getcwd()+'/C_Count_hist.json', 'w') as convert_file:
    convert_file.write(json.dumps(C_count_dict))


