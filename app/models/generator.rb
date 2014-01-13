class Generator < ActiveRecord::Base
  has_one :result , :dependent => :destroy
  belongs_to :user
  default_scope order('created_at DESC')
  
  validates_inclusion_of :user_seq, :in => %w(A T G C R Y S W K M B D H V N), if: :choice_is_seating?
  attr_accessible :choice, :primer_length, :random_primer_generated, :generator_id,:user_seq
  
  def choice_is_seating?
    choice=="seating"
  end
  
  def random_generate(generator_params,monovalent,divalent,dNTP)
    length = primer_length
    chars = 'ATGC'
    seq = ''
    length.times { seq << chars[rand(chars.size)] }
    self.random_primer_generated = seq
    self.percent_gc = seq.gc_percent
    fwrd =Bio::Sequence::NA.new(self.random_primer_generated)
    self.f_primer=fwrd.upcase
    r=f_primer.reverse.upcase
    self.r_primer=r.forward_complement.upcase
    calculate_Tm(self.primer_length,self.random_primer_generated,monovalent,divalent,dNTP)
  end

  def specified_ATGC(no_A,no_T,no_G,no_C,monovalent,divalent,dNTP)
    counts = {'A'=>no_A,'T'=>no_T,'G'=>no_G,'C'=>no_C}
    self.random_primer_generated = Bio::Sequence::NA.randomize(counts).upcase
    self.primer_length = self.random_primer_generated.length
    self.percent_gc = random_primer_generated.gc_percent
    
    fwrd = Bio::Sequence::NA.new(self.random_primer_generated)
    self.f_primer = fwrd.upcase
    r=f_primer.reverse.upcase
    self.r_primer=r.forward_complement.upcase
    calculate_Tm(self.primer_length,self.random_primer_generated,monovalent,divalent,dNTP)
  end

  def seating(user_seq,monovalent,divalent,dNTP)
    desired_random_primer=user_seq
    self.primer_length = desired_random_primer.length
    n=0
    while n < self.primer_length do
      if desired_random_primer[n] == "R"
        chars = 'AG'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "Y"
        chars = 'CT'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "M"
        chars = 'AC'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "K"
        chars = 'GT'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "S"
        chars = 'CG'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "W"
        chars = 'AT'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "H"
        chars = 'ACT'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "B"
        chars = 'CGT'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "V"
        chars = 'ACG'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "D"
        chars = 'AGT'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      elsif desired_random_primer[n] == "N"
        chars = 'ATGC'
        seq = ''
        1.times { seq << chars[rand(chars.size)] }
      desired_random_primer[n]=desired_random_primer[n].replace(seq)
      else
      desired_random_primer[n]=desired_random_primer[n]
      end
      n+=1
    end
    self.random_primer_generated = desired_random_primer
    s= Bio::Sequence::NA.new(random_primer_generated)
    self.percent_gc =s.gc_percent

    fwrd =Bio::Sequence::NA.new(self.random_primer_generated)
    self.f_primer = fwrd.upcase
    r=f_primer.reverse.upcase
    self.r_primer=r.forward_complement.upcase
  
    calculate_Tm(self.primer_length,self.random_primer_generated,monovalent,divalent,dNTP)
  end

  def calculate_Tm(primer_length,random_primer_generated,monovalent,divalent,dNTP)
    random_primer_generated.upcase

    _h = {"AA" => -7.9, "TT" => -7.9, "AT" => -7.2, "TA" => -7.2,
      "CA" => -8.5, "TG" => -8.5, "GT" => -8.4, "AC" => -8.4,
      "CT" => -7.8, "AG" => -7.8, "GA" => -8.2, "TC" => -8.2,
      "CG" => -10.6, "GC" => -9.8, "GG" => -8.0, "CC" => -8.0}

    _s={"AA" => -22.2, "TT" => -22.2, "AT" => -20.4, "TA" => -21.3,
      "CA" => -22.7, "TG" => -22.7, "GT" => -22.4, "AC" => -22.4,
      "CT" => -21.0, "AG" => -21.0, "GA" => -22.2, "TC" => -22.2,
      "CG" => -27.2, "GC" => -24.4, "GG" => -19.9, "CC" => -19.9}

    tot_h=2.4 
    tot_s=1.3 
    for i in 0..(random_primer_generated.length-2)
      tot_h += _h[ random_primer_generated.slice(i,2) ]
      tot_s += _s[ random_primer_generated.slice(i,2) ]
    end
    
    ct = 5/100000000.to_f   # concentration of oligo (mol/L) - 0.05 uM so need /1000000 to become M(mol/L)
    monovalent= monovalent.to_f
    monovalent=monovalent/1000
    divalent=divalent.to_f
    divalent=divalent/1000
    dNTP=dNTP.to_f
    dNTP=dNTP/1000
    @@r=1.987                  

    if self.divalent==0.00 || self.dNTP==0.00 || dNTP>divalent
       #deltaS(predicted) + 0.368*15(NN pairs)*ln(0.05M monovalent cations) 
       tot_s=tot_s+(0.368*(self.primer_length-1)*Math.log(monovalent,2.71828183)) 
    else
      #[Monovalent cations] = [Monovalent cations] + 120*(([divalent cations] - [dNTP])^0.5)
      monovalent = monovalent + 120*((divalent - dNTP)**0.5)
      tot_s=tot_s+(0.368*(self.primer_length-1 )*Math.log(monovalent,2.71828183)) 
    end
      #Tm = deltaH/(deltaS + R*ln(C/4))
      tm = (tot_h*1000)/(tot_s+@@r*Math.log(ct/4,2.71828183))-273.15
      self.melting_temp = tm.round(2)
  end
  
end
