class Reports::LetterOfConformanceCoverLetter < Reports::BaseReport

  SIGNATURE_CLOSING = 'Yours sincerely,'
  ISSUER_NAME = 'Dr. Youssef Mohammad Alhorr'
  ISSUER_TITLE = 'Founding Chairman'

  def initialize(certification_path)
    # A4:: => 595.28 x 841.89 pt
    @document = Prawn::Document.new(:page_size => "A4",
                                    :page_layout => :portrait,
                                    :margin => 20
    )
    @certification_path = certification_path
    @scheme_names = @certification_path.schemes.collect{|scheme| scheme.name}.join ', '

    @addressee = "Mr. Bart Dooms\nPresident & CEO\nVITO BE"
    @addressee_copy = 'Service Provider:   Gulf Engineering & Industrial Office'
    @subject = 'Provisional Certificate to Global Sustainability Assessment System (GSAS v2.1)'
    @content = <<-CONTENTTEMPLATE
Dear Sir,

On behalf of Gulf Organisation for Research and Development, I would like to congratulate you on the successful completion of the Provisional Certification (LOC) stage of your project "#{@certification_path.project.name}", using #{@scheme_names}.

In recognition of this accomplishment and appreciation of your participation in the GSAS v2.1 certification process, I would like to confer this "Provisional Certificate-LOC" to your building with a total built-up area of <b>#{@certification_path.project.project_site_area}</b> m².

Based on the submitted data, the final score at the preliminary review stage is documented to be <b>#{@certification_path.scores_in_certificate_points[:achieved]}</b>, which corresponds to the certification level of <b>#{@certification_path.achieved_star_rating} star(s)</b> in the GSAS v2.1 Design Assessment Rating scheme. Figures 1 to 3 summarize the score for the buildings, the score per category, achieved GSAS v2.1 certification level and GSAS v2.1 scoring bar chart respectively. Also, LOC Criteria Scores for the project is attached.

Kindly be advised that, this letter is only the predecessor towards achieving GSAS v2.1 Design & Build Certificate and <u>should not be considered as the final certificate</u>. For the final GSAS v2.1 Design & Build Certificate, kindly ensure that all certification requirements, during and after the construction of the project, are satisfied (<u>LOC Compliance Audit</u>) as indicated in the GSAS Technical Guide.

In the event of any changes to the design plan, from previously assessed, please note that the project is required to be reassessed once again. To understand the terms and conditions pertaining to GSAS v2.1 certification, please refer to the certification policy on the website: <u><link href='http://www.gord.qa'>www.gord.qa</link></u>.

Congratulations once again for partaking in this noble endeavor, and together let us build a healthy and a sustainable future.

    CONTENTTEMPLATE
    @categories = []
    do_render
  end

  private

  def do_render
    font "Times-Roman", :size => 11
    draw_heading_date
    newline
    draw_heading_addressee
    newline
    draw_heading_addressee_copy
    newline
    draw_heading_subject
    newline
    draw_heading_project
    newline
    draw_content
    newline
    draw_signature

    @certification_path.scheme_mixes.each do |scheme_mix|
      start_new_page
      draw_category_table(scheme_mix)
    end
  end

  def draw_heading_date
    text 'Date: ' + @certification_path.to_s, :size => 9 if @certification_path.certified_at.present?
    text 'Ref: ' + @certification_path.project.code, :size => 9
  end

  def draw_heading_addressee
    text 'Attn:', :style => :bold
    text @addressee, :style => :bold
  end

  def draw_heading_addressee_copy
    text 'Cc: ' + @addressee_copy, :style => :bold
  end

  def draw_heading_subject
    curline = cursor
    size = 40
    bounding_box([0, curline], :width => size) do
      text 'Sub: ', :style => :bold
    end
    bounding_box([size, curline], :width => (@document.margin_box.width-size)) do
      text @subject
    end
  end

  def draw_heading_project
    curline = cursor
    size = 100
    bounding_box([0, curline], :width => size) do
      text 'Project Name: ', :style => :bold
      text 'QSAS ID: ', :style => :bold
    end
    bounding_box([size, curline], :width => (@document.margin_box.width-size)) do
      text @certification_path.project.name, :style => :bold
      text @certification_path.project.code, :style => :bold
    end
  end

  def draw_content
    text @content, :inline_format => true
  end

  def draw_signature
    text SIGNATURE_CLOSING
    newline
    text ISSUER_NAME, :style => :bold
    text ISSUER_TITLE, :style => :bold
  end

  def draw_category_table(scheme_mix)
    text scheme_mix.scheme.name, :style => :bold, :size => 24
    text "Weight: #{scheme_mix.weight}", :size => 12
    newline
    # prepare data
    data = []
    data.append(['Code', 'Category', 'Point'])
    scheme_mix.scheme_categories.each do |category|
      data.append([category.code, category.name, scheme_mix.scores_in_certificate_points_for_category(category)[:achieved]])
    end
    achieved_score = scheme_mix.scores_in_certificate_points[:achieved]
    data.append(['', 'Total score', achieved_score])
    data.append(['', 'Level achieved', CertificationPath.star_rating_for_score(achieved_score)])
    # render table
    table(data) do
      rows(0).background_color = '4A452A'
      rows(1..row_length-3).columns(2).background_color = '8DB4E3'
      rows(row_length-2).border_widths = [2, 1, 1, 1]
    end
  end

end