
class Reports::CriteriaScores < Reports::BaseReport
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper

  MAIN_COLOR = '62A744'.freeze
  COLUMN_1_COLOR = 'ecf1e5'.freeze
  COLUMN_2_COLOR = 'dddcde'.freeze
  TABLE_TEXT_COLOR = '465059'.freeze
  TABLE_BORDER_COLOR = 'a8abb0'.freeze

  HEADER_HEIGHT = 60
  FOOTER_HEIGHT = 70
  CONTENT_PADDING = 20
  # CONTENT_PADDING = 150

  SIGNATURE_CLOSING = 'Yours sincerely,'.freeze
  ISSUER_NAME = 'Dr. Yousef Al Horr'.freeze
  ISSUER_TITLE = 'Founding Chairman'.freeze
  HEADER_IMAGE = 'report_header_image.png'.freeze
  HEADER_LOGO = 'gord_logo.jpg'.freeze
  FOOTER_IMAGE = 'report_footer_image.png'.freeze
  GSB_LOGO = 'gsb_logo.jpg'.freeze
  LOC_LOGO = 'gsb_logo.jpg'.freeze

  TEXT_COLOR = 'ffffff'.freeze
  MAIN_COLOR = '62A744'.freeze
  BACKGROUND_COLOR = 'EEEEEE'.freeze
  FOOTER_LOGO = 'gord_logo_black.jpg'.freeze
  STAR_ICON = 'green_star.png'.freeze
  FOOTER_URL = "<link href='http://www.gord.qa'>www.gord.qa</link>".freeze
  MAX_ROWS_PER_PAGE = 24
  PAGE_MARGIN = 50

  def initialize(scheme_mix)
    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(page_size: 'A4',
    page_layout: :portrait,
    margin: 40)

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

    bounding_box([@document.bounds.left, @document.bounds.top - 80], width: @document.bounds.width) do
      draw_certificate_header
    end
    draw_headers

    bounding_box([0, 630], width: @document.bounds.width) do
      # Draw awarded target
      # draw_awarded_target

      # Draw all category/criteria tables
      rows_on_page = 0
      categories_with_criteria.each do |category_with_criteria|
        row_count = category_with_criteria[:criteria].count + 2 # Add 2 extra rows for table header and margin

        if (rows_on_page + row_count) > MAX_ROWS_PER_PAGE
          start_new_page
          draw_project_info
          newline(2)
          rows_on_page = row_count
        else
          rows_on_page += row_count
        end

        draw_criteria_table(category_with_criteria[:category], category_with_criteria[:criteria])
        newline
      end
    end
    newline(2)
    draw_footers
  end

  def draw_headers
    repeat(:all) do
      bounding_box([@document.bounds.left - 30, @document.bounds.top + 15], width: 580, height: HEADER_HEIGHT) do
        image image_path(HEADER_IMAGE), width: 580
      end
    
      newline
      bounding_box([@document.bounds.right - 105, @document.bounds.top - 45], width: 100, height: HEADER_HEIGHT) do
        text = "Issued Date: #{DateTime.current.to_date}\n"
        text2 = "Ref: LOC/QA 2532-2343-RU"

        styled_text("<div style='font-size: 8; text-align: right'>#{text}<br />#{text2}</div>")
      end
      # bounding_box([@document.bounds.right - 50, @document.bounds.bottom + 100], width: 50, height: HEADER_HEIGHT) do
      #   image image_path(GSB_LOGO), width: 50
      # end
    end
  end

  def draw_certificate_header
    text = "#{@certification_path.name} Criteria Summary"
    text2 = @scheme_mix.scheme.full_name
    text3 = "#{@certification_path.project.name}"

    styled_text("<div style='font-size: 12; text-align: center; color: #{MAIN_COLOR}'>#{text}<br />#{text2}<br />#{text3}</div>")
  end

  def draw_footers
    repeat(:all) do
      bounding_box([@document.bounds.left - 30, @document.bounds.bottom + 30], width: 580, height: FOOTER_HEIGHT) do
        image image_path(FOOTER_IMAGE), width: 580
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
    data.append([{content: "#{scheme_category.name.upcase} [#{scheme_category.code}]", rowspan: scheme_mix_criteria.size + 1}, 'Criterion', 'Level', 'Achieved', 'Remarks'])

    # Add the category rows to the table
    scheme_mix_criteria.each do |smc|
      data.append([smc.full_name, number_with_precision(smc.achieved_score, precision: 0, significant: true), number_with_precision(smc.achieved_score, precision: 0, significant: true), t(smc.status, scope: 'activerecord.attributes.scheme_mix_criterion.statuses')])
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

        column(0).width = width * 0.20
        column(1).width = width * 0.35
        column(2).width = width * 0.10
        column(3).width = width * 0.10
        column(4).width = width * 0.25
  

        # Misc table border style
        row(0).border_top_color = '000000'
        row(-1).border_bottom_color = '000000'
        column(-1).borders = [:top, :bottom, :left]
        column(1).borders = [:top, :right, :bottom]

        # Category name column style
        name_column = column(0)
        name_column.align = :right
        name_column.text_color = TABLE_TEXT_COLOR
        name_column.borders = [:top, :right, :bottom]
        name_column.border_color = TABLE_BORDER_COLOR
        # name_column.border_color = MAIN_COLOR
        # name_column.font_style = :bold
        name_column.background_color = COLUMN_1_COLOR

        # Odd/even row style
        rows(1..-1).style do |c|
          c.background_color = 'EAEAEA' if (c.row % 2).zero?
          c.border_color = COLUMN_2_COLOR
        end

        # Header row style
        header_row = row(0).columns(1..-1)
        header_row.background_color = COLUMN_1_COLOR
        header_row.text_color = TABLE_TEXT_COLOR
        header_row.border_color = TABLE_BORDER_COLOR

        # Criteria name column style
        column(1).align = :left
      end
    end
  end

  def categories_with_criteria
    categories_with_criteria = []
    @scheme_mix.scheme_categories.each do |scheme_category|
      
      category_scheme_mix_criteria = @scheme_mix.category_scheme_mix_criteria(scheme_category&.id)

      if category_scheme_mix_criteria.count > 0
        categories_with_criteria << { category: scheme_category, criteria: @scheme_mix.scheme_mix_criteria.for_category(scheme_category).order('scheme_criteria.number').to_a }
      end
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