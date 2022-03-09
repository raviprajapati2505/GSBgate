$(function() {

  function bindSelect2() {
    $(".multiple-select select").attr("multiple", true);
    $(".multiple-select select").select2();
    
    $(".select2-search-field input").remove();
    $(".select2-search-choice div").html("Select All");
  };

  function set_options_label() {
    var table = $("table.effective-datatable thead");
    var options_with_null = table.find('select option[value=""]');
    
    options_with_null.text("Select All");

    bindSelect2()
  };

  set_options_label();
  
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
    columnNames["Project Construction Year"] = 17;
    columnNames["Certification Score"] = 18;
    columnNames["Project Estimated Cost"] = 19;
    columnNames["Certification Rating"] = 20;
    columnNames["Project Description"] = 21;
    columnNames["Certification Started On"] = 22;
    columnNames["Project Plot Area"] = 23;
    columnNames["Certification Certified On"] = 24;
    columnNames["Project Gross Built Up Area"] = 25;
    columnNames["Certification Updated On"] = 26;
    columnNames["Project Footprint"] = 27;
    columnNames["Certification Active"] = 28;
    columnNames["Project Certified Area"] = 29;
    columnNames["Certification PCR Track"] = 30;
    columnNames["Project Carpark Area"] = 31;
    columnNames["GSAS Trust Certification Manager"] = 32;
    columnNames["Project Planning Type"] = 33;
    columnNames["GSAS Trust Certification Team"] = 34; 
    columnNames["Project Use"] = 35;
    columnNames["Enterprise Clients"] = 36;
    columnNames["Project Service Provider"] = 37;
    columnNames["blank_1"] = 38;
    columnNames["Project CGP"] = 39;
    columnNames["blank_2"] = 40;
    columnNames["Project Team Members"] = 41;
    columnNames["blank_3"] = 42;
    columnNames["Project Service Provider"] = 43;

    $(".buttons-collection").on('click', function(){
      var fieldsCollection = $("ul.dt-button-collection");
      if (fieldsCollection.length > 0) {
        var mainList = $("ul.dt-button-collection");
        for (const item in columnNames) { 
          let tempElement
          if (['blank_1', 'blank_2', 'blank_3'].includes(item) ) {
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

  $("table.effective-datatable").on("column-visibility.dt", function(e, settings, column, state) {
    set_options_label();
  });
});
