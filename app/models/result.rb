class Result < ActiveRecord::Base
   attr_accessible :generator_id,:ncbi_ref_seq,:genome_seq, :genome_sample
   belongs_to :generator
   
    def generate_result(result_params) 
       
       if ncbi_ref_seq == ''
         fasta = Bio::FastaFormat.new(self.genome_seq)
         self.genome_sample = fasta.definition
         self.ncbi_ref_seq = fasta.accession 
       else
              ref_seq = self.ncbi_ref_seq
              Bio::NCBI.default_email = "spykix@hotmail.com"
              fasta_sequence = Bio::NCBI::REST::EFetch.nucleotide(ref_seq,"fasta")
              fasta=Bio::FastaFormat.new(fasta_sequence)
              self.genome_seq = fasta.data
              self.genome_sample = fasta.definition  
       end 
      
        ge=self.generator_id
        g=Generator.find(ge)
        reverse = Bio::Sequence::NA.new(g.r_primer)
        reverse=reverse.forward_complement.upcase
        
        forward=self.genome_seq.scan(g.f_primer)
        reverse=self.genome_seq.scan(reverse)
        self.binding_times= forward.length() + reverse.length()           
    end
   
end
