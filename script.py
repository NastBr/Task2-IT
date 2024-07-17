import argparse
import pysam
import pandas as pd
from datetime import datetime

def convert_file(input_file: str, output_file: str):
    # Print start time
    print(f"Converting started at : {datetime.now()}")

    try:
        data = pd.read_csv(input_file, sep="\t")
    except FileNotFoundError:
        print(f"File {input_file} does not exist")
        return

    fasta = pysam.FastaFile("GRCh38.d1.vd1.fa")
    data["REF"] = data.apply(
        lambda row: fasta.fetch(row["#CHROM"], row["POS"] - 1, row["POS"]), axis=1
    )
    data["ALT"] = data.apply(
        lambda row: row["allele1"] if row["allele1"] != row["REF"] else row["allele2"], axis=1
    )
    data = data.drop('allele1', axis=1)
    data = data.drop('allele2', axis=1)

    data.to_csv(output_file, sep="\t", index=False)

    print(f"Converting finished at: {datetime.now()}")


def main():
    parser = argparse.ArgumentParser(description="Task3")
    parser.add_argument("--input", type=str, help="path to input file")
    parser.add_argument("--output", type=str, help="path to output file")
    args = parser.parse_args()

    # Invoke the function
    convert_file(args.input, args.output)


if __name__ == "__main__":
    main()