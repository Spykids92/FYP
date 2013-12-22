class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :update, :destroy]
  # GET /results
  # GET /results.json
  def index
    @results=Result.order("id DESC")
  end 

  # GET /results/new
  def new
    @result=Result.new
  end

  # POST /results :url=> generator_results_path(@generator)
  # POST /results.json TGATGAACATCATGATGAGGTGATGACATCACATCATTGACTGATGCATCATGATG
  def create    
    @generator = Generator.find(params[:generator_id])
    @result = @generator.build_result(params[:result])
    @result.generate_result(result_params)
    @generator.save
    redirect_to generators_path
  end

  def show
    @result = Result.find(params[:id])
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
      params.require(:result).permit(:ncbi_ref_seq,:genome_seq,:genome_sample,:binding_times,:amp_frags,:seqpos1,:seqpos2)
    end
end
