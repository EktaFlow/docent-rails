class AssessmentsController < ApplicationController
  def index
  end

  def show
  end

  def create
    @assessment = Assessment.new(assessment_params)
    # @assessment.currentMRL = params[:target_mrl]
    if @assessment.save?
      @schema = get_schema(params[:schema_file], params[:threads])
    else
      
    end


  end

  def destroy
  end

  private

  def assessment_params
  end
end
