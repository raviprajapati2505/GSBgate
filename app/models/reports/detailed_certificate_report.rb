class Reports::DetailedCertificateReport < Reports::BaseReport
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ReportsHelper
  include ActionView::Helpers::TranslationHelper

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
  GSAS_LOGO = 'gsas_logo.jpg'.freeze
  LOC_LOGO = 'gsas_logo.jpg'.freeze

  TEXT_COLOR = 'ffffff'.freeze
  BACKGROUND_COLOR = 'EEEEEE'.freeze
  FOOTER_LOGO = 'gord_logo_black.jpg'.freeze
  STAR_ICON = 'green_star.png'.freeze
  FOOTER_URL = "<link href='http://www.gsas.gord.qa'>www.gsas.gord.qa</link>".freeze
  MAX_ROWS_PER_PAGE = 24
  PAGE_MARGIN = 50

  def initialize(certification_path)
    # Note: uncomment to use custom fonts
    self.font_families.update(
      "DinNextLtProLight" => {
        normal: font_path('dinnextltpro-light.woff.ttf')
      }
    )
    
    font 'DinNextLtProLight', size: 10

    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(page_size: 'A4',
                                    page_layout: :portrait,
                                    margin: 40)

    @certification_path = certification_path
    @project = @certification_path.project
    @detailed_certificate_report = @certification_path.certification_path_report
    @scheme_mixes = certification_path&.scheme_mixes
    @scheme_names = @certification_path.schemes.collect(&:name)
    @score = @certification_path.scores_in_certificate_points[:achieved_score_in_certificate_points]
    
    @stars = @certification_path.rating_for_score(@score, certificate: @certification_path.certificate).to_s

    if ['1', '2', '3', '4', '5', '6'].include?(@stars)
      @stars = @stars + ' ' + 'Star'.pluralize(@stars.to_i)
    end

    set_format_colors(@project)
    do_render
  end

  private

  def set_format_colors(project)
    if project&.certificate_type == 1
      @@main_color = 'fe4f00'.freeze
      @@column_1_color = 'ffd7bd'.freeze
      @@stamp_image = 'cm_stamp.png'.freeze
    else
      @@main_color = '2fb548'.freeze
      @@column_1_color = 'cee6c6'.freeze
      @@stamp_image = 'loc_stamp.png'.freeze
    end
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
        if scheme_mix_criteria_scores_by_category[category.id]
          total_category_scores[category.code] = { name: category.name, achieved_score: 0, maximum_score: 0 } unless total_category_scores.key?(category.code)
          category_scores = sum_score_hashes(scheme_mix_criteria_scores_by_category[category.id])
          total_category_scores[category.code][:achieved_score] += category_scores[:achieved_score_in_certificate_points]
          total_category_scores[category.code][:maximum_score] += category_scores[:maximum_score_in_certificate_points]
        end
      end
    end

    draw_page do
      newline(1)
      draw_certificate_header
      newline(1)
      draw_certificate_info_table
      newline(1)
      draw_paragraph1
      newline(1)
      if @certification_path.certificate.only_name == 'Letter of Conformance'
        newline(2)
        span(@document.bounds.right, :position => :center) do
          draw_project_info
        end
      else
        start_new_page
        newline
        span(@document.bounds.right, :position => :center) do
          draw_project_info
        end
      end
      
      newline(1)
      draw_scoring_summary(total_category_scores)
      
      draw_category_graph(total_category_scores)
    
      newline(3)

      draw_score_graph

      # For all scheme_mixes
      @scheme_mixes.each do |scheme_mix|
        start_new_page

        newline(2)
        draw_project_info(scheme_mix)

        newline(1)
        draw_scheme_mix_info(scheme_mix)

        @certification_path = scheme_mix.certification_path
        @score = scheme_mix.scores_in_scheme_points[:achieved_score_in_scheme_points]
        # @stars = @certification_path.rating_for_score(@score, certificate: @certification_path.certificate).to_s +
        #     ' ' + 'Star'.pluralize(@certification_path.rating_for_score(@score, certificate: @certification_path.certificate))

        category_criteria_score(scheme_mix)
      end
    end

    draw_footers
  end

  def draw_certificate_header
    text = certification_type_name(@certification_path)
    styled_text("<div style='font-size: 10; font-weight: 900; color: #{@@main_color}; line-height: 1.2'>GSAS #{text[:project_type]}</div><br /><div style='font-size: 12; font-weight: 900;'>#{text[:certificate_name]}</div>")
  end

  def draw_scheme_mix_header(scheme_mix)
    text "#{scheme_mix&.scheme&.name} (#{scheme_mix&.custom_name})", size: 15, color: @@main_color, align: :center
  end

  def draw_certificate_info_table

    # Prepare table data
    data = []

    # Add the category rows to the table
    data.append(["To", @detailed_certificate_report&.to])
    data.append(["Project ID", @project.code])
    data.append(["Project Name", @detailed_certificate_report&.project_name])
    data.append(["Project Location", @detailed_certificate_report&.project_location])

    if @certification_path.certificate.certification_type == 'final_design_certificate'
      data.append(["GSAS Service Provider", @project.service_provider_2])
    else
      data.append(["GSAS Service Provider", @project.service_provider])
    end

    data.append(["GSAS Certificate", @certification_path.certificate&.report_certification_name])
    data.append(["GSAS Certification Stage", @certification_path.certificate&.stage_title])
    data.append(["GSAS Version", @certification_path.certificate&.only_version])

    unless @certification_path.construction?
      data.append(["GSAS Scheme", @certification_path&.scheme_names])
    end

    # unless @certification_path.construction?
    #   data.append(["Client", @detailed_certificate_report&.project_owner])
    # end

    # Output table
    draw_table(data, true, 'basic_table')
  end

  def draw_paragraph1
    name = @certification_path.certificate.only_name

    case name
    when 'Letter of Conformance'
      text = "This is to notify that GSAS Trust has reviewed the project based on the submitted information. The project is found eligible to receive the Design Certificate as a provision for final GSAS Design & Build Certificate in the form of \"Letter of Conformance (LOC)\", The project is achieving: \n"

      styled_text("<div style='font-size: 10; line-height: 7; color: 000000;'>#{text}</div>")

    when 'GSAS-CM', 'Construction Certificate'
      text =  case @certification_path&.certificate&.stage_title
              when 'Stage 1: Foundation'
                "This is to notify that GSAS Trust has reviewed the construction submittals in accordance with the latest GSAS Construction Management assessments and has completed the Initial Site Audit requirements of Construction Stage 1 (Foundation). The project is found eligible to receive the First Interim Audit Advisory Notice (AAN) No.01 achieving the following: \n"
              when 'Stage 2: Substructure & Superstructure'
                "This is to notify that GSAS Trust has reviewed the construction submittals in accordance with the latest GSAS Construction Management assessments and has completed the Second Site Audit requirements of Construction Stage 2 (Substructure & Superstructure). The project is found eligible to receive the Second Interim Audit Advisory Notice (AAN) No.02 achieving the following: \n"
              when 'Stage 3: Finishing'
                "This is to notify that GSAS Trust has reviewed the construction submittals in accordance with the latest GSAS Construction Management assessments and has completed the Third Site Audit requirements of Construction Stage 3 (Finishing). The project is found eligible to receive the Third Interim Audit Advisory Notice (AAN) No.03 achieving the following: \n"
              end

      styled_text("<div style='font-size: 10; line-height: 7; color: 000000;'>#{text}</div>")

    else
    end

    # Prepare table data
    data = []

    data.append(['STAGE SCORE', 'STAGE RATING'])
    if @certification_path.certificate.only_certification_name == 'GSAS-D&B'
      data.append([number_with_precision(@score, precision: 3), {:image => "#{Rails.root}/app/assets/images/reports/star_#{@stars.split("").first}.png", :width => 350, :image_height => 20, :position  => :center}])
    else
      data.append([number_with_precision(@score, precision: 3), @stars])
    end

    # Output table
    draw_table(data, true, 'score_table')

    case name 
    when 'Letter of Conformance'
      newline

      text = "The summary of the obtained rating is attached herewith."
      styled_text("<div style='font-size: 10; line-height: 7'>#{text}</div>")

      newline(1)
      
      text = "This letter is only the predecessor towards achieving the final GSAS-D&B Certificate and should not be considered as the final certificate. The project should satisfy during the construction stage all the requirements of <b>Conformance to Design Audit(CDA)</b> which is a pre-requisite for the final GSAS-D&B Certificate as indicated in GSAS Technical Guide, <span style='color: #337ab7'>www.gsas.gord.qa</span> \n"
      styled_text("<div style='font-size: 10; line-height: 7'>#{text}</div>")

      text = "In the event of any future changes applied to the criteria pertaining to this issued certificate, the changes are required to be re-assessed once again."
      styled_text("<div style='font-size: 10; line-height: 7'>#{text}</div>")

      newline(1)

      text = "Finally, congratulations on partaking in this noble endeavor. We look forward to creating jointly a healthy and sustainable future."
      styled_text("<div style='font-size: 10; line-height: 7;'>#{text}</div>")

      newline(1)

      styled_text("<div style='font-size: 10; line-height: 7;'><b>Yours sincerely</b>, \n</div>")

      newline(1)

      # image image_path('green_star.png'), width: 50

      styled_text("<div style='font-size: 10; color: #{@@main_color}; font-style: bold;'>\n Dr. Yousef Alhorr</div>")

      styled_text("<div style='font-size: 10; color: 000000; font-style: bold;'>\n Founding Chairman \n</div>")
    when 'GSAS-CM', 'Construction Certificate'
      newline

      text = "Criteria summary of the First Interim Audit Advisory Notice is attached herewith."
      styled_text("<div style='font-size: 10; line-height: 7;'>#{text}</div>")
      
      newline(1)

      text = "This notice is only the predecessor towards achieving the final GSAS-CM Certificate and should not be considered as the final certificate. The project shall satisfy during the rest of the construction stages all the requirements which is a pre-requisite for the GSAS-CM Certificate as stipulated in GSAS Technical Guide, <span style='color: #337ab7'>www.gsas.gord.qa</span> \n"
      styled_text("<div style='font-size: 10; line-height: 7'>#{text}</div>")

      newline(1)

      text = "Finally, congratulations on partaking in this noble endeavor. We look forward to creating jointly a healthy and sustainable future."
      styled_text("<div style='font-size: 10; line-height: 7;'>#{text}</div>")

      newline(1)

      styled_text("<div style='font-size: 10; line-height: 7;'><b>Yours sincerely</b>, \n</div>")

      newline(1)

      # image image_path('green_star.png'), width: 50

      styled_text("<div style='font-size: 10; color: #{@@main_color}; font-style: bold;'>\n Dr. Yousef Alhorr</div>")

      styled_text("<div style='font-size: 10; color: 000000; font-style: bold;'>\n Founding Chairman \n</div>")

    end

  end

  def draw_project_info(scheme_mix = nil)
    # Prepare table data
    data = []

    scheme_info = ''
    if scheme_mix&.custom_name.present?
      scheme_info = "(#{scheme_mix&.custom_name})"
    end

    # Add the category rows to the table
    data.append(["Project ID: #{@project.code}", {content: "Project Name: #{@detailed_certificate_report&.project_name} - #{scheme_mix&.scheme&.name} #{scheme_info}", colspan: 2}])

    data.append(["Certification Stage: #{@certification_path.certificate&.stage_title}", "Approval Date: #{@detailed_certificate_report&.approval_date&.strftime('%d %B, %Y')}", "Reference: #{@detailed_certificate_report&.reference_number}"])

    # Output table
    draw_table(data, true, 'project_info_table')
  end

  def draw_scheme_mix_info(scheme_mix = nil)
    # Prepare table data
    data = []
    # Add the category rows to the table
    
    scheme_info = ''
    if scheme_mix&.custom_name.present?
      scheme_info = "(#{scheme_mix&.custom_name})"
    end
    
    data.append(["Criteria Summary - #{scheme_mix&.scheme&.name} #{scheme_info}"])

    # Output table
    draw_table(data, true, 'scheme_mix_info_table')
  end

  def draw_scoring_summary(total_category_scores)
    # Prepare table data
    data = []

    # Add the header rows to the table
    data.append(["Category", "Scenario 1 - Overall Score \n #{number_with_precision(@score, precision: 3)}"])

    # Add the category rows to the table
    total_category_scores.each do |category_code, category|
      data.append([category[:name], number_with_precision(category[:achieved_score], precision: 3)])
    end

    # Add footer data to the table
    data.append(["Rating Achieved", @stars])

    # Output table
    draw_table(data, true, 'scoring_summary_table')
    newline(1)

    text = "Figure 1: Scoring Summary"
    styled_text("<div style='font-size: 9; line-height: 5; color: 000000; text-align: center; padding-top: 10px;'><b>#{text}</b></div>")
    newline(1)
  end

  def draw_headers
    repeat(:all) do
      bounding_box([@document.bounds.left - 30, @document.bounds.top + 15], width: 580, height: HEADER_HEIGHT) do
        image image_path(HEADER_IMAGE), width: 580
      end
    
      newline
      bounding_box([@document.bounds.right - 125, @document.bounds.top - 45], width: 120, height: HEADER_HEIGHT) do
        text = "Issuance Date: #{@detailed_certificate_report&.issuance_date&.strftime('%d %B, %Y')}\n"
        text2 = "Ref: #{@detailed_certificate_report&.reference_number}"

        styled_text("<div style='font-size: 8; text-align: right'>#{text}<br />#{text2}</div>")
      end

      if @certification_path.construction? || @certification_path.is_design_loc?
        bounding_box([@document.bounds.right - 100, @document.bounds.bottom + 140], width: 110, height: HEADER_HEIGHT + 70) do
          image image_path(@@stamp_image), width: 110
        end
      end
    end
  end

  def draw_page
    bounding_box([CONTENT_PADDING, @document.bounds.top - HEADER_HEIGHT], width: @document.bounds.right - CONTENT_PADDING * 2, height: @document.bounds.top - HEADER_HEIGHT - FOOTER_HEIGHT) do
      yield
    end
  end

  def draw_footers
    repeat(:all) do
      bounding_box([@document.bounds.left - 30, @document.bounds.bottom + 30], width: 580, height: FOOTER_HEIGHT) do
        image image_path(FOOTER_IMAGE), width: 580
      end
    end
  end

  def draw_signature
    text SIGNATURE_CLOSING
    newline(5)
    text ISSUER_NAME, style: :bold
    text ISSUER_TITLE, style: :bold
  end

  def draw_category_graph(total_category_scores)
    chart_generator = ChartGeneratorService.new
    barchart_config = {
      type: 'bar',
      data: {
        labels: total_category_scores.map { |_category_code, category| category[:name] },
        font: {
          weight: "bold",
        },
        datasets: [{
          label: 'Points Attainable',
          data: total_category_scores.map { |_category_code, category| category[:maximum_score]&.round(2) },
          backgroundColor: 'rgba(195, 56, 56, 255)',
          borderColor: 'rgba(195, 56, 56, 255)',
          borderWidth: 1,
          fill: false
        },
        {
          label: 'Achieved',
          data: total_category_scores.map { |_category_code, category| category[:achieved_score]&.round(2) },
          backgroundColor: 'rgba(54,111,178,255)',
          borderColor: 'rgba(54,111,178,255)',
          borderWidth: 1
        }]
      },
      options: {
        indexAxis: 'y',
        legend: {
          display: true,
          position: 'bottom'
        },
        plugins: {
          datalabels: {
            color: "black",
            align: "end",
            anchor: "start"
          }
        }
      }
    }

    # width = 490
    # height = 230
    # x = @document.bounds.left - 5
    # y = @document.bounds.bottom + 20

    begin
      image chart_generator.generate_chart(barchart_config, 600, 230).path, width: 350, position: :center

      # stroke do
      #   stroke_color '000000'
      #   vertical_line   y, y+height+12, :at => x
      #   vertical_line   y, y+height+12, :at => x+width
      #   horizontal_line x, x+width,  :at => y+height+12
      #   horizontal_line x, x+width, :at => y
      # end
    rescue LinkmeService::ApiError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError

          #  bounding_box([x, y], width: x+width, height: height, position: :center) do
             text "An error occurred when creating the chart.", align: :center
          #  end
    end

    newline(1)
    text = "Figure 2: Category Achived Scores Vs. Attainable Scores"
    styled_text("<div style='font-size: 9; line-height: 5; color: 000000; text-align: center; padding-top: 8px;'><b>#{text}</b></div>")
  end

  def draw_score_graph
    chart_generator = ChartGeneratorService.new

    labels = [
        'Certification denied',
        '',
        '★',
        '★★',
        '★★★',
        '★★★★',
        '★★★★★',
        '★★★★★★',
        ''
    ]

    data = [
        -1,
        -0.5,
        0,
        0.5,
        1,
        1.5,
        2,
        2.5,
        3.0
    ]

    point_radius = [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
    ]

    # Mark the certificate score on the line chart
    plot_index = data.index{ |e| e > @score.round(1) || @score.round(1) == 3 } - 1 rescue 0
    plot_index = plot_index - 1 if @score.round(1) == 3
    data[plot_index] = @score.round(1)
    point_radius[plot_index] = 7 unless plot_index.nil?

    linechart_config = {
      type: 'line',
      data: {
        labels: labels,
        font: {
          weight: "bold",
        },
        datasets: [{
          label: '',
          data: data,
          pointRadius: point_radius,
          borderDash: [10],
          backgroundColor: 'rgb(54, 162, 235)',
          borderColor: 'rgb(54, 162, 235)',
          fill: false
        }]
      },
      options: {
        plugins: {
          legend: {
            display: false,
          },
          datalabels: {
            color: "black",
            align: "end",
            anchor: "start",
          }
        },
        scales: {
          y: {
            title: {
              display: true,
              text: "Overall score",
              font: {
                weight: "bold",
              },
            },
            axis: "y",
          },
          x: {
            # title: {
            #   display: true,
            #   text: "Certification denied",
            #   color: "red",
            #   align: "start",
            #   font: {
            #     weight: "bold",
            #   },
            # },
            axis: "x",
          }
        }
      }
    }

    # text 'Legend', size: 13, style: :bold, align: :left
    data = []
    data.append(['Score', 'Rating'])
    data.append(['X<0', 'Certification Denied'])
    data.append(['0.0<=X<=0.5', '*'])
    data.append(['0.5<X<=1.0', '**'])
    data.append(['1.0<X<=1.5', '***'])
    data.append(['1.5<X<=2.0', '****'])
    data.append(['2.0<X<=2.5', '*****'])
    data.append(['2.5<X<=3.0', '******'])

    newline(1)

    table(data, cell_style: { width: 80 }, position: :right) do
      # column(0).align = :center
      row(0).background_color = @@main_color
      row(0).text_color = 'FFFFFF'
      row(0).size = 9
      row(0).font_style = :bold
      row(0..-1).size = 8
      row(0..-1).padding = [3, 3]
      row(1).text_color = 'FF0000'
      rows(1..-1).borders = [:top, :right, :bottom, :left]
      row(-1).borders = [:right, :bottom, :left]
    end

    newline(1)

    begin
      image chart_generator.generate_chart(linechart_config, 450, 270).path, at: [0, 170], width: 270
    rescue LinkmeService::ApiError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
      EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      text 'An error occurred when creating the chart.'
    end
    
    newline(1)

    text = 'Figure 3: Project Overall Scores & Rating'
    styled_text("<div style='font-size: 9; line-height: 5; color: 000000; text-align: center; padding-top: px;'><b>#{text}</b></div>")

    # text 'Level Achieved', size: 12, align: :left
    # data = []
    # @certification_path.scheme_mixes.each do |scheme_mix|
    #   score = scheme_mix.scores_in_scheme_points[:achieved_score_in_scheme_points]
    #   stars = @certification_path.rating_for_score(score, certificate: @certification_path.certificate).to_s +
    #       ' ' + 'Star'.pluralize(@certification_path.rating_for_score(score, certificate: @certification_path.certificate))
    #   data.append([stars, scheme_mix.scheme.name])
    # end

    # table(data, width: 250) do
    #   cells.align = :center
    #   cells.size = 13
    #   cells.borders = []
    #   cells.background_color = '36A2EB'
    # end
  end

  def draw_table(data, has_level_achieved_footer = false, type)
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
        header_row.column(1).background_color = COLUMN_2_COLOR
        header_row.column(1).text_color = TABLE_TEXT_COLOR
        # header_row.font = 'Helvetica'
        header_row.size = 10
        header_row.border_color = TABLE_BORDER_COLOR

        # Content rows style
        content_rows = rows(0..row_length - 1)
        content_rows.column(1).align = :left
        content_rows.padding = [3, 4, 3, 4]
      end
    elsif type == 'score_table'
      table(data, width: @document.bounds.right) do
        # Set default cell style
        cells.align = :left
        cells.borders = []
        cells.padding = 0
        cells.border_width = 0.5

        # Set column widths
        column(0).width = width / 2
        column(1).width = width / 2

        cells.borders = %i(top bottom left)
        header_row = rows(0..row_length - 1)

        header_row.row(0).background_color = @@main_color
        header_row.row(1).background_color = COLUMN_2_COLOR
        header_row.row(0).text_color = 'FFFFFF'
        # header_row.font = 'Helvetica'
        header_row.size = 10
        header_row.font_style = :bold
        header_row.align = :center
        header_row.column(0).border_left_color = 'FFFFFF'
        header_row.row(0).padding = [2, 2]
        header_row.row(1).padding = [5, 5]
        # header_row.column(1).borders = %i(left)
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
    elsif type == 'scoring_summary_table'

      # bounding_box([@document.bounds.left, @document.bounds.top], width: @document.bounds.right, height: HEADER_HEIGHT) do
        table(data, width: @document.bounds.right - 180, position: :center) do

          cells.left_margin = 50
          cells.right_margin = 50

          # Set default cell style
          cells.align = :left
          cells.borders = []
          cells.padding = 2
          cells.border_width = 0.5

          header_row = rows(0)
          header_row.size = 6
          header_row.background_color = '696969'
          header_row.text_color = 'FFFFFF'
          header_row.padding = [2, 2, 2, 2]
          header_row.font_style = :bold
          header_row.align = :center
          header_row.borders = %i(right bottom) 
          header_row.border_left_color = '000000'
          header_row.border_right_color = '000000'
          header_row.border_top_color = '000000'
          header_row.border_bottom_color = '000000'

          content_rows = rows(1..row_length - 1)
          content_rows.size = 6
          content_rows.column(0).align = :right
          content_rows.column(1).align = :center

          content_rows.padding = [2, 2, 2, 2]
          content_rows.borders = %i(right) 
          content_rows.row(row_length - 3).borders = %i(right bottom) 
          content_rows.border_right_color = '000000'
          content_rows.border_bottom_color = '000000'
          content_rows.column(1).border_right_color = 'FFFFFF'
          content_rows.row(row_length - 2).font_style = :bold
          content_rows.row(row_length - 2).column(1).background_color = '538dd5'
          content_rows.row(row_length - 2).borders = %i(bottom) 
          content_rows.row(row_length - 2).column(0).border_bottom_color = 'FFFFFF'

          column(0).width = width - (width / 3)
          column(1).width = width / 3
        end
    elsif type == 'smc_scores_table'
      table(data, width: @document.bounds.right) do

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
        column(1).width = width * 0.50
        column(2).width = width * 0.15
        column(3).width = width * 0.15

        # Misc table border style
        row(0).border_top_color = '000000'
        row(-1).border_bottom_color = '000000'
        column(-1).borders = [:top, :bottom, :left, :right]
        column(1).borders = [:top, :right, :bottom]

        # Category name column style
        name_column = column(0)
        name_column.align = :left
        # name_column.vposition = :center
        name_column.text_color = TABLE_TEXT_COLOR
        name_column.borders = [:top, :right, :bottom, :left]
        name_column.border_color = TABLE_BORDER_COLOR
        # name_column.border_color = @@main_color
        # name_column.font_style = :bold
        name_column.background_color = @@column_1_color

        # Odd/even row style
        rows(1..-1).style do |c|
          c.background_color = 'EAEAEA' if (c.row % 2).zero?
          c.border_color = COLUMN_2_COLOR
        end

        # Header row style
        header_row = row(0).columns(1..-1)
        header_row.background_color = @@column_1_color
        header_row.text_color = TABLE_TEXT_COLOR
        header_row.border_color = TABLE_BORDER_COLOR

        # Criteria name column style
        column(1).align = :left
      end
    elsif type == 'scheme_mix_info_table'
      table(data, width: @document.bounds.right) do

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

        column(0).width = width

        # Category name column style
        name_column = column(0)
        name_column.align = :left
        name_column.text_color = TABLE_TEXT_COLOR
        name_column.borders = [:top, :right, :bottom, :left]
        name_column.border_color = TABLE_BORDER_COLOR
        name_column.background_color = @@main_color
      end
    end
  end

  def category_criteria_score(scheme_mix)
    @scheme_mix = scheme_mix

    bounding_box([0, 655], width: @document.bounds.width) do
      # Draw awarded target
      # draw_awarded_target

      # Draw all category/criteria tables
      rows_on_page = 0
      categories_with_criteria.each_with_index do |category_with_criteria, index|
        row_count = category_with_criteria[:criteria].count + 2 # Add 2 extra rows for table header and margin

        if (rows_on_page + row_count) > MAX_ROWS_PER_PAGE
          start_new_page
          newline(3)
          draw_project_info(scheme_mix)
          newline(1)
          rows_on_page = row_count
        else
          newline(1)
          newline(9) if index == 0

          rows_on_page += row_count
        end

        draw_criteria_table(category_with_criteria[:category], category_with_criteria[:criteria])
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

  def draw_criteria_table(scheme_category, scheme_mix_criteria)
    # Prepare table data
    data = []
    data.append([{content: "#{scheme_category.name.upcase} [#{scheme_category.code}]", rowspan: scheme_mix_criteria.size + 1}, 'Criterion', 'Level', 'Incentive'])

    # Add the category rows to the table
    scheme_mix_criteria.each do |smc|
      achieved_score = smc.achieved_score
      achieved_score = ((achieved_score.is_a?(Float) || achieved_score.is_a?(BigDecimal)) && achieved_score.nan?) ? 0 : achieved_score rescue 0
      data.append([smc.full_name, number_with_precision(achieved_score, precision: 0, significant: true), "#{number_with_precision(smc.calculate_awarded_incentives, precision: 1)}%"])
    end

    # Output table
    draw_table(data, 'smc_scores_table')
  end
end