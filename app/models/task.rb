class Task

  attr_accessor :model, :description_id

  def initialize(model:, description_id:)
    @model = model
    @description_id = description_id
  end

end