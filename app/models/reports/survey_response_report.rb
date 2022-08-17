class Reports::SurveyResponseReport < Reports::BaseReport
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

  def initialize(projects_survey, project)
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

    @projects_survey = projects_survey
    @project = project

    do_render
  end

  private

  def do_render
    draw_headers

    draw_page do
      newline(1)
      draw_survey_response_report
    end

    draw_footers
  end

  def draw_headers
    repeat(:all) do
      bounding_box([@document.bounds.left - 30, @document.bounds.top + 15], width: 580, height: HEADER_HEIGHT) do
        image image_path(HEADER_IMAGE), width: 580
      end
    
      newline
      bounding_box([@document.bounds.right - 125, @document.bounds.top - 45], width: 120, height: HEADER_HEIGHT) do
        text = "Released Date: #{@projects_survey&.released_at&.strftime('%d %B, %Y')}\n" 
        text2 = "Title: #{@projects_survey.title}"

        styled_text("<div style='font-size: 8; text-align: right'>#{text}</div>")
      end
    end
  end

  def draw_page
    bounding_box([CONTENT_PADDING, @document.bounds.top - HEADER_HEIGHT], width: @document.bounds.right - CONTENT_PADDING * 2, height: @document.bounds.top - HEADER_HEIGHT - FOOTER_HEIGHT) do
      yield
    end
  end

  def draw_survey_response_report

    latest_questions = @projects_survey.survey_questionnaire_version&.survey_questions

    data = []
    newline(1)
    data.append(["Project", @project.code])
    data.append(["Survey Type", @projects_survey.survey_type.title])
    data.append(["Survey Title", @projects_survey.title])
    data.append(["Total Questions", latest_questions.count])

    # basic information about survey
    draw_table(data, true, 'basic_table')

    newline(1)

    # all question of the survey
    latest_questions.each.with_index(1) do |question, i|
      styled_text("<div style='font-size: 13; line-height: 7; color: 000000;'>Que. #{i}: #{question.question_text}</div>")
      styled_text("<div style='font-size: 10; line-height: 7; color: 000000;'>Desc. : #{question.description}</div>")

      unless question.fill_in_the_blank?
        # all options with there report count of questions
        option_with_counts = survey_question_options_report(@projects_survey, question) rescue {}
        total_responses = @projects_survey.survey_responses.count rescue 0

        y_position = cursor

        bounding_box([0, y_position], width: 235) do
          option_with_counts.each.with_index(1) do |(key, value), index|
            styled_text("<div style='font-size: 10; line-height: 7; color: 000000;'>#{index}) #{key} (#{value} Out of #{total_responses})</div>")
          end
        end

        bounding_box([300, y_position], width: 235) do
          draw_options_graph(option_with_counts)
        end

      else
        question.question_responses.each.with_index(1) do |text_response, i|
          styled_text("<div style='font-size: 10; line-height: 7; color: 000000;'>Text Response #{i}: #{text_response.value}</div>")
          newline(1)
        end
      end

      newline(1)
      if i == 3 || i == 6 || i == 9 || i == 11
        start_new_page
      end
    end
  end

  def draw_footers
    repeat(:all) do
      bounding_box([@document.bounds.left - 30, @document.bounds.bottom + 30], width: 580, height: FOOTER_HEIGHT) do
        image image_path(FOOTER_IMAGE), width: 580
      end
    end
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
        header_row.column(0).background_color = 'a0cde8'
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
    end
  end

  def draw_options_graph(option_with_counts)
    chart_generator = ChartGeneratorService.new

    columnchart_config = {
      type: 'doughnut',
      data: {
        labels: option_with_counts.keys,
        font: {
          weight: "bold",
        },
        datasets: [
          {
            label: 'Count',
            data: option_with_counts.values,
            backgroundColor: [
              'rgb(255, 99, 132)',
              'rgb(54, 162, 235)',
              'rgb(255, 205, 86)',
              'rgba(54,111,178,255)'
            ],
            borderColor: 'rgba(54,111,178,255)',
            borderWidth: 1
          }
        ]
      },
      options: {
        indexAxis: 'x',
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

    begin
      image chart_generator.generate_chart(columnchart_config, 300, 150).path, width: 150, position: :left

    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError

      #  bounding_box([x, y], width: x+width, height: height, position: :center) do
          text "An error occurred when creating the chart.", align: :center
      #  end
    end

    newline(1)
  end
end