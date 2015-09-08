$(function () {
    $('.select2-ajax').select2({
        placeholder: "Type the first letters of the email address",
        ajax: {
            url: Routes.list_unauthorized_users_path({project_id: $('.select2-ajax').data('project-id')}),
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