class Conversion < ApplicationRecord
  has_one_attached :image
  has_one_attached :pdf_file

  attr_accessor :orientation
  validates :image, presence: true

  def convert_to_pdf!
    return unless image.attached?

    image.open do |file|
      content_type = image.content_type

      # Cas 1 : Si c'est une image (JPEG, PNG, WEBP)
      if content_type.start_with?('image/') && ['image/jpeg', 'image/png', 'image/webp'].include?(content_type)
        case orientation
        when "landscape"
          pdf = Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: 0)
          pdf.image file.path, fit: [pdf.bounds.width, pdf.bounds.height], position: :center, vposition: :center
        when "fit"
          image.analyze unless image.analyzed?
          w = image.metadata[:width] || 800
          h = image.metadata[:height] || 600
          pdf = Prawn::Document.new(page_size: [w, h], margin: 0)
          pdf.image file.path, at: [0, h], width: w, height: h
        else # "portrait" par défaut
          pdf = Prawn::Document.new(page_size: "A4", margin: 20)
          pdf.image file.path, fit: [pdf.bounds.width, pdf.bounds.height], position: :center, vposition: :center
        end
      else
        # Cas 2 : Si c'est un fichier texte, .dat, .txt, etc.
        raw_text = File.read(file.path, encoding: 'BINARY')
        
        # Encodage sécurisé pour Prawn
        safe_text = raw_text.encode('Windows-1252', invalid: :replace, undef: :replace, replace: '?')
        safe_filename = image.filename.to_s.encode('Windows-1252', invalid: :replace, undef: :replace, replace: '?')

        pdf = Prawn::Document.new(page_size: "A4", margin: 40)
        pdf.text "Fichier converti : #{safe_filename}", size: 16, style: :bold
        pdf.move_down 15
        pdf.text safe_text, size: 10, leading: 4
      end

      pdf_data = pdf.render

      # Attachement direct du PDF
      pdf_file.attach(
        io: StringIO.new(pdf_data),
        filename: "#{image.filename.base}.pdf",
        content_type: "application/pdf"
      )
    end
  end
end