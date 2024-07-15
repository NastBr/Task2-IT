FROM ubuntu:22.04

ENV SOFT "/soft"

RUN mkdir -p $SOFT
RUN apt-get update && apt-get install -y git wget bzip2 gcc autoconf automake make perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev libdeflate-dev

# SAMTOOLS 1.20 
RUN cd $SOFT && \
 wget https://github.com/samtools/samtools/releases/download/1.20/samtools-1.20.tar.bz2 && \
 tar -xjf samtools-1.20.tar.bz2 && \
 rm samtools-1.20.tar.bz2 && \
 cd samtools-1.20 && \
 ./configure && \
 make && \
 make install

CMD ["bash"]