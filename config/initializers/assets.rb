# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( maps/_gmaps.js )
Rails.application.config.assets.precompile += %w( maps/project.js )
Rails.application.config.assets.precompile += %w( fileicons/* )
Rails.application.config.assets.precompile += %w( select_user.js )
Rails.application.config.assets.precompile += %w( new_letter_of_conformance.js )
Rails.application.config.assets.precompile += %w( new_final_design.js )
Rails.application.config.assets.precompile += %w( checkbox_multicheck.js )
Rails.application.config.assets.precompile += %w( ckeditor/* )
Rails.application.config.assets.precompile += %w( certification_path.js )
Rails.application.config.assets.precompile += %w( score_widget.js )
Rails.application.config.assets.precompile += %w( audit_log_filter.js )
Rails.application.config.assets.precompile += %w( project_tools_library.js )