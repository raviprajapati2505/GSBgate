// let projects = []
filtered = {}

dataElement = document.getElementById("certData")
yearElement = document.getElementById("cutoff-year")

filter1Element = document.getElementById("filter1")
filter2Element = document.getElementById("filter2")
filter3Element = document.getElementById("filter3")
filter4Element = document.getElementById("filter4")
filter5Element = document.getElementById("filter5")
filter6Element = document.getElementById("filter6")

modalElement = document.getElementById("modal")

graphSelectElement = document.getElementById("graphSelect")

// browser = document.getElementById('csvFile');

advancedFiltering = false;

// function addProjects (cb){
//     let csvfile = browser.files[0]||""
//     browser.onchange = async()=>{
//         if (browser.files[0]!==csvfile){
//             cb (await loadFile(browser.files[0]))
//         }
//     }

//     browser.click()
// }
/*
var browseData = ()=>{
    let csvfile = browser.files[0]||""
    browser.onchange = async()=>{
        if (browser.files[0]!==csvfile){
            projects = await loadFile(browser.files[0])
            prepareInputBox()
        }
    }

    browser.click()
}

var appendData = async()=>{
    let csvfile = browser.files[0]||""
    browser.onchange = async()=>{
        if (browser.files[0]!==csvfile){
            projects = [...projects, ...await loadFile(browser.files[0])]   
        }
    }

    browser.click()
}
*/

// function loadFile(projects) {
//   return trimNonValid(projects, "2023-01-01");
// }

function prepareInputBox() {
  let filterOptions = [
    "Certification Type",
    "Certification Status",
    "Certification Scheme",
    "Certification Rating",
    "Certification Year",
    "Project Country",
    "Project City",
    "Project Planning Type",
    "Project Developer",
    "Project Developer Business Sector",
    "Project Owner",
    "Project Owner Business Sector",
    "Project Use",
    "Project Service Provider",
    "Certification Method",
    "Certification Version",
    "Certification Submission Status",
    "Certification Active",
    "Certification PCR Track"
  ]

  let graphOptions = {
    "By Project Count": "",
    "By Building Area": "cArea",
    "By Site Area": "pArea",
    "By Area (Site+Building)": "combinedArea",
    "By Certified Buildings Count": "cNumber",
    "By Certified Sites": "pNumber"
  }

  let propsHTML = filterOptions.map(k => `<option value="${k}">${k}</option>`).join("");

  filter1Element.innerHTML = `<option value="">N/A</option>${propsHTML}`
  filter2Element.innerHTML = `<option value="">N/A</option>${propsHTML}`
  filter3Element.innerHTML = `<option value="">N/A</option>${propsHTML}`
  filter4Element.innerHTML = `<option value="">N/A</option>${propsHTML}`
  filter5Element.innerHTML = `<option value="">N/A</option>${propsHTML}`
  filter6Element.innerHTML = `<option value="">N/A</option>${propsHTML}`

  filter1Element.value = filterOptions[0];
  filter2Element.value = filterOptions[1];
  filter3Element.value = filterOptions[2];

  graphSelectElement.innerHTML = Object.keys(graphOptions).map(o => `<option value="${graphOptions[o]}">${o}</option>`).join("")
  graphSelectElement.value = ""

}

function toggleSelectAll(lvl) {
  let elements = document.getElementsByName("level-" + lvl.toString())
  let tog = !elements[0].checked;
  elements.forEach(el => el.checked = tog);
}

function showAdvancedFilters(keys, data, excluded) {
  let list = listKeysByLevel(data);
  list = list.map(lvl => [...new Set(lvl)])

  return list.map((keyOptions, lvl) => {
    return `
            <div class="filterBoxDiv m-3 row">
            <p><b>${keys[lvl]}</b></p>
            ` + keyOptions.sort().map(k => `
                  <div class="filterItemDiv col-md-2">
                      <input 
                          type="checkbox" 
                          onchange="flashFilter(${lvl})" 
                          class="filterItem mr-2" ${(excluded[lvl].indexOf(k)>-1)?'':'checked'} 
                          name="level-${lvl}" 
                          value="${k}">
                      <label class="m-2" for="${k}">${k.length>18?k.substring(0,15)+"...":k}</label>
                  </div>
            `).join("") + `
              </div>
              <button class="m-3" onclick="toggleSelectAll(${lvl})">Select/Deselect</button>
              <hr>
            `
  }).join("")
}

function toggleSidebar() {
  let btn = document.getElementById('sidebarBtn')
  let sidebar = document.getElementById('sidebar')

  if (sidebar.style.display === 'none') {
    sidebar.style.display = 'unset'
    btn.innerHTML = 'GSASgate Tabulation Tool <i class="fa fa-chevron-left" aria-hidden="true"></i>'

  } else {
    sidebar.style.display = 'none'
    sidebar.style.width = "0px!important"
    btn.innerHTML = '<i class="fa fa-chevron-right" aria-hidden="true"></i>'
  }
}

