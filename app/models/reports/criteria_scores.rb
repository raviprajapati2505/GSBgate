
class Reports::CriteriaScores < Reports::BaseReport
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper
  
  HEADER_HEIGHT = 70
  FOOTER_HEIGHT = 20
  CONTENT_PADDING = 20
  # CONTENT_PADDING = 150

  SIGNATURE_CLOSING = 'Yours sincerely,'.freeze
  ISSUER_NAME = 'Dr. Yousef Al Horr'.freeze
  ISSUER_TITLE = 'Founding Chairman'.freeze
  HEADER_LOGO = 'gord_logo.jpg'.freeze
  GSAS_LOGO = 'gsas_logo.jpg'.freeze
  LOC_LOGO = 'gsas_logo.jpg'.freeze

  TEXT_COLOR = 'ffffff'.freeze
  MAIN_COLOR = '62A744'.freeze
  BACKGROUND_COLOR = 'EEEEEE'.freeze
  HEADER_LOGO = 'gsas_logo.jpg'.freeze
  FOOTER_LOGO = 'gord_logo_black.jpg'.freeze
  STAR_ICON = 'green_star.png'.freeze
  FOOTER_URL = "<link href='http://www.gord.qa'>www.gord.qa</link>".freeze
  MAX_ROWS_PER_PAGE = 24
  PAGE_MARGIN = 50

  def initialize(scheme_mix)
    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(page_size: 'A4',
                                    page_layout: :portrait,
                                    margin: [170, PAGE_MARGIN, 110, PAGE_MARGIN])
    @scheme_mix = scheme_mix
    @certification_path = @scheme_mix.certification_path
    @score = @scheme_mix.scores_in_scheme_points[:achieved_score_in_scheme_points]
    @stars = @certification_path.rating_for_score(@score, certificate: @certification_path.certificate).to_s +
        ' ' + 'Star'.pluralize(@certification_path.rating_for_score(@score, certificate: @certification_path.certificate))
    do_render
  end

  private

  def do_render
    font 'Times-Roman', size: 11

    draw_headers

    bounding_box([0, 560], width: @document.bounds.width) do
      # Draw awarded target
      # draw_awarded_target
      newline


      # Draw all category/criteria tables
      rows_on_page = 0
      categories_with_criteria.each do |category_with_criteria|
        row_count = category_with_criteria[:criteria].count + 2 # Add 2 extra rows for table header and margin

        if (rows_on_page + row_count) > MAX_ROWS_PER_PAGE
          start_new_page
          rows_on_page = row_count
        else
          rows_on_page += row_count
        end

        newline
        draw_criteria_table(category_with_criteria[:category], category_with_criteria[:criteria])
        newline
      end
    end

    draw_footers
  end

  # def draw_headers
  #   canvas do
  #     repeat(:all) do
  #       # Certificate Information
  #       bounding_box([PAGE_MARGIN, 800], width: 400) do
  #         text "#{@certification_path.name} Criteria Summary", size: 20, color: MAIN_COLOR
  #         text @scheme_mix.scheme.full_name, size: 20, color: MAIN_COLOR
  #         text "#{@certification_path.project.name}", size: 16, color: MAIN_COLOR
  #       end

  #       # Logo
  #       logo_width = 80
  #       bounding_box([@document.bounds.width - logo_width - PAGE_MARGIN, 800], width: logo_width) do
  #         image image_path(HEADER_LOGO), height: logo_width
  #       end

  #       # Project information
  #       bounding_box([PAGE_MARGIN, 720], width: @document.bounds.width - (PAGE_MARGIN * 2)) do
  #         newline
  #         # table(
  #         #     [[
  #         #          "<color rgb='#{MAIN_COLOR}'>Date:</color> #{@certification_path.certified_at.strftime('%B %d, %Y') if @certification_path.certified_at.present?}",
  #         #          "<color rgb='#{MAIN_COLOR}'>Project ID:</color> #{@certification_path.project.code}"
  #         #      ]],
  #         #     width: @document.bounds.width,
  #         #     cell_style: {
  #         #         background_color: 'EAEAEA',
  #         #         border_color: 'BABABB',
  #         #         size: 10,
  #         #         font_style: :bold,
  #         #         inline_format: true
  #         #     }
  #         # )
  #         draw_project_info
  #       end
  #     end
  #   end
  # end

  def draw_headers
    repeat(:all) do
      bounding_box([@document.bounds.left, @document.bounds.top], width: 120, height: HEADER_HEIGHT) do
        image image_path(HEADER_LOGO), width: 120
      end
      bounding_box([@document.bounds.right - 50, @document.bounds.top], width: 60, height: HEADER_HEIGHT) do
        image image_path(GSAS_LOGO), width: 60
      end
      newline
      bounding_box([@document.bounds.right - 90, @document.bounds.top - 60], width: 100, height: HEADER_HEIGHT) do
        text = "Issued Date: #{DateTime.current.to_date}\n"
        text2 = "Ref: LOC/QA 2532-2343-RU"

        styled_text("<div style='font-size: 8; text-align: right'>#{text}<br />#{text2}</div>")
      end
      bounding_box([@document.bounds.right - 380, @document.bounds.bottom + 20], width: 120, height: HEADER_HEIGHT) do
        text = "Qatar Science & Technology Park | Tech 1 | Level 2 \n"
        text2 = "Suite 203 | P.O. Box: 210162| Doha - Qatar \n"
        text3 = "T: +974 4404 9010 F: +974 4404 9002"

        styled_text("<div style='font-size: 7; text-align: right'>#{text}#{text2}#{text3}</div>")
       
        stroke do
          # vertical_line 50, 100, at: [125, 125]
          vertical_line 30, 80, at: 125
          move_down 50
        end
      end
      bounding_box([@document.bounds.right - 250, @document.bounds.bottom + 20], width: 120, height: HEADER_HEIGHT) do
        # text = "واحة قطر للعلوم والتكنولوجيا | تك 1 | المستوي 2 \n"
        # text2 = "جناح 203 | ص. صندوق: 210162 | الدوحة قطر \n"
        # text3 = "هاتف: +974 4404 9010 فاكس: +974 4404 9002"

        text = "Qatar Science & Technology Park | Tech 1 | Level 2 \n"
        text2 = "Suite 203 | P.O. Box: 210162| Doha - Qatar \n"
        text3 = "T: +974 4404 9010 F: +974 4404 9002"

        styled_text("<div style='font-size: 7; text-align: left'>#{text}#{text2}#{text3}</div>")
      end
      bounding_box([@document.bounds.right - 50, @document.bounds.bottom + 100], width: 50, height: HEADER_HEIGHT) do
        image image_path(GSAS_LOGO), width: 50
      end
    end
  end

  def draw_footers
    canvas do
      repeat(:all) do
        # Thick line
        # stroke_color MAIN_COLOR
        # self.line_width = 6
        # stroke_horizontal_line @document.bounds.left + PAGE_MARGIN, @document.bounds.right - PAGE_MARGIN, at: 100

        # URL
        bounding_box([PAGE_MARGIN, 70], width: 50, height: 10) do
          text FOOTER_URL, inline_format: true, size: 9
        end

        # Logo
        logo_width = 70
        bounding_box([@document.bounds.right - logo_width - PAGE_MARGIN, 80], width: logo_width, height: logo_width) do
          image image_path(FOOTER_LOGO), width: logo_width
        end

        # Thin line
        self.line_width = 1
        stroke_horizontal_line bounds.left, bounds.right, at: 30
      end

      # Page number
      bounding_box([270, 70], width: 50) do
        number_pages '<page> / <total>', align: :center, size: 9
      end
    end
  end

  def draw_awarded_target
    table(
        [[
             'Awarded',
             @stars
         ]],
        width: @document.bounds.width,
        cell_style: {
            text_color: MAIN_COLOR,
            align: :center,
            font_style: :bold,
            background_color: 'EAEAEA',
            border_color: MAIN_COLOR,
            size: 16,
            inline_format: true
        }
    ) do
      column(0).borders = [:top, :right, :bottom]
      column(1).borders = [:top, :bottom, :left]
    end
  end

  def draw_criteria_table(scheme_category, scheme_mix_criteria)
    # Prepare table data
    data = []
    data.append([{content: "#{scheme_category.name.upcase} [#{scheme_category.code}]", rowspan: scheme_mix_criteria.size + 1}, 'Criterion', 'Level', 'Remarks'])

    # Add the category rows to the table
    scheme_mix_criteria.each do |smc|
      data.append([smc.full_name, number_with_precision(smc.achieved_score, precision: 0, significant: true), t(smc.status, scope: 'activerecord.attributes.scheme_mix_criterion.statuses')])
    end

    # Output table
    draw_table(data, '')
  end

  def draw_table(data, type)
    table(data, width: @document.bounds.right) do

      if type == 'project_info_table'
        # Set default cell style
        cells.align = :left
        cells.borders = []
        cells.padding = 0
        cells.border_width = 0.5

        header_row = rows(0..row_length - 1)

        data[1][0] = { content: data[1][0], colspan: 2 } 

        # Set column widths
        header_row.row(0).column(0).width = width / 3
        header_row.row(0).column(1).width = width / 3
        header_row.row(0).column(2).width = width / 3
        # header_row.row(1).column(0).width = width - (width / 3)
        # header_row.row(1).column(1).width = width / 3

        cells.borders = %i(top bottom left)

        header_row.background_color = 'F5F5F5'
        header_row.align = :center
        header_row.column(0).border_left_color = 'FFFFFF'
        header_row.padding = [2, 2, 2]
      else
        # Set default cell style
        cells.align = :center
        cells.borders = [:top, :right, :bottom, :left]
        cells.padding = 4
        cells.border_width = 0.5
        cells.border_color = 'BABABB'

        cells.border_left_color = '000000'
        cells.border_right_color = '000000'
        cells.border_top_color = '000000'
        cells.border_bottom_color = '000000'

        # Set column widths
        column(0).width = width * 0.21
        column(1).width = width * 0.37
        column(2).width = width * 0.16
        column(3).width = width * 0.26
        # column(4).width = width * 0.25

        # Misc table border style
        row(0).border_top_color = '000000'
        row(-1).border_bottom_color = '000000'
        column(-1).borders = [:top, :bottom, :left]
        column(1).borders = [:top, :right, :bottom]

        # Category name column style
        name_column = column(0)
        name_column.align = :right
        name_column.text_color = TEXT_COLOR
        name_column.borders = [:top, :right, :bottom]
        # name_column.border_color = MAIN_COLOR
        name_column.font_style = :bold
        name_column.background_color = MAIN_COLOR

        # Odd/even row style
        rows(1..-1).style do |c|
          c.background_color = 'EAEAEA' if (c.row % 2).zero?
        end

        # Header row style
        header_row = row(0).columns(1..-1)
        header_row.background_color = MAIN_COLOR
        header_row.text_color = TEXT_COLOR

        # Criteria name column style
        column(1).align = :left
      end
    end
  end

  def categories_with_criteria
    categories_with_criteria = []
    @scheme_mix.scheme_categories.each do |scheme_category|
      categories_with_criteria << { category: scheme_category, criteria: @scheme_mix.scheme_mix_criteria.for_category(scheme_category).order('scheme_criteria.number').to_a }
    end

    # Order the array by criteria count
    # categories_with_criteria.sort! {|x, y| y[:criteria].count <=> x[:criteria].count}

    # Order the array by category display weight
    categories_with_criteria.sort_by {|value| value[:category].display_weight }
  end

  def draw_project_info
    # Prepare table data
    data = []
    # Add the category rows to the table
    data.append(["Project ID: #{@certification_path.project.code}", "Provisional Rating: #{@stars}", "Approval Date: 14th Nov, 2020"])

    # Add footer to the table
    data.append([{content: "Project Name: #{@certification_path.project.name}", colspan: 2}, "Reference: LOC-KNNAN-239409"])

    # Output table
    draw_table(data, 'project_info_table')
  end
end