FROM ubuntu:22.04

ENV SOFT "/soft"
ENV HTSLIB "$SOFT/htslib-1.20"
ENV SAMTOOLS "$SOFT/samtools-1.20"
ENV LIBDEFLATE "$SOFT/libdeflate-1.20"
ENV BCFTOOLS "$SOFT/bcftools-1.20"
ENV VCFTOOLS "$SOFT/vcftools-0.1.16"

RUN mkdir -p $SOFT
RUN apt-get update && apt-get install -y git wget bzip2 gcc autoconf automake make perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev cmake g++ build-essential pkg-config python3 pip && \
 apt-get clean && apt-get purge && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# LIBDEFLATE 1.20
RUN cd $SOFT && \
 wget https://github.com/ebiggers/libdeflate/releases/download/v1.20/libdeflate-1.20.tar.gz && \
 tar -xf libdeflate-1.20.tar.gz && \
 rm libdeflate-1.20.tar.gz && \ 
 cd libdeflate-1.20 && \
 cmake -B build && cmake -DCMAKE_PREFIX_PATH=$LIBDEFLATE && cmake --build build

# HTSLIB 1.20
ENV CPPFLAGS "-I$SOFT/libdeflate-1.20/build${CPPFLAGS:+:}$CPPFLAGS"
ENV LDFLAGS "-L$SOFT/libdeflate-1.20/build${LDFLAGS:+:}$LDFLAGS"
ENV C_INCLUDE_PATH "$SOFT/libdeflate-1.20"
ENV LIBRARY_PATH "$SOFT/libdeflate-1.20"

RUN cd $SOFT && \
 wget https://github.com/samtools/htslib/releases/download/1.20/htslib-1.20.tar.bz2 && \
 tar -xjf htslib-1.20.tar.bz2 && \
 rm htslib-1.20.tar.bz2 && \
 cd htslib-1.20 && \
 ./configure --prefix $HTSLIB --with-libdeflate && \
 make && \
 make install
  

# SAMTOOLS 1.20
RUN cd $SOFT && \
 wget https://github.com/samtools/samtools/releases/download/1.20/samtools-1.20.tar.bz2 && \
 tar -xjf samtools-1.20.tar.bz2 && \
 rm samtools-1.20.tar.bz2 && \
 cd samtools-1.20 && \
 ./configure --prefix $SAMTOOLS --with-htslib=$HTSLIB && \
 make && \
 make install

# BCFTOOLS 1.20
RUN cd $SOFT && \
 wget https://github.com/samtools/bcftools/releases/download/1.20/bcftools-1.20.tar.bz2 && \
 tar -xjf bcftools-1.20.tar.bz2 && \
 rm bcftools-1.20.tar.bz2 && \
 cd bcftools-1.20 && \
 ./configure --prefix $BCFTOOLS --with-htslib=$HTSLIB && \
 make && \
 make install

# VCFTOOLS 0.1.16
RUN cd $SOFT && \
 wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz && \
 tar -xf vcftools-0.1.16.tar.gz && \
 rm vcftools-0.1.16.tar.gz && \
 cd vcftools-0.1.16 && \
 ./configure --prefix $VCFTOOLS && \
 make && \
 make install

ENV PATH ${PATH}:$HTSLIB:$SAMTOOLS:$LIBDEFLATE:$SOFT/vcftools-0.1.16/bin:$SOFT/bcftools-1.20

ENV SAMTOOLS "$SAMTOOLS/samtools"
ENV BCFTOOLS "$BCFTOOLS/bcftools"
ENV VCFTOOLS "$VCFTOOLS/bin/vcftools"

RUN pip install argparse pysam pandas datetime

COPY FP_SNPs_10k_GB38_twoAllelsFormat.tsv .
COPY script.py .

CMD ["bash"] 