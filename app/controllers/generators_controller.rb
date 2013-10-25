class GeneratorsController < ApplicationController
  before_action :set_generator, only: [:show, :edit, :update, :destroy]
  # GET /generators
  # GET /generators.json
  def index
    @generators = Generator.order("created_at DESC")
  end

  # GET /generators/1
  # GET /generators/1.json
  def show
  end

  # GET /generators/new
  def new
    @generator = Generator.new 
  end

  # GET /generators/1/edit
  def edit
  end

  # POST /generators
  # POST /generators.json
  def create    
    @generator = Generator.new(generator_params)
    @generator.choice = params[:choice]
      if params[:choice] == 'Randomly'
          @generator.random_generate(generator_params)
      elsif params[:choice] == 'Specified ATGC'
          @generator.specified_ATGC(params[:no_A],params[:no_T],params[:no_G],params[:no_C])
      elsif params[:choice] == 'Seating'
          @generator.seating(params[:user_seq])
      end
      
    @generator.result_choice=params[:result_choice]
    @generator.save
    respond_to do |format|
       if @generator.result_choice == 'Yes'
              format.html { redirect_to(generator_path(@generator)) }
       else
              format.html { redirect_to generators_path}
              format.json { render action: 'show', status: :created, location: @generator }
       end
     end 
    
  end

  # PATCH/PUT /generators/1
  # PATCH/PUT /generators/1.json
  def update
    respond_to do |format|
      if @generator.update(generator_params)
        format.html { redirect_to @generator, notice: 'Generator was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generators/1
  # DELETE /generators/1.json
  def destroy
    @generator.destroy
    respond_to do |format|
      format.html { redirect_to generators_url }
      format.json { head :no_content }
    end
  end
  
  private
    def set_generator
      @generator = Generator.find(params[:id])
    end

    def generator_params
      params.require(:generator).permit(:primer_length,:choice,:random_primer_generated,:no_A,:no_T,:no_G,:no_C,:user_seq)
    end
end
