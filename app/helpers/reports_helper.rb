module ReportsHelper
  def certificate_name(name)
    binding.pry
    case name
    when 'Letter of Conformance'
      'LOC Design Certificate'
    when 'GSAS-CM'
      'Construction Management Certificate'
    when 'Operations Certificate'
      'Operations Certificate'
    when ''
    else
    end
  end
end