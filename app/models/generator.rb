class Generator < ActiveRecord::Base
  has_one :result , :dependent => :destroy
  belongs_to :user
  attr_accessible :choice, :primer_length, :random_primer_generated, :generator_id
  def random_generate(generator_params)
    length = primer_length
    chars = 'ATGC'
    seq = ''
    length.times { seq << chars[rand(chars.size)] }
    self.random_primer_generated = seq
    fwrd =Bio::Sequence::NA.new(self.random_primer_generated)
    self.f_primer=fwrd.upcase
    r=f_primer.reverse.upcase
    self.r_primer=r.forward_complement.upcase
    calculate_Tm(self.primer_length,self.random_primer_generated)
  end

  def specified_ATGC(no_A,no_T,no_G,no_C)
    counts = {'A'=>no_A,'T'=>no_T,'G'=>no_G,'C'=>no_C}
    self.random_primer_generated = Bio::Sequence::NA.randomize(counts).upcase
    self.primer_length = self.random_primer_generated.length

    fwrd = Bio::Sequence::NA.new(self.random_primer_generated)
    self.f_primer = fwrd.upcase
    r=f_primer.reverse.upcase
    self.r_primer=r.forward_complement.upcase
    calculate_Tm(self.primer_length,self.random_primer_generated)
  end

  def seating(user_seq)
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

    fwrd =Bio::Sequence::NA.new(self.random_primer_generated)
    self.f_primer = fwrd.upcase
    r=f_primer.reverse.upcase
    self.r_primer=r.forward_complement.upcase
    calculate_Tm(self.primer_length,self.random_primer_generated)
  end

  def calculate_Tm(primer_length,random_primer_generated)

    ct = 0.5/1000000.to_f   # concentration of oligo (mol/L)
    na = 50/1000.to_f      # concentration of Na+ (mol/L)
    fa = 0.to_f           # concentration of Formamide (mol/L)
    @@r=1.987                   # gas constant R

    random_primer_generated.upcase

    _h = {"AA" => -8.4, "TT" => -8.4, "AT" => -6.5, "TA" => -6.3,
      "CA" => -7.4, "TG" => -7.4, "GT" => -8.6, "AC" => -8.6,
      "CT" => -6.1, "AG" => -6.1, "GA" => -7.7, "TC" => -7.7,
      "CG" => -10.1, "GC" => -11.1, "GG" => -6.7, "CC" => -6.7}

    _s={"AA" => -23.6, "TT" => -23.6, "AT" => -18.8, "TA" => -18.5,
      "CA" => -19.3, "TG" => -19.3, "GT" => -23.0, "AC" => -23.0,
      "CT" => -16.1, "AG" => -20.8, "GA" => -20.3, "TC" => -20.3,
      "CG" => -25.5, "GC" => -28.4, "GG" => -15.6, "CC" => -15.6}

    tot_h=0.0
    tot_s=0.0
    for i in 0..(random_primer_generated.length-2)
      tot_h += _h[ random_primer_generated.slice(i,2) ]
      tot_s += _s[ random_primer_generated.slice(i,2) ]
    end

    tm = ((1000*tot_h)/(-10.8+tot_s+@@r*Math::log(ct/4)))-273.15+16.6*Math::log10(na)
    if  tm > 80
      # gc% method
      s = Bio::Sequence::NA.new(random_primer_generated)
      gc=s.gc_content
      tm = 81.5+16.6 * Math::log10(na) + 41*(gc)-500/primer_length-0.62*fa
    elsif tm < 20
      # wallace method
      s = Bio::Sequence::NA.new(random_primer_generated)
    gc=s.gc_content*primer_length
    at=s.at_content*primer_length
    tm = 2*(at)+4*(gc)
    else
    tm=tm
    end
    self.melting_temp = tm.round(2)
  end
end
