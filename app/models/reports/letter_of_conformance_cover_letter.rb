class Reports::LetterOfConformanceCoverLetter < Reports::BaseReport
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  HEADER_HEIGHT = 70
  FOOTER_HEIGHT = 20
  CONTENT_PADDING = 20

  SIGNATURE_CLOSING = 'Yours sincerely,'.freeze
  ISSUER_NAME = 'Dr. Yousef Al Horr'.freeze
  ISSUER_TITLE = 'Founding Chairman'.freeze
  HEADER_LOGO = 'gord_logo.jpg'.freeze

  def initialize(certification_path)
    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(page_size: 'A4',
                                    page_layout: :portrait,
                                    margin: 40)
    @certification_path = certification_path
    @scheme_names = @certification_path.schemes.collect(&:name)
    @score = @certification_path.scores_in_certificate_points[:achieved_score_in_certificate_points]
    @stars = CertificationPath.star_rating_for_score(@score, certificate: @certification_path.certificate).to_s +
             ' ' + 'Star'.pluralize(CertificationPath.star_rating_for_score(@score, certificate: @certification_path.certificate))

    @addressee = "Mr. [FIRSTNAME] [LASTNAME]\n[FUNCTION]\n#{@certification_path.project.owner}"
    @addressee_copy = "Service Provider:   #{@certification_path.project.service_provider}"
    @subject = "#{certification_path.name}\n#{@scheme_names.join(', ')}"
    @content = <<-CONTENTTEMPLATE
Dear,

On behalf of GSAS Trust, I would like to confer this Provisional GSAS Design & Build Certificate in the form of "Letter of Conformance-LOC" to the project mentioned above for the successful completion of GSAS Mixed Development v2.0 certification requirements.

Based on the submitted data, the score is documented to be <b><u>#{@score}</u></b>, which corresponds to the certification level of <b><u>#{@stars}</u></b>. Figures 1 to 3 summarize the score for the project, the score per category, achieved certification level and scoring bar chart respectively. Also, LOC Criteria Summary for the project is attached.

Kindly be advised that, this letter is only the predecessor towards achieving the final GSAS Design & Build Certificate and <u>should not be considered as the final certificate</u>. The project should satisfy during the construction stage the requirements of <u>Conformance to Design Audit</u> which is a prerequisite for the final GSAS Design & Build Certificate as indicated in the GSAS Technical Guide.

In the event of any future changes applied to the criteria pertaining to the issued LOC, the changes are required to be re-assessed once again. To understand the terms and conditions pertaining to GSAS certification, please refer to: <u><link href='http://www.gord.qa'>www.gord.qa</link></u>. 

