class Reports::DetailedCertificateReport < Reports::BaseReport
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ReportsHelper
  include ActionView::Helpers::TranslationHelper

  COLUMN_2_COLOR = 'D9D9D9'.freeze
  TABLE_TEXT_COLOR = '323e48'.freeze
  TABLE_BORDER_COLOR = 'a8abb0'.freeze

  HEADER_HEIGHT = 60
  FOOTER_HEIGHT = 70
  CONTENT_PADDING = 20

  HEADER_IMAGE = 'gsb_loc_header.png'.freeze
  FOOTER_IMAGE = 'gsb_loc_footer.png'.freeze
  GSB_LOGO = 'gsb_logo.jpg'.freeze

  TEXT_COLOR = 'ffffff'.freeze
  BACKGROUND_COLOR = 'EEEEEE'.freeze

  def initialize(certification_path)
    self.font_families.update(
      "CenturyGothic" => {
        normal: font_path('centurygothic.ttf')
      }
    )
    
    font 'CenturyGothic', size: 10

    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(page_size: 'A4',
                                    page_layout: :portrait,
                                    margin: 40)

    @certification_path = certification_path
    @project = @certification_path.project
    @detailed_certificate_report = @certification_path.certification_path_report
    @scheme_mixes = certification_path&.scheme_mixes
    @scheme_names = @certification_path.schemes.collect(&:name)

    set_format_colors(@project)
    do_render
  end

  private

  def set_format_colors(_project)
    @@main_color = '#0070b3'.freeze
    @@column_1_color = 'DCEBF9'.freeze
    @@stamp_image = 'gsb_loc_stamp.png'.freeze
  end

  def do_render
    draw_headers

    total_category_scores = {}
    @certification_path.scheme_mixes.each do |scheme_mix|
      # Fetch all scheme mix criteria score records
      scheme_mix_criteria_scores = scheme_mix.scheme_mix_criteria_scores

      # Group the scores by category
      scheme_mix_criteria_scores_by_category = scheme_mix_criteria_scores.group_by { |item| item[:scheme_category_id] }

      scheme_mix.scheme_categories.each do |category|
        next unless scheme_mix_criteria_scores_by_category[category.id]

        total_category_scores[category.code] = { name: category.name, achieved_score: 0, maximum_score: 0 } unless total_category_scores.key?(category.code)
        category_scores = sum_score_hashes(scheme_mix_criteria_scores_by_category[category.id])
        total_category_scores[category.code][:achieved_score] += category_scores[:achieved_score_in_certificate_points]
        total_category_scores[category.code][:maximum_score] += category_scores[:maximum_score_in_certificate_points]
      end
    end

    draw_page do
      newline(1)
      draw_certificate_header
      newline(1)
      draw_certificate_info_table
      newline(1)
      draw_paragraph1
    end

    draw_footers
  end

  def draw_certificate_header
    text = certification_type_name(@certification_path)
    styled_text("<div style='font-size: 12; line-height: 1.2'>GSB #{text[:project_type]}</div><br /><div style='font-size: 14; font-style: bold; color: #{@@main_color};'>DESIGN CERTIFICATE _ LETTER OF CONFORMANCE (LOC)</div>")
  end

  def draw_certificate_info_table
    # Prepare table data
    data = []

    # Add the category rows to the table
    data.append(["To", @detailed_certificate_report&.to])
    data.append(["Project ID", @project.code])
    data.append(["Project Name", @detailed_certificate_report&.project_name])
    data.append(["Project Location", @detailed_certificate_report&.project_location])
    data.append(["GSB Corporate", @project.corporate])
    data.append(["GSB Certificate", @certification_path.certificate&.report_certification_name])

    case @certification_path.certificate&.name
    when 'Stage 1: Foundation'
        data.append(["GSB Certification Stage", 'Enabling Foundation Works'])
    when 'Stage 2: Substructure & Superstructure'
        data.append(["GSB Certification Stage", 'Stage 2: Substructure & Superstructure Works'])
    when 'Stage 3: Finishing'
        data.append(["GSB Certification Stage", 'Stage 3: Finishing Works'])
    else
        data.append(["GSB Certification Stage", @certification_path.certificate&.name])
    end
    
    data.append(["GSB Version", "GSB #{@certification_path.certificate&.only_version}"])

    # Output table
    draw_table(data, 'basic_table')
  end

  def draw_paragraph1
    newline(1)
    styled_text("<div style='font-size: 10;text-align: justify; line-height: 7;'>Dear Sir/Madam,</div>")
    newline(1)
    styled_text("<div style='font-size: 10;text-align: justify; line-height: 7'>This is to notify that GSB has assessed the project based on the submitted information. The project is found eligible to receive the provisional compliance. <span style='font-style: bold'>Final compliance is subject to successful site audit.</span></div>")
    newline(1)
    styled_text("<div style='font-size: 10;text-align: justify; line-height: 7'>In the event of any future changes applied to the information pertaining to the checklist, the changes are required to be re-assessed once again.</div>")
    newline(1)
    styled_text("<div style='font-size: 10;text-align: justify; line-height: 7'>Finally, Congratulations for partaking in this noble endeavor, and together let us build a healthy and sustainable future.</div>")

    newline(1)
    styled_text("<div style='font-size: 10; line-height: 7;'>Yours sincerely, \n</div>")

    newline(4)
    styled_text("<div style='font-size: 10; color: #{@@main_color}; font-style: bold;'>\n Zaki Ahmed Mohammed</div>")

    styled_text("<div style='font-size: 10; color: 000000;'>\n Senior Director \n</div>")
    styled_text("<div style='font-size: 10; color: 000000;'>\n Sustainability Advisory, \n</div>")
    styled_text("<div style='font-size: 10; color: 000000;'>\n GSB \n</div>")
  end

  def draw_headers
    repeat(:all) do                        
      bounding_box([@document.bounds.left - 10, @document.bounds.top + 15], width: 580, height: HEADER_HEIGHT) do
        image image_path(HEADER_IMAGE), width: 580
      end
    
      newline
      bounding_box([@document.bounds.right - 125, @document.bounds.top - 45], width: 120, height: HEADER_HEIGHT) do
        text = "Issuance Date: #{@detailed_certificate_report&.issuance_date&.strftime('%d-%m-%Y')}\n"
        text2 = "Ref: #{@detailed_certificate_report&.reference_number}"

        styled_text("<div style='font-size: 8; text-align: right'>#{text}<br />#{text2}</div>")
      end

      if @certification_path.is_provisional_certificate?
        bounding_box([@document.bounds.right - 100, @document.bounds.bottom + 210], width: 110, height: HEADER_HEIGHT + 140) do
          image image_path(@@stamp_image), width: 90
        end
      end
    end
  end

  def draw_page(&block)
    bounding_box([CONTENT_PADDING, @document.bounds.top - HEADER_HEIGHT], width: @document.bounds.right - CONTENT_PADDING * 2, height: @document.bounds.top - HEADER_HEIGHT - FOOTER_HEIGHT, &block)
  end

  def draw_footers
    repeat(:all) do
      bounding_box([@document.bounds.left - 30, @document.bounds.bottom + 30], width: 580, height: FOOTER_HEIGHT) do
        image image_path(FOOTER_IMAGE), width: 580
      end
    end
    # Paging
    string = "Page <page> of <total>"
    options = { :at => [@document.bounds.left - 30, @document.bounds.bottom - 20],
                :width => 580,
                :align => :center,
                :size => 10,
                :start_count_at => 1}
    number_pages string, options
  end

  def draw_table(data, type)
    if type == 'basic_table'
      table(data, width: @document.bounds.right) do
        # Set default cell style
        cells.align = :left
        cells.borders = []
        cells.padding = 0
        cells.border_width = 0.5

        # Set column widths
        column(0).width = width / 3
        column(1).width = width * 2 / 3

        cells.borders = %i(top right bottom left)
        cells.border_color = TABLE_BORDER_COLOR

        
        # # Header row style
        header_row = rows(0..row_length - 1)
        header_row.column(0).background_color = @@column_1_color
        header_row.column(0).text_color = TABLE_TEXT_COLOR
        header_row.column(0).font_style = :bold
        header_row.column(1).background_color = COLUMN_2_COLOR
        header_row.column(1).text_color = TABLE_TEXT_COLOR
        header_row.size = 10
        header_row.border_color = TABLE_BORDER_COLOR

        # Content rows style
        content_rows = rows(0..row_length - 1)
        content_rows.column(1).align = :left
        content_rows.padding = [3, 4, 3, 4]
      end
    elsif type == 'project_info_table'
      table(data, width: @document.bounds.right) do
        # Set default cell style
        cells.align = :left
        cells.borders = []
        cells.padding = 0
        cells.border_width = 0.5

        header_row = rows(0..row_length - 1)

        data[1][0] = { content: data[1][0], colspan: 2 } 

        # Set column widths
        header_row.size = 9
        header_row.row(0).column(0).width = width / 3
        header_row.row(0).column(1).width = width / 3
        header_row.row(0).column(2).width = width / 3
        # header_row.row(1).column(0).width = width - (width / 3)
        # header_row.row(1).column(1).width = width / 3

        cells.borders = %i(top bottom left)
        header_row.text_color = TABLE_TEXT_COLOR
        header_row.background_color = COLUMN_2_COLOR
        header_row.align = :left
        header_row.column(0).border_left_color = 'FFFFFF'
        header_row.padding = [2, 2, 2]
      end
    end
  end
end