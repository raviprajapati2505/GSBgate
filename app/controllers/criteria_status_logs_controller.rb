class CriteriaStatusLogsController < ApplicationController
  load_and_authorize_resource

  def index
    @logs = CriteriaStatusLog.for_criterion(params[:scheme_mix_criterion_id])
    @scheme_mix_criterion = SchemeMixCriterion.find(params[:scheme_mix_criterion_id])
  end
end
