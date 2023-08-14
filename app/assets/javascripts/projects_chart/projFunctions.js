var BLDGS = /Core \+ Shell|Districts|Education|Entertainment|Expo Site|Healthcare|Hotels|Industrial|Light Industry|Mosques|Parks|Railways|Residential - Single|Construction Site|Offices|Commercial|Residential|Hospitality|Sports|Transportation|Workers Accomodation|Operations|Premium Scheme|Standard Scheme|Homes|Healthy Building Mark|Energy Neutral Mark|Interiors|Energy Centers|Neighborhoods/g

const certfictionStage = (project) => {
  let certifiedDescriptions = ["Certified", "Certificate Generated", "Certificate In Process"]

  switch (project["Certification Type"]) {
    case "GSAS-CM":
      if (project["Certification Stage"] === "GSAS Construction Management Certificate") {
        return 4;
      } else {
        return parseInt(project["Certification Stage"].substring(6.7));
      }
      break;
    case "GSAS-D&B":
      switch (project["Certification Stage"]) {
        case "Stage 2: CDA, Design & Build Certificate":
          return (certifiedDescriptions.indexOf(project["Certification Submission Status"]) > -1) ? 4 : 2;
        case "Stage 1: LOC, Design Certificate":
          return (certifiedDescriptions.indexOf(project["Certification Submission Status"]) > -1) ? 3 : 1;
        default:
          return 0;
      }
      break;
    case "GSAS-OP":
      return (certifiedDescriptions.indexOf(project["Certification Submission Status"]) > -1) ? 3 : 0;
      break;
    case "GSAS-Ecoleaf":
      switch (project["Certification Stage"]) {
        case "Stage 2: EcoLeaf Certificate":
          return (certifiedDescriptions.indexOf(project["Certification Submission Status"]) > -1) ? 4 : 2;
        case "Stage 1: Provisional Certificate":
          return (certifiedDescriptions.indexOf(project["Certification Submission Status"]) > -1) ? 3 : 1;
        default:
          return 0;
      }
      break;
  }
}

const getStageDescription = (project) => {
  switch (project["Certification Type"]) {
    case "GSAS-CM":
      return (certfictionStage(project) == 4) ? "CM Certified" : "Registered"
      break;
    case "GSAS-D&B":
      var stage = certfictionStage(project);
      if (stage == 4)
        return "Design & Build Certified";
      else if (stage < 2)
        return "Registered"
      else
        return "Design Certified"
      break;
    case "GSAS-OP":
      return (certfictionStage(project) == 3) ? "OP Certified" : "Registered"
      break;
    case "GSAS-Ecoleaf":
      var stage = certfictionStage(project);
      if (stage == 4)
        return "Ecoleaf Certified";
      else if (stage < 2)
        return "Registered"
      else
        return "Provisional Ecoleaf Certified"
      break;
  }
}

const getRating = (proj) => proj["Certification Rating"].match(new RegExp("*", "g")).length;

