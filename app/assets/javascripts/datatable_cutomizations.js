$(function() {
  let pageName = window.location.href.split('/').pop();

  if (pageName == 'projects') {

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
    columnNames["Certification Sub-Typologies"] = 10;
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
    columnNames["Project Updated On"] = 26;
    columnNames["Project Footprint"] = 27;
    columnNames["Certification Active"] = 28;
    columnNames["Project Certified Area"] = 29;
    columnNames["Certification PCR Track"] = 30;
    columnNames["Project Carpark Area"] = 31;
    columnNames["GSAS Trust Certification Team"] = 32;
    columnNames["Project Service Provider"] = 33;
    columnNames["GSAS Trust Certification Manager"] = 34;
    columnNames["Project CGP"] = 35;
    columnNames["Enterprise Clients"] = 36;
    columnNames["Project Team Members"] = 37;
    columnNames["Project Type"] = 38;
    columnNames["Project Use"] = 39

    $(".buttons-collection").on('click', function(){
      var fieldsCollection = $("ul.dt-button-collection");
      if (fieldsCollection.length > 0) {
        var mainList = $("ul.dt-button-collection");
        for (const item in columnNames) { 
          let listElement = $(".buttons-columnVisibility a:contains(" + item + ")").parent();
          let tempElement = listElement
          listElement.remove();
          mainList.append(tempElement);
        };
      }
    });
  }
});


