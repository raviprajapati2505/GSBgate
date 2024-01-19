class Reports::LetterOfConformanceCoverLetter < Reports::BaseReport
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ReportsHelper

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

  def initialize(certification_path)
    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(page_size: 'A4',
                                    page_layout: :portrait,
                                    margin: 40)
    @certification_path = certification_path
    @scheme_names = @certification_path.schemes.collect(&:name)
    @score = @certification_path.scores_in_certificate_points[:achieved_score_in_certificate_points]
    @stars = @certification_path.rating_for_score(@score, certificate: @certification_path.certificate).to_s +
             ' ' + 'Star'.pluralize(@certification_path.rating_for_score(@score, certificate: @certification_path.certificate))

    @addressee = "Mr. [FIRSTNAME] [LASTNAME]\n[FUNCTION]\n#{@certification_path.project.owner}"
    @addressee_copy = "Service Provider:   #{@certification_path.project.service_provider}"
    @subject = "#{certification_path.name}\n#{@scheme_names.join(', ')}"
    @content = <<-CONTENTTEMPLATE
Dear,

On behalf of GSB Trust, I would like to confer this Provisional GSB Design & Build Certificate in the form of "Letter of Conformance-LOC" to the project mentioned above for the successful completion of GSB Mixed Development v2.0 certification requirements.

Based on the submitted data, the score is documented to be <b><u>#{number_with_precision(@score, precision: 3)}</u></b>, which corresponds to the certification level of <b><u>#{@stars}</u></b>. Figures 1 to 3 summarize the score for the project, the score per category, achieved certification level and scoring bar chart respectively. Also, LOC Criteria Summary for the project is attached.

Kindly be advised that, this letter is only the predecessor towards achieving the final GSB Design & Build Certificate and <u>should not be considered as the final certificate</u>. The project should satisfy during the construction stage the requirements of <u>Conformance to Design Audit</u> which is a prerequisite for the final GSB Design & Build Certificate as indicated in the GSB Technical Guide.

In the event of any future changes applied to the criteria pertaining to the issued LOC, the changes are required to be re-assessed once again. To understand the terms and conditions pertaining to GSB certification, please refer to: <u><link href='http://www.gord.qa'>www.gord.qa</link></u>. 

