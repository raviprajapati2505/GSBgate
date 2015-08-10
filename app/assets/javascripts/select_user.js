$(function () {
    $('.select2-ajax').select2({
        placeholder: "Type the first letters of the email address",
        minimumInputLength: 1,
        ajax: {
            url: Routes.new_project_user_path({project_id: $('.select2-ajax').data('project-id')}),
            dataType: 'json',
            quietMillis: 250,
            data: function(term, page) {
                return {
                    q: term,
                    page: page
                };
            },
            results: function(data, page) {
                var more = (page * 25) < data.total_count;
                return {
                    results: data.items,
                    more: more
                };
            },
            cache: false
        },

    });
});