function flashFilter(lvl) {

  let included = []

  document.getElementsByName("level-" + lvl).forEach(el => {
    if (el.checked) included = [...included, el.value]
  })

  keys = [filter1Element.value, filter2Element.value, filter3Element.value, filter4Element.value, filter5Element.value, filter6Element.value];
  keys = keys.filter(i => i !== "");

  let relatedProjects = projects.filter(p => {
    for (let i = 0; i <= lvl; i++) {
      if (included.indexOf(p[keys[lvl]]) > -1) return true
    }
    return false;
  });

  for (let i = lvl + 1; i < keys.length; i++) {
    if (i === lvl) continue;

    let arr = [...new Set(relatedProjects.map(p => p[keys[i]]))]

    document.getElementsByName("level-" + i).forEach(el => {
      el.checked = (arr.indexOf(el.value) > -1);
      if (i > lvl) {
        el.parentNode.style.display = (arr.indexOf(el.value) > -1) ? "flex" : "none";
      }
    })
  }
}

function drawTables() {

  if (projects.length === 0) {
    showError("No file is loaded. Please browse CSV from the button above")
    return;
  }

  keys = [filter1Element.value, filter2Element.value, filter3Element.value, filter4Element.value, filter5Element.value, filter6Element.value];
  keys = keys.filter(i => i !== "");

  let excluded = Array(keys.length).fill([])
  let allOptions = groupByMultipleKeys(projects, keys, excluded)

  if (advancedFiltering) {
    for (i = 0; i < keys.length; i++) {
      document.getElementsByName("level-" + i).forEach(el => {
        if (!el.checked) {
          excluded[i] = [...excluded[i], el.value]
        }
      })
    }
  }

  filtered = groupByMultipleKeys(projects, keys, excluded)
  // console.log(filtered);
  dataElement.innerHTML = ""
  prepareTable(filtered, keys)

  document.getElementById("chartDiv").innerHTML = ""

  if (document.getElementById("graphChart").value === "1") {
    chart(filtered, graphSelectElement.value);
  } else {
    chart2(filtered, graphSelectElement.value);
  }

  document.getElementById("advancedFilters").innerHTML = showAdvancedFilters(keys, allOptions, excluded);
  advancedFiltering = true;
}

function prepareTable(projObject, propKeys) {

  let prop = propKeys[propKeys.length - 1]

  var detailsTable = document.createElement('table')
  detailsTable.id = "detailsTable"
  detailsTable.classList.add("details")

  let header = `
        <tr>
            <th>${prop}</td>
            <th>Quantity (Site)</td>
            <th>Area (Site)</td>
            <th>Quantity (Buildings)</td>
            <th>Area (Buildings)</td>
            <th>Details</td>
        </tr>
    `

  let totalPlotNum = 0;
  let totalPlotArea = 0;
  let totalBldgNum = 0;
  let totalBldgArea = 0;

  let i = 0;

  var getLevel = (obj, lvl) => {
    return Object.keys(obj).sort((a, b) => sortKeys(a, b, propKeys[lvl])).map((k, id) => {

      if (Array.isArray(obj[k])) {
        let valArr = obj[k];
        let rowClass = "GSAS-mixed"

        if (valArr.every(p => p["Certification Type"] === valArr[0]["Certification Type"])) rowClass = valArr[0]["Certification Type"];
        if (rowClass === "GSAS-D&B") rowClass = "GSAS-DB"

        let plotNum = valArr.reduce((a, b) => a + b.pNumber, 0) // numberOfPlots(valArr)
        let bldgNum = valArr.reduce((a, b) => a + b.cNumber, 0) //numberOfBldgs(valArr)

        let plotArea = valArr.reduce((a, b) => a + b.pArea, 0) //getOpenArea(valArr);
        let bldgArea = valArr.reduce((a, b) => a + b.cArea, 0) //getCertArea(valArr);


        totalPlotNum += plotNum
        totalBldgNum += bldgNum

        totalPlotArea += plotArea
        totalBldgArea += bldgArea

        let totalRow = ""

        if (id === Object.keys(obj).length - 1) {
          totalRow = `<tr class="total">
                        <td>Totals</td>
                        <td class="number">${totalPlotNum}</td><td class="number">${totalPlotArea.toLocaleString('en-US')}</td>
                        <td class="number">${totalBldgNum}</td><td class="number">${totalBldgArea.toLocaleString('en-US')}</td>
                        <td></td>
                    </tr><tr><td colspan="6" style="background:white;"></td></tr>`
          totalPlotNum = 0;
          totalPlotArea = 0;
          totalBldgNum = 0;
          totalBldgArea = 0;
        }
        i++;

        let projectsRows = valArr.map(p => {
          return `
                        <tr class="projectRow projectHidden" name="projects-${i}">
                            <td onclick="showProjectData('${p["Project ID"]}')">${p["Project ID"]}-${p["Project Name"]}</td>
                            <td class="number">${p.pNumber?1:0}</td>
                            <td class="number">${p.pArea.toLocaleString("en-US")}</td>
                            <td class="number">${p.cNumber?1:0}</td>
                            <td class="number">${p.cArea.toLocaleString("en-US")}</td>
                            <td></td>
                        </tr>
                    `
        }).join("")

        return `<tr class="${rowClass}">
                    <td>${k}</td>
                    <td class="number">${plotNum}</td><td class="number">${plotArea.toLocaleString('en-US')}</td>
                    <td class="number">${bldgNum}</td><td class="number">${bldgArea.toLocaleString('en-US')}</td>
                    <td><p onclick="showProjects(this,${i})" ><i class="fa fa-chevron-circle-down" aria-hidden="true"></i></p></td>
                </tr>${projectsRows}${totalRow}`
      } else {
        let specialClass = "";
        if (k == "GSAS-D&B") specialClass = "DB-Title"
        if (k == "GSAS-CM") specialClass = "CM-Title"
        if (k == "GSAS-OP") specialClass = "OP-Title"
        if (k == "GSAS-Ecoleaf") specialClass = "Ecoleaf-Title"

        return `
                    <tr></tr>
                    <tr>
                        <td colspan="6" class="lvl-${lvl} ${specialClass}">${k}</td>
                    </tr>
                    ${getLevel(obj[k],lvl+1)}
                `
      }
    }).join("")
  }

  detailsTable.innerHTML = header + getLevel(projObject, 0);
  dataElement.appendChild(detailsTable);
}