Congratulations once again for partaking in this noble endeavor, and together let us build a healthy and a sustainable future.

    CONTENTTEMPLATE
    do_render
  end

  private

  def do_render
    font 'Times-Roman', size: 11

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
        span(@document.bounds.right - CONTENT_PADDING, :position => :center) do
          draw_project_info
        end
      else
        start_new_page
        newline
        span(@document.bounds.right - CONTENT_PADDING, :position => :center) do
          draw_project_info
        end
      end
      
      newline(2)
      draw_scoring_summary(total_category_scores)
      newline(2)
      draw_category_graph(total_category_scores)
      if @certification_path.certificate.only_name == 'Letter of Conformance'
       start_new_page
      end
      draw_score_graph

    end

    draw_footers
  end

  def draw_certificate_header
    text "#{certificate_name(@certification_path)}", size: 15, color: MAIN_COLOR, align: :center, font: 'Helvetica'
  end

  def draw_certificate_info_table

    # Prepare table data
    data = []

     # Add the category rows to the table
    data.append(["To", @certification_path.project.owner])
    data.append(["Project ID", @certification_path.project.code])
    data.append(["Project Name", @certification_path.project.name])
    data.append(["Location", @certification_path.project.location])
    if @certification_path.certificate.certification_type == 'final_design_certificate'
      data.append(["Service Provider", @certification_path.project.service_provider_2])
    else
      data.append(["Service Provider", @certification_path.project.service_provider])
    end
    data.append(["GSB Certificate", @certification_path.certificate.only_certification_name])
    data.append(["Certification Stage", @certification_path.certificate.stage_title])
    data.append(["GSB Version", @certification_path.certificate.only_version])
    data.append(["GSB Scheme", @certification_path.project.building_type_group.name])
    
     # Output table
     draw_table(data, true, 'basic_table')
  end

  def draw_paragraph1
    name = @certification_path.certificate.only_name

    case name
    when 'Letter of Conformance'
      text = "This is to notify that GSB Trust has assessed the project based on the submitted information. The project is found eligible to receive the Provisional GSB-D&B Certificate in the form of \"Letter of Conformance (LOC)\", achieving the following: \n"

      styled_text("<div style='font-size: 10; line-height: 9; color: 000000;'>#{text}</div>")

      newline(1)
    when 'GSB-CM', 'Construction Certificate'
      text = "This is to notify that GAS Trust has reviewed the construction submittals in accordance with the latest GSB Construction Management assessments and has completed the Third Site Audit requirements of Construction Stage 3 (Finishing Works). The project is found eligible to receive the Third Interim Audit Advisory Notice (AAN) No.03 achieving the following: \n"

      styled_text("<div style='font-size: 10; line-height: 9; color: 000000;'>#{text}</div>")

      newline(1)
    else
    end

    # Prepare table data
    data = []

    data.append(['SCORE', 'STAR RATING'])
    if @certification_path.certificate.only_certification_name == 'GSB-D&B'
      data.append([number_with_precision(@score, precision: 3), {:image => "#{Rails.root}/app/assets/images/reports/star_#{@stars.split("").first}.png", :width => 350, :image_height => 20, :position  => :center}])
    else
      data.append([number_with_precision(@score, precision: 3), @stars])
    end

    # Output table
    draw_table(data, true, 'score_table')

    case name 
    when 'Letter of Conformance'
      newline
      text = "The summary of the obtained rating is attached herewith. \n\n This letter is only the predecessor towards achieving the final GSB-D&B Certificate and should not be considered as the final certificate. The project should satisfy during the construction stage all the requirements of <b>Conformance to Design Audit(CDA)</b> which is the pre-requisite for the final GSB-D&B Certificate as indicated in GSB Technical Guide, <a>www.gord.qa</a> \n"
      styled_text("<div style='font-size: 10; line-height: 9'>#{text}</div>")

      newline(1)

      text = "In the event of any future changes applied to the criteria pertaining to the issued LOC, the changes are required to be re-assessed once again."
      styled_text("<div style='font-size: 10; line-height: 9'>#{text}</div>")

      newline(1)

      text = "Finally, Congratulations for partaking in this nobel endeavor, and together let us build a healthy and a sustainable future."
      styled_text("<div style='font-size: 10; line-height: 9;'>#{text}</div>")

      newline(1)

      styled_text("<div style='font-size: 10; line-height: 9;'><b>Yours sincerely</b>, \n</div>")

      newline(1)

      # image image_path('green_star.png'), width: 50

      styled_text("<div style='font-size: 10; color: #{MAIN_COLOR}; font-style: bold;'>\n Dr. Yousef Alhorr</div>")

      styled_text("<div style='font-size: 10; color: 000000; font-style: bold;'>\n Founding Chairman \n</div>")
    when 'GSB-CM', 'Construction Certificate'
      newline
      
      text = "Criteria summary of the Second Inkerim Audit Advisory Notice is attached herewith. \n\n This notice is only the predecessor towards achieving the final GSB-CM Certificate and should not be considered as the final certificate. The project/contractor shall satisfy during the rest of the construction stages all the requirements which is a pre-requisite for the GSB-CM Certificate as stipulated in GSB Technical Guide, <a>www.gord.qa</a> \n"
      styled_text("<div style='font-size: 10; line-height: 9'>#{text}</div>")

      newline(1)

      text = "Finally, Congratulations for partaking in this nobel endeavor, and together let us build a healthy and a sustainable future."
      styled_text("<div style='font-size: 10; line-height: 9;'>#{text}</div>")

      newline(1)

      styled_text("<div style='font-size: 10; line-height: 9;'><b>Yours sincerely</b>, \n</div>")

      newline(1)

      # image image_path('green_star.png'), width: 50

      styled_text("<div style='font-size: 10; color: #{MAIN_COLOR}; font-style: bold;'>\n Dr. Yousef Alhorr</div>")

      styled_text("<div style='font-size: 10; color: 000000; font-style: bold;'>\n Founding Chairman \n</div>")

    end

  end

  def draw_project_info
    # Prepare table data
    data = []
    # Add the category rows to the table
    data.append(["Project ID: #{@certification_path.project.code}", "Provisional Rating: #{@stars}", "Approval Date: 14th Nov, 2020"])

    # Add footer to the table
    data.append([{content: "Project Name: #{@certification_path.project.name}", colspan: 2}, "Reference: LOC-KNNAN-239409"])

    # Output table
    draw_table(data, true, 'project_info_table')
  end

  def draw_scoring_summary(total_category_scores)
    # Prepare table data
    data = []

    # Add the header rows to the table
    data.append(["Category", "Scenario 1 - Overall Score"])

    # Add the category rows to the table
    total_category_scores.each do |category_code, category|
      data.append([category[:name], number_with_precision(category[:achieved_score], precision: 3)])
    end

    # Add footer data to the table
    data.append(["Rating Achieved", @stars])

    # Output table
    draw_table(data, true, 'scoring_summary_table')
    newline(2)
    text = "Figure 1: Scoring Summary"
    styled_text("<div style='font-size: 12; line-height: 9; color: 000000; text-align: center; padding-top: 10px;'><b>#{text}</b></div>")
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

  def draw_heading_date
    text 'Date: ' + @certification_path.certified_at.strftime('%B %d, %Y'), size: 9 if @certification_path.certified_at.present?
    text 'Ref: ' + @certification_path.project.code, size: 9
  end

  def draw_heading_addressee
    text 'Attn,', style: :bold
    text @addressee, style: :bold
  end

  def draw_heading_addressee_copy
    text 'Cc: ' + @addressee_copy, style: :bold
  end

  def draw_heading_subject
    curline = cursor
    size = 40
    bounding_box([0, curline], width: size) do
      text 'Sub: ', style: :bold
    end
    bounding_box([size, curline], width: (@document.bounds.right - size)) do
      text @subject
    end
  end

  def draw_heading_project
    curline = cursor
    size = 100
    bounding_box([0, curline], width: size) do
      text 'Project Name: ', style: :bold
      text 'GSB ID: ', style: :bold
    end
    bounding_box([size, curline], width: (@document.bounds.right - size)) do
      text @certification_path.project.name, style: :bold
      text @certification_path.project.code, style: :bold
    end
  end

  def draw_content
    text @content, inline_format: true
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
      type: 'horizontalBar',
      data: {
        labels: total_category_scores.map { |_category_code, category| category[:name] },
        datasets: [{
          label: 'Points Attainable',
          data: total_category_scores.map { |_category_code, category| category[:maximum_score] },
          backgroundColor: 'rgb(255, 99, 132)',
          borderColor: 'rgb(255, 99, 132)',
          borderWidth: 1
        },
                   {
                     label: 'Achieved',
                     data: total_category_scores.map { |_category_code, category| category[:achieved_score] },
                     backgroundColor: 'rgb(54, 162, 235)',
                     borderColor: 'rgb(54, 162, 235)',
                     borderWidth: 1
                   }]
      },
      options: {
        legend: {
          position: 'bottom'
        }
      }
    }

    begin
      image chart_generator.generate_chart(barchart_config, 600, 400).path, width: 450
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      text 'An error occurred when creating the chart.'
    end

    newline
  end

  def draw_score_graph
    chart_generator = ChartGeneratorService.new

    labels = [
        '',
        '', '', '', '',
        'Certification denied',
        '', '', '', '',
        '*',
        '', '', '', '',
        '**',
        '', '', '', '',
        '***',
        '', '', '', '',
        '****',
        '', '', '', '',
        '*****',
        '', '', '', '',
        '******',
        '', '', '', '',
        ''
    ]

    data = [
        -1,
        -0.9, -0.8, -0.7, -0.6,
        -0.5,
        -0.4, -0.3, -0.2, -0.1,
        0,
        0.1, 0.2, 0.3, 0.4,
        0.5,
        0.6, 0.7, 0.8, 0.9,
        1,
        1.1, 1.2, 1.3, 1.4,
        1.5,
        1.6, 1.7, 1.8, 1.9,
        2,
        2.1, 2.2, 2.3, 2.4,
        2.5,
        2.6, 2.7, 2.8, 2.9,
        3.0
    ]

    point_radius = [
        0,
        0, 0, 0, 0,
        0,
        0, 0, 0, 0,
        4,
        0, 0, 0, 0,
        4,
        0, 0, 0, 0,
        4,
        0, 0, 0, 0,
        4,
        0, 0, 0, 0,
        4,
        0, 0, 0, 0,
        4,
        0, 0, 0, 0,
        0
    ]

    # Mark the certificate score on the line chart
    plot_index = data.index(@score.round(1))
    point_radius[plot_index] = 12 unless plot_index.nil?

    barchart_config = {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: '',
          data: data,
          pointRadius: point_radius,
          backgroundColor: 'rgb(54, 162, 235)',
          borderColor: 'rgb(54, 162, 235)',
          fill: false
        }]
      },
      options: {
        legend: {
          display: false
        }
      }
    }

    # text 'Level Achieved', size: 14, color: '36A2EB', style: :bold, align: :left

    begin
      image chart_generator.generate_chart(barchart_config, 700, 450).path, width: 450
    # rescue LinkmeService::ApiError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
    #        EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    #   text 'An error occurred when creating the chart.'
    end

    newline
    text 'Figure 3 Certfication Level Chart', align: :center

    # Output the legend
    newline(2)
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

    table(data, width: 250) do
      # column(0).align = :center
      row(0).background_color = MAIN_COLOR
      row(0).text_color = 'FFFFFF'
      row(1).text_color = 'FF0000'
      rows(1..-1).borders = [:right, :left]
      row(-1).borders = [:right, :bottom, :left]
    end

    newline(2)
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

  def draw_certificate_table(total_category_scores)
    # Prepare table data
    data = []
    data.append(['', 'Category', 'Point'])

    # Add the category rows to the table
    total_category_scores.each do |category_code, category|
      data.append([category_code, category[:name], number_with_precision(category[:achieved_score], precision: 3)])
    end

    # Add footer to the table
    data.append(['', 'Total points', number_with_precision(@score, precision: 3)])
    data.append(['', 'Level achieved', @stars])

    # Output table
    draw_table(data, true)
    newline
    text 'Figure 1 Scoring Summary', align: :center
  end

  # def draw_scheme_mix_table(certification_path)
  #   # Fetch the certification path scores
  #   certification_path_scores = certification_path.scores_in_certificate_points
  #
  #   achieved_certification_path_score = number_with_precision(certification_path_scores[:achieved_score_in_certificate_points], precision: 3)
  #
  #   # Prepare table data
  #   data = []
  #   data.append(%w(Weight Scheme Points))
  #
  #   # Add the category rows to the table
  #   certification_path.scheme_mixes.each do |scheme_mix|
  #     achieved_scheme_mix_score = number_with_precision(scheme_mix.scores[:achieved_score_in_certificate_points], precision: 3)
  #     data.append(["#{scheme_mix.weight}%", scheme_mix.name, achieved_scheme_mix_score])
  #   end
  #
  #   # Add footer to the table
  #   data.append(['', 'Total points', achieved_certification_path_score])
  #   data.append(['', 'Level achieved', @stars])
  #
  #   # Output table title
  #   text "Certification: #{certification_path.name}", style: :bold, size: 15, color: '69AB87', align: :center
  #
  #   # Output table
  #   draw_table(data, true)
  # end
  #
  # def draw_category_table(scheme_mix)
  #   # Fetch the scheme mix scores
  #   scheme_mix_scores = scheme_mix.scores
  #   achieved_scheme_mix_score = number_with_precision(scheme_mix_scores[:achieved_score_in_certificate_points], precision: 3)
  #
  #   # Fetch all scheme mix criteria score records
  #   scheme_mix_criteria_scores = scheme_mix.scheme_mix_criteria_scores
  #
  #   # Group the scores by category
  #   scheme_mix_criteria_scores_by_category = scheme_mix_criteria_scores.group_by { |item| item[:scheme_category_id] }
  #
  #   # Prepare table data
  #   data = []
  #   data.append(%w(No Category Points))
  #
  #   # Add the category rows to the table
  #   scheme_mix.scheme_categories.each do |category|
  #     category_scores = sum_score_hashes(scheme_mix_criteria_scores_by_category[category.id])
  #     achieved_category_score = number_with_precision(category_scores[:achieved_score_in_certificate_points], precision: 3)
  #     data.append([category.code, category.name, achieved_category_score])
  #   end
  #
  #   # Add footer to the table
  #   data.append(['', 'Total points', achieved_scheme_mix_score])
  #
  #   # Output table title
  #   text "Scheme: #{scheme_mix.name} - #{scheme_mix.weight}%", style: :bold, size: 15, color: '69AB87', align: :center
  #
  #   # Output table
  #   draw_table(data)
  # end

  def draw_table(data, has_level_achieved_footer = false, type)
    

      if type == 'basic_table'

        table(data, width: @document.bounds.right - CONTENT_PADDING) do
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
          header_row.column(0).background_color = COLUMN_1_COLOR
          header_row.column(0).text_color = TABLE_TEXT_COLOR
          header_row.column(1).background_color = COLUMN_2_COLOR
          header_row.column(1).text_color = TABLE_TEXT_COLOR
          header_row.font = 'Helvetica'
          # header_row.font_style = :bold
          header_row.border_color = TABLE_BORDER_COLOR

          # Content rows style
          content_rows = rows(0..row_length - 1)
          content_rows.column(1).align = :left
          content_rows.padding = [3, 4, 3, 4]
        end
      elsif type == 'score_table'
        table(data, width: @document.bounds.right - CONTENT_PADDING) do
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

          header_row.row(0).background_color = MAIN_COLOR
          header_row.row(0).text_color = 'FFFFFF'
          header_row.font = 'Helvetica'
          header_row.size = 12
          header_row.font_style = :bold
          header_row.align = :center
          header_row.column(0).border_left_color = 'FFFFFF'
          header_row.row(0).padding = [2, 2]
          header_row.row(1).padding = [5, 5]
          # header_row.column(1).borders = %i(left)
        end
      elsif type == 'project_info_table'
        table(data, width: @document.bounds.right - CONTENT_PADDING) do
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
        end
      elsif type == 'scoring_summary_table'

        # bounding_box([@document.bounds.left, @document.bounds.top], width: @document.bounds.right, height: HEADER_HEIGHT) do
          table(data, width: @document.bounds.right - 20) do
  
            cells.left_margin = 50
            cells.right_margin = 50
  
            # Set default cell style
            cells.align = :left
            cells.borders = []
            cells.padding = 0
            cells.border_width = 0.5
  
            header_row = rows(0)
            
            header_row.background_color = '696969'
            header_row.text_color = 'FFFFFF'
            header_row.padding = [5, 5]
            header_row.font_style = :bold
            header_row.align = :center
            header_row.borders = %i(right bottom) 
            header_row.border_left_color = MAIN_COLOR
            header_row.border_right_color = MAIN_COLOR
            header_row.border_top_color = MAIN_COLOR
            header_row.border_bottom_color = MAIN_COLOR
  
            content_rows = rows(1..row_length - 1)
            content_rows.column(0).align = :right
            content_rows.column(1).align = :center
  
            content_rows.padding = [5, 5]
            content_rows.borders = %i(right) 
            content_rows.row(row_length - 3).borders = %i(right bottom) 
            content_rows.border_right_color = MAIN_COLOR
            content_rows.border_bottom_color = MAIN_COLOR
            content_rows.column(1).border_right_color = 'FFFFFF'
            content_rows.row(row_length - 2).font_style = :bold
            content_rows.row(row_length - 2).column(1).background_color = '0000FF'
            content_rows.row(row_length - 2).borders = %i(bottom) 
            content_rows.row(row_length - 2).column(0).border_bottom_color = 'FFFFFF'
  
            column(0).width = width - (width / 3)
            column(1).width = width / 3
          end
        # end

      end
    end
end
