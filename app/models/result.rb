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
    get_binding_t(genome_seq)   
          #in the end of this function, delete genome_seq      
    end
   
   def get_binding_t(genome_seq)
        ge=self.generator_id
        g=Generator.find(ge)
        primer_length=g.primer_length
        forward=self.genome_seq.scan(g.f_primer) #pass forward and reverse count for next function determine
        reverse=self.genome_seq.scan(g.r_primer)
        self.binding_times= forward.length+reverse.length 
        
        if reverse.length == 0 || forward.length == 0
            self.amp_frags=0 
            self.genome_seq = nil
        else        
            xf=self.genome_seq.gsub(g.f_primer,' F ') 
            xfr=xf.gsub(g.r_primer,' R ') 
            findstarter(xfr,primer_length)
        end 
   end
   
   def findstarter(xfr,primer_length)
        list=xfr.scan(/\w+/)  
        f_index=list.index('F') 
        r_index=list.index('R') 

        if f_index<r_index==true
          startpos=f_index
        else
          startpos=r_index
        end        
      
    est_amp_frags(startpos,primer_length,*list)   
   end
   
   def est_amp_frags(startpos,primer_length,*list)  
      frags = 0
      list_size= list.length
      while startpos<list_size-2 do  
        checker=startpos+2
        tot_len=0   
        if list[startpos]=='F'
                while checker<list.length do  
                    if list[checker] == 'R' 
                        if list[checker-1] =='R' || list[checker-1] =='F'
                          tot_len+=primer_length
                        else 
                          tot_len+=list[checker-1].length
                        end
                        
                        if tot_len >199 && tot_len<2001 # 200-2000
                            frags +=1 
                            self.amp_frags=frags
                            get_seq_pos(startpos,primer_length,tot_len,*list)
                        end  
                        checker+=1
                    else
                        if list[checker-1] =='F' || list[checker-1]=='R'
                          tot_len+=primer_length
                        else  
                        tot_len+=list[checker-1].length
                        end
                    checker+=1
                    end
                end
        startpos+=1      
        elsif list[startpos]=='R'
              while checker<list.length do              
                    if list[checker] == 'F' 
                        if list[checker-1] =='F' || list[checker-1] =='R'
                          tot_len+=primer_length
                        else 
                          tot_len+=list[checker-1].length
                        end
                        
                        if tot_len >199 && tot_len<2001 #200-2000 REMEMBER TO CHANGE !!
                            frags +=1 
                            self.amp_frags=frags
                            get_seq_pos(startpos,primer_length,tot_len,*list)
                        end  
                    checker+=1
                    else
                        if list[checker-1] =='R' || list[checker-1]=='F'
                            tot_len+=primer_length
                        else  
                          tot_len+=list[checker-1].length
                        end
                    checker+=1
                    end
              end
        startpos+=1        
        else
            startpos+=1       
        end
      end   #while end        
   end
   
   def get_seq_pos(startpos,primer_length,tot_len,*list)#primer.length
      seq_pos1 =0
      seq_pos2= 0
          if startpos==0
            seq_pos1 = primer_length
            seq_pos2 = seq_pos1 + tot_len     
          else 
              while startpos!=-1 do
                    if list[startpos] == 'R' || list[startpos] == 'F'
                      seq_pos1 += primer_length
                    else
                      seq_pos1 += list[startpos].length
                    end
              seq_pos2 = seq_pos1+tot_len
              startpos-=1
              end    
          end #ADD IN DATA ATTRIBUTES POS1 & POS2
          self.seqpos1=seqpos1.to_a.push seq_pos1
          self.seqpos2=seqpos2.to_a.push seq_pos2
          self.genome_seq = nil
   end
end
