$(function () {
    // Find user by email and add him to one of the tables
    $('.find-users-by-email-btn').click(function () {
        var modal = $(this).parents('.modal-body');
        var find_button = $(this)
        var help_block = modal.find('.help-block');
        var users_table = modal.find('.users-table');
        var form_group = modal.find('.form-group');
        var email_field = modal.find('.email-field');
        var existing_user_template = modal.find('.templates .existing-user').html();
        var unknown_user_template = modal.find('.templates .unknown-user').html();
        var error_user_template = modal.find('.templates .error-user').html();
        var findUsersByEmail = {
            showInfoMessage: function (message) {
                help_block.text(message);
                form_group.removeClass('has-error');
                find_button.removeClass('btn-danger').addClass('btn-white');
            },
            showErrorMessage: function (message) {
                help_block.text(message);
                form_group.addClass('has-error');
                find_button.addClass('btn-danger').removeClass('btn-white');
            },
            enableForm: function () {
                email_field.prop('disabled', false);
                find_button.prop('disabled', false);
            },
            disableForm: function () {
                email_field.prop('disabled', true);
                find_button.prop('disabled', true);
            },
            resetForm: function () {
                help_block.text('');
                email_field.prop('disabled', false).val('');
            },
            addTableRow: function (content) {
                users_table.show().children('tbody').append(content);
            }
        }

        // Remove all errors
        findUsersByEmail.showInfoMessage('Looking for users, please wait...');
        findUsersByEmail.disableForm();

        // Not an email
        if ((email_field.val().indexOf('@') == -1) || ((email_field.val().indexOf(' ') != -1))) {
            findUsersByEmail.showErrorMessage('This is not a valid email address.');
            findUsersByEmail.enableForm();
        }
        else {
            $.ajax({
                type: 'GET',
                url: Routes.find_users_by_email_users_path({email: encodeURIComponent(email_field.val()), project_id: modal.data('project-id'), gord_employee: modal.data('gord-employee')}),
                dataType: 'json',
                cache: false
            })
                .done(function (data) {
                    if (data.error) {
                        findUsersByEmail.showErrorMessage(data.error);
                    }
                    else {
                        if (data.total_count > 0) {
                            $.each(data.items, function (user_id, user_data) {
                                // Check uniqueness
                                if (modal.find("[data-user-uid='" + user_id + "']").length < 1) {
                                    if ('error' in user_data) {
                                        findUsersByEmail.addTableRow(error_user_template.replace(/____error____/g, user_data.error).replace(/____user_id____/g, user_id).replace(/____user_name____/g, user_data.user_name));
                                    }
                                    else {
                                        findUsersByEmail.addTableRow(existing_user_template.replace(/____user_id____/g, user_id).replace(/____user_name____/g, user_data.user_name));
                                    }
                                }
                            });
                        }
                        else {
                            // Check uniqueness
                            if (modal.find("[data-user-uid='" + email_field.val() + "']").length < 1) {
                                findUsersByEmail.addTableRow(unknown_user_template.replace(/____email____/g, email_field.val()));
                            }
                        }
                        findUsersByEmail.resetForm();
                    }
                    findUsersByEmail.enableForm();
                })
                .fail(function () {
                    findUsersByEmail.showErrorMessage('An error occurred when trying to find users by email. Please try again later.');
                    findUsersByEmail.enableForm();
                });
        }
    });

    // Remove user from table
    $('.find-users-modal').on('click', '.remove', function () {
        tbody = $(this).parent('td').parent('tr').parent('tbody');
        $(this).parent('td').parent('tr').remove();
        if (tbody.children().length < 2) {
            tbody.parent('table').hide();
        }
    });
});