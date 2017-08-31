class Reports::CriteriaScores < Reports::BaseReport
  include ActionView::Helpers::NumberHelper

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
    @score = @scheme_mix.scores_in_certificate_points[:achieved_score_in_certificate_points]
    @stars = CertificationPath.star_rating_for_score(@score, certificate: @certification_path.certificate).to_s +
        ' ' + 'Star'.pluralize(CertificationPath.star_rating_for_score(@score, certificate: @certification_path.certificate))
    do_render
  end

  private

  def do_render
    font 'Times-Roman', size: 11

    draw_headers

    bounding_box([0, 560], width: @document.bounds.width) do
      # Draw awarded target
      draw_awarded_target
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

        draw_criteria_table(category_with_criteria[:category], category_with_criteria[:criteria])
        newline
      end
    end

    draw_footers
  end

  def draw_headers
    canvas do
      repeat(:all) do
        # Certificate Information
        bounding_box([PAGE_MARGIN, 800], width: 400) do
          text "#{@certification_path.name} Criteria Summary", size: 20, color: MAIN_COLOR
          text @scheme_mix.scheme.full_name, size: 20, color: MAIN_COLOR
          text "#{@certification_path.project.name}: #{@scheme_mix.name}", size: 16, color: MAIN_COLOR
        end

        # Logo
        logo_width = 80
        bounding_box([@document.bounds.width - logo_width - PAGE_MARGIN, 800], width: logo_width) do
          image image_path(HEADER_LOGO), height: logo_width
        end

        # Project information
        bounding_box([PAGE_MARGIN, 720], width: @document.bounds.width - (PAGE_MARGIN * 2)) do
          newline
          table(
              [[
                   "<color rgb='#{MAIN_COLOR}'>Ref:</color> #{@certification_path.project.code}",
                   "<color rgb='#{MAIN_COLOR}'>Date:</color> #{@certification_path.certified_at.strftime('%B %d, %Y') if @certification_path.certified_at.present?}",
                   "<color rgb='#{MAIN_COLOR}'>Project ID:</color> #{@certification_path.project.code}"
               ]],
              width: @document.bounds.width,
              cell_style: {
                  background_color: 'EAEAEA',
                  border_color: 'BABABB',
                  size: 10,
                  font_style: :bold,
                  inline_format: true
              }
          )
        end
      end
    end
  end

  def draw_footers
    canvas do
      repeat(:all) do
        # Thick line
        stroke_color MAIN_COLOR
        self.line_width = 6
        stroke_horizontal_line @document.bounds.left + PAGE_MARGIN, @document.bounds.right - PAGE_MARGIN, at: 100

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
             'Awarded Target',
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
    data.append([{content: "#{scheme_category.name.upcase} [#{scheme_category.code}]", rowspan: scheme_mix_criteria.size + 1}, 'Criterion', 'Targeted Score', 'Achieved Score', 'Comments'])

    # Add the category rows to the table
    scheme_mix_criteria.each do |smc|
      data.append([smc.full_name, number_with_precision(smc.targeted_score, precision: 0, significant: true), number_with_precision(smc.achieved_score, precision: 0, significant: true), smc.status.humanize])
    end

    # Output table
    draw_table(data)
  end

  def draw_table(data)
    table(data, width: @document.bounds.right) do
      # Set default cell style
      cells.align = :center
      cells.borders = [:top, :right, :bottom, :left]
      cells.padding = 4
      cells.border_width = 0.5
      cells.border_color = 'BABABB'

      # Set column widths
      column(0).width = width * 0.20
      column(1).width = width * 0.35
      column(2).width = width * 0.10
      column(3).width = width * 0.10
      column(4).width = width * 0.25

      # Misc table border style
      row(0).border_top_color = MAIN_COLOR
      row(-1).border_bottom_color = MAIN_COLOR
      column(-1).borders = [:top, :bottom, :left]
      column(1).borders = [:top, :right, :bottom]

      # Category name column style
      name_column = column(0)
      name_column.align = :right
      name_column.text_color = MAIN_COLOR
      name_column.borders = [:top, :right, :bottom]
      name_column.border_color = MAIN_COLOR
      name_column.font_style = :bold

      # Odd/even row style
      rows(1..-1).style do |c|
        c.background_color = 'EAEAEA' if (c.row % 2).zero?
      end

      # Header row style
      header_row = row(0).columns(1..-1)
      header_row.background_color = 'CBCBCB'

      # Criteria name column style
      column(1).align = :left
    end
  end

  def categories_with_criteria
    categories_with_criteria = []
    @scheme_mix.scheme_categories.each do |scheme_category|
      categories_with_criteria << { category: scheme_category, criteria: @scheme_mix.scheme_mix_criteria.for_category(scheme_category).order('scheme_criteria.number').to_a }
    end

    # Order the array by criteria count
    categories_with_criteria.sort! {|x, y| y[:criteria].count <=> x[:criteria].count}
  end
end
