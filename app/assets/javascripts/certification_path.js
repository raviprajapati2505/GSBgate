$(function () {
    $('#signed_by_mngr').on('ifToggled', function(e) {
        $.ajax({
            url: Routes.sign_certification_path_path($(this).data('projectId'), $(this).data('id')),
            data: {signed_by_mngr: $(this).is(':checked')},
            method: 'PUT'
        }).done(function(data) {
            toastr.success(data.msg)
        });
        e.preventDefault();
    });

    $('#signed_by_top_mngr').on('ifToggled', function(e) {
        $.ajax({
            url: Routes.sign_certification_path_path($(this).data('projectId'), $(this).data('id')),
            data: {signed_by_top_mngr: $(this).is(':checked')},
            method: 'PUT'
        }).done(function(data) {
            toastr.success(data.msg)
        });
        e.preventDefault();
    });
});
