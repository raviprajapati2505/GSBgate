# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( maps/_gmaps.js )
Rails.application.config.assets.precompile += %w( maps/project.js )
Rails.application.config.assets.precompile += %w( fileicons/* )
Rails.application.config.assets.precompile += %w( new_certificate.js )
Rails.application.config.assets.precompile += %w( checkbox_multicheck.js )
Rails.application.config.assets.precompile += %w( ckeditor/* )
Rails.application.config.assets.precompile += %w( score_widget.js )
Rails.application.config.assets.precompile += %w( project_tools_library.js )
Rails.application.config.assets.precompile += %w( orbitcontrols.js )
Rails.application.config.assets.precompile += %w( find_users_by_email.js )
Rails.application.config.assets.precompile += %w( select_user.js )
Rails.application.config.assets.precompile += %w( select_project_team_member.js )
Rails.application.config.assets.precompile += %w( select_project_certifier.js )
Rails.application.config.assets.precompile += %w( select_project.js )
Rails.application.config.assets.precompile += %w( select_project_certificate.js )
Rails.application.config.assets.precompile += %w( criteria_checkboxes.js )
Rails.application.config.assets.precompile += %w( document_uploader.js )
Rails.application.config.assets.precompile += %w( actual_images_uploader.js )
Rails.application.config.assets.precompile += %w( rendering_images_uploader.js )
Rails.application.config.assets.precompile += %w( task.js )
Rails.application.config.assets.precompile += %w( select_project_notifications.js )
Rails.application.config.assets.precompile += %w( select_owner.js )
Rails.application.config.assets.precompile += %w( incentive_scored.js )