Congratulations once again for partaking in this noble endeavor, and together let us build a healthy and a sustainable future.

    CONTENTTEMPLATE
    do_render
  end

  private

  def do_render
    font 'Times-Roman', size: 11

    draw_headers

    draw_page do
      draw_heading_date
      newline(2)
      draw_heading_addressee
      newline
      draw_heading_addressee_copy
      newline
      draw_heading_subject
      newline
      draw_heading_project
      newline(2)
      draw_content
      draw_signature
    end

    total_category_scores = {}
    @certification_path.scheme_mixes.each do |scheme_mix|
      # Fetch all scheme mix criteria score records
      scheme_mix_criteria_scores = scheme_mix.scheme_mix_criteria_scores

      # Group the scores by category
      scheme_mix_criteria_scores_by_category = scheme_mix_criteria_scores.group_by { |item| item[:scheme_category_id] }

      scheme_mix.scheme_categories.each do |category|
        total_category_scores[category.code] = { name: category.name, achieved_score: 0, maximum_score: 0 } unless total_category_scores.key?(category.code)
        category_scores = sum_score_hashes(scheme_mix_criteria_scores_by_category[category.id])
        total_category_scores[category.code][:achieved_score] += category_scores[:achieved_score_in_certificate_points]
        total_category_scores[category.code][:maximum_score] += category_scores[:maximum_score_in_certificate_points]
      end
    end

    start_new_page
    draw_page do
      draw_certificate_table(total_category_scores)
      newline
      text 'Figure 1 Scoring summary', align: :center
      newline(3)
      draw_category_graph(total_category_scores)
      newline
      text 'Figure 2 Certfication level chart', align: :center
    end

    start_new_page
    draw_page do
      draw_score_graph
      newline
      text 'Figure 3 Certfication level chart', align: :center
    end

    # table_models = [@certification_path] + @certification_path.scheme_mixes.to_a
    #
    # while table_models.any?
    #   start_new_page
    #   draw_page do
    #     (1..2).each do |i|
    #       newline(2) if i == 2
    #       if table_models.any?
    #         table_model = table_models.shift
    #         table_model.is_a?(SchemeMix) ? draw_category_table(table_model) : draw_scheme_mix_table(table_model)
    #       end
    #     end
    #   end
    # end

    draw_footers
  end

  def draw_headers
    repeat(:all) do
      bounding_box([@document.bounds.left, @document.bounds.top], width: 120, height: HEADER_HEIGHT) do
        image image_path(HEADER_LOGO), width: 120
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
      box_width = 120
      bounding_box([@document.bounds.left, @document.bounds.bottom], width: box_width, height: FOOTER_HEIGHT) do
        text 'Crafting a Green Legacy', size: 8, color: '555555', align: :left
      end
      bounding_box([@document.bounds.right - box_width, @document.bounds.bottom], width: box_width, height: FOOTER_HEIGHT) do
        text 'www.gord.qa', size: 8, color: '555555', align: :right
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
      text 'GSAS ID: ', style: :bold
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
    rescue LinkmeService::ApiError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      text 'An error occurred when creating the chart.'
    end
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
        '******'
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
        2.5
    ]

    point_radius = [
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
        4,
        0, 0, 0, 0,
        4
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

    begin
      image chart_generator.generate_chart(barchart_config, 600, 400).path, width: 450
    rescue LinkmeService::ApiError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      text 'An error occurred when creating the chart.'
    end
  end

  def draw_certificate_table(total_category_scores)
    # Prepare table data
    data = []
    data.append(%w(No Category Point))

    # Add the category rows to the table
    total_category_scores.each do |category_code, category|
      data.append([category_code, category[:name], number_with_precision(category[:achieved_score], precision: 3)])
    end

    # Add footer to the table
    data.append(['', 'Total points', number_with_precision(@score, precision: 3)])
    data.append(['', 'Level achieved', @stars])

    # Output table
    draw_table(data, true)
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

  def draw_table(data, has_level_achieved_footer = false)
    table(data, width: @document.bounds.right - CONTENT_PADDING) do
      # Set default cell style
      cells.align = :center
      cells.borders = []
      cells.padding = 0
      cells.border_width = 0.5

      # Set column widths
      column(0).width = width / 4
      column(1).width = width / 2
      column(2).width = width / 4

      # Header row style
      header_row = row(0)
      header_row.background_color = 'F0FBDC'
      header_row.font_style = :bold
      header_row.borders = %i(top bottom)
      header_row.padding = [14, 0, 14, 0]
      header_row.border_top_color = '69AB87'
      header_row.border_top_width = 3

      # Content rows style
      content_rows = rows(1..row_length - 1)
      content_rows.column(1).align = :left
      content_rows.column(1).borders = %i(left right)
      content_rows.padding = [2, 4, 2, 4]

      # Footer rows
      if has_level_achieved_footer
        total_points_row = row(row_length - 2)

        # Level achieved footer row style
        level_achieved_row = row(row_length - 1)
        level_achieved_row.borders = %i(bottom)
        level_achieved_row.font_style = :bold
        level_achieved_row.size = 14
        level_achieved_row.column(1).align = :right
        level_achieved_row.column(1).borders = %i(right bottom)
        level_achieved_row.column(2).background_color = '69AB87'
        level_achieved_row.column(2).text_color = 'FFFFFF'
      else
        total_points_row = row(row_length - 1)
      end

      # Total points footer row style
      total_points_row.borders = %i(top bottom)
      total_points_row.font_style = :bold
      total_points_row.column(1).align = :right
      total_points_row.column(1).borders = %i(top right bottom)
    end
  end
end
