class FileAttachmentsController < ApplicationController
  #this needs new file info, assessment id and question id in params
  #this should be an axios.post() call
  def create
    @assessment = Assessment.find(params[:assessment_id])
    @c_question = Question.find(params[:question_id])
    @file_attachment = FileAttachment.create(assessment: @assessment, file_name: params[:file_name])
    if @file_attachment.save
      @file_attachment.outside_file.attach(params[:file_obj])
      @faa = FileAttachmentAnswer.create(file_attachment: @file_attachment, question: @c_question)
      render json: {file: @file_attachment, question: @c_question}
    else
      render json: {errors: @file_attachment.errors.full_messages}
    end
  end


  #this needs file id, question id
  #should be an axios.post() call
  def add_to_question
    @file_attachment = FileAttachment.find(params[:file_id])
    if @file_attachment
      @question = Question.find(params[:question_id])
      if @question
        @faa = FileAttachmentAnswer.create(file_attachment: @file_attachment, question: @question)
        render json: {file: @file_attachment, question: @question}
      else
        render json: {errors: 'question not found'}
      end
    else
      render json: {errors: 'File Not Found'}
    end
  end
end