const trimNonValid = (arr, year) => {
  arr.forEach(p => {
    let awarded = p["Certification Awarded On"];
    if (awarded !== undefined && awarded !== null && awarded.length > 4) {
      p["Certification Awarded On"] = new Date(awarded)
      p["Certification Year"] = new Date(awarded).getFullYear().toString()
    } else {
      p["Certification Awarded On"] = new Date("1-Jan-2010")
      p["Certification Year"] = ""
    }

    let started = p["Certification Started On"];
    p["Certification Started On"] = new Date((started !== undefined && started !== null && started.length > 4) ? started : "1-Jan-2010")

  })

  let res = arr.filter((p) => {
    let pId = p["Project ID"]

    if (pId == 0) return false;

    //the ID length is variable and it cannot be used
    //if (pId.length!==15) return false

    if (pId === "TBC" || pId.trim().slice(-4) === "IVED" || pId.trim().slice(-4) === "IVE)") return false

    //if (p["Project Country"]!=="Qatar") return false;

    if (p["Certification Rating"] === "CERTIFICATION DENIED") return false;

    let awarded = p["Certification Awarded On"];
    let started = p["Certification Started On"];

    //remove recently registered projects
    if (started >= year) return false;

    let stage = certfictionStage(p);

    //remove FC issued recently and rely on older LOCs
    if (awarded >= year && stage === 4) return false
    //same for OP
    //if (awarded>=year && p["Certification Type"]==="GSAS-OP" && stage===3 ) return false

    //remove FC registered as they are already covered by awarded LOCs
    if (stage === 2) return false

    return true
  });

  res.forEach(p => {
    let awarded = p["Certification Awarded On"];
    let stage = certfictionStage(p);

    //revert recently awarded LOCs & Ecoleaf Provisional Certificates to Submitting stage;
    if (awarded >= year && stage == 3) {
      p["Certification Submission Status"] = "Submitting"
      p["Certification Year"] = ""
      p["Certification Awarded On"] = new Date("1-Jan-2010")
      p["Certification Rating"] = ""
    }

    //CM projects not fully certified to be considered as registered
    if (awarded >= year && stage < 4 && p["Certification Type"] === "GSAS-CM") {
      p["Certification Submission Status"] = "Submitting"
      p["Certification Year"] = ""
      p["Certification Awarded On"] = new Date("1-Jan-2010")
      p["Certification Rating"] = ""
    }

    if (stage < 4 && p["Certification Type"] === "GSAS-CM") {
      p["Certification Submission Status"] = "Submitting"
      p["Certification Year"] = ""
      p["Certification Awarded On"] = new Date("1-Jan-2010")
      p["Certification Rating"] = ""
    }

    //OP
    if (awarded >= year && p["Certification Type"] === "GSAS-OP" && stage === 3) {
      p["Certification Submission Status"] = "Submitting"
      p["Certification Year"] = ""
      p["Certification Awarded On"] = new Date("1-Jan-2010")
      p["Certification Rating"] = ""
    }
  })

  res = res.filter(p => !res.find(proj => proj["Project ID"] === p["Project ID"] && certfictionStage(proj) > certfictionStage(p)))

  //add processed data
  //add buildings for mixed-use and neighbourhoods with 0 area
  res.forEach(p => p["Certification Status"] = getStageDescription(p))
  res = addBuildings(res);

  res = prepareAreaAttr(res);

  res.forEach(p => p["Certification Rating"] = p["Certification Rating"].replaceAll(/\s+/g, " "))

  //check for duplicate values. Try do it often
  /*
  res.forEach(p=>{
      if (res.filter(p2=>p2["Project Name"]===p["Project Name"]).length>1){
          console.log(p["Project Name"])
      }
  })
  */

  return res;
}

const addBuildings = (projArr) => {

  projArr.filter(p => p["Certification Scheme"].substring(0, 3) === "Mix" || p["Certification Scheme"].substring(0, 3) === "Nei").forEach(p => {

    if (p["Certification Sub-Schemes"] === "") {
      //report weird projects
      // console.log(p);
      return false;
    }
    let bldgs = [];
    bldgs = p["Certification Sub-Schemes"].match(BLDGS);

    if (bldgs && bldgs.length > 0) {

      let modified = bldgs.indexOf("Core + Shell")
      if (modified > -1) bldgs[modified] = "Commercial"

      if (bldgs.length === 1) {
        p["Certification Scheme"] = bldgs[0];
        p["Certification Sub-Schemes"] = ""
      } else {
        bldgs.forEach(b => {
          let projBldg = {
            ...p
          };

          projBldg["Certification Scheme"] = b;
          projBldg["Certification Sub-Schemes"] = ""
          projBldg["Project Certified Area"] = "0";
          projBldg["Project Plot Area"] = "0";
          projBldg["Project Gross Built Up Area"] = "0";

          projArr = [...projArr, projBldg]
        })
      }
    }

  })

  return projArr;
}

const prepareAreaAttr = (projArr) => {
  return projArr.map(p => {

    let scheme = p["Certification Scheme"].substring(0, 3);
    let type = p["Certification Type"];

    let pArea = (scheme === "Dis" || scheme === "Par" || scheme === "Nei" || type === "GSAS-CM") ? parseNumber(p["Project Plot Area"]) : 0;

    let cArea = 0;
    if (scheme === "Nei") {
      cArea = parseNumber(p["Project Gross Built Up Area"]);
    } else if (scheme !== "Dis" && scheme !== "Par" && type !== "GSAS-CM") {
      cArea = parseNumber(p["Project Certified Area"]);
    }

    let pNumber = (scheme === "Dis" || scheme === "Par" || scheme === "Nei" || type === "GSAS-CM")
    let cNumber = !pNumber

    return {
      ...p,
      pArea,
      cArea,
      cNumber,
      pNumber,
      combinedArea: pArea + cArea
    }

  })
}
