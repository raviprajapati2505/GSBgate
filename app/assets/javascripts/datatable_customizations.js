$(function() {

  // Change text 'csv' to 'download'
  $('.buttons-csv span').text("Download");

  function bindSelect2() {
    // Allow multi-select only to admin roles
    if (["system_admin", "gsas_trust_top_manager", "gsas_trust_manager", "gsas_trust_admin", "users_admin"].includes($("#projects-table, #users-table").data("user-role"))) {
      $(".multiple-select select").attr("multiple", true);
      $(".multiple-select select").select2();
    
      $(".select2-search-field input").remove();
      $(".select2-search-choice div").html("Select All");
    }

    if (["system_admin", "gsas_trust_top_manager", "gsas_trust_manager", "gsas_trust_admin", "document_controller"].includes($("#offline-projects-table").data("user-role"))) {
      $(".multiple-select select").attr("multiple", true);
      $(".multiple-select select").select2();
    
      $(".select2-search-field input").remove();
      $(".select2-search-choice div").html("Select All");
    }
  };

  function set_options_label() {
    var table = $("table.effective-datatable thead");
    var options_with_null = table.find('select option[value=""]');
    
    options_with_null.text("Select All");

    bindSelect2();
  };

  function bindDateRangePicker(searchInput) {
    if (searchInput.length > 0) {
      searchInput.daterangepicker({
        opens: 'left',
        locale: {
          format: 'DD/MM/YYYY',
          cancelLabel: 'Clear'
        }
      }, function(start_date, end_date, label) {
        searchInput.val(start_date.format('DD-MM-YYYY') + " - " + end_date.format('DD-MM-YYYY'))
        searchInput.trigger('keyup');
      });

      searchInput.val("");
      searchInput.attr("placeholder", "Select Range");

      searchInput.on('cancel.daterangepicker', function(ev, picker) {
        searchInput.val("");
        searchInput.trigger('keyup');
      });
    }
  }

  function bindYearPicker(searchInput){
    if (searchInput.length > 0) {
      searchInput.datepicker({
          opens: 'bottom',
          format: 'yyyy',
          viewMode: 'years',
          minViewMode: 'years',
          changeYear: true,
          startDate: '1900y',
          endDate: '2100y',
          autoclose: true
      });
    }
  }

  $('.custom-year-picker input').change(function(){
    $(this).trigger('keyup');
  })

  set_options_label();

  [
    'certification_path_started_at', 
    'certification_path_certified_at', 
    'certification_path_updated_at', 
    'certification_path_expires_at',
    'released_at',
    'end_date'
  ].forEach(function(date_for) {
    bindDateRangePicker($(".datatable_search_" + date_for + " input"));
  });

  let pageName = window.location.href.split('/').pop();

  if (pageName == 'projects' || pageName == '') {

    // Columns with their positions
    var columnNames = {} 
    columnNames["Certification Name"] = 2;
    columnNames["Project Name"] = 3;
    columnNames["Certification Method"] = 4;
    columnNames["Project Country"] = 5;
    columnNames["Certification Version"] = 6;
    columnNames["Project City"] = 7;
    columnNames["Certification Scheme"] = 8;
    columnNames["Project District"] = 9;
    columnNames["Certification Sub-Schemes"] = 10;
    columnNames["Project Address"] = 11;
    columnNames["Certification Building Name"] = 12;
    columnNames["Project Owner"] = 13;
    columnNames["Certification Stage"] = 14;
    columnNames["Project Developer"] = 15;
    columnNames["Certification Submission Status"] = 16;
    columnNames["Project Completion Year"] = 17;
    columnNames["Certification Score"] = 18;
    columnNames["Project Estimated Cost"] = 19;
    columnNames["Certification Rating"] = 20;
    columnNames["Project Description"] = 21;
    columnNames["Certification Started On"] = 22;
    columnNames["Project Plot Area"] = 23;
    columnNames["Certification Certified On"] = 24;
    columnNames["Project Gross Built Up Area"] = 25;
    columnNames["Certification Expiry On"] = 26;
    columnNames["Project Footprint"] = 27;
    columnNames["Certification Updated On"] = 28;
    columnNames["Project Certified Area"] = 29;
    columnNames["Certification Active"] = 30;
    columnNames["Project Carpark Area"] = 31;
    columnNames["Certification PCR Track"] = 32;
    columnNames["Project Planning Type"] = 33;
    columnNames["GSAS Trust Certification Manager"] = 34;
    columnNames["Project Use"] = 35;
    columnNames["GSAS Trust Certification Team"] = 36;
    columnNames["Project Service Provider"] = 37;
    columnNames["Enterprise Clients"] = 38;
    columnNames["Project CGP"] = 39;
    columnNames["blank_1"] = 40;
    columnNames["Project Team Members"] = 41;
    columnNames["blank_2"] = 42;
    columnNames["Project Service Provider"] = 43;

    $(".buttons-collection").on('click', function() {
      var fieldsCollection = $("ul.dt-button-collection");
      if (fieldsCollection.length > 0) {
        var mainList = $("ul.dt-button-collection");
        for (const item in columnNames) { 
          let tempElement
          if (['blank_1', 'blank_2'].includes(item) ) {
            $("li." + item).remove();
            tempElement = $.parseHTML("<li class='dt-button buttons-columnVisibility " + item + " hover-disabled' tabindex='0' aria-controls='effective-datatables-projects_certification_paths-389818376781'><a href='javascript:void(0)' disabled=disabled>&nbsp;</a></li>")

          } else {
            let listElement = $(".buttons-columnVisibility a:contains(" + item + ")").parent();
          
            if (listElement.length > 0) {
              tempElement = listElement
              // listElement.remove();
              tempElement.find("a").attr("href", "javascript:void(0)")
            }
          }

          mainList.append(tempElement);
        };

        // arrange show default button
        let showDefaultButton = $(".buttons-colvisRestore");
        showDefaultButton.find("a").attr("href", "javascript:void(0)")
        mainList.append(showDefaultButton);

        // arrange show all button
        let showAllButton = $(".buttons-colvisGroup");
        showAllButton.find("a").attr("href", "javascript:void(0)")
        mainList.append(showAllButton);
      }
    });
  }

  $("table.effective-datatable").on("column-visibility.dt", function(e, settings, column_number, state) {
    if (state) {
      var column = $(".col-order-" + column_number);
      if (column.hasClass("multiple-select")){
        // Allow multi-select only to admin roles
        if (["system_admin", "gsas_trust_top_manager", "gsas_trust_manager", "gsas_trust_admin"].includes($("#projects-table").data("user-role"))) {
          column.find("select").attr("multiple", true);
          column.find("select").select2();
          
          column.find(".select2-search-field input").remove();
          
          let select_option = column.find(".select2-search-choice div").html();
          if (Object.keys(columnNames).includes(select_option) || select_option == ""){ 
            column.find(".select2-search-choice div").html("Select All");
          }
        }

        if (["system_admin", "gsas_trust_top_manager", "gsas_trust_manager", "gsas_trust_admin","document_controller"].includes($("#offline-projects-table").data("user-role"))) {
          column.find("select").attr("multiple", true);
          column.find("select").select2();
          
          column.find(".select2-search-field input").remove();
          
          let select_option = column.find(".select2-search-choice div").html();
          if (Object.keys(columnNames).includes(select_option) || select_option == ""){ 
            column.find(".select2-search-choice div").html("Select All");
          }
        }

        let options_with_null = column.find('select option[value=""]');
        if (options_with_null.length > 1) {
          options_with_null[1].remove();
        }
        options_with_null.text("Select All");

      } else if (column.find("select").length > 0) {
        let options_with_null = column.find('select option[value=""]');
        if (options_with_null.length > 1) {
          options_with_null[1].remove();
        }
        options_with_null.text("Select All");

        // let select_option = column.find("select").find(":selected").html();
        // if (Object.keys(columnNames).includes(select_option) || select_option == ""){ 
        //   options_with_null.text("Select All");
        // }

      } else if (column.hasClass("date-range-filter")) {
        if (column.hasClass("col-certification_path_started_at")) {
          bindDateRangePicker($(".datatable_search_certification_path_started_at input"));
        } else if (column.hasClass("col-certification_path_certified_at")) {
          bindDateRangePicker($(".datatable_search_certification_path_certified_at input"));
        } else if (column.hasClass("col-certification_path_updated_at")) {
          bindDateRangePicker($(".datatable_search_certification_path_updated_at input"));
        } else if (column.hasClass("col-certification_path_expires_at")) {
          bindDateRangePicker($(".datatable_search_certification_path_expires_at input"));
        } else if (column.hasClass("col-survey_released_at date-range-filter")) {
          bindDateRangePicker($(".datatable_search_survey_released_at input"));
        } else if (column.hasClass("col-end_date date-range-filter")) {
          bindDateRangePicker($(".datatable_search_end_date input"));
        } 
      } else if (column.hasClass("custom-year-picker")){
        if (column.hasClass("col-construction_year")) {
          bindYearPicker($(".datatable_search_construction_year input"));
        } else if(column.hasClass("col-certification_certified_at")){
          bindYearPicker($(".datatable_search_certification_certified_at input"));
        }
      }
    }
  });
});
