/**
 * Created by danielsb on 21/03/2016.
 */

$(function() {
    $('.select2-ajax').each(function(idx, element) {
        $(this).on('change', function(e) {
            $('#project_owner').val($(this).select2('data').text);
        });
        const select_element = $(element);
        const url = Routes.owners_path();
        GSAS.load_list_ajax(select_element, '- Select a predefined property owner -', url,
            function(el, callback) {
                return $.ajax({
                    type: 'GET',
                    url: Routes.owner_path({id: el.val()}),
                    dataType: 'json',
                    cache: false
                }).done(function(data) {
                    const selection = {id: data.id, text: data.name};
                    callback(selection);
                });
            }
        );
    });

    function populate_country_location(element){
      let country_name = element.find(":selected").val();
      if(country_name.length > 0){
        $.ajax({
          url: "/projects/country_locations",
          method: "GET",
          dataType: "script",
          data: {
            country: country_name,
          },
          error: function(){
            alert('Something went wrong !');
          }
        });
      }
    }

    $('.country-select').on('change', function(){
      populate_country_location($(this));
    });
});