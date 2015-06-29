class SchemeMixCriterionLogsController < ApplicationController
  load_and_authorize_resource

  def index
    @logs = SchemeMixCriterionLog.for_criterion(params[:scheme_mix_criterion_id]).paginate page: params[:page], per_page: 10
    @scheme_mix_criterion = SchemeMixCriterion.find(params[:scheme_mix_criterion_id])
  end
end
