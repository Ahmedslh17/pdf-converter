class ConversionsController < ApplicationController
  def new
    @conversion = Conversion.new
  end

  def create
    @conversion = Conversion.new(conversion_params)

    if @conversion.save
      @conversion.convert_to_pdf!
      redirect_to @conversion, notice: "Conversion réussie !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @conversion = Conversion.find(params[:id])
  end

  private

  def conversion_params
    params.require(:conversion).permit(:image, :orientation)
  end
end