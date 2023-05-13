const parseNumber = (numberString)=>{   
    return Math.floor( parseInt(numberString.replaceAll(",",""))*10.764)
}

const groupByKey = (arr, key)=>{
    let res = {};
    
    arr.forEach(p=>{
        if (res[p[key]]!==undefined){
            res[p[key]] = [...res[p[key]], p]
        } else {
            res[p[key]] = [p]
        }
    })

    return res;
}

const groupByMultipleKeys = (projObj, keyArray, excluded, id)=>{
    if (id===undefined) id=0;
    if (id === keyArray.length) return projObj;
    
    let projObj2 = groupByKey(projObj, keyArray[id])
    //console.log(excluded[id],projObj2)

    let filteredKeys = Object.keys(projObj2).filter(k=>excluded[id].indexOf(k)<0);

    let r = filteredKeys.map(k=>groupByMultipleKeys(projObj2[k], keyArray, excluded, id+1)||[])

    //for some reason, I need to do this trick. I feel it is not neccessary, but I will figure it out later
    let r2={}
    filteredKeys.forEach((k,i)=>{
        r2[k] = r[i]
    })

    return r2;    
}

function listKeysByLevel(obj) {
    let result = [];
    let level = 0;
    function helper(obj, level) {
      if (!result[level]) {
        result[level] = [];
      }
      for (let key in obj) {
        result[level] = [...result[level],key];
        if (typeof obj[key] === "object" && !Array.isArray(obj[key])) {
          helper(obj[key], level + 1);
        }
      }
    }
    helper(obj, level);
    return result;
}


const copyTableNode = ()=>{
  var textToCopy = document.getElementById("detailsTable")?.cloneNode(true);

  if (textToCopy===null || textToCopy===undefined) {
      showError("No table is shown. Press Refine Data Button")
      return;
  }

  textToCopy.childNodes[1].childNodes.forEach((n)=>{ 
      if (n.classList !==  undefined)
          if (n.classList.contains("projectRow"))
              n.remove();        
  })
  
  return textToCopy;
}

function downloadFiltered() {

  var dlAnchorElem = document.getElementById('downloadAnchorElem');

  let dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(filtered));
  dlAnchorElem.setAttribute("href",     dataStr )
  dlAnchorElem.setAttribute("download", "gsas_stat.json");
  dlAnchorElem.click();
}

function showError(msg){
  var msgBox = document.getElementById("errorBox");

  msgBox.innerHTML = msg
  msgBox.style.color = "Black"
  msgBox.style.display = "Block"
  
  setTimeout(() => {
      msgBox.style.display = "None"
  }, 4000);
}


function exportToExcel(){
  var downloadurl;
  var dataFileType = 'application/vnd.ms-excel';

  var tableNode = copyTableNode();
  if (tableNode===undefined) return

  var tableHTMLData = tableNode.outerHTML.replace(/ /g, '%20');
  
  // Specify file name
  var filename = 'export_gsas_stat.xls';
  
  // Create download link element
  downloadurl = document.createElement("a");
  
  document.body.appendChild(downloadurl);
  
  if(navigator.msSaveOrOpenBlob){
      var blob = new Blob(['\ufeff', tableHTMLData], {
          type: dataFileType
      });
      navigator.msSaveOrOpenBlob( blob, filename);
  } else {
      // Create a link to the file
      downloadurl.href = `data: ${dataFileType} , ${tableHTMLData}`;
  
      // Setting the file name
      downloadurl.download = filename;
      
      //triggering the function
      downloadurl.click();
  }
}

function copyTable() {
  let tableNode = copyTableNode();
  if (tableNode!==undefined)
      navigator.clipboard.writeText(tableNode.outerHTML)
}
