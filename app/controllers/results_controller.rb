class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :update, :destroy]
  # GET /results
  # GET /results.json
  def index
    @results = Result.all
  end

  # GET /results/new
  def new
  end

  # GET /results/1/edit

  # POST /results
  # POST /results.json
  def create
    @generator = Generator.find(params[:generator_id])
    #@result = @generator.result.create_result(result_params)
    @result = @generator.build_result(result_params)
    @result=@result.generate_result(result_params)
    @generator.result.save
    redirect_to generators_path
  end

  # PATCH/PUT /results/1
  # PATCH/PUT /results/1.json
  def update
    respond_to do |format|
      if @result.update(result_params)
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @generator= Generator.find(params[:generator_id])
    @result= @generator.results.find(params[:id])
    @result.destroy
    redirect_to generator_path(@generator)
  end
    
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_result
      @result = Result.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def result_params
      params.require(:result).permit(:ncbi_ref_seq,:genome_seq,:genome_sample,:binding_times)
    end
end
