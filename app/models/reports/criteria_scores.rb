class Reports::CriteriaScores < Reports::BaseReport

  MAIN_COLOR = '62A744'
  BACKGROUND_COLOR = 'EEEEEE'
  HEADER_LOGO = 'gsas_logo.png'
  FOOTER_LOGO = 'gord_logo.png'
  FOOTER_URL = "<link href='http://www.gord.qa'>www.gord.qa</link>"

  def initialize(certification_path)
    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(:page_size => "A4",
                                    :page_layout => :portrait,
                                    :margin => 20
    )
    @certification_path = certification_path
    do_render
  end

  private

  def do_render
    font "Times-Roman", :size => 11

    draw_score_tables

    5.times do
      start_new_page
      draw_text "A wonderful page", :at => [400, 400]
    end

    draw_headers
    draw_footers
  end

  def draw_headers
    repeat(:all) do
      # Certificate Information
      bounding_box(@document.bounds.top_left, :width => 200) do
        text "LOC Criteria Scores", :size => 19, :color => MAIN_COLOR
        text "Typology GSAS v2.1", :size => 19, :color => MAIN_COLOR
        text @certification_path.project.name, :size => 17, :color => MAIN_COLOR
      end

      # Logo
      logo_size = 80
      bounding_box([@document.bounds.right-logo_size, @document.bounds.top], :width => logo_size) do
        image image_path(HEADER_LOGO), :width => logo_size
      end

      # Project information
      bounding_box([@document.bounds.left, @document.bounds.top-100], :width => @document.bounds.width) do
        table(
            [[
                 "<color rgb='#{MAIN_COLOR}'>Ref:</color> #{@certification_path.project.code}",
                 "<color rgb='#{MAIN_COLOR}'>Date:</color> #{@certification_path.certified_at if @certification_path.certified_at.present?}",
                 "<color rgb='#{MAIN_COLOR}'>Project ID:</color> #{@certification_path.project.code}"
             ]],
            :width => @document.bounds.width,
            :cell_style => {
                :background_color => BACKGROUND_COLOR,
                :size => 10,
                :inline_format => true
            }
        )
      end
    end

    repeat([1]) do
      bounding_box([@document.bounds.left, @document.bounds.top-130], :width => @document.bounds.width) do
        table(
            [[
                 "Achieved Target",
                 "#{@certification_path.achieved_star_rating} Star(s)"
             ]],
            :width => @document.bounds.width,
            :cell_style => {
                :text_color => MAIN_COLOR,
                :background_color => BACKGROUND_COLOR,
                :size => 16,
                :inline_format => true
            }
        )
      end
    end
  end

  def draw_footers
    footer_height = 40
    repeat(:all) do
      stroke_color MAIN_COLOR
      self.line_width = 4
      stroke_horizontal_line @document.bounds.left, @document.bounds.right, :at => @document.bounds.bottom+footer_height+self.line_width

      bounding_box([@document.bounds.left, @document.bounds.bottom+footer_height], :width => @document.bounds.width) do
        text FOOTER_URL, :inline_format => true, :size => 8, :valign => :center
      end

      logo_width = 100
      bounding_box([@document.bounds.right-logo_width, @document.bounds.bottom+footer_height], :width => @document.bounds.width) do
        image image_path(FOOTER_LOGO), :width => logo_width
      end

      self.line_width = 1
      canvas do
        stroke_horizontal_line bounds.left, bounds.right, :at => (@document.margin_box.absolute_bottom + self.line_width)
      end
    end

    bounding_box([@document.bounds.left, @document.bounds.bottom+footer_height], :width => @document.bounds.width) do
      number_pages "<page> / <total>", {:align => :center, :size => 9, :valign => :center}
    end
  end

  def draw_score_tables
    # # prepare data
    # data = []
    # data.append(['Code', 'Category', 'Point'])
    # @categories.each do |category|
    #   data.append([category.code, category.name, category.score])
    # end
    #
    # #hard coded test data
    # data.append(['W', 'Water', 0.15])
    # data.append(['E', 'Enery', 0.62])
    #
    # # render table
    # table(data) do
    #   rows(0).background_color = '4A452A'
    #   rows(1..row_length-3).columns(2).background_color = '8DB4E3'
    #   rows(row_length-2).border_widths = [2, 1, 1, 1]
    # end
  end

end