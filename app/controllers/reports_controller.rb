class ReportsController < ApplicationController
  # https://github.com/ryanb/cancan/wiki/Non-RESTful-Controllers
  # automatically calls authorize!(:action, :report)
  authorize_resource :class => false

  def certifiers_criteria
    respond_to do |format|
      format.html {
        @datatable = Effective::Datatables::CertifiersCriteria.new
      }
    end
  end

end