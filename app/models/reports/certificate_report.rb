class Reports::CertificateReport < Reports::BaseReport

  CERTIFICATE_BACKGROUND = 'certificate-background.jpg'

  TITLE_PREFIX = 'GSB'

  CERTIFICATION_TEXT_PREFIX = 'This is to certify that'
  CERTIFICATION_TEXT_SUFFIX = 'has sucessfully achieved the following level of Global Sustainability Assessment System (GSB) certification established by Gulf Organisation for Reasearch & Development.'

  ISSUER_NAME = 'Dr. Youssef Mohammad Alhorr'
  ISSUER_TITLE = 'Founding Chairman'
  ISSUER_LOGO = 'issuer_logo.png'

  def initialize(certification_path)
    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(:page_size => "A4",
                                    :page_layout => :landscape,
                                    :margin => 10
    )
    # Note: uncomment to use custom fonts
    # @document.font_families.update(
    #     "Cartoon" => {
    #         :normal => font_path('From Cartoon Blocks.ttf')
    #     }
    # )
    @certification_path = certification_path
    do_render
  end

  private

  def do_render
    draw_background
    # use a span, so we can center the content on the page, with a specific width so we wont touch the edges
    span(600, :position => :center) do
      move_down 80
      draw_title
      move_down 20
      draw_receiver
      move_down 10
      draw_rating
    end
    draw_footers
  end



  def draw_background
    image image_path(CERTIFICATE_BACKGROUND), :at => @document.bounds.top_left, :width => @document.bounds.width
  end



  def draw_title
    title_size = 36
    formatted_text [
                       {:text => TITLE_PREFIX,
                        :font => "Helvetica",
                        :size => title_size,
                        :styles => [],
                       },
                       {:text => " ",
                        :font => "Helvetica",
                        :size => title_size,
                       },
                       {:text => @certification_path.certificate.full_name,
                        :font => "Courier",
                        :size => title_size,
                        :styles => [:bold],
                       }
                   ],
                   :align => :center
  end

  def draw_receiver
    formatted_text [{:text => CERTIFICATION_TEXT_PREFIX,
                     :font => "Courier",
                     :size => 10,
                     :styles => [],
                    }],
                   :align => :center
    move_down 10
    formatted_text [{:text => @certification_path.project.name,
                     :font => "Courier",
                     :size => 28,
                     :styles => [:bold],
                    }],
                   :align => :center
    move_down 10
    formatted_text [{:text => CERTIFICATION_TEXT_SUFFIX,
                     :font => "Courier",
                     :size => 14,
                     :styles => [],
                    }],
                   :align => :center
  end

  def draw_rating
    if @certification_path.achieved_rating > 0
      image image_path("star_#{@certification_path.achieved_rating}.png"), :position => :center
    end
  end


  def draw_footers
    footer_height = 80
    footer_margin_side = 50
    footer_margin_bottom = 50
    bounding_box([@document.bounds.left + footer_margin_side, @document.bounds.bottom+footer_height+footer_margin_bottom], :width => @document.bounds.width - (2*footer_margin_side), :height => footer_height) do
      # divide footer into 3 equal parts
      footer_part_size = bounds.width / 3

      # Signature on the left
      bounding_box([0, bounds.top], :width => footer_part_size, :height => bounds.height) do
        formatted_text [
                           {:text => ISSUER_NAME,
                            :font => "Courier",
                            :size => 14,
                            :styles => [:bold],
                           },
                           {:text => "\n"},
                           {:text => ISSUER_TITLE,
                            :font => "Courier",
                            :size => 12,
                            :styles => [],
                           }
                       ],
                       :align => :center,
                       :valign => :bottom
      end

      # Date in the middle
      bounding_box([footer_part_size, bounds.top], :width => footer_part_size, :height => bounds.height) do
        if not @certification_path.certified_at.nil?
          text @certification_path.certified_at.to_date.to_formatted_s(:long_ordinal), :align => :center, :valign => :bottom
        end
      end

      # Logo on the right
      bounding_box([2*footer_part_size, bounds.top], :width => footer_part_size, :height => bounds.height) do
        image image_path(ISSUER_LOGO), :fit => [bounds.width, bounds.height], :position => :right, :vposition => :bottom
      end
    end
  end

end