function sortKeys(a, b, k) {
  // console.log(k)
  switch (k) {
    case "Certification Scheme":
      let schemes = [
        "Core + Shell",
        "Districts",
        "Education",
        "Expo Site",
        "Entertainment",
        "Healthcare",
        "Hotels",
        "Industrial",
        "Light Industry",
        "Mosques",
        "Parks",
        "Railways",
        "Residential - Single",
        "Construction Site",
        "Offices",
        "Commercial",
        "Residential",
        "Hospitality",
        "Sports",
        "Transportation",
        "Workers Accomodation",
        "Operations",
        "Premium Scheme",
        "Standard Scheme",
        "Homes",
        "Healthy Building Mark",
        "Energy Neutral Mark",
        "Interiors",
        "Energy Centers",
        "Neighborhoods"
      ]

      return schemes.indexOf(a) < schemes.indexOf(b) ? -1 : 1;
      break;
    case "Certification Status":
      let stat = ["Registered", "Design Certified", "Design & Build Certified", "CM Certified", "OP Certified", "Ecoleaf Certified", "Provisional Ecoleaf Certified"]
      return stat.indexOf(a) < stat.indexOf(b) ? -1 : 1;
      break;
    case "Certification Type":
      let ctype = ["GSAS-D&B", "GSAS-CM", "GSAS-OP", "GSAS-Ecoleaf"]
      return ctype.indexOf(a) < ctype.indexOf(b) ? -1 : 1;
      break;
    case "Certification Rating":
      let rating = [
        "CERTIFIED",
        "*",
        "* *",
        "* * *",
        "* * * *",
        "* * * * *",
        "* * * * * *",
        "CLASS A*",
        "CLASS A",
        "CLASS B",
        "CLASS C",
        "CLASS D",
        "PLATINUM",
        "GOLD",
        "SILVER",
        "BRONZE",
        ""
      ]
      return rating.indexOf(a) < rating.indexOf(b) ? -1 : 1;
      break;
    default:
      return a.localeCompare(b)

  }
}

function showProjectData(pID) {
  let proj = projects.find(p => p["Project ID"] === pID)

  if (!proj) return;

  modalElement.innerHTML = `
        <p class="text-right"><i class="fa fa-times" aria-hidden="true" onclick="modalElement.style.display='none'"></i></p>
        <table class="project-details-table">
            ${Object.keys(proj).map((k)=>'<tr><td>'+k+'</td><td>'+proj[k]+'</td></tr>').join("")}
        </table>
        <button 
            class="mt-3"
            onclick="modalElement.style.display='none'">
            Close
        </button>`;

  modalElement.style.display = "flex";
}


function showProjects(el, i) {
  let projectNodes = document.getElementsByName("projects-" + i)

  if (projectNodes.length < 1) return

  if (projectNodes[0].classList.contains("projectHidden")) {
    projectNodes.forEach(row => row.classList.remove("projectHidden"))
    el.innerHTML = '<i class="fa fa-chevron-circle-up" aria-hidden="true"></i>'
  } else {
    projectNodes.forEach(row => row.classList.add("projectHidden"))
    el.innerHTML = '<i class="fa fa-chevron-circle-down" aria-hidden="true"></i>'
  }
}

